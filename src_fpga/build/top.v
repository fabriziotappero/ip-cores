//`include "mkTestBench.v"
//`include "SRAM.v"

module top;

reg [31 : 0]    arr[0:262144];
reg [18:0]      addr_p;  
reg [18:0]      addr_pp;
reg             we_p;
reg             we_pp;
reg             clk;
reg             rst;
wire [31:0]     data_in;
wire [31:0]     data_out;
wire [18:0]     addr;
wire            we;
integer         x;

reg [31 : 0]    arr2[0:262144];
reg [18:0]      addr_p2;  
reg [18:0]      addr_pp2;
reg             we_p2;
reg             we_pp2;
wire [31:0]     data_in2;
wire [31:0]     data_out2;
wire [18:0]     addr2;
wire            we2;

mkTestBench tb(.CLK(clk),
		   .RST_N(rst),
		   
		   .sram_controller1_address_out(addr),
		   .RDY_sram_controller1_address_out(),
		   
		   .sram_controller1_data_O(data_out),
		   .RDY_sram_controller1_data_O(),
		   
		   .sram_controller1_data_I_data(data_in),
		   .EN_sram_controller1_data_I(1),
		   .RDY_sram_controller1_data_I(),
		   
		   .sram_controller1_data_T(),
		   .RDY_sram_controller1_data_T(),
		   
		   .sram_controller1_we_bytes_out(),
		   .RDY_sram_controller1_we_bytes_out(),
		   
		   .sram_controller1_we_out(we),
		   .RDY_sram_controller1_we_out(),
		   
		   .sram_controller1_ce_out(),
		   .RDY_sram_controller1_ce_out(),
		   
		   .sram_controller1_oe_out(),
		   .RDY_sram_controller1_oe_out(),
		   
		   .sram_controller1_cen_out(),
		   .RDY_sram_controller1_cen_out(),
		   
		   .sram_controller1_adv_ld_out(),
		   .RDY_sram_controller1_adv_ld_out(),
		   
		   .sram_controller2_address_out(addr2),
		   .RDY_sram_controller2_address_out(),
		   
		   .sram_controller2_data_O(data_out2),
		   .RDY_sram_controller2_data_O(),
		   
		   .sram_controller2_data_I_data(data_in2),
		   .EN_sram_controller2_data_I(1),
		   .RDY_sram_controller2_data_I(),
		   
		   .sram_controller2_data_T(),
		   .RDY_sram_controller2_data_T(),
		   
		   .sram_controller2_we_bytes_out(),
		   .RDY_sram_controller2_we_bytes_out(),
		   
		   .sram_controller2_we_out(we2),
		   .RDY_sram_controller2_we_out(),
		   
		   .sram_controller2_ce_out(),
		   .RDY_sram_controller2_ce_out(),
		   
		   .sram_controller2_oe_out(),
		   .RDY_sram_controller2_oe_out(),
		   
		   .sram_controller2_cen_out(),
		   .RDY_sram_controller2_cen_out(),
		   
		   .sram_controller2_adv_ld_out(),
		   .RDY_sram_controller2_adv_ld_out());


assign data_in = arr[addr_pp]; 
assign data_in2 = arr2[addr_pp2]; 

always@(*)
  begin
    #5 clk <= ~clk;
  end



always@(posedge clk)
  begin
    if(~rst)
      begin     
        for (x = 0; x < 262144; x = x + 1)
           begin
             arr[x] <= 0;
             arr2[x] <= 0;
           end
        addr_p <= 0;  
        addr_pp <= 0;
        we_p <= 1;
        we_pp <= 1;         
        addr_p2 <= 0;  
        addr_pp2 <= 0;
        we_p2 <= 1;
        we_pp2 <= 1;
      end
    else
      begin
        addr_p <= addr;
        addr_pp <= addr_p;
        we_p <= we;
        we_pp <= we_p;
        addr_p2 <= addr2;
        addr_pp2 <= addr_p2;
        we_p2 <= we2;
        we_pp2 <= we_p2;
        
        if(we_pp2)
         begin
           $display("SRAM2 top.v: index %d reading %d", addr_pp2, arr2[addr_pp2]);          
         end   
        else
         begin
           $display("SRAM2 top.v: index %d writing %d", addr_pp2, data_out2);
           arr2[addr_pp2] <= data_out2;
         end

        if(we_pp)
         begin
           $display("SRAM1 top.v: index %d reading %d", addr_pp, arr[addr_pp]);          
         end   
        else
         begin
           $display("SRAM1 top.v: index %d writing %d", addr_pp, data_out);
           arr[addr_pp] <= data_out;
         end
      end
  end

initial 
  begin
    clk = 0;
    rst = 0;
    @(posedge clk);
    @(posedge clk);
    rst = 1;
    #100000;
  end


endmodule

