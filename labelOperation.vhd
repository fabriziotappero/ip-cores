
-- Company: 
-- Engineer: 
-- 
-- Create Date:     
-- Design Name: 
-- Module Name:     
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
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity label8Operation is
generic (
		CODE_WIDTH	: integer := 10;
		NO_OF_COLS	: integer := 640;
		NO_OF_ROWS  : integer :=480;
		NO_BITS_CC  : integer := 11;
		NO_BITS_RC  : integer := 10
		);
	port(
	 	pclk 		   	: in std_logic;
		reset				: in std_logic;
		fsync_in			: in std_logic;
		rsync_in   		: in std_logic;
		data_in			: in std_logic_vector(7 downto 0):= (others=>'0');
		pbin_in			: in std_logic;
		fsync_out		: out std_logic;
		rsync_out  		: out std_logic;
		pdata_out		: out std_logic_vector( CODE_WIDTH-1 downto 0 );
		featureDataStrobe 	: out std_logic;
		acknowledge		: in std_logic;
		cntObjects 		: out std_logic_vector(9 downto 0);
		x_cog_out		: out std_logic_vector(16 downto 0);
		y_cog_out		: out std_logic_vector(16 downto 0)
		);
end label8Operation;

architecture Behavioral of label8Operation is


signal pointer							: std_logic_vector(NO_BITS_CC-1 downto 0) := (others=>'0');
signal fsynch,rsynch 		      : std_logic := '0';
signal Hbuffer_in, Lbuffer_in		: std_logic_vector(7 downto 0);
signal Hbuffer_out, Lbuffer_out	: std_logic_vector(7 downto 0);
signal outputCodes					: std_logic_vector( CODE_WIDTH-1 downto 0 ):= (others=>'0');
signal ip6,ip7,ip8,ip9  			: std_logic_vector( CODE_WIDTH-1 downto 0 );

begin
	

			  
	pdata_out <= outputCodes;
	rsync_out <= rsynch;
	fsync_out <= fsynch;
	ip6 <= outputCodes;
			  
lineBuffer : entity work.line_buffer_Xb 
   generic map (CODE_WIDTH => CODE_WIDTH, ADDRESS_BITS => NO_BITS_CC)
	port map(
		idata => outputCodes,
		odata => ip7,
		pointer => pointer,
		ena => rsynch,
		clk => pclk );
lblKernel : entity work.label8AndFeatures
	generic map( CODE_BITS => CODE_WIDTH, row=> NO_OF_ROWS,col=> NO_OF_COLS)
	port map (
		ip9 => ip9,
		ip8 => ip8,
		ip7 => ip7,
		ip6 => ip6,
		ibin => pbin_in,
		pdata_in => data_in,
		fsync_in => fsync_in,
		fsync_out => fsynch,
		pdata_o => outputCodes,
		rsync_in => rsync_in,
		rsync_out => rsynch,
		Reset => reset,
		pclk => pclk,
		featureDataStrobe => featureDataStrobe,
		acknowledge => acknowledge,
		cntObjects => cntObjects,
		y_cog => y_cog_out,
		x_cog => x_cog_out
	);

	
process(pclk)
begin	
	if pclk'event and pclk = '1' then
			
		if rsynch = '1' then
			if pointer < NO_OF_COLS-4 then
				pointer <= pointer + 1;
			else
				pointer <= (others=>'0');
			end if;
		end if;
	
	   ip8 <= ip7;
		ip9 <= ip8;
		
	end if;
	
end process;

end Behavioral;

