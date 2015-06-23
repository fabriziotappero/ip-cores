library ieee;
use ieee.std_logic_1164.all;
library lpm;
use lpm.all;

entity mult12x8 is
 port(
  dataa	: in std_logic_vector(11 downto 0);
  datab	: in std_logic_vector(7 downto 0);
  result : out std_logic_vector (11 downto 0)
 );
end mult12x8;

architecture syn of mult12x8 is
 signal sub_wire0 : std_logic_vector(11 downto 0);
 component lpm_mult
  generic(
   lpm_hint	: string;
   lpm_representation : string;
   lpm_type	: string;
   lpm_widtha : natural;
   lpm_widthb : natural;
   lpm_widthp : natural;
   lpm_widths : natural
  );
  port(
   dataa : in std_logic_vector (11 downto 0);
   datab : in std_logic_vector (7 downto 0);
   result : out std_logic_vector (11 downto 0)
  );
 end component;
begin
 result <= sub_wire0(11 downto 0);
 lpm_mult_component : lpm_mult
 generic map (
  lpm_hint => "MAXIMIZE_SPEED=5",
  lpm_representation => "UNSIGNED",
  lpm_type => "LPM_MULT",
  lpm_widtha => 12,
  lpm_widthb => 8,
  lpm_widthp => 12,
  lpm_widths => 1
 )
 port map (
  dataa => dataa,
  datab => datab,
  result => sub_wire0
 );
end syn;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ADAT_receiver is
 port(
  m_clk : in std_logic;
  adat_in : in std_logic;
  adat_user : out std_logic_vector(3 downto 0); -- adat user bits
  adat_wordclock : out std_logic; -- adat wordclock out (approx 50% symmetry)
  
  bus_enable: in std_logic;
  bus_address: in std_logic_vector(2 downto 0);
  bus_data : out std_logic_vector(23 downto 0)
 );
end ADAT_receiver;

architecture behavioral of ADAT_receiver is
 signal adat_input_shift : std_logic_vector(1 downto 0);

 signal adat_edge_detect : std_logic;
 signal adat_edge_shift : std_logic_vector(1 downto 0);
 signal adat_edge_cur_time : std_logic_vector(9 downto 0) := (others=>'0');
 signal adat_edge_max_time : std_logic_vector(9 downto 0) := (others=>'0');
 signal wait_increase : std_logic_vector(15 downto 0);

 signal adat_inc_word_time : std_logic_vector(11 downto 0) := (others=>'0');
 signal adat_cur_word_time : std_logic_vector(11 downto 0) := (others=>'0');
 signal adat_sync_mask_time : std_logic_vector(8 downto 0) := (others=>'0');
 signal adat_sync_mask : std_logic := '0';
 signal adat_sync_mask_shift : std_logic_vector(1 downto 0) := (others=>'0');
 signal adat_bit_counter : std_logic_vector(7 downto 0) := (others=>'0');
 signal adat_bit_sample : std_logic_vector(11 downto 0) := (others=>'0');
 signal adat_bit_clk : std_logic;
 signal adat_data : std_logic_vector(1 downto 0);

 signal adat_data_shift : std_logic_vector(255 downto 0) := (others=>'1');

 signal audio_buffer_0 : std_logic_vector(23 downto 0);
 signal audio_buffer_1 : std_logic_vector(23 downto 0);
 signal audio_buffer_2 : std_logic_vector(23 downto 0);
 signal audio_buffer_3 : std_logic_vector(23 downto 0);
 signal audio_buffer_4 : std_logic_vector(23 downto 0);
 signal audio_buffer_5 : std_logic_vector(23 downto 0);
 signal audio_buffer_6 : std_logic_vector(23 downto 0);
 signal audio_buffer_7 : std_logic_vector(23 downto 0);

 component mult12x8
  port(
   dataa:in std_logic_vector(11 downto 0);
   datab:in std_logic_vector(7 downto 0);
   result:out std_logic_vector(11 downto 0)
  );
 end component;
