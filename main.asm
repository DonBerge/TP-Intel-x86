%include "asm_io.inc"

section .rodata
nullnode: db 16

msg db 'Hello, world!',0xa
len equ $ - msg

formatString db "%s"
buffer db 100

section .text

global newnode
global next
global prev
global getNodeString
global delnode

extern malloc
extern getString
extern free

; NO MODIFICAR EBX

;   newnode(&primernodolist,val)
newnode:
    enter 0,0
    dump_regs 1
    push ebp                ; Guardo el frame poiter
    mov ebp, esp            ; frame pointer = stack pointer
    push ebx                ; ebx TIENE que mantener su valor al final del programa
    push dword 16           ; 16 bytes son necesarios para el nodo, dword es necesario porque push guarda solo palabras dobles
    call malloc             ; malloc de C
    pop ecx                 ; ecx contiene 16, asi sacamos el valor de la pila. eax debe contener el nuevo nodo

    dump_regs 2
    ; TODO: guardar string

    mov edx, [ebp+12]       ; edx = &primernodolist
    mov edx, [edx]          ; edx = *edx = primernodolist
    dump_regs 3
    cmp edx, 0
    jz newnode_empty
    

    newnode_empty:
    mov edx, eax            ; primernodolist = newnode
    mov [edx], eax          ; prev(newnode) = newnode
    mov [edx+12], eax            ; next(newnode) = newnode
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
    dump_regs 4
    pop ebx
    pop ebp
    mov eax, edx
    leave
    ret

; ITERADORES
prev:
    test edi, 0
    jz prev_is_null
    mov edi, [edi]
    prev_is_null:
    mov eax, edi
    ret

next:
    test edi, 0
    jz next_is_null
    mov edi, [edi+12]
    next_is_null:
    mov eax, edi
    ret

delnode:
    test edi, 0             ; delnode(NULL) no hace nada
    jnz delnode_not_null
    mov eax, edi
    ret

    delnode_not_null:
    mov ecx, [edi]          ; ecx = prev(node)
    mov edx, [edi+12]       ; edx = next(node)

    cmp ecx, edx            ; if(ecx == edx) hay solo un nodo
    je delnode_unique
    
    mov [ecx+12], edx       ; next(prev(node)) = next(node)
    mov [edx], ecx          ; prev(next(node)) = prev(node)
    
    push ecx
    push edx
    sub esp, 8

    call free
    
    add esp, 8
    pop edx
    pop ecx

    mov edi, edx
    mov eax, edx

    ret

    delnode_unique:
    sub esp, 8
    call free
    add esp, 8
    mov edi, 0
    mov eax, 0
    ret

; UTILITY
getNodeString:                 ; Primer argumento, nodo
    push edi
    mov edi, [edi+8]
    test edi, 0
    jnz getNodeString_not_null_str

    pop edi
    mov eax, 0
    ret

    getNodeString_not_null_str:
    mov eax, edi
    pop edi
    ret