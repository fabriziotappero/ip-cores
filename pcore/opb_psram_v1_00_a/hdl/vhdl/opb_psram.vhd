----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:07:10 08/30/2006 
-- Design Name: 
-- Module Name:    adc_timing - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity opb_psram is
  generic
    (
      C_BASEADDR       : std_logic_vector(0 to 31) := X"00000000";
      C_HIGHADDR       : std_logic_vector(0 to 31) := X"000000ff";
      C_USER_ID_CODE   : integer                   := 3;
      C_OPB_AWIDTH     : integer                   := 32;
      C_OPB_DWIDTH     : integer                   := 32;
      C_FAMILY         : string                    := "spartan-3";
      -- user generic
      C_PSRAM_DQ_WIDTH : integer                   := 16;
      C_PSRAM_A_WIDTH  : integer                   := 23;
      C_PSRAM_LATENCY  : integer range 0 to 7      := 3;
      C_DRIVE_STRENGTH : integer range 0 to 3      := 1);
  port
    (
      OPB_ABus        : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
      OPB_BE          : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_Clk         : in  std_logic;
      OPB_DBus        : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      OPB_RNW         : in  std_logic;
      OPB_Rst         : in  std_logic;
      OPB_select      : in  std_logic;
      OPB_seqAddr     : in  std_logic;
      Sln_DBus        : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sln_errAck      : out std_logic;
      Sln_retry       : out std_logic;
      Sln_toutSup     : out std_logic;
      Sln_xferAck     : out std_logic;
      -- psram
      PSRAM_Mem_CLK_I : in  std_logic;
      PSRAM_Mem_CLK_O : out std_logic;
      PSRAM_Mem_CLK_T : out std_logic;

      PSRAM_Mem_DQ_I : in  std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);
      PSRAM_Mem_DQ_O : out std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);
      PSRAM_Mem_DQ_T : out std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);

      PSRAM_Mem_A    : out std_logic_vector(C_PSRAM_A_WIDTH-1 downto 0);
      PSRAM_Mem_BE   : out std_logic_vector(C_PSRAM_DQ_WIDTH/8-1 downto 0);
      PSRAM_Mem_WE   : out std_logic;
      PSRAM_Mem_OEN  : out std_logic;
      PSRAM_Mem_CEN  : out std_logic;
      PSRAM_Mem_ADV  : out std_logic;
      PSRAM_Mem_wait : in  std_logic;
      PSRAM_Mem_CRE  : out std_logic);


end opb_psram;

