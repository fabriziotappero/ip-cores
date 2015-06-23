
main()

{
	report_start();

	base_test();

	greth_test(0x80000a00);

	i2cmst_test(0x80000800);

	spictrl_test(0x80000900);

	report_end();
}
