#ifndef __ARM_ASM_H__
#define __ARM_ASM_H__

#define BEGIN_PROC(name)			\
    .global name; 				\
    .type   name,function;			\
    .align;					\
name:

#define END_PROC(name)				\
.fend_##name:					\
    .size   name,.fend_##name - name;

#endif /* __ARM_ASM_H__ */

