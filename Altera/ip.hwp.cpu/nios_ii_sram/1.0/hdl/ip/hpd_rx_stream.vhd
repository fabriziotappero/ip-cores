-------------------------------------------------------------------------------
-- Title      : HIBI PE DMA - streaming rx channel
-- Project    : 
-------------------------------------------------------------------------------
-- File       : hpd_rx_stream.vhd
-- Author     : Lasse Lehtonen
-- Created    : 2012-01-10
-- Last update: 2012-02-28
-------------------------------------------------------------------------------
-- Copyright (c) 2012
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-01-10  1.0      LL      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity hpd_rx_stream is
  
  generic (
    data_width_g      : integer := 0;
    hibi_addr_width_g : integer := 0;
    addr_width_g      : integer := 0;
    words_width_g     : integer := 0;
    addr_cmp_lo_g     : integer := 0;
    addr_cmp_hi_g     : integer := 0
    );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    -- keep still until a new init
    avalon_addr_in : in std_logic_vector(addr_width_g-1 downto 0);
    hibi_addr_in   : in std_logic_vector(hibi_addr_width_g-1 downto 0);
    irq_words_in   : in std_logic_vector(words_width_g-1 downto 0);

    hibi_data_in      : in std_logic_vector(hibi_addr_width_g-1 downto 0);
    hibi_av_in        : in std_logic;
    hibi_empty_in     : in std_logic;
    init_in           : in std_logic;
    irq_ack_in        : in std_logic;
    avalon_waitreq_in : in std_logic;
    avalon_we_in      : in std_logic;

    avalon_addr_out    : out std_logic_vector(addr_width_g-1 downto 0);
    avalon_we_out      : out std_logic;
    avalon_be_out      : out std_logic_vector(data_width_g/8-1 downto 0);
    addr_match_out     : out std_logic;
    addr_match_cmb_out : out std_logic;
    irq_out            : out std_logic;
    -- new words in buffer
    words_out          : out std_logic_vector(words_width_g-1 downto 0);
    read_ack_in        : in  std_logic
    );

end hpd_rx_stream;

architecture rtl of hpd_rx_stream is

  constant addr_offset_c : integer := data_width_g/8;

  constant words_per_hibi_data_c : integer   := data_width_g/32;
  constant upper_valid_c         : std_logic := '0';
  -- in case of odd data words, is
  -- either upper ('1') or lower ('0') half-word valid?

  constant be_width_c       : integer := data_width_g/8;
  signal   addr_match_r     : std_logic;
  signal   addr_match_cmb_s : std_logic;
  signal   write_addr_r     : std_logic_vector(addr_width_g-1 downto 0);
  signal   enable_r         : std_logic;
  signal   ena_av_empty     : std_logic_vector(2 downto 0);
  signal   read_counter_r   : std_logic_vector(words_width_g-1 downto 0);
  signal   irq_counter_r    : std_logic_vector(words_width_g-1 downto 0);
  signal   cnt_max_r        : std_logic_vector(words_width_g-1 downto 0);
  signal   irq_r            : std_logic;
  signal   we_match_waitreq : std_logic_vector(2 downto 0);
  signal   ena_reading_r    : std_logic;
  signal   words_out_r      : std_logic_vector(words_width_g-1 downto 0);
  signal   hibi_av_in_r     : std_logic;

