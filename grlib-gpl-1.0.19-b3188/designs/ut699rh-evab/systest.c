
main()

{
	report_start();

	leon3_test(1, 0x80000200, 0);
	irqtest(0x80000200);
	apbuart_test(0x80000100);
	gptimer_test(0x80000300, 6);
//	mctrl_test(0x80000000, 0x80000f00, 1);
	pci_test(0x80000400, 0xfff1000, 0xc0000000);
	greth_test(0x80000e00);
	can_oc_test(0xfff20000);
	can_oc_test(0xfff20100);
//	spw_test(0x80000A00);
//	spw_test(0x80000B00);
//	spw_test(0x80000C00);
//	spw_test(0x80000D00);

	report_end();
}
