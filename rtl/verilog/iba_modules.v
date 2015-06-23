
/*****************************************************************************/
// Id ..........iba_modules.v                                                 //
// Author.......Ran Minerbi                                                   //
//                                                                            //
//   Unit Description   :                                                     //
//    iba collect  frames from physical layer.                                //
//    Keeps payload of frames that received                                   //
//    And haven't been sent yet.                                              //
//    Iba save a copy of the payload and send                                 //
//    Packet descriptors to dcp unit.                                         //
//    Iba send frames to XBar upon receiving                                  //
//    READY signal from dpq module.                                           //
//                                                                            //                                                                        //
//                                                                            //
/*****************************************************************************/

  
module mem_units(reset,clk,Dw1_iba_i,mem_u_o1,headers_o1,start_length1,StartFrm1,EndFrm1,transmit_done1,adr_valid1,
                           Dw2_iba_i,mem_u_o2,headers_o2,start_length2,StartFrm2,EndFrm2,transmit_done2,adr_valid2,
                           Dw3_iba_i,mem_u_o3,headers_o3,start_length3,StartFrm3,EndFrm3,transmit_done3,adr_valid3,
                           Dw4_iba_i,mem_u_o4,headers_o4,start_length4,StartFrm4,EndFrm4,transmit_done4,adr_valid4,
                           Dw5_iba_i,mem_u_o5,headers_o5,start_length5,StartFrm5,EndFrm5,transmit_done5,adr_valid5,
                           Dw6_iba_i,mem_u_o6,headers_o6,start_length6,StartFrm6,EndFrm6,transmit_done6,adr_valid6                                
                  
                 );
    
   input reset, clk,StartFrm1,EndFrm1,
                    StartFrm2,EndFrm2,
                    StartFrm3,EndFrm3,
                    StartFrm4,EndFrm4,
                    StartFrm5,EndFrm5,
                    StartFrm6,EndFrm6;
            output  transmit_done1,
                    transmit_done2,
                    transmit_done3,
                    transmit_done4,
                    transmit_done5,
                    transmit_done6;
   input [31:0] Dw1_iba_i,Dw2_iba_i,Dw3_iba_i,Dw4_iba_i,Dw5_iba_i,Dw6_iba_i;
   output [31:0] mem_u_o1,mem_u_o2,mem_u_o3,mem_u_o4,mem_u_o5,mem_u_o6;
   output [31:0] headers_o1,headers_o2,headers_o3,headers_o4,headers_o5,headers_o6;
   input [15:0] start_length1,start_length2,start_length3,start_length4,start_length5,start_length6;//from DPQ
   input adr_valid1,adr_valid2,adr_valid3,adr_valid4,adr_valid5,adr_valid6;
   mem_basic_unit basic_mem1(.reset(reset),.clk(clk),.Dw_iba_i(Dw1_iba_i),.ram_do(mem_u_o1),.StartFrm(StartFrm1),.EndFrm(EndFrm1),.header_to_dcp(headers_o1),.start_length(start_length1),.transmit_done(transmit_done1),.adr_valid(adr_valid1));
   mem_basic_unit basic_mem2(.reset(reset),.clk(clk),.Dw_iba_i(Dw2_iba_i),.ram_do(mem_u_o2),.StartFrm(StartFrm2),.EndFrm(EndFrm2),.header_to_dcp(headers_o2),.start_length(start_length2),.transmit_done(transmit_done2),.adr_valid(adr_valid2));
   mem_basic_unit basic_mem3(.reset(reset),.clk(clk),.Dw_iba_i(Dw3_iba_i),.ram_do(mem_u_o3),.StartFrm(StartFrm3),.EndFrm(EndFrm3),.header_to_dcp(headers_o3),.start_length(start_length3),.transmit_done(transmit_done3),.adr_valid(adr_valid3));
   mem_basic_unit basic_mem4(.reset(reset),.clk(clk),.Dw_iba_i(Dw4_iba_i),.ram_do(mem_u_o4),.StartFrm(StartFrm4),.EndFrm(EndFrm4),.header_to_dcp(headers_o4),.start_length(start_length4),.transmit_done(transmit_done4),.adr_valid(adr_valid4));
   mem_basic_unit basic_mem5(.reset(reset),.clk(clk),.Dw_iba_i(Dw5_iba_i),.ram_do(mem_u_o5),.StartFrm(StartFrm5),.EndFrm(EndFrm5),.header_to_dcp(headers_o5),.start_length(start_length5),.transmit_done(transmit_done5),.adr_valid(adr_valid5));
   mem_basic_unit basic_mem6(.reset(reset),.clk(clk),.Dw_iba_i(Dw6_iba_i),.ram_do(mem_u_o6),.StartFrm(StartFrm6),.EndFrm(EndFrm6),.header_to_dcp(headers_o6),.start_length(start_length6),.transmit_done(transmit_done6),.adr_valid(adr_valid6));
                 
