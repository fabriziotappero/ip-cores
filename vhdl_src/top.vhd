library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top is
  port(
    clk       : in std_logic;
	 rstn      : in std_logic;
	 data_in   : in std_logic_vector(7 downto 0);
	 fsync_in  : in std_logic;
	 fsync_out : out std_logic;
    data_out  : out std_logic_vector(7 downto 0)
);
end entity top;

architecture structure of top is
  
  signal data_in_r   : std_logic_vector(7 downto 0);
  signal fsync_in_r  : std_logic;
  
begin

-- registering inputs  
  reg : process(clk)
  begin
	if rising_edge(clk) then
     data_in_r  <= data_in;
	  fsync_in_r <= fsync_in;	  
	end if;
  end process reg;  
  
  edge : entity work.edge_sobel_wrapper
    port map (
	  clk       => clk,
	  rstn      => rstn,
	  pdata_in  => data_in_r,
	  fsync_in  => fsync_in_r,
	  fsync_out => fsync_out,
	  pdata_out => data_out
  );

end architecture structure;