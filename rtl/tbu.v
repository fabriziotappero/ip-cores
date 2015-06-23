module tbu
(
   clk,
   rst,
   enable,
   selection,
   d_in_0,
   d_in_1,
   d_o,
   wr_en
);

   input       clk;
   input       rst;
   input       enable;
   input       selection;
   input [7:0] d_in_0;
   input [7:0] d_in_1;
   output reg  d_o;
   output reg  wr_en;


   reg         d_o_reg;
   reg         wr_en_reg;

   
   reg   [2:0] pstate;
   reg   [2:0] nstate;

   reg         selection_buf;

   always @(posedge clk)
   begin
      selection_buf  <= selection;
      wr_en          <= wr_en_reg;
      d_o            <= d_o_reg;
   end
   always @(posedge clk or negedge rst)
   begin
      if(rst==1'b0)
         pstate   <= 3'b000;
      else if(enable==1'b0)
         pstate   <= 3'b000;
      else if(selection_buf==1'b1 && selection==1'b0)
         pstate   <= 3'b000;
      else
         pstate   <= nstate;
   end


   always @(*)
   begin
      case (pstate)
         3'b000:
         begin
            if(selection==1'b0)
            begin
               wr_en_reg =  1'b0;
               case(d_in_0[0])
                  1'b0: nstate   =  3'b000;
                  1'b1: nstate   =  3'b001;
               endcase
            end
            else
            begin
               d_o_reg   =  d_in_1[0];  
               wr_en_reg =  1'b1;
               case(d_in_1[0])
                  1'b0: nstate   =  3'b000;
                  1'b1: nstate   =  3'b001;
               endcase
           end
         end

         3'b001:
         begin
            if(selection==1'b0)
             begin
             wr_en_reg =  1'b0;
               case(d_in_0[1])
                  1'b0: nstate   =  3'b011;
                  1'b1: nstate   =  3'b010;
               endcase
            end
            else
            begin
               d_o_reg   =  d_in_1[1];  
               wr_en_reg =  1'b1;
               case(d_in_1[1])
                  1'b0: nstate   =  3'b011;
                  1'b1: nstate   =  3'b010;
               endcase
           end
         end

         3'b010:
         begin
            if(selection==1'b0)
            begin
               wr_en_reg =  1'b0;
               case(d_in_0[2])
                  1'b0: nstate   =  3'b100;
                  1'b1: nstate   =  3'b101;
               endcase
            end
            else
            begin
               d_o_reg   =  d_in_1[2];  
               wr_en_reg =  1'b1;
               case(d_in_1[2])
                  1'b0: nstate   =  3'b100;
                  1'b1: nstate   =  3'b101;
               endcase
            end
         end

         3'b011:
         begin
            if(selection==1'b0)
            begin
               wr_en_reg =  1'b0;
               case(d_in_0[3])
                  1'b0: nstate   =  3'b111;
                  1'b1: nstate   =  3'b110;
               endcase
            end
            else
            begin
               d_o_reg   =  d_in_1[3]; 
               wr_en_reg =  1'b1;
               case(d_in_1[3])
                  1'b0: nstate   =  3'b111;
                  1'b1: nstate   =  3'b110;
               endcase
            end
         end

         3'b100:
         begin
            if(selection==1'b0)
            begin
               wr_en_reg =  1'b0;
               case(d_in_0[4])
                  1'b0: nstate   =  3'b001;
                  1'b1: nstate   =  3'b000;
               endcase
            end
            else
            begin
               d_o_reg   =  d_in_1[4];  
               wr_en_reg =  1'b1;
               case(d_in_1[4])
                  1'b0: nstate   =  3'b001;
                  1'b1: nstate   =  3'b000;
               endcase
            end
         end

         3'b101:
         begin
            if(selection==1'b0)
            begin
               wr_en_reg =  1'b0;
               case(d_in_0[5])
                  1'b0: nstate   =  3'b010;
                  1'b1: nstate   =  3'b011;
               endcase
            end
            else
            begin
               d_o_reg   =  d_in_1[5];  
               wr_en_reg =  1'b1;
               case(d_in_1[5])
                  1'b0: nstate   =  3'b010;
                  1'b1: nstate   =  3'b011;
               endcase
            end
         end

         3'b110:
         begin
            if(selection==1'b0)
            begin
               wr_en_reg =  1'b0;
               case(d_in_0[6])
                  1'b0: nstate   =  3'b101;
                  1'b1: nstate   =  3'b100;
               endcase
            end
            else
            begin
               d_o_reg   =  d_in_1[6];  
               wr_en_reg =  1'b1;
               case(d_in_1[6])
                  1'b0: nstate   =  3'b101;
                  1'b1: nstate   =  3'b100;
               endcase
            end
         end

         3'b111:
         begin
            if(selection==1'b0)
            begin
               wr_en_reg =  1'b0;
               case(d_in_0[7])
                  1'b0: nstate   =  3'b110;
                  1'b1: nstate   =  3'b111;
               endcase
            end
            else
            begin
               d_o_reg   =  d_in_1[7];  
               wr_en_reg =  1'b1;
               case(d_in_1[7])
                  1'b0: nstate   =  3'b110;
                  1'b1: nstate   =  3'b111;
               endcase
            end
         end
      endcase
   end

endmodule
