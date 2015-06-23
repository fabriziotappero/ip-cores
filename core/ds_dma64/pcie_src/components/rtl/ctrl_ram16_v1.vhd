---------------------------------------------------------------------------------------------------
--
-- Title       : ctrl_ram16_v1
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0	 
--
---------------------------------------------------------------------------------------------------
--
-- Description :  Теневое ОЗУ для командных регистров и констант
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use	work.host_pkg.all;

package ctrl_ram16_v1_pkg is
	
component ctrl_ram16_v1 is	   
	generic (
		rom			: in bh_rom			-- значения констант
	);
	port(
		clk			: in std_logic;		-- Тактовая частота
		
		adr			: in std_logic_vector( 4 downto 0 );	-- адрес
		data_in		: in std_logic_vector( 15 downto 0 );	-- вход данных
		data_out	: out std_logic_vector( 15 downto 0 );	-- выход данных
		
		data_we		: in std_logic		-- 1 - запись данных
		
	);
end component;

end package ctrl_ram16_v1_pkg;	   




library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library work;
use	work.host_pkg.all;



entity ctrl_ram16_v1 is	   
	generic (
		rom			: in bh_rom			-- значения констант
	);
	port(
		clk			: in std_logic;		-- Тактовая частота
		
		adr			: in std_logic_vector( 4 downto 0 );	-- адрес
		data_in		: in std_logic_vector( 15 downto 0 );	-- вход данных
		data_out	: out std_logic_vector( 15 downto 0 );	-- выход данных
		
		data_we		: in std_logic		-- 1 - запись данных
		
	);
end ctrl_ram16_v1;


architecture ctrl_ram16_v1 of ctrl_ram16_v1 is

function conv_rom( rom: in bh_rom; mode: integer ) return bit_vector is
 variable ret: bit_vector( 15 downto 0 );
begin
	for i in 0 to 7 loop
		ret( i ):=to_bit( rom( i )( mode ), '0' );
	end loop;
	for i in 8 to 15 loop
		ret( i ):='0';
	end loop;
	return ret;
end conv_rom;	

function conv_string( rom: in bh_rom; mode: integer ) return string is
 variable str: string( 4 downto 1 );
 
 variable d	: std_logic_vector( 15 downto 0 );
 variable c	: std_logic_vector( 3 downto 0 );
 variable k	: integer;
begin			 
	
	
	
  for i in 0 to 7 loop  			
	d(i):=rom( i )( mode );
  end loop;
  for i in 8 to 15 loop  			
	d(i):='0';
  end loop;
  
  for j in 0 to 3 loop
	 c:=d( j*4+3 downto j*4 );
	 k:=j+1;
  	 case c is
		when x"0" => str(k) := '0';
		when x"1" => str(k) := '1';
		when x"2" => str(k) := '2';
		when x"3" => str(k) := '3';
		when x"4" => str(k) := '4';
		when x"5" => str(k) := '5';
		when x"6" => str(k) := '6';
		when x"7" => str(k) := '7';
		when x"8" => str(k) := '8';
		when x"9" => str(k) := '9';
		when x"A" => str(k) := 'A';
		when x"B" => str(k) := 'B';
		when x"C" => str(k) := 'C';
		when x"D" => str(k) := 'D';
		when x"E" => str(k) := 'E';
		when x"F" => str(k) := 'F';	
		when others => null;
	 end case;
  end loop; 
		
  return str;
end conv_string;	


constant rom_init_00	: bit_vector( 15 downto 0 ):= conv_rom( rom, 0 );
constant rom_init_01	: bit_vector( 15 downto 0 ):= conv_rom( rom, 1 );
constant rom_init_02	: bit_vector( 15 downto 0 ):= conv_rom( rom, 2 );
constant rom_init_03	: bit_vector( 15 downto 0 ):= conv_rom( rom, 3 );
constant rom_init_04	: bit_vector( 15 downto 0 ):= conv_rom( rom, 4 );
constant rom_init_05	: bit_vector( 15 downto 0 ):= conv_rom( rom, 5 );
constant rom_init_06	: bit_vector( 15 downto 0 ):= conv_rom( rom, 6 );
constant rom_init_07	: bit_vector( 15 downto 0 ):= conv_rom( rom, 7 );
constant rom_init_08	: bit_vector( 15 downto 0 ):= conv_rom( rom, 8 );
constant rom_init_09	: bit_vector( 15 downto 0 ):= conv_rom( rom, 9 );
constant rom_init_0A	: bit_vector( 15 downto 0 ):= conv_rom( rom, 10 );
constant rom_init_0B	: bit_vector( 15 downto 0 ):= conv_rom( rom, 11 );
constant rom_init_0C	: bit_vector( 15 downto 0 ):= conv_rom( rom, 12 );
constant rom_init_0D	: bit_vector( 15 downto 0 ):= conv_rom( rom, 13 );
constant rom_init_0E	: bit_vector( 15 downto 0 ):= conv_rom( rom, 14 );
constant rom_init_0F	: bit_vector( 15 downto 0 ):= conv_rom( rom, 15 );



