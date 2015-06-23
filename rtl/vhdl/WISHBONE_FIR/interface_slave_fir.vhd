library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_slave_fir is 
generic(

data_wordwidth: integer;
adress_wordwidth: integer;
Adr_bas:integer;
reg_control:integer;
reg_data:integer;
reg_status:integer;
reg_Q:integer;
reg_coef:integer;

N_coef:integer;

M:integer;
WordWidth_Q:integer--width signal of Q

);
port(
 
 
 ACK_O: out   std_logic;--to MASTER
 ADR_I: in    std_logic_vector( adress_wordwidth-1 downto 0 );
 DAT_I: in    std_logic_vector( data_wordwidth-1 downto 0 );--from MASTER
 sDAT_I: in    std_logic_vector( data_wordwidth-1 downto 0 );--from SLAVE
 DAT_O: out   std_logic_vector( data_wordwidth-1 downto 0 );--to MASTER
 sDAT_O: out   std_logic_vector( data_wordwidth-1 downto 0 );--to SLAVE
 STB_I: in    std_logic;--from MASTER
 WE_I: in    std_logic;--from MASTER
 Start: out    std_logic;--to SLAVE	
 h0: out std_logic_vector( (N_coef*M)-1 downto 0 );--to SLAVE
 Q :out std_logic_vector(WordWidth_Q-1 downto 0);
 clear,reset,clk: in std_logic
 
 );
end entity;
 
architecture RTL of interface_slave_fir is 

--The fullregister component
component fullregister is

	generic
	(
		N: integer
	);

	port
	(
		clk		  : in std_logic;
		reset_n	  : in std_logic;
		enable	  : in std_logic;
		clear		  : in std_logic;
		d		  : in std_logic_vector(N-1 downto 0);
		q		  : out std_logic_vector(N-1 downto 0)
		
	);
end component;

signal OUT_AUX,rSTATUS_O, ZERO:  std_logic_vector( data_wordwidth-1 downto 0 );
signal ZERO1:  std_logic_vector( WordWidth_Q-1 downto 0 );

type array_aux is array(N_coef downto 0) of std_logic_vector(M-1 downto 0);
signal h0_aux:array_aux;

type array_aux1 is array(N_coef downto 0) of std_logic;
signal enables:array_aux1;

begin
	ZERO<=std_logic_vector(to_unsigned(0,data_wordwidth));
	ZERO1<=std_logic_vector(to_unsigned(0,WordWidth_Q));
	OUT_AUX<=DAT_I;
	ACK_O<=STB_I;
	
	
	DAT_O<=sDAT_I;
	
	coefficients:
			for k in N_coef-1 downto 0 generate			
								
				 enables(k)<='1' when (STB_I='1' and  WE_I='1' and ADR_I(9 downto 0)=std_logic_vector(to_unsigned((4*k)+reg_coef,10))) else 
									'0';
									
						coefs:fullregister
							generic map(
											N=>M
											)
							port map (
											clk=>clk,
											reset_n=>reset,
											enable=>enables(k),
											clear=>clear,
											d=>OUT_AUX(M-1 downto 0),
											q=>h0_aux(k)
											);
							h0((k+1)*M-1 downto k*M)<=std_logic_vector(signed(h0_aux(k)));				
						
			end generate;
								
								
								
	process(ADR_I,STB_I,WE_I,ZERO,ZERO1,OUT_AUX,sDAT_I,rSTATUS_O)
	begin
	
				--if ((ADR_I(adress_wordwidth-1 downto adress_wordwidth-4))=std_logic_vector(to_unsigned(Adr_bas,4))) then 
				 if (WE_I='1' and STB_I='1') then
						case ADR_I(9 downto 0) is 
								
								when std_logic_vector(to_unsigned(reg_control,10)) => start<='1';
																															--sDAT_O<=ZERO;
																															--DAT_O<=ZERO;
																															rSTATUS_O<=ZERO;
																															--Q<=ZERO1;
																																
								
								when std_logic_vector(to_unsigned(Reg_status,10)) => rSTATUS_O<=std_logic_vector(unsigned(OUT_AUX));
																														  --sDAT_O<=ZERO;
																														 -- DAT_O<=ZERO;
																														  start<='0';
																														  --Q<=ZERO1;
														
								
								when OTHERS => --DAT_O<=ZERO;
													--sDAT_O<=ZERO;
													start<='0';
													rSTATUS_O<=ZERO;
													--Q<=ZERO1;
						 end case;
--				 elsif (WE_I='0' and STB_I='1') then
--						case ADR_I(4 downto 0) is 
--								when std_logic_vector(to_unsigned(reg_data,5)) => DAT_O<=sDAT_I;
--																														--sDAT_O<=ZERO;
--																														start<='0';	
--																														rSTATUS_O<=ZERO;	
--																														---Q<=ZERO1;
--
--								when std_logic_vector(to_unsigned(Reg_status,5)) => DAT_O<=rSTATUS_O;
--																														  --sDAT_O<=ZERO;
--																														  start<='0';
--																														  rSTATUS_O<=ZERO; 
--																														  --Q<=ZERO1;
--								when OTHERS => DAT_O<=ZERO;
--													--sDAT_O<=ZERO;
--													start<='0';
--													rSTATUS_O<=ZERO;
--													--Q<=ZERO1;
--						 end case;
					 		
					--end if; 
				 else 
					--	DAT_O<=ZERO;
						--sDAT_O<=ZERO;
						start<='0';
						rSTATUS_O<=ZERO;
						--Q<=ZERO1;
				 end if;
				
	end process;
	
	process(ADR_I,STB_I,WE_I,ZERO,ZERO1,OUT_AUX,sDAT_I,rSTATUS_O)
	begin
	 if rising_edge(clk) then 
				
				 if (WE_I='1' and STB_I='1') then
						if ADR_I(9 downto 0)=std_logic_vector(to_unsigned(reg_data,10)) then 
								
																																				
								 sDAT_O<=OUT_AUX;
						end if;																								
						if ADR_I(9 downto 0)=std_logic_vector(to_unsigned(reg_Q,10)) then 
								
																																				
								 --Q<=OUT_AUX(data_wordwidth-1 downto data_wordwidth-WordWidth_Q);
								 Q<=OUT_AUX(WordWidth_Q-1 downto 0);
						end if;																									
														
								
																														
								
						 
				 end if;
			end if;	
		
			
	end process;
end architecture;
 
 
 