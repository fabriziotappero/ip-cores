
main()

{
	report_start();

	base_test();
	can_oc_test(0xfffc0000);

	report_end();
}
