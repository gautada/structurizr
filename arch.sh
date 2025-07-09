#!/bin/sh

arch=$(uname -m)

if [ "$arch" = "x86_64" ]; then
  echo "x86"
else
  echo "$arch"
fi
