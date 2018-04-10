%option noyywrap

L		[a-zA-Z_]

%{
#include <stdio.h>
#include "k.tab.h"

#define YY_DECL int yylex()

extern void yyerror(const char* s);

%}

%%

[0-9]+		{yylval.ival = atoi(yytext); return T_INT;}
[0-9]+[a-fA-F]*[0-9]*[hH] {char* tmp_yytext = strndup(yytext, strlen(yytext)-1); yylval.ival = strtol(tmp_yytext, NULL, 16); free(tmp_yytext); return T_HEX;}

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

L?\"(\\.|[^\\"])*\"	{yylval.sval = strndup(yytext+1, strlen(yytext)-2); return T_STRING;}

","		{return T_COMMA;}
"+"		{return T_PLUS;}
"-"		{return T_MINUS;}
"*"		{return T_MULTIPLY;}
"/"		{return T_DIVIDE;}
"\\"		{return T_MOD;}
"^"             {return T_POW;}
"("		{return T_LEFT;}
")"		{return T_RIGHT;}
";"		{return T_SEMICOLON;}

[ \t\v\f]	{}
[\n]		{printf("> ");}
.		{printf("Bad character\n");}

%%
