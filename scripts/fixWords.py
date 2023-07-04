#!/bin/python

import pyperclip

text = pyperclip.paste()


words = text.split(" ")
words = " ".join(words)


def format_text(text):
    formatted_text = ""
    for i in range(0, len(text), 100):
        formatted_text += text[i : i + 100] + "\n"
    return formatted_text


pyperclip.copy(format_text(words))
