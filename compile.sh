#!/bin/sh
lang_old=$LANG
export LANG=C
gcc -g -o $1 $2
export LANG=$lang_old
