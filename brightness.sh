#! /bin/bash

VALUE=$1


ddcutil setvcp 0x10 $VALUE -d 1 2>/dev/null
ddcutil setvcp 0x10 $VALUE -d 2 2>/dev/null
