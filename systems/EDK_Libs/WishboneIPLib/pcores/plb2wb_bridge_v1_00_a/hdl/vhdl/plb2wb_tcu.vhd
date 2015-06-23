----------------------------------------------------------------------
----                                                              ----
----  PLB2WB-Bridge                                               ----
----                                                              ----
----  This file is part of the PLB-to-WB-Bridge project           ----
----  http://opencores.org/project,plb2wbbridge                   ----
----                                                              ----
----  Description                                                 ----
----  Implementation of a PLB-to-WB-Bridge according to           ----
----  PLB-to-WB Bridge specification document.                    ----
----                                                              ----
----  To Do:                                                      ----
----   Nothing                                                    ----
----                                                              ----
----  Author(s):                                                  ----
----      - Christian Haettich                                    ----
----        feddischson@opencores.org                             ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2010 Authors                                   ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


library plb2wb_bridge_v1_00_a;
use plb2wb_bridge_v1_00_a.plb2wb_pkg.all;

entity plb2wb_tcu is
   generic(
      C_SPLB_NUM_MASTERS      : integer   := 1;
      C_SPLB_MID_WIDTH        : integer   := 3;
      C_SPLB_SIZE_WIDTH       : integer   := 4;
      C_SPLB_NATIVE_BE_WIDTH  : integer   := 4;
      C_SPLB_DWIDTH           : integer   := 128;
      C_SPLB_TYPE_WIDTH       : integer   := 4;
      C_SPLB_SUPPORT_BUR_LINE   : integer   := 1;
      WB_PIC_INTS             : integer   := 0;    
      WB_PIC_INT_LEVEL        : std_logic := '1';
      WB_TIMEOUT_CYCLES       : integer   := 10;
      WB_SUPPORT_BLOCK        : integer   := 1

   );
   port(

      wb_clk_i                : in  std_logic;
      wb_ack_i                : in  std_logic;
      wb_err_i                : in  std_logic;
      wb_rty_i                : in  std_logic;
      wb_rst_i                : in  std_logic;
      wb_pic_int_i            : in  std_logic_vector( WB_PIC_INTS-1 downto 0 );

      AMU_deviceSelect        : in  std_logic;
      AMU_statusSelect        : in  std_logic; 
      AMU_bufEmpty            : in  std_logic;
      AMU_bufFull             : in  std_logic;
      AMU_buf_RNW             : in  std_logic;
      AMU_buf_size            : in  std_logic_vector( C_SPLB_SIZE_WIDTH-1 downto 0 );
      AMU_buf_BE              : in  std_logic_vector( C_SPLB_NATIVE_BE_WIDTH-1 downto 0 );
      AMU_pipe_size           : in  std_logic_vector( 0 to C_SPLB_SIZE_WIDTH-1     );
      AMU_pipe_rmID           : in  std_logic_vector( 0 to C_SPLB_MID_WIDTH -1 );
      AMU_pipe_wmID           : in  std_logic_vector( 0 to C_SPLB_MID_WIDTH -1 );
      AMU_pipe_BE             : in  std_logic_vector( 0 to C_SPLB_NATIVE_BE_WIDTH-1 );
      AMU_pipe_rStatusSelect  : in  std_logic;
      AMU_pipe_wStatusSelect  : in  std_logic;

      WBF_empty               : in  std_logic;
      WBF_full                : in  std_logic;

      RBF_empty               : in  std_logic;
      RBF_almostEmpty         : in  std_logic;
      RBF_full                : in  std_logic;

      SPLB_Clk                : in  std_logic;
      plb2wb_rst              : in  std_logic;
      PLB_MSize               : in  std_logic_vector( 0 to 1   );
      PLB_TAttribute          : in  std_logic_vector( 0 to 15  );
      PLB_lockErr             : in  std_logic;
      PLB_abort               : in  std_logic;
      PLB_rdBurst             : in  std_logic;
      PLB_wrBurst             : in  std_logic;
      PLB_RNW                 : in  std_logic;
      PLB_PAValid             : in  std_logic;
      PLB_masterID            : in  std_logic_vector( 0 to C_SPLB_MID_WIDTH-1 );
      PLB_rdPrim              : in  std_logic;
      PLB_wrPrim              : in  std_logic;
      PLB_size                : in  std_logic_vector( 0 to C_SPLB_SIZE_WIDTH-1   );
      PLB_BE                  : in  std_logic_vector( 0 to C_SPLB_DWIDTH/8-1 );
      PLB_type                : in  std_logic_vector( 0 to C_SPLB_TYPE_WIDTH  -1 );

      STU_abort               : in  std_logic;
      STU_continue            : in  std_logic;

      RBF_rdErrOut            : in  std_logic;
      RBF_rdErrIn             : out std_logic;


      Sl_MRdErr               : out std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1  );
      Sl_MWrErr               : out std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );
      Sl_wrDAck               : out std_logic;
      Sl_wrComp               : out std_logic;
      Sl_wrBTerm              : out std_logic;
      Sl_rdDAck               : out std_logic;
      Sl_rdComp               : out std_logic;
      Sl_rdBTerm              : out std_logic;
      Sl_rdWdAddr             : out std_logic_vector( 0 to 3 );
      Sl_wait                 : out std_logic;
      Sl_rearbitrate          : out std_logic;

      TCU_wbufWEn             : out std_logic;
      TCU_wbufREn             : out std_logic;

      TCU_rbufWEn             : out std_logic;
      TCU_rbufREn             : out std_logic;

      TCU_adrBufWEn           : out std_logic;
      TCU_adrBufREn           : out std_logic;
      TCU_rpipeRdEn           : out std_logic;
      TCU_wpipeRdEn           : out std_logic;

      TCU_enRdDBus            : out std_logic;
      TCU_MRBusy              : out std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );
      TCU_addrAck             : out std_logic;
      TCU_adr_offset          : out std_logic_vector( 3 downto 0 );

      TCU_stuLatchPA          : out std_logic;
      TCU_stuLatchSA          : out std_logic;
      TCU_stuWritePA          : out std_logic;
      TCU_stuWriteSA          : out std_logic;
      TCU_stat2plb_en         : out std_logic;
      TCU_enStuRdDBus         : out std_logic;
      TCU_wb_status_info      : out std_logic_vector( STATUS2PLB_INFO_SIZE-1 downto 0 );
      TCU_wb_irq_info         : out std_logic_vector( IRQ_INFO_SIZE-1 downto 0 );

      wb_lock_o               : out std_logic;
      wb_stb_o                : out std_logic;
      wb_we_o                 : out std_logic;
      wb_cyc_o                : out std_logic


   );
end entity plb2wb_tcu;


