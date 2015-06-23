#!/bin/bash
#initially created by codingtony (https://github.com/codingtony/udev-monitor-hotplug)
#Adapt this script to your needs.

DEVICES=$(find /sys/class/drm/*/status)

# debug=/home/moiri/monitor.log
displaynum=`ls /tmp/.X11-unix/* | sed s#/tmp/.X11-unix/X##`
display=":$displaynum"
export DISPLAY=":$displaynum"

# xuid=$(xhost | sed s#SI:localuser:## | tail -1)
xuid=$(ps -o uname,comm -A | grep lxpanel | grep -Eo '^[^ ]+')
uid=$(whoami)
if [ "$uid" == "root" ]; then
	# from https://wiki.archlinux.org/index.php/Acpid#Laptop_Monitor_Power_Off
  export XAUTHORITY=$(ps -C Xorg -f --no-header | sed -n 's/.*-auth //; s/ -[^ ].*//; p')
fi


#this while loop declare the $HDMI1 $VGA1 $LVDS1 and others if they are plugged in
while read l 
do 
  dir=$(dirname $l); 
  status=$(cat $l); 
  dev=$(echo $dir | cut -d\- -f 2-); 
  
  if [ $(expr match  $dev "HDMI") != "0" ]
  then
#REMOVE THE -X- part from HDMI-X-n
    dev=HDMI${dev#HDMI-?-}
  else 
    dev=$(echo $dev | tr -d '-')
  fi

  if [ "connected" == "$status" ]
  then 
    echo $dev "connected"
    declare $dev="yes"; 
  
  fi
done <<< "$DEVICES"


if [ ! -z "$HDMI1" -a ! -z "$VGA1" ]
then
  echo "HDMI1 and VGA1 are plugged in"
  xrandr --output eDP1 --off
  xrandr --output VGA1 --mode 1920x1080 --noprimary
  xrandr --output HDMI1 --mode 1920x1200 --right-of VGA1 --primary
elif [ ! -z "$HDMI1" -a -z "$VGA1" ]; then
  echo "HDMI1 is plugged in, but not VGA1"
  xrandr --output eDP1 --off
  xrandr --output VGA1 --off
  xrandr --output HDMI1 --mode 1920x1200 --primary
  # set lxpanel position
  sed -i 's/monitor=1/monitor=0/g' /home/$xuid/.config/lxpanel/Lubuntu/panels/panel
  lxpanelctl restart
elif [ -z "$HDMI1" -a ! -z "$VGA1" ]; then
  echo "VGA1 is plugged in, but not HDMI1"
  xrandr --output eDP1 --mode 1920x1080 --noprimary
  xrandr --output HDMI1 --off
  xrandr --output VGA1 --mode 1920x1080 --right-of eDP1 --primary
  # set lxpanel position
  sed -i 's/monitor=0/monitor=1/g' /home/$xuid/.config/lxpanel/Lubuntu/panels/panel
  lxpanelctl restart
else
  echo "No external monitors are plugged in"
  xrandr --output VGA1 --off
  xrandr --output HDMI1 --off
  xrandr --output eDP1 --mode 1920x1080 --primary
  # set lxpanel position
  sed -i 's/monitor=1/monitor=0/g' /home/$xuid/.config/lxpanel/Lubuntu/panels/panel
  lxpanelctl restart
fi

