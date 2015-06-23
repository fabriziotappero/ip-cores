/////////////////////////////////////////////////////////////////////
////                                                             ////
////  				GCM-AES Top Module                           ////
////                                                             ////
////                                                             ////
////  Author: Tariq Bashir Ahmad and Guy Hutchison               ////
////          tariq.bashir@gmail.com                             ////
////          ghutchis@gmail.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/				  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 	 Tariq Bashir Ahmad and 			 ////	
////                         Guy Hutchison						 ////
////                         http://www.ecs.umass.edu/~tbashir   ////
////                                                			 ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

`define SIZE 128

module gcm_aes_v0(
	          input clk,
	          input rst,

	          /* DATA Input Interface (dii) */
	          input [`SIZE-1:0] dii_data,
	          input dii_data_vld,
	          input dii_data_type,
	          output reg dii_data_not_ready,
	          input dii_last_word,
                  input [3:0] dii_data_size,

	          /* Control Input Interface */
	          input cii_ctl_vld,  			//acts as start signal
	          input cii_IV_vld,
                  input [`SIZE-1:0] cii_K,


	          /* Data Output Interface */
	          output reg [`SIZE-1:0] Out_data,
	          output reg Out_vld,
                  output reg [3:0] Out_data_size,
                  output reg Out_last_word,

	          /* Tag output Interface */
	          output reg  Tag_vld

	          );
  



  
  //actual registers
  reg [`SIZE-1:0]             H, nxt_H, EkY0, nxt_EkY0, Yi, Yi_init;
  reg [`SIZE-1:0]             gfm_result;
  reg [63:0]                  enc_byte_cnt, aad_byte_cnt;

  reg                         nxt_Out_vld, nxt_Tag_vld;

  reg [`SIZE-1:0]             dii_data_star, nxt_Out_data_star;
  
  //wires
  reg [`SIZE-1:0]             nxt_Out_data, nxt_Tag_data;

  //aes signals
  reg [`SIZE-1:0]             aes_text_in;
  reg                         aes_kld;
  wire                        aes_done;
  wire [`SIZE-1:0]            aes_text_out;
  
  //control signals
  reg                         mux_aes_text_in_sel, mux_yi_sel;

  //gfm signals
  reg  [`SIZE-1:0]             v_in, z_in,b_in, gfm_input1;
  wire [`SIZE-1:0]             z_out, v_out;
  reg [3:0]                    gfm_cnt;

  //write enables
  reg                          we_y, we_lenA, we_lenC, start_gfm_cnt;
  
  
  //FSM signals
  reg [9:0]                   state, nxt_state;
  
  parameter          IDLE          = 10'd1,
                     ENCRYPT_0     = 10'd2,
                     INIT_COUNTER  = 10'd4,
                     ENCRYPT_Y0    = 10'd8,
                     DATA_ACCEPT   = 10'd16,
                     GFM_MULT      = 10'd32,
                     INC_COUNTER   = 10'd64,
                     M_ENCRYPT     = 10'd128,
                     PRE_TAG_CALC  = 10'd256,
                     TAG_CALC      = 10'd512;
  
             


 
  

  always @*
    begin
      dii_data_star = 0;
      case(dii_data_size)
        0:  // 1 valid byte
          begin
            dii_data_star = ({dii_data[7:0],120'b0});
          end
        1: //2 valid bytes
          begin
            dii_data_star = {dii_data[15:0],112'b0};
          end
        2: //3 valid bytes
          begin
            dii_data_star = {dii_data[23:0],104'b0};
          end
        3: //4 valid bytes
          begin
            dii_data_star = {dii_data[31:0],96'b0};
          end
        4: //5 valid bytes
          begin
            dii_data_star = {dii_data[39:0],88'b0};
          end
        5: //6 valid bytes
          begin
            dii_data_star = {dii_data[47:0],80'b0};
          end
        6: //7 valid bytes
          begin
            dii_data_star = {dii_data[55:0],72'b0};
          end
        7: //8 valid bytes
          begin
            dii_data_star = {dii_data[63:0],64'b0};
          end
        8:
          begin
            dii_data_star = {dii_data[71:0],56'b0};
          end
        9:
          begin
            dii_data_star = {dii_data[79:0],48'b0};
          end
        10:
          begin
            dii_data_star = {dii_data[87:0],40'b0};
          end
        11:
          begin
            dii_data_star = {dii_data[95:0],32'b0};
          end
        12:
          begin
            dii_data_star = {dii_data[103:0],24'b0};
          end
        13:	//14 valid bytes
          begin
	    dii_data_star = ({dii_data[111:0],16'b0});
          end
        14: //15 valid bytes
          begin
            dii_data_star = {dii_data[119:0],8'b0};
          end
      endcase
      
    end

  always @*
    begin
      nxt_Out_data_star = 0;
      case(dii_data_size)
        0:  //1 valid byte
          begin
            nxt_Out_data_star = {nxt_Out_data[127:120],120'b0};
          end
        1:// 2 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:112],112'b0};
          end
        2:// 3 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:104],104'b0};
          end
        3:// 4 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:96],96'b0};
          end
        4:// 5 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:88],88'b0};
          end
        5:// 6 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:80],80'b0};
          end
        6:// 7 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:72],72'b0};
          end
        7:// 8 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:64],64'b0};
          end
        8:// 9 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:56],56'b0};
          end
        9:// 10 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:48],48'b0};
          end
        10:// 11 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:40],40'b0};
          end
        11:  // 12 valid byte
          begin
            nxt_Out_data_star = {nxt_Out_data[127:32],32'b0};
          end
        12:// 13 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:24],24'b0};
          end
        13:// 14 valid bytes
          begin
            nxt_Out_data_star = {nxt_Out_data[127:16],16'b0};
          end
        14:  // 15 valid byte
          begin
            nxt_Out_data_star = {nxt_Out_data[127:8],8'b0};
          end
        
      endcase // case (dii_data_size)
    end
  
  
  always @(posedge clk or posedge rst)
    if(rst)
      begin
        state  <= #1 IDLE;
        H       <= #1 0;
        EkY0    <= #1 0;
      end
    else
      begin
        H     <= #1 nxt_H;
        EkY0  <= #1 nxt_EkY0;
        state <= #1 nxt_state;
      end


  //out data
   always @(posedge clk)
    begin
      if(nxt_Out_vld & ~nxt_Tag_vld)
        begin
          Out_data 		<= #1 nxt_Out_data;
          Out_data_size <= #1 dii_data_size;
          Out_last_word <= #1 dii_last_word;
        end
      else if(nxt_Tag_vld)
	Out_data <= #1 nxt_Tag_data;
      
      Tag_vld <= #1 nxt_Tag_vld;
      Out_vld <= #1 nxt_Out_vld;
   end
  
 /* always @(posedge clk)
    begin
      if(nxt_Out_vld)
        begin
          Out_data <= #1 nxt_Out_data;
          Out_data_size <= #1 dii_data_size;
          Out_last_word    <= #1 dii_last_word;
        end
      Out_vld <= #1 nxt_Out_vld;
     
    end
	 
  
  always @(posedge clk)
    begin
      if(nxt_Tag_vld)
        Out_data <= #1 nxt_Tag_data;
      
      Tag_vld <= #1 nxt_Tag_vld;
    end
  */

 //aes text_in
  always @*
    begin
      aes_text_in = 0;
      case(mux_aes_text_in_sel)
        0: aes_text_in = 0;
        
        1: aes_text_in = Yi;
        
      endcase
    end
  

  //initializing Yi_init
  always @*
    begin
      Yi_init = 0;
      if(cii_IV_vld)
        begin
          Yi_init = dii_data;
        end
    end

  
  //FSM
  always @*
    begin
      //list of defaults
      nxt_state = state;
      we_y = 0;
      we_lenA = 0;
      we_lenC = 0;
      dii_data_not_ready = 1;
      aes_kld = 0;
      mux_aes_text_in_sel = 0;
      mux_yi_sel = 0;
      start_gfm_cnt = 0;
      nxt_H = H;
      nxt_EkY0 = EkY0;
      nxt_Out_vld           = 0;			
      nxt_Tag_vld           = 0;
      gfm_input1 = 0;
      nxt_Out_data = 0;
      nxt_Tag_data = 0;

      case(state)
        IDLE:
          begin
        //  $display($time,": In IDLE\n");
            if(cii_ctl_vld)
              begin
                aes_kld = 1;
                mux_aes_text_in_sel = 0;
                nxt_state = ENCRYPT_0;
              end
          end

        ENCRYPT_0:
          begin
            if(aes_done)
              begin
                nxt_H = aes_text_out;
                if(cii_IV_vld)
                  begin
                    we_y = 1;
                    nxt_state = INIT_COUNTER;
                  end
              end
          end // case: ENCRYPT_0

        INIT_COUNTER:
          begin
			   // figure out how to launch a GCM op here,
				// or go to next state which launches GCM op
            mux_aes_text_in_sel = 1;
            aes_kld = 1;
            nxt_state = ENCRYPT_Y0;
          end


        ENCRYPT_Y0:
          begin
            if(aes_done)
              begin
                nxt_EkY0 = aes_text_out;
                nxt_state = DATA_ACCEPT;
              end
          end

        DATA_ACCEPT:
          begin
            dii_data_not_ready = 0;
            if(dii_data_vld & dii_data_type)   //AAD
              begin
                if(dii_data_size == 4'd15)
                  begin
                    we_lenA      = 1;
                    gfm_input1    = dii_data;
                    start_gfm_cnt = 1;
                    nxt_state     = GFM_MULT;
                  end
                else
                  begin
                    we_lenA      = 1;
                    gfm_input1    = dii_data_star; //note star
                    start_gfm_cnt = 1;
                    nxt_state     = GFM_MULT;
                  end
              end
            else if(dii_data_vld & ~dii_data_type) //ENC
              begin
                mux_yi_sel = 1;
                we_y = 1;
                nxt_state = INC_COUNTER;
              end
          end // case: AAD_ACCEPT

        INC_COUNTER:
          begin
            we_lenC = 1;
            mux_aes_text_in_sel = 1;
            aes_kld = 1;
            nxt_state = M_ENCRYPT;
          end

        GFM_MULT:
          begin
            if(gfm_cnt == 4'd7)
              begin
                start_gfm_cnt = 0;
                if(~dii_last_word)
                  nxt_state = DATA_ACCEPT;
                else
                  nxt_state = PRE_TAG_CALC;
              end
          end

        M_ENCRYPT:
          begin
            if(aes_done)
              begin
                if(dii_data_size == 4'd15)
                  begin
                    nxt_Out_data = aes_text_out ^ dii_data;
                    nxt_Out_vld  = 1;
                    gfm_input1 = nxt_Out_data;
                  end
                else
                  begin
                    nxt_Out_data = aes_text_out ^ dii_data_star;
                    nxt_Out_vld  = 1;
                    gfm_input1 = nxt_Out_data_star;
                  end
                start_gfm_cnt = 1;
                nxt_state = GFM_MULT;
              end
          end // case: M_ACCEPT

        PRE_TAG_CALC:
          begin
            gfm_input1 = {(aad_byte_cnt << 3),(enc_byte_cnt << 3)};
            start_gfm_cnt = 1;
            nxt_state = TAG_CALC;
          end

        TAG_CALC:
          begin
            if(gfm_cnt == 4'd7)
              begin
                start_gfm_cnt = 0;
                nxt_Tag_data = EkY0 ^ z_out;
                nxt_Tag_vld  = 1'b1;
                nxt_state = IDLE;
              end
          end
        
      endcase
      
    end
  


  
  
  always @(posedge clk)
    if(we_y)
      case(mux_yi_sel)
        0: Yi <= #1 Yi_init;
        1: Yi <= #1 Yi + 1;
      endcase 
  
  always @(posedge clk or posedge rst)
    if(rst)
      enc_byte_cnt <= #1 0;
    else if(we_lenC)
      enc_byte_cnt <= #1 enc_byte_cnt + dii_data_size + 1;
  
  always @(posedge clk or posedge rst)
    if(rst)
      aad_byte_cnt <= #1 0;
    else if(we_lenA)
      aad_byte_cnt <= #1 aad_byte_cnt + dii_data_size + 1;

  always @(posedge clk)
    if(start_gfm_cnt)
      gfm_cnt <= #1 4'd0;
    else if(gfm_cnt != 4'd7)
      gfm_cnt <= #1 gfm_cnt + 1;
 

  always @(posedge clk)
    if(cii_ctl_vld)
      gfm_result <= #1 0;
    else if(gfm_cnt == 4'd7)
      gfm_result <= #1 z_out;
      
  

  always @(posedge clk)
    if(start_gfm_cnt)
      begin
        v_in     <= #1 H; 
        z_in     <= #1 {`SIZE{1'b0}};
        b_in     <= #1 gfm_input1 ^ gfm_result;
      end
  
    else
      begin
        v_in <= #1 v_out;
        z_in <= #1 z_out;
        b_in <= #1 b_in << 16;
      end
  


  
   /*
    gfm128_16 AUTO_TEMPLATE
    (
    .v_out             (v_out[127:0]),
    .z_out             (z_out[127:0]),
    .v_in              (v_in[127:0]),
    .z_in              (z_in[127:0]),
    .b_in              (b_in[127:112]),
    );
    */


  gfm128_16      GFM(/*AUTOINST*/
                     // Outputs
                     .v_out             (v_out[127:0]),          // Templated
                     .z_out             (z_out[127:0]),          // Templated
                     // Inputs
                     .v_in              (v_in[127:0]),           // Templated
                     .z_in              (z_in[127:0]),           // Templated
                     .b_in              (b_in[127:112]));         // Templated


   /*
    aes_cipher_top AUTO_TEMPLATE
    (
    .done                (aes_done),
    .text_out            (aes_text_out[127:0]),
    .clk                 (clk),
    .rst                 (rst),
    .ld                  (aes_kld),
    .key                 (cii_K),
    .text_in             (aes_text_in[127:0]),
    );
    */
    
  aes_cipher_top  AES_ENC (/*AUTOINST*/
                           // Outputs
                           .done                (aes_done),      // Templated
                           .text_out            (aes_text_out[127:0]), // Templated
                           // Inputs
                           .clk                 (clk),           // Templated
                           .rst                 (rst),           // Templated
                           .ld                  (aes_kld),       // Templated
                           .key                 (cii_K),         // Templated
                           .text_in             (aes_text_in[127:0])); // Templated


  
  
endmodule
