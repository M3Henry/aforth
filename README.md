# aforth

A FORTH written in assembly language for Linux x64

Compiles with GNU Assembler

Written by Henry Wilson


The process can be run by typing 'make interactive'

Try entering some of the following:

10 20 + .

: STARS 0 DO 42 EMIT LOOP ;
6 STARS

: TRIANGLE 1+ 1 DO I> STARS CR LOOP ;
4 TRIANGLE

: TRIANGLE DUP IF DUP STARS CR 1- RECURSE ELSE DROP THEN ;
5 TRIANGLE

FORGET TRIANGLE
5 TRIANGLE

![alt text](https://github.com/M3Henry/aforth/blob/master/example.png)
