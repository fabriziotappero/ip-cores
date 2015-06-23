#ifndef _BSDL_H_
#define _BSDL_H_

#include <stdint.h>

// Used by lower levels.
// should not be used by higher levels (i.e. anything that calls
// the API functions).
struct bsdlinfo_node {
  char *name;
  uint32_t idcode;
  uint32_t idcode_mask;
  int IR_size;
  uint32_t cmd_debug;
  uint32_t cmd_user1;
  uint32_t cmd_idcode;
  struct bsdlinfo_node *next;
};

typedef struct bsdlinfo_node bsdlinfo;


#define IDCODE_INVALID 0xFFFFFFFF
#define TAP_CMD_INVALID 0XFFFFFFFF


void bsdl_init(void);
void bsdl_add_directory(const char *dirname);

const char * bsdl_get_name(uint32_t idcode);
int bsdl_get_IR_size(uint32_t idcode);
uint32_t bsdl_get_debug_cmd(uint32_t idcode);
uint32_t bsdl_get_user1_cmd(uint32_t idcode);
uint32_t bsdl_get_idcode_cmd(uint32_t idcode);

#endif
