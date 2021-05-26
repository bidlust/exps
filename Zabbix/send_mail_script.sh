#!/bin/bash

to=$1
subject=$2
context=$3

echo -e "$context" | mail -s "$subject" "$to"