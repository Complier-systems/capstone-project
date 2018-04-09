%option noyywrap

%{
#include <stdio.h>
#include "k.tab.h"

#define YY_DECL int yylex()

extern void yyerror(const char* s);

%}

%%

[ \t]		{yylval.sval = yytext; return T_SPACE;}
[0-9]+		{yylval.ival = atoi(yytext); return T_INT;}
[0-9]+[a-fA-F]*[0-9]*[hH] {memmove(&yytext[strlen(yytext)-1], &yytext[strlen(yytext)], 1); yylval.ival = strtol(yytext, NULL, 16);; return T_HEX;}
\n		{return T_NEWLINE;}
","		{return T_COMMA;}
"+"		{return T_PLUS;}
"-"		{return T_MINUS;}
"*"		{return T_MULTIPLY;}
"/"		{return T_DIVIDE;}
"\\"		{return T_MOD;}
"^"             {return T_POW;}
"("		{return T_LEFT;}
")"		{return T_RIGHT;}
"\""		{printf("DoubleQuote\n"); return T_DOUBLEQUOTE;}
"print"		{return T_PRINT;}
"AND"           {return T_AND;}
"OR"            {return T_OR;}
"NOT"           {return T_NOT;}
"exit"		{return T_QUIT;}
"quit"		{return T_QUIT;}
"$r"[A-Z]	{yylval.ival = yytext[2] - 'A'; return T_REG;}
"SHOW"          {return T_SHOW;}
"LOAD"          {return T_LOAD;}
"$acc"          {return T_ACC;}
"PUSH"          {return T_PUSH;}
"POP"           {return T_POP;}
"$top"          {return T_TOP;}
"$size"         {return T_SIZE;}
[^"]		{yylval.sval = yytext; return T_STRING;}

%%