begin  -- rtl

  we_match_waitreq <= avalon_we_in & addr_match_r & avalon_waitreq_in;
  avalon_we_out    <= addr_match_r and enable_r and ena_reading_r;
  irq_out          <= irq_r;

  addr_match_out     <= addr_match_r and enable_r;
  addr_match_cmb_out <= addr_match_cmb_s;
  avalon_addr_out    <= write_addr_r;

  ena_av_empty <= enable_r & hibi_av_in & hibi_empty_in;

  words_out <= words_out_r;

  addr_match : process (hibi_data_in, hibi_addr_in, addr_match_r, ena_av_empty)
  begin  -- process addr_match

    case ena_av_empty is
      when "000" | "010" | "011" | "001" =>
        addr_match_cmb_s <= '0';
      when "110" =>
        if hibi_data_in(addr_cmp_hi_g downto addr_cmp_lo_g) =
          hibi_addr_in(addr_cmp_hi_g downto addr_cmp_lo_g) then
          addr_match_cmb_s <= '1';
        else
          addr_match_cmb_s <= '0';
        end if;
      when others =>
        addr_match_cmb_s <= addr_match_r;
    end case;
    
  end process addr_match;

  addr_match_reg : process (clk, rst_n)
  begin  -- process addr_matching
    if rst_n = '0' then                 -- asynchronous reset (active low)
      addr_match_r <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      addr_match_r <= addr_match_cmb_s;
    end if;
  end process addr_match_reg;


  ena : process (clk, rst_n)
    variable inter_addr     : std_logic_vector(addr_width_g-1 downto 0);
    variable read_counter_v : std_logic_vector(words_width_g-1 downto 0);
  begin  -- process ena
    if rst_n = '0' then                 -- asynchronous reset (active low)
      enable_r       <= '0';
      irq_counter_r  <= (others => '0');
      read_counter_r <= (others => '0');
      write_addr_r   <= (others => '0');
      cnt_max_r      <= (others => '0');
      irq_r          <= '0';
      ena_reading_r  <= '0';
      words_out_r    <= (others => '0');
      hibi_av_in_r   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      words_out_r <= read_counter_r - irq_counter_r;

      read_counter_v := read_counter_r;

      hibi_av_in_r <= hibi_av_in;

      if init_in = '1' then
        enable_r       <= '1';
        ena_reading_r  <= '1';
        read_counter_r <= irq_words_in;
        irq_counter_r  <= irq_words_in;
        cnt_max_r      <= irq_words_in;
        write_addr_r   <= avalon_addr_in;
      end if;

      if read_ack_in = '1' then
        read_counter_v := read_counter_r - irq_words_in;
        read_counter_r <= read_counter_v;
        if read_counter_v = 0 then
          read_counter_r <= cnt_max_r;
          irq_counter_r  <= cnt_max_r;
          write_addr_r   <= avalon_addr_in;
        end if;
        if enable_r = '0' then          -- 
          read_counter_r <= irq_words_in;
          irq_counter_r  <= irq_words_in;
          cnt_max_r      <= irq_words_in;
        end if;
        ena_reading_r <= '1';
      end if;

      if irq_ack_in = '1' then
        irq_r <= '0';
      else
        irq_r <= irq_r;
      end if;

      if ena_reading_r = '1' then
        
        case we_match_waitreq is
          when "110" =>
            -- we're writing here
            if irq_counter_r <= conv_std_logic_vector(words_per_hibi_data_c,
                                                      words_width_g)
            then
              write_addr_r  <= write_addr_r + addr_offset_c;
              ena_reading_r <= '0';
              irq_r         <= '1';
              irq_counter_r <= irq_counter_r - words_per_hibi_data_c;
            else
              write_addr_r  <= write_addr_r + addr_offset_c;
              irq_counter_r <= irq_counter_r - words_per_hibi_data_c;
            end if;
            
          when others =>
            if irq_counter_r /= read_counter_r
              and (hibi_av_in = '0' or hibi_av_in_r = '1')
            then
              ena_reading_r <= '0';
              irq_r         <= '1';
            end if;
            
        end case;
        
      end if;
      
    end if;
  end process ena;

  byteena : process (irq_counter_r)
  begin  -- process byteena
    if irq_counter_r = conv_std_logic_vector(1, words_width_g)
      and words_per_hibi_data_c = 2
    then
      -- odd number of words wanted, e.g. 64 bit hibi, wanted 5 32-bit
      -- words
      avalon_be_out(be_width_c-1 downto be_width_c/2) <=
        (others => upper_valid_c);
      avalon_be_out(be_width_c/2-1 downto 0) <=
        (others => (not upper_valid_c));
    else
      avalon_be_out <= (others => '1');
    end if;
    
  end process byteena;
  

  
end rtl;
