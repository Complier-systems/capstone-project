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

void yyerror(const char* s);
void setVar(int, int);
int getVar(int);
s_node* createStackNode(int);
int isEmpty(s_node*);
void push(s_node**, int);
int pop(s_node**);
int popAll(s_node** root);
int peek(s_node*);
double pow(double, double);
char*  itoa( int value, char * str, int base );
str_node* createNode(char*, int, int);
void appendNode(str_node**, str_node*);
void printNodeList(str_node**);
void initialize();
void convertAssignment(int);
void convertLoop(int, int);
void convertCondition(int);
void convertPrint(int, long, int);
void convertPrintln();
s_node* createStackNode(int);
int isEmpty(s_node*);
void insert(s_node**, int);
void push(s_node**, int);
int pop(s_node**);
int peek(s_node*);

int size = 0;
int arr[26] = {0};
int topCheck = 1;

str_node* head = NULL;
str_node* const_head = NULL;
str_node* expr_head = NULL;

int cmd_seq = 0;
int label_seq = 1;
int str_seq = 1;
int isVar = 0;
int showCmd = 0;
int int_counter = 0;

s_node* root = NULL;
s_node* int_stack = NULL;

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
%type<ival> assign_var
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
	| calculation line									{ popAll(&int_stack); }
;

line: T_SEMICOLON
	| print1 T_SEMICOLON									{ printf("print: %s\n", $1); }
	| println1 T_SEMICOLON									{ printf("print: %s\n", $1); }
	| if											{ if($1 == 1) printf("True\n"); else printf("False\n");  /*convertCondition();*/}
	| assignment T_SEMICOLON								{ printf(" = %d\n",$1);}
	| loop											{ if($1 < 0){ yyerror("Bad input");} else {printf("range : %d\n", $1);} }
;

assignment: assign_var T_ASSIGN expression							{ setVar($3, $1);
												 $$ = $3;
												 convertAssignment($1);
												 showCmd = 0;
												 int_counter = 0; }
;

assign_var: T_VAR										{ appendNode(&head, createNode("\tpushad\n\n", cmd_seq, ASSIGN_NUM));
												 cmd_seq++;
												 showCmd = 1;
												 int_counter = 0; }
;

loop: loop_token T_LEFT loop_comparison T_RIGHT statement1					{ $$ = $3; convertLoop(2, $3); /*printf("CLOSE LOOP\n");*/ }

;

loop_token: T_LOOP										{ showCmd = 1; int_counter = 0; }

;

loop_comparison: expression loopComma_token expression						{ $$ = $3-$1; convertLoop(1, $3-$1); /*printf("OPEN LOOP\n");*/ }

;

loopComma_token: T_COMMA									{ char* loopCommaBuf = malloc(1000);
												 snprintf(loopCommaBuf, 1000, "\tpush\teax\n\n");
												 appendNode(&head, createNode(loopCommaBuf, cmd_seq, -1));
												 cmd_seq++; 
												 showCmd = 1; 
												 int_counter = 0; }
;

if: if_token T_LEFT if_comparison T_RIGHT statement1						{ $$ = $3; printf("CLOSE IF\n"); convertCondition(2); showCmd = 0; int_counter = 0; }
	|if_token T_LEFT if_comparison T_RIGHT statement1 T_ELSE statement1			{ $$ = $3; printf("CLOSE IF (ELSE)\n"); convertCondition(2); showCmd = 0; int_counter = 0; }
	
;

if_token: T_IF											{ showCmd = 1; int_counter = 0; }

;

if_comparison: expression equal_token expression						{ if($1 == $3) $$ = 1; else $$ = 0;  printf("OPEN IF %d %d %d\n",$1,$3,$$); convertCondition(1); }

;

equal_token: T_EQUAL										{ char* ifcmpBuf = malloc(1000);
												 snprintf(ifcmpBuf, 1000, "\tpush\teax\n\n");
												 appendNode(&head, createNode(ifcmpBuf, cmd_seq, -1));
												 cmd_seq++; 
												 showCmd = 1; 
												 int_counter = 0; }
