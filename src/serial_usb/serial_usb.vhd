library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.serial_usb_package.all;
use work.dongle_arch.all;

 
entity serial_usb is
	port(
		clock		: in  std_logic;
		reset_n		: in  std_logic;
		--VCI Port
		vci_in		: in vci_slave_in;
		vci_out		: out vci_slave_out;
		--FTDI fifo interface
		uart_ena	: in usbser_ctrl;
		fifo_out	: out usb_out;
		fifo_in		: in usb_in
	);
end entity serial_usb;

architecture rtl of serial_usb is

	type reg_type is
	record
		uart	 	: uart_registers;
		fifo		: usb_out;
		fifo_sync: usb_in;
		vci		: vci_slave_out;
		pc_loop  :  boolean;
		vci_write_pending :  boolean;
		vci_read_pending :  boolean;
		tx_timer :  std_logic_vector(2 downto 0);
		rx_timer :  std_logic_vector(2 downto 0);
		ftdi_precharge :  std_logic_vector(2 downto 0);	--time between cycles
	end record;
		
	signal reg, reg_in : reg_type;

begin

	-- Design pattern process 1 Implementation 
	comb : process (vci_in,uart_ena,reg)
			variable reg_v : reg_type;
		begin
			-- Design pattern 
			reg_v:=reg; --pre set default var state
			
			
			--
			--Debug code send repeating "0123456789" to UART
			--
