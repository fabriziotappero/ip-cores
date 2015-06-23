library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lcd is
    Port ( lcd_data   : out std_logic_vector (7 downto 4);
           clk        : in  std_logic;
           reset      : in  std_logic;
           lcd_enable : out STD_LOGIC_VECTOR (1 DOWNTO 0);
           lcd_rs     : out std_logic;
           lcd_rw     : out std_logic
         );
end lcd ;

architecture behavioural of lcd is

    type state_type is (warmup, setfunc, clear1, clear2, setmode1, setmode2, write1, home1, home2);

    signal state : state_type;

    attribute syn_state_machine : boolean;
    attribute syn_state_machine of state : signal is true;

    signal count    : std_logic_vector(3 downto 0);
    signal finished : std_logic;         -- set high if done write cycle

    signal  char_mode : std_logic_vector(1 downto 0);

    --defining the display
    constant N: integer :=8;
    type arr is array (1 to N) of std_logic_vector(7 downto 0);

    constant display_char1 : arr :=    (x"A0",  --blank
                                        X"68",  --h
                                        X"74",  --t
                                        X"74",  --t
                                        X"70",  --p
                                        X"3A",  --:
                                        X"2F",  --/
                                        X"2F"); --/

    constant display_char2 : arr :=    (X"77",  --w
                                        X"77",  --w
                                        X"77",  --w
                                        X"2E",  --.
                                        X"66",  --f
                                        X"70",  --p
                                        X"67",  --g
                                        X"61"); --a

    constant display_char3 : arr :=    (X"2E",  --.
                                        X"62",  --b
                                        X"65",  --e
                                        X"88",  --blank
                                        X"88",  --blank
                                        X"88",  --blank
                                        X"88",  --blank
                                        X"88"); --blank

    constant display_char4 : arr :=    (X"A0",  --blank
                                        X"88",  --blank
                                        X"58",  --X
                                        X"49",  --I
                                        X"4F",  --O
                                        X"53",  --S
                                        X"88",  --blank
                                        X"88"); --blank

    signal display_char : arr;

begin
    lcd_rw <= '0';
    lcd_enable(1) <= clk; --not clk;  -- this is very important! if enable is not pulsed, lcd will not write
    lcd_enable(0) <= clk;

    char_mode_process: process (char_mode)
    begin
        case char_mode  is
            when "00" =>
                display_char <= display_char1;
            when "01" =>
                display_char <= display_char2;
            when "10" =>
                display_char <= display_char3;
            when "11" =>
                display_char <= display_char4;
            when OTHERS  =>
                display_char <= display_char1;
         end case;
    end process;

    state_set: process (clk, reset, finished)
    begin
      if (reset = '1') then

         state     <= warmup;   --setfunc;
         count     <= (others => '0');
         char_mode <= (others => '0');

      elsif (clk'event and clk = '1') then
         case state is

            when warmup =>
               lcd_rs <= '0';
               lcd_data <= "0011"; --"0000";  -- do nothing
               if count = "0111" then  --0111
                  count <= (others => '0');
                  state <= setfunc;
               else
                  count <= count + '1';
                  state <= warmup;
               end if;

            when setfunc =>
               lcd_rs <= '0';
               lcd_data <= "0010";
               finished <= '0';

               if count = "0010" then  --0010
                  count <= (others => '0');
                  state <= clear1;
               else
                  count <= count + '1';
                  state <= setfunc;
               end if;

            when clear1 =>

               lcd_rs <= '0';
               lcd_data <= "0000";
               state <= clear2;

            when clear2 =>
               lcd_rs <= '0';
               if count = "0111" then
                    state <= setmode1;
                    count <= (others => '0');
                    lcd_data <= "1111";
               else
                    count <= count + '1';
                    lcd_data <= "0001";
                    state <= clear1;
               end if;

            when setmode1 =>
               lcd_rs   <= '0';
               lcd_data <= "0000";
               state    <= setmode2;
               finished <= '0';

            when setmode2 =>
               lcd_rs   <= '0';
               lcd_data <= "0110";
               state    <= write1;

            when write1 =>
               if finished = '1' then
                  state <= home1;
               else
                  lcd_rs <= '1';
                  count  <= count  + '1';
                  state  <= write1;

                  CASE count IS

                     WHEN "0000" =>
                         lcd_data <= display_char(1)(7 downto 4);

                     WHEN "0001" =>
                         lcd_data <= display_char(1)(3 downto 0);

                     WHEN "0010" =>
                         lcd_data <= display_char(2)(7 downto 4);

                     WHEN "0011" =>
                         lcd_data <= display_char(2)(3 downto 0);

                     WHEN "0100"=>
                         lcd_data <= display_char(3)(7 downto 4);

                     WHEN "0101"=>
                         lcd_data <= display_char(3)(3 downto 0);

                     WHEN "0110"=>
                         lcd_data <= display_char(4)(7 downto 4);

                     WHEN "0111"=>
                         lcd_data <= display_char(4)(3 downto 0);

                     WHEN "1000" =>
                         lcd_data <= display_char(5)(7 downto 4);

                     WHEN "1001" =>
                         lcd_data <= display_char(5)(3 downto 0);

                     WHEN "1010" =>
                         lcd_data <= display_char(6)(7 downto 4);

                     WHEN "1011" =>
                         lcd_data <= display_char(6)(3 downto 0);

                     WHEN "1100" =>
                         lcd_data <= display_char(7)(7 downto 4);

                     WHEN "1101" =>
                         lcd_data <= display_char(7)(3 downto 0);

                     WHEN "1110" =>
                         lcd_data <= display_char(8)(7 downto 4);
                         --finished <= '1';  -- needed to set done low before valid data is gone
                         --char_mode  <= char_mode + '1';

                    WHEN "1111" =>
                         lcd_data <= display_char(8)(3 downto 0);
                         finished <= '1';  -- needed to set done low before valid data is gone
                         char_mode  <= char_mode + '1';

                     WHEN OTHERS =>
                         lcd_data <= "0000";  -- ' '

                  END CASE;
               end if;

            when home1 =>
               lcd_rs <= '0';
               lcd_data <= "0000";
               state <= home2;
               finished <= '0';
               count <= (others => '0');

            when home2 =>
               lcd_rs <= '0';
               lcd_data <= "0111";
               state <= write1;

         end case;

      end if;

   end process;

end behavioural;
