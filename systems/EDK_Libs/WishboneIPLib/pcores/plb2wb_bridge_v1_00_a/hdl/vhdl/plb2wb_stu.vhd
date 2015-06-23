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

library plb2wb_bridge_v1_00_a;
use plb2wb_bridge_v1_00_a.plb2wb_pkg.all;

entity plb2wb_stu is
   generic(
      SYNCHRONY                     : boolean            := true;
      WB_DWIDTH                     : integer            := 32;
      WB_AWIDTH                     : integer            := 32;
      C_SPLB_AWIDTH                 : integer            := 32;
      C_SPLB_DWIDTH                 : integer            := 128;
      C_SPLB_MID_WIDTH              : integer            := 3;
      C_SPLB_NUM_MASTERS            : integer            := 1;
      C_SPLB_SIZE_WIDTH             : integer            := 4;
      C_SPLB_BE_WIDTH               : integer            := 4;
      C_SPLB_NATIVE_BE_WIDTH        : integer            := 4;
      C_SPLB_NATIVE_DWIDTH          : integer            := 32


   );
   port(

      wb_clk_i                      : in  std_logic;
      SPLB_Clk                      : in  std_logic;
      SPLB_Rst                      : in  std_logic;

      PLB_size                      : in  std_logic_vector( 0 to C_SPLB_SIZE_WIDTH  -1 );
      PLB_wrDBus                    : in  std_logic_vector( 0 to C_SPLB_DWIDTH      -1 );
      PLB_masterID                  : in  std_logic_vector( 0 to C_SPLB_MID_WIDTH   -1 );
      PLB_BE                        : in  std_logic_vector( 0 to C_SPLB_BE_WIDTH    -1 );

      PLB_ABus                      : in  std_logic_vector( 0 to C_SPLB_AWIDTH      -1 );

      --TODO  remove this four signals,  they are not used!
      AMU_masterID                  : in  std_logic_vector( 0 to C_SPLB_MID_WIDTH   -1 );
      AMU_buf_masterID              : in  std_logic_vector( 0 to C_SPLB_MID_WIDTH   -1 );
      AMU_pipe_adr                  : in  std_logic_vector( 0 to C_SPLB_AWIDTH      -1 );
      AMU_buf_adr_wo                : in  std_logic_vector( WB_AWIDTH-1 downto 0       );    -- without offset

      ----
      --  When TCU_stat2plb_en is '1', TCU_wb_status_info is written to
      --  the status pipe, which transfers this info to the plb-side
      TCU_wb_status_info            : in  std_logic_vector( STATUS2PLB_INFO_SIZE-1 downto 0 ) ;
      TCU_stat2plb_en               : in  std_logic;


      ----
      -- This two signals says if we either do a write transfer, which is 
      -- addressed directly with PLB_ABus or if we do a write transfer
      -- which is addressed with a secondary address AMU_pipe_adr 
      -- (which comes from address-pipe -> see amu)
      --
      TCU_stuWritePA                : in  std_logic;     -- write, addressed with primary address
      TCU_stuWriteSA                : in  std_logic;     -- write, addressed with second. address

      ----
      -- This two signals says, if we must latch the primary address 
      -- from PLB_ABus or the secondary address from AMU_pipe_adr
      -- With latching the address, the read-bus STU_rdDBus has 
      -- assigned the desired data
      --
      TCU_stuLatchPA                : in  std_logic;
      TCU_stuLatchSA                : in  std_logic;


      -- This signal enalbes the read-bus STU_rdDBus.
      -- If this signal is '0', STU_rdDBus is complete '0'
      --
      TCU_enStuRdDBus               : in  std_logic;
      TCU_wb_irq_info               : in  std_logic_vector( IRQ_INFO_SIZE-1 downto 0 );
      Sl_rdWdAddr                   : in  std_logic_vector( 0 to 3 );
      Sl_MIRQ                       : out std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );

      WBF_wBus                      : in  std_logic_vector( 0 to C_SPLB_NATIVE_DWIDTH  -1 );

      PLB2WB_IRQ                    : out  std_logic;


      ----
      -- This two signals are used on the wb-side to decide if a transfer must be
      -- continued or aborted
      --
      STU_abort                     : out std_logic;
      STU_continue                  : out std_logic;


      STU_full                      : out std_logic;
      STU_rdDBus                    : out std_logic_vector( 0 to C_SPLB_DWIDTH-1 );

      -- The reset-signal, which does a software reset
      STU_softReset                 : out std_logic
   );

