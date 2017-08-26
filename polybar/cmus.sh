#!/bin/bash

prepend_zero () {
    seq -f "%02g" $1 $1
}

artist=$(echo -n $(cmus-remote -Q | grep artist -m 1 | cut -c 12-))
song=$(echo -n $(cmus-remote -Q | grep title -m 1 | cut -c 11-))

position=$(echo -n $(cmus-remote -Q | grep position | cut -c 10-))
minutes1=$(prepend_zero $((position / 60)))
seconds1=$(prepend_zero $((position % 60)))

duration=$(echo -n $(cmus-remote -Q | grep duration | cut -c 10-))
minutes2=$(prepend_zero $((duration / 60)))
seconds2=$(prepend_zero $((duration % 60)))

player_status=$(echo -n $(cmus-remote -Q | grep status | cut -c 8-))
data="$artist - $song [$minutes1:$seconds1 / $minutes2:$seconds2]"
# data="$song [$minutes1:$seconds1 / $minutes2:$seconds2]"

if [[ $player_status = "playing" ]]; then
    echo -n "%{F#D08770}$data"
elif [[ $player_status = "paused" ]]; then
    echo -n "%{F#65737E}$data"
else
    echo -n "%{F#65737E}"
fi
