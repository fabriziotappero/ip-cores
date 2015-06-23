-------------------------------------------------------------------------------
-- File        : double_fifo_muxed_read.vhdl
-- Description : Double_Fifo_Muxed_Read buffer for hibi v.2 interface
--               Includes two fifos and a special multiplexer
--               so that the reader sees only one fifo. Multiplexer
--               selects addr+data first from fifo 0 (i.e. it has a higher priority)
-- Author      : Erno Salminen
-- Date        : 07.02.2003
-- Modified    : 
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity double_fifo_muxed_read is

  generic (
    Data_Width :    integer := 0;
    Depth_0    :    integer := 0;
    Depth_1    :    integer := 0;
    Comm_Width :    integer := 0
    );
  port (
    Clk        : in std_logic;
    Rst_n      : in std_logic;

    Data_In_0            : in  std_logic_vector ( Data_Width-1 downto 0);
    Comm_In_0            : in  std_logic_vector ( Comm_Width-1 downto 0);
    Addr_Valid_In_0      : in  std_logic;
    Write_Enable_In_0    : in  std_logic;
    One_Place_Left_Out_0 : out std_logic;
    Full_Out_0           : out std_logic;

    Data_In_1            : in  std_logic_vector ( Data_Width-1 downto 0);
    Comm_In_1            : in  std_logic_vector ( Comm_Width-1 downto 0);
    Addr_Valid_In_1      : in  std_logic;
    Write_Enable_In_1    : in  std_logic;
    One_Place_Left_Out_1 : out std_logic;
    Full_Out_1           : out std_logic;

    Read_Enable_In    : in  std_logic;
    Data_Out          : out std_logic_vector ( Data_Width-1 downto 0);
    Comm_Out          : out std_logic_vector ( Comm_Width-1 downto 0);
    Addr_Valid_Out    : out std_logic;
    Empty_Out         : out std_logic;
    One_Data_Left_Out : out std_logic
    );
end double_fifo_muxed_read;



architecture structural of double_fifo_muxed_read is

  


  component fifo   
    generic (
      width : integer := 0;
      depth : integer := 0);

    port (
      Clk            : in  std_logic;
      Rst_n          : in  std_logic;
      Data_In        : in  std_logic_vector (width-1 downto 0);
      Write_Enable   : in  std_logic;
      One_Place_Left : out std_logic;
      Full           : out std_logic;

      Read_Enable    : in  std_logic;
      Data_Out       : out std_logic_vector (width-1 downto 0);
      Empty          : out std_logic;
      One_Data_Left  : out std_logic
      );
  end component; --fifo;

  
  component fifo_mux_read 
    generic (
      Data_Width         :     integer := 0;
      Comm_Width         :     integer := 0
      );
    port (
      Clk                : in  std_logic;
      Rst_n              : in  std_logic;

      Data_0_In          : in  std_logic_vector (Data_Width-1 downto 0);
      Comm_0_In          : in  std_logic_vector (Comm_Width-1 downto 0);
      Addr_Valid_0_In    : in  std_logic;
      One_Data_Left_0_In : in  std_logic;
      Empty_0_In         : in  std_logic;
      RE_0_Out           : out std_logic;

      Data_1_In          : in  std_logic_vector (Data_Width-1 downto 0);
      Comm_1_In          : in  std_logic_vector (Comm_Width-1 downto 0);
      Addr_Valid_1_In    : in  std_logic;
      One_Data_Left_1_In : in  std_logic;
      Empty_1_In         : in  std_logic;
      RE_1_Out           : out std_logic;

      Read_Enable_In    : in  std_logic;
      Data_Out          : out std_logic_vector (Data_Width-1 downto 0);
      Comm_Out          : out std_logic_vector (Comm_Width-1 downto 0);      
      Addr_Valid_Out    : out std_logic;
      One_Data_Left_Out : out std_logic;
      Empty_Out         : out std_logic
      );
  end component; --fifo_mux_read;


  signal Data_AV_Comm_In_0 : std_logic_vector ( 1 + Comm_Width + Data_Width-1 downto 0);
  signal Data_AV_Comm_In_1 : std_logic_vector ( 1 + Comm_Width + Data_Width-1 downto 0);

  signal Data_AV_Comm_0_Mux : std_logic_vector ( 1 + Comm_Width + Data_Width-1 downto 0);
  signal Data_0_Mux         : std_logic_vector ( Data_Width-1 downto 0);
  signal Comm_0_Mux         : std_logic_vector ( Comm_Width-1 downto 0);
  signal AV_0_Mux           : std_logic;

  signal Data_AV_Comm_1_Mux : std_logic_vector ( 1 + Comm_Width + Data_Width-1 downto 0);
  signal Data_1_Mux         : std_logic_vector ( Data_Width-1 downto 0);
  signal Comm_1_Mux         : std_logic_vector ( Comm_Width-1 downto 0);
  signal AV_1_Mux           : std_logic;

  signal Read_Enable_Mux_0   : std_logic;
  signal Empty_0_Mux         : std_logic;
  signal One_Data_Left_0_Mux : std_logic;

  signal Read_Enable_Mux_1   : std_logic;
  signal Empty_1_Mux         : std_logic;
  signal One_Data_Left_1_Mux : std_logic;


  signal Tie_High : std_logic;
  signal Tie_Low  : std_logic;


