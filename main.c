#include <stdio.h>
#include <stdlib.h>

/*
free_slist: .word 0
cclist: .word 0
wclist: .word 0
buffer: .space 104

# MENSAJES
bn: .asciiz "\n"
.align 2
un_asterisco_solitario: .asciiz "*"
.align 2
wclist_mensaje: .asciiz "Categoria en curso: "
.align 2
menu_mensaje:.asciiz "    
    1) Crear una nueva categoria
    2) Pasar a la siguiente categoria
    3) Pasar a la anterior categoria
    4) Mostrar todas las categorias
    5) Borrar la categoria seleccionada
    6) Anexar un objeto a la categoria seleccionada
    7) Borrar un objeto de la categoria seleccionada
    8) Mostrar todos los objetos de la categoria seleccionada
    9) Salir

Seleccione una opcion por su numero: "
.align 2
no_se_vale: .asciiz "Opcion no valida"
.align 2
sin_catego: .asciiz "Antes tiene que crear una categoria"
.align 2
ingrese_palabra: .asciiz "Ingrese una palabra: "
.align 2
ingrese_numero: .asciiz "Ingrese un numero: "
.align 2

*/

void *wclist = NULL;
void *cclist = NULL;

const char *menu_mensaje =
    "1) Crear una nueva categoria\n"
    "2) Pasar a la siguiente categoria\n"
    "3) Pasar a la anterior categoria\n"
    "4) Mostrar todas las categorias\n"
    "5) Borrar la categoria seleccionada\n"
    "6) Anexar un objeto a la categoria seleccionada\n"
    "7) Borrar un objeto de la categoria seleccionada\n"
    "8) Mostrar todos los objetos de la categoria seleccionada\n"
    "9) Salir\n"
    "Seleccione una opcion por su numero: \n";

const char *wclist_mensaje = "Categoria en curso: ";
const char *no_se_vale = "Opcion no valida\n";
const char *ingrese_palabra = "Ingrese una palabra: ";

char buffer[104];

void newobject();

int main()
{
    int opcion = 0;
    while (opcion != 9)
    {
        if (wclist)
        {
            puts(wclist_mensaje);
            puts(wclist + 8);
        }
        puts(menu_mensaje);
        scanf("%d", &opcion);
        if (opcion <= 0 || opcion >= 10)
        {
            puts(no_se_vale);
            continue;
        }
        if (opcion == 9)
            break;

        switch (opcion)
        {
        case 1:
            puts(ingrese_palabra);
            scanf("%s",buffer);
            newobject();
            break;
        
        default:
            break;
        }
    }
    return 0;
}