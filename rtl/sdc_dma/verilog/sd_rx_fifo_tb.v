// module name
`define MODULE_NAME sd_rx_fifo


module sd_rx_fifo_tb ( );
 
 
   reg [4-1:0] d;
   reg wr;
   reg wclk;
   wire [32-1:0] q;
   reg rd;
   wire fe;
   reg rclk;
   reg rst;
   wire  empty;
   reg [31:0] slask;
   wire [1:0] mem_empt;
  sd_rx_fifo sd_rx_fifo_1(
   .d (d),
   .wr (wr),
   .wclk (wclk),
   .q (q),
   .rd (rd),
   .full (fe),
   .empty (empty),
   .mem_empt (mem_empt),
   .rclk (rclk),
   .rst (rst)
   );


event reset_trigger; 
event  reset_done_trigger; 
event start_trigger;
event start_done_trigger; 

reg [3:0] send [16:0];
reg [3:0] send_c;
reg start;
reg sw;
initial 
   begin 
     wclk=0;
     rst=0;
     rclk=0;
     d =0;
     rst=0;
     wr=0;
     #5 ->reset_trigger;
     send [0] = 4'ha;
     send [1] = 4'hb;
     send [2] = 4'hc;
     send [3] = 4'hd;
     send [4] = 4'he;
     send [5] = 4'hf;
     send [6] = 4'hd;
     send [7] = 4'hc;
     send [8] = 4'hf;
     send [9] = 4'he;
     send [10] = 4'hd;
     send [11] = 4'hc;
     send [12] = 4'hb;
     send [13] = 4'ha;
     send [14] = 4'ha;
     send [15] = 4'hb;
     send_c =0;
     sw=0;
     start=0;
end


always begin
  #5 rclk = !rclk;
 end

always begin
  #10 wclk = !wclk;
 end



 initial begin 
    forever begin 
      @ (reset_trigger); 
      @ (posedge wclk); 
      rst =1 ; 
      @ (posedge wclk); 
      rst = 0; 
      #20
      start=1;
      -> reset_done_trigger; 
    end 
  end

always @ (posedge rclk)
if (!empty) begin
  
     rd=1;
    slask =q; 
    
end
else 
  rd=0;
    
always @ (posedge wclk)
begin
if(start)
   sw=~sw;
   if (sw) begin
   d=send[send_c];
   wr=1;
   send_c=send_c+1;  end
   else begin
     wr=0;
   end 
   
   
 //  if (!rd) begin
  //    @ (posedge rclk);
//       slask =q; 
//   rd=1;
//  @ (posedge rclk);
//   rd=0;
//  end
end    
endmodule  

