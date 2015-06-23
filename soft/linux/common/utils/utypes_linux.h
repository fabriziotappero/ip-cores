
#ifndef _UTYPES_LINUX_H_
#define _UTYPES_LINUX_H_

#if defined (__LINUX__) || defined(__linux__)

#include <stdint.h>
#include <limits.h>

typedef uint8_t   u8,   UINT08, U08, *PU08, BYTE, U8;
typedef uint16_t  u16,  UINT16, U16, *PU16, WORD;
typedef uint32_t  u32,  UINT32, U32, *PU32;
typedef uint64_t  u64,  UINT64, U64, *PU64;
typedef int8_t    s8,   SINT08, S08, *PS08;
typedef int16_t   s16,  SINT16, S16, *PS16;
typedef int32_t   s32,  SINT32, S32, *PS32;
typedef int64_t   s64,  SINT64, S64, *PS64, __int64;

//typedef int32_t     LONG;
typedef long        LONG;
typedef int64_t     __int64;

typedef float		REAL32, *PREAL32;
typedef double		REAL64, *PREAL64;

#if !defined(TRUE) && !defined(FALSE)
typedef enum { FALSE=0, TRUE=1 } BOOL;
#endif

typedef uint8_t   UCHAR, *PUCHAR;
typedef uint16_t  USHORT, *PUSHORT;
typedef uint32_t  ULONG, *PULONG, *PUINT, UINT;
typedef int       HANDLE;
typedef void*     HINSTANCE;
typedef void*     PVOID;
typedef void      VOID;
typedef uint32_t  DWORD;
typedef int64_t  __int64;

typedef int 		SOCKET;
typedef char   		TCHAR;
typedef char*  		PTCHAR;
typedef char*  		LPTSTR;

// added for 64-bit windows driver compatibility
typedef char                    BRDCHAR;
#define _BRDC(x)                x
#define BRDC_strlen             strlen
#define BRDC_strcpy             strcpy
#define BRDC_strncpy            strncpy
#define BRDC_strcmp             strcmp
#define BRDC_stricmp            _stricmp
#define BRDC_strnicmp           _strnicmp
#define BRDC_strcat             strcat
#define BRDC_strchr             strchr
#define BRDC_strstr             strstr
#define BRDC_strtol             strtol
#define BRDC_strtod             strtod
#define BRDC_atol               atol
#define BRDC_atoi               atoi
#define BRDC_atoi64             atoll
#define BRDC_atof               atof
#define BRDC_printf             printf
#define BRDC_fprintf            fprintf
#define BRDC_sprintf            sprintf
#define BRDC_vsprintf           vsprintf
#define BRDC_sscanf             sscanf
#define BRDC_fopen              fopen
#define BRDC_sopen              sopen
#define BRDC_fgets              fgets
#define BRDC_getenv             getenv
#define BRDC_main               main
#define BRDC_fputs              fputs

//-------------------------------------

#define lstrcpy strcpy
#define lstrcpyA strcpy
#define lstrcat strcat
#define lstrcatA strcat
#define lstrlen strlen
#define lstrlenA strlen
#define lstrcmpi strcasecmp
#define _tcsstr strstr
#define _tcscpy_s strcpy
#define _tcscpy strcpy
#define _tcschr strchr
#define sprintf_s sprintf
#define _tcscat_s strcat
#define _tcslen strlen
#define _tcscpy strcpy

#define _T(x)       x
#define _TEXT(x)    x
#define INFINITE    (-1)

#define _stricmp strcmp
#define stricmp strcmp
#define _strnicmp strncmp

typedef const char*	LPCTSTR;
typedef char*		PCTSTR;
typedef char*		PTSTR;
typedef void*		LPVOID;
typedef int             LPOVERLAPPED;

#ifndef MAX_PATH
#define MAX_PATH PATH_MAX
#endif

#endif /* __linux__ */

#endif /* _UTYPES_LINUX_H_ */

/*
*  End of File
*/
