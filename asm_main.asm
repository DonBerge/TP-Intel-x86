%include "asm_io.inc"

section .data
cclist: dd 1 0
wclist: dd 1 0
buffer: db 104

section .rodata
nullnode: dd 1 0

section .text
global newnode
global prev
global next
global delnode
global getLongitud
global getNodeString
global doinlist

extern malloc
extern free
extern getString

; ITERADORES
prev:
    mov eax, [esp+4]        ; eax = node
    
    cmp eax, 0
    je prev_end
    
    mov eax, [eax]          ; eax = *(node)

    prev_end:
    ret

next:
    mov eax, [esp+4]

    cmp eax, 0
    je next_end

    mov eax, [eax+12]
    
    next_end:
    ret
; NODOS
newnode:
    enter 0,0
    push ebp                ; Guardo el frame poiter
    mov ebp, esp

    push dword 16           ; 16 bytes son necesarios para el nodo, dword es necesario porque push guarda solo palabras dobles
    call malloc             ; malloc de C
    pop edx                 ; Saco 16 del stack

                            ; Meto un string en el nodo
    push eax                ; Salvo el valor del nodo
    call getString          ; Funcion definida en C, devuelve la dirección de un String
    mov ecx, eax            ; Muevo el valor de retorno a otro registro
    pop eax                 ; Recupero el nodo
    mov [eax+8], ecx        ; Asigno la dirección del string

                            ; Meto el valor adicional al nodo
    mov edx, [ebp+8]        ; Segundo argumento de newnode, parametro a guardar en la segunda double word
    mov [eax+4], edx        ; Guardo el valor en el nuevo nodo

    mov edx, [ebp+12]       ; edx = &primernodolist
    mov edx, [edx]          ; edx = *edx = primernodolist

    cmp edx, 0              ; if(firstnode == NULL)
    je newnode_empty        ;   sin nodos -> goto newnode_empty
    
    cmp [edx], edx          ; else if(firstnode == prev(firstnode))
    je newnode_unique       ;   un unico nodo -> goto newnode_unique

    jmp newnode_not_empty   ; else 2 o mas nodos -> goto newnode_not_empty

    newnode_empty:
    mov [eax], eax          ; prev(newnode) = newnode
    mov [eax+12], eax       ; next(newnode) = newnode
    mov edx, eax            ; primernodolist = newnode
    jmp newnode_end

    newnode_unique:         ; firstnode = primernodolist
    mov [eax], edx          ; prev(newnode) = firstnode
    mov [eax+12], edx       ; next(newnode) = firstnode
    mov [edx], eax          ; prev(firstnode) = newnode
    mov [edx+12], eax       ; next(firstnode) = newnode
    jmp newnode_end

    newnode_not_empty:
    mov ecx, [edx]          ; ecx = prev(firstnode) = lastnode
    mov [ecx+12], eax       ; next(lasnode) = newnode
    mov [eax], ecx          ; prev(newnode) = lastnode
    mov [eax+12], edx       ; next(newnode) = firstnode
    mov [edx], eax          ; prev(fistnode) = lastnode
    jmp newnode_end

    newnode_end:
    mov ecx, [ebp+12]       ; Actualizo el valor de node en la memoria
    mov [ecx], edx

    pop ebp                 ; Recupero el frame pointer
    mov eax, edx
    leave
    ret

delnode:                    ; node = nodo a borrar
    mov eax, [esp+4]        ; &node
    mov eax, [eax]          ; *(&node) = node
    cmp eax, 0              ; delnode(null) no hace nada
    je delnode_end

    mov edx, [eax]          ; prev(node)
    mov ecx, [eax+12]       ; next(node)    

                            ; Libero el string del nodo
    pusha                   ; Salvo todos los registros
    mov eax, [eax+8]        ; Obtengo direccion del string
    push eax                ; Paso el parametro a la pila
    call free               ; free de C
    pop eax                 ; Libero el espacio del parametro
    popa                    ; Recupero los registros

    push edx                ; Hay guardar los registros edx, ecx 
    push ecx                
    push eax                ; eax contiene el nodo a borrar, se pasa el parametro por el stack
    call free
    pop eax
    pop ecx
    pop edx

    cmp eax, ecx            ; if(node == next(node))
    jne delnode_not_null    ;   hay 2 o mas nodos -> delnode_not_null

    delnode_unique:
    mov eax, 0
    jmp delnode_end

    delnode_not_null:
    mov [ecx], edx          ; prev(next(node) = prev(node)
    mov [edx+12], ecx       ; next(prev(node) = next(node)
    mov eax, ecx            ; node se remplaza por next(node)

    delnode_end:
    mov ecx, [esp+4]
    mov [ecx], eax
    ret

; UTILITY
getNodeString:
    mov eax, [esp+4]
    cmp eax, 0
    je getNodeString_end
    mov eax, [eax+8]
    getNodeString_end:
    ret
getNodeVal:
    mov eax, [esp+4]
    cmp eax, 0
    je getNodeVal_end
    mov eax, [eax+4]
    getNodeVal_end:
    ret

getLongitud:                  ; Toma una lista y devuelve su longitud
    mov edx, [esp+4]
    mov eax, edx
    mov ecx, 0
    
    cmp edx, 0
    jne getLongitud_loop
    mov eax, ecx
    ret

    getLongitud_loop:
    push edx
    push ecx
    push eax
    call next
    pop ecx
    pop ecx
    pop edx
    
    inc ecx
    cmp edx, eax
    jne getLongitud_loop
    mov eax, ecx
    ret

; LISTAS
doinlist:
    push ebp                ; Guardo el frame pointer
    mov ebp, esp            ; Remplazo el frame pointer por el stack pointer
    
    pusha                   ; Salvo todos los registros
    mov eax, [ebp+16]       ; Consigo el primer nodo
    
    push eax                ; Parametro para getLongitud
    call getLongitud        ; Consigo la longitud de la lista 
    mov ecx, eax            ; El program counter ahora es la longitud de la lista
    pop eax                 ; Saco el parametro del stack

    cmp ecx, 0              ; Si la longitud es cero, la lista esta vacia
    je doinlist_end         ; Salgo de la funcion

    doinlist_loop:          ; Loop que recorre toda la lista
    push ecx                ; Guardo el valor de ecx
    push eax                ; nodo

    mov eax, [ebp+8]        ; Consigo el valor extra
    push eax                ; Lo meto en el stack
    
    mov eax, [ebp+12]       ; Consigo la funcion
    
    call eax                ; LLamo a la funcion
    
    pop eax                 ; Saco el valor extra del stack, queda el nodo solo
    pop ecx                 ; Saco el nodo del stack y lo guardo en cualquier lado
    pop ecx                 ; Recupero el program counter

    mov eax, [eax+12]

    loop doinlist_loop      ; Vuelve al loop
    
    doinlist_end:
    popa                    ; Recupero todos los registros
    pop ebp                 ; Recupero el frame pointer
    ret