#!/bin/python

import os
from pyfzf.pyfzf import FzfPrompt

fzf = FzfPrompt()

# Savegame link
data = {
    "L.A. Noire": ["https://0x0.st/HXxs.zip"],
    "Control": ["https://0x0.st/HXM9.zip"],
    "Red Dead Redemption 2": ["https://0x0.st/H4FT.zip"],
}


def getSave():
    names = list(data.keys())
    retrieveGame = fzf.prompt(names)[0]
    os.system(f"aria2c '{data[retrieveGame][0]}' -o '{retrieveGame}.zip'")


def heroicSave():
    # Get Game Name
    cmd_1 = """ls $HOME/Games/Heroic/Prefixes/ | fzf>>1.txt"""
    os.system(f"{cmd_1}")
    if os.path.getsize("1.txt") == 0:
        os.system("rm -rf 1.txt")
        exit()
    f = open("1.txt", "r")
    getGame = f.readlines()
    gameName = getGame[0].strip("\n").strip(" ")
    os.system("rm -rf 1.txt")

    # Get Savegame Location
    cmd_2 = f"""find "$HOME/Games/Heroic/Prefixes/{gameName}/pfx/drive_c/users/steamuser/AppData" -maxdepth 2 -type d | fzf>>2.txt"""
    os.system(f"{cmd_2}")
    f = open("2.txt", "r")
    getGameLocation = f.readlines()
    os.system("rm -rf 2.txt")

    # Copy the save
    loc = getGameLocation[0].strip("\n").strip(" ")
    cmd_3 = f"""cp -r \"{loc}\" $HOME/Downloads"""
    os.system(f"{cmd_3}")

    # Make a zip of the save
    getFolderName = loc.split("/")[-1]
    cmd_4 = f'''cd $HOME/Downloads;zip -r "{gameName}.zip" "{getFolderName}"'''
    os.system(f"{cmd_4}")


def steamSave():
    # Get Game Name
    cmd_1 = """protontricks -l|sed '$d'|sed '$d' |sed '$d'|sed '$d'|sed '$d'|sed '1d'>>1.txt"""
    os.system(f"{cmd_1}")
    if os.path.getsize("1.txt") == 0:
        os.system("rm -rf 1.txt")
        exit()
    f = open("1.txt", "r")
    k = f.readlines()
    s = ""
    for i in k:
        l = i.strip("\n").strip(" ")
        s += l + "\n"
    os.system("rm -rf 1.txt")

    # Get Savegame Location
    os.system(f"printf '{s}'|fzf>>2.txt")
    f = open("2.txt", "r")
    getGame = f.readlines()
    os.system("rm -rf 2.txt")
    k1 = getGame[0].strip("\n").strip(" ")
    getAppid = k1.split("(")[1].replace(")", "")
    getName = k1.split("(")[0].strip(" ")
    cmd_2 = f"""find "$HOME/.local/share/Steam/steamapps/compatdata/{getAppid}/pfx/drive_c/users/steamuser" -maxdepth 3 -type d | fzf>>3.txt"""
    os.system(f"{cmd_2}")

    # Copy the save
    f = open("3.txt", "r")
    getGame = f.readlines()
    os.system("rm -rf 3.txt")
    k2 = getGame[0].strip("\n").strip(" ")
    cmd_3 = f"""cp -r \"{k2}\" $HOME/Downloads"""
    os.system(f"{cmd_3}")

    # Make a zip of the save
    getFolderName = k2.split("/")[-1]
    cmd_4 = f'''cd $HOME/Downloads;zip -r "{getName}.zip" "{getFolderName}"'''
    os.system(f"{cmd_4}")


platforms = ["Scrape-Steam", "Scrape-Heroic", "Get-Saves"]
choice = fzf.prompt(platforms)[0]
if choice == "Scrape-Steam":
    steamSave()
elif choice == "Scrape-Heroic":
    heroicSave()
elif choice == "Get-Saves":
    getSave()
else:
    print("Exited!")
