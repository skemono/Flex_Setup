# Actividad: Comprendiendo un generador sintáctico

[Repo](https://github.com/skemono/Flex_Setup/blob/Yacc/RESPUESTAS.md)

## Inciso 1 — Significado de [TOKEN] y [PARSE]

Al ejecutar `./parser < test_valid.input` se observan dos tipos de líneas:

```
  [TOKEN] ID         -> 'x'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '5'
  [PARSE] Assignment
```

- **[TOKEN]**: Lo imprime el **lexer** (Flex) cada vez que reconoce un símbolo atómico del texto de entrada: un identificador, un número, un operador. Ocurre durante el escaneo carácter a carácter.
- **[PARSE]**: Lo imprime el **parser** (YACC) cuando completa una reducción gramatical, es decir, cuando agrupa varios tokens en una estructura con significado semántico (una asignación, una suma, una función).

---

## Inciso 2 — Diferencia entre tokens y reducciones

El **lexer** convierte el texto plano en unidades mínimas con significado propio llamadas tokens. Por ejemplo, la cadena `x + 3` produce tres tokens: `ID`, `PLUS`, `NUMBER`.

El **parser** toma esos tokens y los combina aplicando las reglas gramaticales del lenguaje mediante *reducciones*. Por ejemplo, `NUMBER PLUS NUMBER` se reduce a `term`, luego a `expr`, y al encontrar el salto de línea, se reduce a `statement` con el mensaje `[PARSE] Addition`. Los tokens son la materia prima; las reducciones son la estructura resultante.

---

## Inciso 3 — Cómo modificar el formato del output

Las líneas `[TOKEN]` se controlan en `python_parser.l` dentro de la función `print_token()`:

```c
void print_token(const char* type) {
    printf("  [TOKEN] %-10s -> '%s'\n", type, yytext);
}
```

Para agregar el número de línea se cambiaría a:

```c
printf("  [TOKEN] %-10s -> '%s' (line %d)\n", type, yytext, line);
```

Las líneas `[PARSE]` se controlan en `python_parser.y` dentro de las acciones de cada regla gramatical:

```yacc
| expr PLUS term  { printf("  [PARSE] Addition\n"); }
```

Para cambiar el prefijo o agregar información adicional basta con modificar esos `printf`.

---

## Inciso 4 — ¿Por qué ya no se necesita `./scanner` antes de `./parser`?

En la arquitectura anterior el scanner era un programa independiente con su propio `main()` que escaneaba el input y producía texto como salida.

Ahora el lexer (Flex) y el parser (YACC) **se compilan juntos en un solo ejecutable**. El archivo `.l` ya no tiene `main()` propio; solo define `yylex()`. El `main()` vive en el `.y` y llama a `yyparse()`, que internamente llama a `yylex()` cada vez que necesita el siguiente token. Son una sola unidad binaria y la comunicación entre lexer y parser ocurre a través de llamadas a función, no a través de texto.

---

## Inciso 5 — Operadores módulo `%` y exponenciación `**`

### Cambios en el scanner (`python_parser.l`)

Se agregaron dos reglas. La regla de `**` debe ir **antes** de `*` para que Flex la tome como un token de dos caracteres (Flex usa la coincidencia más larga, pero por claridad se declara primero):

```lex
"**"  { print_token("POW"); return POW; }
"*"   { print_token("TIMES"); return TIMES; }
"%"   { print_token("MOD"); return MOD; }
```

Sí es necesario modificar el scanner porque los tokens `POW` y `MOD` no existían y Flex no los reconocía.

### Cambios en el parser (`python_parser.y`)

Se declararon los tokens y su precedencia:

```yacc
%token MOD POW

%left  PLUS MINUS
%left  TIMES DIVIDE MOD
%right POW
```

`MOD` va al mismo nivel que `*` y `/` porque tiene igual precedencia. `POW` va más arriba (mayor precedencia) y es `%right` porque la exponenciación es right-associative: `2**3**2` = `2**(3**2)`.

Se agregó el nivel `power` entre `term` y `factor`:

```yacc
term
    : term TIMES  power   { printf("  [PARSE] Multiplication\n"); }
    | term DIVIDE power   { printf("  [PARSE] Division\n"); }
    | term MOD    power   { printf("  [PARSE] Modulo\n"); }
    | power
    ;

power
    : factor POW power    { printf("  [PARSE] Exponentiation\n"); }
    | factor
    ;
```

### Caso de prueba y salida

Input (`test_modpow.input`):
```
a = 10 % 3
b = 2 ** 8
c = 10 % 3 + 2
d = 2 ** 3 ** 2
```

Salida obtenida:
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

En `c = 10 % 3 + 2` el módulo se reduce antes que la suma, confirmando que `%` tiene mayor precedencia que `+`. En `d = 2 ** 3 ** 2` se producen dos reducciones `Exponentiation` de derecha a izquierda, confirmando la asociatividad derecha.

---

## Inciso 6 — Soporte de listas `[expr, expr, ...]`

### Cambios en el scanner (`python_parser.l`)

Se agregaron dos tokens para los corchetes. La coma ya existía:

```lex
"["  { print_token("LBRACKET"); return LBRACKET; }
"]"  { print_token("RBRACKET"); return RBRACKET; }
```

### Cambios en el parser (`python_parser.y`)

Se declararon los nuevos tokens:

```yacc
%token LBRACKET RBRACKET
```

Se agregaron las reglas `list` y `expr_list`, y `factor` ahora puede ser una lista:

```yacc
factor
    : ID
    | NUMBER
    | LPAREN expr RPAREN
    | list
    ;

list
    : LBRACKET RBRACKET              { printf("  [PARSE] Empty list\n"); }
    | LBRACKET expr_list RBRACKET    { printf("  [PARSE] List\n"); }
    ;

expr_list
    : expr
    | expr_list COMMA expr
    ;
```

Las listas anidadas funcionan automáticamente porque `list` es un `factor`, que sube por `power → term → expr`, lo que permite que una lista aparezca dentro de otra lista como elemento.

### Casos de prueba y salida

Input (`test_lists.input`):
```
empty = []
nums = [1, 2, 3]
nested = [1, [2, 3]]
```

Salida obtenida:
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

Los tres casos de prueba pasan correctamente: lista vacía, lista con elementos y lista anidada.
