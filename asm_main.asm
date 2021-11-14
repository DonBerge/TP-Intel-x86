%include "asm_io.inc"

section .data
cclist: dd 1 0
wclist: dd 1 0
buffer: db 104

section .rodata
nullnode: dd 1 0

section .text
global asm_main
global newnode
global prev
global next
global delnode

extern malloc
extern free

asm_main:
    enter 0,0
    pusha

    dump_regs 1
    
    popa
    leave
    ret

newnode:
    enter 0,0
    push ebp                ; Guardo el frame poiter
    mov ebp, esp

    push dword 16           ; 16 bytes son necesarios para el nodo, dword es necesario porque push guarda solo palabras dobles
    call malloc             ; malloc de C
    pop edx                ; Saco 16 del stack

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

delnode:                    ; node = nodo a borrar
    mov eax, [esp+4]        ; &node
    mov eax, [eax]          ; *(&node) = node
    cmp eax, 0              ; delnode(null) no hace nada
    je delnode_end

    mov edx, [eax]          ; prev(node)
    mov ecx, [eax+12]       ; next(node)

    

    push edx
    push ecx
    push eax
    call free
    pop eax
    pop ecx
    pop edx

    cmp eax, ecx            ; if(node == next(node))
    je delnode_unique       ;   hay un solo nodo -> delnode_unique
    jmp delnode_not_null    ;   hay 2 o mas nodos -> delnode_not_null

    delnode_unique:
    mov eax, 0
    jmp delnode_end

    delnode_not_null:
    mov [ecx], edx          ; prev(next(node) = prev(node)
    mov [edx+12], ecx       ; next(prev(node) = next(node)
    mov eax, ecx            ; node se remplaza por next(node)
    jmp delnode_end

    delnode_end:
    mov ecx, [esp+4]
    mov [ecx], eax
    ret