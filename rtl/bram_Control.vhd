----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Create Date:    12:29:46 15 Apr 2008 
-- Design Name: 
-- Module Name:    bram_Control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  16.04.2008
-- 
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.abb64Package.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram_Control is
    Generic (
             C_ASYNFIFO_WIDTH  :  integer  :=  72 ;
             P_SIMULATION      :  boolean  :=  TRUE
            );
    Port ( 


           -- DMA interface
           DDR_wr_sof               : IN    std_logic;
           DDR_wr_eof               : IN    std_logic;
           DDR_wr_v                 : IN    std_logic;
           DDR_wr_FA                : IN    std_logic;
           DDR_wr_Shift             : IN    std_logic;
           DDR_wr_Mask              : IN    std_logic_vector(2-1 downto 0);
           DDR_wr_din               : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
           DDR_wr_full              : OUT   std_logic;

           DDR_rdc_sof              : IN    std_logic;
           DDR_rdc_eof              : IN    std_logic;
           DDR_rdc_v                : IN    std_logic;
           DDR_rdc_FA               : IN    std_logic;
           DDR_rdc_Shift            : IN    std_logic;
           DDR_rdc_din              : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
           DDR_rdc_full             : OUT   std_logic;

--           DDR_rdD_sof              : OUT   std_logic;
--           DDR_rdD_eof              : OUT   std_logic;
--           DDR_rdDout_V             : OUT   std_logic;
--           DDR_rdDout               : OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);

           -- DDR payload FIFO Read Port
           DDR_FIFO_RdEn            : IN    std_logic; 
           DDR_FIFO_Empty           : OUT   std_logic;
           DDR_FIFO_RdQout          : OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);

           -- Common interface
           DBG_dma_start            : IN    std_logic;
           DDR_Ready                : OUT   std_logic;
           DDR_blinker              : OUT   std_logic;
           Sim_Zeichen              : OUT   std_logic;

           mem_clk                  : IN    std_logic;
           trn_clk                  : IN    std_logic;
           trn_reset_n              : IN    std_logic
          );
end entity bram_Control;


architecture Behavioral of bram_Control is

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------
  COMPONENT DDR_ClkGen
    PORT(
         ddr_Clock              : OUT   std_logic;
         ddr_Clock_n            : OUT   std_logic;
         ddr_Clock90            : OUT   std_logic;
         ddr_Clock90_n          : OUT   std_logic;
         Clk_ddr_rddata         : OUT   std_logic;
         Clk_ddr_rddata_n       : OUT   std_logic;

         ddr_DCM_locked         : OUT   std_logic;

         clk_in                 : IN    std_logic;
         trn_reset_n            : IN    std_logic
        );
  END COMPONENT;


  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------

  COMPONENT asyn_rw_FIFO72
--    GENERIC (
--             OUTPUT_REGISTERED  : BOOLEAN
--            );
    PORT(
        wClk                    : IN     std_logic;
        wEn                     : IN     std_logic;
        Din                     : IN     std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
        aFull                   : OUT    std_logic;
        Full                    : OUT    std_logic;

        rClk                    : IN     std_logic;
        rEn                     : IN     std_logic;
        Qout                    : OUT    std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
        aEmpty                  : OUT    std_logic;
        Empty                   : OUT    std_logic;

        Rst                     : IN     std_logic          
        );
  END COMPONENT;


  component prim_FIFO_plain
      port (
      wr_clk   : IN  std_logic;
      wr_en    : IN  std_logic;
      din      : IN  std_logic_VECTOR(C_ASYNFIFO_WIDTH-1 downto 0);
      full     : OUT std_logic;
      prog_full: OUT std_logic;
      rd_clk   : IN  std_logic;
      rd_en    : IN  std_logic;
      dout     : OUT std_logic_VECTOR(C_ASYNFIFO_WIDTH-1 downto 0);
      empty    : OUT std_logic;
      rst      : IN  std_logic
      );
  end component;

--  component fifo_512x36_v4_2
--    port (
--    wr_clk      : IN  std_logic;
--    wr_en       : IN  std_logic;
--    din         : IN  std_logic_VECTOR(35 downto 0);
--    prog_full   : OUT std_logic;
--    full        : OUT std_logic;
--
--    rd_clk      : IN  std_logic;
--    rd_en       : IN  std_logic;
--    dout        : OUT std_logic_VECTOR(35 downto 0);
--    prog_empty  : OUT std_logic;
--    empty       : OUT std_logic;
--
--    rst         : IN  std_logic
--    );
--  end component;

  component fifo_512x72_v4_4
    port (
    wr_clk      : IN  std_logic;
    wr_en       : IN  std_logic;
    din         : IN  std_logic_VECTOR(C_ASYNFIFO_WIDTH-1 downto 0);
    prog_full   : OUT std_logic;
    full        : OUT std_logic;

    rd_clk      : IN  std_logic;
    rd_en       : IN  std_logic;
    dout        : OUT std_logic_VECTOR(C_ASYNFIFO_WIDTH-1 downto 0);
--    prog_empty  : OUT std_logic;
    empty       : OUT std_logic;

    rst         : IN  std_logic
    );
  end component;


  ---- Dual-port block RAM for packets
  ---    Core output registered
  --
