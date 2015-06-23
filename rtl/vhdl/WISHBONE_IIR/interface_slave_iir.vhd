library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_slave_iir is 
generic(

Data_wordwidth: integer;
Adress_wordwidth: integer;
Adr_bas:integer;
Reg_control:integer;
Reg_data:integer;
Reg_status:integer;
Reg_coef:integer;
Reg_gain:integer;
Reg_Nsec:integer;
NSECT:integer;
M:integer

);
port(
 
 
 ACK_O: out   std_logic;--to MASTER
 ADR_I: in    std_logic_vector( Adress_wordwidth-1 downto 0 );
 DAT_I: in    std_logic_vector( Data_wordwidth-1 downto 0 );--from MASTER
 sDAT_I: in    std_logic_vector( Data_wordwidth-1 downto 0 );--from SLAVE
 DAT_O: out   std_logic_vector( Data_wordwidth-1 downto 0 );--to MASTER
 sDAT_O: out   std_logic_vector( Data_wordwidth-1 downto 0 );--to SLAVE
 en_out: out   std_logic_vector( 3 downto 0 );--to slave
 STB_I: in    std_logic;--from MASTER
 WE_I: in    std_logic;--from MASTER
 Start: out    std_logic;--to SLAVE	
 h0: out std_logic_vector( (NSECT*M*6)-1 downto 0 );--to SLAVE
 gain: out std_logic_vector(M-1 downto 0);
 enable_in: in std_logic;
 clear,reset,clk: in std_logic
 );
end entity;
 
architecture RTL of interface_slave_iir is 

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

signal OUT_AUX, ZERO,ssDAT_O,RegsDAT_O:  std_logic_vector( Data_wordwidth-1 downto 0 );
signal rSTATUS_O,enable_in_aux:std_logic_vector( 0 downto 0 );
signal Clear_Status:std_logic;
signal enable_gain:std_logic;
signal EN_ZERO: std_logic_vector(3 downto 0);

type array_aux is array(6*NSECT downto 0) of std_logic_vector(M-1 downto 0);
signal h0_aux:array_aux;

signal gains: std_logic_vector(M-1 downto 0);

type array_aux1 is array(6*NSECT downto 0) of std_logic;
signal enables:array_aux1;

begin
	ZERO<=std_logic_vector(to_unsigned(0,Data_wordwidth));

	EN_ZERO<=std_logic_vector(to_unsigned(0,4));
	OUT_AUX<=DAT_I;
	ACK_O<=STB_I;
	enable_in_aux(0)<=enable_in;
	--DAT_O<=sDAT_I;
	coefficients:
			for k in 6*NSECT-1 downto 0 generate			
								
				 enables(k)<='1' when ( WE_I='1' and STB_I='1' and ADR_I(7 downto 0)=std_logic_vector(to_unsigned((4*k)+Reg_coef,8))) else 
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
							h0((k+1)*M-1 downto k*M)<=std_logic_vector(h0_aux(k));				
						
			end generate;
								
								
								
	process(ADR_I,STB_I,WE_I,ZERO,EN_ZERO,OUT_AUX,rSTATUS_O)
	begin
		
			 if (WE_I='1' and STB_I='1') then--ESCRIBIR EN EL FILTRO
					case ADR_I(7 downto 0) is 
								
						when std_logic_vector(to_unsigned(Reg_control,8)) => 	start<='1';
																								DAT_O<=ZERO;								
																								Clear_Status<='0';
						
						when std_logic_vector(to_unsigned(Reg_status,8))=> Clear_Status<='1';
																								DAT_O<=ZERO;
																								start<='0';
						when OTHERS => start<='0';
											DAT_O<=ZERO;
											Clear_Status<='0';
					   end case;
			 elsif (WE_I='0' and STB_I='1') then
					case ADR_I(7 downto 0) is --LEER EL FILTRO
						when std_logic_vector(to_unsigned(Reg_data,8)) => 		
						
						                                                      DAT_O<=RegsDAT_O;
																								start<='0';	
																								
																								Clear_Status<='0';

						when std_logic_vector(to_unsigned(Reg_status,8)) =>	DAT_O(0)<=rSTATUS_O(0);
																								DAT_O(Data_wordwidth-1 downto 1)<=ZERO(Data_wordwidth-1 downto 1);	
																								start<='0';
																								
																								Clear_Status<='0';
						when OTHERS => start<='0';
							
											--DAT_O(M-1 downto 0)<= h0_aux(to_integer(unsigned(ADR_I(7 downto 0))-Reg_coef)/4);  
											--DAT_O(Data_wordwidth-1 downto M)<=(others => h0_aux(to_integer(unsigned(ADR_I(7 downto 0))-Reg_coef)/4)(M-1) );  
											
											DAT_O<=ssDAT_O;
											
											--DAT_O(M-1 downto 0)<= gains;  
											--DAT_O(Data_wordwidth-1 downto M)<=(others => gains(M-1) );  
											
											
											
											Clear_Status<='0';
					end case;
					 		
					
			 else 
						start<='0';
						DAT_O<=ZERO;
						Clear_Status<='0';
			 end if;

	end process;
	
	process(ADR_I,STB_I,WE_I,OUT_AUX)
	begin
	 if rising_edge(clk) then 
				
				 if (WE_I='1' and STB_I='1') then
						if ADR_I(7 downto 0)=std_logic_vector(to_unsigned(reg_data,8)) then 
								ssDAT_O<=OUT_AUX;
						end if;	
						if ADR_I(7 downto 0)=std_logic_vector(to_unsigned(Reg_Nsec,8)) then
								en_out<=OUT_AUX(3 downto 0);
						end if;		
																							
				 end if;
	 end if;	
		
			
	end process;
	
							Reg_Stat:fullregister
							generic map(
											N=>1
											)
							port map (
											clk=>clk,
											reset_n=>reset,
											enable=>(enable_in or Clear_Status),
											clear=>Clear_Status,
											d=>enable_in_aux,
											q=>rSTATUS_O								
											);
							Reg_sDat_O:fullregister
							generic map(
											N=>Data_wordwidth
											)
							port map (
											clk=>clk,
											reset_n=>reset,
											enable=>enable_in ,
											clear=>clear,
											d=>sDAT_I,
											q=>RegsDAT_O								
											);
											
											sDAT_O<=ssDAT_O;
											
							--Registro para gain
							
		enable_gain<='1'  when ( WE_I='1' and STB_I='1' and ADR_I(7 downto 0)=std_logic_vector(to_unsigned(Reg_gain,8))) else 
									'0'; 					
			gainreg:fullregister
							generic map(
											N=>M
											)
							port map (
											clk=>clk,
											reset_n=>reset,
											enable=>enable_gain,
											clear=>clear,
											d=>DAT_I(M-1 downto 0),
											q=>gains
											);				
											
											gain<=gains;
											
end architecture;
 
 
 
