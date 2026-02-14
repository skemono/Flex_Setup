// Test file para el analizador léxico de Java
// Prueba de todas las características implementadas

/* Este es un comentario
   multilínea que debe ser
   ignorado por el lexer */

public class TestClass {
    // Prueba 1: Identificadores válidos
    int variable1;
    int _underscore;
    int camelCase;
    int snake_case_123;
    int _123mixed;
    
    // Prueba 2: Literales numéricos
    
    // Enteros
    int a = 42;
    int b = 0;
    int c = 999999;
    
    // Hexadecimales
    int hex1 = 0xFF;
    int hex2 = 0x1A2B;
    int hex3 = 0xDEADBEEF;
    
    // Flotantes
    float f1 = 3.14;
    double d1 = 2.71828;
    float f2 = 0.5;
    
    // Notación científica
    double sci1 = 1.5e10;
    double sci2 = 2.3E-5;
    double sci3 = 5e+3;
    double sci4 = 6.022e23;
    
    // Prueba 3: Operadores aritméticos
    public int arithmetic() {
        int x = 10 + 5;
        int y = 20 - 8;
        int z = 4 * 6;
        int w = 15 / 3;
        return x + y * z - w / 2;
    }
    
    // Prueba 4: Operadores relacionales
    public void relational(int a, int b) {
        if (a == b) return;
        if (a != b) return;
        if (a < b) return;
        if (a > b) return;
        if (a <= b) return;
        if (a >= b) return;
    }
    
    // Prueba 5: Operadores lógicos
    public void logical(int x, int y) {
        if (x > 0 && y > 0) return;
        if (x < 0 || y < 0) return;
        if (!(x == y)) return;
    }
    
    // Prueba 6: Cadenas literales con secuencias de escape
    public void strings() {
        String s1 = "Hello World";
        String s2 = "Line 1\nLine 2";
        String s3 = "Tab\there";
        String s4 = "Quote: \"text\"";
        String s5 = "Backslash: \\";
        String s6 = "Path: C:\\Users\\Documents";
        String s7 = "Empty: \"\"";
    }
    
    // Prueba 7: Comentarios mixtos
    private static void comments() {
        int x = 5; // comentario de una línea
        /* comentario multilínea */ int y = 10;
        /* otro comentario
           en varias
           líneas */
    }
}

// Prueba 8: Casos edge
class EdgeCases {
    int _; // identificador válido
    int __multiple_underscores__;
    int a1b2c3d4e5;
    
    // Números en expresiones complejas
    double result = 1.5e10 + 0xFF - 3.14 * 2;
}