--  component v5bram4096x32
--    port (
--      clka           : IN  std_logic;
--      addra          : IN  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
--      wea            : IN  std_logic_vector(0 downto 0);
--      dina           : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--      douta          : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--
--      clkb           : IN  std_logic;
--      addrb          : IN  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
--      web            : IN  std_logic_vector(0 downto 0);
--      dinb           : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--      doutb          : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0)
--    );
--  end component;

  component bram4096x64
    port (
      clka           : IN  std_logic;
      addra          : IN  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
      wea            : IN  std_logic_vector(7 downto 0);
      dina           : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      douta          : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      clkb           : IN  std_logic;
      addrb          : IN  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
      web            : IN  std_logic_vector(7 downto 0);
      dinb           : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      doutb          : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0)
    );
  end component;

  -- Blinking  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-
  COMPONENT DDR_Blink
    PORT(
           DDR_Blinker              : OUT   std_logic;

           DBG_dma_start            : IN    std_logic;
           DBG_bram_wea             : IN    std_logic_vector(7 downto 0);
           DBG_bram_addra           : IN    std_logic_vector(C_PRAM_AWIDTH-1 downto 0);

           DDR_Write                : IN    std_logic;
           DDR_Read                 : IN    std_logic;
           DDR_Both                 : IN    std_logic;

           ddr_Clock                : IN    std_logic;
           DDr_Rst_n                : IN    std_logic
          );
  END COMPONENT;

  -- ---------------------------------------------------------------------
  signal  ddr_DCM_locked        :  std_logic;
  --  -- ---------------------------------------------------------------------
  signal  Rst_i                 :  std_logic;
  --  -- ---------------------------------------------------------------------
  signal  DDR_Ready_i           :  std_logic;
  --  -- ---------------------------------------------------------------------
  signal  ddr_Clock             :  std_logic;
  signal  ddr_Clock_n           :  std_logic;
  signal  ddr_Clock90           :  std_logic;
  signal  ddr_Clock90_n         :  std_logic;

  signal  Clk_ddr_rddata        :  std_logic;
  signal  Clk_ddr_rddata_n      :  std_logic;

  -- -- --  Write Pipe Channel
  signal  wpipe_wEn             :  std_logic;
  signal  wpipe_Din             :  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal  wpipe_aFull           :  std_logic;
  signal  wpipe_Full            :  std_logic;
  --  Earlier calculate for better timing
  signal  DDR_wr_Cross_Row      :  std_logic;
  signal  DDR_wr_din_r1         :  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DDR_write_ALC         :  std_logic_vector(11-1 downto 0);

  signal  wpipe_rEn             :  std_logic;
  signal  wpipe_Qout            :  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
--  signal  wpipe_aEmpty          :  std_logic;
  signal  wpipe_Empty           :  std_logic;
  signal  wpipe_Qout_latch      :  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);

  -- -- --  Read Pipe Command Channel
  signal  rpipec_wEn            :  std_logic;
  signal  rpipec_Din            :  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal  rpipec_Din_r          :  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
--  signal  rpipec_aFull          :  std_logic;
--  signal  rpipec_Full           :  std_logic;
  --  Earlier calculate for better timing
  signal  DDR_rd_Cross_Row      :  std_logic;
  signal  DDR_rdc_din_r1        :  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DDR_read_ALC          :  std_logic_vector(11-1 downto 0);

--  signal  rpipec_rEn            :  std_logic;
--  signal  rpipec_Qout           :  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
----  signal  rpipec_aEmpty         :  std_logic;
--  signal  rpipec_Empty          :  std_logic;

  -- -- --  Read Pipe Data Channel
  signal  rpiped_wEn            :  std_logic;
  signal  rpiped_Din            :  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal  rpiped_aFull          :  std_logic;
  signal  rpiped_Full           :  std_logic;

--  signal  rpiped_rEn            :  std_logic;
  signal  rpiped_Qout           :  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
--  signal  rpiped_aEmpty         :  std_logic;
--  signal  rpiped_Empty          :  std_logic;


  --   write State machine
  type bram_wrStates is          ( wrST_bram_RESET
                                 , wrST_bram_IDLE
--                                 , wrST_bram_Address
                                 , wrST_bram_1st_Data
                                 , wrST_bram_1st_Data_b2b
                                 , wrST_bram_more_Data
                                 , wrST_bram_last_DW
                                 );

  -- State variables
  signal pseudo_DDR_wr_State     : bram_wrStates;

  --       Block RAM
  signal   pRAM_weA              : std_logic_vector(7 downto 0);
  signal   pRAM_addrA            : std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
  signal   pRAM_dinA             : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   pRAM_doutA            : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal   pRAM_weB              : std_logic_vector(7 downto 0);
  signal   pRAM_addrB            : std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
  signal   pRAM_dinB             : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   pRAM_doutB            : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   pRAM_doutB_r1         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   pRAM_doutB_shifted    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal   wpipe_qout_lo32b      : std_logic_vector(33-1 downto 0);
  signal   wpipe_QW_Aligned      : std_logic;
  signal   pRAM_AddrA_Inc        : std_logic;
  signal   wpipe_read_valid      : std_logic;


  --   read State machine
  type bram_rdStates is          ( rdST_bram_RESET
                                 , rdST_bram_IDLE
--                                 , rdST_bram_b4_LA
                                 , rdST_bram_LA
--                                 , rdST_bram_b4_Length
--                                 , rdST_bram_Length
--                                 , rdST_bram_b4_Address
--                                 , rdST_bram_Address
                                 , rdST_bram_Data
--                                 , rdST_bram_Data_shift
                                 );

  -- State variables
  signal pseudo_DDR_rd_State     : bram_rdStates;

  signal rpiped_rd_counter       : std_logic_vector(10-1 downto 0);
  signal rpiped_wEn_b3           : std_logic;
  signal rpiped_wEn_b2           : std_logic;
  signal rpiped_wEn_b1           : std_logic;
  signal rpiped_wr_EOF           : std_logic;
  signal rpiped_wr_skew          : std_logic;
  signal rpiped_wr_postpone      : std_logic;


