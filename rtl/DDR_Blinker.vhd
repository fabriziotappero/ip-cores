----------------------------------------------------------------------------------
-- Company:  ZITI
-- Engineer:  wgao
-- 
-- Create Date:    16:38:03 06 Oct 2008 
-- Design Name: 
-- Module Name:    DDR_Blink - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  08.10.2008
-- 
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.abb64Package.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DDR_Blink is
    Port ( 
           DDR_blinker              : OUT   std_logic;

           DBG_dma_start            : IN    std_logic;
           DBG_bram_wea             : IN    std_logic_vector(7 downto 0);
           DBG_bram_addra           : IN    std_logic_vector(C_PRAM_AWIDTH-1 downto 0);

           DDR_Write                : IN    std_logic;
           DDR_Read                 : IN    std_logic;
           DDR_Both                 : IN    std_logic;

           ddr_Clock                : IN    std_logic;
           DDr_Rst_n                : IN    std_logic
          );
end entity DDR_Blink;


architecture Behavioral of DDR_Blink is


  -- Blinking -_-_-_-_
  Constant  C_BLINKER_MSB       : integer      :=   15;  -- 4;  -- 15;
  Constant  CBIT_SLOW_BLINKER   : integer      :=   11;  -- 2;  -- 11;

  signal  DDR_dma_write_wrong_lo   :  std_logic;
  signal  DDR_dma_write_wrong_hi   :  std_logic;
  signal  DDR_dma_write_init_lo    :  std_logic;
  signal  DDR_dma_write_init_hi    :  std_logic;
  signal  dma_bram_wr_address_lo   :  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
  signal  dma_bram_wr_address_hi   :  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);

  signal  DDR_blinker_i         :  std_logic;
  signal  Fast_blinker          :  std_logic_vector(C_BLINKER_MSB downto 0);
  signal  Fast_blinker_MSB_r1   :  std_logic;
  signal  Blink_Pulse           :  std_logic;
  signal  Slow_blinker          :  std_logic_vector(CBIT_SLOW_BLINKER downto 0);

  signal  DDR_write_extension    :  std_logic;
  signal  DDR_write_extension_Cnt:  std_logic_vector(1 downto 0);
  signal  DDR_read_extension     :  std_logic;
  signal  DDR_read_extension_Cnt :  std_logic_vector(1 downto 0);


begin

