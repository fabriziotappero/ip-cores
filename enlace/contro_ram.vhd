library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity contro_ram is
	generic(
		addr_bits : integer := 8); -- 2^addr_bits = numero bits de direccionamiento
  	port(
--entradas y salidas de la RAM
		clk			:in std_logic;
		reset		:in std_logic;
		Eram 		:out std_logic;
		Eram_write 	:out std_logic;
		ram_addr 		:out std_logic_vector(addr_bits-1 downto 0);
		data_in_ram 	:out std_logic_vector(7 downto 0);
		data_out_ram	:in std_logic_vector(7 downto 0);
--entradas y salidas del pico blaze
	 	Eram_picoB	:in std_logic;
		WEram_picoB	:in std_logic;
		addr_picoB	:in std_logic_vector(addr_bits-1 downto 0);
		data_in_ram_picoB:in std_logic_vector(7 downto 0);
		data_out_ram_picoB:out std_logic_vector(7 downto 0);
--entradas y salidas del componente detector
		Eram_det		:in std_logic;
		Eram_write_det	:in std_logic;
		ram_addr_det	:in std_logic_vector(addr_bits-1 downto 0);	
		data_in_ram_det:in std_logic_vector(7 downto 0);
--entradas y salidas del componente generador trama
          E_ram_gen		:in std_logic;
		WE_ram_gen	:in std_logic;
		addr_ram_gen	:in std_logic_vector(addr_bits-1 downto 0);	
		data_out_ram_gen:out std_logic_vector(7 downto 0)
		);		
end contro_ram;

architecture Behavioral of contro_ram is

--signal Senable_ram : std_logic_vector (2 downto 0):="000";
begin

--Senable_ram <= Eram_det & E_ram_gen & Eram_picoB;

enable_ram: process(clk, Eram_det,E_ram_gen,Eram_picoB)
variable Venable_ram : std_logic_vector (2 downto 0):="000";
begin
Venable_ram := Eram_det & E_ram_gen & Eram_picoB;
if clk'event and clk = '1' then
	case (Venable_ram) is 
--	case (Senable_ram) is 
	 when "001" =>
	 	Eram 		<= Eram_picoB;
		Eram_write 	<= WEram_picoB;
		ram_addr 		<= addr_picoB;
		data_in_ram 	<= data_in_ram_picoB;
		data_out_ram_picoB <= data_out_ram;	
    when "010" =>
      Eram 		<= E_ram_gen;
		Eram_write 	<= WE_ram_gen;
		ram_addr 	<= addr_ram_gen;
		data_in_ram 	<= (others=>'0');
		data_out_ram_gen <= data_out_ram;   
	 when "100" =>
      Eram 		<= Eram_det;
		Eram_write 	<= Eram_write_det;
		ram_addr 	<= ram_addr_det;
		data_in_ram 	<= data_in_ram_det;
    when others =>
     	Eram 		<= '0';
		Eram_write	<= '0';
		ram_addr 	<= (others=>'0');
		data_in_ram 	<= (others=>'0');
    end case;
end if;
end process;

end Behavioral;