begin


  Rst_i              <=  not trn_reset_n;
  DDR_Ready          <=  DDR_Ready_i;

  pRAM_doutB_shifted  <= pRAM_doutB_r1(32-1 downto 0) & pRAM_doutB(64-1 downto 32);

  --  Delay
  Syn_Shifting_pRAM_doutB:
  process ( trn_clk)
  begin
     if trn_clk'event and trn_clk = '1' then
        pRAM_doutB_r1 <= pRAM_doutB;
     end if;
  end process;

  -- -----------------------------------------------
  --
  Syn_DDR_CKE:
  process (trn_clk, Rst_i)
  begin
    if Rst_i = '1' then
       DDR_Ready_i       <=  '0';
    elsif trn_clk'event and trn_clk = '1' then
       DDR_Ready_i       <=  '1';   -- ddr_DCM_locked;
    end if;
  end process;

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------
--  DDR_Clock_Generator: 
--  DDR_ClkGen
--  PORT MAP(
--           ddr_Clock            =>  ddr_Clock             , -- OUT   std_logic;
--           ddr_Clock_n          =>  ddr_Clock_n           , -- OUT   std_logic;
--           ddr_Clock90          =>  ddr_Clock90           , -- OUT   std_logic;
--           ddr_Clock90_n        =>  ddr_Clock90_n         , -- OUT   std_logic;
--           Clk_ddr_rddata       =>  Clk_ddr_rddata        , -- OUT   std_logic;
--           Clk_ddr_rddata_n     =>  Clk_ddr_rddata_n      , -- OUT   std_logic;
--           ddr_DCM_locked       =>  ddr_DCM_locked        , -- OUT   std_logic;
--                                
--           clk_in               =>  mem_clk               , -- IN    std_logic;
--           trn_reset_n          =>  trn_reset_n             -- IN    std_logic
--          );


  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------
--  DDR_pipe_write_fifo:
--  asyn_rw_FIFO
--  GENERIC MAP (
--               OUTPUT_REGISTERED    => TRUE
--              )
--  PORT MAP(
--           wClk          =>  trn_clk         ,
--           wEn           =>  wpipe_wEn       ,
--           Din           =>  wpipe_Din       ,
--           aFull         =>  wpipe_aFull     ,
--           Full          =>  wpipe_Full      ,
--
--           rClk          =>  ddr_Clock       ,  -- ddr_Clock_n     ,
--           rEn           =>  wpipe_rEn       ,
--           Qout          =>  wpipe_Qout      ,
--           aEmpty        =>  wpipe_aEmpty    ,
--           Empty         =>  wpipe_Empty     ,
--
--           Rst           =>  Rst_i           
--          );

--  DDR_pipe_write_fifo:
--  asyn_rw_FIFO72
--  PORT MAP(
--           wClk          =>  trn_clk       ,
--           wEn           =>  wpipe_wEn     ,
--           Din           =>  wpipe_Din     ,
--           aFull         =>  wpipe_aFull   ,
--           Full          =>  open          ,
--
--           rClk          =>  ddr_Clock     ,
--           rEn           =>  wpipe_rEn     ,
--           Qout          =>  wpipe_Qout    ,
--           aEmpty        =>  open          ,
--           Empty         =>  wpipe_Empty   ,
--
--           Rst           =>  Rst_i          
--          );

  DDR_pipe_write_fifo:
  prim_FIFO_plain
  PORT MAP(
    wr_clk       =>  trn_clk      , -- IN  std_logic;
    wr_en        =>  wpipe_wEn    , -- IN  std_logic;
    din          =>  wpipe_Din    , -- IN  std_logic_VECTOR(35 downto 0);
    prog_full    =>  wpipe_aFull  , -- OUT std_logic;
    full         =>  wpipe_Full   , -- OUT std_logic;

    rd_clk       =>  trn_clk    , -- IN  std_logic;
    rd_en        =>  wpipe_rEn    , -- IN  std_logic;
    dout         =>  wpipe_Qout   , -- OUT std_logic_VECTOR(35 downto 0);
    empty        =>  wpipe_Empty  , -- OUT std_logic;

    rst          =>  Rst_i          -- IN  std_logic
    );


  wpipe_wEn              <=  DDR_wr_v;
  wpipe_Din              <=  DDR_wr_Mask & DDR_wr_Shift & '0' & DDR_wr_sof & DDR_wr_eof & DDR_wr_Cross_Row & DDR_wr_FA & DDR_wr_din;
  DDR_wr_full            <=  wpipe_aFull;
  Sim_Zeichen            <=  wpipe_Empty;


  Syn_DDR_wrD_Cross_Row:
  process (trn_clk)
  begin
    if trn_clk'event and trn_clk = '1' then
       DDR_wr_din_r1(64-1 downto 10)     <= (OTHERS=>'0');
       DDR_wr_din_r1( 9 downto  0)     <= DDR_wr_din(9 downto  0) - "100";
    end if;
  end process;

  DDR_write_ALC      <= (DDR_wr_din_r1(10 downto 2) &"00") + ('0' & DDR_wr_din(9 downto 2) &"00");
  DDR_wr_Cross_Row   <= '0';   -- DDR_write_ALC(10);

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------

