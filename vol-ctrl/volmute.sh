#!/bin/bash
[ ! -e ~/amixerlock ] && touch ~/amixerlock && amixer -D pulse -q sset Master toggle && rm ~/amixerlock
# pactl set-sink-mute 0 toggle # was an unsuccessful test for pulseaudio
