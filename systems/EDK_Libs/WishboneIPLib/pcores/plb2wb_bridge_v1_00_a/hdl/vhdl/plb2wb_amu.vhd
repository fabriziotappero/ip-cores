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

entity plb2wb_amu is
   generic(
      SYNCHRONY                     : boolean            := true;
      PIPELINE_DEPTH                : integer            := 2;

      WB_DWIDTH                     : integer            := 4;
      WB_AWIDTH                     : integer            := 32;
      WB_ADR_OFFSET                 : std_logic_vector   := X"00000000";
      WB_ADR_OFFSET_NEG             : std_logic          := '0';

      C_BASEADDR                    : std_logic_vector   := X"FFFFFFFF";
      C_HIGHADDR                    : std_logic_vector   := X"00000000";
      C_STATUS_BASEADDR             : std_logic_vector   := X"FFFFFFFF";
      C_STATUS_HIGHADDR             : std_logic_vector   := X"00000000";
      C_SPLB_AWIDTH                 : integer            := 32;
      C_SPLB_SIZE_WIDTH             : integer            := 4;
      C_SPLB_TYPE_WIDTH             : integer            := 4;
      C_SPLB_BE_WIDTH               : integer            := 4;
      C_SPLB_NATIVE_BE_WIDTH        : integer            := 4;
      C_SPLB_MID_WIDTH              : integer            := 0;
      C_SPLB_SUPPORT_BUR_LINE         : integer            := 1;
      C_SPLB_SUPPORT_ADR_PIPE       : integer           := 1

   );
   port(
      wb_clk_i                      : in  std_logic;


      -- PLB Signals --
      SPLB_Clk                      : in  std_logic;
      plb2wb_rst                      : in  std_logic;
      PLB_SAValid                   : in  std_logic;
      PLB_RNW                       : in  std_logic;
      PLB_ABus                      : in  std_logic_vector( 0 to C_SPLB_AWIDTH      -1 );
      PLB_UABus                     : in  std_logic_vector( 0 to C_SPLB_AWIDTH      -1 );
      PLB_size                      : in  std_logic_vector( 0 to C_SPLB_SIZE_WIDTH  -1 );
      PLB_type                      : in  std_logic_vector( 0 to C_SPLB_TYPE_WIDTH  -1 );
      PLB_BE                        : in  std_logic_vector( 0 to C_SPLB_BE_WIDTH    -1 );
      PLB_masterID                  : in  std_logic_vector( 0 to C_SPLB_MID_WIDTH   -1 );


      TCU_adrBufWEn                 : in  std_logic;
      TCU_adrBufREn                 : in  std_logic;
      TCU_rpipeRdEn                 : in  std_logic;
      TCU_wpipeRdEn                 : in  std_logic;
      TCU_stuWriteSA                : in  std_logic;

      -- Internal signals
      AMU_deviceSelect              : out std_logic;
      AMU_statusSelect              : out std_logic;
      AMU_addrAck                   : OUT std_logic;

      AMU_bufEmpty                  : out std_logic;
      AMU_bufFull                   : out std_logic;
      AMU_buf_RNW                   : out std_logic;
      AMU_buf_size                  : out std_logic_vector( C_SPLB_SIZE_WIDTH       -1 downto 0 );
      AMU_buf_BE                    : out std_logic_vector( C_SPLB_NATIVE_BE_WIDTH  -1 downto 0 );
      AMU_buf_adr                   : out std_logic_vector( WB_AWIDTH               -1 downto 0 );
      AMU_buf_adr_wo                : out std_logic_vector( WB_AWIDTH               -1 downto 0 );    -- address without offset
      AMU_buf_masterID              : out std_logic_vector( 0 to C_SPLB_MID_WIDTH   -1          );


      AMU_pipe_rmID                 : out std_logic_vector( 0 to C_SPLB_MID_WIDTH         -1 );
      AMU_pipe_wmID                 : out std_logic_vector( 0 to C_SPLB_MID_WIDTH         -1 );
      AMU_pipe_size                 : out std_logic_vector( 0 to C_SPLB_SIZE_WIDTH        -1 );
      AMU_pipe_BE                   : out std_logic_vector( 0 to C_SPLB_NATIVE_BE_WIDTH   -1 );
      AMU_pipe_adr                  : out std_logic_vector( 0 to C_SPLB_AWIDTH            -1 );
      AMU_pipe_rStatusSelect        : out std_logic;
      AMU_pipe_wStatusSelect        : out std_logic;

      wb_sel_o                      : out std_logic_vector( WB_DWIDTH/8-1 downto 0  )

   );
