/*
 * stdarg.h -- variable argument lists
 */


#ifndef _STDARG_H_
#define _STDARG_H_


typedef char *va_list;


static float __va_arg_tmp;


#define va_start(list, start) \
	((void)((list) = (sizeof(start)<4 ? \
	(char *)((int *)&(start)+1) : (char *)(&(start)+1))))

#define __va_arg(list, mode, n) \
	(__typecode(mode)==1 && sizeof(mode)==4 ? \
	(__va_arg_tmp = *(double *)(&(list += \
	((sizeof(double)+n)&~n))[-(int)((sizeof(double)+n)&~n)]), \
	*(mode *)&__va_arg_tmp) : \
	*(mode *)(&(list += \
	((sizeof(mode)+n)&~n))[-(int)((sizeof(mode)+n)&~n)]))

#define _bigendian_va_arg(list, mode, n) \
	(sizeof(mode)==1 ? *(mode *)(&(list += 4)[-1]) : \
	sizeof(mode)==2 ? *(mode *)(&(list += 4)[-2]) : \
	__va_arg(list, mode, n))

#define va_end(list) ((void)0)

#define va_arg(list, mode) \
	(sizeof(mode)==8 ? \
	*(mode *)(&(list = (char*)(((int)list + 15)&~7U))[-8]) : \
	_bigendian_va_arg(list, mode, 3U))


#endif /* _STDARG_H_ */
