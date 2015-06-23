------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.


library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity lpc_iow is
  port (
     --system signals
    lreset_n   : in  std_logic;
    lclk       : in  std_logic;
    lena_mem_r : in  std_logic;  --enable lpc regular memory read cycles also (default is only LPC firmware read)
	lena_reads : in  std_logic;  --enable read capabilities
	--LPC bus from host
    lad_i      : in  std_logic_vector(3 downto 0);
    lad_o      : out std_logic_vector(3 downto 0);
    lad_oe     : out std_logic;
    lframe_n   : in  std_logic;
	--memory interface
    lpc_addr   : out std_logic_vector(23 downto 0); --shared address
    lpc_wr     : out std_logic;         --shared write not read
    lpc_data_i : in  std_logic_vector(7 downto 0);
    lpc_data_o : out std_logic_vector(7 downto 0);  
    lpc_val    : out std_logic;
    lpc_ack    : in  std_logic
    );
end lpc_iow;

architecture rtl of lpc_iow is
type state is (RESETs,STARTs,ADDRs,TARs,SYNCs,DATAs,LOCAL_TARs);  -- simple LCP states
type cycle is (LPC_IO_W,LPC_MEM_R,LPC_FW_R);  -- simple LPC bus cycle types

signal CS : state;
signal r_lad   : std_logic_vector(3 downto 0);
signal r_addr  : std_logic_vector(31 downto 0);  --should consider saving max
                                                --adress 23 bits on flash
signal r_data  : std_logic_vector(7 downto 0);
signal r_cnt   : std_logic_vector(2 downto 0);
signal cycle_type : cycle;   
--signal r_fw_msize   : std_logic_vector(3 downto 0);


signal data_valid : std_logic;

signal lad_rising_o : std_logic_vector(3 downto 0);
signal lad_rising_oe : std_logic;

constant START_FW_READ : std_logic_vector(3 downto 0):="1101";
constant START_LPC     : std_logic_vector(3 downto 0):="0000";
constant IDSEL_FW_BOOT : std_logic_vector(3 downto 0):="0000";  --0000 is boot device on ThinCan
constant MSIZE_FW_1B   : std_logic_vector(3 downto 0):="0000";  --0000 is 1 byte read
constant SYNC_OK       : std_logic_vector(3 downto 0):="0000";  --sync done
constant SYNC_WAIT     : std_logic_vector(3 downto 0):="0101";  --sync wait device holds the bus
constant SYNC_LWAIT    : std_logic_vector(3 downto 0):="0110";  --sync long wait expected device holds the bus
constant TAR_OK		   : std_logic_vector(3 downto 0):="1111";  --accepted tar constant for master and slave




begin  -- rtl

