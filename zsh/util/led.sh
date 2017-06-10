#!/bin/bash

status=`xset -q | grep 'Scroll Lock' | awk -F 'Scroll Lock:' '{print $2}' | awk '{$1=$1};1'`

if [[ "$status" == "on" ]]; then
    xset led off
else
    xset led on
fi
