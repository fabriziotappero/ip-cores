-------------------------------------------------------------------------------
-- File        : double_fifo_demuxed_write.vhdl
-- Description : Double_Fifo_Demuxed_Write buffer for hibi v.2 interface
--               Includes two fifos and a special demultiplexer
--               so that the writer sees only one fifo. Demultiplexer
--               directs addr+data to correct fifo (0 = for messages)
-- Author      : Vesa Lahtinen
-- Date        : 08.04.2003
-- Modified    : 
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity double_fifo_demuxed_write is

  generic (
    Data_Width :    integer := 0;
    Depth_0    :    integer := 0;
    Depth_1    :    integer := 0;
    Comm_Width :    integer := 0
    );
  port (
    Clk        : in std_logic;
    Rst_n      : in std_logic;

    Data_In             : in  std_logic_vector ( Data_Width-1 downto 0);
    Comm_In             : in  std_logic_vector ( Comm_Width-1 downto 0);
    Addr_Valid_In       : in  std_logic;
    Write_Enable_In     : in  std_logic;
    One_Place_Left_Out  : out std_logic;
    Full_Out            : out std_logic;

    Read_Enable_In_0    : in  std_logic;
    Data_Out_0          : out std_logic_vector ( Data_Width-1 downto 0);
    Comm_Out_0          : out std_logic_vector ( Comm_Width-1 downto 0);
    Addr_Valid_Out_0    : out std_logic;
    Empty_Out_0         : out std_logic;
    One_Data_Left_Out_0 : out std_logic;
    
    Read_Enable_In_1    : in  std_logic;
    Data_Out_1          : out std_logic_vector ( Data_Width-1 downto 0);
    Comm_Out_1          : out std_logic_vector ( Comm_Width-1 downto 0);
    Addr_Valid_Out_1    : out std_logic;
    Empty_Out_1         : out std_logic;
    One_Data_Left_Out_1 : out std_logic
    );
end double_fifo_demuxed_write;



architecture structural of double_fifo_demuxed_write is

  


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


  component fifo_demux_write
    generic (
      Data_Width         :     integer := 0;
      Comm_Width         :     integer := 0);

    port (
      -- 13.04 Clk                : in  std_logic;
      -- 13.04 Rst_n              : in  std_logic;
      Data_In            : in  std_logic_vector (Data_Width-1 downto 0);
      Addr_Valid_In      : in  std_logic;
      Comm_In            : in  std_logic_vector (Comm_Width-1 downto 0);
      WE_In              : in  std_logic;
      One_Place_Left_Out : out std_logic;
      Full_Out           : out std_logic;

      -- Data/Comm/AV conencted to both fifos
      -- Distinction made with WE!
      Data_Out            : out std_logic_vector (Data_Width-1 downto 0);
      Comm_Out            : out std_logic_vector (Comm_Width-1 downto 0);
      Addr_Valid_Out      : out std_logic;
      WE_0_Out            : out std_logic;
      WE_1_Out            : out std_logic;
      Full_0_In           : in  std_logic;
      Full_1_In           : in  std_logic;
      One_Place_Left_0_In : in  std_logic;
      One_Place_Left_1_In : in  std_logic
      );
  end component;
  
  signal Data_AV_Comm_Out_0 : std_logic_vector ( 1 + Comm_Width + Data_Width-1 downto 0);
  signal Data_AV_Comm_Out_1 : std_logic_vector ( 1 + Comm_Width + Data_Width-1 downto 0);

  signal Data_AV_Comm_From_Demux : std_logic_vector ( 1 + Comm_Width + Data_Width-1 downto 0);

  signal Data_Demux_To_fifo       : std_logic_vector(Data_Width-1 downto 0);
  signal Comm_Demux_To_fifo       : std_logic_vector(Comm_Width-1 downto 0);
  signal Addr_Valid_Demux_To_fifo : std_logic;

  signal Write_Enable_0   : std_logic;
  signal Full_0           : std_logic;
  signal One_Place_Left_0 : std_logic;

  signal Write_Enable_1   : std_logic;
  signal Full_1           : std_logic;
  signal One_Place_Left_1 : std_logic;

  signal Tie_High : std_logic;
  signal Tie_Low  : std_logic;