constant str_init_00	: string:= conv_string( rom, 0 );
constant str_init_01	: string:= conv_string( rom, 1 );
constant str_init_02	: string:= conv_string( rom, 2 );
constant str_init_03	: string:= conv_string( rom, 3 );
constant str_init_04	: string:= conv_string( rom, 4 );
constant str_init_05	: string:= conv_string( rom, 5 );
constant str_init_06	: string:= conv_string( rom, 6 );
constant str_init_07	: string:= conv_string( rom, 7 );
constant str_init_08	: string:= conv_string( rom, 8 );
constant str_init_09	: string:= conv_string( rom, 9 );
constant str_init_0A	: string:= conv_string( rom, 10 );
constant str_init_0B	: string:= conv_string( rom, 11 );
constant str_init_0C	: string:= conv_string( rom, 12 );
constant str_init_0D	: string:= conv_string( rom, 13 );
constant str_init_0E	: string:= conv_string( rom, 14 );
constant str_init_0F	: string:= conv_string( rom, 15 );
	

--attribute rom_style : string;
--attribute rom_style of xram	: label is "block";

--attribute init			: string;
--
--attribute init of xram0	 : label is  str_init_00;
--attribute init of xram1	 : label is  str_init_01;
--attribute init of xram2	 : label is  str_init_02;
--attribute init of xram3	 : label is  str_init_03;
--attribute init of xram4	 : label is  str_init_04;
--attribute init of xram5	 : label is  str_init_05;
--attribute init of xram6	 : label is  str_init_06;
--attribute init of xram7	 : label is  str_init_07;
--attribute init of xram8	 : label is  str_init_08;
--attribute init of xram9	 : label is  str_init_09;
--attribute init of xram10 : label is  str_init_0A;
--attribute init of xram11 : label is  str_init_0B;
--attribute init of xram12 : label is  str_init_0C;
--attribute init of xram13 : label is  str_init_0D;
--attribute init of xram14 : label is  str_init_0E;
--attribute init of xram15 : label is  str_init_0F;
--


signal	wr		: std_logic;	-- 1 - запись в память
begin

wr <= '1' when data_we='1' and adr(4)='0' and adr(3)='1' else '0';


xram0:	ram16x1d 
		generic map(
			init =>  rom_init_00
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 0 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 0 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);

xram1:	ram16x1d 
		generic map(
			init =>  rom_init_01
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 1 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 1 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);

xram2:	ram16x1d 
		generic map(
			init =>  rom_init_02
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 2 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 2 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram3:	ram16x1d 
		generic map(
			init =>  rom_init_03
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 3 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 3 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram4:	ram16x1d 
		generic map(
			init =>  rom_init_04
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 4 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 4 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram5:	ram16x1d 
		generic map(
			init =>  rom_init_05
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 5 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 5 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram6:	ram16x1d 
		generic map(
			init =>  rom_init_06
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 6 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 6 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram7:	ram16x1d 
		generic map(
			init =>  rom_init_07
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 7 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 7 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram8:	ram16x1d 
		generic map(
			init =>  rom_init_08
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 8 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 8 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram9:	ram16x1d 
		generic map(
			init =>  rom_init_09
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 9 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 9 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram10:	ram16x1d 
		generic map(
			init =>  rom_init_0A
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 10 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 10 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram11:	ram16x1d 
		generic map(
			init =>  rom_init_0B
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 11 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 11 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram12:	ram16x1d 
		generic map(
			init =>  rom_init_0C
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 12 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 12 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram13:	ram16x1d 
		generic map(
			init =>  rom_init_0D
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 13 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 13 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram14:	ram16x1d 
		generic map(
			init =>  rom_init_0E
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 14 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 14 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		
xram15:	ram16x1d 
		generic map(
			init =>  rom_init_0F
		)
		port map(
			we 	=> wr,
			d 	=> data_in( 15 ),
			wclk => clk,
			a0	=> adr( 0 ),
			a1	=> adr( 1 ),
			a2	=> adr( 2 ),
			a3	=> adr( 3 ),
			spo	=> data_out( 15 ),
			dpra0 => adr( 0 ),
			dpra1 => adr( 1 ),
			dpra2 => adr( 2 ),
			dpra3 => adr( 3 )
		);
		

end ctrl_ram16_v1;