endmodule
   
module Complete_on_write(reset , clk , Dw_iba_i,ram_oe,ram_we,Completed_ram_do,same_DW_read,addr_valid);

     input reset, clk, ram_oe, ram_we;
     input [31:0] Dw_iba_i;
     output [31:0] Completed_ram_do;
     input  [2:0] same_DW_read;
     input  addr_valid;
     reg [31:0] Completed_ram_do  ;
     reg [31:0] delay_data_unit_1 , delay_data_unit_2;
      initial begin 
        delay_data_unit_1 = 32'h0;
        delay_data_unit_2 = 32'h0;
        xor_data = 0;
        cnt_fsm = 0;
        clk_cnt = 0;
     end
       reg xor_data;
     //this blk to solve the read mem with unvalid ram_addr 
       always @ (posedge clk)
       begin
        if (addr_valid == 1)
            begin
                delay_data_unit_1 <= Dw_iba_i;
                delay_data_unit_2<=delay_data_unit_1;
                xor_data <= |(delay_data_unit_1^Dw_iba_i);
            end
         else
            begin
                delay_data_unit_1 = 0;
                delay_data_unit_2 = 0;
            end 
       end
     //  
            reg [7:0]clk_cnt;
            reg [1:0]cnt_fsm; 
            always @(posedge clk)
             begin
               case (cnt_fsm)
                    2'h0: begin
                             if (xor_data ==1)
                                begin
                                    cnt_fsm = 1;
                                    clk_cnt = 0;
                                end                        
                          end
                    2'h1: begin
                            clk_cnt = clk_cnt+1;
                            if (xor_data == 1)
                              begin
                                 clk_cnt = 0;
                              end
                           end      
                endcase
             end
            
            reg [3:0] fsm_cycle;
       initial fsm_cycle =0 ;
       always @ (posedge clk)
       begin
           case (fsm_cycle)
               3'h0: begin
                  Completed_ram_do <= delay_data_unit_1;
                  if (ram_we==1)
                     begin
                       fsm_cycle = 1;
                     end
                  end
               3'h1: begin 
                        fsm_cycle = 2; 
                        Completed_ram_do <= delay_data_unit_2;
                        end
               3'h2: begin fsm_cycle = 3; end
               3'h3: begin fsm_cycle = 4; end
               3'h4: begin fsm_cycle = 5; end
               3'h5: begin fsm_cycle = 6; end
               3'h6: begin fsm_cycle = 7; end
               3'h7: begin fsm_cycle = 0; end
           endcase
       end
        