;

statement1: statement2 T_CRIGHT	

;

statement2: statement2 line									{  }
	| T_CLEFT
;

print1: print2 T_RIGHT										{ int len=0;
												 len = strlen($1);
												 $$ = malloc(len + 1);
												 sprintf($$, "%s", $1); }
;

print2: print2 printComma_token expression      { char* snum = malloc(30);
						snprintf (snum, 30, "%d", $3);
						int len=0;
						len = strlen($1) + strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, snum);
						free(snum); 
						convertPrint(1, $3, -1); }

	| print2 printComma_token hex		{ int len=0;
						len = strlen($1) + strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, $3); }

	| print2 printComma_token T_STRING	{ int len=0;
						len = strlen($1) + strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s%s", $1, $3);
						char* strBuf = malloc(1000);
						snprintf(strBuf, 1000, "\tstr%d db \"%s\"\n", str_seq, $3);
						convertPrint(3, str_seq, strlen($3));
						str_seq++;
						appendNode(&const_head, createNode(strBuf, -1, INIT_NUM)); }

	| print_token T_LEFT expression		{ char* snum = malloc(30);
						snprintf (snum, 30, "%d", $3);
						int len=0;
						len = strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s", snum); 
						free(snum); 
						convertPrint(1, $3, -1); }

	| print_token T_LEFT hex			{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3); }

	| print_token T_LEFT T_STRING		{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3); 
						char* strBuf = malloc(1000);
						snprintf(strBuf, 1000, "\tstr%d db \"%s\"\n", str_seq, $3);
						convertPrint(3, str_seq, strlen($3));
						str_seq++;
						appendNode(&const_head, createNode(strBuf, -1, INIT_NUM)); }

;

printComma_token: T_COMMA			{ char* commaTokenBuf = malloc(1000);
						snprintf(commaTokenBuf, 1000, "\tpushad\n\n");
						appendNode(&head, createNode(commaTokenBuf, cmd_seq, -1));
						cmd_seq++;
						showCmd = 1; 
						int_counter = 0; }

;

print_token: T_PRINT				{ char* printTokenBuf = malloc(1000);
						snprintf(printTokenBuf, 1000, "\tpushad\n\n");
						appendNode(&head, createNode(printTokenBuf, cmd_seq, -1));
						cmd_seq++;
						showCmd = 1; 
						int_counter = 0; }

;
						
println1: println2 T_RIGHT			{ int len=0;
						len = strlen($1) + 1; // + 1 for newline
						$$ = malloc(len + 1); // + 1 for terminal symbol "\0"
						sprintf($$, "%s\n", $1); 
						convertPrintln(); }
;

println2: println2 printlnComma_token expression        	{ char* snum = malloc(30);
								snprintf (snum, 30, "%d", $3);
								int len=0;
								len = strlen($1) + strlen(snum);
								$$ = malloc(len + 1);
								sprintf($$, "%s%s", $1, snum);
								free(snum); 
								convertPrint(1, $3, -1); }

	| println2 printlnComma_token hex			{ int len=0;
								len = strlen($1) + strlen($3);
								$$ = malloc(len + 1);
								sprintf($$, "%s%s", $1, $3); }

	| println2 printlnComma_token T_STRING			{ int len=0;
								len = strlen($1) + strlen($3);
								$$ = malloc(len + 1);
								sprintf($$, "%s%s", $1, $3);
								char* strBuf = malloc(1000);
								snprintf(strBuf, 1000, "\tstr%d db \"%s\"\n", str_seq, $3);
								convertPrint(3, str_seq, strlen($3));
								str_seq++;
								appendNode(&const_head, createNode(strBuf, -1, INIT_NUM)); }

	| println_token T_LEFT expression		{ char* snum = malloc(30);
							snprintf (snum, 30, "%d", $3);
							int len=0;
							len = strlen(snum);
							$$ = malloc(len + 1);
							sprintf($$, "%s", snum); 
							free(snum); 
							convertPrint(1, $3, -1); }

	| println_token T_LEFT hex			{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3); }

	| println_token T_LEFT T_STRING		{ int len=0;
						len = strlen($3);
						$$ = malloc(len + 1);
						sprintf($$, "%s", $3);
						char* strBuf = malloc(1000);
						snprintf(strBuf, 1000, "\tstr%d db \"%s\"\n", str_seq, $3);
						convertPrint(3, str_seq, strlen($3));
						str_seq++;
						appendNode(&const_head, createNode(strBuf, -1, INIT_NUM)); }
