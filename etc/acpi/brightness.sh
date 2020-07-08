#!/bin/bash

current_brightness=`cat /sys/class/backlight/intel_backlight/brightness`
max_brightness=`cat /sys/class/backlight/intel_backlight/max_brightness`

if [ $1 == "up" ] 
then
	new_brightness=$(($current_brightness + 100))
	[ $new_brightness -gt $max_brightness ] && new_brightness=$max_brightness
else
	new_brightness=$(($current_brightness - 100))
	[ $new_brightness -lt 0 ] && new_brightness=0
fi

echo $new_brightness > /sys/class/backlight/intel_backlight/brightness
