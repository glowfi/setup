#!/bin/python

import pyperclip

# Get the string from the clipboard
text = pyperclip.paste()

words = text.split()

current_line = ""  # initialize an empty string for the current line
formatted = ""

for word in words:
    if len(current_line + word) <= 100:
        current_line += word + " "
    else:
        formatted += current_line + "\n"
        current_line = word + " "


pyperclip.copy(formatted)
