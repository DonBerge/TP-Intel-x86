%include "asm_io.inc"
; mi primer programa
;
segment .data
  integer1      dd     15         ; entero 1
  integer2      dd     6          ; entero 2
segment .bss
  result        resd   1          ; resultado
segment .text
  global asm_main
asm_main:
                enter  0,0
                pusha
                mov    eax, [integer1]
                add    eax, [integer2]
                mov    [result],eax
                dump_regs 2
                call   print_int
                call   print_nl
                popa
                mov    eax,0
                leave
                ret