architecture IMP of plb2wb_tcu is


   signal TCU_wbufWEn_t       : std_logic;
   signal TCU_wbufREn_t       : std_logic;
   signal TCU_adrBufWEn_w     : std_logic;
   signal TCU_adrBufWEn_r     : std_logic;
   signal TCU_rbufWEn_t       : std_logic;
   signal TCU_rbufREn_t       : std_logic;
   signal TCU_stuWritePA_t    : std_logic;
   signal TCU_stuWriteSA_t    : std_logic;

   signal Sl_rdComp_t         : std_logic;
   signal Sl_wrComp_t         : std_logic;

   signal Sl_rdDAck_t         : std_logic;

   signal TCU_rpipeRdEn_t     : std_logic;
   signal TCU_wpipeRdEn_t     : std_logic;

   --
   -- Wishbone current and next state
   type wb_trans_state is ( wb_idle, wb_write, wb_read, wb_write_rty, wb_read_rty, wb_write_stall );
   type wb_trans_state_type is record
      state             : wb_trans_state;
      transfer_count    : std_logic_vector( 3 downto 0 );
      abort             : std_logic;
   end record;
   signal c_wb_state, n_wb_state : wb_trans_state_type;



   --
   -- PLB current and next state
   type plb_wtrans_state is( plb_widle, plb_write, plb_burst_write );
   type plb_rtrans_state is( plb_ridle, plb_read, plb_read_ack, plb_line_read, 
                              plb_line_read_ack,  plb_burst_read, plb_burst_read_ack,
                              plb_wait_line_read, plb_wait_burst_read );

   type plb_rtrans_state_type is record
      state             : plb_rtrans_state;
      r_master_id       : std_logic_vector( C_SPLB_MID_WIDTH-1 downto 0 );
      r_secondary       : std_logic;
      transfer_count    : std_logic_vector( 0 to 3 );
      transfer_size     : std_logic_vector( 0 to C_SPLB_SIZE_WIDTH-1 );
      status_transfer   : std_logic;
   end record;

   type plb_wtrans_state_type is record
      state             : plb_wtrans_state;
      w_master_id       : std_logic_vector( C_SPLB_MID_WIDTH-1 downto 0 );
      w_secondary       : std_logic;
      transfer_count    : std_logic_vector( 0 to 3 );
      transfer_size     : std_logic_vector( 0 to C_SPLB_SIZE_WIDTH-1 );
      status_transfer   : std_logic;
   end record;

   signal c_plb_wstate : plb_wtrans_state_type;    -- current write state
   signal n_plb_wstate : plb_wtrans_state_type;    -- next    write state
   signal c_plb_rstate : plb_rtrans_state_type;    -- current read  state
   signal n_plb_rstate : plb_rtrans_state_type;    -- next    read  state



   signal mbusy_read_out         : std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 ); 
   signal mbusy_write_out        : std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 ); 


   signal start_plb_w            : std_logic; -- start plb write (to wb side)
   signal start_plb_r            : std_logic; -- start plb read  (from wb side)

   signal start_plb_stat_w       : std_logic; -- start plb status write
   signal start_plb_stat_r       : std_logic; -- start plb status read

   signal start_plb_sec_w        : std_logic; -- start plb write (to wb side, pipelined)
   signal start_plb_sec_r        : std_logic; -- start plb read  (from wb side, pipelined)

   signal start_plb_sec_stat_r   : std_logic; -- start plb write to status (pipelined)
   signal start_plb_sec_stat_w   : std_logic; -- start plb read from status (pipelined)



   signal start_wb_w             : std_logic; -- start wb write
   signal start_wb_r             : std_logic; -- start wb read

   signal wb_ack                 : std_logic;
   signal wb_rty                 : std_logic;
   signal wb_err                 : std_logic;

   signal addrAck_w              : std_logic;
   signal addrAck_r              : std_logic;

   signal TCU_stuLatchPA_r       : std_logic;
   signal TCU_stuLatchSA_r       : std_logic;
   signal TCU_stuLatchPA_w       : std_logic;
   signal TCU_stuLatchSA_w       : std_logic;


   signal wb_rst_short           : std_logic;


   signal pic_int_ahigh          : std_logic_vector( WB_PIC_INTS-1 downto 0 );
   signal pic_int_ahigh_short    : std_logic_vector( WB_PIC_INTS-1 downto 0 );
   signal pic_int2plb_en         : std_logic;


   -----
   -- wishbone timeout counter
   --
   constant WB_TOUT_COUNTER_SIZE : integer := log2( WB_TIMEOUT_CYCLES );
   constant WB_TOUT_MAX_VALUE    : std_logic_vector( WB_TOUT_COUNTER_SIZE-1 downto 0 ) 
                                       := std_logic_vector( to_unsigned( WB_TIMEOUT_CYCLES-1, WB_TOUT_COUNTER_SIZE ) );
   constant WB_TOUT_MIN_VALUE    : std_logic_vector( WB_TOUT_COUNTER_SIZE-1 downto 0 )
                                       := ( others => '0' );
   signal wb_tout_counter        : std_logic_vector( WB_TOUT_COUNTER_SIZE-1 downto 0 );
   signal wb_tout_count          : std_logic;
   signal wb_tout_reset          : std_logic;
   signal wb_tout_alarm          : std_logic;



