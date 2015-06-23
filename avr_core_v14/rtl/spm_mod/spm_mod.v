//**********************************************************************************************
// PM/Fuse write support
// Version 0.6
// Modified 08.01.2007
// Designed by Ruslan Lepetenok
//**********************************************************************************************

`timescale 1 ns / 1 ns

module spm_mod(
               ireset, 
               cp2, 
	       adr, 
	       dbus_in, 
	       dbus_out, 
	       iore, 
	       iowe, 
	       io_out_en, 
	       ramadr, 
	       dm_dbus_in, 
	       dm_dbus_out, 
	       ramre, ramwe, 
	       dm_sel, 
	       cpuwait, 
	       dm_out_en, 
	       spm_out, 
	       spm_inst, 
	       spm_wait, 
	       spm_irq, 
	       spm_irq_ack, 
	       rwwsre_op, 
	       blbset_op, 
	       pgwrt_op, 
	       pgers_op, 
	       spmen_op, 
	       rwwsre_rdy, 
	       blbset_rdy, 
	       pgwrt_rdy, 
	       pgers_rdy, 
	       spmen_rdy
	       );

`include "avr_adr_pack.vh"
`include "bit_def_pack.vh"

   parameter                 use_dm_loc = 0;
   parameter                 csr_adr = 8'h68 /*SPMCSR_Address*/; // !!!TBC!!!

   // AVR Control
   input                     ireset;
   input                     cp2;
   // I/O 
   input [5:0]               adr;
   input [7:0]               dbus_in;
   output [7:0]              dbus_out;
   input                     iore;
   input                     iowe;
   output                    io_out_en;
   // DM
   input [7:0]               ramadr;
   input [7:0]               dm_dbus_in;
   output [7:0]              dm_dbus_out;
   input                     ramre;
   input                     ramwe;
   input                     dm_sel;
   output                    cpuwait;
   output                    dm_out_en;
   //
   input [15:0]              spm_out;
   input                     spm_inst;
   output                    spm_wait;
   // IRQ
   output                    spm_irq;
   input                     spm_irq_ack;
   //
   output                    rwwsre_op;
   output                    blbset_op;
   output                    pgwrt_op;
   output                    pgers_op;
   output                    spmen_op;
   //
   input                     rwwsre_rdy;
   input                     blbset_rdy;
   input                     pgwrt_rdy;
   input                     pgers_rdy;
   input                     spmen_rdy;
   
   reg                       spmie_current;
   reg                       spmie_next;
   
   wire                      spmcsr_wr;
   wire                      spmcsr_rd;
   
   parameter [2:0]           spm_sm_st_type_idle_st     = 0,
                             spm_sm_st_type_wait4cyc_st = 1,
                             spm_sm_st_type_rwwsre_st   = 2,
                             spm_sm_st_type_blbset_st   = 3,
                             spm_sm_st_type_pgwrt_st    = 4,
                             spm_sm_st_type_pgers_st    = 5,
                             spm_sm_st_type_spmen_st    = 6;
			     
   reg [2:0]                 spm_sm_st_current;
   reg [2:0]                 spm_sm_st_next;
   
   reg [4:0]                 op_tmp_buf_current;
   reg [4:0]                 op_tmp_buf_next;
   
   reg [1:0]                 spm_del_cnt_current;
   reg [1:0]                 spm_del_cnt_next;
   
   // SPM operations
   parameter [4:0]           c_rwwsre_op = 5'b10001;
   parameter [4:0]           c_blbset_op = 5'b01001;
   parameter [4:0]           c_pgwrt_op  = 5'b00101;
   parameter [4:0]           c_pgers_op  = 5'b00011;
   parameter [4:0]           c_spmen_op  = 5'b00001;
   
   // Writing any other combination than  
   // "10001","01001","00101","00011" or "00001"
   // in the lower five bits will have no effect. 
   
   reg                       spm_wait_current;
   reg                       spm_wait_next;
   
   reg                       rwwsre_op_current;
   reg                       blbset_op_current;
   reg                       pgwrt_op_current;
   reg                       pgers_op_current;
   reg                       spmen_op_current;
   
   reg                       rwwsre_op_next;
   reg                       blbset_op_next;
   reg                       pgwrt_op_next;
   reg                       pgers_op_next;
   reg                       spmen_op_next;
   
   reg                       spm_irq_current;
   reg                       spm_irq_next;
   
//   parameter                 c_tot_port_num = 1;		// SPMCSR
//   wire [c_tot_port_num-1:0] port_rd;
   
   wire [7:0]                data_in_tmp;
   wire [7:0]                data_out_tmp;
   
   wire                      spmcsr_sel;

  
   assign spmcsr_sel = (use_dm_loc) ?  (ramadr[7:0] == csr_adr/*[7:0]*/) : (adr[5:0] == csr_adr[5:0]);

   // assign spmcsr_wr = fn_wr_port_en(csr_adr, use_dm_loc, adr, iowe, ramadr, dm_sel, ramwe);
   assign spmcsr_wr  = (use_dm_loc) ?  (dm_sel & ramwe & spmcsr_sel) : (iowe & spmcsr_sel);
   assign spmcsr_rd  = (use_dm_loc) ?  (dm_sel & ramre & spmcsr_sel) : (iore & spmcsr_sel);
   
   // ATMega1280	
   //io_loc:if(use_dm_loc=0) generate 	
   // spmcsr_wr <= '1' when (fn_to_integer(adr)=SPMCSR_Address and iowe='1') else '0';
   // spmcsr_rd <= '1' when (fn_to_integer(adr)=SPMCSR_Address and iore='1') else '0';
   //end generate;
   
   // ATMega128
   //dm_loc:if(use_dm_loc=1) generate 	
   // spmcsr_wr <= '1' when (ramadr=SPMCSR_Address and ramwe='1' and sel='1') else '0';
   // spmcsr_rd <= '1' when (ramadr=SPMCSR_Address and ramre='1' and sel='1') else '0'; 	
   //end generate;
   
   // assign data_in_tmp = fn_wr_port_mux(use_dm_loc, dbus_in, dm_dbus_in);
   assign data_in_tmp = (use_dm_loc) ? dm_dbus_in : dbus_in;
   
   
   always @(posedge cp2 or negedge ireset)
   begin: seq_prc
      if (!ireset)		// Reset
      begin
         spm_sm_st_current   <= spm_sm_st_type_idle_st;
         op_tmp_buf_current  <= {5{1'b0}};
         spm_del_cnt_current <= {2{1'b0}};
         spm_wait_current    <= 1'b0;
         
         rwwsre_op_current   <= 1'b0;
         blbset_op_current   <= 1'b0;
         pgwrt_op_current    <= 1'b0;
         pgers_op_current    <= 1'b0;
         spmen_op_current    <= 1'b0;
         
         spmie_current       <= 1'b0;
         spm_irq_current     <= 1'b0;
      end
      else 		// Clock
      begin
         spm_sm_st_current   <= spm_sm_st_next;
         op_tmp_buf_current  <= op_tmp_buf_next;
         spm_del_cnt_current <= spm_del_cnt_next;
         spm_wait_current    <= spm_wait_next;
         
         rwwsre_op_current   <= rwwsre_op_next;
         blbset_op_current   <= blbset_op_next;
         pgwrt_op_current    <= pgwrt_op_next;
         pgers_op_current    <= pgers_op_next;
         spmen_op_current    <= spmen_op_next;
         
         spmie_current       <= spmie_next;
         spm_irq_current     <= spm_irq_next;
      end
   end
   
   
   always @(spm_del_cnt_current or spm_sm_st_current or spm_sm_st_next)
   begin: delay_cnt_comb
      spm_del_cnt_next = spm_del_cnt_current;
      if (spm_sm_st_current == spm_sm_st_type_idle_st & spm_sm_st_next != spm_sm_st_type_idle_st)
         spm_del_cnt_next = {2{1'b0}};
      else
         spm_del_cnt_next = spm_del_cnt_current + 1;
   end
   
   
   always @(spm_sm_st_current or op_tmp_buf_current or spm_del_cnt_current or spmcsr_wr or data_in_tmp or spm_inst or rwwsre_rdy or blbset_rdy or pgwrt_rdy or pgers_rdy or spmen_rdy)
   begin: main_sm_comb
      spm_sm_st_next = spm_sm_st_current;
      // op_tmp_buf_next = op_tmp_buf_current;
      case (spm_sm_st_current)
         spm_sm_st_type_idle_st :
            if (spmcsr_wr == 1'b1 & (data_in_tmp[4:0] == c_rwwsre_op | data_in_tmp[4:0] == c_blbset_op | data_in_tmp[4:0] == c_pgwrt_op | data_in_tmp[4:0] == c_pgers_op | data_in_tmp[4:0] == c_spmen_op))
               spm_sm_st_next = spm_sm_st_type_wait4cyc_st;
            //	   op_tmp_buf_next = data_in_tmp(op_tmp_buf_next'range);
         spm_sm_st_type_wait4cyc_st :
            if (spm_inst == 1'b1)
               case (op_tmp_buf_current)
                  c_rwwsre_op :
                     spm_sm_st_next = spm_sm_st_type_rwwsre_st;
                  c_blbset_op :
                     spm_sm_st_next = spm_sm_st_type_blbset_st;
                  c_pgwrt_op :
                     spm_sm_st_next = spm_sm_st_type_pgwrt_st;
                  c_pgers_op :
                     spm_sm_st_next = spm_sm_st_type_pgers_st;
                  c_spmen_op :
                     spm_sm_st_next = spm_sm_st_type_spmen_st;
                  default :
                     spm_sm_st_next = spm_sm_st_type_idle_st;
               endcase
            else if (spm_del_cnt_current == 2'b11)
               spm_sm_st_next = spm_sm_st_type_idle_st;
            //	op_tmp_buf_next = (others => '0');   
         spm_sm_st_type_rwwsre_st :
            if (rwwsre_rdy == 1'b1)
               spm_sm_st_next = spm_sm_st_type_idle_st;
         spm_sm_st_type_blbset_st :
            if (blbset_rdy == 1'b1)
               spm_sm_st_next = spm_sm_st_type_idle_st;
         spm_sm_st_type_pgwrt_st :
            if (pgwrt_rdy == 1'b1)
               spm_sm_st_next = spm_sm_st_type_idle_st;
         spm_sm_st_type_pgers_st :
            if (pgers_rdy == 1'b1)
               spm_sm_st_next = spm_sm_st_type_idle_st;
         spm_sm_st_type_spmen_st :
            if (spmen_rdy == 1'b1)
               spm_sm_st_next = spm_sm_st_type_idle_st;
         default :
            spm_sm_st_next = spm_sm_st_type_idle_st;
      endcase
   end
   
   
   always @(spm_sm_st_current or spm_sm_st_next or op_tmp_buf_current or data_in_tmp)
   begin: op_fl_gen_comb
      op_tmp_buf_next = op_tmp_buf_current;
      if (spm_sm_st_current == spm_sm_st_type_idle_st & spm_sm_st_next != spm_sm_st_type_idle_st)
         op_tmp_buf_next = data_in_tmp[4:0]; // ??? Conversion
      else if (spm_sm_st_current != spm_sm_st_type_idle_st & spm_sm_st_next == spm_sm_st_type_idle_st)
         op_tmp_buf_next = {5{1'b0}};
   end
   
   
   always @(spm_sm_st_current or spm_sm_st_next or spm_wait_current or spm_inst)
   begin: spm_wait_gen_comb
      spm_wait_next = spm_wait_current;
      case (spm_wait_current)
         1'b0 :
            if (spm_sm_st_current == spm_sm_st_type_wait4cyc_st & spm_inst == 1'b1)
               spm_wait_next = 1'b1;
         1'b1 :
            if ((spm_sm_st_current == spm_sm_st_type_rwwsre_st | spm_sm_st_current == spm_sm_st_type_blbset_st | spm_sm_st_current == spm_sm_st_type_pgwrt_st | spm_sm_st_current == spm_sm_st_type_pgers_st | spm_sm_st_current == spm_sm_st_type_spmen_st) & spm_sm_st_next == spm_sm_st_type_idle_st)
               spm_wait_next = 1'b0;
         default :
            spm_wait_next = 1'b0;
      endcase
   end
   
   
   always @(spm_sm_st_next)
   begin: op_gen_comb
      rwwsre_op_next = 1'b0;
      blbset_op_next = 1'b0;
      pgwrt_op_next = 1'b0;
      pgers_op_next = 1'b0;
      spmen_op_next = 1'b0;
      
      if (spm_sm_st_next == spm_sm_st_type_rwwsre_st)
         rwwsre_op_next = 1'b1;
      if (spm_sm_st_next == spm_sm_st_type_blbset_st)
         blbset_op_next = 1'b1;
      if (spm_sm_st_next == spm_sm_st_type_pgwrt_st)
         pgwrt_op_next = 1'b1;
      if (spm_sm_st_next == spm_sm_st_type_pgers_st)
         pgers_op_next = 1'b1;
      if (spm_sm_st_next == spm_sm_st_type_spmen_st)
         spmen_op_next = 1'b1;
      
   end
   
   
   always @(spmie_current or spmcsr_wr or data_in_tmp)
   begin: spm_ie_comb
      spmie_next = spmie_current;
      if (spmcsr_wr == 1'b1)
         spmie_next = data_in_tmp[SPMIE_bit];
   end
   
   
   always @(spm_irq_current or spm_irq_ack or spm_sm_st_current or spm_sm_st_next)
   begin: irq_gen_comb
      spm_irq_next = spm_irq_current;
      case (spm_irq_current)
         1'b0 :
            if (spm_sm_st_current != spm_sm_st_type_idle_st & spm_sm_st_current != spm_sm_st_type_wait4cyc_st & spm_sm_st_next == spm_sm_st_type_idle_st)
               spm_irq_next = 1'b1;
         1'b1 :
            if (spm_irq_ack == 1'b1 | (spm_sm_st_current == spm_sm_st_type_idle_st & spm_sm_st_next != spm_sm_st_type_idle_st))
               spm_irq_next = 1'b0;
         default :
            spm_irq_next = 1'b0;
      endcase
   end
   
   assign rwwsre_op = rwwsre_op_current;
   assign blbset_op = blbset_op_current;
   assign pgwrt_op = pgwrt_op_current;
   assign pgers_op = pgers_op_current;
   assign spmen_op = spmen_op_current;
   assign spm_wait = spm_wait_current;
   
   // IRQ
   assign spm_irq      = spm_irq_current & spmie_current;
   
   // Data outs
   // assign data_out_tmp = {spmie_current, 2'b00, op_tmp_buf_current};
//   assign port_rd      = {data_out_tmp, csr_adr, use_dm_loc, 1};
   
   assign data_out_tmp = {spmie_current, 2'b00, op_tmp_buf_current};
   
   assign dbus_out    = (use_dm_loc) ? {8{1'b0}}    : data_out_tmp;
   assign dm_dbus_out = (use_dm_loc) ? data_out_tmp : {8{1'b0}};
   
   
   
//   assign io_out_en   = fn_gen_io_out_en(port_rd, adr, iore);
//assign io_out_en   = iore & (spmcsr_sel & !use_dm_loc[0]);

assign io_out_en  =  (use_dm_loc) ? 1'b0 : (iore & spmcsr_sel);

//    assign dm_out_en   = fn_gen_dm_out_en(port_rd, ramadr, ramre, dm_sel);
// assign dm_out_en   = (dm_sel & ramre) & (spmcsr_sel & use_dm_loc[0]);

assign dm_out_en   =  (use_dm_loc) ? (dm_sel & ramre & spmcsr_sel) : 1'b0;
   
endmodule // spm_mod


