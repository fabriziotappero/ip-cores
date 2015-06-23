
for($n=0;$n<8;$n++) {
for($m=0;$m<16;$m++) {

printf("wire	[dw-1:0]	m%0ds%0d_data_i;\n",$n,$m);
printf("wire	[dw-1:0]	m%0ds%0d_data_o;\n",$n,$m);
printf("wire	[aw-1:0]	m%0ds%0d_addr;\n",$n,$m);
printf("wire	[sw-1:0]	m%0ds%0d_sel;\n",$n,$m);
printf("wire			m%0ds%0d_we;\n",$n,$m);
printf("wire			m%0ds%0d_cyc;\n",$n,$m);
printf("wire			m%0ds%0d_stb;\n",$n,$m);
printf("wire			m%0ds%0d_ack;\n",$n,$m);
printf("wire			m%0ds%0d_err;\n",$n,$m);
printf("wire			m%0ds%0d_rty;\n",$n,$m);

}

}
