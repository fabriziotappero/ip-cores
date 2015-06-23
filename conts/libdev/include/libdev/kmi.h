
#ifndef __KMI_H__
#define __KMI_H__

/*
 * Current keyboard state
 */
struct keyboard_state{
	int keyup;
	int shift;
	int caps_lock;
};

/* Common functions */
void kmi_rx_irq_enable(unsigned long base);
int kmi_data_read(unsigned long base);

/* Keyboard specific calls */
char kmi_keyboard_read(unsigned long base, struct keyboard_state *state);
void kmi_keyboard_init(unsigned long base, unsigned int div);

/* Mouse specific calls */
void kmi_mouse_enable(unsigned long base);
void kmi_mouse_init(unsigned long base, unsigned int div);

#endif /* __KMI_H__ */
