all: bin/aFORTH
	@echo Testing...
	@/bin/echo -ne "Testing, 123! \xe2\x9c\x93" | bin/aFORTH

bin/aFORTH: obj/main.o
	@echo Linking...
	@ld -o bin/aFORTH obj/main.o

obj/main.o: main.s
	@echo Compiling...
	@gcc -c -o obj/main.o main.s

clean:
	@rm obj/*
