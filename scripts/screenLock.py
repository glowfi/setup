#!/bin/python

import time
import cv2
from tkinter import Tk, Canvas, Label, font
from pynput import keyboard
import os
import signal
import requests
import random
import argparse
import getpass
import hashlib
import json
from playsound import playsound
import threading

CONFIG_LOC = os.path.expanduser("~/.config/screensaver")
CONFIG_LOC_FILENAME = "hash.txt"
VIDEO_LOC_FILENAME = os.path.expanduser("~/.config/screensaver/vid.json")
URL = "https://0x0.st/HT-u.json"
LOCK_SOUND_LOC = os.path.expanduser("~/.misc/lock.mp3")
UNLOCK_SOUND_LOC = os.path.expanduser("~/.misc/unlock.mp3")
TYPE_SOUND_LOC = os.path.expanduser("~/.misc/type.mp3")
WRONG_SOUND_LOC = os.path.expanduser("~/.misc/wrong.mp3")

string = ""
matched = None


def getPass(message):
    # Compute the SHA-256 hash of the message
    hash_object = hashlib.sha512(message.encode())

    # Get the hexadecimal representation of the hash
    hex_digest = hash_object.hexdigest()

    # Print the hash
    return hex_digest


def destroyScreen():
    pid = os.getpid()
    os.kill(pid, signal.SIGTERM)


def play_sound_typing(loc):
    playsound(loc)


def listenKey():
    def on_key_press(key):
        global string
        try:
            if key == keyboard.Key.enter:
                if getPass(string) == matched:
                    if os.path.exists(UNLOCK_SOUND_LOC):
                        playsound(UNLOCK_SOUND_LOC)
                        os.system("killall -9 i3lock")
                    destroyScreen()
                else:
                    if os.path.exists(WRONG_SOUND_LOC):
                        playsound(WRONG_SOUND_LOC)
                    string = ""
            elif key == keyboard.Key.backspace:
                if len(string) > 0:
                    string = string.rstrip(string[-1])
            else:
                if os.path.exists(TYPE_SOUND_LOC):
                    threading.Thread(
                        target=play_sound_typing, args=(TYPE_SOUND_LOC,)
                    ).start()
                string += key.char
        except AttributeError as e:
            print(e)

    # Listen for keyboard input using pynput
    listener = keyboard.Listener(on_press=on_key_press)

    return listener


log = listenKey()


# Create the argument parser
parser = argparse.ArgumentParser(description="A Screensaver")

# Add the command-line arguments
parser.add_argument(
    "-ini",
    "--init",
    type=str,
    required=False,
    help="Initialize Database (y/n)",
)


# Parse the command-line arguments
args = parser.parse_args()

if args.init == "y":
    log.stop()
    if os.path.exists(f"{CONFIG_LOC}/{CONFIG_LOC_FILENAME}"):
        print("User Already Registered!")
        exit(0)
    password = getpass.getpass(prompt="Enter your password: ")
    val = getPass(password)

    os.mkdir(CONFIG_LOC)
    os.chdir(CONFIG_LOC)
    with open(f"{CONFIG_LOC_FILENAME}", "w") as f:
        f.write(val)

    # Get Data
    data = requests.get(URL)
    data = data.json()

    with open(f"{VIDEO_LOC_FILENAME}", "w") as f:
        json.dump(data, f)


else:
    if os.path.exists(f"{CONFIG_LOC}") and os.path.exists(
        f"{CONFIG_LOC}/{CONFIG_LOC_FILENAME}"
    ):
        with open(f"{CONFIG_LOC}/{CONFIG_LOC_FILENAME}", "r") as f:
            matched = str(f.readline()).strip(" ").rstrip("\n")

    if not matched:
        print("An error occured!")

    else:
        os.system("xdotool click 1")
        # Generate Random number
        with open(f"{VIDEO_LOC_FILENAME}", "r") as f:
            data = json.load(f)

        log.start()
        if os.path.exists(LOCK_SOUND_LOC):
            playsound(LOCK_SOUND_LOC)

        if data:
            while True:
                k = random.randint(0, len(data) - 1)
                currURL = data[str(k)]

                root = Tk()

                cap = cv2.VideoCapture(currURL)

                while True:
                    ret, frame = cap.read()
                    if not ret:
                        break
                    frame = cv2.resize(
                        frame, (root.winfo_screenwidth(), root.winfo_screenheight())
                    )
                    cv2.putText(
                        frame,
                        time.strftime("%H:%M:%S %p"),
                        (50, root.winfo_screenheight() - 50),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        2,
                        (255, 255, 255),
                        2,
                        cv2.LINE_AA,
                    )
                    cv2.putText(
                        frame,
                        "Type Password to unlock",
                        (60, root.winfo_screenheight() - 10),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1,
                        (255, 255, 255),
                        1,
                        cv2.LINE_AA,
                    )
                    cv2.namedWindow(
                        "Video", cv2.WINDOW_FULLSCREEN | cv2.WINDOW_GUI_NORMAL
                    )
                    cv2.setWindowProperty(
                        "Video", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN
                    )
                    cv2.imshow("Video", frame)

                    if cv2.waitKey(25) & 0xFF == ord("`"):
                        break

                cap.release()
                cv2.destroyAllWindows()
