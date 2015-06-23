----------------------------------------------------------------------------------
-- Company: 
-- Engineer:   Lazaridis Dimitris
-- 
-- Create Date:    22:01:13 06/13/2012 
-- Design Name: 
-- Module Name:    dmem - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dmem is
         port (
               clk : in std_logic;
					rst : in std_logic;
					IorD : in std_logic;
					we : in std_logic_vector(3 downto 0);
               en : in std_logic_vector(3 downto 0);
               ssr : in std_logic_vector(3 downto 0);
               address : in std_logic_vector(10 downto 0);
               data_in : in std_logic_vector(31 downto 0);
               data_out : out std_logic_vector(31 downto 0)
					);

end dmem;
       
architecture Behavioral of dmem is
component RAMB16_S9_0 is
port (
       clk : in std_logic;
		 we : in std_logic; 
       en : in std_logic;
       ssr : in std_logic;
       addr : in std_logic_vector(10 downto 0);
       di : in std_logic_vector (7 downto 0);
       do : out std_logic_vector(7 downto 0)
   	);
end component;
signal  data_out_buff,data_out_l,data_in_buff : std_logic_vector(31 downto 0);
signal address_buff : std_logic_vector(10 downto 0);
begin
       -- This module uses 4 2Kx8 block RAMs
       -- This module uses 4 2Kx8 block RAMs
R1 : for I in 0 to 3 generate
Ram : RAMB16_S9_0 port map (
                         clk => clk,
                         we => we(I),
                         en => en(I),
                         ssr => ssr(I),
                         addr => address_buff,
                         di => data_in_buff(((8*I)+7) downto (8*I)),
                         do => data_out_buff(((8*I)+7) downto (8*I))
);
end generate R1;
     

process(we,en,ssr,data_in,data_out_buff)
variable we_check,en_check : std_logic;
begin
     we_check := we(0) or we(1) or we(2) or we(3);
	  en_check := en(0) or en(1) or en(2) or en(3);
     if we_check = '1' and en_check = '1' then
	     data_in_buff  <= data_in;
		  elsif en_check = '1' then
		  data_out_l <= data_out_buff;
        else 
        data_out_l <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
     end if; 		  

end process;
process(clk,rst,IorD,address)
variable adr_e : integer;
variable adr_tmp : std_logic_vector(10 downto 0);
variable E : std_logic;
begin
   if rst = '0' then
	    address_buff <= (others => '0');
    else --if FALLING_EDGE(clk) then  --for more accurate timing + we,en
	    if IorD = '1' then
		 address_buff <= address;
		 adr_tmp := address;
       adr_e := CONV_INTEGER(adr_tmp); 	 
       if (adr_e mod "100") = 0 then
		 E := '0';
		 else
		 E := '1';
		 end if;
		 end if;
	 end if;
end process;
process(clk,rst,IorD,data_out_l)
begin
     if rst = '0' then
	    data_out <= (others => '0');
    elsif RISING_EDGE(clk) then
	    if IorD = '1' then
		    data_out <= data_out_l;
		 end if;	 
	   end if;	 
end process;


end Behavioral;

