#ifndef __MM0_MACROS_H__
#define __MM0_MACROS_H__

#define __INC_ARCH(x)		<arch/__ARCH__/x>
#define __INC_SUBARCH(x)	<arch/__ARCH__/__SUBARCH__/x>
#define __INC_PLAT(x)		<platform/__PLATFORM__/x>
#define __INC_GLUE(x)		<glue/__ARCH__/x>

#endif /* __MM0_MACROS_H__ */
