#!/bin/bash
[ ! -e ~/amixerlock ] && touch ~/amixerlock && amixer -D pulse -q sset Master unmute 3%+ && rm ~/amixerlock