--  DDR_pipe_read_C_fifo:
--  asyn_rw_FIFO
--  GENERIC MAP (
--               OUTPUT_REGISTERED    => TRUE
--              )
--  PORT MAP(
--           wClk          =>  trn_clk         ,
--           wEn           =>  rpipec_wEn      ,
--           Din           =>  rpipec_Din      ,
--           aFull         =>  rpipec_aFull    ,
--           Full          =>  rpipec_Full     ,
--
--           rClk          =>  ddr_Clock       ,  -- ddr_Clock_n     ,
--           rEn           =>  rpipec_rEn      ,
--           Qout          =>  rpipec_Qout     ,
--           aEmpty        =>  rpipec_aEmpty   ,
--           Empty         =>  rpipec_Empty    ,
--
--           Rst           =>  Rst_i           
--          );
--

--  DDR_pipe_read_C_fifo:
--  asyn_rw_FIFO72
--  PORT MAP(
--           wClk          =>  trn_clk       ,
--           wEn           =>  rpipec_wEn     ,
--           Din           =>  rpipec_Din     ,
--           aFull         =>  rpipec_aFull   ,
--           Full          =>  open          ,
--
--           rClk          =>  ddr_Clock     ,
--           rEn           =>  rpipec_rEn     ,
--           Qout          =>  rpipec_Qout    ,
--           aEmpty        =>  open          ,
--           Empty         =>  rpipec_Empty   ,
--
--           Rst           =>  Rst_i          
--          );

--  DDR_pipe_read_C_fifo:
--  prim_FIFO_plain
--  PORT MAP(
--    wr_clk       =>  trn_clk        , -- IN  std_logic;
--    wr_en        =>  rpipec_wEn     , -- IN  std_logic;
--    din          =>  rpipec_Din     , -- IN  std_logic_VECTOR(35 downto 0);
--    prog_full    =>  rpipec_aFull   , -- OUT std_logic;
--    full         =>  open,   --rpipec_Full    , -- OUT std_logic;
--
--    rd_clk       =>  trn_clk      , -- IN  std_logic;
--    rd_en        =>  rpipec_rEn     , -- IN  std_logic;
--    dout         =>  rpipec_Qout    , -- OUT std_logic_VECTOR(35 downto 0);
--    empty        =>  rpipec_Empty   , -- OUT std_logic;
--
--    rst          =>  Rst_i            -- IN  std_logic
--    );


  rpipec_wEn             <=  DDR_rdc_v;
  rpipec_Din             <=  "00" & DDR_rdc_Shift & '0' & DDR_rdc_sof & DDR_rdc_eof & DDR_rd_Cross_Row & DDR_rdc_FA & DDR_rdc_din;
  DDR_rdc_full           <=  '0';  --rpipec_aFull;


  Syn_DDR_rdC_Cross_Row:
  process (trn_clk)
  begin
    if trn_clk'event and trn_clk = '1' then
       DDR_rdc_din_r1(64-1 downto 10)   <= (OTHERS=>'0');
       DDR_rdc_din_r1( 9 downto  0)     <= DDR_rdc_din(9 downto  0) - "100";
    end if;
  end process;

  DDR_read_ALC       <= (DDR_rdc_din_r1(10 downto 2) &"00") + ('0' & DDR_rdc_din(9 downto 2) &"00");
  DDR_rd_Cross_Row   <= '0';   -- DDR_read_ALC(10);

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------
--  DDR_pipe_read_D_fifo:
--  asyn_rw_FIFO
--  GENERIC MAP (
--               OUTPUT_REGISTERED    => TRUE
--              )
--  PORT MAP(
--           wClk          =>  ddr_Clock,       -- Clk_ddr_rddata  ,  -- ddr_Clock       ,  -- ddr_Clock_n     ,
--           wEn           =>  rpiped_wEn      ,
--           Din           =>  rpiped_Din      ,
--           aFull         =>  rpiped_aFull    ,
--           Full          =>  rpiped_Full     ,
--
--           rClk          =>  trn_clk         ,
--           rEn           =>  DDR_FIFO_RdEn   ,  -- rpiped_rEn      ,
--           Qout          =>  rpiped_Qout     ,
--           aEmpty        =>  open            ,  -- rpiped_aEmpty   ,
--           Empty         =>  DDR_FIFO_Empty  ,  -- rpiped_Empty    ,
--
--           Rst           =>  Rst_i           
--          );

