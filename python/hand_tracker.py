#!/usr/bin/env python3
"""
MediaPipe Hand Tracking Bridge for Godot

Captures webcam, processes with MediaPipe Hands, sends landmarks via WebSocket.
Run this script before starting the Godot game.

Usage:
    python hand_tracker.py [--port 8765] [--camera 0] [--show-preview]
"""

import argparse
import asyncio
import json
import signal
import sys
import urllib.request
import os
from typing import Optional

import cv2
import numpy as np

# MediaPipe Tasks API
import mediapipe as mp
from mediapipe.tasks import python as mp_python
from mediapipe.tasks.python import vision

import websockets

# Global state
connected_clients: set = set()
should_exit = False
latest_frame_data: Optional[dict] = None

# Model path - using GestureRecognizer for gesture detection
MODEL_PATH = os.path.join(os.path.dirname(__file__), "gesture_recognizer.task")
MODEL_URL = "https://storage.googleapis.com/mediapipe-models/gesture_recognizer/gesture_recognizer/float16/1/gesture_recognizer.task"

# Hand connections for drawing
HAND_CONNECTIONS = [
    (0, 1), (1, 2), (2, 3), (3, 4),      # Thumb
    (0, 5), (5, 6), (6, 7), (7, 8),      # Index
    (0, 9), (9, 10), (10, 11), (11, 12), # Middle
    (0, 13), (13, 14), (14, 15), (15, 16), # Ring
    (0, 17), (17, 18), (18, 19), (19, 20), # Pinky
    (5, 9), (9, 13), (13, 17)            # Palm
]


def download_model():
    """Download the hand landmarker model if not present."""
    if os.path.exists(MODEL_PATH):
        return True

    print(f"Downloading hand landmarker model...")
    try:
        urllib.request.urlretrieve(MODEL_URL, MODEL_PATH)
        print("Model downloaded successfully!")
        return True
    except Exception as e:
        print(f"Failed to download model: {e}")
        return False


def signal_handler(sig, frame):
    """Handle Ctrl+C gracefully."""
    global should_exit
    print("\nShutting down...")
    should_exit = True


def process_hand_landmarks(hand_landmarks, handedness: str) -> dict:
    """Convert MediaPipe hand landmarks to serializable dict."""
    landmarks = []
    for i, lm in enumerate(hand_landmarks):
        landmarks.append({
            "id": i,
            "x": round(lm.x, 4),
            "y": round(lm.y, 4),
            "z": round(lm.z, 4)
        })

    return {
        "handedness": handedness,
        "landmarks": landmarks
    }


def get_hand_data(result) -> dict:
    """Extract hand data from MediaPipe GestureRecognizer results."""
    data = {
        "timestamp": 0,
        "left_hand": {},
        "right_hand": {},
        "num_hands": 0,
        "gestures": {
            "left": "None",
            "right": "None"
        },
        "two_open_palms": False
    }

    if result.hand_landmarks and result.handedness:
        data["num_hands"] = len(result.hand_landmarks)

        left_gesture = "None"
        right_gesture = "None"

        for i, (hand_landmarks, handedness_info) in enumerate(zip(
            result.hand_landmarks,
            result.handedness
        )):
            # Get handedness label
            label = handedness_info[0].category_name
            # Flip left/right since camera mirrors
            actual_hand = "right_hand" if label == "Left" else "left_hand"

            data[actual_hand] = process_hand_landmarks(
                hand_landmarks,
                actual_hand.replace("_hand", "")
            )

            # Get gesture for this hand
            if result.gestures and i < len(result.gestures) and result.gestures[i]:
                gesture_name = result.gestures[i][0].category_name
                if actual_hand == "left_hand":
                    left_gesture = gesture_name
                else:
                    right_gesture = gesture_name

        data["gestures"]["left"] = left_gesture
        data["gestures"]["right"] = right_gesture

        # Check for two open palms (CATCH gesture)
        data["two_open_palms"] = (left_gesture == "Open_Palm" and right_gesture == "Open_Palm")

    return data


