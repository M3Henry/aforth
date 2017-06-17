#! /bin/bash

gcc -c -o obj/main.o main.s && ld -o bin/aFORTH obj/* && echo -ne "Testing, 123! \xe2\x9c\x93" | bin/aFORTH
echo "Returns:" $?
