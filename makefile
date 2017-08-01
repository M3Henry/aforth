all: bin/aFORTH
	@echo Testing...
	@bin/aFORTH < test.txt

interactive: bin/aFORTH
	@bin/aFORTH

bin/aFORTH: obj/main.o
	@echo Linking...
	@ld -o bin/aFORTH obj/main.o

obj/main.o: main.s dictionary.s interpreter.s memory.s boolean.s extras.s macros.i stack.s compiler.s input.s maths.s output.s
	@echo Compiling...
	@gcc -c -o obj/main.o main.s

clean:
	@rm obj/*
