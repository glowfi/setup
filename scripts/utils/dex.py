#!/bin/python
import os


LAN_IP = "192.168.1.101:5555"

# STEP 1
print("Plug Your Phone.....")
plugged = input("Type P/p if phone is plugged: ")
if plugged == "p" or plugged == "P":
    os.system("adb kill-server")
    os.system("adb tcpip 5555")

    # STEP 2
    print("Unplug Your Phone....")
    unplugged = input("Type U/u if phone is plugged: ")
    if unplugged == "u" or unplugged == "U":
        os.system(f"adb connect {LAN_IP}")
        print("Waiting for accepting the promt ...")
        os.system(f"adb connect {LAN_IP}")

        # STEP 3
        promptAccepted = input("Type A/a if prompt accepted:")
        if promptAccepted == "a" or promptAccepted == "A":
            os.system(
                "setsid scrcpy --display 2 --bit-rate 32M --window-title 'DexOnLinux' --turn-screen-off --stay-awake"
            )
