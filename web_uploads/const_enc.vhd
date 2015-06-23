-- File: cost_enc.vhd                              
-- Date:  Thursday, Nov 29 2001                                                      
--                                                                     
-- www.opencores.org                  
-- VHDL model of Constellation Encoder 
-- Purpose: VHDL RTL design containing a synthesizable Constellation
-- encoder module for ADSL
--                                                                        
-- Author: Sushanta Jyoti Sarmah (sushanta@@opencores.org )
-- To Do: xxxx                                 
-----------------------------------------------------------------------

library ieee;
 use ieee.std_logic_1164.all;
 use ieee.std_logic_unsigned.all;


entity cost_enc is
	port (
		clk:in std_logic;
		msg_in: in std_logic;
		b_in: in std_logic_vector (3 downto 0);
		err:out std_logic;
		x_out: out std_logic_vector (8 downto 0);
		y_out: out std_logic_vector (8 downto 0));
	end cost_enc;

architecture rtl of cost_enc is

function bin_int(a:std_logic_vector)return integer is
---------------------------------------------------------------
           variable a2,a1,x,y,i,j:integer;
           begin
              a1:=2;
              a2:=0;
              for i in 0 to 3 loop   
              if(a(i)='1')then a2:=a2+(a1 ** i);
              end if; 
              end loop;  
              return(a2);
           end bin_int; 
procedure k_map (k_in: in std_logic_vector(4 downto 0); signal kx_out,ky_out: out std_logic_vector(1 downto 0)) is

begin
case k_in is 

	when "00000" =>kx_out <= "00"; ky_out<="00";
	when "00001" =>kx_out <= "00"; ky_out<="00";
	when "00010" =>kx_out <= "00"; ky_out<="00";
	when "00011" =>kx_out <= "00"; ky_out<="00";

	when "00100" =>kx_out <= "00"; ky_out<="11";
	when "00101" =>kx_out <= "00"; ky_out<="11";
	when "00110" =>kx_out <= "00"; ky_out<="11";
	when "00111" =>kx_out <= "00"; ky_out<="11";

	when "01000" =>kx_out <= "11"; ky_out<="00";
	when "01001" =>kx_out <= "11"; ky_out<="00";
	when "01010" =>kx_out <= "11"; ky_out<="00";
	when "01011" =>kx_out <= "11"; ky_out<="00";

	when "01100" =>kx_out <= "11"; ky_out<="11";
	when "01101" =>kx_out <= "11"; ky_out<="11";
	when "01110" =>kx_out <= "11"; ky_out<="11";
	when "01111" =>kx_out <= "11"; ky_out<="11";

	when "10000" =>kx_out <= "01"; ky_out<="00";
	when "10001" =>kx_out <= "01"; ky_out<="00";
	when "10010" =>kx_out <= "00"; ky_out<="00";
	when "10011" =>kx_out <= "10"; ky_out<="00";

	when "10100" =>kx_out <= "00"; ky_out<="01";
	when "10101" =>kx_out <= "00"; ky_out<="01";
	when "10110" =>kx_out <= "00"; ky_out<="10";
	when "10111" =>kx_out <= "00"; ky_out<="01";

	when "11000" =>kx_out <= "11"; ky_out<="01";
	when "11001" =>kx_out <= "11"; ky_out<="10";
	when "11010" =>kx_out <= "11"; ky_out<="01";
	when "11011" =>kx_out <= "11"; ky_out<="10";

	when "11100" =>kx_out <= "01"; ky_out<="11";
	when "11101" =>kx_out <= "01"; ky_out<="11";
	when "11110" =>kx_out <= "10"; ky_out<="11";
	when "11111" =>kx_out <= "10"; ky_out<="11";
	when others => null;
	
	end case;
    
end; 

--signal tmp: std_logic_vector(4 downto 0);
signal x_tmp,y_tmp: std_logic_vector(1 downto 0);
-- signal s_in :std_logic_vector(4 downto 0):="10111";
BEGIN

process(clk,b_in)

