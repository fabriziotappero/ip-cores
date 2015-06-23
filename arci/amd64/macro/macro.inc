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

%macro call_return_redirect 2
lea rax,[rel %2]
push rax
jmp %1
%endmacro

%macro code_local 1
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

%macro mcall 1+
%if %0>6
mov [rsp+0x28],%7
%endif
%if %0>5
mov [rsp+0x20],%6
%endif
%if %0>4
mov r9,%5
%endif
%if %0>3
mov r8%4
%endif
%if %0>2
mov rdx,%3
%endif
%if %0>1
mov rcx,%2
%endif
call %1
%endmacro

%macro shortmov 2
push %2
pop %1
%endmacro

%macro msyscall 1+
%if %0>6
mov r9,%7
%endif
%if %0>5
mov r8,%6
%endif
%if %0>4
mov r10,%5
%endif
%if %0>3
mov rdx,%4
%endif
%if %0>2
mov rsi,%3
%endif
%if %0>1
mov rdi,%2
%endif
;shortmov rax,%1
push %1
pop rax

syscall
%endmacro

%macro msyscallc 1+ ; C code
%if %0>6
mov r9,%7
%endif
%if %0>5
mov r8,%6
%endif
%if %0>4
mov rcx,%5
%endif
%if %0>3
mov rdx,%4
%endif
%if %0>2
mov rsi,%3
%endif
%if %0>1
mov rdi,%2
%endif
;shortmov rax,%1
push %1
pop rax

syscall
%endmacro

%macro zeroextend8 1
db %1
align 0x08 db 0
%endmacro

%macro definedcall 1
%ifndef using_%1
%define using_%1
%endif
call _%1
%endmacro

%macro using 1 ;requires 2x %endif
%ifdef using_%1
%ifndef used_%1 
%define used_%1
%endmacro

%macro endusing 0 ;yasm bug
%endif
%endif
%endmacro

%endif ;macro include end