--  DDR_pipe_read_D_fifo:
--  asyn_rw_FIFO72
--  PORT MAP(
--           wClk          =>  ddr_Clock       ,
--           wEn           =>  rpiped_wEn     ,
--           Din           =>  rpiped_Din     ,
--           aFull         =>  rpiped_aFull   ,
--           Full          =>  open          ,
--
--           rClk          =>  trn_clk     ,
--           rEn           =>  DDR_FIFO_RdEn     ,
--           Qout          =>  rpiped_Qout    ,
--           aEmpty        =>  open          ,
--           Empty         =>  DDR_FIFO_Empty   ,
--
--           Rst           =>  Rst_i          
--          );

  DDR_pipe_read_D_fifo:
  prim_FIFO_plain
  PORT MAP(
    wr_clk       =>  trn_clk      , -- IN  std_logic;
    wr_en        =>  rpiped_wEn      , -- IN  std_logic;
    din          =>  rpiped_Din      , -- IN  std_logic_VECTOR(35 downto 0);
    prog_full    =>  rpiped_aFull    , -- OUT std_logic;
    full         =>  open,    -- rpiped_Full     , -- OUT std_logic;

    rd_clk       =>  trn_clk         , -- IN  std_logic;
    rd_en        =>  DDR_FIFO_RdEn   , -- IN  std_logic;
    dout         =>  rpiped_Qout     , -- OUT std_logic_VECTOR(35 downto 0);
    empty        =>  DDR_FIFO_Empty  , -- OUT std_logic;

    rst          =>  Rst_i             -- IN  std_logic
    );


    DDR_FIFO_RdQout      <=  rpiped_Qout(C_DBUS_WIDTH-1 downto 0);



    -- -------------------------------------------------
    -- pkt_RAM instantiate
    -- 
    pkt_RAM:
    bram4096x64
      port map (
         clka      =>    trn_clk  ,
         addra     =>    pRAM_addrA ,
         wea       =>    pRAM_weA   ,
         dina      =>    pRAM_dinA  ,
         douta     =>    pRAM_doutA ,

         clkb      =>    trn_clk  ,
         addrb     =>    pRAM_addrB ,
         web       =>    pRAM_weB   ,
         dinb      =>    pRAM_dinB  ,
         doutb     =>    pRAM_doutB 
       );

    pRAM_weB       <= X"00";
    pRAM_dinB      <= (Others =>'0');


