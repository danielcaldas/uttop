#!/bin/bash

fname=$1
while read l; do
  perl uttop.pl "$l"
done < $fname