begin  -- structural
  -- Check generics
  assert (Depth_0 + Depth_1 > 0) report "Both fifo depths zero!" severity warning;

  -- Concurrent assignments
  Tie_High <= '1';
  Tie_Low  <= '0';
  -- Combine fifo inputs
  -- Data_AV_Comm_From_Demux <= Addr_Valid_Demux_To_fifo & Comm_Demux_To_fifo & Data_Demux_To_fifo;

  -- Splitting the data
  Addr_Valid_Out_0 <= Data_AV_Comm_Out_0(Comm_Width+Data_Width);
  Comm_Out_0       <= Data_AV_Comm_Out_0(Comm_Width+Data_Width-1 downto Data_Width);
  Data_Out_0       <= Data_AV_Comm_Out_0(Data_Width-1 downto 0);
  Addr_Valid_Out_1 <= Data_AV_Comm_Out_1(Comm_Width+Data_Width);
  Comm_Out_1       <= Data_AV_Comm_Out_1(Comm_Width+Data_Width-1 downto Data_Width);
  Data_Out_1       <= Data_AV_Comm_Out_1(Data_Width-1 downto 0);
  
  Map_Fifo_0 : if Depth_0 > 0 generate
    Fifo_0 : fifo
      generic map(
        width          => 1 + Comm_Width + Data_Width,
        depth          => Depth_0
        )
      port map(
        Clk            => Clk,
        Rst_n          => Rst_n,

        Data_In        => Data_AV_Comm_From_Demux,
        Write_Enable   => Write_Enable_0,
        One_Place_Left => One_Place_Left_0,
        Full           => Full_0,

        Read_Enable   => Read_Enable_In_0,
        Data_Out      => Data_AV_Comm_Out_0,       
        Empty         => Empty_Out_0,
        One_Data_Left => One_Data_Left_Out_0
        );
  end generate Map_Fifo_0;

  Not_Map_Fifo_0 : if Depth_0 = 0 generate
    -- Fifo #0 and demux does not exist!
    Data_AV_Comm_Out_0  <= (others => '0');
    Empty_Out_0         <= Tie_High;
    One_Data_Left_Out_0 <= Tie_Low;
    Full_0              <= Tie_High;
    One_Place_Left_0    <= Tie_Low;
    Write_Enable_0      <= Tie_Low;

    -- Connect the other fifo (#1) straight to the outputs (FSM)
    Write_Enable_1                                                     <= Write_Enable_In;
    One_Place_Left_Out                                                 <= One_Place_Left_1;
    Full_Out                                                           <= Full_1;
    Data_AV_Comm_From_Demux(Data_Width-1 downto 0)                     <= Data_In;
    Data_AV_Comm_From_Demux(Comm_Width+Data_Width-1 downto Data_Width) <= Comm_In;
    Data_AV_Comm_From_Demux(Comm_Width+Data_Width)                     <= Addr_Valid_In;

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
        
        Data_In        => Data_AV_Comm_From_Demux,
        Write_Enable   => Write_Enable_1,
        One_Place_Left => One_Place_Left_1,
        Full           => Full_1,

        Read_Enable   => Read_Enable_In_1,
        Data_Out      => Data_AV_Comm_Out_1,       
        Empty         => Empty_Out_1,
        One_Data_Left => One_Data_Left_Out_1
        );
  end generate Map_Fifo_1;

  Not_Map_Fifo_1 : if Depth_1 = 0 generate
    -- Fifo #1 and demux does not exist!
    Data_AV_Comm_Out_1  <= (others => '0');
    Empty_Out_1         <= Tie_High;
    One_Data_Left_Out_1 <= Tie_Low;
    Full_1              <= Tie_High;
    One_Place_Left_1    <= Tie_Low;
    Write_Enable_1      <= Tie_Low;

    -- Connect the other fifo (#0) straight to the outputs (FSM)
    Write_Enable_0                                                     <= Write_Enable_In;
    One_Place_Left_Out                                                 <= One_Place_Left_0;
    Full_Out                                                           <= Full_0;
    Data_AV_Comm_From_Demux(Data_Width-1 downto 0)                     <= Data_In;
    Data_AV_Comm_From_Demux(Comm_Width+Data_Width-1 downto Data_Width) <= Comm_In;
    Data_AV_Comm_From_Demux(Comm_Width+Data_Width)                     <= Addr_Valid_In;

  end generate Not_Map_Fifo_1;


  Map_Demux  : if Depth_0 > 0 and Depth_1 > 0 generate
    -- Demultiplexer is needed only if two fifos are used
    DEMUX_01 : fifo_demux_write
      generic map(
        Data_Width          => Data_Width,
        Comm_Width          => Comm_Width
        )
      port map(
        -- 13.04
        -- Clk                 => Clk,
        -- Rst_n               => Rst_n,
        Data_In             => Data_In,
        Comm_In             => Comm_In,
        Addr_Valid_In       => Addr_Valid_In,
        WE_In               => Write_Enable_In,
        
        One_Place_Left_Out  => One_Place_Left_Out,
        Full_Out            => Full_Out,
        Data_Out            => Data_AV_Comm_From_Demux(Data_Width-1 downto 0),
        Comm_Out            => Data_AV_Comm_From_Demux(Comm_Width+Data_Width-1 downto Data_Width),
        Addr_Valid_Out      => Data_AV_Comm_From_Demux(Comm_Width+Data_Width),
        WE_0_Out            => Write_Enable_0,
        WE_1_Out            => Write_Enable_1,
        
        Full_0_In           => Full_0,
        Full_1_In           => Full_1,
        One_Place_Left_0_In => One_Place_Left_0,
        One_Place_Left_1_In => One_Place_Left_1
        );
  end generate Map_Demux;

  
end structural;




