#!/bin/bash
set -x

(/usr/bin/time _build/default/client.exe 24 1) &>> time.txt
(/usr/bin/time _build/default/client.exe 24 10) &>> time.txt