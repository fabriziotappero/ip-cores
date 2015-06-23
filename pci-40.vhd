-- *************************************************************** //
--																   //
--			PCI_TARGET-Wishbone_MASTER INTERFACE MODULE	(PCI-mini) //
--											v4.0			       //
--															       //
--   The original PCI module is from:	Ben Jackson.               //
--				http://www.ben.com/minipci/verilog.php	           //
--														           //
--	  Istvan Nagy, buenos@freemail.hu					           //	   
--										                           //
--													               //
--      DOWNLOADED FROM OPENCORES. (License = GPL)                 //
--                                                                 //
-- *************************************************************** //
--
-- The core implements a 16MB relocable memory image. Relocable on the
--   wb bus. the wb address = 4M*wb_baseaddr_reg + PCI_addr[23:2]
--   Only Dword aligned Dword accesses allowed on the PCI. This way
--   we can access to the 4GB wb-space through a 16MB PCI-window.
--   The addressing on the wb-bus, is Dword addressing, while on the
--   PCI bus, the addressing is byte addressing. A(pci)=A(wb)*4
--   The PCI address is increasing by 4, and we get 4 bytes. The wb
--   address is increasing by 1, and we get 1 Dword (= 4 bytes also).
--   The wb_baseaddr_reg is the wb image relocation register, can be
--   accessed at 50h address in the PCI configuration space.
--   Other bridge status and command is at the 54h and 58h addresses.
--   if access fails with timeout, then the address will be in the 
--   wb address will be stored in the failed_addr_reg at 5Ch address.
--
-- Wishbone compatibility:
--  Wishbone signals: wb_address, wb_dat_o, wb_dat_i, wb_sel_o, wb_cyc_o, 
--  wb_stb_o, wb_wr_o, wb_reset_o, wb_clk_o, wb_ack_i.
--  Not implemented wb signals: error, lock, retry, tag-signals.
--  The peripheral has to response with ack in 16 clk cycles.
--  The core has wishbone clk and reset outputs, just like a Syscon module.
--  The core generates single reads/writes. These are made of 4 phases, so
--  dont write new data, until internal data movement finishes: about 300...500ns
--
-- PCI compatibility: 
-- Only single DWORD reads/writes are supported. between them, the software has 
--   to wait 300...500nsec, to prevent data corrupting. STOP signaling is not 
--   implemented, so target terminations also not. 
--   Single Byte access is NOT supported! It may cause corrupt data.
--   The core uses INTA interrupt signal. There are some special PCI config
--   registers, from 50h...60h config-space addresses.
--   PCI-parity: it generates parity, but doesnt check incoming parity.
--   Because of the PC chipset, if you read a value and write it back,
--   the chipset will not write anything, because it can see the data is not 
--   changed. This is important at some peripherals, where you write, to control.
-- Device specific PCI config header registers:
--   name:					addr:		function:
--   wb_baseaddr_reg;	50h		A(wb)=(A(pci)-BAR0)/4 + wb_baseaddr_reg. RESET TO 0
--   user_status_reg;	54h		not used yet
--   user_command_reg;	58h		not used yet
--   failed_addr_reg;	5Ch		address, when timeout occurs on the wb bus.
--
-- Local bus arbitration: 
-- This is not really wishbone compatible, but needed for the PCI.
--  The method is: "brute force". it means if the PCI interface wants to
--  be mastering on the local (wishbone) bus, then it will be mastering,
--  so, the other master(s) must stop anything immediately. The req signal
--  goes high when there is an Address hit on teh PCI bus. so the other
--  master has few clk cycles to finish.
-- Restrictions: the peripherals have to be fast: If the other master
--  starts a transaction before req goes high, the ack has to arrive before 
--  the PCI interface starts its own transaction. (max 4clk ACK delay)
--  The other master or the bus unit must sense the req, and give bus
--  mastering to the PCI-IF immediatelly, not just when the other master
--  finished everything, like at normal arbitration schemes.
--
-- Buffering:
--  There is a single Dword buffering only.
--
-- The led_out interface: 
--  only for system-debug: we can write to the LEDs, at any address. 
--  (in the same time there is a wishbone write also)
--
-- Changes since original version: wishbone interface,
--  bigger memory-image, parity-generation,
--  interrupt handling. Code size is 3x bigger. New registers, 
-- V4.0 is completely re-written from scratch in VHDL. It has some features removed,
--  like address remapping or user reset control.
--
-- Device Compatibility:
--  Until v3.3 the code was tested on Xilinx FPGAs (sp2, sp3) with ISE 4.7-9.1 and VIA/AMD chipsets.
--  Version 3.4 has modifications to work on Actel/Microsemi ProASIC3 with Sinplify and Intel Atom chipset.
--  (v3.4 was not tested on Xilinx FPGAs) To make sure that it runs on the Actel FPGA, we have to use the
--  timing constraint SDC file, AND ALSO set the P&R to Timing optimized and "effort"=high.
--
-- *************************************************************** //


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--entity header  ----------------------------------------------------------------
entity pci is
    Port ( --ports:
            reset : in std_logic;
            pciclk : in std_logic;
            frame : in std_logic;
            irdy : in std_logic;
            trdy : out std_logic;
            devsel : out std_logic;
            idsel : in std_logic;
            ad : inout std_logic_vector(31 downto 0);
            cbe : in std_logic_vector(3 downto 0);
            par : inout std_logic;
            stop : out std_logic;
            inta : out std_logic;
            serr : out std_logic;
            perr : out std_logic;
            led_out : out std_logic_vector(3 downto 0);
            wb_address : out std_logic_vector(31 downto 0);
            wb_dat_o : out std_logic_vector(31 downto 0);
            wb_dat_i : in std_logic_vector(31 downto 0);
            wb_sel_o : out std_logic_vector(3 downto 0);
            wb_cyc_o : out std_logic;
            wb_stb_o : out std_logic;
            wb_wr_o : out std_logic;
            wb_reset_o : out std_logic;
            wb_clk_o : out std_logic;
            wb_ack_i : in std_logic;
            wb_irq : in std_logic;
            wb_req : out std_logic;
            wb_gnt : in std_logic;
            wb_req_other : in std_logic;
            contr_o : out std_logic_vector(7 downto 0)
           );
