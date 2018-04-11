all: u

u.tab.c u.tab.h: u.y
	bison -d u.y

lex.yy.c: u.l u.tab.h
	flex u.l

u: lex.yy.c u.tab.c u.tab.h
	gcc -o u u.tab.c lex.yy.c -lm

clean:
	rm u u.tab.c lex.yy.c u.tab.h

