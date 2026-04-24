# Python Parser — Flex + YACC

# [Ver respuestas de la actividad → RESPUESTAS.md](./RESPUESTAS.md)

## Files

| File                  | Role                                                              |
| --------------------- | ----------------------------------------------------------------- |
| `python_parser.l`     | Flex lexer — prints tokens and returns codes to YACC              |
| `python_parser.y`     | YACC grammar — defines valid syntax, calls `yyerror` on bad input |
| `test_valid.input`    | Input válido (parsea sin errores)                                 |
| `test_error.input`    | Input con error de sintaxis en línea 2                            |
| `test_modpow.input`   | Pruebas de módulo `%` y exponenciación `**`                       |
| `test_lists.input`    | Pruebas de listas `[...]`                                         |

## How to Build

```bash
# 1. Entrar al contenedor
docker compose exec flex bash
cd /workspace/examples

# 2. Generar archivos C
yacc -d python_parser.y
flex python_parser.l

# 3. Compilar
gcc y.tab.c lex.yy.c -o parser
```

---

## Resultado 1 — Input válido

```bash
./parser < test_valid.input
```

```
=== Python Parser (Flex + YACC) ===

  [TOKEN] ID         -> 'x'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '5'
  [PARSE] Assignment
  [TOKEN] ID         -> 'y'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] ID         -> 'x'
  [TOKEN] PLUS       -> '+'
  [TOKEN] NUMBER     -> '3'
  [PARSE] Addition
  [PARSE] Assignment
  [TOKEN] ID         -> 'z'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] LPAREN     -> '('
  [TOKEN] ID         -> 'x'
  [TOKEN] PLUS       -> '+'
  [TOKEN] ID         -> 'y'
  [TOKEN] RPAREN     -> ')'
  [PARSE] Addition
  [TOKEN] TIMES      -> '*'
  [TOKEN] NUMBER     -> '2'
  [PARSE] Multiplication
  [PARSE] Assignment
  [TOKEN] DEF        -> 'def'
  [TOKEN] ID         -> 'add'
  [TOKEN] LPAREN     -> '('
  [TOKEN] ID         -> 'a'
  [TOKEN] COMMA      -> ','
  [TOKEN] ID         -> 'b'
  [TOKEN] RPAREN     -> ')'
  [TOKEN] COLON      -> ':'
  [PARSE] Function definition
  [TOKEN] ID         -> 'result'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] ID         -> 'a'
  [TOKEN] PLUS       -> '+'
  [TOKEN] ID         -> 'b'
  [PARSE] Addition
  [PARSE] Assignment

[OK] Input parsed successfully — no syntax errors.
```

## Resultado 1 — Input con error de sintaxis

```bash
./parser < test_error.input
```

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

---

## Resultado 5 — Módulo y exponenciación

```bash
./parser < test_modpow.input
```

```
=== Python Parser (Flex + YACC) ===

  [TOKEN] ID         -> 'a'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '10'
  [TOKEN] MOD        -> '%'
  [TOKEN] NUMBER     -> '3'
  [PARSE] Modulo
  [PARSE] Assignment
  [TOKEN] ID         -> 'b'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '2'
  [TOKEN] POW        -> '**'
  [TOKEN] NUMBER     -> '8'
  [PARSE] Exponentiation
  [PARSE] Assignment
  [TOKEN] ID         -> 'c'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '10'
  [TOKEN] MOD        -> '%'
  [TOKEN] NUMBER     -> '3'
  [TOKEN] PLUS       -> '+'
  [PARSE] Modulo
  [TOKEN] NUMBER     -> '2'
  [PARSE] Addition
  [PARSE] Assignment
  [TOKEN] ID         -> 'd'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '2'
  [TOKEN] POW        -> '**'
  [TOKEN] NUMBER     -> '3'
  [TOKEN] POW        -> '**'
  [TOKEN] NUMBER     -> '2'
  [PARSE] Exponentiation
  [PARSE] Exponentiation
  [PARSE] Assignment

[OK] Input parsed successfully — no syntax errors.
```

---

## Resultado 6 — Listas

```bash
./parser < test_lists.input
```

```
=== Python Parser (Flex + YACC) ===

  [TOKEN] ID         -> 'empty'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] LBRACKET   -> '['
  [TOKEN] RBRACKET   -> ']'
  [PARSE] Empty list
  [PARSE] Assignment
  [TOKEN] ID         -> 'nums'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] LBRACKET   -> '['
  [TOKEN] NUMBER     -> '1'
  [TOKEN] COMMA      -> ','
  [TOKEN] NUMBER     -> '2'
  [TOKEN] COMMA      -> ','
  [TOKEN] NUMBER     -> '3'
  [TOKEN] RBRACKET   -> ']'
  [PARSE] List
  [PARSE] Assignment
  [TOKEN] ID         -> 'nested'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] LBRACKET   -> '['
  [TOKEN] NUMBER     -> '1'
  [TOKEN] COMMA      -> ','
  [TOKEN] LBRACKET   -> '['
  [TOKEN] NUMBER     -> '2'
  [TOKEN] COMMA      -> ','
  [TOKEN] NUMBER     -> '3'
  [TOKEN] RBRACKET   -> ']'
  [PARSE] List
  [TOKEN] RBRACKET   -> ']'
  [PARSE] List
  [PARSE] Assignment

[OK] Input parsed successfully — no syntax errors.
```

---

## Grammar

```
program     → statement+
statement   → ID = expr NEWLINE
            | expr NEWLINE
            | def ID ( params ) : NEWLINE
            | NEWLINE
expr        → expr + term | expr - term | term
term        → term * power | term / power | term % power | power
power       → factor ** power | factor
factor      → ID | NUMBER | ( expr ) | list
list        → [ ] | [ expr_list ]
expr_list   → expr | expr_list , expr
```

## Key YACC variables / functions

| Item           | Description                                             |
| -------------- | ------------------------------------------------------- |
| `yyparse()`    | Starts parsing; returns 0 on success                    |
| `yylex()`      | Called by YACC to get the next token (provided by Flex) |
| `yyerror(msg)` | Called on syntax error; receives the error message      |
| `%token`       | Declares terminal symbols shared between `.y` and `.l`  |
| `%left`        | Declares left-associative operators (sets precedence)   |
| `%right`       | Declares right-associative operators (e.g. `**`)        |
| `yacc -d`      | Generates `y.tab.h` so the lexer knows the token codes  |