end pci;






--architecture start ------------------------------------------------------------
architecture Behavioral of pci is




-- SOME CONSTANTS ---------------------------------------------------------------
CONSTANT DEVICE_ID : std_logic_vector := X"9500";
CONSTANT VENDOR_ID : std_logic_vector := X"11AA"; --	160X11AA : std_logic_vector := actel, 
CONSTANT DEVICE_CLASS : std_logic_vector := X"118000";	-- some examples: 068000=bridge/other, 078000=simple_comm_contr/other, 118000=data_acquisition/other
CONSTANT DEVICE_REV : std_logic_vector := X"01";
CONSTANT SUBSYSTEM_ID : std_logic_vector := X"0001";	-- Card identifier
CONSTANT SUBSYSTEM_VENDOR_ID : std_logic_vector := X"13C7"; -- 13C7 : std_logic_vector := bluechip technology
CONSTANT DEVSEL_TIMING : std_logic_vector := "00";	-- Fast!
CONSTANT ST_IDLE : std_logic_vector := "000";
CONSTANT ST_BUSY : std_logic_vector := "010";
CONSTANT ST_MEMREAD : std_logic_vector := "100";
CONSTANT ST_MEMWRITE : std_logic_vector := "101";
CONSTANT ST_CFGREAD : std_logic_vector := "110";
CONSTANT ST_CFGWRITE : std_logic_vector := "111";
CONSTANT ST_HOLD : std_logic_vector := "001";
CONSTANT MEMREAD : std_logic_vector := "0110"; --cbe
CONSTANT MEMWRITE : std_logic_vector := "0111"; --cbe
CONSTANT CFGREAD : std_logic_vector := "1010"; --cbe
CONSTANT CFGWRITE : std_logic_vector := "1011"; --cbe
CONSTANT WB_BASEADDRESS : std_logic_vector := "00000000000000000000000000000000";
CONSTANT INT_PIN_INFO : std_logic_vector := "00000001"; --which interrupt signal is connected on the PCB? 0=none, 1=INTA, 2=INTB, 3=INTC, 4=INTD





