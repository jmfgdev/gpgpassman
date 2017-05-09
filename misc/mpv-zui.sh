#!/bin/bash
# Title: mpv-zui
# Author: simonizor
# URL: http://www.simonizor.gq/scripts
# Dependencies: mpv, zenity
# Description: A simple script that launches a zenity GUI for opening files or urls in mpv.  Also has some useful arguments added that can be easily customized.

mpvfile () {
    MPVFILE=$(zenity --entry --cancel-label="Exit mpv-zui" --title=mpv-zui --entry-text="/home/$USER/" --text="Input the path to a local file or input a remote url.\nClick OK without changing the text in the entry field to browse for a file.")
    if [[ $? -eq 1 ]]; then
        exit 0
    fi
    if [ "$MPVFILE" = "/home/$USER/" ]; then
        MPVFILE=$(zenity --file-selection --filename="/home/$USER/")
        if [[ $? -eq 1 ]]; then
            exit 0
        fi
    fi
    mpvargs
}

mpvargs () {
    ARGFILE="$(< ~/.config/mpv-zui/args.conf)"
    MPVARGS=$(zenity --entry --title=mpv-zui --cancel-label="List options" --text="Input the arguments that you would like to run mpv with:" --entry-text="$ARGFILE")
        if [[ $? -eq 1 ]]; then
            mpv --list-options | zenity --text-info --cancel-label="Exit mpv-zui" --ok-label="Back" --width=710 --height=600 && mpvargs
        if [[ $? -eq 1 ]]; then
            exit 0
        fi
    fi
    if [ ! -d "~/.config/mpv-zui" ]; then
        mkdir ~/.config/mpv-zui
    fi
    echo "$MPVARGS" > ~/.config/mpv-zui/args.conf
    mpvrun
}

mpvrun () {
    mpv $MPVARGS "$MPVFILE"
    MPVARGS=""
    MPVFILE=""
    mpvfile
}

programisinstalled () { # check if inputted program is installed using 'type'
    return=1
    type "$1" >/dev/null 2>&1 || { return=0; }
}

programisinstalled "zenity"
if [ "$return" = "1" ]; then
    programisinstalled "mpv"
    if [ "$return" = "1" ]; then
        if [ ! -d "~/.config/mpv-zui" ]; then
            mkdir ~/.config/mpv-zui
        fi
        if [ ! -f "~/.config/mpv-zui/args.conf" ]; then
            echo "--border=no --vo=opengl --hwdec=vaapi" > ~/.config/mpv-zui/args.conf
        fi
        mpvfile
    else
        echo "mpv is not installed!"
    fi
else
    echo "zenity is not installed!"
fi