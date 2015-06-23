library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity DS1722 is
    Port(	CLK_I:      in    	std_logic;
			RST_I:      in    	std_logic;
	
			DATA_IN: 	in 	std_logic_vector(7 downto 0);	
			DATA_OUT: 	out 	std_logic_vector(7 downto 0);	
			ADDRESS:	in 	std_logic_vector(7 downto 0);				

			START:		in	std_logic;
			DONE:		out	std_logic;
	
			TEMP_SPI: 	out 	STD_LOGIC;	-- Physical interfaes
			TEMP_SPO: 	in 	STD_LOGIC;
			TEMP_CE: 	out 	STD_LOGIC;
			TEMP_SCLK: 	out 	STD_LOGIC
    );
end DS1722;

architecture DS1722_arch of DS1722 is

	signal counter    : std_logic_vector(7 downto 0);
	signal data_latch : std_logic_vector(7 downto 0);

type BIG_STATE is (	SET_CE, LATCH_ADD, ADD_OUT_1, ADD_OUT_2,
					DATA, WRITE_DATA_1, WRITE_DATA_2, READ_DATA_1, READ_DATA_2,
					NEXT_TO_LAST_ONE, LAST_ONE);

	signal state : BIG_STATE;

	signal bit_count:  INTEGER range 0 to 7;

	signal Write: std_logic;

begin

	-- divide CLK_I by 256
	--
	process (CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then	counter <= "00000000";
			else					counter <= counter + "00000001";
			end if;
		end if;
	end process;

	DONE     <= START when (state = LAST_ONE) else '0';
	DATA_OUT <= data_latch;

	Write <= ADDRESS(7);

	-- convert byte commands to SPI and SPI to byte.
	--
	process (CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				state     <= SET_CE;
				TEMP_CE   <= '0';
				TEMP_SCLK <= '0';
				bit_count <= 0;
			elsif (counter = "11111111" and START = '1') then
				case state is
					when SET_CE =>
						TEMP_SCLK <= '0';
						TEMP_CE <= '1';
						state <= LATCH_ADD;
						bit_count <= 0;

					when LATCH_ADD =>
						TEMP_SCLK <= '0';
						TEMP_CE <= '1';
						state <= ADD_OUT_1;
						data_latch <= ADDRESS;

					when ADD_OUT_1 =>
						TEMP_SCLK <= '1';
						TEMP_CE <= '1';
						state <= ADD_OUT_2;
						TEMP_SPI <= data_latch(7);																	

					when ADD_OUT_2 =>
						TEMP_SCLK <= '0';
						TEMP_CE <= '1';
						data_latch <= data_latch(6 downto 0) & data_latch(7);
						if bit_count < 7 then
							state <= ADD_OUT_1;
							bit_count <= bit_count + 1;								
						else
							state <= DATA;
							bit_count <= 0;
						end if;

					when DATA =>
						data_latch <= DATA_IN;
						TEMP_SCLK <= '0';
						TEMP_CE <= '1';
						if Write = '0' then
							state <= READ_DATA_1;
						else 	
							state <= WRITE_DATA_1;
						end if;

					when WRITE_DATA_1 =>
						TEMP_SCLK <= '1';
						TEMP_CE <= '1';
						state <= WRITE_DATA_2;
						TEMP_SPI <= data_latch(7);																	

					when WRITE_DATA_2 =>
						TEMP_SCLK <= '0';
						TEMP_CE <= '1';
						data_latch <=  data_latch(6 downto 0) & data_latch(7);
						if bit_count < 7 then
							state <= WRITE_DATA_1;
							bit_count <= bit_count + 1;								
						else
							state <= NEXT_TO_LAST_ONE;
							bit_count <= 0;
						end if;																								

					when READ_DATA_1 =>
						TEMP_SCLK <= '1';
						TEMP_CE <= '1';
						state <= READ_DATA_2;
			
					when READ_DATA_2 =>
						TEMP_SCLK <= '0';
						TEMP_CE   <= '1';
						data_latch <= data_latch(6 downto 0) & TEMP_SPO;
						if bit_count < 7 then
							state     <= READ_DATA_1;
							bit_count <= bit_count + 1;								
						else
							state     <= NEXT_TO_LAST_ONE;
							bit_count <= 0;
						end if;

					when NEXT_TO_LAST_ONE =>
						TEMP_CE   <= '0';
						TEMP_SCLK <= '0';
						state     <= LAST_ONE;

					when LAST_ONE =>
						TEMP_CE   <= '0';
						TEMP_SCLK <= '0';
						state     <= SET_CE;
				end case;
			end if;
		end if;
	end process;

end DS1722_arch;
