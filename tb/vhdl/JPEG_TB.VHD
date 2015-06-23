--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--
-- Title       : JPEG_TB
-- Design      : JPEG_ENC
-- Author      : Michal Krepa
--
--------------------------------------------------------------------------------
--
-- File        : JPEG_TB.VHD
-- Created     : Sun Mar 1 2009
--
--------------------------------------------------------------------------------
--
--  Description : Testbench top-level
--
--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;
  use IEEE.STD_LOGIC_TEXTIO.ALL;
  
library STD;
  use STD.TEXTIO.ALL;  
  
library work;
  use work.GPL_V2_Image_Pkg.ALL;
  use WORK.MDCT_PKG.all;
  use WORK.MDCTTB_PKG.all;
  use work.JPEG_PKG.all;

entity JPEG_TB is
end JPEG_TB;

--**************************************************************************--

architecture TB of JPEG_TB is
  
  type char_file is file of character;

  file f_capture           : text;
  file f_capture_bin       : char_file;
  constant CAPTURE_ORAM    : string := "OUT_RAM.txt";
  constant CAPTURE_BIN     : string := "test_out.jpg";

  signal CLK               : STD_LOGIC;
  signal RST               : STD_LOGIC;
  
  signal ram_rdaddr        : std_logic_vector(23 downto 0);
  signal ram_q             : std_logic_vector(7 downto 0);
  signal ram_byte          : std_logic_vector(7 downto 0);
  signal ram_wren          : std_logic;
  signal ram_wraddr        : std_logic_vector(23 downto 0); 
  
  signal OPB_ABus          : std_logic_vector(31 downto 0);
  signal OPB_BE            : std_logic_vector(3 downto 0);
  signal OPB_DBus_in       : std_logic_vector(31 downto 0);
  signal OPB_RNW           : std_logic;
  signal OPB_select        : std_logic;
  signal OPB_DBus_out      : std_logic_vector(31 downto 0);
  signal OPB_XferAck       : std_logic;
  signal OPB_retry         : std_logic;
  signal OPB_toutSup       : std_logic;
  signal OPB_errAck        : std_logic;
  signal iram_waddr        : std_logic_vector(19 downto 0);
  signal iram_raddr        : std_logic_vector(19 downto 0);
  signal iram_wdata        : std_logic_vector(C_PIXEL_BITS-1 downto 0);
  signal iram_rdata        : std_logic_vector(C_PIXEL_BITS-1 downto 0);
  signal iram_wren         : std_logic;
  signal iram_rden         : std_logic;     
  signal sim_done          : std_logic;
  signal iram_fifo_afull   : std_logic;
  signal outif_almost_full : std_logic;
  signal count1            : unsigned(15 downto 0);
------------------------------
-- architecture begin
------------------------------       
begin




  ------------------------------
  -- CLKGEN map
  ------------------------------
  U_ClkGen : entity work.ClkGen 
	port map
  (
     CLK            => CLK,                                              
     RST            => RST
	);
  
  ------------------------------
  -- HOST Bus Functional Model
  ------------------------------
  U_HostBFM : entity work.HostBFM
  port map
  (
        CLK            => CLK,
        RST            => RST,
        -- OPB
        OPB_ABus       => OPB_ABus,
        OPB_BE         => OPB_BE,
        OPB_DBus_in    => OPB_DBus_in,
        OPB_RNW        => OPB_RNW,
        OPB_select     => OPB_select,
        OPB_DBus_out   => OPB_DBus_out,
        OPB_XferAck    => OPB_XferAck,
        OPB_retry      => OPB_retry,
        OPB_toutSup    => OPB_toutSup,
        OPB_errAck     => OPB_errAck,
        
        -- IRAM
        iram_wdata     => iram_wdata,
        iram_wren      => iram_wren,
        fifo_almost_full => iram_fifo_afull,
        
        sim_done       => sim_done
    );
  
  ------------------------------
  -- JPEG ENCODER
  ------------------------------
  U_JpegEnc : entity work.JpegEnc
  port map
  (
        CLK                => CLK,
        RST                => RST,

        -- OPB
        OPB_ABus           => OPB_ABus,
        OPB_BE             => OPB_BE,
        OPB_DBus_in        => OPB_DBus_in,
        OPB_RNW            => OPB_RNW,
        OPB_select         => OPB_select,
        OPB_DBus_out       => OPB_DBus_out,
        OPB_XferAck        => OPB_XferAck,
        OPB_retry          => OPB_retry,
        OPB_toutSup        => OPB_toutSup,
        OPB_errAck         => OPB_errAck,  

        -- IMAGE RAM
        iram_wdata         => iram_wdata,
        iram_wren          => iram_wren,
        iram_fifo_afull    => iram_fifo_afull,

        -- OUT RAM
        ram_byte           => ram_byte,
        ram_wren           => ram_wren,  
        ram_wraddr         => ram_wraddr,
        outif_almost_full  => outif_almost_full
    );
  
  -------------------------------------------------------------------
  -- OUT RAM
  -------------------------------------------------------------------
  U_OUT_RAM : entity work.RAMSIM
  generic map
  ( 
      RAMADDR_W     => 18,
      RAMDATA_W     => 8
  )
  port map
  (      
        d           => ram_byte,
        waddr       => ram_wraddr(17 downto 0),
        raddr       => ram_rdaddr(17 downto 0),
        we          => ram_wren,
        clk         => CLK,
                    
        q           => ram_q
  ); 
  
  
  p_capture : process
    variable fLine           : line;
    variable fLine_bin       : line;
  begin
    file_open(f_capture, CAPTURE_ORAM, write_mode);
    file_open(f_capture_bin, CAPTURE_BIN, write_mode);
    
    while sim_done /= '1' loop
      wait until rising_edge(CLK);
      
      if ram_wren = '1' then
        hwrite(fLine, ram_byte);
        write(fLine, string'(" "));
        
        write(f_capture_bin, CHARACTER'VAL(to_integer(unsigned(ram_byte))));
        
      end if;
    
    end loop;
    writeline(f_capture, fLine);
    --writeline(f_capture_bin, fLine_bin);
    
    file_close(f_capture);
    file_close(f_capture_bin);
  
    wait;  
  end process;

  
  backpressure : process(CLK, RST)
  begin
    if RST = '1' then
      outif_almost_full <= '0';
      count1 <= (others => '0');
    elsif CLK'event and CLK = '1' then
      --if count1 = 10000 then
      --  count1 <= (others => '0');
      --  outif_almost_full <= not outif_almost_full;
      --else
      --  count1 <= count1 + 1;
      --end if;
    end if;
  end process;

end TB;
-----------------------------------


--**************************************************************************--
