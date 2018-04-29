all: k.exe

k.tab.c k.tab.h:	k.y
	bison -d k.y

lex.yy.c: k.l k.tab.h
	flex k.l

k: lex.yy.c k.tab.c k.tab.h
	gcc -o k k.tab.c lex.yy.c -lm

k.asm: k test.c
	./k test.c

k.o: k.asm
	nasm -f elf k.asm

k.exe: k.o
	ld -melf_i386 -o k.exe k.o

clean:
	rm k k.tab.c lex.yy.c k.tab.h k.o k.exe

