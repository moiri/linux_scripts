#!/bin/sh

# run mpd
log="/home/moiri/.config/mpd/log"
mpd 2>> $log

# mount the usb-hd connected to the router
gvfs-mount smb://fritz.nas/rahja/Samsung-M3Portable-01/music </home/moiri/.config/mpd/nas.cred

# run scrobbler for last.fm
mpdscribble
