--! @file
--! @brief Serial transmitter http://www.fpga4fun.com/SerialInterface.html
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity serial_transmitter is
    Port ( rst : in  STD_LOGIC;												--! Reset input
           baudClk : in  STD_LOGIC;											--! Baud rate clock input
           data_byte : in  STD_LOGIC_VECTOR ((nBits-1) downto 0);	--! Byte to be sent
			  data_sent : out STD_LOGIC;										--! Indicate that byte has been sent
           serial_out : out  STD_LOGIC);									--! Uart serial output
end serial_transmitter;

--! @brief Serial transmitter http://www.fpga4fun.com/SerialInterface.html
--! @details Implement block that serialize the "data_byte" signal on a stream of bits clocked out by "baudClk"
architecture Behavioral of serial_transmitter is
signal current_s,next_s: txStates; 
begin
	
	-- Next state process
	process (rst, baudClk) 
	begin
		if rst = '1' then
			current_s <= tx_idle;
		elsif rising_edge(baudClk) then
			current_s <= next_s;
		end if;
	end process;
	
	process (current_s, data_byte)
	begin
		case current_s is
			when tx_idle =>
				serial_out <= '1';
				data_sent <= '0';
				next_s <= tx_start;
			
			-- Start bit
			when tx_start =>
				serial_out <= '0';
				data_sent <= '0';
				next_s <= bit0;
			
			when bit0 =>	-- Send the least significat bit
				serial_out <= data_byte(0);
				data_sent <= '0';
				next_s <= bit1;
				
			when bit1 =>
				serial_out <= data_byte(1);
				data_sent <= '0';
				next_s <= bit2;
				
			when bit2 =>
				serial_out <= data_byte(2);
				data_sent <= '0';
				next_s <= bit3;
				
			when bit3 =>
				serial_out <= data_byte(3);
				data_sent <= '0';
				next_s <= bit4;
					
			when bit4 =>
				serial_out <= data_byte(4);
				data_sent <= '0';
				next_s <= bit5;
				
			when bit5 =>
				serial_out <= data_byte(5);
				data_sent <= '0';
				next_s <= bit6;
				
			when bit6 =>
				serial_out <= data_byte(6);
				data_sent <= '0';
				next_s <= bit7;
				
			when bit7 =>	-- Send the most significat bit
				serial_out <= data_byte(7);
				data_sent <= '0';
				next_s <= tx_stop1;
							
			
			when tx_stop1 =>
				serial_out <= '1';
				data_sent <= '1';
				next_s <= tx_stop2;
			
			when tx_stop2 =>	-- Stop here and wait for other reset
				serial_out <= '1';
				data_sent <= '1';
				next_s <= tx_stop2;
			
		end case;
	end process;

end Behavioral;