begin




   TCU_wbufWEn          <= TCU_wbufWEn_t;
   TCU_wbufREn          <= TCU_wbufREn_t;
   TCU_adrBufWEn        <= TCU_adrBufWEn_w or TCU_adrBufWEn_r;
   TCU_rbufWEn          <= TCU_rbufWEn_t;
   TCU_rbufREn          <= TCU_rbufREn_t;
   Sl_rdComp            <= Sl_rdComp_t;
   Sl_wrComp            <= Sl_wrComp_t;
   Sl_rdDAck            <= Sl_rdDAck_t;
   TCU_rpipeRdEn        <= TCU_rpipeRdEn_t;
   TCU_wpipeRdEn        <= TCU_wpipeRdEn_t;
   TCU_stuWritePA       <= TCU_stuWritePA_t;
   TCU_stuWriteSA       <= TCU_stuWriteSA_t;
   TCU_stuLatchSA       <= TCU_stuLatchSA_r or TCU_stuLatchSA_w;
   TCU_stuLatchPA       <= TCU_stuLatchPA_r or TCU_stuLatchPA_w;

   TCU_addrAck          <= addrAck_w or addrAck_r;






   Sl_rearbitrate <= '0';     -- there is no situation, where we want to reabitrate





   Sl_wait        <= '1'   when addrAck_w = '0' and addrAck_r        = '0'
                                                and AMU_deviceSelect = '1' 
                                                and PLB_PAValid      = '1' 
                                                and PLB_RNW          = '0'
                                                and AMU_bufFull      = '1';



   ------
   --    
   --    interrupt signals:   they are converted to active-high signals, 
   --                         which are only for one clock cycle '1'
   --
   pic_ints : if WB_PIC_INTS > 0 generate
      
      --
      --   Generate the active-high interrupt levels
      --    (we work internaly only with active-high interrupt levels)
      --
      gen_active_high1 : if WB_PIC_INT_LEVEL = '0' generate
         pic_int_ahigh <= not wb_pic_int_i;
      end generate gen_active_high1;
      gen_active_high2  : if WB_PIC_INT_LEVEL = '1' generate
         pic_int_ahigh <=  wb_pic_int_i;
      end generate gen_active_high2;

      --
      --    Generate short impulses (of one clock cycle) 
      --
      gen_active_high_short : for i in 0 to WB_PIC_INTS-1 generate
         ah_short : entity plb2wb_bridge_v1_00_a.plb2wb_short_impulse( IMP )
            port map(   CLK            => wb_clk_i, 
                        RESET          => plb2wb_rst,
                        IMPULSE        => pic_int_ahigh(i),
                        SHORT_IMPULSE  => pic_int_ahigh_short(i) );

      end generate;

   end generate;
   --
   -----







   short_impulse : entity plb2wb_bridge_v1_00_a.plb2wb_short_impulse( IMP ) 
      port map (  CLK            => wb_clk_i, 
                  RESET          => plb2wb_rst,
                  IMPULSE        => wb_rst_i, 
                  SHORT_IMPULSE  => wb_rst_short );





   ------------------------------
   -- 
   --    This signals are '1' if a transfer is started:
   --       (burst and line transfers are supported)
   --
   --    start_plb_w:      start a write transfer to the WB side
   --    start_plb_r:      start a read transfer from the WB side
   --    start_plb_stat_w: start a write transfer to the status registers
   --    start_plb_stat_r: start a read transfer from the status registers
   --
   --
   with_plb_bursts : if C_SPLB_SUPPORT_BUR_LINE > 0 generate


      start_plb_w     <= '1' when (  -- we are in the idle state
                                 c_plb_wstate.state = plb_widle
            
                                 -- Address in our range, primary-addr is valid and it is a write transfer
                                 and AMU_deviceSelect = '1' and PLB_PAValid = '1' and PLB_RNW = '0'
                                 
                                 -- this transfer-type is implemented 
                                 --(normal, line and burst -> all fixed-length word bursts)
                                 and ( PLB_size( 0 to 1 ) = "00" or ( PLB_size = "1010" and PLB_BE( 0 to 3 ) /= "0000" ) )
            
                                 -- we are not transfering data from the read pipe 
                                 and TCU_rpipeRdEn_t /= '1'    
            
                                 -- the address buffer is not full
                                 and AMU_bufFull = '0' 

                                 -- supported transfer-type (only mem-type is supported, see PLB-Spec. page 43)
                                 and ( PLB_type = "000" or PLB_type = "110" )  )
                else '0';


      start_plb_r     <= '1' when(   -- we are in the idle state 
                                 c_plb_rstate.state = plb_ridle

                                 -- Address in our range, primary-addr is valid and it is a read transfer
                                 and AMU_deviceSelect = '1' and PLB_PAValid = '1' and PLB_RNW = '1'

                                 -- this transfer-type is implemented (normal and line)
                                 and ( PLB_size( 0 to 1 ) = "00" or ( PLB_size = "1010" and PLB_BE( 0 to 3 ) /="0000" ) )

                                 -- we are not transfering data from the write-pipe 
                                 and TCU_wpipeRdEn_t /= '1'

                                 -- the address buffer is not full
                                 and AMU_bufFull = '0' 

                                 -- supported transfer-type (only mem-type is supported, see PLB-Spec. page 43)
                                 and ( PLB_type = "000" or PLB_type = "110" )  )

                else '0';



      start_plb_stat_w <= '1' when    (   -- we are in the idle state
                                       c_plb_wstate.state = plb_widle
            
                                       -- Address in our range, primary-addr is valid and it is a write transfer
                                       and AMU_statusSelect = '1' and PLB_PAValid = '1' and PLB_RNW = '0'
                                       
                                       -- this transfer-type is implemented 
                                       --(normal, line and burst -> all fixed-length word bursts)
                                       and ( PLB_size( 0 to 1 ) = "00" or ( PLB_size = "1010" and PLB_BE( 0 to 3 ) /= "0000" ) )

                                       -- supported transfer-type (only mem-type is supported, see PLB-Spec. page 43)
                                       and ( PLB_type = "000" or PLB_type = "110" )  )
                   else '0';




      start_plb_stat_r <= '1' when    (   
                                       -- we are in the idle state
                                       c_plb_rstate.state = plb_ridle
            
                                       -- Address in our range, primary-addr is valid and it is a write transfer
                                       and AMU_statusSelect = '1' and PLB_PAValid = '1' and PLB_RNW = '1'
                                       
                                       -- this transfer-type is implemented 
                                       --(normal, line and burst -> all fixed-length word bursts)
                                       and ( PLB_size( 0 to 1 ) = "00" or ( PLB_size = "1010" and PLB_BE( 0 to 3 ) /= "0000" ) )

                                       -- supported transfer-type (only mem-type is supported, see PLB-Spec. page 43)
                                       and ( PLB_type = "000" or PLB_type = "110" )  )
                   else '0';

   end generate with_plb_bursts;







   ------------------------------
   -- 
   --    This signals are '1' if a transfer is started:
   --       (burst and line transfers are not supported)
   --
   --    start_plb_w:      start a write transfer to the WB side
   --    start_plb_r:      start a read transfer from the WB side
   --    start_plb_stat_w: start a write transfer to the status registers
   --    start_plb_stat_r: start a read transfer from the status registers
   --
   --
   without_plb_bursts : if C_SPLB_SUPPORT_BUR_LINE = 0 generate


      start_plb_w     <= '1' when (  -- we are in the idle state
                                 c_plb_wstate.state = plb_widle
            
                                 -- Address in our range, primary-addr is valid and it is a write transfer
                                 and AMU_deviceSelect = '1' and PLB_PAValid = '1' and PLB_RNW = '0'
                                 
                                 -- this transfer-type is implemented (only single)
                                 and ( PLB_size = "0000" ) 
            
                                 -- we are not transfering data from the read pipe 
                                 and TCU_rpipeRdEn_t /= '1'    
            
                                 -- the address buffer is not full
                                 and AMU_bufFull = '0' 

                                 -- supported transfer-type (only mem-type is supported, see PLB-Spec. page 43)
                                 and ( PLB_type = "000" or PLB_type = "110" )  )
                else '0';


      start_plb_r     <= '1' when(   -- we are in the idle state 
                                 c_plb_rstate.state = plb_ridle

                                 -- Address in our range, primary-addr is valid and it is a read transfer
                                 and AMU_deviceSelect = '1' and PLB_PAValid = '1' and PLB_RNW = '1'

                                 -- this transfer-type is implemented (only single)
                                 and ( PLB_size = "0000" ) 

                                 -- we are not transfering data from the write-pipe 
                                 and TCU_wpipeRdEn_t /= '1'

                                 -- the address buffer is not full
                                 and AMU_bufFull = '0' 

                                 -- supported transfer-type (only mem-type is supported, see PLB-Spec. page 43)
                                 and ( PLB_type = "000" or PLB_type = "110" )  )

                else '0';



      start_plb_stat_w <= '1' when    (   -- we are in the idle state
                                       c_plb_wstate.state = plb_widle
            
                                       -- Address in our range, primary-addr is valid and it is a write transfer
                                       and AMU_statusSelect = '1' and PLB_PAValid = '1' and PLB_RNW = '0'
                                       
                                       -- this transfer-type is implemented (only single)
                                       and ( PLB_size = "0000" ) 

                                       -- supported transfer-type (only mem-type is supported, see PLB-Spec. page 43)
                                       and ( PLB_type = "000" or PLB_type = "110" )  )
                   else '0';




      start_plb_stat_r <= '1' when    (   
                                       -- we are in the idle state
                                       c_plb_rstate.state = plb_ridle
            
                                       -- Address in our range, primary-addr is valid and it is a write transfer
                                       and AMU_statusSelect = '1' and PLB_PAValid = '1' and PLB_RNW = '1'
                                       
                                       -- this transfer-type is implemented (only single)
                                       and ( PLB_size = "0000" ) 

                                       -- supported transfer-type (only mem-type is supported, see PLB-Spec. page 43)
                                       and ( PLB_type = "000" or PLB_type = "110" )  )
                   else '0';

   end generate without_plb_bursts;








   
   start_plb_sec_w <= '1' when(
                                 c_plb_wstate.state         = plb_widle -- ----                                            
                                and c_plb_wstate.w_secondary   = '1'       -- This is the case, when there is a write
                                and AMU_bufFull                = '0'       -- from a secondary request directly after a write
                                and AMU_pipe_wStatusSelect     = '0'       -- (this transfer does not write to our status regs)
                             -- and TCU_rpipeRdEn_t        /= '1'       -- note:  start_plb_sec_w has a higher priority
                                                                           -- than start_plb_sec_r, (we can't check 
                                                                           -- TCU_rpipeRdEn_t, because this generates a 
                                                                           -- combinatorial loop!!)
                                )    -- ----                                              
               else     '0';


   start_plb_sec_stat_w <= '1' when(   c_plb_wstate.state        = plb_widle  -- ----
                                and c_plb_wstate.w_secondary   = '1'        -- This is the case, when there is a write
                                and AMU_pipe_wStatusSelect     = '1'        -- from a secondary request (we write to our status regs)
                                )      -- ----
               else     '0';


   start_plb_sec_r <= '1' when(   c_plb_rstate.state         = plb_ridle  -- ----
                                and c_plb_rstate.r_secondary   = '1'        -- This is the case, when there is a read
                                and AMU_bufFull                = '0'        -- from a secondary request directly after a read
                                and AMU_pipe_rStatusSelect     = '0'        -- (this transfer does not read from our status regs)
                                and TCU_wpipeRdEn_t           /= '1' )      -- ----
               else     '0';


   start_plb_sec_stat_r <= '1' when(   c_plb_rstate.state         = plb_ridle  -- ----
                                and c_plb_rstate.r_secondary   = '1'        -- This is the case, when there is a read
                                and AMU_pipe_rStatusSelect     = '1'        -- from a secondary request (we read from our status regs)
                                )      -- ----
               else     '0';



   c_plb_state_p : process( SPLB_Clk, plb2wb_rst ) begin
      if plb2wb_rst='1' then

         c_plb_rstate <= ( state             => plb_ridle,
                           r_master_id       => ( others => '0' ),
                           transfer_count    => ( others => '0' ),
                           transfer_size     => ( others => '0' ),
                           status_transfer   => '0',
                           r_secondary       => '0' );
         c_plb_wstate <= ( state             => plb_widle,
                           w_master_id       => ( others => '0' ),
                           transfer_count    => ( others => '0' ),
                           transfer_size     => ( others => '0' ),
                           status_transfer   => '0',
                           w_secondary       => '0' );
                           

      elsif SPLB_Clk'event and SPLB_Clk='1' then
         c_plb_rstate <= n_plb_rstate;
         c_plb_wstate <= n_plb_wstate;
      end if;
   end process;





   n_plb_wstate_p : process(  c_plb_wstate,
                              PLB_PAValid, PLB_RNW, PLB_masterID, PLB_wrPrim, PLB_size, PLB_BE,
                              AMU_deviceSelect, AMU_statusSelect, AMU_bufFull, WBF_full, AMU_pipe_size, AMU_pipe_wmID, AMU_pipe_BE,
                              start_plb_sec_w, start_plb_sec_stat_w, start_plb_w, start_plb_stat_w,
                              TCU_rpipeRdEn_t ) 
      begin

         
         Sl_MWrErr            <= ( others => '0' );

         -- default output logic
         Sl_wrDAck            <= '0';
         Sl_wrComp_t          <= '0';
         Sl_wrBTerm           <= '0';
         
         TCU_wbufWEn_t        <= '0';
         TCU_adrBufWEn_w      <= '0';
         TCU_wpipeRdEn_t      <= '0';
         addrAck_w            <= '0';


         TCU_stuLatchSA_w     <= '0';
         TCU_stuLatchPA_w     <= '0';

         -- default state
         n_plb_wstate         <= c_plb_wstate;
         mbusy_write_out      <= ( others => '0' );

         TCU_stuWritePA_t     <= '0';
         TCU_stuWriteSA_t     <= '0';

         if PLB_wrPrim = '1' then
            n_plb_wstate.w_secondary <= '1';
         end if;


         
         if start_plb_sec_w = '1' then
            
            -- read from pipe and add it to the buffer
            TCU_wpipeRdEn_t            <= '1';
            TCU_adrBufWEn_w            <= '1';

            n_plb_wstate.w_secondary      <= '0';
            n_plb_wstate.status_transfer  <= '0';

            -- we latch the masterID 
            n_plb_wstate.w_master_id      <= AMU_pipe_wmID;

            -- buffer is not full,   this is a implemented transfer and   this is a normal/single transfer
            if WBF_full = '0' and AMU_pipe_size = "0000"  then

               -- add data to the buffer
               TCU_wbufWEn_t  <= '1';
               -- ack transfer to PLB
               Sl_wrDAck      <= '1';
               Sl_wrComp_t    <= '1';

               -- we stay in the idle state

            -- buffer is not full, this is a line transfer
            elsif WBF_full = '0' and AMU_pipe_size( 0 to 1 ) = "00" and AMU_pipe_size( 2 to 3 ) /= "00" then

               -- add data to the buffer
               TCU_wbufWEn_t  <= '1';
               -- ack transfer to PLB
               Sl_wrDAck      <= '1';

               n_plb_wstate.state            <= plb_write;
               n_plb_wstate.transfer_size    <= AMU_pipe_size;
               -- we did one transfer in this clock cycle 
               n_plb_wstate.transfer_count   <= "0001";    

            -- buffer is full, we switch to the wait-state and wait until we can write to the buffer
            elsif WBF_full = '1' and AMU_pipe_size( 0 to 1 ) = "00" then

               n_plb_wstate.state            <= plb_write;
               n_plb_wstate.transfer_size    <= AMU_pipe_size;
               -- we did one transfer in this clock cycle 
               n_plb_wstate.transfer_count   <= "0000";    

            -- this is a burst transfer
            -- and the buffer is not full
            elsif WBF_full = '0' and AMU_pipe_size( 0 to 1 ) /= "00" then

               -- add data to the buffer
               TCU_wbufWEn_t  <= '1';
               -- ack transfer to PLB
               Sl_wrDAck      <= '1';

               n_plb_wstate.state            <= plb_burst_write;
               n_plb_wstate.transfer_size    <= AMU_pipe_BE;
               -- we did one transfer in this clock cycle 
               n_plb_wstate.transfer_count   <= "0001";    

            -- this is a burst transfer
            -- and the buffer is full
            elsif WBF_full = '1' and AMU_pipe_size( 0 to 1 ) /= "00" then

               n_plb_wstate.state            <= plb_burst_write;
               n_plb_wstate.transfer_size    <= AMU_pipe_BE;
               -- we did one transfer in this clock cycle 
               n_plb_wstate.transfer_count   <= "0000";    

            end if;



         --
         --  NOTE: it is not allowed to write with a burst or line transfer to the status 
         --  registers,  so TCU_stuWriteSA_t is only '1' for a single transfer!
         --
         elsif start_plb_sec_stat_w = '1' then

               TCU_wpipeRdEn_t            <= '1';

               -- we latch the masterID 
               n_plb_wstate.w_master_id      <= AMU_pipe_wmID;
            
               n_plb_wstate.w_secondary      <= '0';

               -- ack transfer to PLB
               Sl_wrDAck         <= '1';


               if AMU_pipe_size = "1010" and AMU_pipe_BE( 0 to 3 ) /= "0000" then
                  -- burst transfer
                                

                  Sl_MWrErr( to_integer( unsigned'( unsigned( AMU_pipe_wmID )  ) ) ) <= '1';

                  -- we switch to the burst_write state:
                  -- we write until transfer_count = transfer_size
                  n_plb_wstate.state            <= plb_burst_write;
                  n_plb_wstate.transfer_size    <= AMU_pipe_BE( 0 to 3 );
                  -- we did no transfer in this clock cycle
                  n_plb_wstate.transfer_count   <= "0001";    

                  n_plb_wstate.status_transfer  <= '1';



               elsif AMU_pipe_size( 0 to 1 ) = "00" and AMU_pipe_size( 2 to 3 ) /= "00" then
                  -- line transfer
                  
                  Sl_MWrErr( to_integer( unsigned'( unsigned( AMU_pipe_wmID )  ) ) ) <= '1';

                  -- we switch to the write state:
                  -- we write until transfer_count = transfer_size
                  n_plb_wstate.state            <= plb_write;
                  n_plb_wstate.transfer_size    <= AMU_pipe_size;
                  -- we did one transfer in this clock cycle 
                  n_plb_wstate.transfer_count   <= "0001";    

                  n_plb_wstate.status_transfer  <= '1';


               else

                  -- single transfer
                  TCU_stuWriteSA_t  <= '1';
                  Sl_wrComp_t       <= '1';
               end if;


         --
         -- start write transfer, initiated through PLB_PAValid
         --
         elsif  start_plb_w = '1' then

            -- we can accept the address

            -- add address and data to the fifos/buffers
            -- this implicit acks the address (see plb2wb_amu.vhd)
            TCU_adrBufWEn_w            <= '1';
            
            addrAck_w                  <= '1';


            -- we latch the masterID 
            n_plb_wstate.w_master_id      <= PLB_masterID;
           
            n_plb_wstate.status_transfer  <= '0';

            -- buffer is not full and this is a single/normal transfer
            -- (we stay in the idle state)
            if WBF_full = '0' and PLB_size = "0000" then
           
               -- add data to the buffer
               TCU_wbufWEn_t  <= '1';
               -- ack transfer to PLB
               Sl_wrDAck      <= '1';
               Sl_wrComp_t    <= '1';


            -- this is a line transfer
            elsif WBF_full = '0' and PLB_size( 0 to 1 ) = "00" and PLB_size( 2 to 3 ) /= "00" then

               -- add data to the buffer
               TCU_wbufWEn_t  <= '1';
               -- ack transfer to PLB
               Sl_wrDAck      <= '1';

               -- we switch to the write state:
               -- we write until transfer_count = transfer_size
               n_plb_wstate.state            <= plb_write;
               n_plb_wstate.transfer_size    <= PLB_size;
               -- we did one transfer in this clock cycle 
               n_plb_wstate.transfer_count   <= "0001";    


            -- the buffer is full:
            -- if this is a single or line transfer, we switch to the plb_write state
            elsif WBF_full = '1' and PLB_size( 0 to 1 ) = "00" then


               -- we switch to the write state:
               -- we write until transfer_count = transfer_size
               n_plb_wstate.state            <= plb_write;
               n_plb_wstate.transfer_size    <= PLB_size;
               -- we did no transfer in this clock cycle
               n_plb_wstate.transfer_count   <= "0000";    


            -- this is a burst transfer
            -- and the buffer is not full
            elsif WBF_full = '0' and PLB_size( 0 to 1 ) /= "00" then


               -- add data to the buffer
               TCU_wbufWEn_t  <= '1';
               -- ack transfer to PLB
               Sl_wrDAck      <= '1';


               -- we switch to the burst_write state:
               -- we write until transfer_count = transfer_size
               n_plb_wstate.state            <= plb_burst_write;
               n_plb_wstate.transfer_size    <= PLB_BE( 0 to 3 );
               -- we did no transfer in this clock cycle
               n_plb_wstate.transfer_count   <= "0001";    


            -- this is a burst transfer
            -- and the buffer is full
            elsif WBF_full = '1' and PLB_size( 0 to 1 ) /= "00" then


               -- we switch to the burst_write state:
               -- we write until transfer_count = transfer_size
               n_plb_wstate.state            <= plb_burst_write;
               n_plb_wstate.transfer_size    <= PLB_BE( 0 to 3 );
               -- we did no transfer in this clock cycle
               n_plb_wstate.transfer_count   <= "0000";    

            end if;

         --
         -- start write transfer to state-register, initiated through PLB_PAValid
         --
         --
         --  NOTE: it is not allowed to write with a burst or line transfer to the status 
         --  registers,  so TCU_stuWritePA_t is only '1' for a single transfer!
         --
         elsif  start_plb_stat_w = '1'  then

               addrAck_w         <= '1';
               
               -- we latch the masterID 
               n_plb_wstate.w_master_id      <= PLB_masterID;

               -- ack transfer to PLB
               Sl_wrDAck         <= '1';


               if PLB_size = "1010" and PLB_BE( 0 to 3 ) /= "0000" then
                  -- burst transfer
                                

                  Sl_MWrErr( to_integer( unsigned'( unsigned( PLB_masterID )  ) ) ) <= '1';

                  -- we switch to the burst_write state:
                  -- we write until transfer_count = transfer_size
                  n_plb_wstate.state            <= plb_burst_write;
                  n_plb_wstate.transfer_size    <= PLB_BE( 0 to 3 );
                  -- we did no transfer in this clock cycle
                  n_plb_wstate.transfer_count   <= "0001";    

                  n_plb_wstate.status_transfer  <= '1';



               elsif PLB_size( 0 to 1 ) = "00" and PLB_size( 2 to 3 ) /= "00" then
                  -- line transfer
                  
                  Sl_MWrErr( to_integer( unsigned'( unsigned( PLB_masterID )  ) ) ) <= '1';

                  -- we switch to the write state:
                  -- we write until transfer_count = transfer_size
                  n_plb_wstate.state            <= plb_write;
                  n_plb_wstate.transfer_size    <= PLB_size;
                  -- we did one transfer in this clock cycle 
                  n_plb_wstate.transfer_count   <= "0001";    

                  n_plb_wstate.status_transfer  <= '1';


               else

                  -- single transfer
                  TCU_stuWritePA_t  <= '1';
                  Sl_wrComp_t       <= '1';
               end if;
      end if;





      --
      -- write transfer: we are here because
      --             - the write buffer was full and the adress buffer not, or
      --             - this is a line transfer
      --
      if (    c_plb_wstate.state = plb_write and
            ( c_plb_wstate.status_transfer = '1' or ( WBF_full = '0' and c_plb_wstate.status_transfer = '0' ) ) )  then     -- we can accept data

            -- ack transfer to PLB
            Sl_wrDAck         <= '1';
            
            
            if (  ( c_plb_wstate.transfer_size( 0 to 3 ) = "0001" and c_plb_wstate.transfer_count = "0011" ) or
                  ( c_plb_wstate.transfer_size( 0 to 3 ) = "0010" and c_plb_wstate.transfer_count = "0111" ) or 
                  ( c_plb_wstate.transfer_size( 0 to 3 ) = "0011" and c_plb_wstate.transfer_count = "1111" ) or
                  ( c_plb_wstate.transfer_size( 0 to 3 ) = "0000"                                          ) -- single transfer
               ) then
               -- we are at the end of this transfer
               Sl_wrComp_t       <= '1';
            
               n_plb_wstate.state <= plb_widle;
            
            
            else
               n_plb_wstate.transfer_count <= std_logic_vector( unsigned'( unsigned(c_plb_wstate.transfer_count) +1 ) );
            end if;
            
            
            if c_plb_wstate.status_transfer = '1' then

               Sl_MWrErr( to_integer( unsigned'( unsigned( c_plb_wstate.w_master_id )  ) ) ) <= '1';

            elsif WBF_full = '0' then
            
               -- add data to the buffer
               TCU_wbufWEn_t     <= '1'; 

            end if;


      
      end if;


      --
      -- burst write transfer: we are here because
      --             - this is a burst transfer
      if(   c_plb_wstate.state = plb_burst_write  and
            (  ( WBF_full = '0' and c_plb_wstate.status_transfer = '0' ) or c_plb_wstate.status_transfer = '1' ) )then     -- we can accept data


            if c_plb_wstate.status_transfer = '1' then

               Sl_MWrErr( to_integer( unsigned'( unsigned( c_plb_wstate.w_master_id )  ) ) ) <= '1';

            elsif WBF_full = '0' then
            
               -- add data to the buffer
               TCU_wbufWEn_t     <= '1'; 

            end if;



            -- ack transfer to PLB
            Sl_wrDAck         <= '1';
         

            -- we show that the burst-transfer ends after the next cycle
            if c_plb_wstate.transfer_count = std_logic_vector( unsigned'( unsigned( c_plb_wstate.transfer_size ) -1 ) ) then
               Sl_wrBTerm <= '1';
            end if;


            if c_plb_wstate.transfer_size = c_plb_wstate.transfer_count then
               -- we are at the end of this transfer
               Sl_wrComp_t          <= '1';
               n_plb_wstate.state   <= plb_widle;
            else
               n_plb_wstate.transfer_count <= std_logic_vector( unsigned'( unsigned(c_plb_wstate.transfer_count) +1 ) );
            end if;




      end if;




      if    c_plb_wstate.state = plb_write   
         or c_plb_wstate.state = plb_burst_write then
         mbusy_write_out( to_integer( unsigned'( unsigned( c_plb_wstate.w_master_id ) ) ) ) <= '1';
      elsif c_plb_wstate.w_secondary  = '1'         then
         mbusy_write_out( to_integer( unsigned'( unsigned( AMU_pipe_wmID ) ) ) ) <= '1';
      end if;

   end process;
            









          
              

   n_plb_rstate_p : process(  c_plb_rstate, 
                              PLB_PAValid, PLB_RNW, PLB_masterID, PLB_rdPrim, PLB_size, PLB_BE,
                              AMU_deviceSelect, AMU_bufFull, AMU_pipe_size, AMU_pipe_rmID, AMU_pipe_BE, AMU_statusSelect,
                              RBF_empty, RBF_almostEmpty,
                              start_plb_sec_r, start_plb_sec_stat_r, start_plb_r, start_plb_stat_r,
                              TCU_wpipeRdEn_t )
      begin


         Sl_rdDAck_t          <= '0';
         Sl_rdComp_t          <= '0';
         Sl_rdBTerm           <= '0';
         
         TCU_rbufREn_t        <= '0';
         TCU_adrBufWEn_r      <= '0';
         
         TCU_enRdDBus         <= '0';
         TCU_rpipeRdEn_t      <= '0';

--       TCU_rbufPreLoad      <= '0';     -- TODO
--       TCU_rbufPreEn        <= '0';     -- TODO

         addrAck_r            <= '0';


         TCU_stuLatchSA_r     <= '0';
         TCU_stuLatchPA_r     <= '0';

         TCU_enStuRdDBus      <= '0';  
         Sl_rdWdAddr          <= ( others => '0' );

         mbusy_read_out       <= ( others => '0' );

         n_plb_rstate         <= c_plb_rstate;

         if PLB_rdPrim = '1' then
            n_plb_rstate.r_secondary <= '1';
         end if;

         
         if start_plb_sec_r = '1' then
            
            TCU_adrBufWEn_r               <= '1';
            TCU_rpipeRdEn_t               <= '1';
            n_plb_rstate.r_secondary      <= '0';

            -- latch the master-id from AMU
            n_plb_rstate.r_master_id      <= AMU_pipe_rmID;

            n_plb_rstate.status_transfer  <= '0';

            -- this is a line transfer
            if AMU_pipe_size( 0 to 1 ) = "00" and AMU_pipe_size( 2 to 3 ) /= "00" and C_SPLB_SUPPORT_BUR_LINE > 0 then

               n_plb_rstate.state            <= plb_line_read;
               n_plb_rstate.transfer_count   <= ( others => '0' );
               n_plb_rstate.transfer_size    <= AMU_pipe_size;


            -- this is a burst transfer
            elsif AMU_pipe_size( 0 to 1 ) /= "00" and C_SPLB_SUPPORT_BUR_LINE > 0 then
            
               n_plb_rstate.state            <= plb_burst_read;
               n_plb_rstate.transfer_count   <= ( others => '0' );
               n_plb_rstate.transfer_size    <= AMU_pipe_BE( 0 to 3 );

            -- this is a single transfer
            else
               n_plb_rstate.state         <= plb_read;
            end if;



         --
         -- start read transfer from state-register, initiated through secondary request
         --
         elsif start_plb_sec_stat_r  = '1' then


            TCU_rpipeRdEn_t               <= '1';
            n_plb_rstate.r_secondary      <= '0';

            -- latch the master-id from AMU
            n_plb_rstate.r_master_id      <= AMU_pipe_rmID;

            -- tell the stu, that it should latch the secondary address
            TCU_stuLatchSA_r  <= '1';

            n_plb_rstate.status_transfer  <= '1';

            -- this is a line transfer
            if AMU_pipe_size( 0 to 1 ) = "00" and AMU_pipe_size( 2 to 3 ) /= "00" and C_SPLB_SUPPORT_BUR_LINE > 0 then

               n_plb_rstate.state            <= plb_line_read;
               n_plb_rstate.transfer_count   <= ( others => '0' );
               n_plb_rstate.transfer_size    <= AMU_pipe_size;


            -- this is a burst transfer
            elsif AMU_pipe_size( 0 to 1 ) /= "00" and C_SPLB_SUPPORT_BUR_LINE > 0 then
            
               n_plb_rstate.state            <= plb_burst_read;
               n_plb_rstate.transfer_count   <= ( others => '0' );
               n_plb_rstate.transfer_size    <= AMU_pipe_BE( 0 to 3 );

            -- this is a single transfer
            else
               n_plb_rstate.state         <= plb_read;
            end if;



         --
         -- start read transfer, initiated through PLB_PAValid
         --
         elsif start_plb_r = '1' then
         
         
                  -- add address to the buffer/fifo
                  TCU_adrBufWEn_r   <= '1';
               
                  addrAck_r         <= '1';
                  
                  -- latch the master-id from plb-bus
                  n_plb_rstate.r_master_id    <= PLB_masterID;


                  n_plb_rstate.status_transfer <= '0';
         
         
                  n_plb_rstate.transfer_count <= "0000";
         
                  -- this is a line transfer
                  if  PLB_size( 0 to 1 ) = "00" and PLB_size( 2 to 3 ) /= "00" and C_SPLB_SUPPORT_BUR_LINE > 0 then  
                     n_plb_rstate.transfer_size    <= PLB_size;
                     n_plb_rstate.state            <= plb_wait_line_read;
                     n_plb_rstate.transfer_count   <= ( others => '0' );

                  -- this is a burst transfer
                  elsif PLB_size( 0 to 1 ) /= "00" and C_SPLB_SUPPORT_BUR_LINE > 0 then
                     n_plb_rstate.state            <= plb_wait_burst_read;
                     n_plb_rstate.transfer_count   <= ( others => '0' );
                     n_plb_rstate.transfer_size    <= PLB_BE( 0 to 3 );
                  -- this is a single transfer
                  else
                     n_plb_rstate.transfer_size    <= PLB_size;
                     n_plb_rstate.state            <= plb_read;
                  end if;
         
         
         --
         -- start read transfer from state-register, initiated through PLB_PAValid
         --
         elsif  start_plb_stat_r = '1'  then


                  -- single transfer
                  addrAck_r         <= '1';

                  -- tell the stu, that it should latch the primary address
                  TCU_stuLatchPA_r  <= '1';

                  -- latch the master-id from plb-bus
                  n_plb_rstate.r_master_id    <= PLB_masterID;

                  n_plb_rstate.transfer_count <= "0000";


                  n_plb_rstate.status_transfer <= '1';

                  -- this is a line transfer
                  if  PLB_size( 0 to 1 ) = "00" and PLB_size( 2 to 3 ) /= "00" and C_SPLB_SUPPORT_BUR_LINE > 0 then  
                     n_plb_rstate.transfer_size    <= PLB_size;
                     n_plb_rstate.state            <= plb_wait_line_read;
                     n_plb_rstate.transfer_count   <= ( others => '0' );

                  -- this is a burst transfer
                  elsif PLB_size( 0 to 1 ) /= "00" and C_SPLB_SUPPORT_BUR_LINE > 0 then
                     n_plb_rstate.state            <= plb_wait_burst_read;
                     n_plb_rstate.transfer_count   <= ( others => '0' );
                     n_plb_rstate.transfer_size    <= PLB_BE( 0 to 3 );
                  -- this is a single transfer
                  else
                     n_plb_rstate.transfer_size    <= PLB_size;
                     n_plb_rstate.state            <= plb_read;

                  end if;



         end if;



         -- the wb-side read the data and added it to the fifo
         --   ->  fifo is not empty any more
         if (     (  c_plb_rstate.state = plb_read and c_plb_rstate.status_transfer = '0' and RBF_empty = '0' )
               -- this transfer reads from status register
               or (  c_plb_rstate.state = plb_read and c_plb_rstate.status_transfer = '1' )     )
         then
         
               -- complete read transfer
               Sl_rdComp_t       <= '1';
         
               -- switch to the ack state
               n_plb_rstate.state <= plb_read_ack;
                  
         end if;
      
      
      
         if c_plb_rstate.state = plb_read_ack then
         
            -- switch to idle state
            n_plb_rstate.state <= plb_ridle;
            
            -- ack. the read transfer
            Sl_rdDAck_t <= '1';
        
      
            if c_plb_rstate.status_transfer = '0' then
      
               -- read from the buffer
               TCU_rbufREn_t     <= '1';
      
            end if;
         
         end if;
      
      
      
      
         if c_plb_rstate.state = plb_line_read then 
                                                           --      /-----  We know, that the fifo contains min. 2 elements
            if (     c_plb_rstate.status_transfer = '1' or --     \/
                  (  c_plb_rstate.status_transfer = '0' and RBF_almostEmpty = '0' ) ) then
         
               n_plb_rstate.transfer_count <= std_logic_vector( unsigned'( unsigned(c_plb_rstate.transfer_count) + 1 ) );
               
               Sl_rdDAck_t       <= '1';
               
               if (  ( c_plb_rstate.transfer_size( 0 to 3 ) = "0001" and c_plb_rstate.transfer_count = "0010" ) or
                     ( c_plb_rstate.transfer_size( 0 to 3 ) = "0010" and c_plb_rstate.transfer_count = "0110" ) or 
                     ( c_plb_rstate.transfer_size( 0 to 3 ) = "0011" and c_plb_rstate.transfer_count = "1110" ) ) then
                  -- we are finished after the next clock cycle
                  Sl_rdComp_t <= '1';
                  n_plb_rstate.state <= plb_line_read_ack;
               end if;
            end if;
      
            if ( c_plb_rstate.status_transfer = '0' and RBF_almostEmpty = '0' ) then
               TCU_rbufREn_t   <= '1';
            end if;
      
         end if;
      
      
      
      
      
      
         if c_plb_rstate.state = plb_burst_read  then
         
      
                                                           --      /-----  We know, that the fifo contains min. 2 elements 
            if (     c_plb_rstate.status_transfer = '1' or --     \/
                  (  c_plb_rstate.status_transfer = '0' and RBF_almostEmpty = '0' ) ) then
      
               n_plb_rstate.transfer_count <= std_logic_vector( unsigned'( unsigned(c_plb_rstate.transfer_count) + 1 ) );
               
               Sl_rdDAck_t    <= '1';
               
               if c_plb_rstate.transfer_count = std_logic_vector( unsigned'( unsigned ( c_plb_rstate.transfer_size ) -1 ) )  then
      
                  -- we are finished after the next clock cycle
                  Sl_rdComp_t <= '1';
                  Sl_rdBTerm  <= '1';
                  n_plb_rstate.state <= plb_burst_read_ack;
               end if;
        
      
            end if;
      
            if ( c_plb_rstate.status_transfer = '0' and RBF_almostEmpty = '0' ) then
               TCU_rbufREn_t  <= '1';
            end if;
      
         end if;
      
      
         -- the wait cycles
         if c_plb_rstate.state = plb_wait_burst_read then
            n_plb_rstate.state <= plb_burst_read;
         end if;
      
         if c_plb_rstate.state = plb_wait_line_read then
            n_plb_rstate.state <= plb_line_read;
         end if;
      
      
      
      
         if c_plb_rstate.state = plb_line_read_ack or
            c_plb_rstate.state = plb_burst_read_ack then
         
            Sl_rdDAck_t          <= '1';
            n_plb_rstate.state   <= plb_ridle;
      
            if c_plb_rstate.status_transfer = '0' then
               TCU_rbufREn_t     <= '1';
            end if;
            
         end if;
      
      
         if    (  (  c_plb_rstate.state = plb_read
                  or c_plb_rstate.state = plb_read_ack
                  or c_plb_rstate.state = plb_line_read 
                  or c_plb_rstate.state = plb_line_read_ack
                  or c_plb_rstate.state = plb_burst_read
                  or c_plb_rstate.state = plb_burst_read_ack)  
                  and  c_plb_rstate.status_transfer = '0' )
         then
               -- we enable the read bus on plb side
               TCU_enRdDBus      <= '1';
      
         elsif (  (  c_plb_rstate.state = plb_read
                  or c_plb_rstate.state = plb_read_ack
                  or c_plb_rstate.state = plb_line_read 
                  or c_plb_rstate.state = plb_line_read_ack
                  or c_plb_rstate.state = plb_burst_read
                  or c_plb_rstate.state = plb_burst_read_ack)  
                  and  c_plb_rstate.status_transfer = '1' )
         then
      
               TCU_enStuRdDBus   <= '1';  
         end if;
      
      
      
         if          c_plb_rstate.state = plb_read           or 
                     c_plb_rstate.state = plb_read_ack       or 
                     c_plb_rstate.state = plb_line_read      or 
                     c_plb_rstate.state = plb_line_read_ack  or
                     c_plb_rstate.state = plb_burst_read     or
                     c_plb_rstate.state = plb_burst_read_ack or
                     c_plb_rstate.state = plb_wait_line_read or
                     c_plb_rstate.state = plb_wait_burst_read 
         then
            mbusy_read_out( to_integer( unsigned'( unsigned( c_plb_rstate.r_master_id ) ) ) ) <= '1';
         end if;
      
      
         if  c_plb_rstate.r_secondary = '1' then
            mbusy_read_out( to_integer( unsigned'( unsigned( AMU_pipe_rmID ) ) ) ) <= '1';
         end if;
      
      
         if c_plb_rstate.state = plb_line_read        or 
            c_plb_rstate.state = plb_line_read_ack    or
            c_plb_rstate.state = plb_burst_read       or
            c_plb_rstate.state = plb_burst_read_ack   
         then
            Sl_rdWdAddr <= c_plb_rstate.transfer_count;
         end if;
      
      
      
      end process;
      
      TCU_MRBusy <= mbusy_read_out or mbusy_write_out;
      
      Sl_MRdErr <= mbusy_read_out when Sl_rdDAck_t = '1' and RBF_rdErrOut = '1' else
                  ( others => '0' );





   -- ====================================================================================================|
   --                                                                                                     |
   -- =========================  W I S H B O N E   --  S I D E   =========================================|
   --                                                                                                     |
   -- ====================================================================================================|






   -------
   --    WB-timeout counter
   --       -> counts from WB_TOUT_MIN_VALUE to WB_TOUT_MAX_VALUE
   --       -> is reseted by driving wb_tout_reset high
   --       -> if counter reaches WB_TOUT_MAX_VALUE, wb_tout_alarm becomes '1'
   --
   wb_tout_process : process( wb_clk_i, plb2wb_rst, wb_tout_counter, wb_tout_reset )
   begin
      wb_tout_alarm <= '0';

      if plb2wb_rst = '1' or wb_tout_reset = '1' then
         wb_tout_counter   <= WB_TOUT_MIN_VALUE;
      elsif wb_clk_i'event and wb_clk_i = '1' then
         if ( wb_tout_count = '1' and wb_tout_counter /= WB_TOUT_MAX_VALUE ) then
            wb_tout_counter <= wb_tout_counter + 1;
         end if;
      end if;
      if wb_tout_counter = WB_TOUT_MAX_VALUE then
         wb_tout_alarm <= '1';
      end if;
   end process;
   --
   -----








   c_wb_state_p : process( wb_clk_i, plb2wb_rst ) begin
      if plb2wb_rst='1' then
         c_wb_state.state           <= wb_idle;
         c_wb_state.transfer_count  <= ( others => '0' );
      elsif wb_clk_i'event and wb_clk_i='1' then
         c_wb_state <= n_wb_state;

      end if;
   end process;



   --
   -- Note: we have fall-through fifo's, so the address is assigned when AMU_bufEmpty becomes '0'
   --
   start_wb_w  <=   '1' when ( c_wb_state.state = wb_idle and AMU_buf_RNW = '0' and AMU_bufEmpty = '0' and WBF_empty    = '0' ) else
                        '0';
   start_wb_r   <=   '1' when ( c_wb_state.state = wb_idle and AMU_buf_RNW = '1' and RBF_full     = '0' and AMU_bufEmpty = '0' ) else
                        '0';
      

   wb_ack         <=    wb_ack_i and not wb_err_i and not wb_rty_i;
   wb_rty         <=    wb_rty_i and not wb_err_i;
   wb_err         <=    wb_err_i;



   n_wb_state_p : process( c_wb_state, AMU_buf_size, 
                           AMU_buf_BE, WBF_empty,
                           start_wb_w, start_wb_r, wb_ack, wb_rty, wb_err, wb_tout_alarm,
                           STU_continue, STU_abort, wb_rst_short,pic_int_ahigh_short  ) begin

      wb_we_o              <= '0';
      wb_stb_o             <= '0';
      wb_cyc_o             <= '0';
      wb_lock_o            <= '0';

      TCU_wbufREn_t        <= '0';
      TCU_rbufWEn_t        <= '0';
      TCU_adrBufREn        <= '0';
      TCU_wb_status_info   <= ( others => '0' );
      TCU_stat2plb_en      <= '0';


      wb_tout_count        <= '0';
      wb_tout_reset        <= '0';

      n_wb_state <= c_wb_state;

      if start_wb_w = '1' then

            wb_stb_o                   <= '1';
            wb_cyc_o                   <= '1';
            wb_we_o                    <= '1';
            n_wb_state.abort           <= '0';
            wb_tout_reset              <= '1';
            
            if    wb_ack = '1' then
               TCU_wbufREn_t  <= '1';
            
               if AMU_buf_size /= "0000" then
               -- this is a line or burst transfer
                  n_wb_state.state           <= wb_write;
                  n_wb_state.transfer_count  <= "0001";
               else
               -- this is a single transfer:
               -- we read from the address buffer,
               -- because this transfer is complete 

                  TCU_adrBufREn        <= '1';

               end if;
            
            elsif wb_err = '1' then
               -- add error info to the status pipe
               -- and switch to the stall state
               n_wb_state.state     <= wb_write_stall;
               TCU_wb_status_info( STATUS2PLB_W_ERR ) <= '1';
               TCU_stat2plb_en      <= '1';
            elsif wb_rty = '1' then
               -- retry this transfer
               n_wb_state.state     <= wb_write_rty;
            else 
               n_wb_state.state     <= wb_write;
            end if;

      end if;





      if start_wb_r = '1'   then


            wb_stb_o                   <= '1';
            wb_cyc_o                   <= '1';
            wb_we_o                    <= '0';
            n_wb_state.abort           <= '0';
            wb_tout_reset              <= '1';

            
            if    wb_ack = '1' or wb_err = '1' then
               TCU_rbufWEn_t <= '1';

               if AMU_buf_size /= "0000" then
               -- this is a line or burst transfer

                  n_wb_state.state           <= wb_read;
                  n_wb_state.transfer_count  <= "0001";
               else
               -- this is a single transfer:
               -- we read from the address buffer,
               -- because this transfer is complete


                  TCU_adrBufREn        <= '1';
               end if;

            elsif wb_rty = '1' then
               n_wb_state.state     <= wb_read_rty;
            else 
               n_wb_state.state     <= wb_read;
            end if;

      end if;

      

      --
      --    write-transfer without writing
      --    -->> we have to empty the write-pipe
      if c_wb_state.state = wb_write and WBF_empty ='0' and c_wb_state.abort = '1' then

            TCU_wbufREn_t     <= '1';
            
            if AMU_buf_size = "0000" then
            -- single write transfer
            
               n_wb_state.state     <= wb_idle;
               TCU_adrBufREn        <= '1';

            elsif AMU_buf_size( 3 downto 2 ) = "00" then
            -- write line transfer

               if (  ( AMU_buf_size( 1 downto 0 ) = "01" and c_wb_state.transfer_count = "0011" ) or
                     ( AMU_buf_size( 1 downto 0 ) = "10" and c_wb_state.transfer_count = "0111" ) or 
                     ( AMU_buf_size( 1 downto 0 ) = "11" and c_wb_state.transfer_count = "1111" ) ) then
                  -- we are at the end of this transfer

                  n_wb_state.transfer_count <= ( others => '0' );
                  n_wb_state.state     <= wb_idle;
                  TCU_adrBufREn        <= '1';

               else
                  n_wb_state.transfer_count <= std_logic_vector( unsigned'( unsigned(c_wb_state.transfer_count) +1 ) );
               end if;

            else
            -- write burst transfer

               if c_wb_state.transfer_count = AMU_buf_BE then
                  -- we are at the end of this transfer

                  n_wb_state.transfer_count  <= ( others => '0' );
                  n_wb_state.state           <= wb_idle;
                  TCU_adrBufREn              <= '1';

               else
                  n_wb_state.transfer_count <= std_logic_vector( unsigned'( unsigned(c_wb_state.transfer_count) +1 ) );
               end if;

            end if;



      elsif c_wb_state.state = wb_write and WBF_empty ='0' and c_wb_state.abort = '0' then
      
            wb_stb_o       <= '1';
            wb_cyc_o       <= '1';
            wb_we_o        <= '1';
            wb_tout_count  <= '1';


            if    wb_ack = '1' then

               TCU_wbufREn_t     <= '1';
               wb_tout_reset     <= '1';

               if AMU_buf_size = "0000" then
               -- single write transfer

                  n_wb_state.state     <= wb_idle;
                  TCU_adrBufREn        <= '1';

               elsif AMU_buf_size( 3 downto 2 ) = "00" then
               -- write line transfer

                  if (  ( AMU_buf_size( 1 downto 0 ) = "01" and c_wb_state.transfer_count = "0011" ) or
                        ( AMU_buf_size( 1 downto 0 ) = "10" and c_wb_state.transfer_count = "0111" ) or 
                        ( AMU_buf_size( 1 downto 0 ) = "11" and c_wb_state.transfer_count = "1111" ) ) then
                     -- we are at the end of this transfer

                     n_wb_state.transfer_count <= ( others => '0' );
                     n_wb_state.state     <= wb_idle;
                     TCU_adrBufREn        <= '1';

                  else
                     n_wb_state.transfer_count <= std_logic_vector( unsigned'( unsigned(c_wb_state.transfer_count) +1 ) );
                  end if;

               else
               -- write burst transfer

                  if c_wb_state.transfer_count = AMU_buf_BE then
                     -- we are at the end of this transfer

                     n_wb_state.transfer_count  <= ( others => '0' );
                     n_wb_state.state           <= wb_idle;
                     TCU_adrBufREn              <= '1';

                  else
                     n_wb_state.transfer_count <= std_logic_vector( unsigned'( unsigned(c_wb_state.transfer_count) +1 ) );
                  end if;

               end if;

            elsif wb_err = '1' then
               -- add error info to the status pipe
               -- and switch to the stall state
               n_wb_state.state     <= wb_write_stall;
               TCU_wb_status_info( STATUS2PLB_W_ERR ) <= '1';
               TCU_stat2plb_en      <= '1';
               wb_tout_reset        <= '1';
            elsif wb_rty = '1' then
               n_wb_state.state     <= wb_write_rty;
               wb_tout_reset        <= '1';
            elsif wb_tout_alarm = '1' then
               n_wb_state.state     <= wb_write_stall;
               TCU_wb_status_info( STATUS2PLB_W_ERR ) <= '1';
               TCU_stat2plb_en      <= '1';
            end if;

      end if;

      --
      -- The WB-spec says, that wb_rty_i terminates a cycle, so wb_stb_o and wb_cyc_o is '0'
      --
      if c_wb_state.state = wb_write_rty then
         n_wb_state.state <= wb_write;
      end if;

      


      if c_wb_state.state = wb_read then

            wb_stb_o       <= '1';
            wb_cyc_o       <= '1';
            wb_we_o        <= '0';
            wb_tout_count  <= '1';

         
            if    wb_ack = '1' or wb_err = '1' then

               wb_tout_reset  <= '1';

               TCU_rbufWEn_t     <= '1';

               if AMU_buf_size = "0000" then
               -- single read transfer

                  n_wb_state.state  <= wb_idle;
                  TCU_adrBufREn     <= '1';

               elsif AMU_buf_size( 3 downto 2 ) = "00" then
               -- read line transfer

                  if (  ( AMU_buf_size( 1 downto 0 ) = "01" and c_wb_state.transfer_count = "0011" ) or
                        ( AMU_buf_size( 1 downto 0 ) = "10" and c_wb_state.transfer_count = "0111" ) or 
                        ( AMU_buf_size( 1 downto 0 ) = "11" and c_wb_state.transfer_count = "1111" ) ) then
                  
                     n_wb_state.transfer_count <= ( others => '0' );
                     n_wb_state.state     <= wb_idle;
                     TCU_adrBufREn        <= '1';

                  else

                     n_wb_state.transfer_count <= std_logic_vector( unsigned'( unsigned(c_wb_state.transfer_count) +1 ) );

                  end if;


               else
               -- burst read transfer

                     if c_wb_state.transfer_count = AMU_buf_BE then
                        n_wb_state.transfer_count  <= ( others => '0' );
                        n_wb_state.state           <= wb_idle;
                        TCU_adrBufREn              <= '1';
                        -- add info to the status fifo
                     else
                        n_wb_state.transfer_count  <= std_logic_vector( unsigned'( unsigned(c_wb_state.transfer_count) +1 ) );
                     end if;

               end if;

            elsif wb_rty = '1' then
               n_wb_state.state     <= wb_read_rty;
               wb_tout_reset        <= '1';


            -----
            --    NOTE: This must be done after all other if-cases (ack, err, rty)
            --    doing this together with ack and err, it results into a wrong behavior,
            --    because the slave gives us a retry in the last timeout cycle
            --
            -- we are still waiting for an reaction of the slave ...
            -- we abort this cycle (we need to drive cyc and stb low)
            -- and continue with the next datum (if its a burst or line transfer)
            --
            elsif wb_tout_alarm = '1' then

               n_wb_state.state     <= wb_read_rty;
               TCU_rbufWEn_t        <= '1';

               if AMU_buf_size = "0000" then
               -- single read transfer

                  n_wb_state.state  <= wb_idle;
                  TCU_adrBufREn     <= '1';

               elsif AMU_buf_size( 3 downto 2 ) = "00" then
               -- read line transfer

                  if (  ( AMU_buf_size( 1 downto 0 ) = "01" and c_wb_state.transfer_count = "0011" ) or
                        ( AMU_buf_size( 1 downto 0 ) = "10" and c_wb_state.transfer_count = "0111" ) or 
                        ( AMU_buf_size( 1 downto 0 ) = "11" and c_wb_state.transfer_count = "1111" ) ) then
                  
                     n_wb_state.transfer_count <= ( others => '0' );
                     n_wb_state.state     <= wb_idle;
                     TCU_adrBufREn        <= '1';

                  else
                     -- we use the retry state to drive stb and cyc low
                     n_wb_state.state     <= wb_read_rty;
                     n_wb_state.transfer_count <= std_logic_vector( unsigned'( unsigned(c_wb_state.transfer_count) +1 ) );
                  end if;
               
               else
               -- burst read transfer

                     if c_wb_state.transfer_count = AMU_buf_BE then
                        n_wb_state.transfer_count  <= ( others => '0' );
                        n_wb_state.state           <= wb_idle;
                        TCU_adrBufREn              <= '1';
                        -- add info to the status fifo
                     else
                        -- we use the retry state to drive stb and cyc low
                        n_wb_state.state     <= wb_read_rty;
                        n_wb_state.transfer_count  <= std_logic_vector( unsigned'( unsigned(c_wb_state.transfer_count) +1 ) );
                     end if;

               end if;

            end if;

      end if;




      --
      --  The generation of the lock-signal. If we are in a transfer (or starting a transfer), which is on 
      --  the plb-size a line or burst transfer and if block transfers are supported, we lock the bus (block transfer)
      -- 
      --
      if ( (   c_wb_state.state = wb_read       or 
               c_wb_state.state = wb_write      or
               c_wb_state.state = wb_read_rty   or
               c_wb_state.state = wb_write_rty  or
               start_wb_w       = '1'           or
               start_wb_r       = '1'  )  and AMU_buf_size /= "0000" and WB_SUPPORT_BLOCK > 0  ) then
         wb_lock_o   <= '1';
      end if;
               


      --
      -- The WB-spec says, that wb_rty_i terminates a cycle, so wb_stb_o and wb_cyc_o is '0'
      --
      if c_wb_state.state = wb_read_rty then
         n_wb_state.state <= wb_read;
         wb_tout_reset        <= '1';
      end if;
        


      if ( c_wb_state.state = wb_write_stall and ( STU_continue = '1' or STU_abort = '1' ) )then
            if STU_abort = '1' then
               n_wb_state.abort           <= '1';
            end if;
            n_wb_state.state <= wb_write;
            wb_tout_reset        <= '1';
      end if;



      if wb_rst_short = '1' then
         TCU_wb_status_info( STATUS2PLB_RST ) <= '1';
         TCU_stat2plb_en         <= '1';
      end if;
      


      for i in 0 to WB_PIC_INTS-1 loop
         
         if pic_int_ahigh_short( i ) = '1' then
            TCU_stat2plb_en                        <= '1';
            TCU_wb_status_info( STATUS2PLB_IRQ )   <= '1';
         end if;
      
      end loop;

      TCU_wb_irq_info   <= ( others => '0' );
      TCU_wb_irq_info( IRQ_INFO_SIZE-1 downto IRQ_INFO_SIZE-WB_PIC_INTS ) <=  pic_int_ahigh_short;


   end process;


   TCU_adr_offset <= c_wb_state.transfer_count;

   -- We drive this signal high, if 
   --    -> there is a wb-error
   --    -> there is a timeout and if we are not getting any response in this clock cycle
   RBF_rdErrIn    <= '1' when (     wb_err_i = '1' 
                                 or ( wb_tout_alarm = '1' and wb_rty_i = '0' and wb_ack_i = '0' ) )
                else '0';

end architecture IMP;
