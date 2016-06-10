#!/bin/bash
[ ! -e ~/amixerlock ] && touch ~/amixerlock && amixer -D pulse -q sset Master unmute 3%+ && rm ~/amixerlock
# sh -c "pactl set-sink-mute 0 false ; pactl set-sink-volume 0 +5%" # was an unsuccessful test for pulseaudio
