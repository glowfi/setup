#!/usr/bin/python

import requests
import webbrowser
import argparse


class reverseSearchbyImage:
    """Python script to identify by a given image."""

    def __init__(self, *args):
        self.image = args[0]

    def revSearch(self):
        searchUrl = "http://www.google.hr/searchbyimage/upload"
        multipart = {
            "encoded_image": (self.image, open(self.image, "rb")),
            "image_content": "",
        }
        response = requests.post(searchUrl, files=multipart, allow_redirects=False)
        fetchUrl = response.headers["Location"]
        webbrowser.open(fetchUrl)


parser = argparse.ArgumentParser()
parser.add_argument(
    "--image", type=str, required=True, help="Provide the image to search"
)
args = parser.parse_args()
reverseSearchbyImage(f"{args.image}").revSearch()
