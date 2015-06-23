library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity madi_receiver is
 port(
  clk_125_in : in std_logic;
  madi_clk_in : in std_logic;
  madi_data_valid : in std_logic;
  madi_symbol_in : in std_logic_vector(4 downto 0);
  
  madi_write : out std_logic;
  madi_wordclock : out std_logic;
  madi_channel : out std_logic_vector(5 downto 0) := (others => '0');
  madi_data : out std_logic_vector(23 downto 0) := (others => '0')
 );
end madi_receiver;

architecture behavioral of madi_receiver is
 type nibble_buffer is array(7 downto 0) of std_logic_vector(3 downto 0);
 
 signal madi_input_shift : std_logic_vector(14 downto 0) := (others => '0');
 signal madi_clk_shift : std_logic_vector(1 downto 0) := (others => '0');
 signal madi_sync_detect : std_logic := '0';
 signal madi_aligned : std_logic := '0';
 signal madi_symbol : std_logic_vector(4 downto 0) := (others => '0');
 signal madi_symbol_count : std_logic_vector(2 downto 0) := (others => '0');
 signal madi_sync_count : std_logic_vector(8 downto 0) := (others => '0');
 signal madi_nibble_clk : std_logic := '0';
 signal madi_nibble : std_logic_vector(3 downto 0) := (others => '0');
 signal madi_nibble_cnt : std_logic_vector(2 downto 0) := (others => '0');
 signal madi_nibble_buffer : nibble_buffer;
 signal madi_nibble_rst : std_logic := '0';
 signal madi_channel_cnt : std_logic_vector(5 downto 0) := (others => '0');
 signal madi_channel_rst : std_logic := '0';
 signal madi_write_buffer : std_logic := '0';
 signal madi_wordclk_shift : std_logic_vector(1 downto 0);
 signal madi_wordclk_current : std_logic_vector(11 downto 0) := (others => '0');
 signal madi_wordclk_reference : std_logic_vector(24 downto 0) := (others => '0');
 signal madi_wordclk_count : std_logic_vector(11 downto 0) := (others => '0');
 
