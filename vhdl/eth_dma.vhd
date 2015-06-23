---------------------------------------------------------------------
-- TITLE: Ethernet DMA
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 12/27/07
-- FILENAME: eth_dma.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Ethernet DMA (Direct Memory Access) controller.  
--    Reads four bits and writes four bits from/to the Ethernet PHY each 
--    2.5 MHz clock cycle.  Received data is DMAed starting at 0x13ff0000 
--    transmit data is read from 0x13fd0000.
--    To send a packet write bytes/4 to Ethernet send register.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.mlite_pack.all;

entity eth_dma is port(
   clk         : in std_logic;                      --25 MHz
   reset       : in std_logic;
   enable_eth  : in std_logic;                      --enable receive DMA
   select_eth  : in std_logic;
   rec_isr     : out std_logic;                     --data received
   send_isr    : out std_logic;                     --transmit done

   address     : out std_logic_vector(31 downto 2); --to DDR
   byte_we     : out std_logic_vector(3 downto 0);
   data_write  : out std_logic_vector(31 downto 0);
   data_read   : in std_logic_vector(31 downto 0);
   pause_in    : in std_logic;

   mem_address : in std_logic_vector(31 downto 2);  --from CPU
   mem_byte_we : in std_logic_vector(3 downto 0);
   data_w      : in std_logic_vector(31 downto 0);
   pause_out   : out std_logic;

   E_RX_CLK    : in std_logic;                      --2.5 MHz receive
   E_RX_DV     : in std_logic;                      --data valid
   E_RXD       : in std_logic_vector(3 downto 0);   --receive nibble
   E_TX_CLK    : in std_logic;                      --2.5 MHz transmit
   E_TX_EN     : out std_logic;                     --transmit enable
   E_TXD       : out std_logic_vector(3 downto 0)); --transmit nibble
end; --entity eth_dma

architecture logic of eth_dma is
   signal rec_clk    : std_logic_vector(1 downto 0);  --receive
   signal rec_store  : std_logic_vector(31 downto 0); --to DDR
   signal rec_data   : std_logic_vector(27 downto 0);
   signal rec_cnt    : std_logic_vector(2 downto 0);  --nibbles
   signal rec_words  : std_logic_vector(13 downto 0);
   signal rec_dma    : std_logic_vector(1 downto 0);  --active & request
   signal rec_done   : std_logic;

   signal send_clk   : std_logic_vector(1 downto 0);  --transmit
   signal send_read  : std_logic_vector(31 downto 0); --from DDR
   signal send_data  : std_logic_vector(31 downto 0);
   signal send_cnt   : std_logic_vector(2 downto 0);  --nibbles
   signal send_words : std_logic_vector(8 downto 0);
   signal send_level : std_logic_vector(8 downto 0);
   signal send_dma   : std_logic_vector(1 downto 0);  --active & request
   signal send_enable: std_logic;

begin  --architecture

   dma_proc: process(clk, reset, enable_eth, select_eth, 
         data_read, pause_in, mem_address, mem_byte_we, data_w, 
         E_RX_CLK, E_RX_DV, E_RXD, E_TX_CLK,
         rec_clk, rec_store, rec_data, 
         rec_cnt, rec_words, rec_dma, rec_done,
         send_clk, send_read, send_data, send_cnt, send_words, 
         send_level, send_dma, send_enable)
   begin

      if reset = '1' then
         rec_clk <= "00";
         rec_cnt <= "000";
         rec_words <= ZERO(13 downto 0);
         rec_dma <= "00";
         rec_done <= '0';
         send_clk <= "00";
         send_cnt <= "000";
         send_words <= ZERO(8 downto 0);
         send_level <= ZERO(8 downto 0);
         send_dma <= "00";
         send_enable <= '0';
      elsif rising_edge(clk) then

         --Receive nibble on low->high E_RX_CLK.  Send to DDR every 32 bits.
         rec_clk <= rec_clk(0) & E_RX_CLK;
         if rec_clk = "01" and enable_eth = '1' then
            if E_RX_DV = '1' or rec_cnt /= "000" then
               if rec_cnt = "111" then
                  rec_store <= rec_data & E_RXD;
                  rec_dma(0) <= '1';           --request DMA
               end if;
               rec_data <= rec_data(23 downto 0) & E_RXD;
               rec_cnt <= rec_cnt + 1;
            end if;
         end if;

         --Set transmit count or clear receive interrupt
         if select_eth = '1' then
            if mem_byte_we /= "0000" then
               send_cnt <= "000";
               send_words <= ZERO(8 downto 0);
               send_level <= data_w(8 downto 0);
               send_dma(0) <= '1';
            else
               rec_done <= '0';
            end if;
         end if;

         --Transmit nibble on low->high E_TX_CLK.  Get 32 bits from DDR.
         send_clk <= send_clk(0) & E_TX_CLK;
         if send_clk = "01" then
            if send_cnt = "111" then
               if send_words /= send_level then
                  send_data <= send_read;
                  send_dma(0) <= '1';
                  send_enable <= '1';
               else
                  send_enable <= '0';
               end if;
            else
               send_data(31 downto 4) <= send_data(27 downto 0);
            end if;
            send_cnt <= send_cnt + 1;
         end if;

         --Pick which type of DMA operation: bit0 = request; bit1 = active
         if pause_in = '0' then
            if rec_dma(1) = '1' then
               rec_dma <= "00";               --DMA done
               rec_words <= rec_words + 1;
               if E_RX_DV = '0' then
                  rec_done <= '1';
               end if;
            elsif send_dma(1) = '1' then
               send_dma <= "00";
               send_words <= send_words + 1;
               send_read <= data_read;
            elsif rec_dma(0) = '1' then
               rec_dma(1) <= '1';             --start DMA
            elsif send_dma(0) = '1' then
               send_dma(1) <= '1';            --start DMA
            end if;
         end if;

      end if;  --rising_edge(clk)

      E_TXD <= send_data(31 downto 28);
      E_TX_EN <= send_enable;
      rec_isr <= rec_done;
      if send_words = send_level then
         send_isr <= '1';
      else
         send_isr <= '0';
      end if;

      if rec_dma(1) = '1' then
         address <= "0001001111111111" & rec_words;        --0x13ff0000
         byte_we <= "1111";
         data_write <= rec_store;
         pause_out <= '1';                                 --to CPU
      elsif send_dma(1) = '1' then
         address <= "000100111111111000000" & send_words;  --0x13fe0000
         byte_we <= "0000";
         data_write <= data_w;
         pause_out <= '1';
      else
         address <= mem_address;  --Send request from CPU to DDR
         byte_we <= mem_byte_we;
         data_write <= data_w;
         pause_out <= '0';
      end if;

   end process;

end; --architecture logic
