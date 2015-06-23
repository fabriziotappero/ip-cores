
main()

{
	report_start();

	leon3_test(1, 0x80000200, 0);
	irqtest(0x80000200);
	apbuart_test(0x80000100);
	apbuart_test(0x80000900);
	gptimer_test(0x80000300, 6);

	report_end();
}
