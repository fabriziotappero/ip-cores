//**********************************************************************************************
// Static RAM controller
// Version 0.5
// Modified 10.01.2007
// Designed by Ruslan Lepetenok (lepetenokr@yahoo.com)
// Modified 09.06.12 (Verilog version)
//**********************************************************************************************
`timescale 1 ns / 1 ns

module sr_ctrl(
   ireset,
   cp2,
   ramadr,
   dbus_in,
   dbus_out,
   ramre,
   ramwe,
   cpuwait,
   out_en,
   ram_sel,
   ws_in,
   sr_adr,
   sr_d_in,
   sr_d_out,
   sr_d_oe,
   sr_we_n,
   sr_cs_n,
   sr_oe_n
);

/*
type sr_ws_single_type is record
 ws_val : std_logic_vector(2 downto 0); -- Up to 7 wait states
 ws_adr : std_logic; 			-- Wait one cycle before driving out new address
end record;	

type sr_ws_type is array (natural range <>) of sr_ws_single_type;
*/


   parameter                 chip_num = 1;
   // AVR Control
   input                     ireset;
   input                     cp2;
   input [15:0]              ramadr;
   input [7:0]               dbus_in;
   output reg [7:0]          dbus_out;
   input                     ramre;
   input                     ramwe;
   output                    cpuwait;
   output reg                out_en;
   // Address decoder
   input [chip_num-1:0]      ram_sel;		// ???
   
   
   // Configuration

// [2:0] ws_val
// [3]   ws_adr

// ws_in[i].ws_val
// ws_in[i].ws_adr 

   input [4*chip_num-1:0]      ws_in;  // !!!!!!! 
   
   // Static RAM interface
   output reg [15:0]         sr_adr;
   input [7:0]               sr_d_in;
   output reg [7:0]          sr_d_out;
   output reg                sr_d_oe;
   output reg                sr_we_n;
   output reg [chip_num-1:0] sr_cs_n;
   output reg                sr_oe_n;
   
   reg [15:0]                sr_adr_current;
   reg [15:0]                sr_adr_next;
   reg [7:0]                 sr_d_out_current;
   reg [7:0]                 sr_d_out_next;
   reg                       sr_d_oe_n_current;
   reg                       sr_d_oe_n_next;
   reg                       sr_we_n_current;
   reg                       sr_we_n_next;
   reg [chip_num-1:0]        sr_cs_n_current;
   reg [chip_num-1:0]        sr_cs_n_next;
   reg                       sr_oe_n_current;
   reg                       sr_oe_n_next;
   
   // Wait states
   reg [2:0]                 ws_cnt_current;
   reg [2:0]                 ws_cnt_next;
   
   // Main state machine
   parameter [2:0]           MAIN_SM_ST_TYPE_IDLE_ST  = 3'd0,
                             MAIN_SM_ST_TYPE_PAUSE_ST = 3'd1,
                             MAIN_SM_ST_TYPE_WR1_ST   = 3'd2,
                             MAIN_SM_ST_TYPE_WR2_ST   = 3'd3,
                             MAIN_SM_ST_TYPE_WR3_ST   = 3'd4,
                             MAIN_SM_ST_TYPE_RD1_ST   = 3'd5,
                             MAIN_SM_ST_TYPE_RD2_ST   = 3'd6;
			     
   reg [2:0]                 main_sm_st_current;
   reg [2:0]                 main_sm_st_next;
   
   reg [7:0]                 data_rd_current;
   reg [7:0]                 data_rd_next;
  
 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
  
function[2:0] fn_get_ws_val;
input [4*chip_num-1:0] ws_in_i;
input integer sel_chip_num;

integer i;
integer j;
reg[2:0] res;
begin
 res = {3{1'b0}};
 for(i=0;i<chip_num;i=i+1) begin
  if(i == sel_chip_num) begin
   for(j=0;j<3;j=j+1) begin
    res[j] = ws_in_i[4*i+j];
   end
  end 
 end
 fn_get_ws_val = res;
end
endfunction // fn_get_ws_val;



function fn_get_ws_adr;
input [4*chip_num-1:0] ws_in_i;
input integer sel_chip_num;

reg res;
begin
 res = ws_in_i[4*sel_chip_num+3];
 fn_get_ws_adr = res;
end
endfunction // fn_get_ws_adr;
  
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
  
   
   
   always @(posedge cp2 or negedge ireset)
   begin: main_seq
      if (!ireset)		// Reset
      begin
         sr_adr_current     <= {16{1'b0}};
         sr_d_out_current   <= {8{1'b0}};
         sr_d_oe_n_current  <= 1'b1;
         sr_we_n_current    <= 1'b1;
         sr_cs_n_current    <= {chip_num{1'b1}};
         sr_oe_n_current    <= 1'b1;
         main_sm_st_current <= MAIN_SM_ST_TYPE_IDLE_ST;
         ws_cnt_current     <= {3{1'b0}};
         data_rd_current    <= {8{1'b0}}; // ??
         dbus_out           <= {8{1'b0}};
      end
      else 		// Clock 
      begin
         sr_adr_current     <= sr_adr_next;
         sr_d_out_current   <= sr_d_out_next;
         sr_d_oe_n_current  <= sr_d_oe_n_next;
         sr_we_n_current    <= sr_we_n_next;
         sr_cs_n_current    <= sr_cs_n_next;
         sr_oe_n_current    <= sr_oe_n_next;
         main_sm_st_current <= main_sm_st_next;
         ws_cnt_current     <= ws_cnt_next;
         data_rd_current    <= data_rd_next; // ??
         dbus_out           <= data_rd_next;
      end
   end // main_seq
 
 
    always @(posedge cp2 or negedge ireset)
   begin: out_regs
      if (!ireset)		// Reset 
      begin
         sr_adr   <= {16{1'b0}};
         sr_d_out <= {8{1'b0}};
         sr_d_oe  <= 1'b0;
         sr_we_n  <= 1'b1;
         sr_cs_n  <= {chip_num{1'b1}};
         sr_oe_n  <= 1'b1;
      end
      else 		// Clock 
      begin
         sr_adr   <= sr_adr_next;
         sr_d_out <= sr_d_out_next;
         sr_d_oe  <= sr_d_oe_n_next;
         sr_we_n  <= sr_we_n_next;
         sr_cs_n  <= sr_cs_n_next;
         sr_oe_n  <= sr_oe_n_next;
      end
   end // out_regs
 
 
   
   
   always @(main_sm_st_current or main_sm_st_next or ws_cnt_current or ws_in)
   begin: ws_cnt_comb
      ws_cnt_next = ws_cnt_current;
      if (main_sm_st_next == MAIN_SM_ST_TYPE_WR2_ST || main_sm_st_next == MAIN_SM_ST_TYPE_RD1_ST)
         ws_cnt_next = {3{1'b0}};
      else if (main_sm_st_current == MAIN_SM_ST_TYPE_WR2_ST || main_sm_st_current == MAIN_SM_ST_TYPE_RD1_ST)
         ws_cnt_next = ws_cnt_current + 1;
   end // ws_cnt_comb
   
   
   always @(main_sm_st_current or ram_sel or ws_cnt_current or ws_cnt_next or ramre or ramwe or ws_in)
   begin: main_sm_comb
      integer                   i;
      main_sm_st_next = main_sm_st_current;
      out_en          = 1'b0;
      
      case (main_sm_st_current)
         MAIN_SM_ST_TYPE_IDLE_ST :
            for (i = 0; i < chip_num; i = i + 1)
               if (ram_sel[i])
               begin
                  if (ramre)
                     main_sm_st_next = MAIN_SM_ST_TYPE_RD1_ST;
                  else if (ramwe)
                     main_sm_st_next = MAIN_SM_ST_TYPE_WR1_ST;
               end
         
         MAIN_SM_ST_TYPE_WR1_ST :
            main_sm_st_next = MAIN_SM_ST_TYPE_WR2_ST;
         
         MAIN_SM_ST_TYPE_WR2_ST :
            for (i = 0; i < chip_num; i = i + 1)
               if (ram_sel[i])
               begin
                  if (ws_cnt_current == fn_get_ws_val(ws_in, i)/*ws_in.ws_val*/)
                     main_sm_st_next = MAIN_SM_ST_TYPE_WR3_ST;
               end
         
         MAIN_SM_ST_TYPE_RD1_ST :
            for (i = 0; i < chip_num; i = i + 1)
               if (ram_sel[i])
               begin
                  if (ws_cnt_current == fn_get_ws_val(ws_in, i)/*ws_in.ws_val*/)
                     main_sm_st_next = MAIN_SM_ST_TYPE_RD2_ST;
               end
         
         MAIN_SM_ST_TYPE_WR3_ST, MAIN_SM_ST_TYPE_RD2_ST :
            begin
               main_sm_st_next = MAIN_SM_ST_TYPE_IDLE_ST;
               for (i = 0; i < chip_num; i = i + 1)
                  if (ram_sel[i] && /*ws_in.ws_adr*/ fn_get_ws_adr(ws_in, i))
                  begin
                     main_sm_st_next = MAIN_SM_ST_TYPE_PAUSE_ST;
                  end
            end
         
         MAIN_SM_ST_TYPE_PAUSE_ST :
            main_sm_st_next = MAIN_SM_ST_TYPE_IDLE_ST;
         default :
            main_sm_st_next = MAIN_SM_ST_TYPE_IDLE_ST;
      endcase
      
      // out_en generation 
      for (i = 0; i < chip_num; i = i + 1)
         if (ram_sel[i])
         begin
            if (ramre)
               out_en = 1'b1;
         end
      
   end // main_sm_comb
   
   
   always @(ramadr or dbus_in or ramre or ramwe or ram_sel or sr_adr_current or sr_d_out_current or sr_d_oe_n_current or sr_we_n_current or sr_cs_n_current or sr_oe_n_current or main_sm_st_current or main_sm_st_next or data_rd_current or sr_d_in)
   begin: aux_comb
      sr_adr_next    = sr_adr_current;
      sr_d_out_next  = sr_d_out_current;
      sr_d_oe_n_next = sr_d_oe_n_current;
      sr_we_n_next   = sr_we_n_current;
      sr_cs_n_next   = sr_cs_n_current;
      sr_oe_n_next   = sr_oe_n_current;
      data_rd_next   = data_rd_current;
      
      // Address register
      if (main_sm_st_current == MAIN_SM_ST_TYPE_IDLE_ST && main_sm_st_next != MAIN_SM_ST_TYPE_IDLE_ST)
      begin
         sr_adr_next   = ramadr[15:0];
         sr_d_out_next = dbus_in;
      end
      
      if (main_sm_st_next == MAIN_SM_ST_TYPE_WR1_ST || main_sm_st_next == MAIN_SM_ST_TYPE_WR2_ST || main_sm_st_next == MAIN_SM_ST_TYPE_WR3_ST)
         sr_d_oe_n_next = 1'b1;
      else
         sr_d_oe_n_next = 1'b0;
      
      // WE#
      if (main_sm_st_next == MAIN_SM_ST_TYPE_WR2_ST)
         sr_we_n_next = 1'b0;
      else
         sr_we_n_next = 1'b1;
      
      // CS#
      if (main_sm_st_next == MAIN_SM_ST_TYPE_RD1_ST || 
         (main_sm_st_next == MAIN_SM_ST_TYPE_WR1_ST || 
	  main_sm_st_next == MAIN_SM_ST_TYPE_WR2_ST || 
	  main_sm_st_next == MAIN_SM_ST_TYPE_WR3_ST))
         
	 sr_cs_n_next = (~ram_sel);
      else
         sr_cs_n_next = {chip_num{1'b1}};
      
      // OE#
      if (main_sm_st_next == MAIN_SM_ST_TYPE_RD1_ST)
         sr_oe_n_next = 1'b0;
      else
         sr_oe_n_next = 1'b1;
      
      // Data from SRAM
      if (main_sm_st_next == MAIN_SM_ST_TYPE_RD2_ST) data_rd_next = sr_d_in;
      
   end // aux_comb
   
   // cpuwait
   assign cpuwait = (((ramre || ramwe ) && main_sm_st_next != MAIN_SM_ST_TYPE_IDLE_ST)) ? 1'b1 : 1'b0;

   
endmodule // sr_ctrl

//sr_adr   <=	sr_adr_current;  
//sr_d_out <=	sr_d_out_current;
//sr_d_oe  <=	sr_d_oe_n_current; 
//sr_we_n  <=	sr_we_n_current; 
//sr_cs_n  <=	sr_cs_n_current; 
//sr_oe_n  <=	sr_oe_n_current; 
