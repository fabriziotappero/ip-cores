
.section .entry,"ax"
	.word _boot_uart // entry point(from boot_command of boot_flash)
	.byte 0xff

