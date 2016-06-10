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

if [ ! -z "$DVII1" -a ! -z "$HDMI1" -a -z "$VGA1" ]; then
    # I am at home
    echo "DVII1 (dock) and HDMI1 are plugged in, but not VGA1"
    xrandr --output HDMI1 --mode 1920x1200 --primary \
        --output VGA1 --off \
        --output eDP1 --off
    # only one of those will run, the other will be ignored
    xrandr --output DVI-1-0 --mode 1024x768 --noprimary # dock without screen (only sound)
    xrandr --output DVII1 --mode 1920x1200 --noprimary # doch with screen
    # set lxpanel position
    sed -i 's/monitor=1/monitor=0/g' /home/$xuid/.config/lxpanel/Lubuntu/panels/panel
    lxpanelctl restart
elif [ ! -z "$HDMI1" -a -z "$VGA1" ]; then
    # I am at home
    echo "DVII1 (dock) and HDMI1 are plugged in, but not VGA1"
    xrandr --output HDMI1 --mode 1920x1200 --primary \
        --output VGA1 --off \
        --output eDP1 --off
    # set lxpanel position
    sed -i 's/monitor=1/monitor=0/g' /home/$xuid/.config/lxpanel/Lubuntu/panels/panel
    lxpanelctl restart
elif [ -z "$DVII1" -a -z "$HDMI1" -a ! -z "$VGA1" ]; then
    # I am at UH
    echo "VGA1 is plugged in, but not DVII1 (dock) and HDMI1"
    xrandr --output HDMI1 --off \
        --output eDP1 --mode 1920x1080 --noprimary \
        --output VGA1 --mode 1920x1080 --right-of eDP1 --primary
    # set lxpanel position
    sed -i 's/monitor=0/monitor=1/g' /home/$xuid/.config/lxpanel/Lubuntu/panels/panel
    lxpanelctl restart
elif [ -z "$DVI-0-1" -a -z "$DVII1" -a -z "$HDMI1" -a -z "$VGA1" ]; then
    # I use the notebook without anything connected
    echo "No external monitors are plugged in"
    xrandr --output HDMI1 --off \
        --output VGA1 --off \
        --output eDP1 --mode 1920x1080 --primary
    # set lxpanel position
    sed -i 's/monitor=1/monitor=0/g' /home/$xuid/.config/lxpanel/Lubuntu/panels/panel
    lxpanelctl restart
else
    # I did not think of this configuration -> just run the internal screen
    xrandr --output HDMI1 --off \
        --output VGA1 --off \
        --output eDP1 --mode 1920x1080 --primary
    # set lxpanel position
    sed -i 's/monitor=1/monitor=0/g' /home/$xuid/.config/lxpanel/Lubuntu/panels/panel
    lxpanelctl restart
fi
