library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--use work.fft_pkg.all;

entity interface_slave_fft is 
generic(
N: integer:=1024;
data_wordwidth: integer:=32;
adress_wordwidth: integer:=32;
reg_control:integer:=0;
reg_data:integer:=4;
reg_status:integer:=8;
reg_memory:integer:=12


);
port(
 
 
 ACK_O: out   std_logic;--to MASTER
 ADR_I: in    std_logic_vector( adress_wordwidth-1 downto 0 );
 ADR_FFT: in    std_logic_vector( integer(ceil(log2(real(N))))-1 downto 0 );
 DAT_I: in    std_logic_vector( data_wordwidth-1 downto 0 );--from MASTER
 sDAT_I: in    std_logic_vector( data_wordwidth-1 downto 0 );--from SLAVE
 DAT_O: out   std_logic_vector( data_wordwidth-1 downto 0 );--to MASTER
 sDAT_O: out   std_logic_vector( data_wordwidth-1 downto 0 );--to SLAVE
 STB_I: in    std_logic;--from MASTER
 WE_I: in    std_logic;--from MASTER
 FFT_finish_in: in    std_logic;--from SLAVE	
 FFT_enable: out    std_logic;--to SLAVE	
 enable_in: in    std_logic;--from SLAVE	
 clear_out: out    std_logic;--to SLAVE
 clk: in std_logic
 );
end entity;
 
architecture RTL of interface_slave_fft is 

component ramsita IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

component RAM_Memory is 
generic(

Add_WordWidth: integer;
Data_WordWidth: integer
);
port(
 
 
 DATi: in   std_logic_vector( Data_WordWidth-1 downto 0 );
 DATo: out   std_logic_vector( Data_WordWidth-1 downto 0 );
 ADR_WB: in    std_logic_vector( Add_WordWidth-1 downto 0 );
 ADR_FFT: in    std_logic_vector( Add_WordWidth-1 downto 0 );
 W_R: in    std_logic;
 clk: in std_logic
 
 );
end component;

signal OUT_AUX,OUT_AUX1, ZERO:  std_logic_vector( Data_wordwidth-1 downto 0 );
signal ADD_aux:std_logic_vector( integer(ceil(log2(real((N+3)*4))))-1 downto 0 );

signal ack_r, ack_w: std_logic;

begin
	
	OUT_AUX<=DAT_I;
	ZERO<=std_logic_vector(to_unsigned(0,Data_wordwidth));



	ACK_O<=ack_r or ack_w;

	--Reconocimiento de escritura sin estado de espera
	ack_w<= '1' when (STB_I='1' and WE_I='1') else '0';
	
	

	--Reconocimiento de lectura con 1 estado de espera, caso RAM sincrona
	process(clk)
	
	begin
		if(rising_edge(clk)) then
			if(STB_I='1' and WE_I='0') then
			
			ack_r<='1';			
			else 			
			ack_r<='0';
			
			end if;
		end if;
	
		end process;
	
	
   --Se elimina offset para direcciones de lectura de memoria RAM 
	ADD_aux<=std_logic_vector(unsigned(ADR_I(integer(ceil(log2(real((N+3)*4))))-1 downto 0))-(reg_memory));
	
	RAM: RAM_Memory  
generic map(

Add_WordWidth=>integer(ceil(log2(real(N)))),
Data_WordWidth=>Data_WordWidth
)
port map(
 
 
 DATi=>sDAT_I,
 DATo=>OUT_AUX1,
 --Divide entre cuatro, direcciones alineadas cada 4 bytes
 ADR_WB=>ADD_aux(integer(ceil(log2(real((N)))))+1 downto 2),
 ADR_FFT=>ADR_FFT(integer(ceil(log2(real(N))))-1 downto 0),
 W_R=>enable_in,
 clk=>clk 
 );


   --Decodificador de escritura
	process(ADR_I,STB_I,WE_I,ZERO,OUT_AUX,OUT_AUX1,FFT_finish_in)
	begin
		
	
			 if (WE_I='1' and STB_I='1') then--ESCRIBIR EN FFT
					case ADR_I(integer(ceil(log2(real((N+3)*4))))-1 downto 0) is 
								
						when std_logic_vector(to_unsigned(Reg_control,integer(ceil(log2(real((N+3)*4)))))) => 	
																												clear_out<='1';
																												FFT_enable<='1';																													
																												sDAT_O<=ZERO;						
						when std_logic_vector(to_unsigned(Reg_data,integer(ceil(log2(real((N+3)*4))))))=>   
																											  sDAT_O<=OUT_AUX;
																											 FFT_enable<='1';																										 
																											 clear_out<='0';
																							 	
						when OTHERS => sDAT_O<=ZERO;											
											clear_out<='0';
											FFT_enable<='0';	
					   end case;
			 		
			 else 
						sDAT_O<=ZERO;						
						clear_out<='0';
						FFT_enable<='0';
			 end if;
			 
		

	end process;
	
	--Decodificador de lectura
	process(ADR_I,STB_I,WE_I,ZERO,OUT_AUX,OUT_AUX1,FFT_finish_in)
	begin
	
	
	
	if (WE_I='0' and STB_I='1') then
			 

			 
					if ADR_I(integer(ceil(log2(real((N+3)*4))))-1 downto 0) = std_logic_vector(to_unsigned(Reg_status,integer(ceil(log2(real((N+3)*4)))))) then			
				
																								DAT_O(0)<=FFT_finish_in;
																								DAT_O(Data_wordwidth-1 downto 1)<=ZERO(Data_wordwidth-1 downto 1);														
						else   
						 										DAT_O<=OUT_AUX1;											
	
						end if;
						
						else 
						DAT_O<=ZERO;
							end if;

end process;	
		

								
end architecture;
 
 
 
