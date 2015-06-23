---------------------------------------------------------------------
----                                                             ----
----  Reed Solomon decoder/encoder IP core                       ----
----                                                             ----
----  Authors: Anatoliy Sergienko, Volodya Lepeha                ----
----  Company: Unicore Systems http://unicore.co.ua              ----
----                                                             ----
----  Downloaded from: http://www.opencores.org                  ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2006-2010 Unicore Systems LTD                 ----
---- www.unicore.co.ua                                           ----
---- o.uzenkov@unicore.co.ua                                     ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
---- THIS SOFTWARE IS PROVIDED "AS IS"                           ----
---- AND ANY EXPRESSED OR IMPLIED WARRANTIES,                    ----
---- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED                  ----
---- WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT              ----
---- AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.        ----
---- IN NO EVENT SHALL THE UNICORE SYSTEMS OR ITS                ----
---- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,            ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL            ----
---- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT         ----
---- OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,               ----
---- DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                 ----
---- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,              ----
---- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                 ----
---- IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,                 ----
---- EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          ----
----                                                             ----
---------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {RS_DEC4} architecture {RS_DEC4}}

library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;     
use type1.all;

entity RS_DEC4 is
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC; 
		 STR : in STD_LOGIC;
		 D_IN : in STD_LOGIC_VECTOR(7 downto 0);
		 RD : in STD_LOGIC;
		 D_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		 S_er : out STD_LOGIC;		
		 S_ok : out STD_LOGIC;
		 SNB : out STD_LOGIC
	     );
end RS_DEC4;

--}} End of automatically maintained section

architecture RS_DEC4 of RS_DEC4 is	

component RS_DEC_SINDDROM is		 
	--generic( G_range:  integer := 4;
--	A_range:  integer := 9);
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC;
		 STR : in STD_LOGIC;
		 D_IN : in STD_LOGIC_VECTOR(7 downto 0);
		 RD : in STD_LOGIC;
		 D_OUT : out STD_LOGIC_VECTOR(7 downto 0);	
		 S_er : out STD_LOGIC;
		 SNB : out STD_LOGIC; 
		 D_OUT1 : out tregA
	     );
end component;

component RS_BER_MESS is		 
	--generic( G_range:  integer := 4;
--	A_range:  integer := 9);
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC;
		 STR : in STD_LOGIC;
		 D_IN : in STD_LOGIC_VECTOR(7 downto 0);
		 S_OK : out STD_LOGIC;
		 SNB : out STD_LOGIC;
		 D_OUT : out kgx8; 
		 D_OUT1 : out tregA
	     );
end component;
signal rd1,s_er1,snb1,snb_sindr : std_logic:= '0'; 
signal d_sindr : STD_LOGIC_VECTOR(7 downto 0);	
signal rgA1,rgA2,rgA3,rgA4 : tregA; 
begin
 
		 
U_dec: RS_DEC_SINDDROM 		 
	--generic map( G_range => G_range,
--	A_range => A_range )
	 port map( 
		 CLK => clk, RST => rst,
		 D_IN => d_in,
		 STR => str,
		 RD => rd1,
		 D_OUT => d_sindr,
		 S_er => s_er1,
		 SNB => snb_sindr,
		 D_OUT1  => rgA2
	     );	  
		S_er <= s_er1; 
U_BM: RS_BER_MESS 		 
	--generic map( G_range => G_range,
--	A_range => A_range )
	 port map(
		 CLK => clk, RST => rst,
		 STR => snb_sindr, 
		 D_IN => d_sindr,
		 S_OK => s_ok,
		 SNB => snb1,
		 D_OUT  => open,	 
		 D_OUT1  => rgA1
	     );	 
process(clk,rst)  
variable c : integer;
begin  
	if rst = '1' then 
		snb <= '0';
		rgA3 <= (others => (others => '0'));      
		rgA4 <= (others => (others => '0'));
	elsif clk = '1' and clk'event then	
		snb <= snb1;
		for i in 0 to A_range-1 loop rgA3(i) <= rgA1(i) xor rgA2(i); end loop; 
	if snb1 = '1' then 	
		rgA4 <= rgA3; 
	elsif rd = '1' then 
		for i in 0 to A_range-2 loop rgA4(i+1) <= rgA4(i); end loop; 
	end if;	   	
    d_out <= rgA4(A_range-1);
	end if;		 
	
end process;  
	 -- enter your statements here --

end RS_DEC4;
			