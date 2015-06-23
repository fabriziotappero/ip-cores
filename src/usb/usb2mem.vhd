--COMMAND STRUCTURE OF SERAL USB PROTOCOL

-- MSBYTE   LSBYTE

-- DATA     CODE

--Dongle internal command codes
-- 0x00     0xC5  		--Get Status data is don't care (must return) 0x3210 (3 is the MSNibble)
-- 0x01     0xC5        --Get Dongle version code
-- 0x02     0xC5        --PCB version code
-- 0x03     0xC5        --Get Mode switch setting

-- 0xC1     0xC5        --Release memeory interface to LPC
-- 0xC2     0xC5        --Put the device in USB programming mode (pulldown buf_en)
-- 0xC3     0xC5        --Force the dongle to indicate it's disconnected
-- 0xC4     0xC5        --Force the dongle to indicate it's connected

-- 0xC5     0xC5        --Force the dongle to lock memory interface
-- 0xC6     0xC5        --Force the dongle to unlock memory interface

-- 0x--     0xC5  		--Get Status data is don't care (must return) 0x3210 (3 is the MSNibble)


-- 0xNN     0xCD        --Get Data from flash (performs read from current address) NN count of words auto increment address
-- 0xAA     0xA0		--Addr LSByte write
-- 0xAA     0xA1        --Addr Byte write
-- 0xAA     0xA2		--Addr MSByte write
-- 0x--     0x3F		--NOP

--Flash operations codes
-- 0xNN     0xE8        --Write to buffer returns extended satus NN is word count for USB machine
-- 0x--     0xD0			-- 0xD0 is flash confirm command

--PSRAM operations codes
-- 0xNN     0xE9        --Write to buffer returns extended satus NN is word count for USB machine
-- 0xDD     0xDD        --N+1 times data expected 0xF + 1 is the maximum


--write flash buffer sequence
--      ???					-- set address if needed               
-- 0xNN     0xE8        --Write to buffer returns extended satus NN is word count for USB machine
-- 0x--     0xNN 			--0xNN is word count for flash ges directly to flash and is wordCount - 1
-- 0xDD     0xDD        --N+1 times data expected 0xF + 1 is the maximum
--      ...
-- 0x--     0xD0			-- 0xD0 is flash confirm command



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity usb2mem is
  port (
    clk25     : in  std_logic;
    reset_n   : in  std_logic;
	dongle_ver: in std_logic_vector(15 downto 0);
	pcb_ver   : in std_logic_vector(15 downto 0);
	mode       : in    std_logic_vector(2 downto 0);  --sel upper addr bits
	usb_buf_en : out  std_logic;
	dev_present_n : out  std_logic;
    -- mem Bus
	mem_busy_n: in std_logic;
	mem_idle  : out std_logic; -- '1' if controller is idle (flash is safe for LPC reads)
    mem_addr  : out std_logic_vector(23 downto 0);
    mem_do    : out std_logic_vector(15 downto 0);
    mem_di    : in std_logic_vector(15 downto 0);
    mem_wr    : out std_logic;
    mem_val   : out std_logic;
    mem_ack   : in  std_logic;
    mem_cmd   : out std_logic;
    -- USB port
	usb_mode_en : in   std_logic;  -- enable this block 
    usb_rd_n   : out  std_logic;  -- enables out data if low (next byte detected by edge / in usb chip)
    usb_wr     : out  std_logic;  -- write performed on edge \ of signal
    usb_txe_n  : in   std_logic;  -- tx fifo empty (redy for new data if low)
    usb_rxf_n  : in   std_logic;  -- rx fifo empty (data redy if low)
    usb_bd_o   : out  std_logic_vector(7 downto 0); --bus data
	 usb_bd     : in   std_logic_vector(7 downto 0) --bus data
    ); 
end usb2mem;

		
architecture RTL of usb2mem is



  
  type state_type is (RESETs,RXCMD0s,RXCMD1s,DECODEs,INTERNs,VCIRDs,VCIWRs,TXCMD0s,TXCMD1s,STS_WAITs);
  signal CS : state_type;

  signal data_reg_i : std_logic_vector(15 downto 0);
  signal data_reg_o : std_logic_vector(15 downto 0);
  signal data_oe    : std_logic;  -- rx fifo empty (data redy if low)
  signal usb_wr_d   : std_logic;  -- internal readable output state for write
  signal addr_reg: std_logic_vector(23 downto 0);  

  --State machine
  signal cmd_cnt   : std_logic_vector(15 downto 0);
  signal state_cnt : std_logic_vector(3 downto 0);
  --shyncro to USB
  signal usb_txe_nd  :    std_logic;  -- tx fifo empty (redy for new data if low)
  signal usb_rxf_nd  :    std_logic;  -- rx fifo empty (data redy if low)
  --signal internal_cmd  :    std_logic;  -- rx fifo empty (data redy if low)

  signal read_mode   : std_logic;
  --signal write_mode  : std_logic;
  signal write_count : std_logic;
  signal first_word : std_logic;
  signal mem_busy_nd : std_logic;


  
