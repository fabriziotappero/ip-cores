#define BIOS_PRINTF_HALT     1
#define BIOS_PRINTF_SCREEN   2
#define BIOS_PRINTF_INFO     4
#define BIOS_PRINTF_DEBUG    8
#define BIOS_PRINTF_ALL      (BIOS_PRINTF_SCREEN | BIOS_PRINTF_INFO)
#define BIOS_PRINTF_DEBHALT  (BIOS_PRINTF_SCREEN | BIOS_PRINTF_INFO | BIOS_PRINTF_HALT)

#define printf(format, p...)  bios_printf(BIOS_PRINTF_SCREEN, format, ##p)
#define BX_INFO(format, p...)   bios_printf(BIOS_PRINTF_INFO, format, ##p)
#define BX_PANIC(format, p...)  bios_printf(BIOS_PRINTF_DEBHALT, format, ##p)