end plb2wb_amu;


architecture IMP of plb2wb_amu is

   -- TODO:  muss master ID durch pipe und buffer??
   -- TODO:  remove PLB_type und chkecke PLB_type auf "000" und "110"
   -- TODO:  nur ein comperator fuer status_select -->>  info durch pipe!


   ------------------------------------------------------|
   --                                                    |
   --
   -- Pipelined data types and convertion functions
   --
   type pipeline_data_type is record
      PLB_Abus       : std_logic_vector( 0 to C_SPLB_AWIDTH     -1      );
      PLB_size       : std_logic_vector( 0 to C_SPLB_SIZE_WIDTH -1      );
      PLB_BE         : std_logic_vector( 0 to C_SPLB_NATIVE_BE_WIDTH-1  );
      PLB_masterID   : std_logic_vector( 0 to C_SPLB_MID_WIDTH  -1      );
      statusSelect   : std_logic;                                             -- we transfer the statusSelect through the pipe,
   end record;                                                                -- so we don't need an additional comperator after the pipe
   constant PIPELINE_DATA_WIDTH : integer := C_SPLB_AWIDTH + C_SPLB_SIZE_WIDTH + C_SPLB_NATIVE_BE_WIDTH + C_SPLB_MID_WIDTH + 1;

   --
   -- pipeline_data_type to std_logic_vector
   function pdt_to_vector( data : pipeline_data_type ) return std_logic_vector is
   begin
      return  data.PLB_Abus & data.PLB_size & data.PLB_BE & data.PLB_masterID & data.statusSelect;
   end function pdt_to_vector;




   constant PIPE_ABUS_START      : integer :=  0                                                             ;
   constant PIPE_SIZE_START      : integer :=  C_SPLB_AWIDTH                                                 ;
   constant PIPE_TYPE_START      : integer :=  C_SPLB_AWIDTH + C_SPLB_SIZE_WIDTH                             ;
   constant PIPE_BE_START        : integer :=  C_SPLB_AWIDTH + C_SPLB_SIZE_WIDTH                             ;
   constant PIPE_MASTERID_START  : integer :=  C_SPLB_AWIDTH + C_SPLB_SIZE_WIDTH + C_SPLB_NATIVE_BE_WIDTH    ;

   constant PIPE_ABUS_END        : integer :=  C_SPLB_AWIDTH                     -1                          ;
   constant PIPE_SIZE_END        : integer :=  C_SPLB_AWIDTH + C_SPLB_SIZE_WIDTH -1                          ;
   constant PIPE_TYPE_END        : integer :=  C_SPLB_AWIDTH + C_SPLB_SIZE_WIDTH -1                          ;
   constant PIPE_BE_END          : integer :=  C_SPLB_AWIDTH + C_SPLB_SIZE_WIDTH + C_SPLB_NATIVE_BE_WIDTH -1 ;
   constant PIPE_MASTERID_END    : integer :=  PIPELINE_DATA_WIDTH-2                                         ;

   constant PIPE_STATUS_SELECT   : integer := PIPELINE_DATA_WIDTH-1;

   procedure vector_to_pdt(   signal vector  : in  std_logic_vector;
                              signal pdt     : out pipeline_data_type ) is
   begin
      pdt.PLB_Abus     <= vector( PIPE_ABUS_START      to PIPE_ABUS_END     );
      pdt.PLB_size     <= vector( PIPE_SIZE_START      to PIPE_SIZE_END     );
      pdt.PLB_BE       <= vector( PIPE_BE_START        to PIPE_BE_END       );
      pdt.PLB_masterID <= vector( PIPE_MASTERID_START  to PIPE_MASTERID_END );
      pdt.statusSelect <= vector( PIPE_STATUS_SELECT );        
   end procedure vector_to_pdt;


   --
   -- clear pipeline_data_type
   procedure pdt_clear( signal data : out pipeline_data_type ) is
   begin
      data.PLB_ABus     <= ( others => '0' );
      data.PLB_size     <= ( others => '0' );
      data.PLB_BE       <= ( others => '0' );
      data.PLB_masterID <= ( others => '0' );
      data.statusSelect <= '0';
   end procedure pdt_clear;
   --                                                    |
   ------------------------------------------------------|



   constant ABUF_WIDTH : integer := C_SPLB_AWIDTH + C_SPLB_NATIVE_BE_WIDTH + C_SPLB_SIZE_WIDTH + C_SPLB_MID_WIDTH + 1;


   ------------------------------------------------------|
   --                                                    |
   --    Pipeline-FIFO signals
   --
   signal pipeline_in    : pipeline_data_type;
   signal pipe_data_in   : std_logic_vector( 0 to PIPELINE_DATA_WIDTH-1 );
   
   signal rpipe_rd       : std_logic;
   signal rpipe_wr       : std_logic;
   signal rpipe_data_out : std_logic_vector( 0 to PIPELINE_DATA_WIDTH-1 );
   signal rpipe_out      : pipeline_data_type;
   signal rpipe_empty    : std_logic;
   signal rpipe_full     : std_logic;
   --
   signal wpipe_rd       : std_logic;
   signal wpipe_wr       : std_logic;
   signal wpipe_data_out : std_logic_vector( 0 to PIPELINE_DATA_WIDTH-1 );
   signal wpipe_out      : pipeline_data_type;
   signal wpipe_empty    : std_logic;
   signal wpipe_full     : std_logic;

   signal en_rpipe_outputs : std_logic;
   --                                                    |
   ------------------------------------------------------|



   
   ------------------------------------------------------|
   --                                                    |
   --    Buffer-FIFO signals
   --
   
   signal abuf_dout     : std_logic_vector( 0 to ABUF_WIDTH -1 );
   signal abuf_din      : std_logic_vector( 0 to ABUF_WIDTH -1 );
   signal abuf_wr_en    : std_logic; 
   --                                                    |
   ------------------------------------------------------|


   signal BE_selected         : std_logic_vector( 0 to C_SPLB_NATIVE_BE_WIDTH-1 );


   signal AMU_deviceSelect_t  : std_logic;
   signal AMU_statusSelect_t  : std_logic;

   signal AMU_buf_size_t      : std_logic_vector( C_SPLB_SIZE_WIDTH-1 downto 0 );


