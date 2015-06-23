module ACS
(
   path_0_valid,
   path_1_valid,
   path_0_bmc,
   path_1_bmc,
   path_0_pmc,
   path_1_pmc,
   selection,
   valid_o,
   path_cost
);
   input       path_0_valid;
   input [1:0] path_0_bmc;
   input [7:0] path_0_pmc;

   input       path_1_valid;
   input [1:0] path_1_bmc;
   input [7:0] path_1_pmc;

   output reg        selection;
   output reg        valid_o;
   output      [7:0] path_cost;  


   wire  [7:0] path_cost_0;
   wire  [7:0] path_cost_1;

   assign path_cost_0  =  path_0_bmc + path_0_pmc;
   assign path_cost_1  =  path_1_bmc + path_1_pmc;

   assign path_cost      =  (valid_o?(selection?path_cost_1:path_cost_0):7'd0);   


   always @ (*)
   begin
      valid_o = 1'b1;

      case({path_0_valid,path_1_valid})
         2'b00:
         begin
            selection = 1'b0;
            valid_o   = 1'b0; 
         end
         2'b01:   selection = 1'b1;
         2'b10:   selection = 1'b0;
         2'b11:   selection = (path_cost_0 > path_cost_1)?1'b1:1'b0;
       endcase
   end
   

endmodule
