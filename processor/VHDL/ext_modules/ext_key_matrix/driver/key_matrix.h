


#ifndef __EXT_KEY_MATRIX_H__
#define __EXT_KEY_MATRIX_H__

#define KEY_MATRIX_BADDR                  ((uint32_t)-352)

#define KEY_MATRIX_CONFIG_BOFF            2
#define KEY_MATRIX_CONFIG_BADDR           KEY_MATRIX_BADDR + KEY_MATRIX_CONFIG_BOFF
#define KEY_MATRIX_CONFIG                 (*(volatile uint8_t *const) (KEY_MATRIX_CONFIG_BADDR))
#define KEY_MATRIX_CONFIG_INTA            0x0

#define KEY_MATRIX_PRESSED_KEY_BOFF       4
#define KEY_MATRIX_PRESSED_KEY            (*(volatile uint8_t *const) (KEY_MATRIX_BADDR+KEY_MATRIX_PRESSED_KEY_BOFF))


#endif // __EXT_KEY_MATRIX_H__
