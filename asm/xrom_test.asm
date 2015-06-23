    ajmp start;

check:
    subb a, #04;
    jnz error1;
    mov a, b;
    jnz error2;
    ret;

error1:
    mov p1, #01;
    ajmp error1;

error2:
    mov p1, #02;
    ajmp error2;

    .org 020eh
start:
    mov p0, #090h;
    mov a, #20;
    mov b, #05;
    div ab;
    lcall check;
    mov p0, #00h;
    ljmp test1;

    .org 500dh;
test1:
    mov a, #00;
    mov b, #00;
    mov r0, a;
    mov r1, #30h
    mov dptr, #data;
loop1:
    mov a, r0;
    movc a, @a+dptr;
    mov @r1, a;
    inc r0;
    inc r1;
    mov a, r0;
    subb a, #25;
    jnz loop1;
    
    mov p0, #01h;

    mov r0, #00h;
    mov r1, #30h;
    mov b, #05;
    
loop2:
    clr c;
    mov a, @r1;
    subb a, b;
    jnz error3;
    inc b;
    inc r1;
    inc r0;
    mov a, r0;
    subb a, #25;
    jnz loop2;
    
    mov p0, #002h;
    ljmp _end;


error3:
    mov p1, #03;
    ajmp error3;

    .org 800fh;
_end:
    mov p0, #0eeh;
    ajmp _end;

    .org 9000h;
data:
    .db 5;
    .db 6;
    .db 7;
    .db 8;
    .db 9;
    .db 10;
    .db 11;
    .db 12;
    .db 13;
    .db 14;
    .db 15;
    .db 16;
    .db 17;
    .db 18;
    .db 19;
    .db 20;
    .db 21;
    .db 22;
    .db 23;
    .db 24;
    .db 25;
    .db 26;
    .db 27;
    .db 28;
    .db 29;
    .db 30;
    .db 31;
    