-- ------------------------------------------------
-- write States synchronous
--
   Syn_Pseudo_DDR_wr_States:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         pseudo_DDR_wr_State   <= wrST_bram_RESET;
         pRAM_addrA            <= (OTHERS=>'1');
         pRAM_weA              <= (OTHERS=>'0');
         pRAM_dinA             <= (OTHERS=>'0');
         wpipe_qout_lo32b      <= (OTHERS=>'0');
         wpipe_QW_Aligned      <= '1';
         pRAM_AddrA_Inc        <= '1';

      elsif trn_clk'event and trn_clk = '1' then

        case pseudo_DDR_wr_State  is

          when wrST_bram_RESET =>
             pseudo_DDR_wr_State   <= wrST_bram_IDLE;
             pRAM_addrA            <= (OTHERS=>'1');
             wpipe_QW_Aligned      <= '1';
             wpipe_qout_lo32b      <= (OTHERS=>'0');
             pRAM_weA              <= (OTHERS=>'0');
             pRAM_dinA             <= (OTHERS=>'0');
             pRAM_AddrA_Inc        <= '1';

          when wrST_bram_IDLE =>
             pRAM_addrA            <= wpipe_Qout(14 downto 3);
             pRAM_AddrA_Inc        <= wpipe_Qout(2);
             wpipe_QW_Aligned      <= not wpipe_Qout(69);
             wpipe_qout_lo32b      <= (32=>'1', OTHERS=>'0');
             pRAM_weA              <= (OTHERS=>'0');
             pRAM_dinA             <= pRAM_dinA;
             if wpipe_read_valid = '1' then
               pseudo_DDR_wr_State   <= wrST_bram_1st_Data;  -- wrST_bram_Address;
             else
               pseudo_DDR_wr_State   <= wrST_bram_IDLE;
             end if;


          when wrST_bram_1st_Data =>
             pRAM_addrA          <= pRAM_addrA;
             if wpipe_read_valid = '0' then
               pseudo_DDR_wr_State <= wrST_bram_1st_Data;
               pRAM_weA            <= (OTHERS=>'0'); --pRAM_weA;
               pRAM_dinA           <= pRAM_dinA;
             elsif wpipe_Qout(66)='1' then   -- eof
                if wpipe_QW_Aligned='1' then
                  pseudo_DDR_wr_State <= wrST_bram_IDLE;
                  pRAM_weA            <= not ( wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) 
                                             & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                                             );
                  pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
                elsif wpipe_Qout(70)='1' then     -- mask(0)
                  pseudo_DDR_wr_State <= wrST_bram_IDLE;
                  pRAM_weA            <= not ( wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_dinA           <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                elsif wpipe_Qout(71)='1' then     -- mask(1)
                  pseudo_DDR_wr_State <= wrST_bram_IDLE;
                  pRAM_weA            <= X"F0";
                  pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1-32 downto 0) & X"00000000";
                else
                  pseudo_DDR_wr_State <= wrST_bram_last_DW;
                  pRAM_weA            <= not ( wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_dinA           <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                  wpipe_qout_lo32b    <= '0' & wpipe_Qout(32-1 downto 0);
                end if;
             else
                if wpipe_QW_Aligned='1' then
                  pseudo_DDR_wr_State <= wrST_bram_more_Data;
                  pRAM_weA            <= not ( wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) 
                                             & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                                             );
                  pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
                elsif pRAM_AddrA_Inc='1' then
                  pseudo_DDR_wr_State <= wrST_bram_more_Data;
                  pRAM_weA            <= not ( wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_dinA           <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                  wpipe_qout_lo32b    <= '0' & wpipe_Qout(32-1 downto 0);
                else
                  pseudo_DDR_wr_State <= wrST_bram_1st_Data;
                  pRAM_AddrA_Inc      <= '1';
                  pRAM_weA            <= X"00";
                  pRAM_dinA           <= pRAM_dinA;
                  wpipe_qout_lo32b    <= wpipe_Qout(70) & wpipe_Qout(32-1 downto 0);
                end if;
             end if;

          when wrST_bram_more_Data =>
             if wpipe_read_valid = '0' then
               pseudo_DDR_wr_State <= wrST_bram_more_Data;  -- wrST_bram_1st_Data;
               pRAM_weA            <= (OTHERS=>'0'); --pRAM_weA;
               pRAM_addrA          <= pRAM_addrA;
               pRAM_dinA           <= pRAM_dinA;
             elsif wpipe_Qout(66)='1' then   -- eof
                if wpipe_QW_Aligned='1' then
                  pseudo_DDR_wr_State <= wrST_bram_IDLE;
                  pRAM_weA            <= not ( wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) 
                                             & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                                             );
                  pRAM_addrA          <= pRAM_addrA + '1';
                  pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
                elsif wpipe_Qout(70)='1' then  -- mask(0)
                  pseudo_DDR_wr_State <= wrST_bram_IDLE;
                  pRAM_weA            <= not ( wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_addrA          <= pRAM_addrA + '1';
                  pRAM_dinA           <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                else
                  pseudo_DDR_wr_State <= wrST_bram_last_DW;
                  pRAM_weA            <= not ( wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_addrA          <= pRAM_addrA + '1';
                  pRAM_dinA           <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                  wpipe_qout_lo32b    <= '0' & wpipe_Qout(32-1 downto 0);
                end if;
             else
                if wpipe_QW_Aligned='1' then
                  pseudo_DDR_wr_State <= wrST_bram_more_Data;
                  pRAM_weA            <= not ( wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) 
                                             & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                                             );
                  pRAM_addrA          <= pRAM_addrA + '1';
                  pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
                else
                  pseudo_DDR_wr_State <= wrST_bram_more_Data;
                  pRAM_weA            <= not ( wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_addrA          <= pRAM_addrA + '1';
                  pRAM_dinA           <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                  wpipe_qout_lo32b    <= '0' & wpipe_Qout(32-1 downto 0);
                end if;
             end if;


          when wrST_bram_last_DW =>
--             pseudo_DDR_wr_State   <= wrST_bram_IDLE;
             pRAM_weA              <= X"F0";
             pRAM_addrA            <= pRAM_addrA + '1';
             pRAM_dinA             <= wpipe_qout_lo32b(32-1 downto 0) & X"00000000";
             if wpipe_read_valid = '1' then
               pseudo_DDR_wr_State         <= wrST_bram_1st_Data_b2b;  -- wrST_bram_Address;
               wpipe_Qout_latch            <= wpipe_Qout;
             else
               pseudo_DDR_wr_State         <= wrST_bram_IDLE;
               wpipe_Qout_latch            <= wpipe_Qout;
             end if;


          when wrST_bram_1st_Data_b2b =>
             pRAM_addrA            <= wpipe_Qout_latch(14 downto 3);
             wpipe_QW_Aligned      <= not wpipe_Qout_latch(69);
             if wpipe_read_valid = '0' then
               pseudo_DDR_wr_State <= wrST_bram_1st_Data;
               pRAM_weA            <= (OTHERS=>'0'); --pRAM_weA;
               pRAM_dinA           <= pRAM_dinA;
               pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
               wpipe_qout_lo32b    <= (32=>'1', OTHERS=>'0');
             elsif wpipe_Qout(66)='1' then   -- eof
                if wpipe_Qout_latch(69)='0' then   -- wpipe_QW_Aligned
                  pseudo_DDR_wr_State <= wrST_bram_IDLE;
                  pRAM_weA            <= not ( wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) 
                                             & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                                             );
                  pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
                  pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
                  wpipe_qout_lo32b    <= (32=>'1', OTHERS=>'0');
                elsif wpipe_Qout(70)='1' then     -- mask(0)
                  pseudo_DDR_wr_State <= wrST_bram_IDLE;
                  pRAM_weA            <= not ( X"f"
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_dinA           <= X"00000000" & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                  pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
                  wpipe_qout_lo32b    <= (32=>'1', OTHERS=>'0');
                elsif wpipe_Qout(71)='1' then     -- mask(1)
                  pseudo_DDR_wr_State <= wrST_bram_IDLE;
                  pRAM_weA            <= X"F0";
                  pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1-32 downto 0) & X"00000000";
                  pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
                  wpipe_qout_lo32b    <= (32=>'1', OTHERS=>'0');
                else
                  pseudo_DDR_wr_State <= wrST_bram_last_DW;
                  pRAM_weA            <= not ( X"f"
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_dinA           <= X"00000000" & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                  pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
                  wpipe_qout_lo32b    <= '0' & wpipe_Qout(32-1 downto 0);
                end if;
             else
                if wpipe_Qout_latch(69)='0' then    -- wpipe_QW_Aligned
                  pseudo_DDR_wr_State <= wrST_bram_more_Data;
                  pRAM_weA            <= not ( wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) 
                                             & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                                             );
                  pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
                  pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
                  wpipe_qout_lo32b    <= (32=>'1', OTHERS=>'0');
                elsif wpipe_Qout_latch(2)='1' then   -- pRAM_AddrA_Inc
                  pseudo_DDR_wr_State <= wrST_bram_more_Data;
                  pRAM_weA            <= not ( X"f"
                                             & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                                             );
                  pRAM_dinA           <= X"00000000" & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
                  pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
                  wpipe_qout_lo32b    <= '0' & wpipe_Qout(32-1 downto 0);
                else
                  pseudo_DDR_wr_State <= wrST_bram_1st_Data;
                  pRAM_AddrA_Inc      <= '1';
                  pRAM_weA            <= X"00";
                  pRAM_dinA           <= pRAM_dinA;
                  wpipe_qout_lo32b    <= wpipe_Qout(70) & wpipe_Qout(32-1 downto 0);
                end if;
             end if;


          when OTHERS =>
             pseudo_DDR_wr_State   <= wrST_bram_RESET;
             pRAM_addrA            <= (OTHERS=>'1');
             pRAM_weA              <= (OTHERS=>'0');
             pRAM_dinA             <= (OTHERS=>'0');
             wpipe_qout_lo32b      <= (OTHERS=>'0');
             wpipe_QW_Aligned      <= '1';
             pRAM_AddrA_Inc        <= '1';

        end case;

      end if;
   end process;


   -- 
   Syn_wPipe_read:
   process ( trn_clk, DDR_Ready_i)
   begin
      if DDR_Ready_i = '0' then
         wpipe_rEn         <= '0';
         wpipe_read_valid  <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         wpipe_rEn         <= '1';
         wpipe_read_valid  <= wpipe_rEn and not wpipe_Empty;

      end if;
   end process;



   -- 
   Syn_rPipeC_read:
   process ( trn_clk, DDR_Ready_i)
   begin
      if DDR_Ready_i = '0' then
         rpiped_wr_postpone   <= '0';
         rpiped_wr_skew       <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         if DDR_rdc_v='1' then
            rpiped_wr_postpone  <= DDR_rdc_din(2) and not DDR_rdc_Shift;
            rpiped_wr_skew      <= DDR_rdc_Shift xor DDR_rdc_din(2);
         else
            rpiped_wr_postpone  <= rpiped_wr_postpone;
            rpiped_wr_skew      <= rpiped_wr_skew;
         end if;

      end if;
   end process;

-- ------------------------------------------------
-- Read States synchronous
--
   Syn_Pseudo_DDR_rd_States:
   process ( trn_clk, DDR_Ready_i)
   begin
      if DDR_Ready_i = '0' then
         pseudo_DDR_rd_State   <= rdST_bram_RESET;
--         rpipec_rEn            <= '0';
         pRAM_addrB            <= (OTHERS=>'1');
         rpiped_rd_counter     <= (OTHERS=>'0');
         rpiped_wEn_b3         <= '0';
         rpiped_wr_EOF         <= '0';
         rpipec_Din_r          <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then

        case pseudo_DDR_rd_State  is

          when rdST_bram_RESET =>
             pseudo_DDR_rd_State   <= rdST_bram_IDLE;
--             rpipec_rEn            <= '0';
             rpipec_Din_r          <= (OTHERS=>'0');
             pRAM_addrB            <= (OTHERS=>'1');
             rpiped_rd_counter     <= (OTHERS=>'0');
             rpiped_wEn_b3         <= '0';
             rpiped_wr_EOF         <= '0';

          when rdST_bram_IDLE =>
             pRAM_addrB            <= pRAM_addrB;
             rpiped_rd_counter     <= (OTHERS=>'0');
             rpiped_wEn_b3         <= '0';
             rpiped_wr_EOF         <= '0';
             if rpipec_wEn = '1' then
--               rpipec_rEn          <= '1';
               rpipec_Din_r        <= rpipec_Din;
               pseudo_DDR_rd_State <= rdST_bram_LA;  --rdST_bram_b4_Length;
             else
--               rpipec_rEn          <= '0';
               rpipec_Din_r        <= rpipec_Din_r;
               pseudo_DDR_rd_State <= rdST_bram_IDLE;
             end if;

--          when rdST_bram_b4_LA =>
--             pRAM_addrB            <= pRAM_addrB;
--             rpiped_rd_counter     <= (OTHERS=>'0');
--             rpiped_wEn_b3         <= '0';
--             rpiped_wr_EOF         <= '0';
--             rpipec_rEn            <= '0';
--             pseudo_DDR_rd_State   <= rdST_bram_LA;

          when rdST_bram_LA =>
--             rpipec_rEn            <= '0';
             pRAM_addrB            <= rpipec_Din_r(14 downto 3);
             rpiped_wr_EOF         <= '0';
             rpiped_wEn_b3         <= '0';
             if rpipec_Din_r(2+32)='1' then
               rpiped_rd_counter     <= rpipec_Din_r(11+32 downto 2+32) + '1';
             elsif rpipec_Din_r(2)='1' and rpipec_Din_r(69)='1' then
               rpiped_rd_counter     <= rpipec_Din_r(11+32 downto 2+32) + "10";
             elsif rpipec_Din_r(2)='0' and rpipec_Din_r(69)='1' then
               rpiped_rd_counter     <= rpipec_Din_r(11+32 downto 2+32) + "10";
             elsif rpipec_Din_r(2)='1' and rpipec_Din_r(69)='0' then
               rpiped_rd_counter     <= rpipec_Din_r(11+32 downto 2+32);
             else
               rpiped_rd_counter     <= rpipec_Din_r(11+32 downto 2+32);
             end if;

--             elsif rpipec_Qout(2)='1' then
--               rpiped_rd_counter     <= rpipec_Qout(11+32 downto 2+32) + "10";
--             elsif rpipec_Qout(69)='1' then
--               rpiped_rd_counter     <= rpipec_Qout(11+32 downto 2+32) + "10";
--             else
--               rpiped_rd_counter     <= rpipec_Qout(11+32 downto 2+32);
--             end if;
             pseudo_DDR_rd_State   <= rdST_bram_Data;


          when rdST_bram_Data =>
--             rpipec_rEn            <= '0';
             if rpiped_rd_counter = CONV_STD_LOGIC_VECTOR(2, 10) then
               pRAM_addrB            <= pRAM_addrB + '1';
               rpiped_rd_counter     <= rpiped_rd_counter;
               rpiped_wEn_b3         <= '1';
               rpiped_wr_EOF         <= '1';
               pseudo_DDR_rd_State   <= rdST_bram_IDLE;
             elsif rpiped_aFull = '1' then
               pRAM_addrB            <= pRAM_addrB;
               rpiped_rd_counter     <= rpiped_rd_counter;
               rpiped_wEn_b3         <= '0';
               rpiped_wr_EOF         <= '0';
               pseudo_DDR_rd_State   <= rdST_bram_Data;
             else
               pRAM_addrB            <= pRAM_addrB + '1';
               rpiped_rd_counter     <= rpiped_rd_counter - "10";
               rpiped_wEn_b3         <= '1';
               rpiped_wr_EOF         <= '0';
               pseudo_DDR_rd_State   <= rdST_bram_Data;
             end if;


          when OTHERS =>
--               rpipec_rEn            <= '0';
               pRAM_addrB            <= pRAM_addrB;
               rpiped_rd_counter     <= rpiped_rd_counter;
               rpiped_wEn_b3         <= '0';
               rpiped_wr_EOF         <= '0';
               pseudo_DDR_rd_State   <= rdST_bram_RESET;

        end case;

      end if;
   end process;



   Syn_Pseudo_DDR_rdd_write:
   process ( trn_clk, DDR_Ready_i)
   begin
      if DDR_Ready_i = '0' then
         rpiped_wEn_b1      <= '0';
         rpiped_wEn_b2      <= '0';
         rpiped_wEn         <= '0';
         rpiped_Din         <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         rpiped_wEn_b2      <= rpiped_wEn_b3;
         rpiped_wEn_b1      <= rpiped_wEn_b2;
         if rpiped_wr_skew='1' then
--           rpiped_wEn         <= rpiped_wEn_b2;
           rpiped_wEn         <= (rpiped_wEn_b2 and not rpiped_wr_postpone)
                              or (rpiped_wEn_b1 and rpiped_wr_postpone);
           rpiped_Din         <= "0000" & '0' & rpiped_wr_EOF & "00" & pRAM_doutB_shifted;
         else
--           rpiped_wEn         <= rpiped_wEn_b2;
           rpiped_wEn         <= (rpiped_wEn_b2 and not rpiped_wr_postpone)
                              or (rpiped_wEn_b1 and rpiped_wr_postpone);
           rpiped_Din         <= "0000" & '0' & rpiped_wr_EOF & "00" & pRAM_doutB;
         end if;

      end if;
   end process;


  -- 
  DDR_Blinker_Module:
  DDR_Blink
  PORT MAP(
           DDR_Blinker          =>  DDR_Blinker    ,

           DBG_dma_start        =>  DBG_dma_start  ,
           DBG_bram_wea         =>  pRAM_weA       ,
           DBG_bram_addra       =>  pRAM_addrA     ,

           DDR_Write            =>  wpipe_rEn      ,
           DDR_Read             =>  rpiped_wEn     ,
           DDR_Both             =>  '0'            ,

           ddr_Clock            =>  trn_clk        ,
           DDr_Rst_n            =>  DDR_Ready_i      -- DDR_CKE_i      
          );


end architecture Behavioral;