;

printlnComma_token: T_COMMA			{ char* commaLnTokenBuf = malloc(1000);
						snprintf(commaLnTokenBuf, 1000, "\tpushad\n\n");
						appendNode(&head, createNode(commaLnTokenBuf, cmd_seq, -1));
						cmd_seq++;
						showCmd = 1; 
						int_counter = 0; }

;

println_token: T_PRINTLN				{ char* printlnTokenBuf = malloc(1000);
						snprintf(printlnTokenBuf, 1000, "\tpushad\n\n");
						appendNode(&head, createNode(printlnTokenBuf, cmd_seq, -1));
						cmd_seq++;
						showCmd = 1; 
						int_counter = 0; }

;

hex: T_HEXPRINT T_LEFT expression T_RIGHT	{ char* snum = malloc(30);
						snprintf (snum, 30, "0x%X", $3);
						int len=0;
						len = strlen(snum);
						$$ = malloc(len + 1);
						sprintf($$, "%s", snum); 
						free(snum); 
						convertPrint(2, $3, -1); }
;

expression: T_INT				{  
						 $$ = $1;

						 if(showCmd == 1){
							if(int_counter == 0){
								char* intBuf = malloc(1000);
								snprintf(intBuf, 1000, "\tmov\teax, %d\n\n", $1);
								appendNode(&head, createNode(intBuf, cmd_seq, -1));
								cmd_seq++;
								int_counter = 1;
							}
							else {
								char* intBuf = malloc(1000);
								snprintf(intBuf, 1000, "\tpush\teax\n\tmov\teax, %d\n\n", $1);
								appendNode(&head, createNode(intBuf, cmd_seq, -1));
								cmd_seq++;
							}
						 }

						 /*insert(&int_stack, $1);
						 printf("%d\n", peek(int_stack));
						 isVar = 0;*/
						 printf("%d\n",$1); 
						}

	| T_HEX                               { $$ = $1; 
						 //isVar = 0;

						 if(showCmd == 1){
							char* snum = malloc(30);
							snprintf (snum, 30, "0%xh", $1);
							if(int_counter == 0){
								char* hexBuf = malloc(1000);
								snprintf(hexBuf, 1000, "\tmov\teax, %s\n\n", snum);
								appendNode(&head, createNode(hexBuf, cmd_seq, -1));
								cmd_seq++;
								int_counter = 1;
							}
							else {
								char* hexBuf = malloc(1000);
								snprintf(hexBuf, 1000, "\tpush\teax\n\tmov\teax, %s\n\n", snum);
								appendNode(&head, createNode(hexBuf, cmd_seq, -1));
								cmd_seq++;
							}
							free(snum);
						 }

						}

	| T_VAR				{ $$ = getVar($1);

						 if(showCmd == 1){
							if(int_counter == 0){
								char* intBuf = malloc(1000);
								snprintf(intBuf, 1000, "\tmov\teax, [var%d]\n\n", $1);
								appendNode(&head, createNode(intBuf, cmd_seq, -1));
								cmd_seq++;
								int_counter = 1;
							}
							else {
								char* intBuf = malloc(1000);
								snprintf(intBuf, 1000, "\tpush\teax\n\tmov\teax, [var%d]\n\n", $1);
								appendNode(&head, createNode(intBuf, cmd_seq, -1));
								cmd_seq++;
							}
						 }

						 /*if(showCmd == 1) {
							 isVar = 1;

							 char* varBuf = malloc(1000);
							 snprintf(varBuf, 1000, "\tmov\tebx, [var%d]\n", $1);
							 appendNode(&head, createNode(varBuf, cmd_seq, -1));
							 cmd_seq++;
						 }*/

						 printf("Expr: var%d\n", $1);
						}

	| expression T_PLUS expression	{ $$ = $1 + $3;

						 if(showCmd == 1){
							char* plusBuf = malloc(1000);
							snprintf(plusBuf, 1000, "\tmov\tebx, eax\n\tpop\teax\n\tadd\teax, ebx\n\n");
							appendNode(&head, createNode(plusBuf, cmd_seq, -1));
							cmd_seq++;
						 }

						 /*if(isVar == 1){
							char* constBuf = malloc(1000);
							snprintf(constBuf, 1000, "\tadd\teax, %d\n", popAll(&int_stack));
							appendNode(&head, createNode(constBuf, cmd_seq, -1));
							cmd_seq++;
						 }*/
						 
						 printf("Create Node\n");
						 
						 /*char* exprBuf = malloc(1000);
						 snprintf(intBuf, 1000, "\tmov\teax, %ld\n\tmov\t[var%d], eax\n\n\tpopad\n\n", value, var_num);
						 appendNode(&head, createNode(assignBuf1, cmd_seq, ASSIGN_NUM));
						 cmd_seq++;*/ 
						 }

	| expression T_MINUS expression	{ $$ = $1 - $3; 

						 if(showCmd == 1){
							char* minusBuf = malloc(1000);
							snprintf(minusBuf, 1000, "\tmov\tebx, eax\n\tpop\teax\n\tsub\teax, ebx\n\n");
							appendNode(&head, createNode(minusBuf, cmd_seq, -1));
							cmd_seq++;
						 }

						}

	| expression T_MULTIPLY expression	{ $$ = $1 * $3; 

						 if(showCmd == 1){
							char* mulBuf = malloc(1000);
							snprintf(mulBuf, 1000, "\tmov\tebx, eax\n\tpop\teax\n\timul\tebx\n\n");
							appendNode(&head, createNode(mulBuf, cmd_seq, -1));
							cmd_seq++;
						 }

						}
	| expression T_DIVIDE expression	{ $$ = $1 / $3; 

						 if(showCmd == 1){
							char* divBuf = malloc(1000);
							snprintf(divBuf, 1000, "\tmov\tebx, eax\n\tpop\teax\n\tidiv\tebx\n\n");
							appendNode(&head, createNode(divBuf, cmd_seq, -1));
							cmd_seq++;
						 }

						}

	| expression T_MOD expression	        { $$ = $1 % $3; 

						 if(showCmd == 1){
							char* modBuf = malloc(1000);
							snprintf(modBuf, 1000, "\tmov\tebx, eax\n\tpop\teax\n\tidiv\tebx\n\tmov\teax, edx\n\n");
							appendNode(&head, createNode(modBuf, cmd_seq, -1));
							cmd_seq++;
						 }

						}

	| expression T_POW expression        	{ $$ = (int)pow ($1, $3); }
	| T_MINUS expression %prec T_NEG      { $$ = -$2; 
						
						 if(showCmd == 1){
							char* divBuf = malloc(1000);
							snprintf(divBuf, 1000, "\tneg\teax\n\n");
							appendNode(&head, createNode(divBuf, cmd_seq, -1));
							cmd_seq++;
						 }
						
						}
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

	char* newlineBuf = malloc(1000);
	snprintf(newlineBuf, 1000, "\tnl db 10\n");
	appendNode(&const_head, createNode(newlineBuf, -1, INIT_NUM));

	FILE *f = fopen("k.asm", "w");
	if (f == NULL)
	{
		printf("Error opening file!\n");
		exit(1);
	}

	str_node* ptr;

	ptr = head;
	while(ptr){
		fprintf(f, "%s", ptr->str);
		ptr = ptr->next;
	}
	
	ptr = const_head;
	while(ptr){
		fprintf(f, "%s", ptr->str);
		ptr = ptr->next;
	}

	printNodeList(&head);
	printNodeList(&const_head);

	fclose(f);

	return 0;
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

