#!/bin/bash

if [ -z "$1" ]; then
  printf "error: Wrong usage of uttop. Use \"./uttop.sh --help\" to view correct usage.\n"
elif [ $1 == "--help" ] || [ $1 == "?" ]; then
  printf "uttop help\n\n"
  printf "usage: uttop [options] band/artist or file.txt\n\n"
  printf "options:\n"
  printf "\t-f file \t give .txt file containing one band/artist per line\n"
  printf "examples:\n";
  printf "\t./uttop.sh -f bands.txt\n"
  printf "\t./uttop.sh \"The Strokes\"\n"
elif [ $1 == "-f" ]; then
  if [ -z "$2" ]; then
    printf "error: No file supplied. Use \"./uttop.sh --help\" to view correct usage.\n"
  else
    fname=$2
    while read l; do
      perl uttop.pl "$l"
    done < $fname
  fi
else
  perl uttop.pl $1
fi
