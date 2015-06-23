/**
 * \brief Common header file for SCARTS driver implementation.
 */

#ifndef __drivers_h__
#define __drivers_h__

#include <inttypes.h>

#if defined __SCARTS16__
  #define scarts_addr_t  uint16_t
#elif defined __SCARTS32__
  #define scarts_addr_t  uint32_t
#else
  #error "Unsupported target machine type"
#endif

/**
 * \struct module_handle_t
 * \brief Stores context for access of a specific extension module.
 */
typedef struct {
  scarts_addr_t baseAddress;
} module_handle_t;


#define MODULE_STATUS_BOFF          0
#define MODULE_STATUS_LOOR          0x7
#define MODULE_STATUS_FSS           0x4
#define MODULE_STATUS_BUSY          0x3
#define MODULE_STATUS_ERR           0x2
#define MODULE_STATUS_RDY           0x1
#define MODULE_STATUS_INT           0x0

#define MODULE_CONFIG_BOFF          2
#define MODULE_CONFIG_LOOW          0x7
#define MODULE_CONFIG_EFSS          0x4
#define MODULE_CONFIG_OUTD          0x3
#define MODULE_CONFIG_SRES          0x2
#define MODULE_CONFIG_ID            0x1
#define MODULE_CONFIG_INTA          0x0


#endif // __drivers_h__
