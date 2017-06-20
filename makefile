all: bin/aFORTH
	@echo Testing...
	@/bin/echo -ne "+ . CR WORDY GREET" | bin/aFORTH

interactive: bin/aFORTH
	@bin/aFORTH

bin/aFORTH: obj/main.o
	@echo Linking...
	@ld -o bin/aFORTH obj/main.o

obj/main.o: main.s
	@echo Compiling...
	@gcc -c -o obj/main.o main.s

clean:
	@rm obj/*
