# Pregunta 7: Cambio de Color de Palabras (Syntax Highlighting)

## ¿Cómo implementar syntax highlighting al estilo Visual Studio Code?

Para cambiar el color de palabras clave y tokens en un editor como Visual Studio Code, necesitarías extender el lexer actual con información de colorización. Aquí están los pasos y consideraciones:

## 1. Extensión del Lexer para Colorización

### Modificar el Lexer Flex
En lugar de simplemente imprimir tokens, el lexer debería retornar información estructurada:

```c
%{
typedef struct {
    char *type;      // Tipo de token
    char *value;     // Valor del token
    int line;        // Número de línea
    int column;      // Columna de inicio
    int length;      // Longitud del token
    char *color;     // Color/categoría para highlighting
} Token;
%}

// En lugar de printf, retornar tokens con información de posición
{KEYWORD} {
    return create_token("KEYWORD", yytext, line_num, column, yyleng, "keyword");
}

{IDENTIFIER} {
    return create_token("IDENTIFIER", yytext, line_num, column, yyleng, "identifier");
}
```

## 2. Categorías de Colorización

### Mapeo de Tokens a Categorías de Color

| Categoría Token | Tipo de Color | Ejemplo VSCode |
|----------------|---------------|----------------|
| Keywords       | `keyword`     | Azul (#569CD6) |
| Identifiers    | `variable`    | Celeste (#9CDCFE) |
| Strings        | `string`      | Naranja (#CE9178) |
| Numbers        | `number`      | Verde claro (#B5CEA8) |
| Operators      | `operator`    | Blanco/Gris |
| Comments       | `comment`     | Verde (#6A9955) |
| Functions      | `function`    | Amarillo (#DCDCAA) |
| Types          | `type`        | Verde azulado (#4EC9B0) |

## 3. Arquitectura de Integración

### Opción A: Language Server Protocol (LSP)

```
Editor (VSCode) <--LSP--> Language Server <---> Lexer/Parser
```

**Pasos:**
1. Crear un Language Server que use tu lexer
2. El servidor procesa el archivo con el lexer
3. Retorna tokens con información semántica
4. VSCode aplica colores según la configuración del tema

### Opción B: TextMate Grammar

VSCode usa gramáticas TextMate para syntax highlighting básico:

```json
{
  "scopeName": "source.java",
  "patterns": [
    {
      "name": "keyword.control.java",
      "match": "\\b(if|else|while|for|return)\\b"
    },
    {
      "name": "string.quoted.double.java",
      "match": "\"([^\\\\\"]|\\\\.)*\""
    },
    {
      "name": "constant.numeric.java",
      "match": "\\b[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?\\b"
    }
  ]
}
```

### Opción C: Extensión del Output del Lexer

Modificar el lexer actual para generar output en formato estructurado:

```c
// Output JSON para fácil parsing
{KEYWORD} {
    printf("{\"type\":\"keyword\",\"value\":\"%s\",\"line\":%d,\"color\":\"#569CD6\"},\n", 
           yytext, line_num);
}
```

## 4. Implementación Práctica para VSCode

### Paso 1: Crear una Extensión de VSCode

```javascript
// extension.js
const vscode = require('vscode');
const { execFile } = require('child_process');

function activate(context) {
    // Registrar provider de colorización
    const provider = vscode.languages.registerDocumentSemanticTokensProvider(
        { language: 'java' },
        new MySemanticTokensProvider(),
        legend
    );
    context.subscriptions.push(provider);
}

class MySemanticTokensProvider {
    async provideDocumentSemanticTokens(document) {
        // 1. Ejecutar el lexer con el contenido del documento
        const tokens = await runLexer(document.getText());
        
        // 2. Convertir tokens del lexer a tokens semánticos de VSCode
        const builder = new vscode.SemanticTokensBuilder(legend);
        
        tokens.forEach(token => {
            builder.push(
                token.line,
                token.column,
                token.length,
                getTokenType(token.type),
                0 // modifiers
            );
        });
        
        return builder.build();
    }
}
```

### Paso 2: Definir la Leyenda de Tokens

```javascript
const legend = new vscode.SemanticTokensLegend(
    ['keyword', 'string', 'number', 'operator', 'comment', 'variable', 'function'],
    [] // modifiers
);
```

## 5. Modificaciones Necesarias al Lexer Actual

Para integrar con un sistema de colorización, el lexer necesitaría:

```c
// Agregar tracking de columnas
int column = 1;

// Mantener información de posición
#define YY_USER_ACTION { \
    yylloc.first_line = line_num; \
    yylloc.first_column = column; \
    yylloc.last_column = column + yyleng; \
    column += yyleng; \
}

// Output estructurado en lugar de printf
{KEYWORD} {
    emit_token(TOKEN_KEYWORD, yytext, line_num, column - yyleng, yyleng);
}

// Función para emitir tokens en formato estructurado
void emit_token(int type, char *value, int line, int col, int len) {
    printf("%d,%d,%d,%d,%s\n", type, line, col, len, value);
    // Formato: tipo,línea,columna,longitud,valor
}
```

## 6. Archivo de Configuración de Colores

Crear un archivo de tema que mapee categorías a colores:

```json
{
  "tokenColors": [
    {
      "scope": "keyword",
      "settings": {
        "foreground": "#569CD6",
        "fontStyle": "bold"
      }
    },
    {
      "scope": "string",
      "settings": {
        "foreground": "#CE9178"
      }
    },
    {
      "scope": "constant.numeric",
      "settings": {
        "foreground": "#B5CEA8"
      }
    },
    {
      "scope": "comment",
      "settings": {
        "foreground": "#6A9955",
        "fontStyle": "italic"
      }
    }
  ]
}
```

## Resumen

Para implementar syntax highlighting necesitarías:

1. **Extender el lexer** para retornar información de posición (línea, columna, longitud)
2. **Categorizar tokens** según su propósito semántico
3. **Implementar un proveedor** (LSP o extensión) que:
   - Ejecute el lexer sobre el código
   - Convierta los tokens a formato del editor
   - Comunique al editor qué colores aplicar
4. **Definir mapeo de colores** según el tema del editor
5. **Manejar actualizaciones en tiempo real** mientras el usuario edita

El enfoque más robusto es usar **Language Server Protocol (LSP)** ya que permite no solo colorización sino también otras características como autocompletado, ir a definición, etc.
