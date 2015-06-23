//************************************************************************************************
// Debug master + communication i/f
// Version 0.41 
// Designed by Ruslan Lepetenok 
// Modified 10.01.2007
//************************************************************************************************

`timescale 1 ns / 1 ns

module ext_dbg_mod(		 
   ireset,
   cp2,
   d_adr,
   d_iore,
   d_iowe,
   d_iowait,
   d_io_dbusout,
   d_io_dbusin,
   d_ramadr,
   d_ramre,
   d_ramwe,
   d_ramwait,
   d_dm_dbusout,
   d_dm_dbusin,
   irqlines,
   bm_ramadr,
   bm_ramre,
   bm_ramdata,
   j_chain_ac_in,
   j_chain_d_in,
   j_chain_ac_out,
   j_chain_d_out,
   j_upd_ac,
   j_upd_d,
   tlr_st
);
   parameter               num_of_irqs = 23;  // 23 - Mega103 / 33 - Mega 128
   input                   ireset;
   input                   cp2;
   // I/O
   output [5:0]            d_adr;
   output                  d_iore;
   output                  d_iowe;
   input                   d_iowait;
   output [7:0]            d_io_dbusout;
   input [7:0]             d_io_dbusin;
   // RAM
   output [15:0]           d_ramadr;
   output                  d_ramre;
   output                  d_ramwe;
   input                   d_ramwait;
   output [7:0]            d_dm_dbusout;
   input [7:0]             d_dm_dbusin;
   // IRQ
   input [num_of_irqs-1:0] irqlines;
   // Bus monitor(optional)
   output [15:0]           bm_ramadr;
   output                  bm_ramre;
   input [7:0]             bm_ramdata;
   // JTAG module i/f !!!TBD!!!
   input [18:0]            j_chain_ac_in;
   input [8:0]             j_chain_d_in;
   output [18:0]           j_chain_ac_out;
   output [8:0]            j_chain_d_out;
   input                   j_upd_ac;
   input                   j_upd_d;
   input                   tlr_st;
   
   parameter [2:0]         main_sm_st_type_st_idle = 0,
                           main_sm_st_type_st_iord = 1,
                           main_sm_st_type_st_iowr = 2,
                           main_sm_st_type_st_ramwr = 3,
                           main_sm_st_type_st_ramrd = 4,
                           main_sm_st_type_st_irqrd = 5,
                           main_sm_st_type_st_bmrd = 6;
   reg [2:0]               main_sm_st_current;
   reg [2:0]               main_sm_st_next;
   
   parameter [2:0]         aux_sm_st_type_st_idle = 0,
                           aux_sm_st_type_st_wr1 = 1,
                           aux_sm_st_type_st_wr2 = 2,
                           aux_sm_st_type_st_rd1 = 3,
                           aux_sm_st_type_st_rd2 = 4;
   reg [2:0]               aux_sm_st_current;
   reg [2:0]               aux_sm_st_next;
   
   reg                     ireset_stat;
   
   reg                     d_ramre_current;
   reg                     d_ramre_next;
   
   reg                     d_ramwe_current;
   reg                     d_ramwe_next;
   
   reg                     d_iore_current;
   reg                     d_iore_next;
   
   reg                     d_iowe_current;
   reg                     d_iowe_next;
   
   reg [7:0]               d_io_dbusout_current;
   reg [7:0]               d_io_dbusout_next;
   
   reg [7:0]               d_dm_dbusout_current;
   reg [7:0]               d_dm_dbusout_next;
   
   reg                     bm_ramre_current;
   reg                     bm_ramre_next;
   
   wire [2:0]              cmd;
   
   reg                     j_upd_ac_del;
   reg                     j_upd_d_del;
   
   wire                    j_upd_ac_re;
   wire                    j_upd_d_re;
   
   reg                     j_upd_ac_re_del;
   reg                     j_upd_d_re_del;
   
   reg [7:0]               in_data_reg_current;
   reg [7:0]               in_data_reg_next;
   
   wire [63:0]             irqlines_tmp;
   wire [2:0]              irq_adr;
   
   reg [15:0]              xadr_current;
   reg [15:0]              xadr_next;
   
   reg                     ready_current;
   reg                     ready_next;
   
   reg [18:0]              adr_cmd_current;
   reg [18:0]              adr_cmd_next;
   
   reg [8:0]               data_current;
   reg [8:0]               data_next;
   
   
   always @(posedge cp2)
   begin: edge_det_dffs
      
      begin
         j_upd_ac_del <= j_upd_ac;
         j_upd_d_del <= j_upd_d;
      end
      end // edge_det_dffs
      
      // Edge detecters
      assign j_upd_ac_re = (~j_upd_ac_del) & j_upd_ac;
      assign j_upd_d_re = (~j_upd_d_del) & j_upd_d;
      
      
      always @(negedge ireset or posedge cp2)
      begin: new_seq_prc
         if (!ireset)
         begin
            j_upd_ac_re_del <= 1'b0;
            j_upd_d_re_del  <= 1'b0;
            adr_cmd_current <= {19{1'b0}};
            data_current    <= {9{1'b0}};
         end
         else 
         begin
            j_upd_ac_re_del <= j_upd_ac_re;
            j_upd_d_re_del  <= j_upd_d_re;
            adr_cmd_current <= adr_cmd_next;
            data_current    <= data_next;
         end
         end  // new_seq_prc
         
         assign cmd = adr_cmd_current[18:16];
         
         
         always @(adr_cmd_current or data_current or j_upd_ac_re or j_upd_d_re or j_chain_ac_in or j_chain_d_in)
         begin: adr_data_rg_comb
            adr_cmd_next = adr_cmd_current;
            data_next = data_current;
            
            if (j_upd_ac_re)
               adr_cmd_next = j_chain_ac_in;
            
            if (j_upd_d_re)
               data_next = j_chain_d_in;

            end // adr_data_rg_comb
            
            
            always @(aux_sm_st_current or j_upd_ac_re_del or j_upd_d_re_del or cmd or data_current or tlr_st)
            begin: aux_sm_comb
               aux_sm_st_next = aux_sm_st_current;
               
               if (tlr_st)
                  aux_sm_st_next = aux_sm_st_type_st_idle;
               else
                  
                  case (aux_sm_st_current)
                     aux_sm_st_type_st_idle :
                        if (j_upd_ac_re_del)
                        begin
                           if (cmd == C_CmdRdIO | cmd == C_CmdRdDM | cmd == C_CmdRdBMB | cmd == C_CmdRdIRQ)
                              aux_sm_st_next = aux_sm_st_type_st_rd1;
                           else if (cmd == C_CmdWrIO | cmd == C_CmdWrDM)
                              aux_sm_st_next = aux_sm_st_type_st_wr1;
                        end
                     
                     aux_sm_st_type_st_wr1 :
                        if (j_upd_d_re_del)
                           aux_sm_st_next = aux_sm_st_type_st_wr2;
                     
                     aux_sm_st_type_st_wr2 :
                        if (data_current[C_DRCtrlStBit])
                           aux_sm_st_next = aux_sm_st_type_st_wr1;
                        else
                           aux_sm_st_next = aux_sm_st_type_st_idle;
                     
                     aux_sm_st_type_st_rd1 :
                        if (j_upd_d_re_del)
                           aux_sm_st_next = aux_sm_st_type_st_rd2;
                     
                     aux_sm_st_type_st_rd2 :
                        if (data_current[C_DRCtrlStBit])
                           aux_sm_st_next = aux_sm_st_type_st_rd1;
                        else
                           aux_sm_st_next = aux_sm_st_type_st_idle;
                     default :
                        aux_sm_st_next = aux_sm_st_type_st_idle;
                  
                  endcase
            end
            
            
            always @(main_sm_st_current or d_iowait or d_ramwait or aux_sm_st_current or aux_sm_st_next or cmd or tlr_st)
            begin: main_sm_comb
               main_sm_st_next = main_sm_st_current;
               
               if (tlr_st)
                  main_sm_st_next = main_sm_st_type_st_idle;
               else
                  
                  case (main_sm_st_current)
                     main_sm_st_type_st_idle :
                        if ((aux_sm_st_current == main_sm_st_type_st_idle & aux_sm_st_next == aux_sm_st_type_st_rd1) | (aux_sm_st_current == aux_sm_st_type_st_rd2 & aux_sm_st_next == aux_sm_st_type_st_rd1))		// Read
                           case (cmd)
                              C_CmdRdIO :
                                 main_sm_st_next = main_sm_st_type_st_iord;
                              C_CmdRdDM :
                                 main_sm_st_next = main_sm_st_type_st_ramrd;
                              C_CmdRdBMB :
                                 main_sm_st_next = main_sm_st_type_st_bmrd;
                              C_CmdRdIRQ :
                                 main_sm_st_next = main_sm_st_type_st_irqrd;
                              default :
                                 main_sm_st_next = main_sm_st_type_st_idle;
                           endcase
                        else if (aux_sm_st_current == aux_sm_st_type_st_wr2 & aux_sm_st_next != aux_sm_st_type_st_wr2)		// Write
                           case (cmd)
                              C_CmdWrIO :
                                 main_sm_st_next = main_sm_st_type_st_iowr;
                              C_CmdWrDM :
                                 main_sm_st_next = main_sm_st_type_st_ramwr;
                              default :
                                 main_sm_st_next = main_sm_st_type_st_idle;
                           endcase
                     
                     main_sm_st_type_st_iord :
                        if (d_iowait == 1'b0)
                           main_sm_st_next = main_sm_st_type_st_idle;
                     main_sm_st_type_st_iowr :
                        if (d_iowait == 1'b0)
                           main_sm_st_next = main_sm_st_type_st_idle;
                     main_sm_st_type_st_ramrd :
                        if (d_ramwait == 1'b0)
                           main_sm_st_next = main_sm_st_type_st_idle;
                     main_sm_st_type_st_ramwr :
                        if (d_ramwait == 1'b0)
                           main_sm_st_next = main_sm_st_type_st_idle;
                     main_sm_st_type_st_irqrd :
                        main_sm_st_next = main_sm_st_type_st_idle;
                     main_sm_st_type_st_bmrd :
                        main_sm_st_next = main_sm_st_type_st_idle;
                     default :
                        main_sm_st_next = main_sm_st_type_st_idle;
                  endcase
               
            end
            
            assign irqlines_tmp[num_of_irqs-1:0] = irqlines;
            assign irqlines_tmp[63:num_of_irqs-1 + 1] = {2{1'b0}};
            assign irq_adr = xadr_current[2:0];
            
            
            always @(aux_sm_st_current or aux_sm_st_next or main_sm_st_current or main_sm_st_next or d_iore_current or d_iowe_current or d_io_dbusout_current or d_dm_dbusout_current or d_ramre_current or d_ramwe_current or bm_ramre_current or in_data_reg_current or d_io_dbusin or d_dm_dbusin or bm_ramdata or irqlines_tmp or irq_adr or xadr_current or d_iowait or d_ramwait or adr_cmd_current or data_current or ready_current or tlr_st or cmd)
            begin: ctrl_adr_comb
               d_iore_next = d_iore_current;
               d_iowe_next = d_iowe_current;
               d_io_dbusout_next = d_io_dbusout_current;
               d_dm_dbusout_next = d_dm_dbusout_current;
               d_ramre_next = d_ramre_current;
               d_ramwe_next = d_ramwe_current;
               bm_ramre_next = bm_ramre_current;
               in_data_reg_next = in_data_reg_current;
               xadr_next = xadr_current;
               ready_next = ready_current;
               // 
               
               if (tlr_st == 1'b1)
               begin
                  
                  d_iore_next = 1'b0;
                  d_iowe_next = 1'b0;
                  d_io_dbusout_next = {8{1'b0}};
                  d_dm_dbusout_next = {8{1'b0}};
                  d_ramre_next = 1'b0;
                  d_ramwe_next = 1'b0;
                  bm_ramre_next = 1'b0;
                  in_data_reg_next = {8{1'b0}};
                  xadr_next = {16{1'b0}};
                  ready_next = 1'b1;
               end
               else
               begin
                  
                  case (d_iowe_current)
                     1'b0 :
                        if (main_sm_st_next == main_sm_st_type_st_iowr)
                           d_iowe_next = 1'b1;
                     1'b1 :
                        if (d_iowait == 1'b0)
                           d_iowe_next = 1'b0;
                     default :
                        d_iowe_next = 1'b0;
                  endcase
                  
                  case (d_iore_current)
                     1'b0 :
                        if (main_sm_st_next == main_sm_st_type_st_iord)
                           d_iore_next = 1'b1;
                     1'b1 :
                        if (d_iowait == 1'b0)
                           d_iore_next = 1'b0;
                     default :
                        d_iore_next = 1'b0;
                  endcase
                  
                  case (d_ramwe_current)
                     1'b0 :
                        if (main_sm_st_next == main_sm_st_type_st_ramwr)
                           d_ramwe_next = 1'b1;
                     1'b1 :
                        if (d_ramwait == 1'b0)
                           d_ramwe_next = 1'b0;
                     default :
                        d_ramwe_next = 1'b0;
                  endcase
                  
                  case (d_ramre_current)
                     1'b0 :
                        if (main_sm_st_next == main_sm_st_type_st_ramrd)
                           d_ramre_next = 1'b1;
                     1'b1 :
                        if (d_ramwait == 1'b0)
                           d_ramre_next = 1'b0;
                     default :
                        d_ramre_next = 1'b0;
                  endcase
                  
                  case (bm_ramre_current)
                     1'b0 :
                        if (main_sm_st_next == main_sm_st_type_st_bmrd)
                           bm_ramre_next = 1'b1;
                     1'b1 :
                        bm_ramre_next = 1'b0;
                     default :
                        bm_ramre_next = 1'b0;
                  endcase
                  
                  case (main_sm_st_current)
                     main_sm_st_type_st_iord :
                        if (d_iowait == 1'b0)
                           in_data_reg_next = d_io_dbusin;
                     main_sm_st_type_st_ramrd :
                        if (d_ramwait == 1'b0)
                           in_data_reg_next = d_dm_dbusin;
                     main_sm_st_type_st_bmrd :
                        in_data_reg_next = bm_ramdata;
                     main_sm_st_type_st_irqrd :
                        case (irq_adr)
                           3'b000 :
                              in_data_reg_next = irqlines_tmp[7:0];
                           3'b001 :
                              in_data_reg_next = irqlines_tmp[15:8];
                           3'b010 :
                              in_data_reg_next = irqlines_tmp[23:16];
                           3'b011 :
                              in_data_reg_next = irqlines_tmp[31:24];
                           3'b100 :
                              in_data_reg_next = irqlines_tmp[39:32];
                           3'b101 :
                              in_data_reg_next = irqlines_tmp[47:40];
                           3'b110 :
                              in_data_reg_next = irqlines_tmp[55:48];
                           3'b111 :
                              in_data_reg_next = irqlines_tmp[63:56];
                           default :
                              in_data_reg_next = {8{1'b0}};
                        endcase
                     default :
                        in_data_reg_next = {8{1'b0}};
                  endcase
                  
                  if (aux_sm_st_current == aux_sm_st_type_st_idle & aux_sm_st_next != aux_sm_st_type_st_idle)
                     xadr_next = adr_cmd_current[15:0];		// Load address
                  else if (((main_sm_st_current == main_sm_st_type_st_ramrd | main_sm_st_current == main_sm_st_type_st_ramwr) & d_ramwait == 1'b0) | main_sm_st_current == main_sm_st_type_st_irqrd | main_sm_st_current == main_sm_st_type_st_bmrd)
                     xadr_next = xadr_current + 1;		// Increment address 	  
                  
                  if (aux_sm_st_current == aux_sm_st_type_st_wr1 & aux_sm_st_next == aux_sm_st_type_st_wr2)
                  begin
                     if (cmd == C_CmdWrIO)		// Write I/O	  
                        d_io_dbusout_next = data_current[7:0];
                     else if (cmd == C_CmdWrDM)		// Write DM
                        d_dm_dbusout_next = data_current[7:0];
                  end
                  
                  if (main_sm_st_next != aux_sm_st_type_st_idle)
                     ready_next = 1'b0;
                  else
                     ready_next = 1'b1;
               end
               
            end
            
            
            always @(negedge ireset or posedge cp2)
            begin: seq_prc
               if (!ireset)
               begin
                  main_sm_st_current <= main_sm_st_type_st_idle;
                  aux_sm_st_current <= aux_sm_st_type_st_idle;
                  ireset_stat          <= 1'b0;
                  d_iore_current       <= 1'b0;
                  d_iowe_current       <= 1'b0;
                  d_io_dbusout_current <= {8{1'b0}};
                  d_dm_dbusout_current <= {8{1'b0}};
                  d_ramre_current      <= 1'b0;
                  d_ramwe_current      <= 1'b0;
                  bm_ramre_current     <= 1'b0;
                  in_data_reg_current  <= {8{1'b0}};
                  xadr_current         <= {16{1'b0}};
                  ready_current        <= 1'b0;
               end
               else 
               begin
                  main_sm_st_current   <= main_sm_st_next;
                  aux_sm_st_current    <= aux_sm_st_next;
                  ireset_stat          <= 1'b1;
                  d_iore_current       <= d_iore_next;
                  d_iowe_current       <= d_iowe_next;
                  d_io_dbusout_current <= d_io_dbusout_next;
                  d_dm_dbusout_current <= d_dm_dbusout_next;
                  d_ramre_current      <= d_ramre_next;
                  d_ramwe_current      <= d_ramwe_next;
                  bm_ramre_current     <= bm_ramre_next;
                  in_data_reg_current  <= in_data_reg_next;
                  xadr_current         <= xadr_next;
                  ready_current        <= ready_next;
               end
            end
            
            //
            
            assign d_adr = xadr_current[5:0];
            assign d_iore = d_iore_current;
            assign d_iowe = d_iowe_current;
            assign d_io_dbusout = d_io_dbusout_current;
            assign d_dm_dbusout = d_dm_dbusout_current;
            
            assign d_ramadr = xadr_current;
            assign d_ramre = d_ramre_current;
            assign d_ramwe = d_ramwe_current;
            
            assign bm_ramadr = xadr_current[15:0];
            assign bm_ramre = bm_ramre_current;
            
            // TBD
            assign j_chain_d_out = {ready_current, in_data_reg_current};		// TBD -> Ready flag
            assign j_chain_ac_out = {3'b000, xadr_current};
            
endmodule
// TBD
