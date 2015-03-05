#!/bin/bash
[ ! -e ~/amixerlock ] && touch ~/amixerlock && amixer -D pulse -q sset Master 3%- && rm ~/amixerlock
