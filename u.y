%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
void setVar(int, int);
int getVar(int);
void setAcc(int);
int getAcc(void);
void push(int);
int pop();
int getSize();
int isEmpty();
int getTop();
double pow(double, double);
char*  itoa( int value, char * str, int base );

struct Node
{
   int data;
   int size;
   struct Node *next;
}*top = NULL;

int size = 0;
int arr[26] = {0};
int acc = 0;
int topCheck = 1;

%}

%union {
	int ival;
	char* sval;
}

%token<ival> T_INT
%token<ival> T_HEX
%token<ival> T_VAR
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_MOD T_POW T_LEFT T_RIGHT
%token<ival> T_REG
%token T_PRINT
%token T_PRINTLN
%token T_HEXPRINT
%token T_COMMA
%token T_SEMICOLON
%token T_CLEFT
%token T_CRIGHT
%token T_IF
%token T_ENDIF
%token T_ELSE
%token T_ASSIGN
%token T_EQUAL
%token T_LOOP
%token<sval> T_STRING

%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE T_MOD
%right T_NOT
%precedence T_NEG T_POS
%right T_POW

%type<ival> expression
%type<ival> assignment
%type<ival> comparison
%type<ival> if
%type<ival> loop
%type<sval> print1
%type<sval> print2
%type<sval> println1
%type<sval> println2
%type<sval> hex

%start calculation

%%

calculation: 
	| calculation line			{  }
;

line: T_SEMICOLON
	| print1 T_SEMICOLON			{ printf("print: %s\n", $1); }
	| println1 T_SEMICOLON			{ printf("print: %s\n", $1); }
	| if 					{ if($1 == 1) printf("True\n"); else printf("False\n");  }
	| assignment T_SEMICOLON		{ printf(" = %d\n",$1);}
	| loop					{ if($1 < 0){ yyerror("Bad input");} else {printf("range : %d\n", $1);} }
;

assignment: T_VAR T_ASSIGN expression		{setVar($3, $1);
						 printf("var%d",$1);
						 $$ = $3;
						}
;

loop: T_LOOP T_LEFT expression T_COMMA expression T_RIGHT statement1	{ $$ = $5-$3; }

;

if: T_IF T_LEFT comparison T_RIGHT statement1		{ $$ = $3; printf("Unsucces! %d\n",$$); }
	|T_IF T_LEFT comparison T_RIGHT statement1 T_ELSE statement1		{ $$ = $3; printf("Succes!\n");}
	
;

comparison: expression T_EQUAL expression	{ if($1 == $3) $$ = 1; else $$ = 0;  printf("%d %d %d\n",$1,$3,$$);}
;

statement1: statement2 T_CRIGHT
;

statement2: statement2 line
	| T_CLEFT
;

print1: print2 T_RIGHT				{ int len=0;
						len = strlen($1);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $1); }
;

print2: print2 T_COMMA expression         	{ char* snum = malloc(30);
						snprintf (snum, 30, "%d", $3);
						int len=0;
						len = strlen($1) + strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, snum);
						free(snum); }

	| print2 T_COMMA hex			{ int len=0;
						len = strlen($1) + strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, $3); }

	| print2 T_COMMA T_STRING		{ int len=0;
						len = strlen($1) + strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, $3); }

	| T_PRINT T_LEFT expression		{ char* snum = malloc(30);
						snprintf (snum, 30, "%d", $3);
						int len=0;
						len = strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s", snum); 
						free(snum); }

	| T_PRINT T_LEFT hex			{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3); }

	| T_PRINT T_LEFT T_STRING		{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3); }
;

println1: println2 T_RIGHT			{ int len=0;
						len = strlen($1) + 1; // + 1 for newline
						$$ = malloc(len + 1); // + 1 for terminal symbol "\0"
						sprintf($$, "%s\n", $1); }
;

println2: println2 T_COMMA expression         	{ char* snum = malloc(30);
						snprintf (snum, 30, "%d", $3);
						int len=0;
						len = strlen($1) + strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, snum);
						free(snum); }

	| println2 T_COMMA hex			{ int len=0;
						len = strlen($1) + strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, $3); }

	| println2 T_COMMA T_STRING		{ int len=0;
						len = strlen($1) + strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, $3); }

	| T_PRINTLN T_LEFT expression		{ char* snum = malloc(30);
						snprintf (snum, 30, "%d", $3);
						int len=0;
						len = strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s", snum); 
						free(snum); }

	| T_PRINTLN T_LEFT hex			{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3); }

	| T_PRINTLN T_LEFT T_STRING		{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3); }
;

hex: T_HEXPRINT T_LEFT expression T_RIGHT	{ char* snum = malloc(30);
						snprintf (snum, 30, "0x%X", $3);
						int len=0;
						len = strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s", snum); 
						free(snum); }
;

expression: T_INT				{ $$ = $1; }
          | T_HEX                               { $$ = $1; }
	  | T_VAR				{ $$ = getVar($1); }
	  | expression T_PLUS expression	{ $$ = $1 + $3; }
	  | expression T_MINUS expression	{ $$ = $1 - $3; }
	  | expression T_MULTIPLY expression	{ $$ = $1 * $3; }
          | expression T_DIVIDE expression	{ $$ = $1 / $3; }
          | expression T_MOD expression	        { $$ = $1 % $3; }
          | expression T_POW expression        	{ $$ = (int)pow ($1, $3); }
          | T_MINUS expression %prec T_NEG      { $$ = -$2; }
	  | T_PLUS expression %prec T_POS       { $$ = $2; }
	  | T_NOT expression	                { $$ = ~$2; }
	  | T_LEFT expression T_RIGHT		{ $$ = $2; }
;

%%

int main() {
	yyin = stdin;
	printf("> ");
	do { 
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void setVar(int val, int ind) {
  arr[ind] = val;
}

int getVar(int ind) {
  return arr[ind];
}

void setAcc(int val) {
  acc = val;
}

int getAcc() {
  return acc;
}

void push(int value)
{
   struct Node *newNode;
   newNode = (struct Node*)malloc(sizeof(struct Node));
   newNode->data = value;
   newNode->size = ++size;  
   if(isEmpty())
      newNode->next = NULL;
   else
      newNode->next = top;
   top = newNode;
}

int pop()
{
   if(isEmpty())
      return 0;
   else{
      struct Node *temp = top;
      int val = temp->data;
      top = temp->next;
      free(temp);
      return val;
   }
}

int getTop() 
{
   if(isEmpty())
      printf("\nStack is Empty!!!\n");
   else{
      return top->data;
   }
}

int getSize() //check stack whether empty or not
{
	if(isEmpty())
		return 0;
	else{
		struct Node *temp = top;
		return(temp->size);
	}
}

int isEmpty() //check stack whether empty or not
{
	if(top == NULL)
		return 1;
	else
		return 0;
}

void yyerror(const char* s) //show error messages
{
	fprintf(stderr, "Parse error: %s\n", s);
}
