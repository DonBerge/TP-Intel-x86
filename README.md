# TP-Intel-x86
Trabajo práctico de la materia Instalación y Remplazo de componentes internos del Instituto Politecnico Superior

El trabajo trata sobre la arquitectura **Intel x86**

## ¿Como compilar?
    nasm -felf32 main.asm
    ld -m elf_i386 -s -o main main.o