void insert(s_node** root, int data)
{
    s_node* ptr;

	if((*root) == NULL){
		(*root) = createStackNode(data);
	}
	else {
		ptr = (*root);
		while(ptr->next){
			ptr = ptr->next;
		}
		ptr->next = createStackNode(data);
	}
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

int popAll(s_node** root)
{
    int sum = 0;
    
    while(peek(*root) != -1) {
        sum = sum + pop(root);
    }

    return sum;
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

void yyerror(const char* s) //show error messages
{
	fprintf(stderr, "Parse error: %s\n", s);
}

void initialize() /////
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
	tmpBuf = malloc(1000);
	snprintf(tmpBuf, 1000, "\tdecstr resb 10\n\tct1 resd 1\n");
	strcat(bssBuf, tmpBuf);
	free(tmpBuf);
	
	strcat(bssBuf, "\n");
	appendNode(&head, createNode(bssBuf, cmd_seq, INIT_NUM));
	cmd_seq++;

	snprintf(textBuf, 1000, "section .text\n\nglobal _start\n\n_start:\n");
	appendNode(&head, createNode(textBuf, cmd_seq, INIT_NUM));
	cmd_seq++;

}

void convertAssignment(int var_num) /////
{
	char* assignBuf1 = malloc(1000);
	
	snprintf(assignBuf1, 1000, "\tmov\t[var%d], eax\n\n\tpopad\n\n", var_num);
	appendNode(&head, createNode(assignBuf1, cmd_seq, ASSIGN_NUM));
	cmd_seq++;

}

void convertLoop(int sec_num, int loop_count) /////
{
	char* loopBuf1 = malloc(1000);
	char* loopBuf2 = malloc(1000);

	if(sec_num == 1){
		snprintf(loopBuf1, 1000, "\tpop\tebx\n\n\tsub\teax, ebx\n\n\tcmp\teax, 0\n\tjl\tl%d\n\n\tmov\tecx, eax\n\nl%d:\n\tpush\tecx\n\tcall\tl%d\n\tpop\tecx\n\n\tloop\tl%d\n\nl%d:\n\tjmp l%d\n\nl%d:\n", label_seq + 1, label_seq, label_seq + 2, label_seq, label_seq + 1, label_seq + 3, label_seq + 2);
		appendNode(&head, createNode(loopBuf1, cmd_seq, LOOP_NUM));
		label_seq += 3;
		push(&root, label_seq);
		cmd_seq++;
		label_seq++;
	}
	else if(sec_num == 2){
		snprintf(loopBuf2, 1000, "\tret\n\nl%d:\n", pop(&root));
		appendNode(&head, createNode(loopBuf2, cmd_seq, LOOP_NUM));
		cmd_seq++;
	}
	else{
		printf("Invalid section number\n");
		exit(1);
	}

}

void convertCondition(int sec_num) //To-Do: else
{
	char* condBuf1 = malloc(1000);
	char* condBuf2 = malloc(1000);

	if(sec_num == 1){
		snprintf(condBuf1, 1000, "\tmov\tedx, eax\n\n\tpop\teax\n\n\tcmp\teax, edx\n\tjne\tl%d\n\tjmp\tl%d\n\nl%d:\n\tjmp\tl%d\n\nl%d:\n", label_seq, label_seq + 1, label_seq, label_seq + 2, label_seq + 1);

		appendNode(&head, createNode(condBuf1, cmd_seq, COND_NUM));
		label_seq += 2;
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

}

void convertPrint(int type, long num, int len) /////
{
	if(type == 1){
		char* printBuf1 = malloc(1000);
		snprintf(printBuf1, 1000, \
"\tmov\tdword[ct1], 0\n\
\tmov\tedi, decstr\n\
\tadd\tedi, 9\n\
\txor\tedx, edx\n\
\n\
\tpush\t0\n\
\tcmp\teax, 0\n\
\tjge\tl%d\n\
\tneg\teax\n\
\tpop\tebx\n\
\tpush\t'-'\n\
\n\
l%d:\n\
\tmov\tebx, 10\n\
\tdiv\tebx\n\
\tadd\tedx, '0'\n\
\tmov\tbyte[edi], dl\n\
\tdec\tedi\n\
\tinc\tdword[ct1]\n\
\txor\tedx, edx\n\
\tcmp\teax, 0\n\
\tjne\tl%d\n\
\n\
\tpop\tedx\n\
\tcmp\tedx, 0\n\
\tje\tl%d\
\n\
\tmov\tbyte[edi], dl\n\
\tdec\tedi\n\
\tinc\tdword[ct1]\n\
\txor\tedx, edx\n\
\n\
l%d:\n\
\tinc\tedi\n\
\tmov\tecx, edi\n\
\tmov\tedx, [ct1]\n\
\tmov\teax, 4\n\
\tmov\tebx, 1\n\
\tint\t0x80\n\
\n\
\tpopad\n\n"\
, label_seq, label_seq, label_seq, label_seq + 1, label_seq + 1);

		appendNode(&head, createNode(printBuf1, cmd_seq, PRINT_NUM));
		cmd_seq++;
		label_seq += 2;

	}
	else if(type == 2){
		char* printBuf1 = malloc(1000);
		snprintf(printBuf1, 1000, \
"\tmov\tdword[ct1], 0\n\
\tmov\tedi, decstr\n\
\tadd\tedi, 9\n\
\txor\tedx, edx\n\
\n\
l%d:\n\
\tmov\tebx, 16\n\
\tdiv\tebx\n\
\tadd\tedx, '0'\n\
\n\
\tcmp\tedx, '9'\n\
\tjle\tl%d\n\
\tadd\tedx, 7\n\
\n\
l%d:\n\
\tmov\tbyte[edi], dl\n\
\tdec\tedi\n\
\tinc\tdword[ct1]\n\
\txor\tedx, edx\n\
\tcmp\teax, 0\n\
\tjne\tl%d\n\
\n\
\tmov\tbyte[edi], 'x'\n\
\tdec\tedi\n\
\tinc\tdword[ct1]\n\
\txor\tedx, edx\n\
\n\
\tmov\tbyte[edi], '0'\n\
\tdec\tedi\n\
\tinc\tdword[ct1]\n\
\txor\tedx, edx\n\
\n\
\tinc\tedi\n\
\tmov\tecx, edi\n\
\tmov\tedx, [ct1]\n\
\tmov\teax, 4\n\
\tmov\tebx, 1\n\
\tint\t0x80\n\
\n\
\tpopad\n\n"\
, label_seq, label_seq + 1, label_seq + 1, label_seq);

		appendNode(&head, createNode(printBuf1, cmd_seq, PRINT_NUM));
		cmd_seq++;
		label_seq += 2;

	}
	else if(type == 3){
		char* printBuf3 = malloc(1000);
		snprintf(printBuf3, 1000, \
"\tmov\tecx, str%ld\n\
\tmov\tedx, %d\n\
\tmov\teax, 4\n\
\tmov\tebx, 1\n\
\tint\t0x80\n\
\n\
\tpopad\n\n"\
, num, len);

		appendNode(&head, createNode(printBuf3, cmd_seq, PRINT_NUM));
		cmd_seq++;
	}
	else{
		printf("Invalid type number\n");
		exit(1);
	}

}

void convertPrintln() /////
{
	char* printlnBuf = malloc(1000);
	snprintf(printlnBuf, 1000, \
"\tpushad\n\
\n\
\tmov\tecx, nl\n\
\tmov\tedx, 1\n\
\tmov\teax, 4\n\
\tmov\tebx, 1\n\
\tint\t0x80\n\
\n\
\tpopad\n\n"\
);

	appendNode(&head, createNode(printlnBuf, cmd_seq, PRINTLN_NUM));
	cmd_seq++;

}
