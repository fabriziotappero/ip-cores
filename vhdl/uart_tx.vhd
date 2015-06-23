library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity UART_TX is 
	PORT(	CLK_I      : in  std_logic;	
			RST_I      : in  std_logic;							-- RESET
			CE_16      : in  std_logic;							-- BUAD rate clock
			DATA       : in  std_logic_vector(7 downto 0);		-- DATA to be sent
			DATA_FLAG  : in  std_logic;							-- toggle to send data
			SER_OUT    : out std_logic;							-- Serial output line
			DATA_FLAGQ : out std_logic							-- Transmitting Flag
		);
end UART_TX;


architecture TX_UART_arch of UART_TX is

	signal BUF      : std_logic_vector(7 downto 0);
	signal TODO     : integer range 0 to 9;			-- bits to send
	signal FLAGQ    : std_logic;
	signal CE_1     : std_logic;
	signal C16      : std_logic_vector(3 downto 0);

begin

	DATA_FLAGQ <= FLAGQ;

	-- generate a CE_1 every 16 CE_16...
	--
	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			CE_1 <= '0';
			if (RST_I = '1') then
				C16 <= "0000";
			elsif (CE_16 = '1') then
				if (C16 = "1111") then
					CE_1 <= '1';
				end if;
				C16 <= C16 + "0001";
			end if;
		end if;
	end process;

	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				SER_OUT     <= '1';
				BUF         <= "11111111";
				TODO        <= 0;
				FLAGQ       <= DATA_FLAG;					-- idle
			elsif (CE_1 = '1') then
				if (TODO > 0) then							-- transmitting
					SER_OUT <= BUF(0);		-- next bit
					BUF     <= '1' & BUF(7 downto 1);
					if (TODO = 1) then
						FLAGQ   <= DATA_FLAG;
					end if;
					TODO    <= TODO - 1;
				elsif (FLAGQ /= DATA_FLAG) then				-- new byte
					SER_OUT <= '0';			-- start bit
					TODO    <= 9;
					BUF     <= DATA;
				end if;
			end if;
		end if;
	end process; 

end TX_UART_arch;  
