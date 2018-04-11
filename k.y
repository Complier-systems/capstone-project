%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
void setReg(int, int);
int getReg(int);
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
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_MOD T_POW T_LEFT T_RIGHT
%token T_AND T_OR T_NOT
%token T_QUIT
%token<ival> T_REG
%token T_SHOW
%token T_LOAD
%token<ival> T_ACC
%token T_PUSH
%token T_POP
%token T_PRINT
%token T_HEXPRINT
%token T_COMMA
%token T_SEMICOLON
%token<sval> T_STRING
%token<ival> T_TOP
%token<ival> T_SIZE

%left T_PUSH T_POP
%left T_OR
%left T_AND
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE T_MOD
%right T_NOT
%precedence T_NEG T_POS
%right T_POW
%precedence ERR_MISSOPTOR
%precedence ERR_MISSOPRND

%type<ival> expression
%type<sval> print1
%type<sval> print2
%type<sval> hex
//%type<sval> string

%start calculation

%%

calculation: 
	   | calculation line			{  }
;

line: T_SEMICOLON
    	  | expression T_SEMICOLON 		{ if(topCheck){printf("= %i\n", $1); setAcc($1);} topCheck=1; }
	  | expression %prec ERR_MISSOPTOR " " expression T_SEMICOLON{ yyerror("Missing operator"); }
    	  | T_QUIT T_SEMICOLON 			{ printf("Program is shutting down..\n"); exit(0); }
	  | print1 T_SEMICOLON			{ printf("print: %s\n", $1); }
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
          | T_REG                               { $$ = getReg($1); }
          | T_ACC                               { $$ = getAcc(); }
          | T_TOP                               { if(!isEmpty()){$$ = getTop();}else{yyerror("Stack is empty");topCheck=0;} }
          | T_SIZE                              { $$ = getSize(); }
	  | expression T_PLUS expression	{ $$ = $1 + $3; }
	  | expression T_MINUS expression	{ $$ = $1 - $3; }
	  | expression T_MULTIPLY expression	{ $$ = $1 * $3; }
          | expression T_DIVIDE expression	{ $$ = $1 / $3; }
          | expression T_MOD expression	        { $$ = $1 % $3; }
          | expression T_POW expression        	{ $$ = (int)pow ($1, $3); }
          | T_MINUS expression %prec T_NEG      { $$ = -$2; }
	  | T_PLUS expression %prec T_POS       { $$ = $2; }
	  | expression T_AND expression	        { $$ = $1 & $3; }
	  | expression T_OR expression	        { $$ = $1 | $3; }
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

void setReg(int val, int ind) {
  arr[ind] = val;
}

int getReg(int ind) {
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