begin

 madi_shift_clk : process (clk_125_in)
 begin
  if clk_125_in'event and clk_125_in = '1' then
   madi_clk_shift <= madi_clk_shift(0) & madi_clk_in;
  end if;
 end process madi_shift_clk;

 madi_shift_input : process (clk_125_in)
 begin
  if clk_125_in'event and clk_125_in = '1' then
   if madi_clk_shift = "01" then
    madi_input_shift <= madi_input_shift(13 downto 4) & madi_symbol_in;
   else
    madi_input_shift <= madi_input_shift(13 downto 0) & '0';
   end if;
  end if;
 end process madi_shift_input;
 
 madi_detect_sync : process (clk_125_in)
 begin
  if clk_125_in'event and clk_125_in = '1' then
   if madi_symbol_count = 4 then
    madi_symbol_count <= (others => '0');
    if madi_aligned = '1' then
     madi_symbol <= madi_input_shift(9 downto 5);
    end if;
   else
    madi_symbol_count <= madi_symbol_count + 1;
    if madi_input_shift(14 downto 5) = "1100010001" then -- JK sync Symbols detected?
     madi_symbol_count <= (others => '0');
     madi_sync_detect <= '1';
     madi_aligned <= '1';
    else
     madi_sync_detect <= '0';
    end if;
   end if;
  end if;
 end process madi_detect_sync;
 
 madi_count_symbol : process (clk_125_in)
 begin
  if clk_125_in'event and clk_125_in = '1' then
   if madi_sync_detect = '1' then
    madi_sync_count <= madi_sync_count + 1;
   end if;
  end if;
 end process madi_count_symbol;
 
 madi_decode : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in = '1' then
   case madi_symbol is
    when "11110" =>
     madi_nibble <= "0000";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "01001" =>
     madi_nibble <= "0001";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "10100" =>
     madi_nibble <= "0010";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "10101" =>
     madi_nibble <= "0011";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "01010" =>
     madi_nibble <= "0100";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "01011" =>
     madi_nibble <= "0101";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "01110" =>
     madi_nibble <= "0110";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "01111" =>
     madi_nibble <= "0111";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "10010" =>
     madi_nibble <= "1000";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "10011" =>
     madi_nibble <= "1001";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "10110" =>
     madi_nibble <= "1010";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "10111" =>
     madi_nibble <= "1011";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "11010" =>
     madi_nibble <= "1100";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "11011" =>
     madi_nibble <= "1101";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "11100" =>
     madi_nibble <= "1110";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when "11101" =>
     madi_nibble <= "1111";
     madi_nibble_clk <= '1';
     madi_nibble_rst <= '0';
    when others  =>
     madi_nibble <= "0000";
     madi_nibble_clk <= '0';
     madi_nibble_rst <= '1';
   end case;
  end if;
 end process madi_decode;
 
 place_nibble : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in = '1' then
   if madi_nibble_rst = '1' then
    madi_nibble_cnt <= (others => '0');
   end if;
   if madi_channel_rst = '1' then
    madi_channel_rst <= '0';
   end if;
   if madi_nibble_clk = '1' then
    madi_nibble_cnt <= madi_nibble_cnt + 1;
    case madi_nibble_cnt is
     when "000" =>
      madi_nibble_buffer(0) <= madi_nibble;
     when "001" =>
      madi_nibble_buffer(1) <= madi_nibble;
     when "010" =>
      madi_nibble_buffer(2) <= madi_nibble;
     when "011" =>
      madi_nibble_buffer(3) <= madi_nibble;
     when "100" =>
      madi_nibble_buffer(4) <= madi_nibble;
     when "101" =>
      madi_nibble_buffer(5) <= madi_nibble;
     when "110" =>
      madi_nibble_buffer(6) <= madi_nibble;
     when "111" =>
      madi_nibble_buffer(7) <= madi_nibble;
     when others =>
    end case;
    if madi_nibble(3) = '1' and madi_nibble_cnt = "000" then
     madi_channel_rst <= '1';
     madi_channel_cnt <= (others => '0');
    end if;
    if madi_nibble_cnt = 7 then
     madi_data <= madi_nibble_buffer(1) & madi_nibble_buffer(2) & madi_nibble_buffer(3) & madi_nibble_buffer(4) & madi_nibble_buffer(5) & madi_nibble_buffer(6);
     madi_write_buffer <= '1';
    else
     madi_write_buffer <= '0';
    end if;
    if madi_nibble_cnt = 7 then
     madi_channel_cnt <= madi_channel_cnt + 1;
     madi_channel <= madi_channel_cnt;
    end if;
   end if;
  madi_write <= madi_write_buffer;
  end if;
 end process place_nibble;
 
 generate_madi_wordclk : process (clk_125_in)
 begin
  if clk_125_in'event and clk_125_in = '1' then
   madi_wordclk_shift <= madi_wordclk_shift(0) & madi_channel_rst;
   if madi_wordclk_shift = "01" then
    madi_wordclk_count <= (others => '0');
    madi_wordclk_current <= (others => '0');
    if madi_wordclk_current > madi_wordclk_reference(madi_wordclk_reference'left downto madi_wordclk_reference'left-11) then
     madi_wordclk_reference <= madi_wordclk_reference + 1;
    else
     madi_wordclk_reference <= madi_wordclk_reference - 1;
    end if;
   else
    madi_wordclk_count <= madi_wordclk_count + 1;
    madi_wordclk_current <= madi_wordclk_current + 1;
   end if;
   if madi_wordclk_count < madi_wordclk_reference(madi_wordclk_reference'left downto madi_wordclk_reference'left-11) then
    madi_wordclock <= '1';
   else
    madi_wordclock <= '0';
   end if;
  end if;
 end process generate_madi_wordclk;
    
end behavioral; 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adat_transmitter is
 port(
  data_in : in std_logic_vector(23 downto 0);
  address_out : out std_logic_vector(2 downto 0);

  bitclk_in : in std_logic;
  wordclk_in : in std_logic;
  adat_out : out std_logic
 );
end adat_transmitter;

