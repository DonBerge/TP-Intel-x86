%include "asm_io.inc"
; subrutina calc_sum

segment .text
        global  calc_sum

calc_sum:
        enter   4,0               ; espacio en stack para sum

        mov     dword [ebp-4],0   ; sum = 0
        dump_stack 1,2,4
        mov     ecx,1
for_loop:
        cmp     ecx,[ebp+8]
        jnle    end_for

        add     [ebp-4],ecx
        inc     ecx
        jmp     short for_loop

end_for:
        mov     eax,[ebp-4]
        leave
        ret
