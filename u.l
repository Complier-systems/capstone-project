%option noyywrap

L		[a-zA-Z_]

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "u.tab.h"

#define YY_DECL int yylex()

extern void yyerror(const char* s);

%}

%%

[ \t]		{yylval.sval = yytext; return T_SPACE;}
[0-9]+		{yylval.ival = atoi(yytext); return T_INT;}
[0-9]+[a-fA-F]*[0-9]*[hH] {memmove(&yytext[strlen(yytext)-1], &yytext[strlen(yytext)], 1); yylval.ival = strtol(yytext, NULL, 16); return T_HEX;}
\n		{return T_NEWLINE;}
","		{return T_COMMA;}
"+"		{return T_PLUS;}
"-"		{return T_MINUS;}
"*"		{return T_MULTIPLY;}
"/"		{return T_DIVIDE;}
"%"		{return T_MOD;}
"^"             {return T_POW;}
"("		{return T_LEFT;}
")"		{return T_RIGHT;}
"{"		{return T_CLEFT;}
"}"		{return T_CRIGHT;}
"="		{return T_ASSIGN;}
";"		{return T_SEMICOLON;}
"if"		{return T_IF;}
"=="		{return T_EQUAL;}
"print"		{return T_PRINT;}
"println"	{return T_PRINTLN;}
"hex"		{return T_HEXPRINT;}
"var"[1-9]	{char* str = malloc(1);
		 sprintf(str, "%c", yytext[3]);
		 yylval.ival = atoi(str); 
		 return T_VAR;
		}
"var"[10-26]	{char* str = malloc(2);
		 sprintf(str, "%c%c", yytext[3], yytext[4]);
		 yylval.ival = atoi(str); 
		 return T_VAR;
		}
L?\"(\\.|[^\\"])*\"	{yylval.sval = strndup(yytext+1, strlen(yytext)-2); return T_STRING;}

%%
