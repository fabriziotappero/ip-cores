/*
FIR filter with comples samples
convolution computation divided into blocks for parallel processing
then summ of results in blocks is computed

filter designed to evaluate convolution of echo-signal
it works in two modes:
1 - echo-signal with ping signal leaked into input assumed. FIR takes first n (loadable runtime) samples in frame into pulse response RAM and convolutes other samples in frame with first n
 n is ping signal length
 frame begins with inp_ping_start strobe
 
2 - pulse response RAM loaded through parallel interface (Data, Addres, WR, I/Q)

Number of cycles required to compute one sample is determined by formula
block_length + number_of_blocks + 11
it is constant for synthesized filter

block_length and number_of_blocks should be power of 2
for example
pulse response RAM depth is 2**11 = 2048
block size is 2**8 = 256
number of blocks is 2048/256 = 2**(11-8) = 8

block_length + number_of_blocks + 11 = 256 + 8 + 11 = 275

In any case filter yelds output samples after n = 2**PING_ADDR_WIDTH samples

*/
module FIR_cascaded
#(
	parameter	INP_SAMP_WIDTH = 14,				// imput samples width
	parameter	PING_ADDR_WIDTH = 11,				// address width of pulse response characteristic samples
	parameter	CONV_MEM_BLOCK_ADDR_WIDTH = 10,		// address width of block
	parameter	FRAME_ADDR_WIDTH = 18,				// address width of counter of samples in frame
	parameter	OUT_SAMP_WIDTH = 18,				// output samples width
	parameter	CLK_TO_SAMP_ADDR_WIDTH	= 11,		// clocks in frame counter width
	//for debug. out_samp_A_sq is I^2 + Q^2
	parameter	OUT_SAMP_A_SQ_WIDTH = 8,			// width of out_samp_A_sq
	parameter	OUT_SAMP_A_SQ_OFFS = 8				// downscale for out_samp_A_sq. OUT_SAMP_A_SQ_OFFS and next OUT_SAMP_A_SQ_WIDTH bits goes to the output
)
(
	// ping means first n=inp_ping_length samples, which can be loaded into ping RAM, where stores FIR coefficients or pulse response
	input	clk,			// clock
	input	reset,			// reset
	input	inp_clk,		// input samples strobes
	input	inp_ping_start, // frame strobes
	input signed	[INP_SAMP_WIDTH - 1:0]	inp_samp_I,			// input samples Re
	input signed	[INP_SAMP_WIDTH - 1:0]	inp_samp_Q,			// input samples Im
	input [PING_ADDR_WIDTH - 1:0] 			inp_ping_length,	// ping duration, in samples
	input									IOB_ping_from_Rx,	// 1 - take pulse response from input samles, 0 - do not take pulse response from input samples, assumes load coefficient through parallel interface
	input 									IOB_ping_RAM_CS,	// select coefficient RAM
	inout signed	[INP_SAMP_WIDTH - 1:0]	IOB_ping_RAM_D,		// coefficient RAM, data
	input 									IOB_ping_RAM_IQ,	// coefficient RAM, I/Q select. 0 - I, 1 - Q
	input signed	[PING_ADDR_WIDTH - 1:0]	IOB_ping_RAM_A,		// coefficient RAM, address
	input 									IOB_ping_RAM_WR,	// coefficient RAM, write enable
	input 									IOB_ping_RAM_RD,	// coefficient RAM, read enable
	output signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_I,			// output samples, Re
	output signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_Q,			// output samples, Im
	output signed	[OUT_SAMP_A_SQ_WIDTH - 1:0]	out_samp_A_sq,	// I^2 + Q^2, for debug
	output	out_samp_strobe,									// output sample strobe
	output	out_frame_strobe									// output frame strobe
);

	//wire signed	[INP_SAMP_WIDTH - 1:0]	IOB_ping_RAM_D;
	//wire signed	[PING_ADDR_WIDTH - 1:0]	IOB_ping_RAM_A;
	parameter CONV_BLOCK_ADDR_WIDTH = PING_ADDR_WIDTH - CONV_MEM_BLOCK_ADDR_WIDTH;	// address width for blocks counting
	reg	[2**CONV_BLOCK_ADDR_WIDTH - 1:0]	IOB_ping_RAM_A_bank_sel;	// one-hot block select for WR coefficients through parallel bus
	reg	[PING_ADDR_WIDTH - 1:0] inp_ping_length_reg;	// inp_ping_length store register
	reg	[FRAME_ADDR_WIDTH - 1:0] sample_counter;		// sample in frame counter
	reg	inp_ping_start_str;								// frame begins strobe
	reg	inp_ping_start_catch;							// for generating inp_ping_start_catch
	reg	inp_clk_str;									// sample begins strobe
	reg	inp_clk_catch;									// for generating inp_clk_str
	reg	ping_to_store;									// set to 1 from frame begining to the end of ping. While 1 and if should take input samples to coefficients, to store input samples into coefficient RAM
	reg	[2**CONV_BLOCK_ADDR_WIDTH:0]	ping_to_store_n;									// one-hot to select block in coefficients RAM to store sample
	reg	[CLK_TO_SAMP_ADDR_WIDTH - 1:0]	clk_to_samp_counter;								// clock between samples counter, used to calculation of output samples
	reg signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_I_reg;										// register to store output Re samples
	reg signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_Q_reg;										// register to store output Im samples
	reg signed	[OUT_SAMP_WIDTH - 1:0]	samp_mult_II[2**CONV_BLOCK_ADDR_WIDTH - 1:0];		// multipliers for output sample calculation, Re*Re
	reg signed	[OUT_SAMP_WIDTH - 1:0]	samp_mult_QQ[2**CONV_BLOCK_ADDR_WIDTH - 1:0];		// multipliers for output sample calculation, Im*Im
	reg signed	[OUT_SAMP_WIDTH - 1:0]	samp_mult_QI[2**CONV_BLOCK_ADDR_WIDTH - 1:0];		// multipliers for output sample calculation, Im*Re
	reg signed	[OUT_SAMP_WIDTH - 1:0]	samp_mult_IQ[2**CONV_BLOCK_ADDR_WIDTH - 1:0];		// multipliers for output sample calculation, Re*Im
	reg signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_acc_I[2**CONV_BLOCK_ADDR_WIDTH - 1:0];		// accumulators for calculation summ in block Re
	reg signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_acc_Q[2**CONV_BLOCK_ADDR_WIDTH - 1:0];		// accumulators for calculation summ in block Im
	wire signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_acc_Q_selected;							// accumulators for calculation summ in block Im
	//reg signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_acc_result_I[2**CONV_BLOCK_ADDR_WIDTH - 1:0];	// регистр хранения результата вычисления отсчёта свёртки канала I
	//reg signed	[OUT_SAMP_WIDTH - 1:0]	out_samp_acc_result_Q[2**CONV_BLOCK_ADDR_WIDTH - 1:0];	// регистр хранения результата вычисления отсчёта свёртки канала Q
	reg signed	[OUT_SAMP_WIDTH - 1:0]	blocks_acc_I;										// summ of summs in blocks accumulator, Re
	reg signed	[OUT_SAMP_WIDTH - 1:0]	blocks_acc_Q;										// summ of summs in blocks accumulator, Re
	reg signed	[OUT_SAMP_WIDTH*2  :0]	out_samp_A_sq_reg;									// Re^2 + Im^2 register, for debug
	reg	[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0]	addr_ping;										// coefficient address register for convolution calculation
	reg	[CLK_TO_SAMP_ADDR_WIDTH:0]			addr_echo;										// TODO: width CONV_BLOCK_ADDR_WIDTH + CONV_MEM_BLOCK_ADDR_WIDTH
	reg	proc_store_samp;							// sets for saving samples
	reg	proc_count_blocks;							// sets when reading data from coefficient RAM and samples RAM
	reg	proc_count_blocks_acc;						// sets for summs in blocks calculating
	reg	proc_count_blocks_sum;						// sets for summs of summs in block calculating
	reg	[CONV_BLOCK_ADDR_WIDTH - 1:0]	blocks_sum_counter;	// block number counter for summs of summs in block calculating

	reg signed [INP_SAMP_WIDTH - 1:0]	multiplier_ping_I[2**CONV_BLOCK_ADDR_WIDTH - 1:0];	// Re coefficient register for multiplication
	reg signed [INP_SAMP_WIDTH - 1:0]	multiplier_ping_Q[2**CONV_BLOCK_ADDR_WIDTH - 1:0];	// Im coefficient register for multiplication
	reg signed [INP_SAMP_WIDTH - 1:0]	multiplier_echo_I[2**CONV_BLOCK_ADDR_WIDTH - 1:0];	// Re sample register for multiplication
	reg signed [INP_SAMP_WIDTH - 1:0]	multiplier_echo_Q[2**CONV_BLOCK_ADDR_WIDTH - 1:0];	// Im sample register for multiplication

	// Buses of RAM for storing coefficients and data samples
	// address bus is shared, data and control buses are separated for Re and Im
	wire signed	[INP_SAMP_WIDTH - 1:0]			ping_RAM_D_I	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire signed	[INP_SAMP_WIDTH - 1:0]			ping_RAM_D_Q	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire	[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0]	ping_RAM_A		[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	//wire	[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0]	ping_RAM_A_buf;
	wire signed	[INP_SAMP_WIDTH - 1:0]			ping_RAM_Q_I	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire signed	[INP_SAMP_WIDTH - 1:0]			ping_RAM_Q_Q	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire										ping_RAM_W_I	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire										ping_RAM_W_Q	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire signed	[INP_SAMP_WIDTH - 1:0]			samp_RAM_D_I	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire signed	[INP_SAMP_WIDTH - 1:0]			samp_RAM_D_Q	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire	[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0]	samp_RAM_A		[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire signed	[INP_SAMP_WIDTH - 1:0]			samp_RAM_Q_I	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire signed	[INP_SAMP_WIDTH - 1:0]			samp_RAM_Q_Q	[2**CONV_BLOCK_ADDR_WIDTH - 1:0];
	wire										samp_RAM_W		[2**CONV_BLOCK_ADDR_WIDTH - 1:0];

	reg	out_samp_strobe_reg;	// register for generating out_samp_strobe
	reg	out_frame_strobe_reg;	// register for generating out_frame_strobe
	// RAM for coefficients - ping and for data - samp
	// number of blocks is 2**CONV_BLOCK_ADDR_WIDTH * 2 (ping, samp) * 2 (I, Q)
	generate
		genvar i_ram;
		for (i_ram = 0; i_ram < 2**CONV_BLOCK_ADDR_WIDTH; i_ram = i_ram + 1) begin : gen_ram
			single_port_ram
				#(
				.DATA_WIDTH	(INP_SAMP_WIDTH),
				.ADDR_WIDTH	(CONV_MEM_BLOCK_ADDR_WIDTH))
			ping_RAM_I
			(
				.clk	(~clk),
				.d_wr	(ping_RAM_D_I[i_ram]),
				.addr	(ping_RAM_A[i_ram]),
				.we		(ping_RAM_W_I[i_ram]),
				.d_rd	(ping_RAM_Q_I[i_ram])
			);
			single_port_ram
				#(
				.DATA_WIDTH	(INP_SAMP_WIDTH),
				.ADDR_WIDTH	(CONV_MEM_BLOCK_ADDR_WIDTH))
			ping_RAM_Q
			(
				.clk	(~clk),
				.d_wr	(ping_RAM_D_Q[i_ram]),
				.addr	(ping_RAM_A[i_ram]),
				.we		(ping_RAM_W_Q[i_ram]),
				.d_rd	(ping_RAM_Q_Q[i_ram])
			);
			single_port_ram
				#(
				.DATA_WIDTH	(INP_SAMP_WIDTH),
				.ADDR_WIDTH	(CONV_MEM_BLOCK_ADDR_WIDTH))
			samp_RAM_I
			(
				.clk	(~clk),
				.d_wr	(samp_RAM_D_I[i_ram]),
				.addr	(samp_RAM_A[i_ram]),
				.we		(samp_RAM_W[i_ram]),
				.d_rd	(samp_RAM_Q_I[i_ram])
			);
			single_port_ram
				#(
				.DATA_WIDTH	(INP_SAMP_WIDTH),
				.ADDR_WIDTH	(CONV_MEM_BLOCK_ADDR_WIDTH))
			samp_RAM_Q
			(
				.clk	(~clk),
				.d_wr	(samp_RAM_D_Q[i_ram]),
				.addr	(samp_RAM_A[i_ram]),
				.we		(samp_RAM_W[i_ram]),
				.d_rd	(samp_RAM_Q_Q[i_ram])
			);
		end // for
	endgenerate

	// strobes for frame start ang sample start
	always @ (negedge clk or posedge reset) begin
		if (reset) begin
			inp_ping_start_catch <= 0;
			inp_ping_start_str <= 0;
			inp_clk_catch <= 0;
			inp_clk_str <= 0;
		end else begin
			inp_ping_start_catch <= inp_ping_start;
			inp_ping_start_str <= inp_ping_start & ~inp_ping_start_catch;
			inp_clk_catch <= inp_clk;
			inp_clk_str <= inp_clk & ~inp_clk_catch;
		end
	end //always

	// one-hot for ping_RAM block selecting for access from parallel interface
	always @(IOB_ping_RAM_A) begin
		IOB_ping_RAM_A_bank_sel = {2**CONV_BLOCK_ADDR_WIDTH{1'b0}};
		IOB_ping_RAM_A_bank_sel[IOB_ping_RAM_A[CONV_MEM_BLOCK_ADDR_WIDTH + CONV_BLOCK_ADDR_WIDTH - 1 : CONV_MEM_BLOCK_ADDR_WIDTH]] = 1'b1;
	end //always

	// sample number "sample_counter", ping present signal "ping_to_store" and ping_RAM block number to store ping "ping_to_store_n"
	always @ (negedge clk)
	begin
		if (inp_ping_start_str) begin
			inp_ping_length_reg <= inp_ping_length;
			sample_counter <= 0;
			ping_to_store <= 1;
			ping_to_store_n = 1;
		end else begin
			if (inp_clk_str) begin
				sample_counter <= sample_counter + 1;
				if (sample_counter[PING_ADDR_WIDTH - 1:0] == inp_ping_length_reg) begin	// ping ends, stop storing samples to coefficients RAM
					ping_to_store <= 0;
				end
				if (sample_counter[CONV_MEM_BLOCK_ADDR_WIDTH - 1 : 0] == {CONV_MEM_BLOCK_ADDR_WIDTH{1'b1}}) begin	// addres goes to the next bank
					ping_to_store_n  = ping_to_store_n << 1;
				end
			end
		end
	end

	// clock counter, counts clocks in frame, used to convolution calculating
	always @ (negedge clk)
	begin
		clk_to_samp_counter <= inp_clk_str ? 0 : (clk_to_samp_counter + 1);
	end
	
	//	clk_to_samp_counter
	//	0										registers initialization
	//	1										store sample into RAM
	//	2										/summands calculation (II, IQ, QI, QQ)
	//	5										|	2**CONV_MEM_BLOCK_ADDR_WIDTH + 3 такта	/summs in blocks calculation
	//	2**CONV_MEM_BLOCK_ADDR_WIDTH + 5		\											|
	//	2**CONV_MEM_BLOCK_ADDR_WIDTH + 6		/ summs of summs in blocks calculation		\
	//  2**CONV_MEM_BLOCK_ADDR_WIDTH + 6		|
	//			+ 2**CONV_BLOCK_ADDR_WIDTH		\
	//	2**CONV_MEM_BLOCK_ADDR_WIDTH + 7		output result, sample strobe and frame strobe
	//			+ 2**CONV_BLOCK_ADDR_WIDTH
	always @ (negedge clk)
	begin
		if (inp_clk_str) begin
			proc_store_samp <= 0;
			proc_count_blocks <= 0;
			proc_count_blocks_acc <= 0;
			proc_count_blocks_sum <= 0;
		end else begin
			proc_store_samp = clk_to_samp_counter == 0;
			if (clk_to_samp_counter == 2) begin
				proc_count_blocks <= 1;		// begin to calculate convolution in blocks
			end else if (clk_to_samp_counter == 2**CONV_MEM_BLOCK_ADDR_WIDTH + 5) begin
				proc_count_blocks <= 0;		// finish
			end
			if (clk_to_samp_counter == 5) begin
				proc_count_blocks_acc <= 1;		// begin to calculate summs in blocks
			end else if (clk_to_samp_counter == 2**CONV_MEM_BLOCK_ADDR_WIDTH + 7) begin
				proc_count_blocks_acc <= 0;		// finish
			end
			if (clk_to_samp_counter == 2**CONV_MEM_BLOCK_ADDR_WIDTH + 6) begin
				proc_count_blocks_sum <= 1;	// begin to count summs of summs
			end else if (clk_to_samp_counter == 2**CONV_MEM_BLOCK_ADDR_WIDTH + 7 + 2**CONV_BLOCK_ADDR_WIDTH) begin	// continue for 2**CONV_BLOCK_ADDR_WIDTH times
				proc_count_blocks_sum <= 0;	// finish
			end
		end
	end

	assign out_samp_acc_Q_selected = out_samp_acc_Q[blocks_sum_counter];
	// coefficient address counter, sample address counter
	always @ (negedge clk or posedge proc_store_samp)
	begin
		if (proc_store_samp) begin
			addr_ping <= 0;
			addr_echo <= sample_counter - (2**PING_ADDR_WIDTH - 1);
		end else if (proc_count_blocks) begin
			addr_ping <= addr_ping + 1;
			addr_echo <= addr_echo + 1;
		end
	end

	// bidirectional bus for coefficient RAM
	assign	IOB_ping_RAM_D = (IOB_ping_RAM_RD & IOB_ping_RAM_CS) ? 	// Data bus, Z if read not selected
		(IOB_ping_RAM_IQ ?											// if read, then I or Q
				ping_RAM_D_Q[IOB_ping_RAM_A[CONV_MEM_BLOCK_ADDR_WIDTH + CONV_BLOCK_ADDR_WIDTH - 1 : CONV_MEM_BLOCK_ADDR_WIDTH]]
			 : ping_RAM_D_I[IOB_ping_RAM_A[CONV_MEM_BLOCK_ADDR_WIDTH + CONV_BLOCK_ADDR_WIDTH - 1 : CONV_MEM_BLOCK_ADDR_WIDTH]]
		) : {INP_SAMP_WIDTH{1'bZ}};
	wire	[2**CONV_BLOCK_ADDR_WIDTH - 1 : 0] block_num_buf[2**CONV_BLOCK_ADDR_WIDTH - 1 : 0];	// block number for coefficient
	reg	[2**CONV_BLOCK_ADDR_WIDTH - 1 : 0] block_num_buf_reg[2**CONV_BLOCK_ADDR_WIDTH - 1 : 0];	// delayed for using in convolution calculation pipe
	// convolution calculating blocks
	genvar mac_block;
	generate
		for (mac_block = 0; mac_block < 2**CONV_BLOCK_ADDR_WIDTH; mac_block = mac_block + 1)
		begin : mac_blocks
			// RAM buses
			// coefficient RAM buses
			// Data bus: if IOB_ping_from_Rx = 0 - coefficient RAM loaded from parallel bus and CS set then here is data from parallel bus
			//					else if flag ping is present is set, then here is input samples
			assign ping_RAM_D_I[mac_block] = (IOB_ping_RAM_CS & ~IOB_ping_from_Rx) ? IOB_ping_RAM_D : (ping_to_store ? inp_samp_I : 0);
			assign ping_RAM_D_Q[mac_block] = (IOB_ping_RAM_CS & ~IOB_ping_from_Rx) ? IOB_ping_RAM_D : (ping_to_store ? inp_samp_Q : 0);
			// address bus: if IOB_ping_from_Rx = 0 - coefficient RAM loaded from parallel bus and CS set then here is address from parallel bus
			//					else if inp_clk_str is set - here is address for storing input samples
			//							else here is coefficient address for convolution calculation
			assign ping_RAM_A  [mac_block] = (IOB_ping_RAM_CS & ~IOB_ping_from_Rx) ? IOB_ping_RAM_A[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0] : (proc_store_samp ? sample_counter[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0] : addr_ping[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0]);
			// write strobe
			// if coefficient RAM loading from parallel bus selected, then with WE on parallel bus generated WE for appropriate block of coefficient RAM
			// else WE generated with input samples while ping is present
			assign ping_RAM_W_I[mac_block] = (IOB_ping_RAM_CS & ~IOB_ping_from_Rx & IOB_ping_RAM_WR & ~IOB_ping_RAM_IQ & IOB_ping_RAM_A_bank_sel[mac_block]) | (IOB_ping_from_Rx & proc_store_samp & ping_to_store_n[mac_block]);
			assign ping_RAM_W_Q[mac_block] = (IOB_ping_RAM_CS & ~IOB_ping_from_Rx & IOB_ping_RAM_WR &  IOB_ping_RAM_IQ & IOB_ping_RAM_A_bank_sel[mac_block]) | (IOB_ping_from_Rx & proc_store_samp & ping_to_store_n[mac_block]);
			// samples RAM buses
			assign samp_RAM_D_I[mac_block] = inp_samp_I;
			assign samp_RAM_D_Q[mac_block] = inp_samp_Q;
			// with new sample address for storing new sample then address for reading for convolution calculation
			assign samp_RAM_A[mac_block] = proc_store_samp ? sample_counter[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0] : addr_echo[CONV_MEM_BLOCK_ADDR_WIDTH - 1:0];
			// with new sample WE for appropriate block of samples RAM is set
			assign samp_RAM_W[mac_block] = proc_store_samp & (sample_counter[CONV_MEM_BLOCK_ADDR_WIDTH + CONV_BLOCK_ADDR_WIDTH - 1:CONV_MEM_BLOCK_ADDR_WIDTH] == mac_block);
			// block number for reading sample for convolution calculating is evaluated as summ of its number and address offset counted in blocks, floor(addr/sizeof(block)) 
			assign block_num_buf[mac_block] = (mac_block + addr_echo[CONV_MEM_BLOCK_ADDR_WIDTH + CONV_BLOCK_ADDR_WIDTH - 1:CONV_MEM_BLOCK_ADDR_WIDTH]) & {CONV_BLOCK_ADDR_WIDTH{1'b1}};
			always @ (negedge clk or negedge  proc_count_blocks) begin
				block_num_buf_reg[mac_block] <= block_num_buf[mac_block];
				// registers initialization if convolution not processed
				if (~proc_count_blocks) begin
					multiplier_ping_I[mac_block] <= 0;
					multiplier_ping_Q[mac_block] <= 0;
					multiplier_echo_I[mac_block] <= 0;
					multiplier_echo_Q[mac_block] <= 0;
					samp_mult_II[mac_block] <= 0;
					samp_mult_QQ[mac_block] <= 0;
				end else begin
					// multipiers are read from its block with no offset
					multiplier_ping_I[mac_block] <= ping_RAM_Q_I[mac_block];
					multiplier_ping_Q[mac_block] <= ping_RAM_Q_Q[mac_block];
					// multipliers of samples are read with offset
					multiplier_echo_I[mac_block] <= samp_RAM_Q_I[block_num_buf_reg[mac_block]];
					multiplier_echo_Q[mac_block] <= samp_RAM_Q_Q[block_num_buf_reg[mac_block]];
					// summands of convolution Si + jSq = Ai*Bi-Aq*Bq + j(Ai*Bq + Aq*Bi)
					samp_mult_II[mac_block] <= multiplier_ping_I[mac_block] * multiplier_echo_I[mac_block];
					samp_mult_QQ[mac_block] <= multiplier_ping_Q[mac_block] * multiplier_echo_Q[mac_block];
					samp_mult_QI[mac_block] <= multiplier_ping_Q[mac_block] * multiplier_echo_I[mac_block];
					samp_mult_IQ[mac_block] <= multiplier_ping_I[mac_block] * multiplier_echo_Q[mac_block];
				end
			end // always
			always @ (negedge clk ) begin
				if (inp_clk_str) begin
					out_samp_acc_I[mac_block] <= 0;
					out_samp_acc_Q[mac_block] <= 0;
				end else if (proc_count_blocks_acc) begin
					// use II - QQ and QI + IQ to get complex FIR or use II and QQ to get real FIR
					out_samp_acc_I[mac_block] <= out_samp_acc_I[mac_block] + samp_mult_II[mac_block] + samp_mult_QQ[mac_block];
					//out_samp_acc_I[mac_block] <= out_samp_acc_I[mac_block] + samp_mult_II[mac_block];
					out_samp_acc_Q[mac_block] <= out_samp_acc_Q[mac_block] - samp_mult_QI[mac_block] + samp_mult_IQ[mac_block];
					//out_samp_acc_Q[mac_block] <= out_samp_acc_Q[mac_block] + samp_mult_QQ[mac_block];
				end
			end
		end // for
	endgenerate

	always @ (negedge clk)
	begin
		if (inp_clk_str) begin
			blocks_sum_counter <= 0;
			blocks_acc_I <= 0;
			blocks_acc_Q <= 0;
		end else begin
			if (proc_count_blocks_sum) begin	// here is summ of summs calculation
				blocks_sum_counter <= blocks_sum_counter + 1;
				blocks_acc_I <= blocks_acc_I + out_samp_acc_I[blocks_sum_counter];
				blocks_acc_Q <= blocks_acc_Q + out_samp_acc_Q[blocks_sum_counter];
			end
			if (clk_to_samp_counter == 2**CONV_MEM_BLOCK_ADDR_WIDTH + 7 + 2**CONV_BLOCK_ADDR_WIDTH) begin	// convolution sample ready, move result to output register
				out_samp_I_reg <= blocks_acc_I;
				out_samp_Q_reg <= blocks_acc_Q;
			end
		end //if
	end // always

	// sample strobe, frame strobe and |output|^2 for debug
	always @ (negedge clk ) begin
		// output strobes outputs with output sample
		out_samp_strobe_reg <= clk_to_samp_counter == 2**CONV_MEM_BLOCK_ADDR_WIDTH + 7 + 2**CONV_BLOCK_ADDR_WIDTH;
		out_frame_strobe_reg <= (clk_to_samp_counter == 2**CONV_MEM_BLOCK_ADDR_WIDTH + 7 + 2**CONV_BLOCK_ADDR_WIDTH) & (sample_counter == 0) & ping_to_store_n[0];
		out_samp_A_sq_reg <= out_samp_I_reg * out_samp_I_reg + out_samp_Q_reg * out_samp_Q_reg;
	end

	assign out_samp_strobe = out_samp_strobe_reg;
	assign out_frame_strobe = out_frame_strobe_reg;
	assign out_samp_I = out_samp_I_reg;
	assign out_samp_Q = out_samp_Q_reg;
	assign out_samp_A_sq = out_samp_A_sq_reg[OUT_SAMP_A_SQ_WIDTH + OUT_SAMP_A_SQ_OFFS - 1:OUT_SAMP_A_SQ_OFFS];
endmodule