variable b :integer:=0;
variable I :integer:=0;
variable DATA : std_logic_vector( 15 downto 0):="0000000000000000";
variable tmp: std_logic_vector(4 downto 0);
--variable x_tmp,y_tmp: std_logic_vector(1 downto 0);
variable tmp_b: std_logic_vector(2 downto 0);
begin

		b:= bin_int(b_in);
		if (clk'event and clk = '1') then
		if (I< b) then
	   data(I):= msg_in;
		I:= I+1;
		else
		I:=0;
		err<= '0';
		if ( b=1) then --special error case
		err<='1';
		end if;
		if (b=2) then
		x_out<= data(0)& data(0)& data(0)& data(0) & data(0)& data(0)& data(0)& data(0)& '1';
		y_out<= data(1)& data(1)& data(1)& data(1) & data(1)& data(1)& data(1)& data(1)& '1';
		end if;

		if (b=3) then
		tmp_b:=data(2 downto 0);
		case tmp_b is
		when "000" =>x_out <= "000000001"; y_out<="000000011";
		when "001" =>x_out <= "000000001"; y_out<="111111111";
		when "010" =>x_out <= "111111111"; y_out<="000000001";
		when "011" =>x_out <= "111111111"; y_out<="111111111";
	
		when "100" =>x_out <= "111111101"; y_out<="000000001";
		when "101" =>x_out <= "000000001"; y_out<="000000011";
		when "110" =>x_out <= "111111111"; y_out<="111111101";
		when "111" =>x_out <= "000000011"; y_out<="111111111";

	
		when others => null;
	
		end case;
		end if;
		

		if (b=4) then
		x_out<= data(2)& data(2)& data(2)& data(2) & data(2)& data(2)& data(2)& data(0)& '1';
		y_out<= data(3)& data(3)& data(3)& data(3) & data(3)& data(3)& data(3)& data(1)& '1';
		end if;

		if (b=5) then
		tmp:= data(4 downto 0);
		k_map(tmp,x_tmp,y_tmp);
		x_out<=x_tmp(1)& x_tmp(1)& x_tmp(1)& x_tmp(1) & x_tmp(1)& x_tmp(1)& x_tmp(0)& data(0)& '1';
		y_out<= y_tmp(1)& y_tmp(1)& y_tmp(1)& y_tmp(1) & y_tmp(1)& y_tmp(1)& y_tmp(0)& data(1)& '1';
		end if;

		if (b=6) then
		x_out<= data(4)& data(4)& data(4)& data(4) & data(4)& data(4)& data(2)& data(0)& '1';
		y_out<= data(5)& data(5)& data(5)& data(5) & data(5)& data(5)& data(3)& data(1)& '1';
		end if;

		if (b=7) then
		tmp:= data(6 downto 2);
		k_map(tmp,x_tmp,y_tmp);
		x_out<=x_tmp(1)& x_tmp(1)& x_tmp(1)& x_tmp(1) & x_tmp(1)& x_tmp(0)& data(2)& data(0)& '1';
		y_out<= y_tmp(1)& y_tmp(1)& y_tmp(1)& y_tmp(1) & y_tmp(1)& y_tmp(0)& data(3)& data(1)& '1';
		end if;
		if (b=8) then
		x_out<= data(6)& data(6)& data(6)& data(6) & data(6)& data(4)& data(2)& data(0)& '1';
		y_out<= data(7)& data(7)& data(7)& data(7) & data(7)& data(5)& data(3)& data(1)& '1';
		end if;
		if (b=9) then
		tmp:= data(7 downto 3);
		k_map(tmp,x_tmp,y_tmp);
		x_out<=x_tmp(1)& x_tmp(1)& x_tmp(1)& x_tmp(1) & x_tmp(0)& data(4)& data(2)& data(0)& '1';
		y_out<= y_tmp(1)& y_tmp(1)& y_tmp(1)& y_tmp(1) & y_tmp(0)& data(5)& data(3)& data(1)& '1';
		end if;
		if (b=10) then
		x_out<= data(8)& data(8)& data(8)& data(8) & data(6)& data(4)& data(2)& data(0)& '1';
		y_out<= data(9)& data(9)& data(9)& data(9) & data(7)& data(5)& data(3)& data(1)& '1';
		end if;
		if (b=11) then
		tmp:= data(8 downto 4);
		k_map(tmp,x_tmp,y_tmp);
		x_out<=x_tmp(1)& x_tmp(1)& x_tmp(1)& x_tmp(0) &data(6)& data(4)& data(2)& data(0)& '1';
		y_out<= y_tmp(1)& y_tmp(1)& y_tmp(1)& y_tmp(0) & data(7)&data(5)& data(3)& data(1)& '1';
		end if;
		if (b=12) then
		x_out<= data(10)& data(10)& data(10)& data(8) & data(6)& data(4)& data(2)& data(0)& '1';
		y_out<= data(11)& data(11)& data(11)& data(9) & data(7)& data(5)& data(3)& data(1)& '1';
		end if;
		if (b=13) then
		tmp:= data(9 downto 5);
		k_map(tmp,x_tmp,y_tmp);
		x_out<=x_tmp(1)& x_tmp(1)& x_tmp(1)& x_tmp(0) & data(6)& data(4)& data(2)& data(0)& '1';
		y_out<= y_tmp(1)& y_tmp(1)& y_tmp(1)& y_tmp(0) & data(7)& data(5)& data(3)& data(1)& '1';
		end if;
		if (b=14) then
		x_out<= data(12)& data(12)& data(10)& data(8) & data(6)& data(4)& data(2)& data(0)& '1';
		y_out<= data(13)& data(13)& data(11)& data(9) & data(7)& data(5)& data(3)& data(1)& '1';
		end if;
		if ( b=15) then --special error case
		err<='1';
		end if;
		

	end if;
 end if;


end process;

end RTL;