endmodule
   /* this unit should return 
      1. full packets by DPQ request - ram_do________________________________________
      2. header only to dcp - header_out   |___ 32 bit_-Dmac | length|start addr| 
      3. how to distinct in start addrs ?   every time it toggle ??
       start_length   {length 8bit  , start_adrr 8bit } 
      */ 
      module mem_basic_unit(reset , clk , Dw_iba_i , ram_do,StartFrm,EndFrm , header_to_dcp,start_length, transmit_done,adr_valid);   //add done from iba to dpq

        input StartFrm,EndFrm;
        input reset, clk;
        input [31:0] Dw_iba_i;
        input [15:0] start_length;
        input adr_valid;         // from dpq - request to release that addr
        output transmit_done;    // tell DPQ transmission completed for last request
        output [31:0] ram_do,header_to_dcp;
       wire  ram_ce ;
       reg   ram_oe , tst_reg;
       reg  ram_we, ram_we_pre,ram_oe_pre , headers_2_dcp_en , dmac_en;
       reg [7:0]   ram_addr ,w_ram_addr ;
       reg [31:0] Dmac_header,Dmac_header1 , header_to_dcp;
       wire [31:0] ram_do1 ;
       reg [7:0] header_out_length , header_out_start_addr, input_length , counter_length ;
       reg [2:0] same_DW_read_cnt , same_DW_free_cnt ;
       reg [3:0] fsm_state, counter_modulu8_fsm;
       reg transmit_done, increment_same_DW;
       reg read_arguments_valid,read_argumets_valid_delay_unit1,read_argumets_valid_delay_unit2, read_valid , div_2_clk,div_4_clk;
       reg ipg_out_mem;   // this bit indicate when we can start read again from mem.
       assign ram_ce = 1;
       //  assign  ram_do = Dw1_iba_i;
        initial begin
           ram_addr =0;
           w_ram_addr=0;
           header_out_length=0;
           counter_length=0;
           header_out_start_addr=0;
           dmac_en=1;
           transmit_done=0;
           read_arguments_valid=0;
           div_2_clk =0;
            div_4_clk =0;
            same_DW_read_cnt=0;
            ram_oe=0;
            increment_same_DW=0;
            same_DW_free_cnt = 0;
            ipg_out_mem = 0;
            fsm_state = 0; 
            read_valid=0;
            counter_modulu8_fsm=0;
         end
        reg [31:0] prev_input, xor_data ;
       always @ (posedge clk)
       begin
         div_2_clk = clk^div_2_clk;
         prev_input <= Dw_iba_i;

         ram_we <= |(prev_input^Dw_iba_i); //ram_we pulse every word change
         ram_oe <= (~|(prev_input^Dw_iba_i)) & read_argumets_valid_delay_unit1;
         read_argumets_valid_delay_unit1 <= read_arguments_valid;
         read_argumets_valid_delay_unit2 <=read_argumets_valid_delay_unit1;      
         end

       always @(posedge StartFrm)
       begin
          headers_2_dcp_en = 0;
          header_out_length = 0;
        end 
        always @ (negedge ram_we)
        begin
           header_out_length=header_out_length+1;
        end
        always @ (posedge EndFrm)
        begin
           headers_2_dcp_en=1;
           dmac_en=1;
        end
     //complete mem output upon write to mem interupts  
     Complete_on_write complete_on_write1(.reset(reset),.clk(clk),.Dw_iba_i(ram_do1),.ram_oe(ram_oe),.ram_we(ram_we),.Completed_ram_do(ram_do),.same_DW_read(same_DW_read_cnt),.addr_valid(read_argumets_valid_delay_unit2));
     //   | 32bit dmac | 16 bit dmac | 8 bit length| 8 bit start addr|
       //Go into write interval 
       always @ (posedge ram_we)    //write interval
        begin
            w_ram_addr = w_ram_addr +1;              //need better management on free mem when can write?
            ram_addr = w_ram_addr;
            if (header_out_length==0)
                begin
                    header_out_start_addr=ram_addr; //mark start_addr for dcp
                    Dmac_header=Dw_iba_i;           //take dmac for header to dcp
                 end
            if (header_out_length==1)
                begin
                    Dmac_header1=Dw_iba_i;        //take dmac for header to dcp
                 end     
            if (headers_2_dcp_en==1 && dmac_en==1)
                begin
                 header_to_dcp=Dmac_header;
                 dmac_en=0;
                end
                else if(headers_2_dcp_en==1 && dmac_en==0)
                    begin
                      header_to_dcp={Dmac_header1[31:16],header_out_length,header_out_start_addr};
                       headers_2_dcp_en=0;
                        dmac_en=1;
                     end    else  header_to_dcp=0;
        end

        // when ram_we go down we move back to read cycle.
        always @ (negedge   ram_we)
        begin
          
             if (  adr_valid ==1)
                 begin
                   ram_addr =  start_length[7:0] + counter_length;
                  end
                  else
                  begin
                      ram_addr = 8'hzz;    
                  end            
         end   
          

          


            //arguments are valid from DPQ . can start with reading from iba
        always @ (posedge adr_valid)
          begin
               counter_modulu8_fsm=0 ;    
            end  
            
        always @( posedge clk)
         begin
            
             same_DW_free_cnt <= same_DW_free_cnt + 1;
             if ( ram_oe == 1 && adr_valid ==1)
               begin
                     same_DW_read_cnt = same_DW_read_cnt + 1;
                     if (same_DW_read_cnt == 1 )
                         begin
                          increment_same_DW=1;
                          ipg_out_mem = 1;
                         end
               end                                                 
                                                                       
        end 
         
        always @(posedge clk)
         begin
             case (counter_modulu8_fsm)
                 3'h0: begin
                     if (read_arguments_valid == 1)
                         begin
                              counter_modulu8_fsm = 1;
                            //  counter_length <= counter_length + 1;
                          end
                     end

                  3'h1: begin
                     if (read_arguments_valid == 1)
                           counter_length = counter_length + 1;
                         begin
                              counter_modulu8_fsm = 2;
                              ram_addr =  start_length[7:0] + counter_length -1;
                          end
                     end

                3'h2: begin
                    if (read_arguments_valid == 1)
                        begin
                             counter_modulu8_fsm = 3;
                         end
                    end

                 3'h3: begin
                    if (read_arguments_valid == 1)
                        begin
                             counter_modulu8_fsm = 4;
                         end
                    end   
                   3'h4: begin                          
                      if (read_arguments_valid == 1)    
                          begin                         
                               counter_modulu8_fsm = 5; 
                           end                          
                      end                               
                                                        
                 3'h5: begin                            
                     if (read_arguments_valid == 1)     
                         begin                          
                              counter_modulu8_fsm = 6;  
                          end                           
                     end                                
                                                        
                  3'h6: begin                           
                     if (read_arguments_valid == 1)     
                         begin                          
                              counter_modulu8_fsm = 7;  
                          end                           
                     end                                

                   3'h7: begin                           
                     if (read_arguments_valid == 1)     
                         begin                          
                              counter_modulu8_fsm = 0;  
                          end                           
                     end
                                             
             endcase
         end
         
        //fsm new
        always @(posedge clk)
        begin
          case (fsm_state)
              3'h0: begin            //  not started
                     transmit_done = 0;  
                     counter_length = 0; 
                    if (adr_valid == 1)
                        begin
                            fsm_state = 1;
                       
                            read_arguments_valid =1;
                        end                        
                  end
              3'h1: begin            //  transmitting
                    transmit_done = 0;  
                 
                     if (same_DW_free_cnt == 0)
                         begin
                     
                         end
                    if (ram_addr ==start_length[15:8]+start_length[7:0] )   
                       begin
                          read_arguments_valid =0;
                          increment_same_DW=0;
                          fsm_state = 2;
                        end
                    end
              3'h2: begin            //  pending1
                      transmit_done = 1;                      
                      fsm_state = 3;                                                   
                    end
               3'h3: begin            //  pending2
                      transmit_done = 1;                      
                      fsm_state = 4;                                                   
                    end
      
              3'h4: begin            //  pending3
                      transmit_done = 1;    
                      fsm_state = 0;
                            
                   //     end
                    end      
                        
          endcase
        end


                
        eth_spram_256x32
             mem1
             (
              .clk     (~clk),
              .rst     (reset),             
              .ce      (ram_ce),                                                                                         // Chip enable input, active high   
              .we      ({ram_we ,ram_we ,ram_we,ram_we }),      // Write enable input, active high  
              .oe      (ram_oe),                                                                                         // Output enable input, active high 
              .addr    (ram_addr),                                                                                       // address bus inputs               
              .di      (Dw_iba_i),                                                                                      // input data bus                   
              .dato    (ram_do1)                                                                                        // output data bus                
        `ifdef ETH_BIST
              ,
              .mbist_si_i       (0),
              .mbist_so_o       (0),
              .mbist_ctrl_i       (0)
        `endif
              );
         

    
endmodule