-- INTERNAL SIGNALS -------------------------------------------------------------
    SIGNAL wb0_state  :  std_logic_VECTOR(7 DOWNTO 0);
    SIGNAL wb_transaction_complete :  std_logic;
    SIGNAL start_read_wb0 :  std_logic;
    SIGNAL start_write_wb0 :  std_logic;
    SIGNAL wb_address_feed  :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL wb_dat_o_feed  :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL wb_dat_i_latched  :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL wb_sel_o_feed :  std_logic_VECTOR(3 DOWNTO 0);

    SIGNAL pci_state  :  std_logic_VECTOR(2 DOWNTO 0);
    SIGNAL second_clock_pci :  std_logic;
    SIGNAL assert_stop :  std_logic;
    SIGNAL data  :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL wr_data_pci  :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL ad_latched   :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL cbe_latched   :  std_logic_VECTOR(3 DOWNTO 0);
    SIGNAL frame_latched  :  std_logic;
    SIGNAL irdy_latched  :  std_logic;
    SIGNAL idsel_latched  :  std_logic;
    SIGNAL cbe_latched2  :  std_logic_VECTOR(3 DOWNTO 0);
    SIGNAL frame_latched2 :  std_logic;

    SIGNAL pci_address   :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL pci_address_previous  :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL pci_address_readonly  :  std_logic_VECTOR(31 DOWNTO 0);
    SIGNAL hit :  std_logic;
    SIGNAL int_stat :  std_logic;
    SIGNAL addr_hit :  std_logic;
    SIGNAL cfg_hit :  std_logic;
    SIGNAL baseaddr   :  std_logic_VECTOR(7 DOWNTO 0);
    SIGNAL int_line   :  std_logic_VECTOR(7 DOWNTO 0);
    SIGNAL int_dis :  std_logic;
    SIGNAL data_par :  std_logic;
    SIGNAL memen :  std_logic;
    SIGNAL dummyreg32  :  std_logic_VECTOR(31 DOWNTO 0);





--------- COMPONENT DECLARATIONS (introducing the IPs) --------------------------
--none


--architecture body start -------------------------------------------------------
begin



--------- COMPONENT INSTALLATIONS (connecting the IPs to local signals) ---------
--none


