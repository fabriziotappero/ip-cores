library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- La mayoría de las familias de las FPGA Spartan poseen bloques de RAM.
-- para hacer uso de los mismos se debe realizar una descripción adecuada
-- que se obtiene de los templates proporcionados por el fabricante.
-- El módulo descripto a continuación hace uso de ésta característica para
-- almacenar los datos que son adquiridos de la red MODBUS en un nivel de enlace.



entity ram2_top is
	generic ( bits : integer := 8;   -- ancho de datos de la memoria
            	addr_bits : integer := 8); -- 2^addr_bits = numero bits de direccionamiento
	port(
		clk		:in	std_logic;
		reset	:in	std_logic;
		E		:in	std_logic;	-- habilitador de la ram
		WE		:in	std_logic;	-- habilitador de escritura
		ADDR		:in	std_logic_vector(addr_bits-1 downto 0);
		data_in	:in	std_logic_vector(bits-1 downto 0);
		data_out	:out	std_logic_vector(bits-1 downto 0));
end ram2_top;

architecture Behavioral of ram2_top is

type tipo_ram is array (2**addr_bits-1 downto 0) of std_logic_vector (bits-1 downto 0);   
signal RAM : tipo_ram;	   
begin

process (clk)
begin
   if (clk'event and clk = '1') then
      if (E = '1') then
         if (WE = '1') then
            RAM(conv_integer(ADDR)) <= data_in;
         else
            data_out <= RAM(conv_integer(ADDR));
         end if;
      end if;
   end if;
end process;

end Behavioral;
