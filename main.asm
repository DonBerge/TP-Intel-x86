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

newnode:
    ; Llamo a la funcion smalloc para obtener un nuevo nodo y guardo lo que sea necesario en el stack
    push edi
    push esi
    
    sub esp, 8

    mov edi, 16
    call malloc
    
    add esp, 8

    ;push eax
    ;call getString
    ;pop ecx
    ;mov [ecx+8], eax
    ;mov eax, ecx

    pop esi
    pop edi

    ; eax = newnode
    ; edi = lastnode
    ;mov [eax+4], esi

    ; if lastnode == null
    test edi, 0
    jz newnode_empty

    ; if prev(lastnode) == lastnode
    mov ecx, [edi]
    cmp edi, ecx
    je newnode_unique

    newnode_not_empty:      ; slist != NULL and slist != elist (hay 2 o mas elementos)
    mov ecx, [edi]          ; ecx = prev(lastnode)
    mov [edi], eax          ; prev(lastnode) = newnode
    mov [eax+12], edi       ; next(newnode) = lastnode
    mov [ecx+12], eax       ; next(prev(lastnode)) = newnode
    mov [eax], ecx          ; prev(newnode) = prev(lastnode)
    mov eax, edi
    ret

    newnode_unique:
    mov [edi], eax          ; prev(lastnode) = newnode
    mov [edi+12], eax       ; next(lastnode) = newnode
    mov [eax], edi          ; prev(newnode)  = lastnode
    mov [eax+12], edi       ; next(newnode)  = lastnode
    ret

    newnode_empty:
    mov [eax], eax          ; prev(newnode) = newnode
    mov [eax+12], eax       ; next(newnode) = newnode
    mov edi, eax
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