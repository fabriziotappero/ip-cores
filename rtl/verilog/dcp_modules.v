
/*****************************************************************************/
// Id ..........dcp_modules.v                                                 //
// Author.......Ran Minerbi                                                   //
//                                                                            //
//   Unit Description   :                                                     //
//     dcp unit receive frames descriptors                                    //
//     from iba, determine destination port                                   //
//     according to frame MAC Address.                                        //
//                                                                            //
/*****************************************************************************/


   module Header_parser(reset,clk,header_i,Dmac,Start_addr);
         input reset, clk;
         input [31:0] header_i;
         output[47:0] Dmac;
         output [15:0] Start_addr;

         reg [15:0] Start_addr;
         reg [31:0] header_prev;
         reg [47:0] Dmac;
         reg [1:0]  state; // 0 - state 0 , 1- state dmac , 2 - state length/addr
         reg flip;
         initial 
         begin
           state=0;
           Dmac=0;
           flip=0;
           Start_addr=0;
         end
         always @ (posedge clk)
         begin
             header_prev<= header_i;
             flip=|(header_prev ^ header_i);
                                   
         end

         always @( negedge flip)
         begin
               case (state)
                   2'h0:  state=1;
                   2'h1:  begin
                          state=2;
                          Dmac[47:16] = header_i;
                         end
                   2'h2:  begin
                          state=0;
                          Start_addr=header_i[15:0];
                          Dmac[15:0] = header_i[31:16];
                          end 
                endcase 
          end
             
   endmodule

   module FDB(reset,clk,dmac,T_q);
        input reset, clk;
        input [47:0] dmac;
        output [4:0] T_q;

        reg  [4:0] T_q;
        initial  T_q=0;
        always @ (posedge clk)
        begin
            case (dmac)
                48'haa2030405060: T_q=1;
                48'hffccbb440011: T_q=2;
                48'hddffbb550022: T_q=3; 
                48'hccbbaa990099: T_q=4; 
                48'h66eecc001133: T_q=5; 
                48'h1100aaff00aa: T_q=6; 
                default: T_q=0;
            endcase
            
            end
        
   endmodule

