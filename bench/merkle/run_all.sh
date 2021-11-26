#!/usr/bin/env bash
set -x

for i in 1 2 4 8 12
do
time taskset --cpu-list 2-13 chrt -r 1 _build/default/eval_compute.exe $i
done


for i in 16 20 24
do
time taskset --cpu-list 2-13,16-27 chrt -r 1 _build/default/eval_compute.exe $i
done