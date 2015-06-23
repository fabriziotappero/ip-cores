module encoder
(
   clk,
   rst,
   enable_i,
   d_in,
   valid_o,
   d_out
);
   input             clk;
   input             rst;
   input             enable_i;
   input             d_in;
   output reg        valid_o;
   output      [1:0] d_out;
   
   reg         [2:0] cstate;
   reg         [2:0] nstate;
   
   reg         [1:0] d_out_reg;

   assign   d_out    =  (enable_i==1'b1)?d_out_reg:2'b00;
     

   always @(*) begin
      valid_o  =   enable_i;
      case (cstate)
         3'b000:
         begin
            if(d_in==1'b0)
            begin
               nstate   =  3'b000;
               d_out_reg    =  2'b00;
            end
            else
            begin
               nstate   =  3'b100;
               d_out_reg    =  2'b11;
            end
         end
         3'b001:
         begin
            if(d_in==1'b0)
            begin
               nstate   =  3'b100;
               d_out_reg    =  2'b00;
            end
            else
            begin
               nstate   =  3'b000;
               d_out_reg    =  2'b11;
            end
         end
         3'b010:
         begin
            if(d_in==1'b0)
            begin
               nstate   =  3'b101;
               d_out_reg    =  2'b10;
            end
            else
            begin
               nstate   =  3'b001;
               d_out_reg    =  2'b01;
            end
         end
         3'b011:
         begin
            if(d_in==1'b0)
            begin
               nstate   =  3'b001;
               d_out_reg    =  2'b10;
            end
            else
            begin
               nstate   =  3'b101;
               d_out_reg    =  2'b01;
            end
         end
         3'b100:
         begin
            if(d_in==1'b0)
            begin
               nstate   =  3'b010;
               d_out_reg    =  2'b10;
            end
            else
            begin
               nstate   =  3'b110;
               d_out_reg    =  2'b01;
            end
         end
         3'b101:
         begin
            if(d_in==1'b0)
            begin
               nstate   =  3'b110;
               d_out_reg    =  2'b10;
            end
            else
            begin
               nstate   =  3'b010;
               d_out_reg    =  2'b01;
            end
         end
         3'b110:
         begin
            if(d_in==1'b0)
            begin
               nstate   =  3'b111;
               d_out_reg    =  2'b00;
            end
            else
            begin
               nstate   =  3'b011;
               d_out_reg    =  2'b11;
            end
         end
         3'b111:
         begin
            if(d_in==1'b0)
            begin
               nstate   =  3'b011;
               d_out_reg    =  2'b00;
            end
            else
            begin
               nstate   =  3'b111;
               d_out_reg    =  2'b11;
            end
         end

      endcase
   end



   always @ (posedge clk,negedge rst) 
   begin
//      $display("data in=%d state=%b%b%b data out=%b%b",d_in,reg_1,reg_2,reg_3,d_out_reg[1],d_out_reg[0]);
      if(rst==1'b0)
         cstate   <= 3'b000;
      else if(enable_i==1'b0)
         cstate   <= 3'b000;
      else
         cstate   <= nstate;
   end
   


endmodule
