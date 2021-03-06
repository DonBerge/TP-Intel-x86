#!/bin/bash

ASM_MAIN='asm_main'
C_MAIN='main'

# Limpia la pantalla
clear

#Genera el archivo objeto de asm_io
nasm -felf32 -d ELF_TYPE asm_io.asm

#Genera el archivo objeto de asm_main
nasm -felf32 -d ELF_TYPE "$ASM_MAIN.asm"

#Linkea con C y compila
gcc -std=c99 -m32 -Wno-all "$C_MAIN.c" "$ASM_MAIN.o" asm_io.o -o "$C_MAIN"

#Abre el ejecutable
#./$C_MAIN
