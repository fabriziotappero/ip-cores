
main()

{
	report_start();

	base_test();
	gpio_test(0x80000800);

	report_end();
}
