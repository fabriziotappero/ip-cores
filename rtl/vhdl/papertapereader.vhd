----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:37:05 2009-08-20
-- Design Name: fake paper tape reader for PDP-1
-- Module Name:    papertapereader - Behavioral 
-- Project Name: PDP-1
-- Target Devices: Spartan 3A Starter Kit
-- Tool versions: Webpack 11.1
-- Description: RS-232 interface emulating a tape reader.
--
-- Dependencies: Minimal UART core from opencores.
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity papertapereader is
    Port ( clk : in STD_LOGIC;
           dopulse : in  STD_LOGIC;
           done : out  STD_LOGIC := 'L';
           io : out  STD_LOGIC_VECTOR (0 to 17) := (others=>'L');
           io_set : out  STD_LOGIC := 'L';
           ptr_rpa : in  STD_LOGIC;
           ptr_rpb : in  STD_LOGIC;
           ptr_rrb : in  STD_LOGIC;
           rb_loaded : out  STD_LOGIC;
			  RXD : in std_logic;
			  TXD : out std_logic);
end papertapereader;

architecture Behavioral of papertapereader is
	COMPONENT Minimal_UART_CORE
	PORT(
		CLOCK : IN std_logic;
		RXD : IN std_logic;
		INP : IN std_logic_vector(7 downto 0);
		WR : IN std_logic;    
		OUTP : INOUT std_logic_vector(7 downto 0);      
		EOC : OUT std_logic;
		TXD : OUT std_logic;
		EOT : OUT std_logic;
		READY : OUT std_logic
		);
	END COMPONENT;
	signal rb : std_logic_vector(0 to 17);
	signal received_byte, old_received_byte, tx_ready, wrote : std_logic := '0';
	signal read_byte, write_byte: std_logic_vector(7 downto 0);
	
	type task_type is (read_character, read_word0, read_word1, read_word2, done_reading, idle);
	signal task : task_type := idle;
	signal senddone : std_logic;
begin
	Inst_Minimal_UART_CORE: Minimal_UART_CORE PORT MAP(
		CLOCK => CLK,
		
		EOC => received_byte,	-- end of character; rising edge indicates valid data in OUTP
		OUTP => read_byte,
		
		RXD => RXD,
		TXD => TXD,

		EOT => open,	-- end of transmit; indicates a character has been sent
		INP => write_byte,
		READY => tx_ready,	-- indicates that we may write
		WR => wrote
	);
	write_byte <= x"65"; --"e" --"00010010";		-- ASCII device control 2 (Ctrl+R) to request a byte from the tape.
	
	rb_loaded <= '1' when task=done_reading else '0';
	process(clk)
	begin
          if rising_edge(clk) then
            -- default state for pulse signals
            wrote<='0';
            done <= '0';
            io_set <= '0';
            -- load edge detector
            old_received_byte <= received_byte;
            if received_byte='1' and old_received_byte='0' then
              case task is
                when idle =>		-- not awaiting a character, ignore it
                when read_character =>
                  rb(0 to 17-8) <= (others=>'0');
                  rb(17-7 to 17) <= read_byte;
                  task <= done_reading;
                when read_word0 =>
                  if read_byte(7)='1' then
                    rb(0 to 5) <= read_byte(5 downto 0);
                    task <= read_word1;
                  end if;
                  wrote<='1';	-- request another byte
                when read_word1 =>
                  if read_byte(7)='1' then
                    rb(6 to 11) <= read_byte(5 downto 0);
                    task <= read_word2;
                  end if;
                  wrote<='1';	-- request another byte
                when read_word2 =>
                  if read_byte(7)='1' then
                    rb(12 to 17) <= read_byte(5 downto 0);
                    task <= done_reading;
                  else
                    wrote<='1';	-- request another byte
                  end if;
                when others =>
              end case;
            end if;		-- received a byte
            if ptr_rpa='1' then
              task<=read_character;
              senddone<=dopulse;
              wrote<='1';
            elsif ptr_rpb='1' then
              task<=read_word0;
              senddone<=dopulse;
              wrote<='1';
            elsif ptr_rrb='1' then
              senddone<=dopulse;
            end if;
            if task=done_reading and senddone='1' then
              done<='1';
              IO<=rb;
              io_set<='1';
              task <= idle;
            end if;
          end if;		-- rising_edge(clk)
	end process;
        --io(0 to 17-8) <= (others => '0');
        --io(17-7 to 17) <= read_byte;
end Behavioral;