begin  -- structural
  -- Check generics
  assert (Depth_0 + Depth_1 > 0) report "Both fifo depths zero!" severity warning;

  -- Concurrent assignments
  Tie_High <= '1';
  Tie_Low  <= '0';
  -- Combine fifo inputs
  Data_AV_Comm_In_0 <= Addr_Valid_In_0 & Comm_In_0 & Data_In_0;
  Data_AV_Comm_In_1 <= Addr_Valid_In_1 & Comm_In_1 & Data_In_1;

  
  -- Split fifooutput
  AV_0_Mux   <= Data_AV_Comm_0_Mux ( 1+Comm_Width + Data_Width-1);
  Comm_0_Mux <= Data_AV_Comm_0_Mux (   Comm_Width + Data_Width-1 downto Data_Width);
  Data_0_Mux <= Data_AV_Comm_0_Mux (                Data_Width-1 downto 0);
  AV_1_Mux   <= Data_AV_Comm_1_Mux ( 1+Comm_Width + Data_Width-1);
  Comm_1_Mux <= Data_AV_Comm_1_Mux (   Comm_Width + Data_Width-1 downto Data_Width);
  Data_1_Mux <= Data_AV_Comm_1_Mux (                Data_Width-1 downto 0);
  

  Map_Fifo_0 : if Depth_0 > 0 generate
    Fifo_0 : fifo
      generic map(
        width          => 1 + Comm_Width + Data_Width,
        depth          => Depth_0
        )
      port map(
        Clk            => Clk,
        Rst_n          => Rst_n,

        Data_In        => Data_AV_Comm_In_0,
        Write_Enable   => Write_Enable_In_0,
        One_Place_Left => One_Place_Left_Out_0,
        Full           => Full_Out_0,

        Read_Enable   => Read_Enable_Mux_0,
        Data_Out      => Data_AV_Comm_0_Mux,
        Empty         => Empty_0_Mux,
        One_Data_Left => One_Data_Left_0_Mux
        );
  end generate Map_Fifo_0;

  
  Not_Map_Fifo_0 : if Depth_0 = 0 generate
    -- Fifo #0 does not exist!
    Data_AV_Comm_0_Mux   <= (others => '0');
    Empty_0_Mux          <= Tie_High;
    One_Data_Left_0_Mux  <= Tie_Low;
    Full_Out_0           <= Tie_High;
    One_Place_Left_Out_0 <= Tie_Low;

    -- Connect the other fifo (#1)straight to the outputs ( =>  FSM)
    Data_Out          <= Data_1_Mux;
    Comm_Out          <= Comm_1_Mux;
    Addr_Valid_Out    <= AV_1_Mux;
    One_Data_Left_Out <= One_Data_Left_1_Mux;
    Empty_Out         <= Empty_1_Mux;    

    Read_Enable_Mux_1 <= Read_Enable_In;  --15.05

  end generate Not_Map_Fifo_0;



  
  Map_Fifo_1 : if Depth_1 > 0 generate
    Fifo_1 : fifo
      generic map(
        width          => 1 + Comm_Width + Data_Width,
        depth          => Depth_1
        )
      port map(
        Clk            => Clk,
        Rst_n          => Rst_n,
        
        Data_In        => Data_AV_Comm_In_1,
        Write_Enable   => Write_Enable_In_1,
        One_Place_Left => One_Place_Left_Out_1,
        Full           => Full_Out_1,

        Read_Enable   => Read_Enable_Mux_1,
        Data_Out      => Data_AV_Comm_1_Mux,
        Empty         => Empty_1_Mux,
        One_Data_Left => One_Data_Left_1_Mux
        );
  end generate Map_Fifo_1;

  
  Not_Map_Fifo_1 : if Depth_1 = 0 generate
    -- Fifo #1 does not exist!

    -- Signals fifo#1=> IP
    --     Full_Out_1           <= Tie_High;
    --     One_Place_Left_Out_1 <= Tie_Low;

    -- Signals fifo#1=> FSM
    Data_AV_Comm_1_Mux   <= (others => '0');
    Empty_1_Mux          <= Tie_High;
    One_Data_Left_1_Mux  <= Tie_Low;

    -- Connect the other fifo (#0)straight to the outputs ( =>  FSM)
    Data_Out          <= Data_0_Mux;
    Comm_Out          <= Comm_0_Mux;
    Addr_Valid_Out    <= AV_0_Mux;
    One_Data_Left_Out <= One_Data_Left_0_Mux;
    Empty_Out         <= Empty_0_Mux;

    Read_Enable_Mux_0 <= Read_Enable_In;  --15.05

  end generate Not_Map_Fifo_1;


  Map_Mux : if Depth_0 > 0 and Depth_1 > 0 generate
    -- Only one fifo used
    -- Multiplexer is needed only if two fifos are used
    MUX_01: fifo_mux_read 
      generic map(
        Data_Width         => Data_Width,
        Comm_Width         => Comm_Width
        )
      port map(
        Clk                => Clk,
        Rst_n              => Rst_n,

        Data_0_In          => Data_0_Mux,
        Comm_0_In          => Comm_0_Mux,
        Addr_Valid_0_In    => AV_0_Mux,
        One_Data_Left_0_In => One_Data_Left_0_Mux,
        Empty_0_In         => Empty_0_Mux,
        RE_0_Out           => Read_Enable_Mux_0,

        Data_1_In          => Data_1_Mux,
        Comm_1_In          => Comm_1_Mux,
        Addr_Valid_1_In    => AV_1_Mux,
        One_Data_Left_1_In => One_Data_Left_1_Mux,
        Empty_1_In         => Empty_1_Mux,
        RE_1_Out           => Read_Enable_Mux_1,

        Read_Enable_In    => Read_Enable_In,
        Data_Out          => Data_Out,
        Comm_Out          => Comm_Out,
        Addr_Valid_Out    => Addr_Valid_Out,
        One_Data_Left_Out => One_Data_Left_Out,
        Empty_Out         => Empty_Out
        );
  end generate Map_Mux;


  






  
end structural;