architecture behavioral of adat_transmitter is
 signal bit_counter : std_logic_vector(7 downto 0) := (others => '0');
 signal wordclk_shift : std_logic_vector(1 downto 0):= (others => '0');
 signal adat_buffer : std_logic_vector(29 downto 0) := (others => '0');
 signal adat_address : std_logic_vector(2 downto 0) := (others => '0');
 signal adat_nrzi : std_logic := '0';
 
begin
 
 bit_count : process (bitclk_in)
 begin
  if bitclk_in'event and bitclk_in='1' then
   wordclk_shift <= wordclk_shift(0) & wordclk_in;
   bit_counter <= bit_counter + 1;
  end if;
 end process bit_count;
 
 proc_adat_buffer : process (bitclk_in)
 begin
  if bitclk_in'event and bitclk_in='1' then
   case bit_counter is
    when "00000000" =>
     adat_buffer <= '1' & data_in(0) & data_in(1) & data_in(2) & data_in(3) & '1' & data_in(4) & data_in(5) & data_in(6) & data_in(7) & '1' & data_in(8) & data_in(9) & data_in(10) & data_in(11) & '1' & data_in(12) & data_in(13) & data_in(14) & data_in(15) & '1' & data_in(16) & data_in(17) & data_in(18) & data_in(19) & '1' & data_in(20) & data_in(21) & data_in(22) & data_in(23);
     adat_address <= adat_address +1;
    when "00011110" =>
     adat_buffer <= '1' & data_in(0) & data_in(1) & data_in(2) & data_in(3) & '1' & data_in(4) & data_in(5) & data_in(6) & data_in(7) & '1' & data_in(8) & data_in(9) & data_in(10) & data_in(11) & '1' & data_in(12) & data_in(13) & data_in(14) & data_in(15) & '1' & data_in(16) & data_in(17) & data_in(18) & data_in(19) & '1' & data_in(20) & data_in(21) & data_in(22) & data_in(23);
     adat_address <= adat_address +1;
    when "00111100" =>
     adat_buffer <= '1' & data_in(0) & data_in(1) & data_in(2) & data_in(3) & '1' & data_in(4) & data_in(5) & data_in(6) & data_in(7) & '1' & data_in(8) & data_in(9) & data_in(10) & data_in(11) & '1' & data_in(12) & data_in(13) & data_in(14) & data_in(15) & '1' & data_in(16) & data_in(17) & data_in(18) & data_in(19) & '1' & data_in(20) & data_in(21) & data_in(22) & data_in(23);
     adat_address <= adat_address +1;
    when "01011010" =>
     adat_buffer <= '1' & data_in(0) & data_in(1) & data_in(2) & data_in(3) & '1' & data_in(4) & data_in(5) & data_in(6) & data_in(7) & '1' & data_in(8) & data_in(9) & data_in(10) & data_in(11) & '1' & data_in(12) & data_in(13) & data_in(14) & data_in(15) & '1' & data_in(16) & data_in(17) & data_in(18) & data_in(19) & '1' & data_in(20) & data_in(21) & data_in(22) & data_in(23);
     adat_address <= adat_address +1;
    when "01111000" =>
     adat_buffer <= '1' & data_in(0) & data_in(1) & data_in(2) & data_in(3) & '1' & data_in(4) & data_in(5) & data_in(6) & data_in(7) & '1' & data_in(8) & data_in(9) & data_in(10) & data_in(11) & '1' & data_in(12) & data_in(13) & data_in(14) & data_in(15) & '1' & data_in(16) & data_in(17) & data_in(18) & data_in(19) & '1' & data_in(20) & data_in(21) & data_in(22) & data_in(23);
     adat_address <= adat_address +1;
    when "10010110" =>
     adat_buffer <= '1' & data_in(0) & data_in(1) & data_in(2) & data_in(3) & '1' & data_in(4) & data_in(5) & data_in(6) & data_in(7) & '1' & data_in(8) & data_in(9) & data_in(10) & data_in(11) & '1' & data_in(12) & data_in(13) & data_in(14) & data_in(15) & '1' & data_in(16) & data_in(17) & data_in(18) & data_in(19) & '1' & data_in(20) & data_in(21) & data_in(22) & data_in(23);
     adat_address <= adat_address +1;
    when "10110100" =>
     adat_buffer <= '1' & data_in(0) & data_in(1) & data_in(2) & data_in(3) & '1' & data_in(4) & data_in(5) & data_in(6) & data_in(7) & '1' & data_in(8) & data_in(9) & data_in(10) & data_in(11) & '1' & data_in(12) & data_in(13) & data_in(14) & data_in(15) & '1' & data_in(16) & data_in(17) & data_in(18) & data_in(19) & '1' & data_in(20) & data_in(21) & data_in(22) & data_in(23);
     adat_address <= adat_address +1;
    when "11010010" =>
     adat_buffer <= '1' & data_in(0) & data_in(1) & data_in(2) & data_in(3) & '1' & data_in(4) & data_in(5) & data_in(6) & data_in(7) & '1' & data_in(8) & data_in(9) & data_in(10) & data_in(11) & '1' & data_in(12) & data_in(13) & data_in(14) & data_in(15) & '1' & data_in(16) & data_in(17) & data_in(18) & data_in(19) & '1' & data_in(20) & data_in(21) & data_in(22) & data_in(23);
     adat_address <= (others => '0');
    when "11110000" =>
                      -- Sync sequence          USER    Dummy bits (no tx)
     adat_buffer <= '1' & "0000000000" & '1' & "0000" & "00000000000000";
    when others =>
   adat_buffer <= adat_buffer(adat_buffer'left-1 downto 0) & '0';
   end case;
  end if;
 end process proc_adat_buffer;
 
 proc_adat_nrzi : process (bitclk_in)
 begin
  if bitclk_in'event and bitclk_in='1' then
   if adat_buffer(adat_buffer'left)='0' then
    adat_nrzi <= adat_nrzi;
   else
    adat_nrzi <= not adat_nrzi;
   end if;
  end if;
 end process proc_adat_nrzi;

 address_out <= adat_address;
 adat_out <= adat_nrzi;
   
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity madi_to_adat is
 port(
  madi_clk_in : in std_logic;
  madi_data_valid : in std_logic;
  madi_symbol_in : in std_logic_vector(4 downto 0);
  
  clk_125_in : in std_logic;

  word_clk_out : out std_logic;
  bit_clk_in : in std_logic;
  adat_0_out : out std_logic;
  adat_1_out : out std_logic;
  adat_2_out : out std_logic;
  adat_3_out : out std_logic;
  adat_4_out : out std_logic;
  adat_5_out : out std_logic;
  adat_6_out : out std_logic;
  adat_7_out : out std_logic
 );
end madi_to_adat;

architecture behavioral of madi_to_adat is
 signal madi_channel : std_logic_vector(5 downto 0);
 signal madi_data : std_logic_vector(23 downto 0);
 signal madi_write : std_logic;
 signal word_clk : std_logic;
 
 signal madi_write_0 : std_logic;
 signal madi_write_1 : std_logic;
 signal madi_write_2 : std_logic;
 signal madi_write_3 : std_logic;
 signal madi_write_4 : std_logic;
 signal madi_write_5 : std_logic;
 signal madi_write_6 : std_logic;
 signal madi_write_7 : std_logic; 

 signal adat_addr_0 : std_logic_vector(2 downto 0);
 signal adat_addr_1 : std_logic_vector(2 downto 0);
 signal adat_addr_2 : std_logic_vector(2 downto 0);
 signal adat_addr_3 : std_logic_vector(2 downto 0);
 signal adat_addr_4 : std_logic_vector(2 downto 0);
 signal adat_addr_5 : std_logic_vector(2 downto 0);
 signal adat_addr_6 : std_logic_vector(2 downto 0);
 signal adat_addr_7 : std_logic_vector(2 downto 0);
 
 signal adat_data_0 : std_logic_vector(23 downto 0);
 signal adat_data_1 : std_logic_vector(23 downto 0);
 signal adat_data_2 : std_logic_vector(23 downto 0);
 signal adat_data_3 : std_logic_vector(23 downto 0);
 signal adat_data_4 : std_logic_vector(23 downto 0);
 signal adat_data_5 : std_logic_vector(23 downto 0);
 signal adat_data_6 : std_logic_vector(23 downto 0);
 signal adat_data_7 : std_logic_vector(23 downto 0);

 component madi_receiver is
  port(
   madi_clk_in : in std_logic;
   clk_125_in : in std_logic;
   madi_data_valid : in std_logic;
   madi_symbol_in : in std_logic_vector(4 downto 0);
  
   madi_write : out std_logic;
   madi_wordclock : out std_logic;
   madi_channel : out std_logic_vector(5 downto 0);
   madi_data : out std_logic_vector(23 downto 0)
  );
 end component madi_receiver;

 component adat_transmitter is
  port(
   data_in : in std_logic_vector(23 downto 0);
   address_out : out std_logic_vector(2 downto 0);

   bitclk_in : in std_logic;
   wordclk_in : in std_logic;
   adat_out : out std_logic
  );
 end component adat_transmitter;

 component dp_ram is
  port(
   clock: in std_logic;
   data: in std_logic_vector(23 downto 0);
   rdaddress: in std_logic_vector(2 downto 0);
   wraddress: in std_logic_vector(2 downto 0);
   wren: in std_logic  := '1';
   q: out std_logic_vector(23 downto 0)
  );
 end component dp_ram;

begin

 word_clk_out <= word_clk;

 madi_receive : madi_receiver
 port map(
  madi_clk_in => madi_clk_in,
  clk_125_in => clk_125_in,
  madi_data_valid => madi_data_valid,
  madi_symbol_in => madi_symbol_in,
  madi_write => madi_write,
  madi_wordclock => word_clk,
  madi_channel => madi_channel,
  madi_data => madi_data
 );

-- adat channel 0

 dp_ram_0_write : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in='1' then
   if madi_channel(5 downto 3) = 0 and madi_write = '1' then
    madi_write_0 <= '1';
   else
    madi_write_0 <= '0';
   end if;
  end if;
 end process dp_ram_0_write;

 dp_ram_0 : dp_ram
 port map(
  clock => madi_clk_in,
  data => madi_data,
  rdaddress => adat_addr_0,
  wraddress => madi_channel(2 downto 0),
  wren => madi_write_0,
  q => adat_data_0
 );

 adat_transmitter_0 : adat_transmitter
 port map(
  data_in => adat_data_0,
  address_out => adat_addr_0,
  bitclk_in => bit_clk_in,
  wordclk_in => word_clk,
  adat_out => adat_0_out
 );

-- adat channel 1

 dp_ram_1_write : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in='1' then
   if madi_channel(5 downto 3) = 1 and madi_write = '1' then
    madi_write_1 <= '1';
   else
    madi_write_1 <= '0';
   end if;
  end if;
 end process dp_ram_1_write;

 dp_ram_1 : dp_ram
 port map(
  clock => madi_clk_in,
  data => madi_data,
  rdaddress => adat_addr_1,
  wraddress => madi_channel(2 downto 0),
  wren => madi_write_1,
  q => adat_data_1
 );

 adat_transmitter_1 : adat_transmitter
 port map(
  data_in => adat_data_1,
  address_out => adat_addr_1,
  bitclk_in => bit_clk_in,
  wordclk_in => word_clk,
  adat_out => adat_1_out
 );

-- adat channel 2

 dp_ram_2_write : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in='1' then
   if madi_channel(5 downto 3) = 2 and madi_write = '1' then
    madi_write_2 <= '1';
   else
    madi_write_2 <= '0';
   end if;
  end if;
 end process dp_ram_2_write;

 dp_ram_2 : dp_ram
 port map(
  clock => madi_clk_in,
  data => madi_data,
  rdaddress => adat_addr_2,
  wraddress => madi_channel(2 downto 0),
  wren => madi_write_2,
  q => adat_data_2
 );

 adat_transmitter_2 : adat_transmitter
 port map(
  data_in => adat_data_2,
  address_out => adat_addr_2,
  bitclk_in => bit_clk_in,
  wordclk_in => word_clk,
  adat_out => adat_2_out
 );

-- adat channel 3

 dp_ram_3_write : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in='1' then
   if madi_channel(5 downto 3) = 3 and madi_write = '1' then
    madi_write_3 <= '1';
   else
    madi_write_3 <= '0';
   end if;
  end if;
 end process dp_ram_3_write;

 dp_ram_3 : dp_ram
 port map(
  clock => madi_clk_in,
  data => madi_data,
  rdaddress => adat_addr_3,
  wraddress => madi_channel(2 downto 0),
  wren => madi_write_3,
  q => adat_data_3
 );

 adat_transmitter_3 : adat_transmitter
 port map(
  data_in => adat_data_3,
  address_out => adat_addr_3,
  bitclk_in => bit_clk_in,
  wordclk_in => word_clk,
  adat_out => adat_3_out
 );

-- adat channel 4

 dp_ram_4_write : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in='1' then
   if madi_channel(5 downto 3) = 4 and madi_write = '1' then
    madi_write_4 <= '1';
   else
    madi_write_4 <= '0';
   end if;
  end if;
 end process dp_ram_4_write;

 dp_ram_4 : dp_ram
 port map(
  clock => madi_clk_in,
  data => madi_data,
  rdaddress => adat_addr_4,
  wraddress => madi_channel(2 downto 0),
  wren => madi_write_4,
  q => adat_data_4
 );

 adat_transmitter_4 : adat_transmitter
 port map(
  data_in => adat_data_4,
  address_out => adat_addr_4,
  bitclk_in => bit_clk_in,
  wordclk_in => word_clk,
  adat_out => adat_4_out
 );

-- adat channel 5

 dp_ram_5_write : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in='1' then
   if madi_channel(5 downto 3) = 5 and madi_write = '1' then
    madi_write_5 <= '1';
   else
    madi_write_5 <= '0';
   end if;
  end if;
 end process dp_ram_5_write;

 dp_ram_5 : dp_ram
 port map(
  clock => madi_clk_in,
  data => madi_data,
  rdaddress => adat_addr_5,
  wraddress => madi_channel(2 downto 0),
  wren => madi_write_5,
  q => adat_data_5
 );

 adat_transmitter_5 : adat_transmitter
 port map(
  data_in => adat_data_5,
  address_out => adat_addr_5,
  bitclk_in => bit_clk_in,
  wordclk_in => word_clk,
  adat_out => adat_5_out
 );

-- adat channel 6

 dp_ram_6_write : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in='1' then
   if madi_channel(5 downto 3) = 6 and madi_write = '1' then
    madi_write_6 <= '1';
   else
    madi_write_6 <= '0';
   end if;
  end if;
 end process dp_ram_6_write;

 dp_ram_6 : dp_ram
 port map(
  clock => madi_clk_in,
  data => madi_data,
  rdaddress => adat_addr_6,
  wraddress => madi_channel(2 downto 0),
  wren => madi_write_6,
  q => adat_data_6
 );

 adat_transmitter_6 : adat_transmitter
 port map(
  data_in => adat_data_6,
  address_out => adat_addr_6,
  bitclk_in => bit_clk_in,
  wordclk_in => word_clk,
  adat_out => adat_6_out
 );

-- adat channel 7

 dp_ram_7_write : process (madi_clk_in)
 begin
  if madi_clk_in'event and madi_clk_in='1' then
   if madi_channel(5 downto 3) = 7 and madi_write = '1' then
    madi_write_7 <= '1';
   else
    madi_write_7 <= '0';
   end if;
  end if;
 end process dp_ram_7_write;

 dp_ram_7 : dp_ram
 port map(
  clock => madi_clk_in,
  data => madi_data,
  rdaddress => adat_addr_7,
  wraddress => madi_channel(2 downto 0),
  wren => madi_write_7,
  q => adat_data_7
 );

 adat_transmitter_7 : adat_transmitter
 port map(
  data_in => adat_data_7,
  address_out => adat_addr_7,
  bitclk_in => bit_clk_in,
  wordclk_in => word_clk,
  adat_out => adat_7_out
 );

end behavioral;