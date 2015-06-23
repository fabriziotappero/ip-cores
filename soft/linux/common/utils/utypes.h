/***************************************************
*
* UTYPES.H - define usefull types.
*
* (C) Instrumental Systems Corp. Ekkore, Dec. 1997-2001
*
****************************************************/


#ifndef _UTYPES_H_
#define _UTYPES_H_

#include "utypes_linux.h"



/*************************************
*
*  Types for MSDOS
*/


#ifdef __MSDOS__

typedef	unsigned char	UINT08;
typedef	signed   char	SINT08;
typedef	unsigned short	UINT16;
typedef	signed   short	SINT16;
typedef	unsigned long	UINT32;
typedef	signed   long	SINT32;

typedef	unsigned char	U08, *PU08;
typedef	signed   char	S08, *PS08;
typedef	unsigned short	U16, *PU16;
typedef	signed   short	S16, *PS16;
typedef	unsigned long	U32, *PU32;
typedef	signed   long	S32, *PS32;

typedef float			REAL32, *PREAL32;
typedef double			REAL64, *PREAL64;

//typedef enum{ FALSE=0, TRUE=1}        BOOL;
typedef unsigned char   UCHAR;
typedef unsigned short  USHORT;
typedef unsigned long   ULONG;
typedef unsigned long   HANDLE;

#endif /* __MSDOS__ */


/*************************************
*
*  Types for Windows
*/


#ifdef _WIN32

typedef	unsigned char	UINT08;
typedef	signed   char	SINT08;
typedef	unsigned short	UINT16;
typedef	signed   short	SINT16;
typedef	unsigned int	UINT32;
typedef	signed   int	SINT32;

typedef	unsigned char	U08, *PU08;
typedef	signed   char	S08, *PS08;
typedef	unsigned short	U16, *PU16;
typedef	signed   short	S16, *PS16;
typedef	unsigned int	U32, *PU32;
typedef	signed   int	S32, *PS32;

#if _MSC_VER == 1200
#else
typedef	unsigned long long int	U64, *PU64;
typedef	signed   long long int	S64, *PS64;
#endif

typedef float			REAL32, *PREAL32;
typedef double			REAL64, *PREAL64;

#ifdef _WIN64
typedef wchar_t			BRDCHAR;
#define _BRDC(x)		L ## x
#define BRDC_strlen		wcslen
#define BRDC_strcpy		wcscpy
#define BRDC_strncpy	wcsncpy
#define BRDC_strcmp		wcscmp
#define BRDC_stricmp	_wcsicmp
#define BRDC_strnicmp	wcsnicmp
#define BRDC_strcat		wcscat
#define BRDC_strchr		wcschr
#define BRDC_strstr		wcsstr
#define BRDC_strtol		wcstol
#define BRDC_strtoul	wcstoul
#define BRDC_strtod		wcstod
#define BRDC_atol		_wtol
#define BRDC_atoi		_wtoi
#define BRDC_atoi64		_wtoi64
#define BRDC_atof		_wtof
#define BRDC_printf		wprintf
#define BRDC_fprintf	fwprintf
#define BRDC_sprintf	swprintf
#define BRDC_vsprintf	vswprintf
#define BRDC_sscanf		swscanf
#define BRDC_fopen		_wfopen
#define BRDC_sopen		_wsopen
#define BRDC_fgets		fgetws
#define BRDC_fputs		fputws
#define BRDC_getenv		_wgetenv
#define BRDC_main		wmain
#else
typedef char			BRDCHAR;
#define _BRDC(x)		x
#define BRDC_strlen		strlen
#define BRDC_strcpy		strcpy
#define BRDC_strncpy	strncpy
#define BRDC_strcmp		strcmp
#define BRDC_stricmp	_stricmp
#define BRDC_strnicmp	_strnicmp
#define BRDC_strcat		strcat
#define BRDC_strchr		strchr
#define BRDC_strstr		strstr
#define BRDC_strtol		strtol
#define BRDC_strtoul	strtoul
#define BRDC_strtod		strtod
#define BRDC_atol		atol
#define BRDC_atoi		atoi
#define BRDC_atoi64		_atoi64
#define BRDC_atof		atof
#define BRDC_printf		printf
#define BRDC_fprintf	fprintf
#define BRDC_sprintf	sprintf
#define BRDC_vsprintf	vsprintf
#define BRDC_sscanf		sscanf
#define BRDC_fopen		fopen
#define BRDC_sopen		sopen
#define BRDC_fgets		fgets
#define BRDC_fputs		fputs
#define BRDC_getenv		getenv
#define BRDC_main		main
#endif

#endif /* _WIN32 */


/*************************************
*
*  Types for TMS320C3x/C4x
*/


#if defined(_TMS320C30) || defined(_TMS320C40 )