lad_o<= lad_rising_o;
lad_oe <= lad_rising_oe;


  
--Pass the whole LPC address to the system
lpc_addr <= r_addr(23 downto 0);
lpc_data_o<= r_data;



  
-- purpose: LPC IO write/LPC MEM read/LPC FW read  handler
-- type   : sequential
-- inputs : lclk, lreset_n
-- outputs: 
LPC: process (lclk, lreset_n)
begin  -- process LPC
  if lreset_n = '0' then                -- asynchronous reset (active low)
    CS<= RESETs;
    lad_rising_oe<='0';
    data_valid <='1';
    lad_rising_o<="0000";
    lpc_val <='0';
	lpc_wr <='0';
	r_lad <= (others=>'0');
	cycle_type <= LPC_IO_W; --initial value 
	r_addr <= (others=>'0');
	r_cnt <= (others=>'0');
   elsif lclk'event and lclk = '1' then  -- rising clock edge
    case CS is
      when RESETs => ----------------------------------------------------------
        lpc_wr <='0';             
        lpc_val <='0';
        if lframe_n='0' then
          CS <= STARTs;
          r_lad <= lad_i;
        else
          CS <= RESETs;
        end if;
      when STARTs => ----------------------------------------------------------
        if lframe_n = '0' then
        	r_lad <= lad_i; -- latch lad state for next cycle
        	CS <= STARTs;
        elsif r_lad = START_LPC then
              --must identify CYCTYPE
	          if lad_i(3 downto 1)="001" then --IO WRITE WILL HAPPEN
	            --next 4 states must be address states
	            CS<=ADDRs;
				cycle_type <= LPC_IO_W;
	            r_cnt <= "000";
	          elsif lad_i(3 downto 1)="010"  and lena_mem_r='1' and lena_reads='1' then --MEM READ ALLOWED
	            CS<=ADDRs;
				cycle_type <= LPC_MEM_R;
	            r_cnt <= "000"; 
	          else
	            CS<= RESETs;
	          end if;
        elsif r_lad = START_FW_READ then    --FW READ is always allowed
			if lad_i = IDSEL_FW_BOOT and lena_reads='1'  then
	            CS<=ADDRs;
				cycle_type <= LPC_FW_R;
	            r_cnt <= "000"; 				
			else
				CS<= RESETs;
		    end if;
        end if;
      when ADDRs => -----------------------------------------------------------
       case cycle_type is
         when LPC_IO_W =>                   --IO write cycle
          if r_cnt ="011" then
             if r_addr(11 downto 0)=x"008" and lad_i(3 downto 2)="00" then
              r_addr<= r_addr(27 downto 0)&lad_i;
              r_cnt <= "000";
              CS<=DATAs;
            elsif r_addr(11 downto 0)=x"008" and lad_i(3 downto 0)=x"8" then  --for debug switch
              r_addr<= r_addr(27 downto 0)&lad_i;
              r_cnt <= "000";
              CS<=DATAs;
            else
              --not for this device
               CS<=RESETs;
            end if;
          else
            r_addr<= r_addr(27 downto 0)&lad_i;
            r_cnt<=r_cnt + 1;
            CS<=ADDRs;
          end if;
        when LPC_MEM_R =>                    --Memory read cycle
          if r_cnt ="111" then
              r_addr<= r_addr(27 downto 0)&lad_i;
              r_cnt <= "000";
              lpc_wr <='0';             --memory read mus accure
              lpc_val <='1';
              data_valid <='0';
              CS<=TARs;
          else
            r_addr<= r_addr(27 downto 0)&lad_i;
            r_cnt<=r_cnt + 1;
            CS<=ADDRs;
          end if;
		 when LPC_FW_R =>                    --Firmware read
          if r_cnt ="111" then
              --r_fw_msize <= lad_i; --8'th cycle on FW read is mem size
              r_cnt <= "000";
              lpc_wr <='0';             --memory read must accure
              lpc_val <='1';
              data_valid <='0';
			  if lad_i = MSIZE_FW_1B then
			  	 CS<=TARs;
			  else
	             --over byte fw read not supported
    	         CS<=RESETs;				
			  end if;
          else
            r_addr<= r_addr(27 downto 0)&lad_i;  --28 bit address is given
            r_cnt<=r_cnt + 1;
            CS<=ADDRs;
          end if;			
		
         when others => null;
        end case; 
      when DATAs => -----------------------------------------------------------
       case cycle_type is           
        when LPC_IO_W =>              --IO write cycle              
          if r_cnt ="001" then
            r_data <= lad_i&r_data(7 downto 4); --LSB first from io cycle
            r_cnt <= "000";
            lpc_wr <='1';             --IO write must accure
            lpc_val <='1';
            CS <= TARs;
          else
            r_data <= lad_i&r_data(7 downto 4); --LSB first from io cycle
            r_cnt<=r_cnt + 1;
            CS <= DATAs;
          end if;
        when LPC_MEM_R | LPC_FW_R =>                    --Memory/FW read cycle
          if r_cnt ="001" then
            lad_rising_o<= r_data(7 downto 4);
            r_cnt <= "000";
            CS <= LOCAL_TARs;
          else
            lad_rising_o<= r_data(3 downto 0);
            r_cnt<=r_cnt + 1;
            CS <= DATAs;
          end if;
       when others => null;          
       end case;                         
      when TARs => ------------------------------------------------------------
        if cycle_type /= LPC_IO_W and lpc_ack='1' and r_cnt ="001" then --if mem_read or fr_read
            r_data <= lpc_data_i;
            lpc_val <='0';
            data_valid <='1';
			CS<= SYNCs;
			r_cnt <= "000";
		  elsif lpc_ack='1' and r_cnt ="001" then
		    lad_rising_o<=SYNC_OK;              --added to avoid trouble as SYNC is OK allready
			lpc_val <='0';
			CS<= SYNCs;
			r_cnt <= "000";			
          end if;

          if r_cnt ="001" then
			  if lpc_ack='0' then
				lad_rising_o <= SYNC_LWAIT;              --added to avoid trouble				
			  end if;
           lad_rising_oe<='1';
          elsif lad_i = TAR_OK then
            r_cnt<=r_cnt + 1;
            --lad_rising_oe<='1'; --BUG fix by LPC stanard TAR cycle part 2 must be tri-stated by host and device
            lad_rising_o <= TAR_OK;              --drive to F on the bus
            CS <= TARs;
          else
            CS <= RESETs; --some error in protocol master must drive lad to "1111" on 1st TAR
          end if;
      when SYNCs => -----------------------------------------------------------
       case cycle_type is           
        when LPC_IO_W =>                   --IO write cycle   
          -- just passing r_lad on bus again
          lad_rising_o<= TAR_OK;
          CS <= LOCAL_TARs;
        when LPC_MEM_R | LPC_FW_R =>                    --Memory/FW read cycle
          if data_valid ='1' then
            lad_rising_o<=SYNC_OK;
            CS <= DATAs;
          else
            if lpc_ack='1' then
              r_data <= lpc_data_i;
              data_valid <= '1';
              lad_rising_o<=SYNC_OK;           --SYNC ok now                            
              lpc_val <='0';
              CS <= DATAs;
            end if;
          end if;
         when others => null;          
        end case;                      
      when LOCAL_TARs => ------------------------------------------------------
       case cycle_type is           
        when LPC_IO_W =>                   --IO write cycle   
            lpc_wr <='0';
            lad_rising_oe <='0';
            CS <= RESETs;
        when LPC_MEM_R | LPC_FW_R =>                    --Memory read cycle
          if r_cnt ="000" then                    
            lad_rising_o<= TAR_OK;
            r_cnt <= r_cnt + 1;
          else
            lad_rising_oe <= '0';
            r_cnt <="000";
            CS <= RESETs;
          end if;
        when others => null;            
       end case;                       
    end case; -----------------------------------------------------------------
  end if;
end process LPC;

end rtl;
