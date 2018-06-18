.PHONY: all run test clean

all: bin/aFORTH

test: all
	@echo Testing...
	@bin/aFORTH < test.txt

run: all
	@bin/aFORTH

bin/aFORTH: obj/main.o
	@echo Linking...
	@ld -o bin/aFORTH obj/main.o

obj/main.o: main.s dictionary.s interpreter.s memory.s boolean.s extras.s macros.i stack.s compiler.s input.s maths.s output.s
	@echo Compiling...
	@gcc -c -o obj/main.o main.s

clean:
	@rm obj/*
	@rm bin/*
