%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

#define INIT_NUM 0
#define ASSIGN_NUM 1
#define LOOP_NUM 2
#define COND_NUM 3
#define PRINT_NUM 4
#define PRINTLN_NUM 5
#define RET_NUM 6

typedef struct stringNode {
	char* str;
	int seq;
	int num;
	struct stringNode* next;
} str_node;

typedef struct stackNode
{
    int data;
    struct stackNode* next;
} s_node;

extern int yyget_lineno  (void);
void yyerror(const char* s);
void setVar(int, int);
int getVar(int);
s_node* createStackNode(int);
int isEmpty(s_node*);
void push(s_node**, int);
int pop(s_node**);
int peek(s_node*);
double pow(double, double);
char*  itoa( int value, char * str, int base );
str_node* createNode(char*, int, int);
void appendNode(str_node**, str_node*);
void printNodeList(str_node**);
void initialize();
void convertAssignment();
void convertLoop(int);
void convertCondition(int);
void convertPrint();
void convertPrintln();
s_node* createStackNode(int);
int isEmpty(s_node*);
void push(s_node**, int);
int pop(s_node**);
int peek(s_node*);

int size = 0;
int arr[26] = {0};
int topCheck = 1;

str_node* head = NULL;
str_node* const_head = NULL;
int cmd_seq = 0;
int label_seq = 1;
int str_seq = 1;

s_node* root = NULL;

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
%type<ival> if_comparison
%type<ival> loop_comparison
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
	| calculation line			{ /*printf("A COMMAND\n");*/ }
;

line: T_SEMICOLON
	|semi_statement				{ }
	|nonsemi_statement			{ }

;
semi_statement:
	print1 T_SEMICOLON			{ printf("print: %s\n", $1); }
	| println1 T_SEMICOLON			{ printf("print: %s\n", $1); }
	| assignment T_SEMICOLON		{ printf(" = %d\n",$1);}
	| error					{ yyerror("Missing \';\'"); exit(0);}
;

nonsemi_statement:
	if 					{ if($1 == 1) printf("True\n"); else printf("False\n");  /*convertCondition();*/}
	| loop					{ if($1 < 0){printf("range : 0\n");} else {printf("range : %d\n", $1);} }
;

assignment: T_VAR T_ASSIGN expression		{setVar($3, $1);
						 printf("var%d",$1);
						 $$ = $3;
						 convertAssignment();
						}
;

loop: T_LOOP T_LEFT loop_comparison T_RIGHT statement1	{ $$ = $3; printf("CLOSE LOOP\n"); convertLoop(2); }
	|T_LOOP T_LEFT loop_comparison error		{ char* str = malloc(50);
							sprintf(str, "Missing \')\' (line no. %d)\n",yyget_lineno());
							yyerror(str); 
							exit(0);
							}
	|T_LOOP error					{ char* str = malloc(50);
							sprintf(str, "Missing \'(\' (line no. %d)\n",yyget_lineno());
							yyerror(str); 
							exit(0);
							}
;

loop_comparison: expression T_COMMA expression		{ $$ = $3-$1; printf("OPEN LOOP\n"); convertLoop(1); }

;

if: T_IF T_LEFT if_comparison T_RIGHT statement1		{ $$ = $3; printf("CLOSE IF\n"); convertCondition(2); }
	|T_IF T_LEFT if_comparison T_RIGHT statement1 T_ELSE statement1		{ $$ = $3; printf("CLOSE IF (ELSE)\n"); convertCondition(2); }
	
;

if_comparison: expression T_EQUAL expression	{ if($1 == $3) $$ = 1; else $$ = 0;  printf("OPEN IF %d %d %d\n",$1,$3,$$); convertCondition(1); }
;

statement1: statement2 T_CRIGHT
;

statement2: statement2 line			{ /*printf("HERE!!\n");*/ }
	| T_CLEFT
;

print1: print2 T_RIGHT				{ int len=0;
						len = strlen($1);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $1); 
						convertPrint(); }
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
						sprintf($$, "%s%s", $1, $3);
						char* strBuf = malloc(1000);
						snprintf(strBuf, 1000, "\tstr%d db \"%s\"\n", str_seq, $3);
						str_seq++;
						appendNode(&const_head, createNode(strBuf, -1, INIT_NUM)); }

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
						sprintf($$, "%s", $3); 
						char* strBuf = malloc(1000);
						snprintf(strBuf, 1000, "\tstr%d db \"%s\"\n", str_seq, $3);
						str_seq++;
						appendNode(&const_head, createNode(strBuf, -1, INIT_NUM)); }
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
						sprintf($$, "%s%s", $1, $3);
						char* strBuf = malloc(1000);
						snprintf(strBuf, 1000, "\tstr%d db \"%s\"\n", str_seq, $3);
						str_seq++;
						appendNode(&const_head, createNode(strBuf, -1, INIT_NUM)); }

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
						sprintf($$, "%s", $3);
						char* strBuf = malloc(1000);
						snprintf(strBuf, 1000, "\tstr%d db \"%s\"\n", str_seq, $3);
						str_seq++;
						appendNode(&const_head, createNode(strBuf, -1, INIT_NUM)); }
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

int main(int argc, char** argv) {

	initialize();

	if (argc > 1)
	{
		FILE *file;
		file = fopen(argv[1], "r");
		if (!file)
		{

			fprintf(stderr, "failed open");
			exit(1);

		}
		yyin=file;
	}
	else
	{
	    printf("no input file\n");
	    exit(1);
	}

	yyparse();

	//yyin = stdin;
	//printf("> ");
	/*do { 
		yyparse();
	} while(!feof(yyin));*/

	printf("ASSEMBLY CODE:\n\n");
	
	char* retBuf = malloc(1000);
	snprintf(retBuf, 1000, "\tmov\teax, 1\n\tint\t0x80\n\n");
	appendNode(&head, createNode(retBuf, cmd_seq, RET_NUM));
	cmd_seq++;		
	char* dataBuf = malloc(1000);
	snprintf(dataBuf, 1000, "section .data\n");
	appendNode(&head, createNode(dataBuf, cmd_seq, INIT_NUM));
	cmd_seq++;

	printNodeList(&head);
	printNodeList(&const_head);

	return 0;
}

