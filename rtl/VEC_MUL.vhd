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

library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_unsigned .all;	
use IEEE.STD_LOGIC_arith .all; 	   
use type1.all;

entity VEC_MUL is
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC;  		 
		 m_d : in STD_LOGIC;
		 A,B : in kgx8;	  
		 C : out kgx8
	     );
end VEC_MUL;

--}} End of automatically maintained section

architecture VEC_MUL of VEC_MUL is 
component mul_g8 is
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;		 
		 m_d : in STD_LOGIC;
		 a : in STD_LOGIC_VECTOR(7 downto 0);
		 b : in STD_LOGIC_VECTOR(7 downto 0);
		 res : out STD_LOGIC_VECTOR(7 downto 0)
	     );
end component;
begin  
	
	
 U_md: for i in 0 to G_range - 1 generate
		  
mul : mul_g8 
	 port map(
		 clk => clk, rst => rst,	 
		 m_d => m_d,
		 a => a(i),	 b => b(i),
		 res => c(i)
	     );	
	  end generate;	  
  
	 -- enter your statements here --

end VEC_MUL;  
