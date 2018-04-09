%option noyywrap

%{
#include <stdio.h>
#include "s.tab.h"

#define YY_DECL int yylex()

extern void yyerror(const char* s);

%}

%%

[ \t]		; // ignore all whitespace
[0-9]+		{yylval.ival = atoi(yytext); return T_INT;}
[0-9]+[a-fA-F]*[0-9]*[hH] {memmove(&yytext[strlen(yytext)-1], &yytext[strlen(yytext)], 1); yylval.ival = strtol(yytext, NULL, 16);; return T_HEX;}
\n		{return T_NEWLINE;}
"+"		{return T_PLUS;}
"-"		{return T_MINUS;}
"*"		{return T_MULTIPLY;}
"/"		{return T_DIVIDE;}
"%"		{return T_MOD;}
"("		{return T_LEFT;}
")"		{return T_RIGHT;}
"AND"           {return T_AND;}
"OR"            {return T_OR;}
"NOT"           {return T_NOT;}
"exit"		{return T_QUIT;}
"quit"		{return T_QUIT;}
"var"[1-9]	{yylval.ival = atoi(yytext[3]); return T_VAR;}
"var"[10-26]	{yylval.ival = atoi(yytext[3]+yytext[4]); return T_VAR;}
"SHOW"          {return T_SHOW;}
"LOAD"          {return T_LOAD;}
"$acc"          {return T_ACC;}
"PUSH"          {return T_PUSH;}
"POP"           {return T_POP;}
"$top"          {return T_TOP;}
"$size"         {return T_SIZE;}
.		{yyerror("Invalid character");}

%%
