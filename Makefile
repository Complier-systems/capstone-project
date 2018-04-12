all: k

k.tab.c k.tab.h:	k.y
	bison -d k.y

lex.yy.c: k.l k.tab.h
	flex k.l

k: lex.yy.c k.tab.c k.tab.h
	gcc -o k k.tab.c lex.yy.c -lm

clean:
	rm k k.tab.c lex.yy.c k.tab.h

