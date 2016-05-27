#!/bin/bash

g++ bootstrap.c decode.c -o bootstrap
gcc -c -Wall -Werror -fpic decode.c
gcc -shared -o libbufeater.dylib decode.c

