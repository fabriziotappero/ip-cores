module wb_7seg_new (clk_i, nrst_i, wb_adr_i, wb_dat_o, wb_dat_i, wb_sel_i, wb_we_i, 
	wb_stb_i, wb_cyc_i, wb_ack_o, wb_err_o, wb_int_o, DISP_SEL, DISP_LED);

	input clk_i;
	input nrst_i;
	input [24:1] wb_adr_i;
	output [15:0] wb_dat_o;
   	input [15:0] wb_dat_i;
	input [1:0] wb_sel_i;
   	input wb_we_i;
	input wb_stb_i;
	input wb_cyc_i;
	output wb_ack_o;
	output wb_err_o;
	output wb_int_o;
 	output reg [3:0] DISP_SEL;
	output reg [6:0] DISP_LED;

	reg [15:0]	data_reg;
	reg	[6:0]	disp_cnt;
	reg	[3:0]	disp_data;
	wire	[6:0]	disp_data_led;
	reg	[3:0]	disp_pos;

	always @(posedge clk_i or negedge nrst_i)
	begin
		if (nrst_i == 0)
			data_reg <= 16'hABCD;
		else 
			if (wb_stb_i && wb_we_i)
				data_reg <= wb_dat_i;
	end

	assign wb_ack_o = wb_stb_i;
	assign wb_err_o = 1'b0;
	assign wb_int_o = 1'b0;
	assign wb_dat_o = data_reg;

	always @(posedge clk_i or negedge nrst_i)
	begin
		if (nrst_i == 0)
			disp_cnt <= 7'b0000000;
		else 
			disp_cnt <= disp_cnt + 1;
	end

	always @(posedge clk_i or negedge nrst_i)
	begin
		if (nrst_i == 0)
			disp_pos <= 4'b0010;
		else 
			if (disp_cnt == 7'b1111111)
				disp_pos <= {DISP_SEL[2] , DISP_SEL[1] , DISP_SEL[0] , DISP_SEL[3]};
	end

	always @(posedge clk_i or negedge nrst_i)
	begin
		if (nrst_i == 0)
			disp_data <= 4'b0000;
		else 
			case (DISP_SEL)
				4'b1000: disp_data <= data_reg[3:0];
				4'b0100: disp_data <= data_reg[7:4];
				4'b0010: disp_data <= data_reg[11:8];
				4'b0001: disp_data <= data_reg[15:12];
			endcase
	end

	disp_dec u0 (disp_data, disp_data_led);

	always @(posedge clk_i or negedge nrst_i)
	begin
		if (nrst_i == 0)
			DISP_LED <= 7'b0000000;
		else 
			DISP_LED <= disp_data_led;
	end

	always @(posedge clk_i or negedge nrst_i)
	begin
		if (nrst_i == 0)
			DISP_SEL <= 0;
		else 
			DISP_SEL <= disp_pos;
	end

endmodule
