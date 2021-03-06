%option noyywrap

L		[a-zA-Z_]

%{

#include <stdio.h>
#include "k.tab.h"

#define YY_DECL int yylex()

extern void yyerror(const char* s);
extern int nl_counter;

%}

%option yylineno

%%

"var"[1-9]			{char* str = malloc(1);
				 sprintf(str, "%c", yytext[3]);
				 yylval.ival = atoi(str); 
				 return T_VAR;}
"var"([1][0-9]|[2][0-6])	{char* str = malloc(2);
				 sprintf(str, "%c%c", yytext[3], yytext[4]);
				 yylval.ival = atoi(str); 
				 return T_VAR;}

"print"				{return T_PRINT;}
"println"			{return T_PRINTLN;}
"hex"				{return T_HEXPRINT;}
"loop"				{return T_LOOP;}
"if"				{return T_IF;}
"else"				{return T_ELSE;}
"else if"			{return T_ELSEIF;}
"=="				{return T_EQUAL;}
">="				{return T_GREATEREQU;}
"<="				{return T_LESSEREQU;}
"!="				{return T_NOTEQUAL;}

[0-9]+				{yylval.ival = atoi(yytext); return T_INT;}
[0-9]+[a-fA-F]*[0-9]*[hH] 	{char* tmp_yytext = strndup(yytext, strlen(yytext)-1); yylval.ival = strtol(tmp_yytext, NULL, 16); free(tmp_yytext); return T_HEX;}

L?\"(\\.|[^\\"])*\"		{yylval.sval = strndup(yytext+1, strlen(yytext)-2); return T_STRING;}

","				{return T_COMMA;}
"+"				{return T_PLUS;}
"-"				{return T_MINUS;}
"*"				{return T_MULTIPLY;}
"/"				{return T_DIVIDE;}
"%"				{return T_MOD;}
"("				{return T_LEFT;}
")"				{return T_RIGHT;}
"{"				{return T_CLEFT;}
"}"				{return T_CRIGHT;}
";"				{return T_SEMICOLON;}
"="				{return T_ASSIGN;}
">"				{return T_GREATER;}
"<"				{return T_LESSER;}

[ \t\v\f]

[\n]				{ ++nl_counter; }

.				{return T_UNKNOWN;}

%%