void yyerror(const char* s) //show error messages
{
	fprintf(stderr, "Parse error: %s\n", s);
}

void setVar(int val, int ind) {
  arr[ind] = val;
}

int getVar(int ind) {
  return arr[ind];
}

s_node* createStackNode(int data)
{
    s_node* stackNode = (s_node*)malloc(sizeof(s_node));
    stackNode->data = data;
    stackNode->next = NULL;
    return stackNode;
}
 
int isEmpty(s_node* root)
{
    return !root;
}
 
void push(s_node** root, int data)
{
    s_node* stackNode = createStackNode(data);
    stackNode->next = *root;
    *root = stackNode;
    printf("%d pushed to stack\n", data);
}
 
int pop(s_node** root)
{
    if (isEmpty(*root))
        return -1;
    s_node* temp = *root;
    *root = (*root)->next;
    int popped = temp->data;
    free(temp);
 
    return popped;
}
 
int peek(s_node* root)
{
    if (isEmpty(root))
        return -1;
    return root->data;
}

str_node* createNode(char* str, int seq, int num)
{
	str_node* node = (str_node*)malloc(sizeof(str_node));
	node->str = str;
	node->seq = seq;
	node->num = num; 
	node->next = NULL;
	return node;
}

void appendNode(str_node** head, str_node* node)
{
	str_node* ptr;

	if((*head) == NULL){
		(*head) = node;
	}
	else {
		ptr = (*head);
		while(ptr->next){
			ptr = ptr->next;
		}
		ptr->next = node;
	}
}

void printNodeList(str_node** head)
{
	str_node* ptr;

	ptr = (*head);
	while(ptr){
		printf("%s", ptr->str);
		ptr = ptr->next;
	}
}

void initialize()
{

	char* bssBuf = malloc(1000);
	char* textBuf = malloc(1000);

	char* tmpBuf;
	snprintf(bssBuf, 1000, "segment .bss\n");
	for(int i = 1; i <= 26; i++) {
		tmpBuf = malloc(1000);
		snprintf(tmpBuf, 1000, "\tvar%d resb 8\n", i);
		strcat(bssBuf, tmpBuf);
		free(tmpBuf);
	}
	strcat(bssBuf, "\n");
	appendNode(&head, createNode(bssBuf, cmd_seq, INIT_NUM));
	cmd_seq++;

	snprintf(textBuf, 1000, "section .text\n\nglobal _start\n\n_start:\n");
	appendNode(&head, createNode(textBuf, cmd_seq, INIT_NUM));
	cmd_seq++;

}

void convertAssignment()
{
	char* assignBuf1 = malloc(1000);
	
	snprintf(assignBuf1, 1000, "\tmov\teax, '5'\n\tsub\teax, '0'\n\tmov\tebx, '3'\n\tsub\tebx, '0'\n\tadd\teax, ebx\n\tadd\teax, '0'\n\tmov\t[var1], eax\n\n");
	appendNode(&head, createNode(assignBuf1, cmd_seq, ASSIGN_NUM));
	cmd_seq++;
	
	//printf("var = expr + expr;\n");
}

void convertLoop(int sec_num)
{
	char* loopBuf1 = malloc(1000);
	char* loopBuf2 = malloc(1000);

	if(sec_num == 1){
		snprintf(loopBuf1, 1000, "\tmov\tecx, %d\n\nl%d:\n", 10, label_seq);
		appendNode(&head, createNode(loopBuf1, cmd_seq, LOOP_NUM));
		push(&root, label_seq);
		cmd_seq++;
		label_seq++;
	}
	else if(sec_num == 2){
		snprintf(loopBuf2, 1000, "\tloop\tl%d\n\n", pop(&root));
		appendNode(&head, createNode(loopBuf2, cmd_seq, LOOP_NUM));
		cmd_seq++;
	}
	else{
		printf("Invalid section number\n");
		exit(1);
	}

	//printf("loop(expr,expr){...}\n");
}

void convertCondition(int sec_num)
{
	char* condBuf1 = malloc(1000);
	char* condBuf2 = malloc(1000);

	if(sec_num == 1){
		snprintf(condBuf1, 1000, "\tmov\tedx, 0\n\tcmp\tedx, 0\n\tjne\tl%d\n\n", label_seq);
		appendNode(&head, createNode(condBuf1, cmd_seq, COND_NUM));
		push(&root, label_seq);
		cmd_seq++;
		label_seq++;
	}
	else if(sec_num == 2){
		snprintf(condBuf2, 1000, "l%d:\n", pop(&root));
		appendNode(&head, createNode(condBuf2, cmd_seq, COND_NUM));
		cmd_seq++;
	}
	else{
		printf("Invalid section number\n");
		exit(1);
	}

	//printf("if(expr==expr){...}\n");
}

void convertPrint()
{
	char* printBuf1 = malloc(1000);

	snprintf(printBuf1, 1000, "\tmov\tecx, 'T'\n\tmov\tedx, 1\n\tmov\tebx, 1\n\tmov\teax, 4\n\tint\t0x80\n\n");
	appendNode(&head, createNode(printBuf1, cmd_seq, PRINT_NUM));
	cmd_seq++;
	
	//printf("print(...);\n");
}

void convertPrintln()
{
	printf("println(...);\n");
}







