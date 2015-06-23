----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:13:49 05/31/2012 
-- Design Name: 
-- Module Name:    Imem - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Imem is
port (
        clk : in std_logic;
		  en : in std_logic;
		  address : in std_logic_vector(12 downto 0);
		  imem_to_ir : out std_logic_vector(31 downto 0)
		  
		);
end Imem;

architecture Behavioral of Imem is
Component Rom16_S36 is
port  (
       clk : in std_logic;
       we : in std_logic; 
       en : in std_logic;
       ssr : in std_logic;
       addr : in std_logic_vector(10 downto 2);
       di : in std_logic_vector (31 downto 0);
       do : out std_logic_vector(31 downto 0)
     );
end component;
Component Rom16_S36_1 is
port  (
       clk : in std_logic;
       we : in std_logic;
       en : in std_logic;
       ssr : in std_logic;
       addr : in std_logic_vector(10 downto 2);
       di : in std_logic_vector (31 downto 0);
       do : out std_logic_vector(31 downto 0)
     );
end component;

Component Rom16_S36_2 is
port  (
       clk : in std_logic;
       we : in std_logic;
       en : in std_logic;
       ssr : in std_logic;
       addr : in std_logic_vector(10 downto 2);
       di : in std_logic_vector (31 downto 0);
       do : out std_logic_vector(31 downto 0)
     );
end component;
Component Rom16_S36_3 is
port  (
       clk : in std_logic;
       we : in std_logic; 
       en : in std_logic;
       ssr : in std_logic;
       addr : in std_logic_vector(10 downto 2);
       di : in std_logic_vector (31 downto 0);
       do : out std_logic_vector(31 downto 0)
     );
end component;
Component Addr_dec is
port  (    
              addr : in std_logic_vector(1 downto 0);
			     dec_out: out std_logic_vector(3 downto 0)
			    );
end component;
Component imem_or_out is
port  (
       
		 do_internal_0 :in std_logic_vector(31 downto 0);
		 do_internal_1 :in std_logic_vector(31 downto 0);
		 do_internal_2 :in std_logic_vector(31 downto 0);
		 do_internal_3 :in std_logic_vector(31 downto 0);
       imem_or_out   :out std_logic_vector(31 downto 0)
		 
);
end component;
signal sl: std_logic_vector(3 downto 0);
signal do_internal_0,do_internal_1,do_internal_2,do_internal_3: std_logic_vector(31 downto 0);

begin

RI_0 : Rom16_S36
	   port map 
		(
			clk => clk,
			we => '0',
			en => en,
			ssr => sl(0),
			addr => address (10 downto 2),
			di => "00000000000000000000000000000000",
			do => do_internal_0    --(0)
		);
		
RI_1 : Rom16_S36_1
	   port map 
		(
			clk => clk,
			we => '0',
			en => en,
			ssr => sl(1),
			addr => address (10 downto 2),
			di => "00000000000000000000000000000000",
			do => do_internal_1    --(1)
		);
RI_2 : Rom16_S36_2
	   port map 
		(
			clk => clk,
			we => '0',
			en => en,
			ssr => sl(2),
			addr => address (10 downto 2),
			di => "00000000000000000000000000000000",
			do => do_internal_2     --(2)
		);
		
RI_3 : Rom16_S36_3
	   port map 
		(
			clk => clk,
			we => '0',
			en => en,
			ssr => sl(3),
			addr => address (10 downto 2),
			di => "00000000000000000000000000000000",
			do => do_internal_3     --(3)
		);
		
Addr_dec_i:Addr_dec port map(addr=>address(12 downto 11),dec_out=>sl);


imem_to_ir <= 	do_internal_0 or 	do_internal_1 or 	do_internal_2 or 	do_internal_3;		

					  

end Behavioral;