end entity plb2wb_stu;

architecture IMP of plb2wb_stu is

   type  reg_type is array( integer range<> ) of std_logic_vector( 0 to C_SPLB_NATIVE_DWIDTH-1 );

   signal status_regs      : reg_type( 0 to 3);
   signal status_reg_out   : std_logic_vector( 0 to C_SPLB_NATIVE_DWIDTH-1 );




   -------
   --
   --    This two bit are used for read transfers from our status registers.
   --    We DON'T need this for write transfers, because we write in 
   --    one clock cycle ( we don't need to latch the address ).
   --
   --    This address-register is loaded with TCU_stuLatchPA or TCU_stuLatchSA
   --
   signal address_reg      : std_logic_vector( 0 to 1 );

   signal stat2plb_rd_en   : std_logic;
   signal stat2plb_empty   : std_logic;
   signal stat2plb_dout    : std_logic_vector( IRQ_INFO_SIZE + C_SPLB_NATIVE_DWIDTH + C_SPLB_AWIDTH + C_SPLB_MID_WIDTH + STATUS2PLB_INFO_SIZE -1 downto 0 );
   signal stat2plb_din     : std_logic_vector( IRQ_INFO_SIZE + C_SPLB_NATIVE_DWIDTH + C_SPLB_AWIDTH + C_SPLB_MID_WIDTH + STATUS2PLB_INFO_SIZE -1 downto 0 );

   signal stat2wb_rd_en   : std_logic;
   signal stat2wb_wr_en   : std_logic;
   signal stat2wb_empty   : std_logic;
   signal stat2wb_full    : std_logic;
   signal stat2wb_dout    : std_logic_vector( 1-1 downto 0 );
   signal stat2wb_din     : std_logic_vector( 1-1 downto 0 );

   signal addr_with_offset : std_logic_vector( 0 to 31 );

   signal STU_softReset_t  : std_logic;
   signal soft_reset_count : std_logic_vector( 0 to 1 );    -- counter, implemented with gray-code



   signal plb2wb_rst       : std_logic;
   signal status_loaded    : std_logic;

   signal wb_status_info : std_logic_vector( STATUS2PLB_INFO_SIZE-1 downto 0  );
   signal wb_master_id   : std_logic_vector( 0 to C_SPLB_MID_WIDTH -1         );

   
   signal Sl_MIRQ_t   : std_logic_vector( C_SPLB_NUM_MASTERS -1    downto 0  );


begin

   Sl_MIRQ <= ( others => '0' );
   

   plb2wb_rst     <= SPLB_Rst or STU_softReset_t;
   STU_softReset  <= STU_softReset_t;


   status_reg_out <= status_regs(0) when std_logic_vector( unsigned (  address_reg ) + unsigned( Sl_rdWdAddr( 2 to 3 ) ) )= "00"  else
                     status_regs(1) when std_logic_vector( unsigned (  address_reg ) + unsigned( Sl_rdWdAddr( 2 to 3 ) ) )= "01"  else
                     status_regs(2) when std_logic_vector( unsigned (  address_reg ) + unsigned( Sl_rdWdAddr( 2 to 3 ) ) )= "10"  else     
                     status_regs(3);


   gen_128 : if C_SPLB_DWIDTH = 128 generate
      STU_rdDBus  <= status_reg_out & status_reg_out & status_reg_out & status_reg_out when TCU_enStuRdDBus = '1' else
                                                ( others => '0' );
   end generate;

   gen_64 : if C_SPLB_DWIDTH = 64 generate
      STU_rdDBus  <= status_reg_out & status_reg_out                       when TCU_enStuRdDBus = '1' else
                                                ( others => '0' );
   end generate;

   gen_32 : if C_SPLB_DWIDTH = 32 generate
      STU_rdDBus  <= status_reg_out                                  when TCU_enStuRdDBus = '1' else
                                                ( others => '0' );
   end generate;




   stat2plb : entity plb2wb_bridge_v1_00_a.fifo_stat2plb
      generic map(
         SYNCHRONY         => SYNCHRONY,
         WB_DWIDTH         => WB_DWIDTH,
         WB_AWIDTH         => WB_AWIDTH,
         C_SPLB_MID_WIDTH  => C_SPLB_MID_WIDTH
         )
      port map(
         rd_en    => stat2plb_rd_en,
         wr_en    => TCU_stat2plb_en,
         full     => STU_full,
         empty    => stat2plb_empty,
         wr_clk   => wb_clk_i,
         rst      => plb2wb_rst,
         rd_clk   => SPLB_Clk,
         dout     => stat2plb_dout,
         din      => stat2plb_din
      );
   


   stat2wb : entity plb2wb_bridge_v1_00_a.fifo_stat2wb
      generic map(
         SYNCHRONY   => SYNCHRONY
      )
      port map(
         rd_en    => stat2wb_rd_en,
         wr_en    => stat2wb_wr_en,
         full     => stat2wb_full,
         empty    => stat2wb_empty,
         wr_clk   => SPLB_Clk,
         rst      => plb2wb_rst,
         rd_clk   => wb_clk_i,
         dout     => stat2wb_dout,
         din      => stat2wb_din
      );

   stat2plb_din   <= TCU_wb_irq_info &  AMU_buf_adr_wo & WBF_wBus & TCU_wb_status_info & AMU_buf_masterID;

   wb_status_info <=  stat2plb_dout( STATUS2PLB_INFO_SIZE + C_SPLB_MID_WIDTH -1 downto C_SPLB_MID_WIDTH );

   wb_master_id   <= stat2plb_dout( C_SPLB_MID_WIDTH-1 downto 0 );




   status_reg_p : process( SPLB_Clk, SPLB_Rst, stat2plb_rd_en, Sl_MIRQ_t, status_regs, plb2wb_rst  )
   begin

      if plb2wb_rst = '1' then
         status_regs    <= ( others => ( others => '0' ) );
         address_reg    <= ( others => '0'               );
         status_loaded  <= '0';
      elsif SPLB_Clk'event and SPLB_Clk = '1' then


         if TCU_stuLatchPA = '1' then
            address_reg <= PLB_ABus( 28 to 29 );
         elsif TCU_stuLatchSA = '1' then
            address_reg <= AMU_pipe_adr( 28 to 29 );
         end if;


         ----
         -- Write acceess to the first regser     address = "00"
         --    -> clears the irq 
         if ( ( TCU_stuWritePA = '1' and  PLB_ABus( 28 to 29 ) = "00"      ) or
              ( TCU_stuWriteSA = '1' and  AMU_pipe_adr( 28 to 29 ) = "00"  ) )
         then
            status_loaded    <= '0';
            status_regs( 0 ) <= ( others => '0' );
         end if;


         -----
         --
         -- if there is something in the pipe, we save it 
         -- (we don't save the bit about the finished transfer!)
         --
         -- NOTE: This has a higher priority than writing from plb-bus!!
         --
         --
         if (  stat2plb_rd_en = '1' ) then
            status_regs(0)(0 to STATUS2PLB_INFO_SIZE-1 ) <= status_regs(0)(0 to STATUS2PLB_INFO_SIZE-1 ) or wb_status_info( STATUS2PLB_INFO_SIZE-1 downto 0 );
            status_loaded <= '1';


            status_regs(3)          <= stat2plb_dout( IRQ_INFO_SIZE        +
                                                      C_SPLB_AWIDTH        +
                                                      C_SPLB_NATIVE_DWIDTH + 
                                                      STATUS2PLB_INFO_SIZE + 
                                                      C_SPLB_MID_WIDTH     -1 
                                                               downto 
                                                      C_SPLB_AWIDTH        +
                                                      C_SPLB_NATIVE_DWIDTH +
                                                      STATUS2PLB_INFO_SIZE + 
                                                      C_SPLB_MID_WIDTH    );


            status_regs(2)          <= stat2plb_dout( C_SPLB_AWIDTH        + C_SPLB_NATIVE_DWIDTH + 
                                                      STATUS2PLB_INFO_SIZE + C_SPLB_MID_WIDTH -1 
                                                               downto 
                                                      C_SPLB_NATIVE_DWIDTH + STATUS2PLB_INFO_SIZE + 
                                                      C_SPLB_MID_WIDTH    );



            status_regs(1)          <= stat2plb_dout( C_SPLB_NATIVE_DWIDTH + STATUS2PLB_INFO_SIZE + 
                                                      C_SPLB_MID_WIDTH     -1 
                                                               downto 
                                                      STATUS2PLB_INFO_SIZE + C_SPLB_MID_WIDTH );

            status_regs(0)( C_SPLB_NATIVE_DWIDTH - C_SPLB_MID_WIDTH    to C_SPLB_NATIVE_DWIDTH -1 ) <= wb_master_id;



         end if;

      end if;




   end process;


   stat2plb_rd_en <= '1' when ( stat2plb_empty = '0' and status_loaded = '0' and TCU_stuWritePA = '0' and TCU_stuWriteSA = '0' ) else
                     '0';


   --------
   --
   --   Interrupt generation
   --
   Sl_MIRQ_t   <= ( others => '0' );   -- is not supported by xilinx!
   PLB2WB_IRQ  <= status_regs(0)( 2 ) or status_regs(0)( 1 ) or status_regs(0)( 0 ); 






   ----------
   -- 
   --    Handling of write access to the status registers 
   --       (except clearing the irq)
   --       - soft reset (for 4 clock cycles)   address = "11"
   --       - continue failed write transfer    address = "01"
   --       - abort failed write transfer       address = "10"
   --
   status_state_p : process( SPLB_Clk, SPLB_Rst, TCU_stuWritePA, PLB_ABus, TCU_stuWriteSA, AMU_pipe_adr )
   begin

      if SPLB_Rst = '1' then
         soft_reset_count  <= ( others => '0' );
      elsif SPLB_Clk'event and SPLB_Clk = '1' then

         -- if the status-address range is selected:
         -- do a soft reset, depending on the address
         if (  ( soft_reset_count = "00" and TCU_stuWritePA = '1' and PLB_ABus( 28 to 29 ) = "11"      ) or 
               ( soft_reset_count = "00" and TCU_stuWriteSA = '1' and AMU_pipe_adr( 28 to 29 ) = "11"  ) ) then
            soft_reset_count <= "10";
         end if;

         if soft_reset_count = "10" then
            soft_reset_count <= "11";
         elsif soft_reset_count = "11" then
            soft_reset_count <= "01";
         elsif soft_reset_count = "01" then
            soft_reset_count <= "00";
         end if;



      end if;


      -- if the status-address range is selected:
      -- add a continue or abort information to the fifo, depending on the address
      --
      stat2wb_din    <= "0";
      stat2wb_wr_en  <= '0';
      if (  ( TCU_stuWritePA = '1' and PLB_ABus( 28 to 29 ) = "01"      ) or 
            ( TCU_stuWriteSA = '1' and AMU_pipe_adr( 28 to 29 ) = "01"  ) ) then
         stat2wb_din    <= STATUS_CONTINUE;
         stat2wb_wr_en  <= '1';
      elsif (  ( TCU_stuWritePA = '1' and PLB_ABus( 28 to 29 ) = "10"      ) or 
            ( TCU_stuWriteSA = '1' and AMU_pipe_adr( 28 to 29 ) = "10"  ) ) then
         stat2wb_din    <= STATUS_ABORT;
         stat2wb_wr_en  <= '1';
      end if;

   end process;


   stat2wb_rd_en <= not stat2wb_empty;
   STU_continue <= '1' when stat2wb_empty = '0' and stat2wb_dout = STATUS_CONTINUE else
                   '0';
   STU_abort    <= '1' when stat2wb_empty = '0' and stat2wb_dout = STATUS_ABORT    else
                   '0';



   STU_softReset_t   <= '0' when soft_reset_count = "00" else
                        '1';



end architecture IMP;
