%ifndef globalmacroincluded
%define globalmacroincluded

%macro hst 1
db 0x3e
%1
%endmacro

%macro hwnt 1
db 0x2e
%1
%endmacro

%macro code_local 1
section .text
%1
%endmacro

%macro datos_local 1
section .data
%1
%endmacro

%macro reserva_local 1
section .bss
%1
%endmacro

%macro codigi_local 1
section .text
%1
%endmacro

%macro codigi_global 1
section .text
%1
global %1
%endmacro

%macro code_global 1
section .text
%1
global %1
%endmacro

%macro code_global_ 1 ;skip text section declaration (just in case)
;section .text
%1
global %1
%endmacro

%macro bphere 0
%ifdef bpenable
db 0xcc
%endif
%endmacro

%macro shortmov 2
push %2
pop %1
%endmacro

%macro zeroextend8 1
db %1
align 0x08 db 0
%endmacro

%endif ;macro include end