begin



   -- We ack. the secondary address, if we write to the write-address-pipe or read-address-pipe
   AMU_addrAck <= rpipe_wr or wpipe_wr;


   -------------
   --
   -- Comperator: device_select is '1' if PLB_ABus selects this IP
   --
   AMU_deviceSelect_t <= '1'     when ( PLB_ABus >= C_BASEADDR and PLB_ABus <= C_HIGHADDR ) else
                         '0';

   AMU_statusSelect_t <= '1'     when ( PLB_ABus >= C_STATUS_BASEADDR and PLB_ABus <= C_STATUS_HIGHADDR ) else
                         '0';





   AMU_deviceSelect   <= AMU_deviceSelect_t;
   AMU_statusSelect   <= AMU_statusSelect_t;

   AMU_buf_size       <= AMU_buf_size_t;


   -----
   --    The selection of the Byte-Enable signals, according to spec:5.6.x
   --
   besel_p : process( PLB_BE, PLB_ABus(28 to 29) ) begin


      -- 128-bit bridge on 128-bit PLB (default)
      BE_selected <= PLB_BE( 0 to C_SPLB_NATIVE_BE_WIDTH-1 );

      --  32-bit bridge on 128-bit PLB
      if C_SPLB_NATIVE_BE_WIDTH = 4 and C_SPLB_BE_WIDTH = 16 then 
         case PLB_ABus(28 to 29) is
            when "00"   => BE_selected <= PLB_BE( 0  to 3  );
            when "01"   => BE_selected <= PLB_BE( 4  to 7  );
            when "10"   => BE_selected <= PLB_BE( 8  to 11 );
            when others => BE_selected <= PLB_BE( 12 to 15 );
         end case;
      end if;


      --  64-bit bridge on 128-bit PLB
      if C_SPLB_NATIVE_BE_WIDTH = 8 and C_SPLB_BE_WIDTH = 16 then
         case PLB_ABus(28) is
            when '0'    => BE_selected <= PLB_BE( 0  to 7 );
            when others => BE_selected <= PLB_BE( 8 to 15 );
         end case;
      end if;


   end process;




   with_adr_pipelinig : if C_SPLB_SUPPORT_ADR_PIPE > 0 generate


   -------------------------------
   --
   -- read and write pipe control signals
   --
   -- -> we only write to a pipeline, if the transfer is supported.
   --
   --
   with_plb_bursts : if C_SPLB_SUPPORT_BUR_LINE > 0 generate

      rpipe_wr <= '1' when     PLB_SAValid   = '1' 
                           and PLB_RNW       = '1' 
                           and rpipe_full    = '0'
                           and ( PLB_size( 0 to 1 ) = "00" or ( PLB_size = "1010" and PLB_BE( 0 to 3 ) /= "0000" ) )
                           and ( AMU_deviceSelect_t = '1' or AMU_statusSelect_t = '1' ) 
                           and ( PLB_type = "000" or PLB_type = "110" )
            else  '0';

      wpipe_wr <= '1' when     PLB_SAValid   = '1' 
                           and PLB_RNW       = '0' 
                           and wpipe_full    = '0' 
                           and ( PLB_size( 0 to 1 ) = "00" or ( PLB_size = "1010" and PLB_BE( 0 to 3 ) /= "0000" ) )
                           and ( AMU_deviceSelect_t = '1' or AMU_statusSelect_t = '1' ) 
                           and ( PLB_type = "000" or PLB_type = "110" )
            else '0';

   end generate with_plb_bursts;

   without_plb_bursts : if C_SPLB_SUPPORT_BUR_LINE = 0 generate

      rpipe_wr <= '1' when     PLB_SAValid   = '1' 
                           and PLB_RNW       = '1' 
                           and rpipe_full    = '0' 
                           and PLB_size      = "0000"
                           and ( AMU_deviceSelect_t = '1' or AMU_statusSelect_t = '1' ) 
                           and ( PLB_type = "000" or PLB_type = "110" )
            else  '0';

      wpipe_wr <= '1' when     PLB_SAValid   = '1' 
                           and PLB_RNW       = '0' 
                           and wpipe_full    = '0' 
                           and PLB_size      = "0000"
                           and ( AMU_deviceSelect_t = '1' or AMU_statusSelect_t = '1' ) 
                           and ( PLB_type = "000" or PLB_type = "110" )
            else '0';

   end generate without_plb_bursts;




   rpipe_rd          <= TCU_rpipeRdEn;
   wpipe_rd          <= TCU_wpipeRdEn;
   en_rpipe_outputs  <= TCU_rpipeRdEn or TCU_stuWriteSA;


   ------
   --
   -- read and write pipe inputs
   --
   vector_to_pdt( rpipe_data_out, rpipe_out );
   vector_to_pdt( wpipe_data_out, wpipe_out );
   pipeline_in.PLB_ABus       <= PLB_ABus;
   pipeline_in.PLB_size       <= PLB_size;
   pipeline_in.PLB_BE         <= BE_selected;
   pipeline_in.PLB_masterID   <= PLB_masterID;
   pipeline_in.statusSelect   <= AMU_statusSelect_t;
   pipe_data_in               <= pdt_to_vector( pipeline_in );


   -----
   --  read and write pipe outputs
   --
   AMU_pipe_adr   <= rpipe_out.PLB_Abus when en_rpipe_outputs = '1' else
                     wpipe_out.PLB_Abus;

   AMU_pipe_BE    <= rpipe_out.PLB_BE when en_rpipe_outputs = '1' else
                     wpipe_out.PLB_BE;

   AMU_pipe_rmID  <= rpipe_out.PLB_masterID;
   AMU_pipe_wmID  <= wpipe_out.PLB_masterID;

   AMU_pipe_size  <= rpipe_out.PLB_size      when en_rpipe_outputs = '1' else
                     wpipe_out.PLB_size;

   AMU_pipe_rStatusSelect <= rpipe_out.statusSelect;
   AMU_pipe_wStatusSelect <= wpipe_out.statusSelect;

   --
   -- read pipe
   --
   read_pipeline : entity plb2wb_bridge_v1_00_a.plb2wb_fifo( IMP )
      generic map(
         DATA_W   => PIPELINE_DATA_WIDTH,
         ADDR_W   => PIPELINE_DEPTH
      )
      port map(
         rd_en    => rpipe_rd,
         wr_en    => rpipe_wr,
         full     => rpipe_full,
         empty    => rpipe_empty,
         clk      => SPLB_Clk,
         rst      => plb2wb_rst,
         dout     => rpipe_data_out,
         din      => pipe_data_in
      );

   --
   -- write pipe
   --
   write_pipeline : entity plb2wb_bridge_v1_00_a.plb2wb_fifo( IMP )
      generic map(
         DATA_W   => PIPELINE_DATA_WIDTH,
         ADDR_W   => PIPELINE_DEPTH
      )
      port map(
         rd_en    => wpipe_rd,
         wr_en    => wpipe_wr,
         full     => wpipe_full,
         empty    => wpipe_empty,
         clk      => SPLB_Clk,
         rst      => plb2wb_rst,
         dout     => wpipe_data_out,
         din      => pipe_data_in
   );

   --
   --
   --------------------------


   end generate with_adr_pipelinig;


   without_adr_pipelining : if C_SPLB_SUPPORT_ADR_PIPE = 0 generate

      pdt_clear( rpipe_out );
      pdt_clear( wpipe_out );

      wpipe_full  <= '1';
      rpipe_full  <= '1';
      wpipe_empty <= '1';
      rpipe_empty <= '1';

   end generate without_adr_pipelining;




   --------------------------
   --
   -- address-buffer input
   --
   --           address               byte enable         size                 master-id             rnw
   abuf_din <= rpipe_out.PLB_ABus & rpipe_out.PLB_BE & rpipe_out.PLB_size & rpipe_out.PLB_masterID & "1"   when TCU_rpipeRdEn   = '1' else
               wpipe_out.PLB_ABus & wpipe_out.PLB_BE & wpipe_out.PLB_size & rpipe_out.PLB_masterID & "0"   when TCU_wpipeRdEn   = '1' else
               PLB_ABus           & BE_selected      & PLB_size           & PLB_masterID           & PLB_RNW;

   ----------------
   --
   -- address-buffer outputs
   --

   -- address-output without offset
   AMU_buf_adr_wo <= abuf_dout( 0 to C_SPLB_AWIDTH-1 );

   -- address-output with offset (but offset is 0)
   adr_offset_g1 : if WB_ADR_OFFSET = X"00000000" generate
      AMU_buf_adr <= abuf_dout( 0 to C_SPLB_AWIDTH-1 );
   end generate;

   -- address-output with offset
   adr_offset_g2 : if WB_ADR_OFFSET /= X"00000000" generate

      -- negative offset
      adr_offset_g3 : if WB_ADR_OFFSET_NEG = '1' generate
         AMU_buf_adr <= std_logic_vector ( unsigned'(unsigned( abuf_dout( 0 to C_SPLB_AWIDTH-1 )) ) - unsigned'(unsigned( WB_ADR_OFFSET )) );
      end generate;
      -- positive offset
      adr_offset_g4 : if WB_ADR_OFFSET_NEG = '0' generate
         AMU_buf_adr <= std_logic_vector ( unsigned'(unsigned( abuf_dout( 0 to C_SPLB_AWIDTH-1 ) )) + unsigned'(unsigned( WB_ADR_OFFSET )) );
      end generate;

   end generate;


   -- note: AMU_buf_BE and wb_sel_o is almoust the same, except the case that we have a burst transfer
   --
   AMU_buf_BE     <= abuf_dout( C_SPLB_AWIDTH to C_SPLB_AWIDTH + C_SPLB_NATIVE_BE_WIDTH-1 );
   -- note: wb_sel_o is "1111" if we have a burst transfer
   wb_sel_o       <= abuf_dout( C_SPLB_AWIDTH to C_SPLB_AWIDTH + C_SPLB_NATIVE_BE_WIDTH-1 )
                           when AMU_buf_size_t( 3 downto 2 ) = "00" else
                     ( others => '1' );

   AMU_buf_size_t    <= abuf_dout( C_SPLB_AWIDTH + C_SPLB_NATIVE_BE_WIDTH to C_SPLB_AWIDTH + C_SPLB_NATIVE_BE_WIDTH + C_SPLB_SIZE_WIDTH-1 );
   AMU_buf_masterID  <= abuf_dout( C_SPLB_AWIDTH + C_SPLB_NATIVE_BE_WIDTH + C_SPLB_SIZE_WIDTH to C_SPLB_AWIDTH + C_SPLB_NATIVE_BE_WIDTH + C_SPLB_SIZE_WIDTH + C_SPLB_MID_WIDTH -1 );
   AMU_buf_RNW       <= abuf_dout( C_SPLB_AWIDTH + C_SPLB_NATIVE_BE_WIDTH + C_SPLB_SIZE_WIDTH + C_SPLB_MID_WIDTH + 1 - 1 );


   -----
   --
   -- address-buffer control signals
   --
   abuf_wr_en <= TCU_adrBufWEn;

   --
   -- address buffer
   --
   addr_buffer_e : entity plb2wb_bridge_v1_00_a.fifo_adr( IMP )
   generic map
   (
      SYNCHRONY         => SYNCHRONY,
      C_SPLB_MID_WIDTH  => C_SPLB_MID_WIDTH     
   )
   port map(
    rd_en               => TCU_adrBufREn,
    wr_en               => abuf_wr_en,
    full                => AMU_bufFull,
    empty               => AMU_bufEmpty,
    wr_clk              => SPLB_Clk,
    rst                 => plb2wb_rst,
    rd_clk              => wb_clk_i,
    dout                => abuf_dout,
    din                 => abuf_din

   );

   --
   --
   --------------------------


end IMP;




