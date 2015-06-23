/*
--------------------------------------------------------------------------------

Module: proc_reg.v

Function: 
- Single processor register w/ multiple type & input options (synchronous).

Instantiates: 
- Nothing.

Notes:
- Init value for each latched bit.
- LIVE_MASK[i]=1 indicates live bit.
- LIVE_MASK[i]=0 indicates dead bit, reads zero.
- Optional resync (2x registering) of inputs.
- Optional edge detection (rising) of inputs.
- data_o is driven non-zero if there is an address match, regardless of
  state of rd_i.
- Use large OR gate to combine multiple registers in a set.

OUT_MODE:
- "ZERO" : zero out
- "THRU" : no latch, direct connect
- "LTCH" : write latch
- "READ" : no latch, output selected read data

READ_MODE:
- "THRU" : no latch, direct connect
- "CORD" : set on input one, clear on read
- "COW1" : set on input one, clear on write one
- "DFFE" : D type flip flop with enable
- "OUT"  : no latch, read selected out data

--------------------------------------------------------------------------------
*/


module proc_reg
	#(
	parameter	integer							DATA_W			= 8,		// data width (bits)
	parameter	integer							ADDR_W			= 4,		// address width (bits)
	parameter	[ADDR_W-1:0]					ADDRESS			= 0,		// address this register responds to
	parameter										OUT_MODE			= "READ",	// modes are: "ZERO", "THRU", "LTCH", "READ"
	parameter										READ_MODE		= "COW1",	// modes are: "THRU", "CORD", "COW1", "DFFE", "OUT"
	parameter	[DATA_W-1:0]					LIVE_MASK		= { DATA_W{ 1'b1 } },	// 1=live data bit, 0=dead (0)
	parameter										IN_RESYNC		= 0,		// 1=resync (double clock) input, 0=no resync
	parameter										IN_EDGE			= 0,		// 1=edge (rising) sensitive, 0=level sensitive
	parameter	[DATA_W-1:0]					RESET_VAL		= 0		// reset value of latched data
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// bus interface
	input			wire	[ADDR_W-1:0]			addr_i,						// address
	input			wire								wr_i,							// data write enable, active high
	input			wire								rd_i,							// data read enable, active high
	input			wire	[DATA_W-1:0]			data_i,						// write data
	output		wire	[DATA_W-1:0]			data_o,						// read data
	// register interface
	output		wire								reg_wr_o,					// reg write active, active high
	output		wire								reg_rd_o,					// reg read active, active high
	input			wire								reg_en_i,					// reg enable, active high ("DFF" mode only)
	input			wire	[DATA_W-1:0]			reg_data_i,					// reg data in
	output		wire	[DATA_W-1:0]			reg_data_o					// reg data out
	);


	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	wire												addr_match;
	genvar											i;
	wire					[DATA_W-1:0]			in_data, out_data, rd_data;


	/*
	================
	== code start ==
	================
	*/


	// check for address match
	assign addr_match = ( addr_i == ADDRESS[ADDR_W-1:0] );

	// decode read & write
	assign reg_rd_o = ( rd_i & addr_match );
	assign reg_wr_o = ( wr_i & addr_match );


	// generate output logic based on mode
	generate
		for ( i=0; i<DATA_W; i=i+1 ) begin : output_loop
			if ( LIVE_MASK[i] ) begin  // live bit
				case ( OUT_MODE )
					"ZERO" : begin
						assign out_data[i] = 1'b0;
					end
					"THRU" : begin
						assign out_data[i] = data_i[i];
					end
					"LTCH" : begin
						reg reg_bit;
						always @ ( posedge clk_i or posedge rst_i ) begin
							if ( rst_i ) begin
								reg_bit <= RESET_VAL[i];
							end else begin
								if ( reg_wr_o ) begin
									reg_bit <= data_i[i];
								end
							end
						end
						assign out_data[i] = reg_bit;
					end
					"READ" : begin
						assign out_data[i] = rd_data[i];
					end
					default : begin  // unknown mode!
						initial $display ( "OUT_MODE %s does not exist!", OUT_MODE );
					end
				endcase
			end else begin  // dead bit
				assign out_data[i] = 1'b0;
			end
		end
	endgenerate


	// generate optional input resync & edge detect logic
	generate
		for ( i=0; i<DATA_W; i=i+1 ) begin : input_processing_loop
			if ( LIVE_MASK[i] ) begin  // live bit
				wire in_2;
				if ( IN_RESYNC ) begin
					reg in_0, in_1;
					always @ ( posedge clk_i or posedge rst_i ) begin
						if ( rst_i ) begin
							in_0 <= 1'b0;
							in_1 <= 1'b0;
						end else begin
							in_0 <= reg_data_i[i];
							in_1 <= in_0;
						end
					end
					assign in_2 = in_1;
				end else begin
					assign in_2 = reg_data_i[i];
				end
				//
				if ( IN_EDGE ) begin
					reg in_3;
					always @ ( posedge clk_i or posedge rst_i ) begin
						if ( rst_i ) begin
							in_3 <= 1'b0;
						end else begin
							in_3 <= in_2;
						end
					end
					assign in_data[i] = ( in_2 & ~in_3 );
				end else begin
					assign in_data[i] = in_2;
				end
			end else begin  // dead bit
				assign in_data[i] = 1'b0;
			end  // endif
		end  // endfor
	endgenerate


	// generate read logic based on mode
	generate
		for ( i=0; i<DATA_W; i=i+1 ) begin : read_loop
			if ( LIVE_MASK[i] ) begin  // live bit
				case ( READ_MODE )
					"THRU" : begin
						assign rd_data[i] = in_data[i];
					end
					"CORD" : begin
						reg reg_bit;
						always @ ( posedge clk_i or posedge rst_i ) begin
							if ( rst_i ) begin
								reg_bit <= RESET_VAL[i];
							end else begin
								if ( reg_rd_o ) begin
									reg_bit <= 1'b0;
								end else begin
									reg_bit <= reg_bit | in_data[i];
								end
							end
						end
						assign rd_data[i] = reg_bit;
					end
					"COW1" : begin
						reg reg_bit;
						always @ ( posedge clk_i or posedge rst_i ) begin
							if ( rst_i ) begin
								reg_bit <= RESET_VAL[i];
							end else begin
								if ( reg_wr_o ) begin
									reg_bit <= reg_bit & ~data_i[i];
								end else begin
									reg_bit <= reg_bit | in_data[i];
								end
							end
						end
						assign rd_data[i] = reg_bit;
					end
					"DFFE" : begin
						reg reg_bit;
						always @ ( posedge clk_i or posedge rst_i ) begin
							if ( rst_i ) begin
								reg_bit <= RESET_VAL[i];
							end else if ( reg_en_i ) begin
								reg_bit <= in_data[i];
							end
						end
						assign rd_data[i] = reg_bit;
					end
					"OUT" : begin
						assign rd_data[i] = out_data[i];
					end
					default : begin  // unknown mode!
						initial $display ( "RD_MODE %s does not exist!", RD_MODE );
					end
				endcase
			end else begin  // dead bit
				assign rd_data[i] = 1'b0;
			end
		end
	endgenerate


	// drive outputs
	assign data_o = ( addr_match ) ? rd_data : 1'b0;
	assign reg_data_o = out_data;


endmodule
