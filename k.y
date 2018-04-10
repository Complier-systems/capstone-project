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
%type<ival> register_operation
%type<ival> display
%type<sval> print1
%type<sval> print2
//%type<sval> string

%start calculation

%%

calculation: 
	   | calculation line			{  }
;

line: T_SEMICOLON
    	  | expression T_SEMICOLON 		{ if(topCheck){printf("= %i\n", $1); setAcc($1);} topCheck=1; }
	  | expression %prec ERR_MISSOPTOR " " expression T_SEMICOLON{ yyerror("Missing operator"); }
    	  | register_operation T_SEMICOLON
    	  | display	T_SEMICOLON		{ if(topCheck){printf("= %i\n", $1);} topCheck=1; }
	  | T_LOAD T_INT T_REG T_SEMICOLON			{ yyerror("Unexpected operand"); }
	  | T_LOAD T_HEX T_REG T_SEMICOLON			{ yyerror("Unexpected operand"); }
    	  | T_QUIT T_SEMICOLON 			{ printf("Program is shutting down..\n"); exit(0); }
	  | print1 T_SEMICOLON			{ printf("print: %s\n", $1); }
;

register_operation: T_PUSH expression           { $$ = $2; push($2); }
          | T_POP T_REG                         { if(!isEmpty()){int val=pop(); $$ = val; setReg(val, $2);}else{yyerror("Stack is empty");} }
          | T_LOAD T_REG T_REG                 	{ $$ = getReg($2); setReg(getReg($2), $3); }
	  | T_LOAD T_ACC T_REG                 	{ $$ = getAcc(); setReg(getAcc(), $3); }
	  | T_LOAD T_TOP T_REG                 	{ if(!isEmpty()){$$ = getTop(); setReg(getTop(), $3);}else{yyerror("Stack is empty");} }
	  | T_LOAD T_SIZE T_REG                	{ $$ = getSize(); setReg(getSize(), $3); }

          | T_POP T_ACC				{ yyerror("Accumulator is Read-only"); }
	  | T_LOAD T_REG T_ACC                 	{ yyerror("Accumulator is Read-only"); }
	  | T_LOAD T_ACC T_ACC                 	{ yyerror("Accumulator is Read-only"); }
	  | T_LOAD T_TOP T_ACC                 	{ yyerror("Accumulator is Read-only"); }
	  | T_LOAD T_SIZE T_ACC                 { yyerror("Accumulator is Read-only"); }

          | T_POP T_TOP				{ yyerror("Top of stack is Read-only"); }
	  | T_LOAD T_REG T_TOP                 	{ yyerror("Top of stack is Read-only"); }
	  | T_LOAD T_ACC T_TOP                 	{ yyerror("Top of stack is Read-only"); }
	  | T_LOAD T_TOP T_TOP                 	{ yyerror("Top of stack is Read-only"); }
	  | T_LOAD T_SIZE T_TOP                 { yyerror("Top of stack is Read-only"); }

          | T_POP T_SIZE			{ yyerror("Size of stack is Read-only"); }
	  | T_LOAD T_REG T_SIZE                 { yyerror("Size of stack is Read-only"); }
	  | T_LOAD T_ACC T_SIZE                 { yyerror("Size of stack is Read-only"); }
	  | T_LOAD T_TOP T_SIZE                 { yyerror("Size of stack is Read-only"); }
	  | T_LOAD T_SIZE T_SIZE              	{ yyerror("Size of stack is Read-only"); }
;

display: T_SHOW T_REG				{ $$ = getReg($2); }
	  | T_SHOW T_ACC			{ $$ = getAcc(); }
	  | T_SHOW T_TOP			{ if(!isEmpty()){$$ = getTop();}else{yyerror("Stack is empty"); topCheck=0;} }
	  | T_SHOW T_SIZE			{ $$ = getSize(); }
	  | T_SHOW T_INT			{ yyerror("Unexpected operand: SHOW <reg>"); }
	  | T_SHOW T_HEX			{ yyerror("Unexpected operand: SHOW <reg>"); }
;

print1: print2 T_RIGHT				{ int len=0;
						len = strlen($1);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $1); }
;

print2: print2 T_COMMA expression         	{ char* snum = malloc(sizeof($3));
						snprintf (snum, sizeof($3), "%d", $3);
						int len=0;
						len = strlen($1) + strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, snum); }

	| print2 T_COMMA T_STRING		{ int len=0;
						len = strlen($1) + strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, $3); }

	| T_PRINT T_LEFT expression		{ char* snum = malloc(sizeof($3));
						snprintf (snum, sizeof($3), "%d", $3);
						int len=0;
						len = strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s", snum); }

	| T_PRINT T_LEFT T_STRING		{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3); }
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