begin

usb_wr <= usb_wr_d;

-- this goes to byte buffer for that reason send LSB first and MSB second
usb_bd_o <=data_reg_o(7 downto 0)when data_oe='1' and CS=TXCMD0s and usb_mode_en='1' else --LSB byte first
			  data_reg_o(15 downto 8) when data_oe='1' and CS=TXCMD1s and usb_mode_en='1' else
			  (others=>'0');


process (clk25,reset_n)  --enable the scanning while in reset (simulation will be incorrect)
begin  -- process
  if reset_n='0' then
	CS <= RESETs;
	usb_rd_n <= '1';
	usb_wr_d <= '0';
	usb_txe_nd <= '1';
	usb_rxf_nd <= '1';
	data_oe <='0';
	state_cnt <=(others=>'0'); --init command counter
	mem_do <= (others=>'0');
	mem_addr <= (others=>'0');
	addr_reg <= (others=>'0');
	mem_val <= '0';
	mem_wr <='0';
	mem_cmd <='0';
	cmd_cnt <= (others=>'0');
	read_mode <='0';
 	write_count <='0';
  	first_word <='0';
	mem_idle <='1'; --set idle
	mem_busy_nd <='1';
	usb_buf_en <='1'; -- default mode (USB prog disabled, buffer with HiZ outputs)
	dev_present_n <='0'; --indicate that device is present on LPC bus for thincans
  elsif clk25'event and clk25 = '1' then    -- rising clock edge
	usb_txe_nd <= usb_txe_n; --syncronize
	usb_rxf_nd <= usb_rxf_n; --syncronize
	mem_busy_nd <=mem_busy_n; --syncronize
  	case CS is
    	when RESETs =>
			if usb_rxf_nd='0' and usb_mode_en='1' and mem_busy_nd='1' then
				state_cnt <=(others=>'0'); --init command counter
				data_oe <='0'; --we will read command in
				--mem_idle <='0'; --set busy untill return here
				CS <= RXCMD0s;
			end if;
		when RXCMD0s =>
			if state_cnt="0000" then
				usb_rd_n <='0'; -- set read low
				state_cnt <= state_cnt + 1;-- must be min 50ns long (two cycles)
			elsif state_cnt="0001" then 
				state_cnt <= state_cnt + 1;-- one wait cycle
			elsif state_cnt="0010" then
				state_cnt <= state_cnt + 1;-- now is ok
				data_reg_i(15 downto 8) <= usb_bd; --get data form bus MSByte must come first
			elsif state_cnt="0011" then
				usb_rd_n <='1'; -- set read back to high
				state_cnt <= state_cnt + 1;-- start wait	
			elsif state_cnt="0100" then
				state_cnt <= state_cnt + 1;-- wait	(the usb_rxf_n toggles after each read and next data is not ready)
			elsif state_cnt="0101" then
 				state_cnt <= state_cnt + 1;-- wait	
			elsif state_cnt="0110" then
				state_cnt <= state_cnt + 1;-- now is ok prob.														
			else
				if usb_rxf_nd='0' then	--wait untill next byte is available
					state_cnt <=(others=>'0'); --init command counter
					CS <= RXCMD1s;					
				end if;		
			end if;  
		when RXCMD1s =>
			if state_cnt="0000" then
				usb_rd_n <='0'; -- set read low
				state_cnt <= state_cnt + 1;-- must be min 50ns long (two cycles)
			elsif state_cnt="0001" then 
				state_cnt <= state_cnt + 1;-- one wait cycle
			elsif state_cnt="0010" then
				state_cnt <= state_cnt + 1;-- now is ok
				data_reg_i(7 downto 0) <= usb_bd; --get data form bus LSByte must come last
			elsif state_cnt="0011" then
				state_cnt <= state_cnt + 1;-- now is ok
				usb_rd_n <='1'; -- set read back to high	
			elsif state_cnt="0100" then
				state_cnt <= state_cnt + 1;-- wait (the usb_rxf_n toggles after each read and next data is not ready)
			elsif state_cnt="0101" then
				state_cnt <= state_cnt + 1;-- wait
			elsif state_cnt="0110" then
				state_cnt <= state_cnt + 1;-- now is ok prob.												
			else
				state_cnt <=(others=>'0'); --init command counter
				CS <= INTERNs;					
			end if;  			
		when INTERNs =>
		if 	cmd_cnt=x"0000" then
			if data_reg_i(7 downto 0)=x"A0" then
				addr_reg(7 downto 0)<= data_reg_i(15 downto 8);
				CS <= RESETs; --go back to resets
			elsif data_reg_i(7 downto 0)=x"A1" then
				addr_reg(15 downto 8)<= data_reg_i(15 downto 8);
				CS <= RESETs; --go back to resets
			elsif data_reg_i(7 downto 0)=x"A2" then
				addr_reg(23 downto 16)<= data_reg_i(15 downto 8);
				CS <= RESETs; --go back to resets
			elsif data_reg_i(7 downto 0)=x"3F" then
				CS <= RESETs; --go back to resets		--NOP command		
			elsif data_reg_i(7 downto 0)=x"C5" then
				if (data_reg_i(15 downto 8))=x"00" then
					data_reg_o <=x"3210";
				elsif(data_reg_i(15 downto 8))=x"01" then
					data_reg_o <=dongle_ver;
				elsif(data_reg_i(15 downto 8))=x"02" then
					data_reg_o <=pcb_ver;
				elsif(data_reg_i(15 downto 8))=x"03" then	
					data_reg_o <="0000000000000"&mode;
				elsif(data_reg_i(15 downto 8))=x"C1" then	--release flash to LPC interface
					data_reg_o <=x"C1C5";
					mem_idle <='1'; --set idle
				elsif(data_reg_i(15 downto 8))=x"C2" then	--force USB prog mode
					usb_buf_en <='0';
					data_reg_o <=x"C2C5";
				elsif(data_reg_i(15 downto 8))=x"C3" then	--fake dongle disconnect
					data_reg_o <=x"C3C5";	
					dev_present_n <='0';
				elsif(data_reg_i(15 downto 8))=x"C4" then	--fake dongle connect
					data_reg_o <=x"C4C5";	
					dev_present_n <='1';
				elsif(data_reg_i(15 downto 8))=x"C5" then	--fake dongle connect
					data_reg_o <=x"C5C5";	
					mem_idle <='0';  --lock LPC out from memory interface
				elsif(data_reg_i(15 downto 8))=x"C6" then	--fake dongle connect
					data_reg_o <=x"C6C5";	
					mem_idle <='1';  --unlock memory interface					
				else
					data_reg_o <=x"3210";  --always return even on unknown commands
				end if;
				CS <= TXCMD0s;	
			elsif data_reg_i(7 downto 0)=x"CD" then
				if (data_reg_i(15 downto 8))=x"00" then --64K word read coming
					cmd_cnt <= (others=>'1'); --64K word count
				else
					cmd_cnt <= x"00"&data_reg_i(15 downto 8) - 1; -- -1 as one read will be done right now (cmd_cnt words)
				end if;
				CS <= VCIRDs; --go perform a read
				read_mode <='1';
			elsif data_reg_i(7 downto 0)=x"E8" then
			    --write_mode <='1';
				write_count <='0';
			  	first_word <='0';			
				cmd_cnt <= x"00"&data_reg_i(15 downto 8) + 1;  --+2 for direct count write +1
				data_reg_i(15 downto 8)<=(others=>'0');
				CS <= VCIWRs; --go perform a write
			elsif data_reg_i(7 downto 0)=x"E9" then
				write_count <='1';  --no initial command write
			  	first_word <='0';			
				if (data_reg_i(15 downto 8))=x"00" then --64K word write coming
					cmd_cnt <= (others=>'1'); --64K word count
				else
					cmd_cnt <= x"00"&data_reg_i(15 downto 8);
				end if;
				data_reg_i(15 downto 8)<=(others=>'0');
				CS <= RESETs;	 --PSRAM does not need command			
			else 
				CS <= VCIWRs; 
			end if;
		else
			if cmd_cnt>x"0000" then
				cmd_cnt<= cmd_cnt - 1;
				if write_count='0' then
					write_count<='1';
				elsif write_count='1' and  first_word ='0' then
					first_word <='1';
				elsif write_count='1' and  first_word ='1' then
					addr_reg <= addr_reg + 1; --autoincrement address in in block mode
				end if;
				--if cmd_cnt>x"02" then --so not to increase too many times on write buffer
				--	addr_reg <= addr_reg + 1; --autoincrement address in in block mode
				--end if;
			end if;
			CS <= VCIWRs;		
		end if;
		when VCIRDs =>		--flash read
			mem_wr <='0';  			--this is VCI write_not_read
			mem_cmd <='0';
			mem_addr <= addr_reg(22 downto 0)&'0'; --translate byte address to word address
			mem_val <= '1';   	
			if mem_ack='1' then
				data_reg_o <= mem_di;
				mem_wr <='0';  			--this is VCI write_not_read
				mem_cmd <='0';
				mem_val <= '0';
				CS <= TXCMD0s;
			end if;		
		when VCIWRs =>		--flash write
			mem_addr <= addr_reg(22 downto 0)&'0'; --translate byte address to word address
			if mode(2)='1' then
				--this HW swap removes the need to swap bytes in python for PSRAM region
				mem_do <= data_reg_i(7 downto 0)&data_reg_i(15 downto 8); --SWAP data for PSRAM region
			else				
				mem_do <= data_reg_i; 	--USB data in will go to mem_out
			end if;	
			mem_wr <='1';  			--this is VCI write_not_read
			mem_cmd <='1';
			mem_val <= '1';  	
			if mem_ack='1' then
				mem_do <= (others=>'Z');
				mem_wr <='0';  			--this is VCI write_not_read
				mem_cmd <='0';
				mem_val <= '0'; 
				--if write_mode='0' then
					
					if cmd_cnt=x"0000" then --if flash command and not data
						state_cnt <=(others=>'0'); --init command counter
						CS <= STS_WAITs;
					else
						CS <= RESETs;
					end if;
				--else  --else if was 0xE8 must read and return XSR
				--	write_mode <='0'; --XSR return will no follow clear this bit
				--	CS <= VCIRDs;
				--end if;
			end if;
		when TXCMD0s =>  --transmit over USB what ever is in data_reg_o MSB first
			
				if state_cnt="0000" then
					if usb_txe_nd='0' then
						usb_wr_d<='1'; -- data is mux'ed by state and data_oe in the beginning of arch
						state_cnt <= state_cnt + 1;-- now is ok
					end if;		
				elsif state_cnt="0010" then
				    data_oe<='1'; --this is to put data on bus befora falling edge of wr (max 20ns before)
					state_cnt <= state_cnt + 1;-- now is ok
				elsif state_cnt="0011" then
				    usb_wr_d<='0'; --falling edge performs write  must be high for atleast 50ns
					state_cnt <= state_cnt + 1;-- now is ok
				elsif state_cnt="0100" then
					state_cnt <= state_cnt + 1;-- now is ok		
					data_oe<='0';	
				elsif state_cnt="0111" then	  --must stay low at least 50ns
					CS <= TXCMD1s;
					state_cnt <= (others=>'0');
				else 
					state_cnt <= state_cnt + 1;-- if intermediate cnt then count
				end if;
			
		when TXCMD1s => 
			
				if state_cnt="0000" then
				    if usb_txe_nd='0' then
						usb_wr_d<='1'; -- data is mux'ed by state and data_oe in the beginning of arch
						state_cnt <= state_cnt + 1;-- now is ok
		   			end if;		
				elsif state_cnt="0010" then
				    data_oe<='1'; --this is to put data on bus befora falling edge of wr (max 20ns before)
					state_cnt <= state_cnt + 1;-- now is ok
				elsif state_cnt="0011" then
				    usb_wr_d<='0'; --falling edge performs write  must be high for atleast 50ns
					state_cnt <= state_cnt + 1;-- now is ok
				elsif state_cnt="0100" then
					state_cnt <= state_cnt + 1;-- now is ok		
					data_oe<='0';			
				elsif state_cnt="0111" then	  --must stay low at least 50ns
					if read_mode='0' then
						CS <= RESETs;
					elsif cmd_cnt="0000" then --last word sent
						addr_reg <= addr_reg + 1; --autoincrement address in read mode
						read_mode <='0';
						CS <= RESETs;
					else
						cmd_cnt<= cmd_cnt - 1;
						addr_reg <= addr_reg + 1; --autoincrement address in read mode
						CS <= VCIRDs;	--more data to be read
					end if;
					state_cnt <= (others=>'0');
				else 
					state_cnt <= state_cnt + 1;-- if intermediate cnt then count
				end if;
		when STS_WAITs => 
				if mem_busy_nd='0' or mode(2)='1' then  --go to RESETs if PSRAM mode is selected
					CS <= RESETs; --now it's ok to go here
				else
					state_cnt <= state_cnt + 1;
					if state_cnt="1111" then
						--sts cant take longer than 500 ns to go low
						CS <= RESETs; --time out go to resets anyway
					end if;
				end if;		
    	when others => null;
  	end case;
  end if;
end process;



end RTL;

