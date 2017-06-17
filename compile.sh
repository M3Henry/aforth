#! /bin/bash

gcc -c -o obj/main.o main.s && ld -o bin/aFORTH obj/* && echo "Testing, 123..." | bin/aFORTH
echo "Returns:" $?
