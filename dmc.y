%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

void yyerror(char *);
int yylex(void);
extern int line_num;
extern char* yytext;

// Function to print AST
void print_ast(void *node, int level);
%}

%union {
    int num;
    char* str;
    char* id;
    void* node;
}

%token <num> NUMBER
%token <str> STRING
%token <id> IDENTIFIER
%token VAR IF ELSE WHILE PRINT INPUT WAIT SAVE TIME
%token EQ NE LE GE LT GT ASSIGN PLUS MINUS MULT DIV
%token LBRACE RBRACE LPAREN RPAREN COMMA NEWLINE

%type <node> program statements statement
%type <node> variable_declaration assignment print_statement input_statement
%type <node> if_statement while_statement wait_statement save_statement
%type <node> block expression comparison addition term factor
%type <node> else_if_list else_clause

%%

program: statements { 
    printf("\nAbstract Syntax Tree:\n");
    print_ast($1, 0);
    $$ = $1;
}
    ;

statements: statement { $$ = $1; }
         | statements statement { 
             // Create a list node
             void** node = malloc(2 * sizeof(void*));
             node[0] = $1;
             node[1] = $2;
             $$ = node;
         }
    ;

statement: variable_declaration { $$ = $1; }
        | assignment { $$ = $1; }
        | print_statement { $$ = $1; }
        | input_statement { $$ = $1; }
        | if_statement { $$ = $1; }
        | while_statement { $$ = $1; }
        | wait_statement { $$ = $1; }
        | save_statement { $$ = $1; }
        | NEWLINE { $$ = NULL; }
    ;

variable_declaration: VAR IDENTIFIER ASSIGN expression NEWLINE {
    void** node = malloc(4 * sizeof(void*));
    node[0] = strdup("var_decl");
    node[1] = strdup($2);
    node[2] = $4;
    node[3] = NULL;
    $$ = node;
}
    ;

assignment: IDENTIFIER ASSIGN expression NEWLINE {
    void** node = malloc(4 * sizeof(void*));
    node[0] = strdup("assign");
    node[1] = strdup($1);
    node[2] = $3;
    node[3] = NULL;
    $$ = node;
}
    ;

print_statement: PRINT LPAREN expression RPAREN NEWLINE {
    void** node = malloc(3 * sizeof(void*));
    node[0] = strdup("print");
    node[1] = $3;
    node[2] = NULL;
    $$ = node;
}
    ;

input_statement: IDENTIFIER ASSIGN INPUT NEWLINE {
    void** node = malloc(3 * sizeof(void*));
    node[0] = strdup("input");
    node[1] = strdup($1);
    node[2] = NULL;
    $$ = node;
}
    ;

if_statement: IF expression block else_if_list else_clause {
    void** node = malloc(6 * sizeof(void*));
    node[0] = strdup("if");
    node[1] = $2;
    node[2] = $3;
    node[3] = $4;
    node[4] = $5;
    node[5] = NULL;
    $$ = node;
}
    ;

else_if_list: /* empty */ { $$ = NULL; }
           | else_if_list ELSE IF expression block {
               void** node = malloc(3 * sizeof(void*));
               node[0] = $4;
               node[1] = $5;
               node[2] = $1;
               $$ = node;
           }
    ;

else_clause: /* empty */ { $$ = NULL; }
          | ELSE block { $$ = $2; }
    ;

while_statement: WHILE expression block {
    void** node = malloc(4 * sizeof(void*));
    node[0] = strdup("while");
    node[1] = $2;
    node[2] = $3;
    node[3] = NULL;
    $$ = node;
}
    ;

wait_statement: WAIT LPAREN expression RPAREN NEWLINE {
    void** node = malloc(3 * sizeof(void*));
    node[0] = strdup("wait");
    node[1] = $3;
    node[2] = NULL;
    $$ = node;
}
    ;

save_statement: SAVE LPAREN expression COMMA expression RPAREN NEWLINE {
    void** node = malloc(4 * sizeof(void*));
    node[0] = strdup("save");
    node[1] = $3;
    node[2] = $5;
    node[3] = NULL;
    $$ = node;
}
    ;

block: LBRACE statements RBRACE { $$ = $2; }
    ;

expression: comparison { $$ = $1; }
    ;

comparison: addition { $$ = $1; }
         | addition EQ addition {
             void** node = malloc(4 * sizeof(void*));
             node[0] = strdup("eq");
             node[1] = $1;
             node[2] = $3;
             node[3] = NULL;
             $$ = node;
         }
         | addition NE addition {
             void** node = malloc(4 * sizeof(void*));
             node[0] = strdup("ne");
             node[1] = $1;
             node[2] = $3;
             node[3] = NULL;
             $$ = node;
         }
         | addition LT addition {
             void** node = malloc(4 * sizeof(void*));
             node[0] = strdup("lt");
             node[1] = $1;
             node[2] = $3;
             node[3] = NULL;
             $$ = node;
         }
         | addition GT addition {
             void** node = malloc(4 * sizeof(void*));
             node[0] = strdup("gt");
             node[1] = $1;
             node[2] = $3;
             node[3] = NULL;
             $$ = node;
         }
         | addition LE addition {
             void** node = malloc(4 * sizeof(void*));
             node[0] = strdup("le");
             node[1] = $1;
             node[2] = $3;
             node[3] = NULL;
             $$ = node;
         }
         | addition GE addition {
             void** node = malloc(4 * sizeof(void*));
             node[0] = strdup("ge");
             node[1] = $1;
             node[2] = $3;
             node[3] = NULL;
             $$ = node;
         }
    ;

