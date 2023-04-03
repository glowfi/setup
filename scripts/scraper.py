import logging
import os
import time

# import platform
import re
import subprocess
import sys

import mov_cli.__main__ as movcli
from fzf import fzf_prompt

from .httpclient import HttpClient
from .lang import getlang, setlang
from .player import PlayerNotFound
from ..players.mpv import Mpv
from ..players.vlc import Vlc
from ..extractors.doodstream import dood

# import shlex
# required for development

# Not needed
# def determine_path() -> str:
#    plt = platform.system()
#    if plt == "Windows":
#        return f"C://Users//{os.getenv('username')}//Downloads"
#    elif (plt == "Linux") or (plt == "Darwin"):
#        return f"/home/{os.getlogin()}/Downloads"
#    else:
#        print("Please open an issue for your os")
#        sys.exit(-2)


class WebScraper:
    def __init__(self, base_url: str) -> None:
        self.client = HttpClient()
        self.base_url = base_url
        self.title, self.url, self.aid, self.mv_tv = 0, 1, 2, 3
        self.translated = getlang()
        (
            self.task,
            self.exit,
            self.searcha,
            self.download,
            self.sprovider,
            self.dshow,
            self.dseason,
            self.tse,
            self.tep,
            self.change,
        ) = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        pass

    @staticmethod
    def parse(txt: str) -> str:
        return re.sub(r"\W+", "-", txt.lower())

    def dl(
        self,
        url: str,
        name: str,
        subtitle: str = None,
        season="",
        episode=None,
        referrer: str = None,
    ):
        name = self.parse(name).strip() + "--" + str(int(time.time()))
        name = re.sub(r"-+", " ", name)
        if season is None:
            pass
        else:
            name = f"{name}S{season}E{episode}".strip() + "--" + str(int(time.time()))

        # Copy URL to clipboard
        subprocess.run("xclip", universal_newlines=True, input=url)
        CRED = "\033[91m"
        CEND = "\033[0m"
        print()
        print("Scraped URL copied to clipboard:")
        print(CRED + f"{url}" + CEND)

        # Download video
        os.system("mkdir -p ~/Downloads")
        path = os.path.expanduser(f"~/Downloads/{name}/")
        subprocess.getoutput(f'mkdir "{path}"')
        os.chdir(path)
        subprocess.run(
            [
                "yt-dlp",
                "--ignore-errors",
                "--external-downloader",
                "aria2c",
                "--external-downloader-args",
                "-j 16 -x 16 -s 16 -k 1M --max-tries=0 --retry-wait=0",
                url,
                "-o",
                f"{name}.%(ext)s",
            ]
        )

        # Download subtitles
        # if subtitle:
        #     args = [
        #         "ffmpeg",
        #         "-i",
        #         f"{url}",
        #         "-vf",
        #         f"subtitle={subtitle}",
        #         f"{name}.srt",
        #     ]
        #     ffmpeg_process = subprocess.Popen(args)
        #     ffmpeg_process.wait()

        return "Downloaded !"

    def play(self, url: str, name: str, referrer=None):
        if referrer is None:
            referrer = self.base_url
        try:
            try:
                mpv_process = Mpv(self).play(url, referrer, name)
                mpv_process.wait()
            except (
                PlayerNotFound
            ):  # why do you even exist if you don't have MPV installed? WHY?
                vlc_process = Vlc(self).play(url, referrer, name)
                vlc_process.wait()
        except Exception as e:
            txt = f"{self.red('[!]')} Could not play {name}: MPV not found | {e}"
            logging.log(logging.ERROR, txt)
            # print(txt)  # TODO implement logging to a file
            sys.exit(1)

    def search(self, q: str = None) -> str:
        pass
        # return NotImplementedError()

    def results(self, data: str) -> list:
        pass
        # return NotImplementedError()

    def TV_PandDP(self, t: list, state: str = "d" or "p"):
        pass

    def MOV_PandDP(self, m: list, state: str = "d" or "p"):
        pass

    def SandR(self, q: str = None):
        return self.results(self.search(q))

    def display(self, q: str = None, result_no: int = None):
        result = self.SandR(q)
        r = []
        for ix, vl in enumerate(result):
            r.append(f"[{ix + 1}] {vl[self.title]} {vl[self.mv_tv]}")
        r.extend(
            [
                "",
                f"[q] {self.translated[self.exit]}",
                f"[s] {self.translated[self.searcha]}",
                f"[d] {self.translated[self.download]}",
                f"[p] {self.translated[self.sprovider]}",
                f"[sd] {self.translated[self.dshow]}",
                f"[ds] {self.translated[self.dseason]}",
                f"[c] {self.translated[self.change]}",
            ]
        )
        r = r[::-1]
        choice = ""
        while choice not in range(len(result) + 1):
            pre = fzf_prompt(r)
            choice = re.findall(r"\[(.*?)\]", pre)[0] if not result_no else result_no
            if choice == "q":
                sys.exit()
            elif choice == "s":
                return self.redo()
            elif choice == "p":
                return movcli.movcli()
            elif choice == "c":
                setlang()
                return movcli.movcli()
            elif choice == "d":
                try:
                    pre = fzf_prompt(r)
                    choice = (
                        re.findall(r"\[(.*?)\]", pre)[0] if not result_no else result_no
                    )
                    mov_or_tv = result[int(choice) - 1]
                    if mov_or_tv[self.mv_tv] == "TV":
                        self.TV_PandDP(mov_or_tv, "d")
                    else:
                        self.MOV_PandDP(mov_or_tv, "d")
                except ValueError as e:
                    print(
                        "[!]  Invalid Choice Entered! | ",
                        str(e),
                    )
                    sys.exit(1)
                except IndexError as e:
                    print(
                        "[!]  This Episode is coming soon! | ",
                        str(e),
                    )
                    sys.exit(2)
            elif choice == "sd":
                try:
                    pre = fzf_prompt(r)
                    choice = (
                        re.findall(r"\[(.*?)\]", pre)[0] if not result_no else result_no
                    )
                    mov_or_tv = result[int(choice) - 1]
                    if mov_or_tv[self.mv_tv] == "TV":
                        self.TV_PandDP(mov_or_tv, "sd")
                    else:
                        print("You selected a Movie")
                        exit(0)
                except ValueError as e:
                    print(
                        "[!]  Invalid Choice Entered! | ",
                        str(e),
                    )
                    sys.exit(1)
                except IndexError as e:
                    print(
                        "[!]  This Episode is coming soon! | ",
                        str(e),
                    )
                    sys.exit(2)
            elif choice == "ds":
                try:
                    pre = fzf_prompt(r)
                    choice = (
                        re.findall(r"\[(.*?)\]", pre)[0] if not result_no else result_no
                    )
                    mov_or_tv = result[int(choice) - 1]
                    if mov_or_tv[self.mv_tv] == "TV":
                        self.TV_PandDP(mov_or_tv, "ds")
                    else:
                        print("You selected a Movie")
                        exit(0)
                except ValueError as e:
                    print(
                        "[!]  Invalid Choice Entered! | ",
                        str(e),
                    )
                    sys.exit(1)
                except IndexError as e:
                    print(
                        "[!]  This Episode is coming soon! | ",
                        str(e),
                    )
                    sys.exit(2)
            else:
                mov_or_tv = result[int(choice) - 1]
                if mov_or_tv[self.mv_tv] == "TV":
                    self.TV_PandDP(mov_or_tv, "p")
                else:
                    self.MOV_PandDP(mov_or_tv, "p")

    def doodstream(self, url: str):
        return dood(url)

    def redo(self, search: str = None, result: int = None):
        print(result)
        return self.display(search, result)

    def askseason(self, seasons: int):
        texts = []
        for i in range(seasons):
            texts.append(f"{self.translated[self.tse]} {i+1}")
        choice = fzf_prompt(texts).split(" ")[-1]
        return choice

    def askepisode(self, episodes: int):
        texts = []
        for i in range(episodes):
            texts.append(f"{self.translated[self.tep]} {i+1}")
        choice = fzf_prompt(texts).split(" ")[-1]
        return choice
