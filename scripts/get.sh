#!/bin/bash

link="$1"
name=$(echo "$link" | awk -F"/" '{print $NF}') 
curl "$link" -o ~/"$name"
