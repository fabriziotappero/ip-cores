`timescale 10ns / 1ns

module tb_blitter();

reg CLK_I;
reg reset_n;

reg [31:0] master_DAT_I;
reg ACK_I;
wire CYC_O;
wire STB_O;
wire WE_O;
wire [29:0] ADR_O;
wire [3:0] SEL_O;
wire [31:0] master_DAT_O;

reg CYC_I;
reg STB_I;
reg WE_I;
reg [8:2] ADR_I;
reg [3:0] SEL_I;
reg [31:0] slave_DAT_I;
wire ACK_O;

reg [10:0] dma_con;
wire blitter_irq;
wire blitter_zero;
wire blitter_busy;

ocs_blitter blitter_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    // WISHBONE master
    .CYC_O(CYC_O),
    .STB_O(STB_O),
    .WE_O(WE_O),
    .ADR_O(ADR_O),
    .SEL_O(SEL_O),
    .master_DAT_O(master_DAT_O),
    .master_DAT_I(master_DAT_I),
    .ACK_I(ACK_I),
    
    // WISHBONE slave
    .CYC_I(CYC_I),
    .STB_I(STB_I),
    .WE_I(WE_I),
    .ADR_I(ADR_I),
    .SEL_I(SEL_I),
    .slave_DAT_I(slave_DAT_I),
    .ACK_O(ACK_O),
    
    // dma enable
    .dma_con(dma_con),
    .blitter_irq(blitter_irq),
    .blitter_zero(blitter_zero),
    .blitter_busy(blitter_busy)
);

initial begin
	CLK_I = 1'b0;
	forever #5 CLK_I = ~CLK_I;
end

function [31:0] get_argument(input [87:0] name);
reg [31:0] result;
begin
	if( $value$plusargs({name, "=%h"}, result) == 0 ) begin
		$display("Missing argument: %s", name);
		$finish_and_return(-1);
	end
	get_argument = result;
end
endfunction

function [255:0] get_argument_as_string(input [87:0] name);
reg [255:0] result;
begin
	if( $value$plusargs({name, "=%s"}, result) == 0 ) begin
		$display("Missing argument: %s", name);
		$finish_and_return(-1);
	end
	get_argument_as_string = result;
end
endfunction

reg [255:0] string;
reg [31:0] write_data_selected;

reg [3:0] mem_valid[749:0];
reg [31:0] mem[749:0];
reg [31:0] mem_arg;

always @(posedge CLK_I) begin
    if(STB_O == 1'b1 && WE_O == 1'b0) begin
		$display("memory read: address=%h, select=%h", {ADR_O, 2'b0}, SEL_O);

		$sformat(string, "MEM%h", {ADR_O, 2'b0});

		#5
		mem_arg = get_argument(string);
		master_DAT_I = mem_arg;
		if(ADR_O < 30'd750) begin
		    if(mem_valid[ADR_O][0] == 1'b1) master_DAT_I[7:0] = mem[ADR_O][7:0]; else master_DAT_I[7:0] = mem_arg[7:0];
		    if(mem_valid[ADR_O][1] == 1'b1) master_DAT_I[15:8] = mem[ADR_O][15:8]; else master_DAT_I[15:8] = mem_arg[15:8];
		    if(mem_valid[ADR_O][2] == 1'b1) master_DAT_I[23:16] = mem[ADR_O][23:16]; else master_DAT_I[23:16] = mem_arg[23:16];
		    if(mem_valid[ADR_O][3] == 1'b1) master_DAT_I[31:24] = mem[ADR_O][31:24]; else master_DAT_I[31:24] = mem_arg[31:24];
		end
		
		ACK_I = 1'b1;
		#10
		master_DAT_I = 32'd0;
		ACK_I = 1'b0;
	end
    else if(STB_O == 1'b1 && WE_O == 1'b1) begin
		if(SEL_O == 4'd0) write_data_selected = 32'd0;
		else if(SEL_O == 4'd1) write_data_selected = { 24'd0, master_DAT_O[7:0] };
		else if(SEL_O == 4'd2) write_data_selected = { 16'd0, master_DAT_O[15:8], 8'd0 };
		else if(SEL_O == 4'd3) write_data_selected = { 16'd0, master_DAT_O[15:0] };
		else if(SEL_O == 4'd4) write_data_selected = { 8'd0, master_DAT_O[23:16], 16'd0 };
		else if(SEL_O == 4'd5) write_data_selected = { 8'd0, master_DAT_O[23:16], 8'd0, master_DAT_O[7:0] };
		else if(SEL_O == 4'd6) write_data_selected = { 8'd0, master_DAT_O[23:8], 8'd0 };
		else if(SEL_O == 4'd7) write_data_selected = { 8'd0, master_DAT_O[23:0] };
		else if(SEL_O == 4'd8) write_data_selected = { master_DAT_O[31:24], 24'd0 };
		else if(SEL_O == 4'd9) write_data_selected = { master_DAT_O[31:24], 16'd0, master_DAT_O[7:0] };
		else if(SEL_O == 4'd10) write_data_selected = { master_DAT_O[31:24], 8'd0, master_DAT_O[15:8], 8'd0 };
		else if(SEL_O == 4'd11) write_data_selected = { master_DAT_O[31:24], 8'd0, master_DAT_O[15:0] };
		else if(SEL_O == 4'd12) write_data_selected = { master_DAT_O[31:16], 16'd0 };
		else if(SEL_O == 4'd13) write_data_selected = { master_DAT_O[31:16], 8'd0, master_DAT_O[7:0] };
		else if(SEL_O == 4'd14) write_data_selected = { master_DAT_O[31:8], 8'd0 };
		else if(SEL_O == 4'd15) write_data_selected = master_DAT_O[31:0];

		$display("memory write: address=%h, select=%h, value=%h", { ADR_O, 2'b0 }, SEL_O, write_data_selected);
        
        if(ADR_O < 30'd750) begin
            if(SEL_O[0] == 1'b1) begin mem[ADR_O][7:0] = write_data_selected[7:0]; mem_valid[ADR_O][0] = 1'b1; end
            if(SEL_O[1] == 1'b1) begin mem[ADR_O][15:8] = write_data_selected[15:8]; mem_valid[ADR_O][1] = 1'b1; end
            if(SEL_O[2] == 1'b1) begin mem[ADR_O][23:16] = write_data_selected[23:16]; mem_valid[ADR_O][2] = 1'b1; end
            if(SEL_O[3] == 1'b1) begin mem[ADR_O][31:24] = write_data_selected[31:24]; mem_valid[ADR_O][3] = 1'b1; end
        end
        
		#5
		ACK_I = 1'b1;
		#10
		ACK_I = 1'b0;
	end
end

task init_blitter;
integer count;
integer i;
reg [31:0] adr;
reg [31:0] value;
integer read_count;
begin
    count = get_argument("init_writes");
    dma_con = get_argument("dma_con");
    
    for(i=0; i<count; i=i+1) begin
        $sformat(string, "SLV%h", i);
        string = get_argument_as_string(string);
        read_count = $sscanf(string, "%h:%h", adr,value);
        //$display("Found: ADR=%h, VALUE=%h", adr,value);
        
        ADR_I = adr[7:2];
        slave_DAT_I = value;
        STB_I = 1'b1;
        CYC_I = 1'b1;
        WE_I = 1'b1;
        SEL_I = 4'b1111;
        
        while(ACK_O == 1'b0) #10;
        while(ACK_O == 1'b1) #10;
        
        STB_I = 1'b0;
        CYC_I = 1'b0;
        
        if(read_count != 2) begin
            $display("Invalid SLV arguments.");
            $finish_and_return(-1);
        end
    end
    
    
end
endtask

integer j;
initial begin
	#10
	for(j=0; j<100000; j=j+1) begin
	    if(blitter_irq == 1'b1) begin
	        $display("blitter_done.");
	        
	        $display("aph: %04x", blitter_inst.a_address[31:16]);
	        $display("apl: %04x", blitter_inst.a_address[15:0]);
	        $display("bph: %04x", blitter_inst.b_address[31:16]);
	        $display("bpl: %04x", blitter_inst.b_address[15:0]);
	        $display("cph: %04x", blitter_inst.c_address[31:16]);
	        $display("cpl: %04x", blitter_inst.c_address[15:0]);
	        $display("dph: %04x", blitter_inst.d_address[31:16]);
	        $display("dpl: %04x", blitter_inst.d_address[15:0]);
	        
	        $display("adh: %08x", blitter_inst.a_dat[63:32]);
	        $display("adl: %08x", blitter_inst.a_dat[31:0]);
	        
	        $display("bdh: %08x", blitter_inst.b_dat[63:32]);
	        $display("bdl: %08x", blitter_inst.b_dat[31:0]);
	        
	        $display("cdh: %04x", blitter_inst.c_dat[47:32]);
	        $display("cdl: %08x", blitter_inst.c_dat[31:0]);
	        
            $finish_and_return(0);
	    end
	    #10 ;
	end
	$finish_and_return(-1);
end

integer i;
initial begin
    $dumpfile("tb_blitter.vcd");
	$dumpvars(0);
	$dumpon();

	reset_n = 1'b0;
	#10 reset_n = 1'b1;
    
    #30
    for(i=0; i<750; i=i+1) mem_valid[i] = 4'b0;
    
    blitter_inst.a_dat[63:32] = get_argument("adh");
    blitter_inst.a_dat[31:0] = get_argument("adl");
    blitter_inst.b_dat[63:32] = get_argument("bdh");
    blitter_inst.b_dat[31:0] = get_argument("bdl");
    blitter_inst.c_dat[47:32] = get_argument("cdh");
    blitter_inst.c_dat[31:0] = get_argument("cdl");
    init_blitter();
	
    forever #10 ;

	$dumpoff();
    
	$finish();
end

endmodule

