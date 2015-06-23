library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity UART_RX is
	PORT(	CLK_I     : in  std_logic;
			RST_I     : in  std_logic;
			CE_16     : in  std_logic;			-- 16 times baud rate 
			SER_IN    : in  std_logic;			-- Serial input line

			DATA      : out std_logic_vector(7 downto 0);
			DATA_FLAG : out std_logic			-- toggle on every byte received
   );
end UART_RX;

architecture RX_UART_arch of UART_RX is

	signal POSITION   : std_logic_vector(7 downto 0);		--  sample position
	signal BUF        : std_logic_vector(9 downto 0); 
	signal LDATA_FLAG : std_logic; 
	signal SER_IN1    : std_logic;							-- double clock the input
	signal SER_HOT    : std_logic;							-- double clock the input

begin

	-- double clock the input data...
	--
	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then	
			if (RST_I = '1') then
				SER_IN1 <= '1';
				SER_HOT <= '1';
			else
				SER_IN1 <= SER_IN;
				SER_HOT <= SER_IN1;
			end if;
		end if;
	end process;

	DATA_FLAG <= LDATA_FLAG;

	process(CLK_I, POSITION)

		variable START_BIT : boolean;
		variable STOP_BIT  : boolean;
		variable STOP_POS  : boolean;

	begin
		START_BIT := POSITION(7 downto 4) = X"0";
		STOP_BIT  := POSITION(7 downto 4) = X"9";
		STOP_POS  := STOP_BIT and POSITION(3 downto 2) = "11";		-- 3/4 of stop bit

		if (rising_edge(CLK_I)) then	
			if (RST_I = '1') then
				LDATA_FLAG <= '0';
				POSITION   <= X"00";	-- idle
				BUF        <= "1111111111";
				DATA       <= "00000000";
			elsif (CE_16 = '1') then	
				if (POSITION = X"00") then			-- uart idle
					BUF    <= "1111111111";
					if (SER_HOT = '0')  then		-- start bit received
						POSITION <= X"01";
					end if;
				else
					POSITION <= POSITION + X"01";
					if (POSITION(3 downto 0) = "0111") then		-- 1/2 of the bit
						BUF <= SER_HOT & BUF(9 downto 1);		-- sample data
						-- validate start bit
						--
						if (START_BIT and SER_HOT = '1') then	-- inside start bit
							POSITION <= X"00";
						end if;

						if (STOP_BIT) then					-- inside stop bit
							DATA <= BUF(9 downto 2);
						end if;
					elsif (STOP_POS) then	-- 3/4 of stop bit
						LDATA_FLAG <= LDATA_FLAG xor (BUF(9) and not BUF(0));
						POSITION <= X"00";
					end if;
				end if;
			end if;
		end if;
	end process;	

end RX_UART_arch;