-- local Logic ------------------------------------------------------------------

    led_out <= "0000";
    contr_o <= "00000000";




    -- ************** WISBONE BACK-end INTERFACE ****************************
    -- **********************************************************************

    --main state machine: set states, capture inputs, set addr/data outputs
	 --minimum 2 clock cycles / transaction. writes are posted, reads have wait states.
    process (reset, pciclk, wb0_state, start_read_wb0, start_write_wb0,
				wb_address_feed, wb_dat_o_feed, wb_sel_o_feed) 
    begin
    if (reset='0') then 
       wb0_state <= "00000000";
       wb_transaction_complete <= '0';
		 wb_address <= "00000000000000000000000000000000";
		 wb_sel_o <= "0000";
		 wb_dat_o <=   "00000000000000000000000000000000";		
		 wb_transaction_complete <='0';
         wb_dat_i_latched <= "00000000000000000000000000000000";		 
    else
      if (pciclk'event and pciclk = '1') then
                case ( wb0_state ) is

                --********** IDLE STATE  **********
                when "00000000" =>   --state 0        
                    wb_transaction_complete <='0';
						  wb_sel_o <= wb_sel_o_feed;
						  wb_address <= wb_address_feed;
						  if (start_read_wb0 ='1') then --go to read
						    wb0_state <= "00000001";
						  elsif (start_write_wb0 ='1') then --go to write
						    wb0_state <= "00000010";
							wb_dat_o <= wb_dat_o_feed;								  
						  end if;

                --********** READ STATE ********** 
					 --set the outputs, 
					 --if ACK asserted, sample the data input
					 --The hold requirements are oversatisfyed by going back to idle, and by the fact that the slave uses the cyc/stb/wr strobes synchronously.
                when "00000001" =>   --state 1
                    if (wb_ack_i='1') then
						     wb_dat_i_latched <= wb_dat_i; --sample the incoming data						
							 wb_transaction_complete <='1'; --signalling ready, but only for one clock cycle
							 wb0_state <= "00000000"; --go to state 0
						  else
						  	 wb_transaction_complete <='0';
						  end if;	   		  

                --********** WRITE STATE **********     
					 --if ACK asserted, go back to idle
					 --The hold requirements are oversatisfyed by waiting for ACK to remove write data					 
                when "00000010" =>   --state 2
                    if (wb_ack_i='1') then
							 wb0_state <= "00000000"; --go to state 0
							 wb_transaction_complete <='1';
						  else
						     wb_transaction_complete <='0';
						  end if;
						  
                when others => --error
                      wb0_state <= "00000000"; --go to state 0
                end case;     
       end if;        
    end if;
    end process;
    --sync control on wb-control signals:
    process (reset, wb0_state) 
    begin
    if (reset='0') then 
		wb_cyc_o  <= '0';
		wb_stb_o  <= '0';
		wb_wr_o  <= '0';
    else
      if (wb0_state = "00000000") then --idle
			wb_cyc_o  <= '0';
			wb_stb_o  <= '0';
			wb_wr_o  <= '0';
      elsif (wb0_state = "00000001") then --read 
			wb_cyc_o  <= '1';
			wb_stb_o  <= '1';
			wb_wr_o  <= '0';
      elsif (wb0_state = "00000010") then --write 
			wb_cyc_o  <= '1';
			wb_stb_o  <= '1';
			wb_wr_o  <= '1';
		else
			wb_cyc_o  <= '0';
			wb_stb_o  <= '0';
			wb_wr_o  <= '0';
		end if;
    end if;
    end process;

    wb_reset_o <= not reset;
    wb_clk_o <= pciclk;
    wb_sel_o_feed <= "1111"; --only 32bit accesses are supported



    -- wishbone arbitration:
    --not supported at the moment:
    wb_req <= '1';
    -- xx <- wb_req_other, wb_gnt












    -- ************** THE PCI I/O STATEMACHINE ******************************
    -- **********************************************************************
    process (reset, pciclk) 
    begin
    if (reset='0') then 
        trdy  <= 'Z';
        devsel  <= 'Z';
        ad  <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
        par  <= 'Z';
        stop  <= 'Z';
        start_read_wb0 <= '0';
        start_write_wb0  <= '0';
        wb_address_feed  <= "11111111111111111111111111111111";
        wb_dat_o_feed  <= "11111111111111111111111111111111";
        pci_state <= ST_IDLE;
        ad_latched <= (others => '0');
        cbe_latched <= "0000";
        frame_latched <= '1';
        irdy_latched <= '1';
        idsel_latched <= '0';
        second_clock_pci <= '0';
        wr_data_pci <=  (others => '0');
        assert_stop  <= '0';
        dummyreg32 <=   (others => '0');
        baseaddr  <=   (others => '0');
        int_line   <=   (others => '0');
        int_dis  <= '0';
        memen  <= '0';
        pci_address    <=   (others => '0');
        pci_address_previous   <=   (others => '1');
        pci_address_readonly <=   (others => '0');
        data   <=   (others => '0');
        cbe_latched2 <= "0000";
        frame_latched2 <= '1';
    else
      if (pciclk'event and pciclk = '1') then

              --latching some signals to break timing path:
              ad_latched <= ad;
              cbe_latched <= cbe;
              frame_latched <= frame;
              irdy_latched <= irdy;
              idsel_latched <= idsel;
              --again::
              cbe_latched2 <= cbe_latched;
              frame_latched2 <= frame_latched;

              case ( pci_state ) is

                --********** idle STATE  **********
                when ST_IDLE =>   --state 000        
                    --pci signals:
                    trdy  <= 'Z';
                    ad  <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
                    par  <= 'Z';
                    stop  <= 'Z';
                    --logic:
                    --address handling/latching:
                    if (frame_latched = '0') then
                      pci_address <= ad_latched;
                    end if;
                    if (frame_latched2='0' and hit='1') then
                      --next state without decoding:
                      --pci_state(2) <= '1';
                      --pci_state(1) <=  cbe_latched(3);
                      --pci_state(0) <= cbe_latched(0);
                      if (cbe_latched2 = MEMREAD) then
                        pci_state <=  ST_MEMREAD ;
                        pci_address_readonly <= pci_address;
                        pci_address_previous <= pci_address_readonly;
                      elsif (cbe_latched2 = MEMWRITE) then
                        pci_state <=  ST_MEMWRITE ;
                      elsif (cbe_latched2 = CFGREAD) then
                        pci_state <=  ST_CFGREAD ;
                      elsif (cbe_latched2 = CFGWRITE) then
                        pci_state <=  ST_CFGWRITE  ;
                      end if;
                      devsel  <= '0';
                    else
                      devsel  <= 'Z';
                    end if;
                    start_read_wb0 <= '0';
                    start_write_wb0 <= '0';
                    assert_stop  <= '0';
                    second_clock_pci <= '0';

                --********** CFG Read STATE ********** 
                when ST_CFGREAD =>   --state 110
                    second_clock_pci <= '1';
                    case (pci_address(7 downto 2)) is
                      when "000000" => --0
                         data (31 downto 16) <=  DEVICE_ID;
                         data (15 downto 0) <=  VENDOR_ID;
                      when "000001" => --1
                         data (31 downto 27) <=  "00000";
                         data (26 downto 25 ) <=  DEVSEL_TIMING;
                         data (24 downto 20) <=  "00000";
                         data ( 19 ) <=  int_stat;
                         data (18 downto 11) <=  "00000000";
                         data ( 10 ) <=  int_dis;
                         data (9 downto 2) <=  "00000000";
                         data ( 1 ) <=  memen;
                         data ( 0 ) <=  '0';
                      when "000010" => --2
                         data (31 downto 8) <=  DEVICE_CLASS;
                         data (7 downto 0) <=  DEVICE_REV;
                      when "000100" => --4 (BAR0)
                         data (31 downto 24) <=  baseaddr;
                         data (23 downto 0) <=  (others => '0');
                      when "001011" => --11
                         data (31 downto 16) <=  SUBSYSTEM_ID;
                         data (15 downto 0) <=  SUBSYSTEM_VENDOR_ID;
                      when "001111" => --15
                         data (31 downto 16) <=  (others => '0');
                         data (15 downto 8) <=  INT_PIN_INFO;
                         data (7 downto 0) <=  int_line;
                      --when "010000" => --16
                         --data ( downto ) <=  ;
                      when others => --0
                         data <= "00000000000000000000000000000000";
                    end case;
                    --finishing off:
                    if (second_clock_pci='1' and irdy_latched='0') then
                        --pci signals:
                        trdy  <= '0';
                        ad  <= data;
                        par  <= data_par;
                        pci_state <= ST_HOLD;
                    end if;

                --********** CFG Write STATE **********     				 
                when ST_CFGWRITE =>   --state 111
                    if (second_clock_pci='0' and irdy_latched='0') then
                        wr_data_pci <= ad;
                        second_clock_pci <= '1';
                    end if;
                    --finishing off:
                    if (second_clock_pci='1') then
                        --pci signals:
                        devsel  <= '1';
                        trdy  <= '1';
                        stop  <= '1';
                        pci_state <= ST_HOLD;
                        --set the appropriate register
                        case (pci_address(7 downto 2)) is
                          when "000001" => --1
                             int_dis <= wr_data_pci(10);
                             memen <= wr_data_pci(1); 
                          when "000100" => --4 (BAR0)
                             baseaddr <= wr_data_pci(31 downto 24);
                          when "001111" => --15
                             int_line  <= wr_data_pci(7 downto 0);
                          --when "010000" => --16
                             --data ( downto ) <=  ;
                          when others => --0
                             dummyreg32 <= wr_data_pci;
                        end case;
                    elsif (irdy_latched='0') then --second_clock_pci='0'
                      trdy  <= '0';
                    end if;

                --********** Mem Read STATE ********** 
                when ST_MEMREAD =>   --state 100
                   second_clock_pci <= '1';
                   --initialize wishbone read:
                   if (second_clock_pci='0' ) then
                        wb_address_feed(21 downto 0) <= pci_address (23 downto 2);
                        wb_address_feed(31 downto 22) <= (others => '0');
                        start_read_wb0 <= '1';
                        data <= wb_dat_i_latched;
                   else
                        start_read_wb0 <= '0';
                   end if;
                   if (pci_address_previous = pci_address_readonly) then
                       assert_stop  <= '0';
                   else
                       assert_stop  <= '1';
                   end if;
                   if (second_clock_pci='1' and irdy_latched='0') then
                        --pci signals:
                        ad  <= data;
                        par  <= data_par;
                        pci_state <= ST_HOLD;
                        if (assert_stop = '1') then --terminate with retry
                          stop  <= '0';
                          trdy  <= 'Z';
                        else                        --terminate with data
                          stop  <= 'Z';
                          trdy  <= '0';
                          pci_address_readonly <=   (others => '1'); --so next time it will reqest a retry again
                        end if;
                   end if;

                --********** Mem Write STATE **********     				 
                when ST_MEMWRITE =>   --state 101
                    if (second_clock_pci='0' and irdy_latched='0') then
                        wr_data_pci <= ad;
                        second_clock_pci <= '1';
                    end if;
                    --finishing off:
                    if (second_clock_pci='1') then
                        --pci signals:
                        devsel  <= '1';
                        trdy  <= '1';
                        stop  <= '1';
                        pci_state <= ST_HOLD;
                        --set the awishbone bus to go
                        start_write_wb0 <= '1';
                        wb_address_feed(21 downto 0) <= pci_address (23 downto 2);
                        wb_address_feed(31 downto 22) <= (others => '0');
                        wb_dat_o_feed <= wr_data_pci;
                    elsif (irdy_latched='0') then --second_clock_pci='0'
                      trdy  <= '0';
                    end if;

                --********** busy STATE **********
                --this is left over from the original PCI core
                when ST_BUSY =>   --state 010
                    pci_state <= ST_IDLE; --go to state 0

                --********** HOLD STATE **********     				 
                when ST_HOLD =>   --state 001
                    pci_state <= ST_IDLE; --go to state 0
                    trdy  <= '1';
                    devsel  <= '1';
                    stop  <= '1';
                    start_write_wb0 <= '0';
                                        						  
                when others => --error
                      pci_state <= ST_IDLE; --go to state 0
              end case;     
       end if;        
    end if;
    end process; --pci statemachine ends here











-- some PCI glue logic: -------------------------------------------------

    --parity:
    data_par <= (data(31) xor data(30) xor data(29) xor data(28)) xor
                    (data(27) xor data(26) xor data(25) xor data(24)) xor
                    (data(23) xor data(22) xor data(21) xor data(20)) xor
                    (data(19) xor data(18) xor data(17) xor data(16)) xor
                    (data(15) xor data(14) xor data(13) xor data(12)) xor
                    (data(11) xor data(10) xor data(9)  xor data(8))  xor
                    (data(7)  xor data(6)  xor data(5)  xor data(4))  xor
    				(cbe(3)  xor cbe(2)  xor cbe(1)  xor cbe(0))  xor
                    (data(3)  xor data(2)  xor data(1)  xor data(0)) ;




  --these are not used:
   serr  <= 'Z';
   perr <= 'Z';



    --interrupt:
	process ( reset, pciclk)
    begin
       if (reset='0') then
           inta <= 'Z';
           int_stat <= '0';
       elsif (pciclk'event and pciclk='1') then
             if (wb_irq = '1' and int_dis='0') then
               inta <= '0';
             else
               inta <= 'Z';
             end if;
             int_stat <= wb_irq;
       end if;
    end process;
    


	 --address match detection logic:
	process ( reset, pciclk )
    begin
       if (reset='0') then
           cfg_hit <= '0';
           addr_hit <= '0';
       elsif (pciclk'event and pciclk='1') then
             --config access:
             if ((cbe_latched = CFGREAD or cbe_latched = CFGWRITE) 
                 and idsel_latched='1'
                 and ad_latched(10 downto 8) = "000"
                 and ad_latched(1 downto 0) = "00") then
                  cfg_hit <= '1';
             else
                  cfg_hit <= '0';
             end if;
             --memory access:
             if ((cbe_latched = MEMREAD or cbe_latched = MEMWRITE) 
                 and memen = '1'
                 and ad_latched(31 downto 24) = baseaddr) then
                  addr_hit <= '1';
             else
                  addr_hit <= '0';
             end if;
       end if;
    end process;
    hit <= cfg_hit or addr_hit;






--end file ----------------------------------------------------------------------
end Behavioral;


