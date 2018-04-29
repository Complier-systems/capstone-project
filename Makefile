all: k.exe

u.tab.c u.tab.h: u.y
	bison -d u.y

lex.yy.c: u.l u.tab.h
	flex u.l

u: lex.yy.c u.tab.c u.tab.h
	gcc -o u u.tab.c lex.yy.c -lm

k.asm: k test.c
	./k test.c

k.o: k.asm
	nasm -f elf k.asm

k.exe: k.o
	ld -melf_i386 -o k.exe k.o

clean:
	rm k k.tab.c lex.yy.c k.tab.h k.o k.exe