architecture Behavioral of opb_psram is

  component psram_clk_iob
    port (
      clk    : in  std_logic;
      clk_en : in  std_logic;
      clk_q  : out std_logic);
  end component;

  component psram_data_iob
    port (
      iff_d   : in  std_logic;
      iff_q   : out std_logic;
      iff_clk : in  std_logic;
      off_d   : in  std_logic;
      off_q   : out std_logic;
      off_clk : in  std_logic);
  end component;

  component psram_off_iob
    port (
      off_d   : in  std_logic;
      off_q   : out std_logic;
      off_clk : in  std_logic);
  end component;

  component psram_wait_iob
    port (
      iff_d   : in  std_logic;
      iff_q   : out std_logic;
      iff_clk : in  std_logic;
      iff_en  : in  std_logic);
  end component;

  component opb_psram_controller
    generic (
      C_BASEADDR       : std_logic_vector(0 to 31);
      C_HIGHADDR       : std_logic_vector(0 to 31);
      C_USER_ID_CODE   : integer;
      C_OPB_AWIDTH     : integer;
      C_OPB_DWIDTH     : integer;
      C_FAMILY         : string;
      C_PSRAM_DQ_WIDTH : integer;
      C_PSRAM_A_WIDTH  : integer;
      C_PSRAM_LATENCY  : integer range 0 to 7      := 3;
      C_DRIVE_STRENGTH : integer range 0 to 3      := 1);
    port (
      OPB_ABus            : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
      OPB_BE              : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_Clk             : in  std_logic;
      OPB_DBus            : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      OPB_RNW             : in  std_logic;
      OPB_Rst             : in  std_logic;
      OPB_select          : in  std_logic;
      OPB_seqAddr         : in  std_logic;
      Sln_DBus            : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sln_errAck          : out std_logic;
      Sln_retry           : out std_logic;
      Sln_toutSup         : out std_logic;
      Sln_xferAck         : out std_logic;
      PSRAM_Mem_CLK_EN    : out std_logic;
      PSRAM_Mem_DQ_I_int  : in  std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);
      PSRAM_Mem_DQ_O_int  : out std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);
      PSRAM_Mem_DQ_OE_int : out std_logic;
      PSRAM_Mem_A_int     : out std_logic_vector(C_PSRAM_A_WIDTH-1 downto 0);
      PSRAM_Mem_BE_int    : out std_logic_vector(C_PSRAM_DQ_WIDTH/8-1 downto 0);
      PSRAM_Mem_WE_int    : out std_logic;
      PSRAM_Mem_OEN_int   : out std_logic;
      PSRAM_Mem_CEN_int   : out std_logic;
      PSRAM_Mem_ADV_int   : out std_logic;
      PSRAM_Mem_WAIT_int  : in  std_logic;
      PSRAM_Mem_CRE_int   : out std_logic);
  end component;


  -- internal Signals
  signal PSRAM_Mem_CLK_EN    : std_logic;
  signal PSRAM_Mem_DQ_I_int  : std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);
  signal PSRAM_Mem_DQ_O_int  : std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);
  signal PSRAM_Mem_DQ_OE_int : std_logic;
  signal PSRAM_Mem_A_int     : std_logic_vector(C_PSRAM_A_WIDTH-1 downto 0);
  signal PSRAM_Mem_BE_int    : std_logic_vector(C_PSRAM_DQ_WIDTH/8-1 downto 0);
  signal PSRAM_Mem_WE_int    : std_logic;
  signal PSRAM_Mem_OEN_int   : std_logic;
  signal PSRAM_Mem_CEN_int   : std_logic;
  signal PSRAM_Mem_ADV_int   : std_logic;
  signal PSRAM_Mem_WAIT_int  : std_logic;
  signal PSRAM_Mem_CRE_int   : std_logic;

  signal OFF_Clk : std_logic;
  signal wait_en : std_logic;

  
begin


