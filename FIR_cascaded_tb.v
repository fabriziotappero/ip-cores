`timescale 1 ns/ 1 ns
module FIR_cascaded_tb
#(
	// uncomment selected test
	`define test_saw		// test with I -4, -3, ..., 4, 5 ; and Q 1, 2, ..., 9, 10, 10 complex samples of ping total
	//`define test_tone		// tone pulse
	//`define test_rect		// rectangle pulse
	//`define test_delta	// test with delta-function
	//`define test_chirp	// test with chirp. It is long test, pulse response length is 2048
	//`define test_chirp_short

	`ifdef test_saw
	//Test short signal
	parameter	PING_FROM_INPUT_SIGNAL = 1,
	parameter	INP_SAMP_WIDTH = 14,				// imput samples width
	parameter	PING_ADDR_WIDTH = 4,				// address width of pulse response characteristic samples
	parameter	CONV_MEM_BLOCK_ADDR_WIDTH = 3,		//address width of block
	parameter	FRAME_ADDR_WIDTH = 14,				// address width of counter of samples in frame
	parameter	OUT_SAMP_WIDTH = 18,				// output samples width
	parameter	CLK_TO_SAMP_ADDR_WIDTH	= 12,		// inp_samp counter width, it counts clk 
	parameter	CLK_TO_SAMP_RATIO = 25,				// clk -> inp_clk divider
	parameter	SIM_FRAME_ADDR_COUNTER_WIDTH = 18,	// address in frame counter
	parameter	SIM_FRAME_COUNTER_WIDTH = 18,		// number of frame counter
	parameter	PARAM_INP_PING_LENGTH = 10,			// ping length
	parameter	FRAME_PERIOD = 100,					// frame period
	parameter	OUT_SAMP_A_SQ_WIDTH = 16,			// |output|^2 word width
	parameter	OUT_SAMP_A_SQ_OFFS = 4,				// offset of |output|^2 word, OUT_SAMP_A_SQ_WIDTH bits from OUT_SAMP_A_SQ_OFFS writes to output
	parameter	INP_FILE = "IQ_saw_signal.txt",		// input signal samples file
	parameter	PING_FILE = "IQ_saw_ping.txt",		// ping samples file
	parameter	SIM_DURATION = 100000					// simulation duration after reset duration
	// input file example with -4,-3... in I and 1, 2, 3 in Q:
	// fffc
	// 0001
	// fffd
	// 0002
	// fffe
	// 0003
	`endif

	`ifdef test_tone
	parameter	PING_FROM_INPUT_SIGNAL = 1,
	parameter	INP_SAMP_WIDTH = 14,				// imput samples width
	parameter	PING_ADDR_WIDTH = 7,				// address width of pulse response characteristic samples
	parameter	CONV_MEM_BLOCK_ADDR_WIDTH = 3,		//address width of block
	parameter	FRAME_ADDR_WIDTH = 14,				// address width of counter of samples in frame
	parameter	OUT_SAMP_WIDTH = 18,				// output samples width
	parameter	CLK_TO_SAMP_ADDR_WIDTH	= 12,		// inp_samp counter width, it counts clk 
	parameter	CLK_TO_SAMP_RATIO = 100,			// clk -> inp_clk divider
	parameter	SIM_FRAME_ADDR_COUNTER_WIDTH = 18,	// address in frame counter
	parameter	SIM_FRAME_COUNTER_WIDTH = 18,		// number of frame counter
	parameter	PARAM_INP_PING_LENGTH = 100,		// ping length
	parameter	FRAME_PERIOD = 2500,				// frame period
	parameter	OUT_SAMP_A_SQ_WIDTH = 16,			// |output|^2 word width
	parameter	OUT_SAMP_A_SQ_OFFS = 16,				// offset of |output|^2 word, OUT_SAMP_A_SQ_WIDTH bits from OUT_SAMP_A_SQ_OFFS writes to output
	parameter	INP_FILE = "IQ_tone_signal.txt",	// input signal samples file
	parameter	PING_FILE = "IQ_tone_ping.txt",		// ping samples file
	parameter	SIM_DURATION = 5000000					// simulation duration after reset duration
	`endif

	`ifdef test_rect
	//Test short signal
	parameter	PING_FROM_INPUT_SIGNAL = 1,
	parameter	INP_SAMP_WIDTH = 14,				// imput samples width
	parameter	PING_ADDR_WIDTH = 7,				// address width of pulse response characteristic samples
	parameter	CONV_MEM_BLOCK_ADDR_WIDTH = 3,		//address width of block
	parameter	FRAME_ADDR_WIDTH = 14,				// address width of counter of samples in frame
	parameter	OUT_SAMP_WIDTH = 18,				// output samples width
	parameter	CLK_TO_SAMP_ADDR_WIDTH	= 12,		// inp_samp counter width, it counts clk 
	parameter	CLK_TO_SAMP_RATIO = 100,			// clk -> inp_clk divider
	parameter	SIM_FRAME_ADDR_COUNTER_WIDTH = 18,	// address in frame counter
	parameter	SIM_FRAME_COUNTER_WIDTH = 18,		// number of frame counter
	parameter	PARAM_INP_PING_LENGTH = 100,		// ping length
	parameter	FRAME_PERIOD = 2500,				// frame period
	parameter	OUT_SAMP_A_SQ_WIDTH = 16,			// |output|^2 word width
	parameter	OUT_SAMP_A_SQ_OFFS = 4,				// offset of |output|^2 word, OUT_SAMP_A_SQ_WIDTH bits from OUT_SAMP_A_SQ_OFFS writes to output
	parameter	INP_FILE = "IQ_rect_signal.txt",	// input signal samples file
	parameter	PING_FILE = "IQ_rect_ping.txt",		// ping samples file
	parameter	SIM_DURATION = 4000000					// simulation duration after reset duration
	`endif

	`ifdef test_delta
	//Test delta function
	parameter	PING_FROM_INPUT_SIGNAL = 1,
	parameter	INP_SAMP_WIDTH = 14,
	parameter	PING_ADDR_WIDTH = 4,
	parameter	FRAME_ADDR_WIDTH = 14,
	parameter	CONV_MEM_BLOCK_ADDR_WIDTH = 3,
	parameter	OUT_SAMP_WIDTH = 18,
	parameter	CLK_TO_SAMP_ADDR_WIDTH	= 12,
	parameter	CLK_TO_SAMP_RATIO = 25,
	parameter	SIM_FRAME_ADDR_COUNTER_WIDTH = 18,
	parameter	SIM_FRAME_COUNTER_WIDTH = 18,
	parameter	PARAM_INP_PING_LENGTH = 1,
	parameter	FRAME_PERIOD = 50,
	parameter	OUT_SAMP_A_SQ_WIDTH = 16,
	parameter	OUT_SAMP_A_SQ_OFFS = 4,
	parameter	INP_FILE = "IQ_delta_signal.txt",
	parameter	PING_FILE = "IQ_delta_ping.txt",
	parameter	SIM_DURATION = 1000000					// simulation duration after reset duration
	`endif
	`ifdef test_chirp_short
	parameter	PING_FROM_INPUT_SIGNAL = 1,
	parameter	INP_SAMP_WIDTH = 14,
	parameter	PING_ADDR_WIDTH = 6,
	parameter	FRAME_ADDR_WIDTH = 18,
	parameter	CONV_MEM_BLOCK_ADDR_WIDTH = 5,
	parameter	OUT_SAMP_WIDTH = 18,
	parameter	CLK_TO_SAMP_ADDR_WIDTH	= 11,
	parameter	CLK_TO_SAMP_RATIO = 500,
	parameter	SIM_FRAME_ADDR_COUNTER_WIDTH = 18,
	parameter	SIM_FRAME_COUNTER_WIDTH = 18,
	parameter	PARAM_INP_PING_LENGTH = 50,
	parameter	FRAME_PERIOD = 1000,
	parameter	OUT_SAMP_A_SQ_WIDTH = 20,
	parameter	OUT_SAMP_A_SQ_OFFS = 18,
	parameter	INP_FILE = "IQ_chirp_signal.txt",
	parameter	PING_FILE = "IQ_chirp_ping.txt",
	parameter	SIM_DURATION = 16000000					// simulation duration after reset duration
	`endif
	`ifdef test_chirp
	parameter	PING_FROM_INPUT_SIGNAL = 1,
	parameter	INP_SAMP_WIDTH = 14,
	parameter	PING_ADDR_WIDTH = 11,
	parameter	FRAME_ADDR_WIDTH = 18,
	parameter	CONV_MEM_BLOCK_ADDR_WIDTH = 10,
	parameter	OUT_SAMP_WIDTH = 18,
	parameter	CLK_TO_SAMP_ADDR_WIDTH	= 11,
	parameter	CLK_TO_SAMP_RATIO = 2000,
	parameter	SIM_FRAME_ADDR_COUNTER_WIDTH = 18,
	parameter	SIM_FRAME_COUNTER_WIDTH = 18,
	parameter	PARAM_INP_PING_LENGTH = 50,
	parameter	FRAME_PERIOD = 8000,
	parameter	OUT_SAMP_A_SQ_WIDTH = 20,
	parameter	OUT_SAMP_A_SQ_OFFS = 16,
	parameter	INP_FILE = "IQ_chirp_signal.txt",
	parameter	PING_FILE = "IQ_chirp_ping.txt",
	parameter	SIM_DURATION = 24000000					// simulation duration after reset duration
	`endif
);
	reg	clk;										// тактовая частота
	reg	reset;										// сброс
	reg	inp_clk;									// стробы отсчётов
	wire	[3:0] count;
	reg									inp_ping_start;		// начало зондирующего импулься
	reg			[INP_SAMP_WIDTH - 1:0]	inp_samp_I;			// входные отсчёты
	reg			[INP_SAMP_WIDTH - 1:0]	inp_samp_Q;			// входные отсчёты
	reg			[PING_ADDR_WIDTH - 1:0] inp_ping_length;	// длительность зондирующего импульса, во входных отсчётах
	// parallel interface to coefficients RAM
	reg									IOB_ping_from_Rx;	// 1 - получать ЗИ из входных отсчётов, 0 - не получать ЗИ из входных отсчётов, подразумевается запись напрямую в RAM
	reg 								IOB_ping_RAM_CS;	// RAM зондирующего импульса, выбор RAM, должен быть 1, чтобы RAM не заполнялась входными отсчётами ЗИ
	wire signed	[INP_SAMP_WIDTH - 1:0]	IOB_ping_RAM_D;		// RAM зондирующего импульса, data Re
	reg signed	[INP_SAMP_WIDTH - 1:0]	IOB_ping_RAM_D_reg;	// RAM зондирующего импульса, data Re
	//reg	signed	[INP_SAMP_WIDTH - 1:0]	IOB_ping_RAM_D_I;		// RAM зондирующего импульса, data Re
	//reg	signed	[INP_SAMP_WIDTH - 1:0]	IOB_ping_RAM_D_Q;		// RAM зондирующего импульса, data Im
	reg signed	[PING_ADDR_WIDTH - 1:0]	IOB_ping_RAM_A;		// RAM зондирующего импульса, address
	reg									IOB_ping_RAM_IQ;	// RAM зондирующего импульса, write enable
	reg									IOB_ping_RAM_WR;	// RAM зондирующего импульса, write enable
	reg	 								IOB_ping_RAM_RD;	// RAM зондирующего импульса, write enable
	reg									IOB_ping_RAM_load_ready;
	wire		[OUT_SAMP_WIDTH - 1:0]	out_samp_I;			// выходные отсчёты, результат обработки
	wire		[OUT_SAMP_WIDTH - 1:0]	out_samp_Q;			// выходные отсчёты, результат обработки
	wire signed	[OUT_SAMP_A_SQ_WIDTH - 1:0]	out_samp_A_sq;	// сумма квадратов выходных отсчётов, для отладки
	wire								out_samp_strobe;	// стробы выходных отсчётов
	wire								out_frame_strobe;	// стробы периода зондирования
	//reg	[INP_SAMP_WIDTH - 1:0]	inp_signal_file	[0:32767];
	reg	[15:0]	inp_signal_file	[0:8191];					// хранение входного сигнала
	reg	[15:0]	ping_file	[0:4095];						// хранение ЗИ
	
	reg	[CLK_TO_SAMP_ADDR_WIDTH - 1:0]			clk_to_samp_counter;	// счётчик номера отсчёта в периоде зондирования
	reg	[SIM_FRAME_ADDR_COUNTER_WIDTH - 1:0]	frame_addr_counter;		// счётчик адреса в frame
	reg	[SIM_FRAME_COUNTER_WIDTH - 1:0]			frame_counter;			// счётчик номера frame
	integer	cpu_io_counter;
	FIR_cascaded
