/* mcapi_config.h.  Generated from mcapi_config.h.in by configure.  */
/* mcapi_config.h.in.  Generated from configure.ac by autoheader.  */

/**
 * This version is edited by hand!
 *
 * The following values are modified:
 *  name              | new value | old value |
 * --------------------------------------------
 * MAX_ATTRIBUTES     |     8     |     32    |
 * MAX_BUFFERS        |    64     |   1024    |
 * MAX_CHANNELS       |     8     |     32    |
 * MAX_ENDPOINTS      |     8     |     32    |
 * MAX_NODES          |     8     |     32    |
 * MAX_QUEUE_ELEMENTS |    32     |     64    |
 *
 * And *why* they were edited? The mcapi_database structure
 * took a whopping 1290628 bytes from data memory!
 * Currently it is "only" 37732 bytes.
 */

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to the sub-directory in which libtool stores uninstalled libraries.
   */
#define LT_OBJDIR ".libs/"

/* Defined and set to $max_attributes. */
#define MAX_ATTRIBUTES 8

/* Defined and set to $max_buffers. */
#define MAX_BUFFERS 64

/* Defined and set to $max_channels. */
#define MAX_CHANNELS 8

/* Defined and set to $max_endpoints. */
#define MAX_ENDPOINTS 8

/* Defined and set to $max_msg_size. */
#define MAX_MSG_SIZE 1024

/* Defined and set to $max_nodes. */
#define MAX_NODES 8

/* Defined and set to $max_pkt_size. */
#define MAX_PKT_SIZE 32

/* Defined and set to $max_queue_elements. */
#define MAX_QUEUE_ELEMENTS 32

/* Name of package */
#define PACKAGE "mcapi"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT ""

/* Define to the full name of this package. */
#define PACKAGE_NAME "mcapi"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "mcapi 0.0.1"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "mcapi"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "0.0.1"

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Version number of package */
#define VERSION "0.0.1"

/* Defined and set to 1 if we're including debug print support. */
#define WITH_DEBUG 0

/* Define for Solaris 2.5.1 so the uint32_t typedef from <sys/synch.h>,
   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
   #define below would cause a syntax error. */
/* #undef _UINT32_T */

/* Define for Solaris 2.5.1 so the uint64_t typedef from <sys/synch.h>,
   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
   #define below would cause a syntax error. */
/* #undef _UINT64_T */

/* Define for Solaris 2.5.1 so the uint8_t typedef from <sys/synch.h>,
   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
   #define below would cause a syntax error. */
/* #undef _UINT8_T */

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Define to `unsigned int' if <sys/types.h> does not define. */
/* #undef size_t */

/* Define to the type of an unsigned integer type of width exactly 16 bits if
   such a type exists and the standard includes do not define it. */
/* #undef uint16_t */

/* Define to the type of an unsigned integer type of width exactly 32 bits if
   such a type exists and the standard includes do not define it. */
/* #undef uint32_t */

/* Define to the type of an unsigned integer type of width exactly 64 bits if
   such a type exists and the standard includes do not define it. */
/* #undef uint64_t */

/* Define to the type of an unsigned integer type of width exactly 8 bits if
   such a type exists and the standard includes do not define it. */
/* #undef uint8_t */