-------------------------------------------------------------------------------
  
  PSRAM_Mem_CLK_T <= '0';               -- allways enable

  psram_clk_iob_1 : psram_clk_iob
    port map (
      clk    => OPB_Clk,
      clk_en => PSRAM_Mem_CLK_EN,
      clk_q  => PSRAM_Mem_CLK_O);

  OFF_CLK <= not OPB_Clk;


  u1 : for i in 0 to C_PSRAM_DQ_WIDTH-1 generate
    psram_dq_iob_1 : psram_data_iob
      port map (
        iff_d   => PSRAM_Mem_DQ_I(i),
        iff_q   => PSRAM_Mem_DQ_I_int(i),
        iff_clk => OPB_Clk,
        off_d   => PSRAM_Mem_DQ_O_int(i),
        off_q   => PSRAM_Mem_DQ_O(i),
        off_clk => OFF_Clk);

    psram_a_off_1 : psram_off_iob
      port map (
        off_d   => PSRAM_Mem_DQ_OE_int,
        off_q   => PSRAM_Mem_DQ_T(i),
        off_clk => OFF_Clk);

  end generate u1;

  u2 : for i in 0 to C_PSRAM_A_WIDTH-1 generate
    psram_a_off_1 : psram_off_iob
      port map (
        off_d   => PSRAM_Mem_A_int(i),
        off_q   => PSRAM_Mem_A(i),
        off_clk => OFF_Clk);
  end generate u2;

  u3 : for i in 0 to C_PSRAM_DQ_WIDTH/8-1 generate
    psram_be_off_1 : psram_off_iob
      port map (
        off_d   => PSRAM_Mem_BE_int(i),
        off_q   => PSRAM_Mem_BE(i),
        off_clk => OFF_Clk);
  end generate u3;

  psram_we_off_1 : psram_off_iob
    port map (
      off_d   => PSRAM_Mem_WE_int,
      off_q   => PSRAM_Mem_WE,
      off_clk => OFF_Clk);  

  psram_oen_off_1 : psram_off_iob
    port map (
      off_d   => PSRAM_Mem_OEN_int,
      off_q   => PSRAM_Mem_OEN,
      off_clk => OFF_Clk);    

  psram_cen_off_1 : psram_off_iob
    port map (
      off_d   => PSRAM_Mem_CEN_int,
      off_q   => PSRAM_Mem_CEN,
      off_clk => OFF_Clk);

  psram_adv_off_1 : psram_off_iob
    port map (
      off_d   => PSRAM_Mem_ADV_int,
      off_q   => PSRAM_Mem_ADV,
      off_clk => OFF_Clk);  

  psram_cre_off_1 : psram_off_iob
    port map (
      off_d   => PSRAM_Mem_CRE_int,
      off_q   => PSRAM_Mem_CRE,
      off_clk => OFF_Clk);

  process(OFF_Clk)
  begin
    if rising_edge(OFF_Clk) then
      if ((PSRAM_Mem_ADV_int = '0') or (PSRAM_Mem_CEN_int = '1'))then
        wait_en <= '1';
      else
        wait_en <= '0';
      end if;

    end if;
  end process;

  psram_wait_iob_1 : psram_wait_iob
    port map (
      iff_d   => PSRAM_Mem_WAIT,
      iff_q   => PSRAM_Mem_WAIT_int,
      iff_clk => OPB_Clk,
      iff_en  => wait_en);

  
  opb_psram_1 : opb_psram_controller
    generic map (
      C_BASEADDR       => C_BASEADDR,
      C_HIGHADDR       => C_HIGHADDR,
      C_USER_ID_CODE   => C_USER_ID_CODE,
      C_OPB_AWIDTH     => C_OPB_AWIDTH,
      C_OPB_DWIDTH     => C_OPB_DWIDTH,
      C_FAMILY         => C_FAMILY,
      C_PSRAM_DQ_WIDTH => C_PSRAM_DQ_WIDTH,
      C_PSRAM_A_WIDTH  => C_PSRAM_A_WIDTH,
      C_PSRAM_LATENCY  => C_PSRAM_LATENCY,
      C_DRIVE_STRENGTH => C_DRIVE_STRENGTH)
    port map (
      OPB_ABus            => OPB_ABus,
      OPB_BE              => OPB_BE,
      OPB_Clk             => OPB_Clk,
      OPB_DBus            => OPB_DBus,
      OPB_RNW             => OPB_RNW,
      OPB_Rst             => OPB_Rst,
      OPB_select          => OPB_select,
      OPB_seqAddr         => OPB_seqAddr,
      Sln_DBus            => Sln_DBus,
      Sln_errAck          => Sln_errAck,
      Sln_retry           => Sln_retry,
      Sln_toutSup         => Sln_toutSup,
      Sln_xferAck         => Sln_xferAck,
      PSRAM_Mem_CLK_EN    => PSRAM_Mem_CLK_EN,
      PSRAM_Mem_DQ_I_int  => PSRAM_Mem_DQ_I_int,
      PSRAM_Mem_DQ_O_int  => PSRAM_Mem_DQ_O_int,
      PSRAM_Mem_DQ_OE_int => PSRAM_Mem_DQ_OE_int,
      PSRAM_Mem_A_int     => PSRAM_Mem_A_int,
      PSRAM_Mem_BE_int    => PSRAM_Mem_BE_int,
      PSRAM_Mem_WE_int    => PSRAM_Mem_WE_int,
      PSRAM_Mem_OEN_int   => PSRAM_Mem_OEN_int,
      PSRAM_Mem_CEN_int   => PSRAM_Mem_CEN_int,
      PSRAM_Mem_ADV_int   => PSRAM_Mem_ADV_int,
      PSRAM_Mem_WAIT_int  => PSRAM_Mem_WAIT_int,
      PSRAM_Mem_CRE_int   => PSRAM_Mem_CRE_int);

end Behavioral;