/*
typedef	unsigned char	UINT08;
typedef	signed   char	SINT08;
typedef	unsigned short	UINT16;
typedef	signed   short	SINT16;
*/
typedef	unsigned int	UINT32;
typedef	signed   int	SINT32;

typedef	unsigned int	U32, *PU32;
typedef	signed   int	S32, *PS32;

typedef float			REAL32, *PREAL32;
typedef double			REAL64, *PREAL64;

typedef UINT32	ULONG;
typedef UINT32	USHORT;
typedef UINT32	UCHAR;

#endif /* _TMS320C30 || _TMS320C40 */


/*************************************
*
*  Types for TMS320C6x
*/


#ifdef _TMS320C6X

typedef	unsigned char	UINT08;
typedef	signed   char	SINT08;
typedef	unsigned short	UINT16;
typedef	signed   short	SINT16;
typedef	unsigned int	UINT32;
typedef	signed   int	SINT32;

typedef	unsigned char	U08, *PU08;
typedef	signed   char	S08, *PS08;
typedef	unsigned short	U16, *PU16;
typedef	signed   short	S16, *PS16;
typedef	unsigned int	U32, *PU32;
typedef	signed   int	S32, *PS32;

typedef	unsigned long long int	U64, *PU64;
typedef	signed   long long int	S64, *PS64;

typedef float			REAL32, *PREAL32;
typedef double			REAL64, *PREAL64;

typedef UINT32	ULONG;
typedef UINT16	USHORT;
typedef UINT08	UCHAR;

#endif /* _TMS320C6X */


/*************************************
*
*  Types for ADSP2106x
*/


#if defined(__ADSP21060__) || defined(__ADSP21061__) || defined(__ADSP21062__)|| defined(__ADSP21065L__)

typedef	unsigned int	UINT32;
typedef	signed   int	SINT32;

typedef	unsigned int	U32, *PU32;
typedef	signed   int	S32, *PS32;

typedef float	 REAL32, *PREAL32;
typedef double	 REAL64, *PREAL64;

typedef UINT32	ULONG;
typedef UINT32	USHORT;
typedef UINT32	UCHAR;

#endif /* __ADSP2106x__ */

/*************************************
*
*  Types for ADSP2116x
*/


#if defined(__ADSP21160__) || defined(__ADSP21161__)

typedef	unsigned int	UINT32;
typedef	signed   int	SINT32;

typedef	unsigned int	U32, *PU32;
typedef	signed   int	S32, *PS32;

typedef float	 REAL32, *PREAL32;
typedef double	 REAL64, *PREAL64;

typedef UINT32	ULONG;
typedef UINT32	USHORT;
typedef UINT32	UCHAR;

#endif /* __ADSP2116x__ */

/*************************************
*
*  Types for ADSP-TS101
*/


#if defined(__ADSPTS__)

typedef	unsigned int	UINT32;
typedef	signed   int	SINT32;

typedef	unsigned int	U32, *PU32;
typedef	signed   int	S32, *PS32;

typedef	unsigned long long int	U64, *PU64;
typedef	signed   long long int	S64, *PS64;

typedef float	 REAL32, *PREAL32;
typedef long double	 REAL64, *PREAL64;

typedef UINT32	ULONG;
typedef UINT32	USHORT;
typedef UINT32	UCHAR;

#endif /* __ADSPTS__ */

/*************************************
*
*  Types for MC24
*/

#if defined(__GNUC__) && !defined(__linux__)

typedef unsigned char   UINT08;
typedef signed   char   SINT08;
typedef unsigned short  UINT16;
typedef signed   short  SINT16;
typedef unsigned long   UINT32;
typedef signed   long   SINT32;

typedef unsigned char   U08, *PU08;
typedef signed   char   S08, *PS08;
typedef unsigned short  U16, *PU16;
typedef signed   short  S16, *PS16;
typedef unsigned long   U32, *PU32;
typedef signed   long   S32, *PS32;

typedef unsigned long long int	U64, *PU64;
typedef signed   long long int	S64, *PS64;

typedef float           REAL32, *PREAL32;
typedef double          REAL64, *PREAL64;

typedef unsigned char   UCHAR;
typedef unsigned short  USHORT;
typedef unsigned long   ULONG;
typedef unsigned long   HANDLE;

#endif /* __GNUC__ */

/*************************************
*
*  Type Aliasing
*/

typedef UINT32	Uns;

/*************************************************
*
* Entry Point types
*
*/
#if !defined(WIN32) && !defined(__WIN32__)
//#ifndef WIN32
#define FENTRY
#define STDCALL
#else
#include <windows.h>
#define DllImport	__declspec( dllimport )
#define DllExport	__declspec( dllexport )
#define FENTRY		DllExport
#define STDCALL		__stdcall
#define	huge
#endif  // WIN32


#endif /* _UTYPES_H_ */

/*
*  End of File
*/



