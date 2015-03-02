#!/bin/sh
! (($#)) && echo -e "ERROR: readlink <link to analyze>" 1>&2 && exit 99

link="$1"
while [ -L "$link" ]; do
  lastLink="$link"
  link=$(/bin/ls -ldq "$link")
  link="${link##* -> }"
  link=$(realpath "$link")
  [ "$link" == "$lastlink" ] && echo -e "ERROR: link loop detected on $link" 1>&2 && break
done

echo "$link"