--   DDR_blinker    <=  DDR_blinker_i;
   DDR_blinker    <=  DDR_dma_write_wrong_lo or DDR_dma_write_wrong_hi;

   -- 
   Syn_DDR_Fast_blinker:
   process ( ddr_Clock, DDr_Rst_n)
   begin
      if DDr_Rst_n = '0' then
         Fast_blinker        <= (OTHERS=>'0');
         Fast_blinker_MSB_r1 <= '0';
         Blink_Pulse         <= '0';

         Slow_blinker        <= (OTHERS=>'0');

      elsif ddr_Clock'event and ddr_Clock = '1' then
         Fast_blinker        <= Fast_blinker + '1';
         Fast_blinker_MSB_r1 <= Fast_blinker(C_BLINKER_MSB);
         Blink_Pulse         <= Fast_blinker(C_BLINKER_MSB) and not Fast_blinker_MSB_r1;

         Slow_blinker        <= Slow_blinker + Blink_Pulse;

      end if;
   end process;


   -- 
   Syn_DDR_Write_Extenstion:
   process ( ddr_Clock, DDr_Rst_n)
   begin
      if DDr_Rst_n = '0' then
         DDR_write_extension_Cnt <= (OTHERS=>'0');
         DDR_write_extension     <= '0';

      elsif ddr_Clock'event and ddr_Clock = '1' then

         case DDR_write_extension_Cnt is

           when "00"   =>
             if DDR_Write='1' then
                DDR_write_extension_Cnt <= "01";
                DDR_write_extension     <= '1';
             else
                DDR_write_extension_Cnt <= DDR_write_extension_Cnt;
                DDR_write_extension     <= DDR_write_extension;
             end if;

           when "01"   =>
             if Slow_blinker(CBIT_SLOW_BLINKER)='1' then
                DDR_write_extension_Cnt <= "11";
                DDR_write_extension     <= '1';
             else
                DDR_write_extension_Cnt <= DDR_write_extension_Cnt;
                DDR_write_extension     <= DDR_write_extension;
             end if;

           when "11"   =>
             if Slow_blinker(CBIT_SLOW_BLINKER)='0' then
                DDR_write_extension_Cnt <= "10";
                DDR_write_extension     <= '1';
             else
                DDR_write_extension_Cnt <= DDR_write_extension_Cnt;
                DDR_write_extension     <= DDR_write_extension;
             end if;

           when Others          =>
             if Slow_blinker(CBIT_SLOW_BLINKER)='1' then
                DDR_write_extension_Cnt <= "00";
                DDR_write_extension     <= '0';
             else
                DDR_write_extension_Cnt <= DDR_write_extension_Cnt;
                DDR_write_extension     <= DDR_write_extension;
             end if;

         end case;

      end if;
   end process;


   -- 
   Syn_DDR_Read_Extenstion:
   process ( ddr_Clock, DDr_Rst_n)
   begin
      if DDr_Rst_n = '0' then
         DDR_read_extension_Cnt <= (OTHERS=>'0');
         DDR_read_extension     <= '1';

      elsif ddr_Clock'event and ddr_Clock = '1' then

         case DDR_read_extension_Cnt is

           when "00"   =>
             if DDR_Read='1' then
                DDR_read_extension_Cnt <= "01";
                DDR_read_extension     <= '0';
             else
                DDR_read_extension_Cnt <= DDR_read_extension_Cnt;
                DDR_read_extension     <= DDR_read_extension;
             end if;

           when "01"   =>
             if Slow_blinker(CBIT_SLOW_BLINKER)='1' then
                DDR_read_extension_Cnt <= "11";
                DDR_read_extension     <= '0';
             else
                DDR_read_extension_Cnt <= DDR_read_extension_Cnt;
                DDR_read_extension     <= DDR_read_extension;
             end if;

           when "11"   =>
             if Slow_blinker(CBIT_SLOW_BLINKER)='0' then
                DDR_read_extension_Cnt <= "10";
                DDR_read_extension     <= '0';
             else
                DDR_read_extension_Cnt <= DDR_read_extension_Cnt;
                DDR_read_extension     <= DDR_read_extension;
             end if;

           when Others          =>
             if Slow_blinker(CBIT_SLOW_BLINKER)='1' then
                DDR_read_extension_Cnt <= "00";
                DDR_read_extension     <= '1';
             else
                DDR_read_extension_Cnt <= DDR_read_extension_Cnt;
                DDR_read_extension     <= DDR_read_extension;
             end if;

         end case;

      end if;
   end process;


   -- 
   Syn_DDR_Working_blinker:
   process ( ddr_Clock, DDr_Rst_n)
   begin
      if DDr_Rst_n = '0' then
         DDR_Blinker_i      <= '0';
      elsif ddr_Clock'event and ddr_Clock = '1' then
         DDR_Blinker_i      <= (Slow_blinker(CBIT_SLOW_BLINKER-2) or DDR_write_extension) and DDR_read_extension;
      end if;
   end process;


   -- !!! DBG !!!
   Syn_DDR_DBG_blinker:
   process ( ddr_Clock, DBG_dma_start)
   begin
      if DBG_dma_start = '1' then
         DDR_dma_write_init_lo  <= '1';
         DDR_dma_write_init_hi  <= '1';
         DDR_dma_write_wrong_lo <= '0';
         DDR_dma_write_wrong_hi <= '0';
         dma_bram_wr_address_lo <= (others=>'0');
         dma_bram_wr_address_hi <= (others=>'0');

      elsif ddr_Clock'event and ddr_Clock = '1' then
         if DBG_bram_wea(0)='1' then
            DDR_dma_write_init_lo  <= '0';
         else
            DDR_dma_write_init_lo  <= DDR_dma_write_init_lo;
         end if;

         if DDR_dma_write_init_lo='1' then
            DDR_dma_write_wrong_lo <= '0';
            if DBG_bram_wea(0)='1' then
               dma_bram_wr_address_lo <= DBG_bram_addra + '1';
            else
               dma_bram_wr_address_lo <= dma_bram_wr_address_lo;
            end if;
         else
           if DBG_bram_wea(0)='1' then
               dma_bram_wr_address_lo <= dma_bram_wr_address_lo + '1';
               if DBG_bram_addra<dma_bram_wr_address_lo then
                  DDR_dma_write_wrong_lo <= '1';
               else
                  DDR_dma_write_wrong_lo <= '0';
               end if;
           else
               dma_bram_wr_address_lo <= dma_bram_wr_address_lo;
           end if;
         end if;

         --------------------------------------------------------------------------------

         if DBG_bram_wea(4)='1' then
            DDR_dma_write_init_hi  <= '0';
         else
            DDR_dma_write_init_hi  <= DDR_dma_write_init_hi;
         end if;

         if DDR_dma_write_init_hi='1' then
            DDR_dma_write_wrong_hi <= '0';
            if DBG_bram_wea(4)='1' then
               dma_bram_wr_address_hi <= DBG_bram_addra + '1';
            else
               dma_bram_wr_address_hi <= dma_bram_wr_address_hi;
            end if;
         else
           if DBG_bram_wea(4)='1' then
               dma_bram_wr_address_hi <= dma_bram_wr_address_hi + '1';
               if DBG_bram_addra<dma_bram_wr_address_hi then
                  DDR_dma_write_wrong_hi <= '1';
               else
                  DDR_dma_write_wrong_hi <= '0';
               end if;
           else
               dma_bram_wr_address_hi <= dma_bram_wr_address_hi;
           end if;
         end if;

      end if;
   end process;

end architecture Behavioral;
