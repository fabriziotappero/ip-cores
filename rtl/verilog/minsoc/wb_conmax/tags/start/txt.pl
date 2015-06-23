#!/bin/perl


for($n=8;$n<8;$n++) {

printf("wb_mast	m%0d(	.clk(		clk		),\n", $n );
printf("		.rst(		~rst		),\n", $n );
printf("		.adr(		m%0d_addr_i	),\n", $n );
printf("		.din(		m%0d_data_o	),\n", $n );
printf("		.dout(		m%0d_data_i	),\n", $n );
printf("		.cyc(		m%0d_cyc_i	),\n", $n );
printf("		.stb(		m%0d_stb_i	),\n", $n );
printf("		.sel(		m%0d_sel_i	),\n", $n );
printf("		.we(		m%0d_we_i		),\n", $n );
printf("		.ack(		m%0d_ack_o	),\n", $n );
printf("		.err(		m%0d_err_o	),\n", $n );
printf("		.rty(		m%0d_rty_o	)\n", $n );
printf("		);\n\n", $n );

   }



for($n=0;$n<16;$n++) {

printf("wb_slv	s%0d(	.clk(		clk		),\n", $n );
printf("		.rst(		~rst		),\n", $n );
printf("		.adr(		s%0d_addr_o	),\n", $n );
printf("		.din(		s%0d_data_o	),\n", $n );
printf("		.dout(		s%0d_data_i	),\n", $n );
printf("		.cyc(		s%0d_cyc_o	),\n", $n );
printf("		.stb(		s%0d_stb_o	),\n", $n );
printf("		.sel(		s%0d_sel_o	),\n", $n );
printf("		.we(		s%0d_we_o		),\n", $n );
printf("		.ack(		s%0d_ack_i	),\n", $n );
printf("		.err(		s%0d_err_i	),\n", $n );
printf("		.rty(		s%0d_rty_i	)\n", $n );
printf("		);\n\n", $n );

   }

