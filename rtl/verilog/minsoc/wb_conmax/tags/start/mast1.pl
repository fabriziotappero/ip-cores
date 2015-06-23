#!/bin/perl


for($n=16;$n<16;$n++) {

printf("	// Slave %0d Interface\n", $n );
printf("	s%0d_data_i, s%0d_data_o, s%0d_addr_o, s%0d_sel_o, s%0d_we_o, s%0d_cyc_o,\n", $n, $n, $n, $n, $n, $n );
printf("	s%0d_stb_o, s%0d_ack_i, s%0d_err_i, s%0d_rty_i,\n\n", $n, $n, $n, $n );

   }

for($n=0;$n<8;$n++) {

printf("// Master %0d Interface\n", $n);
printf("input	[dw-1:0]	m%0d_data_i;\n", $n);
printf("output	[dw-1:0]	m%0d_data_o;\n", $n);
printf("input	[aw-1:0]	m%0d_addr_i;\n", $n);
printf("input	[sw-1:0]	m%0d_sel_i;\n", $n);
printf("input			m%0d_we_i;\n", $n);
printf("input			m%0d_cyc_i;\n", $n);
printf("input			m%0d_stb_i;\n", $n);
printf("output			m%0d_ack_o;\n", $n);
printf("output			m%0d_err_o;\n", $n);
printf("output			m%0d_rty_o;\n\n", $n);

   }

for($n=0;$n<16;$n++) {

printf("// Slave %0d Interface\n", $n);
printf("input	[dw-1:0]	s%0d_data_i;\n", $n);
printf("output	[dw-1:0]	s%0d_data_o;\n", $n);
printf("output	[aw-1:0]	s%0d_addr_o;\n", $n);
printf("output	[sw-1:0]	s%0d_sel_o;\n", $n);
printf("output			s%0d_we_o;\n", $n);
printf("output			s%0d_cyc_o;\n", $n);
printf("output			s%0d_stb_o;\n", $n);
printf("input			s%0d_ack_i;\n", $n);
printf("input			s%0d_err_i;\n", $n);
printf("input			s%0d_rty_i;\n\n", $n);


   }


for($n=8;$n<8;$n++) {

printf("	// Master %0d Interface\n", $n );
printf("	m%0d_data_i, m%0d_data_o, m%0d_addr_i, m%0d_sel_i, m%0d_we_i, m%0d_cyc_i,\n", $n, $n, $n, $n, $n, $n );
printf("	m%0d_stb_i, m%0d_ack_o, m%0d_err_o, m%0d_rty_o,\n\n", $n, $n, $n, $n );

   }

