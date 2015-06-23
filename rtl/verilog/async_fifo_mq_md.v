// async FIFO with multiple queues, multiple data

module async_fifo_mq_md (
    d, fifo_full, write, write_enable, clk1, rst1,
    q, fifo_empty, read, read_enable, clk2, rst2
);

parameter a_hi_size = 4;
parameter a_lo_size = 4;
parameter nr_of_queues = 16;
parameter data_width = 36;

input [data_width*nr_of_queues-1:0] d;
output [0:nr_of_queues-1] fifo_full;
input                     write;
input  [0:nr_of_queues-1] write_enable;
input clk1;
input rst1;

output [data_width-1:0] q;
output [0:nr_of_queues-1] fifo_empty;
input                     read;
input  [0:nr_of_queues-1] read_enable;
input clk2;
input rst2;

wire [a_lo_size-1:0]  fifo_wadr_bin[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_wadr_gray[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_radr_bin[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_radr_gray[0:nr_of_queues-1];
reg [a_lo_size-1:0] wadr;
reg [a_lo_size-1:0] radr;
reg [data_width-1:0] wdata;
wire [data_width-1:0] wdataa[0:nr_of_queues-1];

genvar i;
integer j,k,l;

function [a_lo_size-1:0] onehot2bin;
input [0:nr_of_queues-1] a;
integer i;
begin
    onehot2bin = {a_lo_size{1'b0}};
    for (i=1;i<nr_of_queues;i=i+1) begin
        if (a[i])
            onehot2bin = i;
    end
end
endfunction

generate
    for (i=0;i<nr_of_queues;i=i+1) begin : fifo_adr
        
        gray_counter wadrcnt (
            .cke(write & write_enable[i]),
            .q(fifo_wadr_gray[i]),
            .q_bin(fifo_wadr_bin[i]),
            .rst(rst1),
            .clk(clk1));
        
        gray_counter radrcnt (
            .cke(read & read_enable[i]),
            .q(fifo_radr_gray[i]),
            .q_bin(fifo_radr_bin[i]),
            .rst(rst2),
            .clk(clk2));
        
	versatile_fifo_async_cmp
            #(.ADDR_WIDTH(a_lo_size))
            egresscmp ( 
                .wptr(fifo_wadr_gray[i]), 
		.rptr(fifo_radr_gray[i]), 
		.fifo_empty(fifo_empty[i]), 
		.fifo_full(fifo_full[i]), 
		.wclk(clk1), 
		.rclk(clk2), 
		.rst(rst1));
        
    end
endgenerate

// and-or mux write address
always @*
begin
    wadr = {a_lo_size{1'b0}};
    for (j=0;j<nr_of_queues;j=j+1) begin
        wadr = (fifo_wadr_bin[j] & {a_lo_size{write_enable[j]}}) | wadr;
    end
end

// and-or mux read address
always @*
begin
    radr = {a_lo_size{1'b0}};
    for (k=0;k<nr_of_queues;k=k+1) begin
        radr = (fifo_radr_bin[k] & {a_lo_size{read_enable[k]}}) | radr;
    end
end

// and-or mux write data
generate
    for (i=0;i<nr_of_queues;i=i+1) begin : vector2array
        assign wdataa[i] = d[(nr_of_queues-i)*data_width-1:(nr_of_queues-1-i)*data_width];
    end
endgenerate

always @*
begin
    wdata = {data_width{1'b0}};
    for (l=0;l<nr_of_queues;l=l+1) begin
        wdata = (wdataa[l] & {data_width{write_enable[l]}}) | wdata;
    end
end

vfifo_dual_port_ram_dc_sw # ( .DATA_WIDTH(data_width), .ADDR_WIDTH(a_hi_size+a_lo_size))
    dpram (
    .d_a(wdata),
    .adr_a({onehot2bin(write_enable),wadr}), 
    .we_a(write),
    .clk_a(clk1),
    .q_b(q),
    .adr_b({onehot2bin(read_enable),radr}),
    .clk_b(clk2) );

endmodule
