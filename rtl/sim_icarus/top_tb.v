`timescale 1ns/10ps

//-----------------------------------------------------------------
// Module
//-----------------------------------------------------------------
module top_tb ;

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
reg                 clk;
reg                 rst;
wire                fault;
wire                break;

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------
top  
u_top
(
    .clk_i(clk),
    .rst_i(rst),
    .fault_o(fault),
    .break_o(break),
    .intr_i(1'b0)
);

//-----------------------------------------------------------------
// Test
//-----------------------------------------------------------------
initial 
begin 
    clk = 0; 
    rst = 1; 
    $dumpfile("waveform.vcd");
    $dumpvars(0,top_tb);
        
#(31.25*2)  rst = 0;
end

always
begin
    #31.25 clk =  ! clk; 
end

integer cycle_count;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        cycle_count = 0;
    end
    else
    begin
        cycle_count = cycle_count + 1;

        if (fault)
        begin
            $display("Fault detected");
            $finish;
        end
        else if (break)
        begin
            $display("Completed after %2d cycles", cycle_count);
            $finish;
        end
    end
end

endmodule
