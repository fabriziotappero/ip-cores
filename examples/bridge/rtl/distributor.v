module distributor
  (input         clk,
   input         reset,

   input         ptx_srdy,
   output        ptx_drdy,
   input [`PFW_SZ-1:0] ptx_data,

   output        p_srdy,
   input         p_drdy,
   output [1:0]  p_code,
   output [7:0]  p_data
   );

  reg [7:0]	ic_data;
  reg [1:0]     ic_code;
  wire          ic_drdy;
  reg           ic_srdy;
  wire [`PFW_SZ-1:0] ip_data;
  reg                ip_drdy;
  wire               ip_srdy;
  reg [7:0]          remain, nxt_remain;

  sd_input #(`PFW_SZ) sdin
    (
     // Outputs
     .c_drdy				(ptx_drdy),
     .ip_srdy				(ip_srdy),
     .ip_data				(ip_data),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(ptx_srdy),
     .c_data				(ptx_data),
     .ip_drdy				(ip_drdy));

  always @*
    begin
      nxt_remain = remain;
      ic_srdy = 0;
      ip_drdy = 0;

      case (remain)
        0 : ic_data = ip_data[63:56];
        7 : ic_data = ip_data[55:48];
        6 : ic_data = ip_data[47:40];
        5 : ic_data = ip_data[39:32];
        4 : ic_data = ip_data[31:24];
        3 : ic_data = ip_data[23:16];
        2 : ic_data = ip_data[15: 8];
        1 : ic_data = ip_data[ 7: 0];
        default : ic_data = ip_data[63:56];
      endcase
      
      if (ip_srdy & ic_drdy)
        begin
          if (remain == 0)
            begin
              ic_srdy = 1;
              if (ip_data[`PRW_VALID] == 0)
                nxt_remain = 7;
              else
                nxt_remain = ip_data[`PRW_VALID]-1;
              
              if (nxt_remain == 0)
                ip_drdy = 1;
              
              if (ip_data[`PRW_PCC] == `PCC_SOP)
                ic_code = `PCC_SOP;
              else
                ic_code = `PCC_DATA;
            end // if (remain == 0)
          else
            begin
              ic_srdy = 1;
              nxt_remain = remain - 1;
              if (nxt_remain == 0)
                begin
                  ip_drdy = 1;
                  if ((ip_data[`PRW_PCC] == `PCC_EOP) |
                      (ip_data[`PRW_PCC] == `PCC_BADEOP))
                    ic_code = ip_data[`PRW_PCC];
                  else
                    ic_code = `PCC_DATA;
                end
              else
                ic_code = `PCC_DATA;
            end // else: !if(remain == 0)
        end
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
        remain <= #1 0;
      else
        remain <= #1 nxt_remain;
    end

  sd_output #(8+2) sdout
    (
     // Outputs
     .ic_drdy				(ic_drdy),
     .p_srdy				(p_srdy),
     .p_data				({p_code,p_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .ic_srdy				(ic_srdy),
     .ic_data				({ic_code,ic_data}),
     .p_drdy				(p_drdy));

endmodule // template_1i1o

// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/memory" "../../../rtl/verilog/forks")
// End:  