addition: term { $$ = $1; }
       | addition PLUS term {
           void** node = malloc(4 * sizeof(void*));
           node[0] = strdup("add");
           node[1] = $1;
           node[2] = $3;
           node[3] = NULL;
           $$ = node;
       }
       | addition MINUS term {
           void** node = malloc(4 * sizeof(void*));
           node[0] = strdup("sub");
           node[1] = $1;
           node[2] = $3;
           node[3] = NULL;
           $$ = node;
       }
    ;

term: factor { $$ = $1; }
    | term MULT factor {
        void** node = malloc(4 * sizeof(void*));
        node[0] = strdup("mul");
        node[1] = $1;
        node[2] = $3;
        node[3] = NULL;
        $$ = node;
    }
    | term DIV factor {
        void** node = malloc(4 * sizeof(void*));
        node[0] = strdup("div");
        node[1] = $1;
        node[2] = $3;
        node[3] = NULL;
        $$ = node;
    }
    ;

factor: NUMBER {
        void** node = malloc(3 * sizeof(void*));
        node[0] = strdup("number");
        // Store number in a dynamically allocated int
        int* num = malloc(sizeof(int));
        *num = $1;
        node[1] = num;
        node[2] = NULL;
        $$ = node;
    }
     | STRING {
        void** node = malloc(3 * sizeof(void*));
        node[0] = strdup("string");
        node[1] = strdup($1);
        node[2] = NULL;
        $$ = node;
    }
     | IDENTIFIER {
        void** node = malloc(3 * sizeof(void*));
        node[0] = strdup("identifier");
        node[1] = strdup($1);
        node[2] = NULL;
        $$ = node;
    }
     | INPUT {
        void** node = malloc(2 * sizeof(void*));
        node[0] = strdup("input");
        node[1] = NULL;
        $$ = node;
    }
     | TIME LPAREN RPAREN {
        void** node = malloc(2 * sizeof(void*));
        node[0] = strdup("time");
        node[1] = NULL;
        $$ = node;
    }
     | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

void print_ast(void *node, int level) {
    if (node == NULL) return;
    
    void **n = (void**)node;
    char *type = (char*)n[0];
    
    // Print indentation
    for (int i = 0; i < level; i++) printf("  ");
    
    if (strcmp(type, "number") == 0) {
        printf("Number: %d\n", *(int*)n[1]);
    }
    else if (strcmp(type, "string") == 0) {
        printf("String: %s\n", (char*)n[1]);
    }
    else if (strcmp(type, "identifier") == 0) {
        printf("Identifier: %s\n", (char*)n[1]);
    }
    else if (strcmp(type, "var_decl") == 0) {
        printf("Variable Declaration:\n");
        for (int i = 0; i < level + 1; i++) printf("  ");
        printf("Name: %s\n", (char*)n[1]);
        print_ast(n[2], level + 1);
    }
    else if (strcmp(type, "assign") == 0) {
        printf("Assignment:\n");
        for (int i = 0; i < level + 1; i++) printf("  ");
        printf("Variable: %s\n", (char*)n[1]);
        print_ast(n[2], level + 1);
    }
    else if (strcmp(type, "print") == 0) {
        printf("Print Statement:\n");
        print_ast(n[1], level + 1);
    }
    else if (strcmp(type, "while") == 0) {
        printf("While Loop:\n");
        printf("  Condition:\n");
        print_ast(n[1], level + 2);
        printf("  Body:\n");
        print_ast(n[2], level + 2);
    }
    else if (strcmp(type, "if") == 0) {
        printf("If Statement:\n");
        printf("  Condition:\n");
        print_ast(n[1], level + 2);
        printf("  Then:\n");
        print_ast(n[2], level + 2);
        if (n[3] != NULL) {
            printf("  Else If:\n");
            print_ast(n[3], level + 2);
        }
        if (n[4] != NULL) {
            printf("  Else:\n");
            print_ast(n[4], level + 2);
        }
    }
    else if (strcmp(type, "input") == 0) {
        printf("Input Operation\n");
    }
    else if (strcmp(type, "wait") == 0) {
        printf("Wait Statement:\n");
        print_ast(n[1], level + 1);
    }
    else if (strcmp(type, "save") == 0) {
        printf("Save Statement:\n");
        printf("  File:\n");
        print_ast(n[1], level + 2);
        printf("  Content:\n");
        print_ast(n[2], level + 2);
    }
    else {
        printf("%s\n", type);
        // Print children
        for (int i = 1; n[i] != NULL; i++) {
            print_ast(n[i], level + 1);
        }
    }
}

void yyerror(char *s) {
    fprintf(stderr, "Line %d: Syntax error: %s\n", line_num, s);
    fprintf(stderr, "Unexpected token: %s\n", yytext);
    fprintf(stderr, "Current line: %d\n", line_num);
}

int main(void) {
    yyparse();
    return 0;
} 