
volatile int *grtestmod = (volatile int *) 0x20000000;

report_start()
{
	if (!get_pid()) grtestmod[4] = 1;
}

report_end()
{
	grtestmod[5] = 1;
}

report_device(int dev)
{
	grtestmod[0] = dev;
	return(0);
}

report_subtest(int dev)
{
	grtestmod[2] = dev;
}

fail(int dev)
{
	grtestmod[1] = dev;
}
