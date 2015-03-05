#!/bin/bash
[ ! -e ~/amixerlock ] && touch ~/amixerlock && amixer -D pulse -q sset Master toggle && rm ~/amixerlock
