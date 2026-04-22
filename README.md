# Python Parser — Flex + YACC

Extends the Python scanner with a **YACC grammar** that validates syntax and reports errors with line numbers.

## Files

| File               | Role                                                              |
| ------------------ | ----------------------------------------------------------------- |
| `python_parser.l`  | Flex lexer — prints tokens **and** returns codes to YACC          |
| `python_parser.y`  | YACC grammar — defines valid syntax, calls `yyerror` on bad input |
| `test_valid.input` | Valid input (parses cleanly)                                      |
| `test_error.input` | Input with a syntax error on line 2                               |

## How to Build

```bash
# 1. Enter the container
docker compose exec flex bash
cd /workspace/examples

# 2. Generate C files
yacc -d python_parser.y    # produces y.tab.c and y.tab.h
flex python_parser.l       # produces lex.yy.c

# 3. Compile
gcc y.tab.c lex.yy.c -o parser
```

## Running — valid input

```bash
./parser < test_valid.input
```

Expected output:

```
=== Python Parser (Flex + YACC) ===

  [TOKEN] ID         -> 'x'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '5'
  [PARSE] Assignment
  ...
  [TOKEN] DEF        -> 'def'
  [TOKEN] ID         -> 'add'
  ...
  [PARSE] Function definition

[OK] Input parsed successfully — no syntax errors.
```

## Running — input with a syntax error

```bash
./parser < test_error.input
```

`test_error.input` contains `y = * 3` on line 2 — a `*` where an expression is expected.

Expected output:

```
=== Python Parser (Flex + YACC) ===

  [TOKEN] ID         -> 'x'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '5'
  [PARSE] Assignment
  [TOKEN] ID         -> 'y'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] TIMES      -> '*'

  [SYNTAX ERROR] syntax error at line 2

[FAIL] Parsing stopped due to syntax error(s).
```

## Grammar summary

```
program       → statement+
statement     → ID = expr NEWLINE
              | expr NEWLINE
              | def ID ( params ) : NEWLINE
              | NEWLINE
expr          → expr + term | expr - term | term
term          → term * factor | term / factor | factor
factor        → ID | NUMBER | ( expr )
```

## Key YACC variables / functions

| Item           | Description                                             |
| -------------- | ------------------------------------------------------- |
| `yyparse()`    | Starts parsing; returns 0 on success                    |
| `yylex()`      | Called by YACC to get the next token (provided by Flex) |
| `yyerror(msg)` | Called on syntax error; receives the error message      |
| `%token`       | Declares terminal symbols shared between `.y` and `.l`  |
| `%left`        | Declares left-associative operators (sets precedence)   |
| `yacc -d`      | Generates `y.tab.h` so the lexer knows the token codes  |