--			if reg_v.uart.lsr.reg(SEL_LSR_EMPTY_TXH)='1' then
--				reg_v.uart.lsr.reg(SEL_LSR_EMPTY_TXH):='0';  --set TX filled
--				reg_v.uart.txhold.reg(3 downto 0):= reg_v.uart.txhold.reg(3 downto 0)+1;
--				if reg_v.uart.txhold.reg(3 downto 0)=x"A" then
--					reg_v.uart.txhold.reg(3 downto 0):=x"0";
--				end if;
--				reg_v.uart.txhold.reg(7 downto 4):=x"3";
--			end if;
			
			------------------------------------
			---  <implementation>			---
			------------------------------------
			
			
			--reduce precharge counter always
			if reg_v.ftdi_precharge>"000" then
				reg_v.ftdi_precharge:=reg_v.ftdi_precharge - 1;
			end if;
			
			--VCI write access request			
			if vci_in.lpc_val='1' and vci_in.lpc_wr='1' and reg_v.vci.lpc_ack='0'  then
				reg_v.vci_write_pending:=true;
			end if;			

			--VCI read access request
			if vci_in.lpc_val='1' and vci_in.lpc_wr='0' and reg_v.vci.lpc_ack='0' then
				reg_v.vci_read_pending:=true;
			end if;			
			
			--Writable conf registers
			if reg_v.vci_write_pending then --write decode			
				case vci_in.lpc_addr(2 downto 0) is
					when "000" => 
						--select DLAB or not
						if reg_v.uart.lcr.reg(SEL_LCR_DLAB)='0' then --Line Control Register (LCR) SEL_LCR_DLAB   
							reg_v.uart.txhold.reg:=vci_in.lpc_data_o;  --Transmitter Holding Buffer
							clr_uart_tx_int(reg_v.uart); --clear tx on tx buff write
							if reg_v.uart.mcr.reg(SEL_MCR_LOOP)='0'  then --loop not endabled
								reg_v.uart.lsr.reg(SEL_LSR_EMPTY_TXH):='0'; -- TX not empty
								reg_v.uart.lsr.reg(SEL_LSR_EMPTY_DH):='0'; -- TX not empty
							else --do local loop
								reg_v.uart.rxbuff.reg:=reg_v.uart.txhold.reg;
								reg_v.uart.lsr.reg(SEL_LSR_DATARDY):='1'; --set data ready in register
								set_uart_rx_int(reg_v.uart);								
							end if;
						else
							reg_v.uart.div_low.reg:=vci_in.lpc_data_o; --Divisor Latch Low Byte
						end if;			
					when "001" => 
						--select DLAB or not
						if reg_v.uart.lcr.reg(SEL_LCR_DLAB)='0' then --Line Control Register (LCR) SEL_LCR_DLAB   
							reg_v.uart.ier.reg:=vci_in.lpc_data_o; --Interrupt Enable Register
						else
							reg_v.uart.div_high.reg:=vci_in.lpc_data_o; --Divisor Latch High Byte
						end if;
					when "011" => -- +3
						reg_v.uart.lcr.reg:=vci_in.lpc_data_o; --Line Control Register (don't care except DLA bit)
					when "100" => -- +4
						reg_v.uart.mcr.reg:=vci_in.lpc_data_o; --Modem Control Register (don't care except loopback)
						reg_v.uart.mcr.reg(SEL_MCR_FLWCTRL):='0'; --this is not supported so auto clear
					when "111" => -- +7
						reg_v.uart.scr.reg:=vci_in.lpc_data_o;
					when others =>
						null;
				end case;
				--we must ack the write always
				reg_v.vci_write_pending:= false;
				reg_v.vci.lpc_ack:='1'; --ack all writes to non writable addresses for VCI to work
			end if;
			
			--Readable conf registers
			if reg_v.vci_read_pending then --write decode			
				case vci_in.lpc_addr(2 downto 0) is
					when "000" =>
						--select DLAB or not
						if reg_v.uart.lcr.reg(SEL_LCR_DLAB)='0' then --Line Control Register (LCR) SEL_LCR_DLAB   
							reg_v.vci.lpc_data_i:=reg_v.uart.rxbuff.reg; --RX read data
							reg_v.uart.lsr.reg(SEL_LSR_DATARDY):='0'; --data has been read
							clr_uart_rx_int(reg_v.uart);
						else
							reg_v.vci.lpc_data_i:=reg_v.uart.div_low.reg;
						end if;	
					when "001" =>
						if reg_v.uart.lcr.reg(SEL_LCR_DLAB)='0' then --Interrupt Enable Register (IER) SEL_LCR_DLAB  
							reg_v.vci.lpc_data_i:=reg_v.uart.ier.reg;
						else --Divisor Latch High Byte
							reg_v.vci.lpc_data_i:=reg_v.uart.div_high.reg;
						end if;
					when "010" =>
							reg_v.vci.lpc_data_i:=reg_v.uart.iir.reg; -- Interrupt Identification Register(IIR)
							clr_uart_tx_int(reg_v.uart); --clear tx on iir read
					when "011" =>
							reg_v.vci.lpc_data_i:=reg_v.uart.lcr.reg;		
					when "100" =>
							reg_v.vci.lpc_data_i:=reg_v.uart.mcr.reg;		
					when "101" =>
							reg_v.vci.lpc_data_i:=reg_v.uart.lsr.reg;		
					when "110" =>
							reg_v.vci.lpc_data_i:=reg_v.uart.msr.reg;
					when "111" =>
							reg_v.vci.lpc_data_i:=reg_v.uart.scr.reg;																		
					when others => 
						reg_v.vci.lpc_data_i:=(others=>'0'); -- return 0
				end case;
				--we must ack the read always
				reg_v.vci_read_pending:= false;
				reg_v.vci.lpc_ack:='1'; --ack all reads to non readable addresses for VCI to work					 							
			end if;			
			
			--UART Register state change handling
			--TX haldler
			if reg_v.fifo.rx_oe_n='1' and reg_v.ftdi_precharge="000" and reg_v.fifo_sync.tx_empty_n='0' and reg_v.tx_timer="000" and reg_v.uart.lsr.reg(SEL_LSR_EMPTY_TXH)='0' then --No ongoing read and can and has something to TX
				reg_v.fifo.txdata:=reg_v.uart.txhold.reg;
				reg_v.fifo.tx_wr:='1';
				reg_v.tx_timer:="011"; --FDTI fifo timing 40 ns needed for write pulse high
			end if;
			if reg_v.tx_timer>"000" then -- TX cycle timer
				reg_v.tx_timer:=reg_v.tx_timer-1;
				if reg_v.tx_timer="000" then
					reg_v.fifo.tx_wr:='0'; -- write happens on falling edge '''\,,,
					reg_v.ftdi_precharge:="011"; --start cycle cap
					reg_v.uart.lsr.reg(SEL_LSR_EMPTY_TXH):='1'; -- all sent
					reg_v.uart.lsr.reg(SEL_LSR_EMPTY_DH):='1'; -- ready for new data
					set_uart_tx_int(reg_v.uart);
				end if;
			end if;
			--RX Handler
			
			
			if (not reg_v.pc_loop) or reg_v.uart.lsr.reg(SEL_LSR_EMPTY_TXH)='1' then	
				if reg_v.fifo.tx_wr='0'and reg_v.ftdi_precharge="000" and reg_v.fifo_sync.rx_full_n='0' and reg_v.rx_timer="000" and reg_v.uart.lsr.reg(SEL_LSR_DATARDY)='0' then -- no ongoing TX and data in FTDI fifo and read buffer has been read
					reg_v.fifo.rx_oe_n:='0'; -- output enable
					reg_v.rx_timer:="100";
				end if;
				if reg_v.rx_timer>"000" then --RX cycle timer
					reg_v.rx_timer:=reg_v.rx_timer-1;
					if reg_v.rx_timer="000" then
						reg_v.fifo.rx_oe_n:='1'; -- read happens on rising front  ,,,,/'''' of oe_n
						reg_v.ftdi_precharge:="101"; --start cycle cap
						reg_v.uart.rxbuff.reg:=reg_v.fifo_sync.rxdata;
						if reg_v.pc_loop then --pc test loop
							reg_v.uart.txhold.reg:=reg_v.fifo_sync.rxdata;
							reg_v.uart.lsr.reg(SEL_LSR_EMPTY_TXH):='0'; --do transmit
						else
							reg_v.uart.lsr.reg(SEL_LSR_DATARDY):='1'; --set data ready in register
							set_uart_rx_int(reg_v.uart);
						end if;
					end if;
				end if;
			end if;
			
			--UART Interrupt
			if reg_v.uart.iir.reg(SEL_IIR_PENDING_N)='0' then
				reg_v.vci.lpc_irq:='1'; --set up int signal
			else
				reg_v.vci.lpc_irq:='0';
			end if;
			--End UART
			
			--VCI request end, clear ack when val drops			
			if vci_in.lpc_val='0' and reg_v.vci.lpc_ack='1'  then
				reg_v.vci.lpc_ack:='0';
			end if;			

			
			-- Design pattern 
			-- drive register input signals
			reg_in<=reg_v;
			-- drive module outputs signals
			--port_comb_out<= reg_v.port_comb;  --combinatorial output
			--port_reg_out<= reg.port_reg; --registered output
			vci_out<=reg.vci;
			fifo_out<= reg.fifo;			
		end process;

	-- Pattern process 2, Registers
	regs : process (clock,reset_n)
		begin
			if reset_n='0' then
				reg.pc_loop<=false;
				reg.rx_timer<=(others=>'0');
				reg.tx_timer<=(others=>'0');
				reg.ftdi_precharge<=(others=>'0');
				reg.vci_read_pending<=false;
				reg.vci_write_pending<=false;				
				uart_reset(reg.uart);
				fifo_reset(reg.fifo);
				vci_slave_reset(reg.vci);
			elsif rising_edge(clock) then
				reg<=reg_in;
				reg.fifo_sync<=fifo_in;
			end if;
		end process;


end rtl;
