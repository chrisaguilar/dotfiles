#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch Bar
if type "xrandr"; then
  MONITOR=$(xrandr --query | egrep "primary" | awk '{print $1}') polybar --reload main &

  for m in $(xrandr --query | egrep -v "primary" | awk '{print $1}'); do
    MONITOR=$m polybar --reload secondary &
  done
else
  polybar --reload main &
fi
