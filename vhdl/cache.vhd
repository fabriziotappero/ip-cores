---------------------------------------------------------------------
-- TITLE: Cache Controller
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 12/22/08
-- FILENAME: cache.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Control 4KB unified cache that uses the upper 4KB of the 8KB
--    internal RAM.  Only lowest 2MB of DDR is cached.
--    Only include file for Xilinx FPGAs.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;
use work.mlite_pack.all;

entity cache is
   generic(memory_type : string := "DEFAULT");
   port(clk            : in std_logic;
        reset          : in std_logic;
        address_next   : in std_logic_vector(31 downto 2);
        byte_we_next   : in std_logic_vector(3 downto 0);
        cpu_address    : in std_logic_vector(31 downto 2);
        mem_busy       : in std_logic;

        cache_access   : out std_logic;   --access 4KB cache
        cache_checking : out std_logic;   --checking if cache hit
        cache_miss     : out std_logic);  --cache miss
end; --cache

architecture logic of cache is
   subtype state_type is std_logic_vector(1 downto 0);
   constant STATE_IDLE     : state_type := "00";
   constant STATE_CHECKING : state_type := "01";
   constant STATE_MISSED   : state_type := "10";
   constant STATE_WAITING  : state_type := "11";

   signal state_reg        : state_type;
   signal state            : state_type;
   signal state_next       : state_type;

   signal cache_address    : std_logic_vector(10 downto 0);
   signal cache_tag_in     : std_logic_vector(8 downto 0);
   signal cache_tag_reg    : std_logic_vector(8 downto 0);
   signal cache_tag_out    : std_logic_vector(8 downto 0);
   signal cache_we         : std_logic;
begin

   cache_proc: process(clk, reset, mem_busy, cache_address, 
      state_reg, state, state_next, 
      address_next, byte_we_next, cache_tag_in, --Stage1
      cache_tag_reg, cache_tag_out,             --Stage2
      cpu_address) --Stage3
   begin

      case state_reg is
      when STATE_IDLE =>            --cache idle
         cache_checking <= '0';
         cache_miss <= '0'; 
         state <= STATE_IDLE;
      when STATE_CHECKING =>        --current read in cached range, check if match
         cache_checking <= '1';
         if cache_tag_out /= cache_tag_reg or cache_tag_out = ONES(8 downto 0) then
            cache_miss <= '1';
            state <= STATE_MISSED;
         else
            cache_miss <= '0';
            state <= STATE_IDLE;
         end if;
      when STATE_MISSED =>          --current read cache miss
         cache_checking <= '0';
         cache_miss <= '1';
         if mem_busy = '1' then
            state <= STATE_MISSED;
         else
            state <= STATE_WAITING;
         end if;
      when STATE_WAITING =>         --waiting for memory access to complete
         cache_checking <= '0';
         cache_miss <= '0';
         if mem_busy = '1' then
            state <= STATE_WAITING;
         else
            state <= STATE_IDLE;
         end if;
      when others =>
         cache_checking <= '0';
         cache_miss <= '0';
         state <= STATE_IDLE;
      end case; --state

      if state = STATE_IDLE then    --check if next access in cached range
         cache_address <= '0' & address_next(11 downto 2);
         if address_next(30 downto 21) = "0010000000" then  --first 2MB of DDR
            cache_access <= '1';
            if byte_we_next = "0000" then     --read cycle
               cache_we <= '0';
               state_next <= STATE_CHECKING;  --need to check if match
            else
               cache_we <= '1';               --update cache tag
               state_next <= STATE_WAITING;
            end if;
         else
            cache_access <= '0';
            cache_we <= '0';
            state_next <= STATE_IDLE;
         end if;
      else
         cache_address <= '0' & cpu_address(11 downto 2);
         cache_access <= '0';
         if state = STATE_MISSED then
            cache_we <= '1';                  --update cache tag
         else
            cache_we <= '0';
         end if;
         state_next <= state;
      end if;

      if byte_we_next = "0000" or byte_we_next = "1111" then  --read or 32-bit write
         cache_tag_in <= address_next(20 downto 12);
      else
         cache_tag_in <= ONES(8 downto 0);  --invalid tag
      end if;

      if reset = '1' then
         state_reg <= STATE_IDLE;
         cache_tag_reg <= ZERO(8 downto 0);
      elsif rising_edge(clk) then
         state_reg <= state_next;
         if state = STATE_IDLE and state_reg /= STATE_MISSED then
            cache_tag_reg <= cache_tag_in;
         end if;
      end if;

   end process;

   cache_xilinx: if memory_type = "XILINX_16X" generate
   begin
      cache_tag: RAMB16_S9  --Xilinx specific
      port map (
         DO   => cache_tag_out(7 downto 0),
         DOP  => cache_tag_out(8 downto 8), 
         ADDR => cache_address,             --registered
         CLK  => clk, 
         DI   => cache_tag_in(7 downto 0),  --registered
         DIP  => cache_tag_in(8 downto 8),
         EN   => '1',
         SSR  => ZERO(0),
         WE   => cache_we);
   end generate; --cache_xilinx
      
   cache_generic: if memory_type /= "XILINX_16X" generate
   begin
      cache_tag: process(clk, cache_address, cache_tag_in, cache_we)
         constant ADDRESS_WIDTH : natural := 10;
         type storage_array is
            array(natural range 0 to 2 ** ADDRESS_WIDTH - 1) of 
            std_logic_vector(8 downto 0);
         variable storage : storage_array;
         variable index   : natural := 0;
      begin
         if rising_edge(clk) then
            index := conv_integer(cache_address(ADDRESS_WIDTH-1 downto 0));
            if cache_we = '1' then
               storage(index) := cache_tag_in;
            end if;
            cache_tag_out <= storage(index);
         end if;
      end process; --cache_tag
   end generate; --cache_generic

end; --logic