begin

 shift_adat_input : process (m_clk)
 begin
  if m_clk'event and m_clk='1' then
   adat_input_shift <= adat_input_shift(0) & adat_in;
  end if;
 end process shift_adat_input;

 detect_adat_sync : process (m_clk)
 begin
  if m_clk'event and m_clk='1' then
   if (adat_input_shift="01") or (adat_input_shift="10") then
    adat_edge_detect <= '1';
    adat_edge_cur_time <= (others => '0');
   else
    adat_edge_cur_time <= adat_edge_cur_time + 1;
    adat_edge_detect <= '0';
    if adat_edge_cur_time > adat_edge_max_time then
     adat_edge_max_time <= adat_edge_cur_time;
     wait_increase <= (others => '0');
    else
     wait_increase <= wait_increase + 1;
     if wait_increase = 2**(wait_increase'length - 1) then
      adat_edge_max_time <= adat_edge_max_time - 1;
     end if;
    end if;
   end if;
  end if;
 end process detect_adat_sync;

 multiplier : mult12x8
 port map(
  dataa => adat_cur_word_time,
  datab => adat_bit_counter,
  result => adat_bit_sample
 );

 shift_adat_edge : process (m_clk)
 begin
  if m_clk'event and m_clk='1' then
   adat_edge_shift <= adat_edge_shift(0) & adat_edge_detect;
  end if;
 end process shift_adat_edge;

 mask_adat_edge : process (m_clk)
 begin
  if m_clk'event and m_clk='1' then
   adat_sync_mask_time <= adat_edge_max_time(adat_edge_max_time'left downto 1) + adat_edge_max_time(adat_edge_max_time'left downto 2);
   if adat_edge_cur_time <= adat_sync_mask_time then
    adat_sync_mask <= '1';
   else
    adat_sync_mask <= '0';
   end if;
  end if;
 end process mask_adat_edge;
 
  shift_adat_mask : process (m_clk)
 begin
  if m_clk'event and m_clk='1' then
   adat_sync_mask_shift <= adat_sync_mask_shift(0) & adat_sync_mask;
  end if;
 end process shift_adat_mask;

 detect_adat_bits : process (m_clk)
 begin
  if m_clk'event and m_clk='1' then
   adat_inc_word_time <= adat_inc_word_time + 1;
   if (adat_edge_detect='1') and (adat_sync_mask='0') then
    adat_cur_word_time <= adat_inc_word_time;
    adat_bit_counter <= (others=>'0'); -- set to bit 0 for first sample point
   end if;
   if adat_sync_mask_shift="01" then
    adat_inc_word_time <= (others => '0');
   end if;
   if adat_inc_word_time = adat_bit_sample then
    adat_bit_clk <= '1';
    adat_data <= adat_data(0) & adat_in;
    adat_bit_counter <= adat_bit_counter + 1;
   else
    adat_bit_clk <= '0';
   end if;
  end if;
 end process detect_adat_bits;

 shift_adat_data : process (adat_bit_clk)
 begin
  if adat_bit_clk'event and adat_bit_clk='1' then
   if (adat_data = "00") or (adat_data = "11") then
    adat_data_shift<=adat_data_shift(adat_data_shift'left-1 downto 0) & '0';
   else 
    adat_data_shift<=adat_data_shift(adat_data_shift'left-1 downto 0) & '1';
   end if;
  end if;
 end process shift_adat_data;
 
 generate_wordclock : process (adat_bit_clk)
 begin
  if adat_bit_clk'event and adat_bit_clk='1' then
   if adat_bit_counter <= 127 then
    adat_wordclock <= '0';
   else
    adat_wordclock <= '1';
   end if;
  end if;
 end process generate_wordclock;

 align_adat_data : process (adat_bit_clk)
 begin
  if adat_bit_clk'event and adat_bit_clk='1' then
   if adat_data_shift(adat_data_shift'left downto adat_data_shift'left-9) = "0000000000" then
    adat_user<=adat_data_shift(adat_data_shift'left-11 downto adat_data_shift'left-14);
    audio_buffer_0<=adat_data_shift(adat_data_shift'left-16 downto adat_data_shift'left-19)&adat_data_shift(adat_data_shift'left-21 downto adat_data_shift'left-24)&adat_data_shift(adat_data_shift'left-26 downto adat_data_shift'left-29)&adat_data_shift(adat_data_shift'left-31 downto adat_data_shift'left-34)&adat_data_shift(adat_data_shift'left-36 downto adat_data_shift'left-39)&adat_data_shift(adat_data_shift'left-41 downto adat_data_shift'left-44);
    audio_buffer_1<=adat_data_shift(adat_data_shift'left-46 downto adat_data_shift'left-49)&adat_data_shift(adat_data_shift'left-51 downto adat_data_shift'left-54)&adat_data_shift(adat_data_shift'left-56 downto adat_data_shift'left-59)&adat_data_shift(adat_data_shift'left-61 downto adat_data_shift'left-64)&adat_data_shift(adat_data_shift'left-66 downto adat_data_shift'left-69)&adat_data_shift(adat_data_shift'left-71 downto adat_data_shift'left-74);
    audio_buffer_2<=adat_data_shift(adat_data_shift'left-76 downto adat_data_shift'left-79)&adat_data_shift(adat_data_shift'left-81 downto adat_data_shift'left-84)&adat_data_shift(adat_data_shift'left-86 downto adat_data_shift'left-89)&adat_data_shift(adat_data_shift'left-91 downto adat_data_shift'left-94)&adat_data_shift(adat_data_shift'left-96 downto adat_data_shift'left-99)&adat_data_shift(adat_data_shift'left-101 downto adat_data_shift'left-104);
    audio_buffer_3<=adat_data_shift(adat_data_shift'left-106 downto adat_data_shift'left-109)&adat_data_shift(adat_data_shift'left-111 downto adat_data_shift'left-114)&adat_data_shift(adat_data_shift'left-116 downto adat_data_shift'left-119)&adat_data_shift(adat_data_shift'left-121 downto adat_data_shift'left-124)&adat_data_shift(adat_data_shift'left-126 downto adat_data_shift'left-129)&adat_data_shift(adat_data_shift'left-131 downto adat_data_shift'left-134);
    audio_buffer_4<=adat_data_shift(adat_data_shift'left-136 downto adat_data_shift'left-139)&adat_data_shift(adat_data_shift'left-141 downto adat_data_shift'left-144)&adat_data_shift(adat_data_shift'left-146 downto adat_data_shift'left-149)&adat_data_shift(adat_data_shift'left-151 downto adat_data_shift'left-154)&adat_data_shift(adat_data_shift'left-156 downto adat_data_shift'left-159)&adat_data_shift(adat_data_shift'left-161 downto adat_data_shift'left-164);
    audio_buffer_5<=adat_data_shift(adat_data_shift'left-166 downto adat_data_shift'left-169)&adat_data_shift(adat_data_shift'left-171 downto adat_data_shift'left-174)&adat_data_shift(adat_data_shift'left-176 downto adat_data_shift'left-179)&adat_data_shift(adat_data_shift'left-181 downto adat_data_shift'left-184)&adat_data_shift(adat_data_shift'left-186 downto adat_data_shift'left-189)&adat_data_shift(adat_data_shift'left-191 downto adat_data_shift'left-194);
    audio_buffer_6<=adat_data_shift(adat_data_shift'left-196 downto adat_data_shift'left-199)&adat_data_shift(adat_data_shift'left-201 downto adat_data_shift'left-204)&adat_data_shift(adat_data_shift'left-206 downto adat_data_shift'left-209)&adat_data_shift(adat_data_shift'left-211 downto adat_data_shift'left-214)&adat_data_shift(adat_data_shift'left-216 downto adat_data_shift'left-219)&adat_data_shift(adat_data_shift'left-221 downto adat_data_shift'left-224);
    audio_buffer_7<=adat_data_shift(adat_data_shift'left-226 downto adat_data_shift'left-229)&adat_data_shift(adat_data_shift'left-231 downto adat_data_shift'left-234)&adat_data_shift(adat_data_shift'left-236 downto adat_data_shift'left-239)&adat_data_shift(adat_data_shift'left-241 downto adat_data_shift'left-244)&adat_data_shift(adat_data_shift'left-246 downto adat_data_shift'left-249)&adat_data_shift(adat_data_shift'left-251 downto adat_data_shift'left-254);
   end if;
  end if;
 end process align_adat_data;

 bus_controller : process (bus_enable)
 begin
  if bus_enable='0' then
   if bus_address="000" then
    bus_data<=audio_buffer_0;
   end if;
   if bus_address="001" then
    bus_data<=audio_buffer_1;
   end if;
   if bus_address="010" then
    bus_data<=audio_buffer_2;
   end if;
   if bus_address="011" then
    bus_data<=audio_buffer_3;
   end if;
   if bus_address="100" then
    bus_data<=audio_buffer_4;
   end if;
   if bus_address="101" then
    bus_data<=audio_buffer_5;
   end if;
   if bus_address="110" then
    bus_data<=audio_buffer_6;
   end if;
   if bus_address="111" then
    bus_data<=audio_buffer_7;
   end if;
  else
   bus_data<="ZZZZZZZZZZZZZZZZZZZZZZZZ";
  end if;
 end process bus_controller;

end behavioral;