#(
	.INP_SAMP_WIDTH				(INP_SAMP_WIDTH),
	.PING_ADDR_WIDTH			(PING_ADDR_WIDTH),
	.FRAME_ADDR_WIDTH			(FRAME_ADDR_WIDTH),
	.CONV_MEM_BLOCK_ADDR_WIDTH	(CONV_MEM_BLOCK_ADDR_WIDTH),
	.OUT_SAMP_WIDTH				(OUT_SAMP_WIDTH),
	.CLK_TO_SAMP_ADDR_WIDTH		(CLK_TO_SAMP_ADDR_WIDTH),
	.OUT_SAMP_A_SQ_WIDTH		(OUT_SAMP_A_SQ_WIDTH),
	.OUT_SAMP_A_SQ_OFFS			(OUT_SAMP_A_SQ_OFFS)
)
	FIR_cascaded_DUT (
		.clk				(clk),
		.reset				(reset),
		.inp_clk			(inp_clk),
		.inp_ping_start		(inp_ping_start),
		.inp_samp_I			(inp_samp_I),
		.inp_samp_Q			(inp_samp_Q),
		.inp_ping_length	(inp_ping_length),
		.IOB_ping_from_Rx	(IOB_ping_from_Rx),
		.IOB_ping_RAM_CS	(IOB_ping_RAM_CS),
		.IOB_ping_RAM_D		(IOB_ping_RAM_D),
		.IOB_ping_RAM_IQ	(IOB_ping_RAM_IQ),
		.IOB_ping_RAM_A		(IOB_ping_RAM_A),
		.IOB_ping_RAM_WR	(IOB_ping_RAM_WR),
		.IOB_ping_RAM_RD	(IOB_ping_RAM_RD),
		.out_samp_I			(out_samp_I),
		.out_samp_Q			(out_samp_Q),
		.out_samp_A_sq		(out_samp_A_sq),
		.out_samp_strobe	(out_samp_strobe),
		.out_frame_strobe	(out_frame_strobe)
	);

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(1, FIR_cascaded_tb, FIR_cascaded_DUT,
		FIR_cascaded_DUT.out_samp_Q_reg,
		FIR_cascaded_DUT.multiplier_ping_Q[0], FIR_cascaded_DUT.out_samp_acc_Q[0], FIR_cascaded_DUT.multiplier_echo_Q[0]
		//,FIR_cascaded_DUT.multiplier_ping_Q[1], FIR_cascaded_DUT.out_samp_acc_Q[1], FIR_cascaded_DUT.multiplier_echo_Q[1]
		//,FIR_cascaded_DUT.multiplier_ping_Q[2], FIR_cascaded_DUT.out_samp_acc_Q[2], FIR_cascaded_DUT.multiplier_echo_Q[2]
		//,FIR_cascaded_DUT.multiplier_ping_Q[3], FIR_cascaded_DUT.out_samp_acc_Q[3], FIR_cascaded_DUT.multiplier_echo_Q[3]
		,FIR_cascaded_DUT.ping_RAM_W_I[0]
		//,FIR_cascaded_DUT.ping_RAM_A
		,FIR_cascaded_DUT.ping_RAM_D_I[0]
		);
		clk = 0;
		reset = 0;
		inp_clk = 0;
		inp_ping_start = 0;
		clk_to_samp_counter = 0;
		frame_addr_counter = 0;
		frame_counter = 0;
		inp_ping_length = PARAM_INP_PING_LENGTH;
		IOB_ping_from_Rx = PING_FROM_INPUT_SIGNAL;
		IOB_ping_RAM_load_ready = 0;
		IOB_ping_RAM_CS = 1;
		IOB_ping_RAM_D_reg = {INP_SAMP_WIDTH{1'bZ}};
		IOB_ping_RAM_IQ = 0;
		IOB_ping_RAM_A = 0;
		IOB_ping_RAM_WR = 1;
		IOB_ping_RAM_RD = 0;
		cpu_io_counter = 0;
		$readmemh(INP_FILE, inp_signal_file);
		$readmemh(PING_FILE, ping_file);
		IOB_ping_RAM_D_reg = ping_file[cpu_io_counter];
		IOB_ping_RAM_IQ = cpu_io_counter[0];
		IOB_ping_RAM_A = cpu_io_counter[PING_ADDR_WIDTH:1];
		inp_samp_I <= inp_signal_file[frame_addr_counter*2];
		inp_samp_Q <= inp_signal_file[frame_addr_counter*2 + 1];
		#20 reset = 1;
		#20 reset = 0;
		#SIM_DURATION $finish;
	end

	always
		#10 clk = !clk;
	always@(negedge clk)
	begin
		if (IOB_ping_RAM_load_ready == 1) begin
			if (clk_to_samp_counter == CLK_TO_SAMP_RATIO - 1) begin	// generate sample
				clk_to_samp_counter <= 0;
				inp_clk <= 1;
				inp_samp_I <= inp_signal_file[(frame_addr_counter)*2];
				inp_samp_Q <= inp_signal_file[(frame_addr_counter)*2 + 1];
				if (frame_addr_counter == FRAME_PERIOD) begin		// ping start
					frame_addr_counter <= 0;
					frame_counter <= frame_counter + 1;
				end else begin
					frame_addr_counter <= frame_addr_counter + 1;
				end
				inp_ping_start <= frame_addr_counter == 0;
			end else begin
				if (clk_to_samp_counter == CLK_TO_SAMP_RATIO / 2) begin
					inp_clk <= 0;
				end
				clk_to_samp_counter <= clk_to_samp_counter + 1;
			end
			if (clk_to_samp_counter == 0) begin
			end else if (clk_to_samp_counter == CLK_TO_SAMP_RATIO / 2) begin
			end
		end else begin
			frame_addr_counter <= 0;
		end
	end

	assign	IOB_ping_RAM_D = IOB_ping_RAM_WR ? IOB_ping_RAM_D_reg : {INP_SAMP_WIDTH{1'bZ}};

	always @ (negedge clk) begin
		if (reset) begin
			cpu_io_counter <= 0;
		end else begin
			if (cpu_io_counter <= (2**PING_ADDR_WIDTH) * 2) begin
				cpu_io_counter <= cpu_io_counter + 1;
			end
			if (cpu_io_counter < (2**PING_ADDR_WIDTH) * 2) begin
				IOB_ping_RAM_CS = 1;
				IOB_ping_RAM_D_reg = ping_file[cpu_io_counter];
				IOB_ping_RAM_IQ = cpu_io_counter[0];
				IOB_ping_RAM_A = cpu_io_counter[PING_ADDR_WIDTH:1];
				IOB_ping_RAM_WR = 1;
				IOB_ping_RAM_RD = 0;
			end else begin
				IOB_ping_RAM_load_ready = 1;
				IOB_ping_RAM_CS = 0;
				IOB_ping_RAM_IQ = 0;
				IOB_ping_RAM_A = 0;
				IOB_ping_RAM_WR = 0;
				IOB_ping_RAM_RD = 0;
			end
		end
	end //always
endmodule
