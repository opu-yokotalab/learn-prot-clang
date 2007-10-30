#!/bin/sh
lang_old=$LANG
export LANG=C
gcc -o $1 $2
export LANG=$lang_old