#ifndef __exception_handler_h__
#define __exception_handler_h__

/* MIPS32 Exception Handlers */
void mips32_handler_AdEL(void);
void mips32_handler_AdES(void);
void mips32_handler_Bp(void);
void mips32_handler_CpU(void);
void mips32_handler_Ov(void);
void mips32_handler_RI(void);
void mips32_handler_Sys(void);
void mips32_handler_Tr(void);

/* MIPS32 Interrupt Handlers */
void mips32_handler_HwInt5(void);
void mips32_handler_HwInt4(void);
void mips32_handler_HwInt3(void);
void mips32_handler_HwInt2(void);
void mips32_handler_HwInt1(void);
void mips32_handler_HwInt0(void);
void mips32_handler_SwInt1(void);
void mips32_handler_SwInt0(void);

#endif

