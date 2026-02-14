%{
/* Analizador léxico para Java - Lab 1 */
#include <stdio.h>
#include <stdlib.h>

int line_num = 1;
%}

DIGIT       [0-9]
IDENTIFIER  [a-zA-Z_][a-zA-Z0-9_]*
INTEGER     {DIGIT}+
HEX         0[xX][0-9a-fA-F]+
FLOAT       {DIGIT}+\.{DIGIT}+
SCIENTIFIC  {DIGIT}+(\.{DIGIT}+)?[eE][+-]?{DIGIT}+
WHITESPACE  [ \t\r]+

%x COMMENT

%%

"//".*      { }
"/*"        { BEGIN(COMMENT); }
<COMMENT>"*/" { BEGIN(INITIAL); }
<COMMENT>\n { line_num++; }
<COMMENT>.  { }

\"([^\\\"]|\\.)*\"   { printf("STRING: %s (línea %d)\n", yytext, line_num); }

{SCIENTIFIC} { printf("SCIENTIFIC_NUMBER: %s (línea %d)\n", yytext, line_num); }
{HEX}       { printf("HEXADECIMAL: %s (línea %d)\n", yytext, line_num); }
{FLOAT}     { printf("FLOAT: %s (línea %d)\n", yytext, line_num); }
{INTEGER}   { printf("INTEGER: %s (línea %d)\n", yytext, line_num); }

"=="        { printf("RELATIONAL_OP: == (línea %d)\n", line_num); }
"!="        { printf("RELATIONAL_OP: != (línea %d)\n", line_num); }
"<="        { printf("RELATIONAL_OP: <= (línea %d)\n", line_num); }
">="        { printf("RELATIONAL_OP: >= (línea %d)\n", line_num); }
"<"         { printf("RELATIONAL_OP: < (línea %d)\n", line_num); }
">"         { printf("RELATIONAL_OP: > (línea %d)\n", line_num); }

"&&"        { printf("LOGICAL_OP: && (línea %d)\n", line_num); }
"||"        { printf("LOGICAL_OP: || (línea %d)\n", line_num); }
"!"         { printf("LOGICAL_OP: ! (línea %d)\n", line_num); }

"+"         { printf("ARITHMETIC_OP: + (línea %d)\n", line_num); }
"-"         { printf("ARITHMETIC_OP: - (línea %d)\n", line_num); }
"*"         { printf("ARITHMETIC_OP: * (línea %d)\n", line_num); }
"/"         { printf("ARITHMETIC_OP: / (línea %d)\n", line_num); }

"="         { printf("ASSIGNMENT: = (línea %d)\n", line_num); }
";"         { printf("SEMICOLON: ; (línea %d)\n", line_num); }
"("         { printf("LPAREN: ( (línea %d)\n", line_num); }
")"         { printf("RPAREN: ) (línea %d)\n", line_num); }
"{"         { printf("LBRACE: { (línea %d)\n", line_num); }
"}"         { printf("RBRACE: } (línea %d)\n", line_num); }
","         { printf("COMMA: , (línea %d)\n", line_num); }

"class"     { printf("KEYWORD: class (línea %d)\n", line_num); }
"public"    { printf("KEYWORD: public (línea %d)\n", line_num); }
"private"   { printf("KEYWORD: private (línea %d)\n", line_num); }
"static"    { printf("KEYWORD: static (línea %d)\n", line_num); }
"void"      { printf("KEYWORD: void (línea %d)\n", line_num); }
"int"       { printf("KEYWORD: int (línea %d)\n", line_num); }
"float"     { printf("KEYWORD: float (línea %d)\n", line_num); }
"double"    { printf("KEYWORD: double (línea %d)\n", line_num); }
"if"        { printf("KEYWORD: if (línea %d)\n", line_num); }
"else"      { printf("KEYWORD: else (línea %d)\n", line_num); }
"while"     { printf("KEYWORD: while (línea %d)\n", line_num); }
"for"       { printf("KEYWORD: for (línea %d)\n", line_num); }
"return"    { printf("KEYWORD: return (línea %d)\n", line_num); }

{IDENTIFIER} { printf("IDENTIFIER: %s (línea %d)\n", yytext, line_num); }

\n          { line_num++; }
{WHITESPACE} { }

.           { printf("ERROR: Caracter no reconocido '%s' (línea %d)\n", yytext, line_num); }

%%

int yywrap() { return 1; }

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Error: No se puede abrir '%s'\n", argv[1]);
            return 1;
        }
    }
    yylex();
    if (argc > 1) fclose(yyin);
    return 0;
}
