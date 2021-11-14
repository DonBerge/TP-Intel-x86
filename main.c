#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cdecl.h"

void* PRE_CDECL newnode(void **lista, void *extra) POST_CDECL;
void* PRE_CDECL delnode(void *node) POST_CDECL;
void PRE_CDECL doinlist(void *node, void (*func)(void *, void *), void *arg) POST_CDECL;
void* PRE_CDECL next(void *node) POST_CDECL;
void* PRE_CDECL prev(void *node) POST_CDECL;

void *wclist = NULL;
void *cclist = NULL;

const char *menu_mensaje =
    "1) Crear una nueva categoria\n"
    "2) Pasar a la anterior categoria\n"
    "3) Pasar a la siguiente categoria\n"
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

void newcatego()
{
    void *oldcclist = cclist;
    newnode(&cclist, NULL);
    if (oldcclist == NULL)
        wclist = cclist;
}

void nextcatego()
{
    wclist = next(wclist);
}

void prevcatego()
{
    wclist = prev(wclist);
}

void delcatego()
{
    void* p = delnode(wclist);
    printf("%p %p\n",wclist, p);
    wclist = p;
}

char buffer[104];

char* getString()
{
    char* str = malloc(100);
    strncpy(str, buffer, 99);
    str[100]='\0';
    return str;
}

int main()
{
    int opcion = 0;
    while (opcion != 9)
    {
        printf("%p",prev(wclist));
        printf(" %p ",wclist);
        printf("%p\n",next(wclist));
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
            scanf("%s", buffer);
            newcatego();
            break;
        case 2:
            nextcatego();
            break;
        case 3:
            prevcatego();
            break;
        case 5:
            delcatego();
        default:
            break;
        }
    }
    return 0;
}