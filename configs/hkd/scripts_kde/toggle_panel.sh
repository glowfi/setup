#!/bin/sh

qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript "p = panelById(panelIds[0]); p.height = p.height>=35?-1:35;"
