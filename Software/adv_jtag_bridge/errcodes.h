#ifndef _ERRCODES_H_
#define _ERRCODES_H_

// Errors in high-level chain transactions
// An error is a 32-bit bit-encoded value
#define APP_ERR_NONE          0x0
#define APP_ERR_COMM          0x1
#define APP_ERR_MALLOC        0x2
#define APP_ERR_MAX_RETRY     0x4
#define APP_ERR_CRC           0x08
#define APP_ERR_MAX_BUS_ERR   0x10
#define APP_ERR_CABLE_INVALID 0x20
#define APP_ERR_INIT_FAILED   0x40
#define APP_ERR_BAD_PARAM     0x080
#define APP_ERR_CONNECT       0x100
#define APP_ERR_USB           0x200
#define APP_ERR_CABLENOTFOUND 0x400
#define APP_ERR_TEST_FAIL     0x0800

char *get_err_string(int errval);

#endif
