library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nineFiFOLineBuffer is
  generic (
	DATA_WIDTH : integer := 8;
	NO_OF_COLS : integer := 640
	);
  port(
    clk : in std_logic;
	fsync : in std_logic;
	pdata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out1 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out2 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out3 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out4 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out5 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out6 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out7 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out8 : buffer std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out9 : buffer std_logic_vector(DATA_WIDTH -1 downto 0)
	);
  end nineFiFOLineBuffer;
  
architecture Behavioral of nineFiFOLineBuffer is

signal pdata_in_r : std_logic_vector(DATA_WIDTH -1 downto 0);

component FIFOLineBuffer is
  generic (
	DATA_WIDTH : integer := DATA_WIDTH;
	NO_OF_COLS : integer := 640 
	);
  port(
	clk : in std_logic;
	fsync : in std_logic;
	pdata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out : buffer std_logic_vector(DATA_WIDTH -1 downto 0)
	);
  end component;
  
begin
  
  pdata_out1 <= pdata_in_r;

  update_reg : process (clk)
  begin 
    if rising_edge(clk) then
	if fsync = '1' then
	  pdata_in_r <= pdata_in;
	end if;
	end if;
  end process update_reg;  

  LineBuffer1 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map(clk, fsync, pdata_in_r, pdata_out2);
	
  LineBuffer2 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map(clk, fsync, pdata_out2, pdata_out3);
 
    LineBuffer3 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map(clk, fsync, pdata_out3, pdata_out4);
	
  LineBuffer4 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map(clk, fsync, pdata_out4, pdata_out5);

  LineBuffer5 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map(clk, fsync, pdata_out5, pdata_out6);
	
  LineBuffer6 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map(clk, fsync, pdata_out6, pdata_out7);
 
  LineBuffer7 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map(clk, fsync, pdata_out7, pdata_out8);
	
  LineBuffer8 : FIFOLineBuffer
	generic map (
	  DATA_WIDTH => DATA_WIDTH,
	  NO_OF_COLS => NO_OF_COLS
	  )
	port map(clk, fsync, pdata_out8, pdata_out9);	
	
  

end Behavioral;