
#ifndef _LEGACY_DBG_COMMANDS_H_
#define _LEGACY_DBG_COMMANDS_H_

#define DC_SIZE           4
#define DC_STATUS_SIZE    4

#define DC_WISHBONE       0
#define DC_CPU0           1
#define DC_CPU1           2

#define DI_GO          0
#define DI_READ_CMD    1
#define DI_WRITE_CMD   2
#define DI_READ_CTRL   3
#define DI_WRITE_CTRL  4


// Interface to send commands to the legacy debug interface
int legacy_dbg_set_chain(int chain);
int legacy_dbg_command(int type, unsigned long adr, int len);
int legacy_dbg_ctrl(int reset, int stall);
int legacy_dbg_ctrl_read(int *reset, int *stall);
int legacy_dbg_go(unsigned char *data, unsigned short len, int read);

#endif