def draw_landmarks(frame, result):
    """Draw hand landmarks on frame."""
    if not result.hand_landmarks:
        return frame

    h, w, _ = frame.shape

    for hand_landmarks in result.hand_landmarks:
        # Draw landmarks
        for lm in hand_landmarks:
            x, y = int(lm.x * w), int(lm.y * h)
            cv2.circle(frame, (x, y), 5, (0, 255, 0), -1)

        # Draw connections
        for start, end in HAND_CONNECTIONS:
            x1, y1 = int(hand_landmarks[start].x * w), int(hand_landmarks[start].y * h)
            x2, y2 = int(hand_landmarks[end].x * w), int(hand_landmarks[end].y * h)
            cv2.line(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

    return frame


async def broadcast_data(data: dict):
    """Send data to all connected WebSocket clients."""
    if not connected_clients:
        return

    message = json.dumps(data)
    disconnected = set()

    for client in list(connected_clients):  # Copy to list to avoid modification during iteration
        try:
            await client.send(message)
        except websockets.exceptions.ConnectionClosed:
            disconnected.add(client)

    connected_clients.difference_update(disconnected)


async def websocket_handler(websocket):
    """Handle new WebSocket connections."""
    connected_clients.add(websocket)
    client_addr = websocket.remote_address
    print(f"Client connected: {client_addr}")

    try:
        async for message in websocket:
            pass
    except websockets.exceptions.ConnectionClosed:
        pass
    finally:
        connected_clients.discard(websocket)
        print(f"Client disconnected: {client_addr}")


async def capture_and_process(camera_index: int, show_preview: bool):
    """Main capture loop."""
    global latest_frame_data, should_exit

    # Download model if needed
    if not download_model():
        print("Cannot proceed without model file.")
        should_exit = True
        return

    cap = cv2.VideoCapture(camera_index)

    if not cap.isOpened():
        print(f"Error: Could not open camera {camera_index}")
        should_exit = True
        return

    # Set camera properties
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FPS, 30)

    print(f"Camera {camera_index} opened successfully")
    print(f"Resolution: {int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))}x{int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))}")

    # Create gesture recognizer
    base_options = mp_python.BaseOptions(model_asset_path=MODEL_PATH)
    options = vision.GestureRecognizerOptions(
        base_options=base_options,
        running_mode=vision.RunningMode.IMAGE,
        num_hands=2,
        min_hand_detection_confidence=0.5,
        min_hand_presence_confidence=0.5,
        min_tracking_confidence=0.5
    )

    recognizer = vision.GestureRecognizer.create_from_options(options)

    frame_count = 0

    try:
        while not should_exit:
            success, frame = cap.read()
            if not success:
                await asyncio.sleep(0.01)
                continue

            frame_count += 1

            # Flip horizontally for selfie view
            frame = cv2.flip(frame, 1)

            # Convert BGR to RGB
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            # Create MediaPipe Image
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

            # Process with MediaPipe GestureRecognizer
            result = recognizer.recognize(mp_image)

            # Extract hand data
            data = get_hand_data(result)
            data["timestamp"] = frame_count
            latest_frame_data = data

            # Broadcast to connected clients
            await broadcast_data(data)

            # Optional preview window
            if show_preview:
                preview_frame = draw_landmarks(frame.copy(), result)

                # Add status text
                status = f"Hands: {data['num_hands']} | Clients: {len(connected_clients)}"
                cv2.putText(
                    preview_frame, status, (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2
                )

                # Show gestures
                left_g = data['gestures']['left']
                right_g = data['gestures']['right']
                gesture_text = f"L: {left_g} | R: {right_g}"
                cv2.putText(
                    preview_frame, gesture_text, (10, 60),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 0), 2
                )

                # Show detected gesture
                if data['two_open_palms']:
                    cv2.putText(
                        preview_frame, "CATCH! (2 palms)", (10, 100),
                        cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 255, 255), 3
                    )
                elif left_g == "Open_Palm" or right_g == "Open_Palm":
                    cv2.putText(
                        preview_frame, "1 HAND PASS", (10, 100),
                        cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 255, 0), 3
                    )

                cv2.imshow("Hand Tracking", preview_frame)

                if cv2.waitKey(1) & 0xFF == ord('q'):
                    should_exit = True
                    break

            # Limit to ~30fps
            await asyncio.sleep(1/30)

    finally:
        recognizer.close()
        cap.release()
        if show_preview:
            cv2.destroyAllWindows()


async def main(port: int, camera_index: int, show_preview: bool):
    """Main entry point."""
    global should_exit

    print(f"Starting Hand Tracking Bridge...")
    print(f"WebSocket server on ws://127.0.0.1:{port}")
    print(f"Using camera index: {camera_index}")
    print("Press Ctrl+C to stop (or 'q' in preview window)\n")

    # Start WebSocket server
    server = await websockets.serve(
        websocket_handler,
        "127.0.0.1",
        port
    )

    print(f"WebSocket server running on port {port}")

    # Run capture loop
    try:
        await capture_and_process(camera_index, show_preview)
    except KeyboardInterrupt:
        pass
    finally:
        should_exit = True
        server.close()
        await server.wait_closed()
        print("Server stopped")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="MediaPipe Hand Tracking Bridge")
    parser.add_argument("--port", type=int, default=8765, help="WebSocket port (default: 8765)")
    parser.add_argument("--camera", type=int, default=0, help="Camera index (default: 0)")
    parser.add_argument("--show-preview", action="store_true", help="Show camera preview window")

    args = parser.parse_args()

    signal.signal(signal.SIGINT, signal_handler)

    try:
        asyncio.run(main(args.port, args.camera, args.show_preview))
    except KeyboardInterrupt:
        print("\nStopped by user")
        sys.exit(0)
