
main()

{
	report_start();
        
        base_test();

        greth_test(0x80000e00);

	/* grusbhc_test(0x80000d00, 0xfffa0000, 0, 0); */

        report_end();
}
