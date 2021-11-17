#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cdecl.h"

#define true 1
#define false 0

typedef void *node;
typedef void *any;
typedef void *list;
typedef char *string;

typedef unsigned char bool;

// node = | node | any | string | node |
//       0      4     8       12     16

void PRE_CDECL newnode(list* lista, any extra) POST_CDECL;
void PRE_CDECL delnode(node* node) POST_CDECL;
void PRE_CDECL doinlist(list* lista, void (*func)(node*, any), any arg) POST_CDECL;
node PRE_CDECL next(node _node) POST_CDECL;
node PRE_CDECL prev(node _node) POST_CDECL;
string PRE_CDECL getNodeString(node _node) POST_CDECL;
any* PRE_CDECL getNodeVal(node _node) POST_CDECL;
int PRE_CDECL getLongitud(list lista) POST_CDECL;
void PRE_CDECL printNodeString(node* _node, any val) POST_CDECL;
void PRE_CDECL printNodeId(node _node,any val) POST_CDECL;
void* PRE_CDECL findby(node _node,any val) POST_CDECL;

list wclist = NULL;
list cclist = NULL;

char buffer[104];

const string menu_mensaje =
    "1) Crear una nueva categoria\n"
    "2) Pasar a la anterior categoria\n"
    "3) Pasar a la siguiente categoria\n"
    "4) Mostrar todas las categorias\n"
    "5) Borrar la categoria seleccionada\n"
    "6) Anexar un objeto a la categoria seleccionada\n"
    "7) Borrar un objeto de la categoria seleccionada\n"
    "8) Mostrar todos los objetos de la categoria seleccionada\n"
    "9) Salir\n"
    "Seleccione una opcion por su numero: ";

const string wclist_mensaje = "Categoria en curso: ";
const string no_se_vale = "Opcion no valida\n";
const string ingrese_palabra = "Ingrese una palabra: ";
const string ingrese_numero = "Ingrese un numero: ";
const string sin_catego = "Antes tiene que crear una categoria";

void clrscr()
{
#ifdef __linux__
    system("clear");
#else
    system("cls");
#endif
}

void pause()
{
#ifdef __linux__
    printf("Presione una tecla para continuar");
    getchar();
    getchar();
#else
    system("pause");
#endif
}

void newcatego()
{
    list oldcclist = cclist;
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

void mostrarcategos()
{
    doinlist(&cclist, printNodeString, wclist);
    pause();
}

void delnodeparaquefuncionecondoinlist(node* _node, any val) // Sirve para eliminar una lista: ejemplo doinlist(&list,delnodeparaque*,NULL);
{
    delnode(_node);
}

void delcatego()
{
    bool cambiar_cclist = (wclist == cclist);
    list* objeto_list = getNodeVal(wclist);
    doinlist(objeto_list,delnodeparaquefuncionecondoinlist,NULL);   // Borra toda la lista de objetos
    delnode(&wclist);                                               // Borra el nodo actual
    if (cambiar_cclist)
        cclist = wclist;
}

int getNodeId(node _node)
{
    return **((int**)getNodeVal(_node));                            // Atajo rapido para sacar el id de un nodo objeto
}

void doinlist(list* lista, void (*func)(node*, any), any arg)
{
    node _node = *lista;
    for (int i = getLongitud(*lista); i > 0; i--)
    {
        node sig_node = next(_node);
        func(&_node, arg);
        _node = sig_node;
    }
}

void delnodeById(node* _node, any val)
{
    int find_id = *((int*)val);
    int node_id = getNodeId(*_node);
    if(find_id == node_id)
        delnode(_node);
}

void updateNodeId(node* _node, any val)
{
    int find_id = *((int*)val);
    **((int**)getNodeVal(*_node)) = find_id;
    *((int*)val) = find_id+1; 
}

string getString()
{
    string str = malloc(100);
    strncpy(str, buffer, 99);
    str[100] = '\0';
    return str;
}

void newobjeto()
{
    list* objeto_list = getNodeVal(wclist);
    int *objeto_id;
    objeto_id = malloc(sizeof(int));
    *objeto_id = getLongitud(*objeto_list) + 1;
    newnode(objeto_list, objeto_id);
}

void delobjeto(int id)
{
    list* objeto_list = getNodeVal(wclist);
    if(id==1)
        delnode(objeto_list);
    else
        doinlist(objeto_list,delnodeById,&id);
    id = 1;
    doinlist(objeto_list,updateNodeId,&id);
}

void mostrarobjetos()
{
    list* objeto_list = getNodeVal(wclist);
    doinlist(objeto_list, printNodeString, cclist);
    pause();
}

void printNodeString(node* _node,any val)
{
    string str = getNodeString(*_node);
    if(*_node == val)
        putchar('*');
    puts(str);
}

int main()
{
    clrscr();
    int opcion = 0;
    while (1)
    {
        // debug
        //printf("%p %p %p\n",prev(wclist),wclist,next(wclist));
        //printf("Direccion del string: %p\n",getNodeString(wclist));
        string str = getNodeString(wclist);
        if (str)
            printf("%s%s\n", wclist_mensaje, str);
        else
            printf("No hay categorias\n");
        printf("%s", menu_mensaje);
        scanf("%d", &opcion);
        if (opcion <= 0 || opcion >= 10)
        {
            puts(no_se_vale);
            pause();
            clrscr();
            continue;
        }
        if (opcion == 9)
            break;

        if(wclist==NULL && (opcion!=1))
        {
            puts(sin_catego);
            pause();
            clrscr();
            continue;
        }

        switch (opcion)
        {
        case 1:
            printf("%s", ingrese_palabra);
            scanf(" %s", buffer);
            newcatego();
            break;
        case 2:
            wclist = prev(wclist);
            break;
        case 3:
            wclist = next(wclist);
            break;
        case 4:
            mostrarcategos();
            break;
        case 5:
            delcatego();
            break;
        case 6:
            printf("%s", ingrese_palabra);
            scanf(" %s", buffer);
            newobjeto();
            break;
        case 7:
            printf("%s", ingrese_numero);
            scanf(" %d", &opcion);
            getchar();
            delobjeto(opcion);
            break;
        case 8:
            mostrarobjetos();
        default:
            break;
        }
        clrscr();
    }
    clrscr();
    return 0;
}