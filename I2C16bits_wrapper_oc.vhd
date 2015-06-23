----------------------------------------------------------------------------------
-- Company:       University Rey Juan Carlos I - FRAV Group (www.frav.es) 
-- Engineer:      Victor Lopez Lorenzo (galland (at) opencores (dot) org)
-- 
-- Create Date:    17:46:20 12/June/2008 
-- Project Name:   I2C16bits to WISHBONE Wrapper
-- Tool versions:  Xilinx ISE 9.2i
-- Description: WISHBONE wrapper for the "I2C controller core" by Richard Herveille
--       Fully transparent I2C <-> WISHBONE operation: A WB read/write of address X
--       becomes an I2C read/write of reg. X and the I2C slave's response is sent back to the WB bus.
--       This is very useful as the raw control of the I2C controller core is very cumbersome,
--       requiring many commands to make a single I2C read/write.
--       IMPORTANT: This core makes I2C operations of 16 bits!
--
-- Dependencies: "I2C controller core" by Richard Herveille on OpenCores http://www.opencores.org/projects.cgi/web/i2c
--
-- Additional Comments: 
--
--       This core wraps the OpenCores' "I2C controller core" to virtually convert an I2C slave
--       into a WISHBONE slave, it does all the necessary I2C core's setup automatically
--       ONLY THREE CONSTANTS MUST BE CHANGED IN THIS FILE:
--          1) Set your I2C slave address constant (SLAVE_ADDR1)
--          2) Set the right prescaler constants (PRESCALER_HI and PRESCALER_LO) 
--             according to "I2C controller core" documentation: they depend on 
--             wb_clk_i and the desired I2C SCL frequency with this simple formula:
--                   prescale = (wb_clk_i /(5*desired SCL)) - 1
--                Examples:
--                    wb_clk_i = 48 MHz, desired SCL = 384 KHz -> PRESCALER_HI = 00h and PRESCALER_LO = 18h (24)
--                    wb_clk_i = 33 MHz, desired SCL = 100 KHz -> PRESCALER_HI = 00h and PRESCALER_LO = 40h (64)
--
--
--
-- LICENSE TERMS: GNU LESSER GENERAL PUBLIC LICENSE Version 2.1
--     That is you may use it in ANY project (commercial or not) without paying me a cent.
--     You are only required to include in the copyrights/about section of accompanying 
--     software and manuals of use that your system contains a "I2CWB Wrapper
--     (C) Victor Lopez Lorenzo under LGPL license"
--     This holds also in the case where you modify the core, as the resulting core
--     would be a derived work.
--     Also, for the sake of gratefulness, I would like to know if you use this core
--     in a project of yours, just an email will do ;)
--
--    Please take good note of the disclaimer section of the LPGL license, as I don't
--    take any responsability for anything that this core does.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity I2C16bits_wrapper is port (
		wb_clk_i  : in  std_logic;                    -- master clock input
		wb_rst_i  : in  std_logic := '0';             -- synchronous active high reset
      
      --WB slave
		i2c16_wb_adr_i  : in  std_logic_vector(7 downto 0); -- I2C reg number
		i2c16_wb_dat_i  : in  std_logic_vector(15 downto 0); -- I2C data to write
		i2c16_wb_dat_o  : out std_logic_vector(15 downto 0); -- I2C data read
		i2c16_wb_we_i   : in  std_logic; -- Write enable input
		i2c16_wb_stb_i  : in  std_logic; -- Strobe signals / core select signal
		i2c16_wb_cyc_i  : in  std_logic;	-- Valid bus cycle input
		i2c16_wb_ack_o  : out std_logic; -- Bus cycle acknowledge output
      i2c16_wb_err_o  : out std_logic; -- Bus cycle error output

		-- i2c lines
		scl_pad_i     : in  std_logic;                -- i2c clock line input
		scl_pad_o     : out std_logic;                -- i2c clock line output
		scl_padoen_o  : out std_logic;                -- i2c clock line output enable, active low
		sda_pad_i     : in  std_logic;                -- i2c data line input
		sda_pad_o     : out std_logic;                -- i2c data line output
		sda_padoen_o  : out std_logic);               -- i2c data line output enable, active low
end I2C16bits_wrapper;

architecture Behavioral of I2C16bits_wrapper is
   
   --higher 8 bits of prescaler for I2C master core (reg 0x01)
   constant PRESCALER_HI : std_logic_vector(7 downto 0) := x"00";
   --lower 8 bits of prescaler for I2C master core (reg 0x00):
   constant PRESCALER_LO : std_logic_vector(7 downto 0) := x"40";
   --7 bit address of I2C slave
   constant SLAVE_ADDR1 : std_logic_vector(6 downto 0) := "1001000"; 
   
  
   --I2C master core registers
   constant PRERlo : unsigned(2 downto 0) := "000";
   constant PRERhi : unsigned(2 downto 0) := "001";
   constant CTR : unsigned(2 downto 0) := "010";
   constant TXR : unsigned(2 downto 0) := "011";
   constant RXR : unsigned(2 downto 0) := "011";
   constant CR : unsigned(2 downto 0) := "100";
   constant SR : unsigned(2 downto 0) := "100";


	component i2c_master_top
		generic(ARST_LVL : std_logic := '1');                   -- asynchronous reset level
		port (
			-- wishbone signals
			wb_clk_i  : in  std_logic;                    -- master clock input
			wb_rst_i  : in  std_logic := '0';             -- synchronous active high reset
			arst_i    : in  std_logic := not ARST_LVL;    -- asynchronous reset
			wb_adr_i  : in  unsigned(2 downto 0);         -- lower address bits
			wb_dat_i  : in  std_logic_vector(7 downto 0); -- Databus input
			wb_dat_o  : out std_logic_vector(7 downto 0); -- Databus output
			wb_we_i   : in  std_logic;	              -- Write enable input
			wb_stb_i  : in  std_logic;                    -- Strobe signals / core select signal
			wb_cyc_i  : in  std_logic;	              -- Valid bus cycle input
			wb_ack_o  : out std_logic;                    -- Bus cycle acknowledge output
			wb_inta_o : out std_logic;                    -- interrupt request output signal
			-- i2c lines
			scl_pad_i     : in  std_logic;                -- i2c clock line input
			scl_pad_o     : out std_logic;                -- i2c clock line output
			scl_padoen_o  : out std_logic;                -- i2c clock line output enable, active low
			sda_pad_i     : in  std_logic;                -- i2c data line input
			sda_pad_o     : out std_logic;                -- i2c data line output
			sda_padoen_o  : out std_logic);               -- i2c data line output enable, active low
	end component i2c_master_top;
   
   --Signals for I2C core interface
	signal i2c_wb_adr  : unsigned(2 downto 0);         -- lower address bits
	signal i2c_wb_dat_i  : std_logic_vector(7 downto 0); -- Databus input
	signal i2c_wb_dat_o  : std_logic_vector(7 downto 0); -- Databus output
	signal i2c_wb_we   : std_logic;	              -- Write enable input
	signal i2c_wb_stb  : std_logic;                    -- Strobe signals / core select signal
	signal i2c_wb_cyc  : std_logic;	              -- Valid bus cycle input
	signal i2c_wb_ack  : std_logic;                    -- Bus cycle acknowledge output
   signal i2c_wb_inta  : std_logic;
   
   
   signal SLAVE_ADDR : std_logic_vector(6 downto 0);
begin
   
   
   Wishbone_slave : process (wb_clk_i, wb_rst_i)
      --Initialization of I2C master core (normal WB transfers):
      --write PRESCALER_HI in PRERhi reg (0x01)
      --write PRESCALER_LO in PRERlo reg (0x00)
      --write 80h in CTR reg (0x02) (Enable I2C core and disable interrupts)
      
      --In parenthesis: I2C master core's Wishbone regs affected (bits to set, or / to clear) TXR and CR imply write, RXR and SR imply read:
      --
      --I2C 16-bit WRITE sequence is:
      --START / send I2C slave address with WRITE bit / wait ACK (TXR, CR(STA&WR), wait SR(/RxACK&/TIP))
      --send I2C slave register to write / wait ACK (TXR, CR(WR), wait SR(/RxACK&/TIP))
      --send high 8 bits of data to write / wait ACK (TXR, CR(WR), wait SR(/RxACK&/TIP))
      --send low 8 bits of data to write / wait ACK / STOP signal (TXR, CR(WR&STO), wait SR(/RxACK&/TIP))
      --
      --I2C 16-bit READ sequence is:
      --START / send I2C slave address with WRITE bit / wait ACK (TXR, CR(STA&WR), wait SR(/RxACK&/TIP))
      --send I2C slave register to read / wait ACK (TXR, CR(WR), wait SR(/RxACK&/TIP))
      --START again / send I2C slave address with READ bit / wait ACK (TXR, CR(STA&WR), wait SR(/RxACK&/TIP))
      --receive high 8 bits of data read / send ACK (CR(RD), wait SR(/RxACK&/TIP), save high data byte from RXR)
      --receive low 8 bits of data read / send NACK / STOP signal (CR(RD&STO&ACK), wait SR(/RxACK&/TIP), save low data byte from RXR)
      --
      variable State : integer range 0 to 31;
      variable Init: integer range 0 to 3;
      variable WaitACK, WaitSR : std_logic;
      variable data : std_logic_vector(7 downto 0);
   begin
      if (wb_rst_i = '1') then
         i2c_wb_adr <= SR;
         i2c_wb_dat_i <= (others => '0');
         i2c_wb_we <= '0';
         i2c_wb_cyc <= '0';
         i2c_wb_stb <= '0';
         i2c16_wb_ack_o <= '0';
         i2c16_wb_err_o <= '0';
         i2c16_wb_dat_o <= (others => '0');
         State := 0;
         Init := 0;
         WaitACK := '0';
         WaitSR := '0'; --used to do a WB block read until RxACK and TIP bits are negated in reg SR
         data := (others => '0');
         SLAVE_ADDR <= SLAVE_ADDR1;
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         i2c16_wb_ack_o <= '0'; --only up one cycle
         --i2c16_wb_err_o <= '0';
         
         if (WaitACK = '1') then --stay here until WB ACK is received from I2C master core or until I2C transfer complete (WaitSR)
            if (i2c_wb_ack = '1') then
               if (i2c_wb_adr = SR and i2c_wb_we = '0') then --reading Status register?
                  if (i2c_wb_dat_o(5) = '1') then --error?
                     i2c16_wb_err_o <= '1';
                  else
                     i2c16_wb_err_o <= '0';
                  end if;
                  if (i2c_wb_dat_o(1) = '0') then --transfer finished?
                     WaitSR := '0';
                  end if;
               end if;               
               if (WaitSR = '0') then
                  WaitACK := '0';
                  data := i2c_wb_dat_o;
                  i2c_wb_we <= '0';
                  i2c_wb_cyc <= '0';
                  i2c_wb_stb <= '0';
               end if;
            end if;
         else
            --defaults unless overriden
            i2c_wb_we <= '1';
            i2c_wb_cyc <= '1';
            i2c_wb_stb <= '1';
            WaitACK := '1';
            WaitSR := '0';
            
            if (Init /= 3) then --initializing I2C master core
               case Init is
                  when 0 => --write prescaler's high byte (0x01)
                     i2c_wb_adr <= PRERhi;
                     i2c_wb_dat_i <= PRESCALER_HI;
                  when 1 => --write prescaler's low byte (0x00)
                     i2c_wb_adr <= PRERlo;
                     i2c_wb_dat_i <= PRESCALER_LO;
                  when others => --2 write CTR reg (0x02)
                     i2c_wb_adr <= CTR;
                     i2c_wb_dat_i <= x"80";
               end case;
               Init := Init + 1;
            else
               --I2C reg read/write
               if (i2c16_wb_cyc_i = '1' and i2c16_wb_stb_i = '1') then
                  case State is
                     --COMMON READ AND WRITE
                     when 0 => --write to TXR the slave address followed by Write bit ('0')
                        i2c_wb_adr <= TXR;
                        i2c_wb_dat_i <= SLAVE_ADDR & '0';
                        --i2c_wb_dat_i <= i2c16_wb_adr_i(6 downto 0) & '0';
                     when 1 => --write WR and STA bits to CR
                        i2c_wb_adr <= CR;
                        i2c_wb_dat_i <= "10010000";
                     when 2 => --wait for SR to negate TIP and RxACK 
                        i2c_wb_adr <= SR;
                        i2c_wb_we <= '0';
                        WaitSR := '1';
                     when 3 => --write to TXR the I2C register to read/write
                        i2c_wb_adr <= TXR;
                        i2c_wb_dat_i <= i2c16_wb_adr_i;
                        --i2c_wb_dat_i <= x"00";
                     when 4 => --write WR bit to CR
                        i2c_wb_adr <= CR;
                        i2c_wb_dat_i <= "00010000";
                     when 5 => --wait for SR to negate TIP and RxACK 
                        i2c_wb_adr <= SR;
                        i2c_wb_we <= '0';
                        WaitSR := '1';
                        
                     --COMMON STEPS CHANGING ONLY DATA FOR READ OR WRITE
                     when 6 => --write to TXR... READS: send I2C slave address with read bit or WRITES: send higher 8 bits of data
                        i2c_wb_adr <= TXR;
                        if (i2c16_wb_we_i = '1') then
                           i2c_wb_dat_i <= i2c16_wb_dat_i(15 downto 8); --write
                        else
                           i2c_wb_dat_i <= SLAVE_ADDR & '1'; --read
                           --i2c_wb_dat_i <= i2c16_wb_adr_i(6 downto 0) & '1';
                        end if;
                     when 7 => --write to CR... READS: WR and STA bits set or WRITES: WR bit set
                        i2c_wb_adr <= CR;
                        if (i2c16_wb_we_i = '1') then
                           i2c_wb_dat_i <= "00010000"; --write
                        else
                           i2c_wb_dat_i <= "10010000"; --read
                        end if;
                     when 8 => --wait for SR to negate TIP and RxACK and change State for next steps according to READ or WRITE
                        i2c_wb_adr <= SR;
                        i2c_wb_we <= '0';
                        WaitSR := '1';
                        if (i2c16_wb_we_i = '0') then
                           State := 12; --read (go to following read state minus 1, because it will be incremented after this case)
                        end if;
                     
                     --WRITE: send the lower 8 bits of data
                     when 9 => --write to TXR the lower 8 bits of data
                        i2c_wb_adr <= TXR;
                        i2c_wb_dat_i <= i2c16_wb_dat_i(7 downto 0);
                     when 10 => --write to CR with WR and STO bits set
                        i2c_wb_adr <= CR;
                        i2c_wb_dat_i <= "01010000"; --WR and STO bits
                     when 11 => --wait for SR to negate TIP and RxACK
                        i2c_wb_adr <= SR;
                        i2c_wb_we <= '0';
                        WaitSR := '1';
                     when 12 => --rise I2C16_ACK to mark operation finished
                        i2c16_wb_ack_o <= '1';
                        i2c16_wb_dat_o <= i2c16_wb_dat_i;
                        WaitACK := '0'; --override defaults
                        i2c_wb_cyc <= '0';
                        i2c_wb_stb <= '0';
                        i2c_wb_we <= '0';
                        State := 31; --go to idle state

                        
                     --READ: receive the 16 bits of data
                     when 13 => --write in CR the RD bit set
                        i2c_wb_adr <= CR;
                        i2c_wb_dat_i <= "00100000"; --RD
                     when 14 => --wait for SR to negate TIP and RxACK
                        i2c_wb_adr <= SR;
                        i2c_wb_we <= '0';
                        WaitSR := '1';
                     when 15 => --read high data byte from RXR
                        i2c_wb_adr <= RXR;
                        i2c_wb_we <= '0';
                     when 16 => --save high data byte and write in CR with the RD, STO and ACK bits set (ACK set=NACK)
                        i2c16_wb_dat_o(15 downto 8) <= data;
                        i2c_wb_adr <= CR;
                        i2c_wb_dat_i <= "01101000"; --RD,STO,ACK
                     when 17 => --wait for SR to negate TIP and RxACK
                        i2c_wb_adr <= SR;
                        i2c_wb_we <= '0';
                        WaitSR := '1';
                     when 18 => --read low data byte from RXR
                        i2c_wb_adr <= RXR;
                        i2c_wb_we <= '0';
                     when 19 => --save low data byte and write in CR to clear ACK bit
                        i2c16_wb_dat_o(7 downto 0) <= data;
                        i2c_wb_adr <= CR;
                        i2c_wb_dat_i <= "00000000"; --because the ACK/NACK bit is not autocleared by I2C master core
                     when 20 => --rise I2C16_ACK to mark operation finished
                        i2c16_wb_ack_o <= '1';
                        WaitACK := '0'; --override defaults
                        i2c_wb_cyc <= '0';
                        i2c_wb_stb <= '0';
                        i2c_wb_we <= '0';
                        State := 31; --go to idle state
                     
                     --IDLE STATE
                     when others => --31
                        --operation finished: stay here until i2c16_cyc and i2c16_stb go down so State resets itself to 0
                        i2c_wb_cyc <= '0';
                        i2c_wb_stb <= '0';
                        i2c_wb_we <= '0';
                        SLAVE_ADDR <= SLAVE_ADDR1;
                        WaitACK := '0';
                  end case;
                  if (State /= 31) then State := State + 1; end if;
               else
                  State := 0;
                  i2c16_wb_dat_o <= (others => '0');
                  --override defaults:
                  i2c_wb_cyc <= '0';
                  i2c_wb_stb <= '0';
                  i2c_wb_we <= '0';
                  WaitACK := '0';
               end if;
            end if;
         end if;
      end if;
   end process Wishbone_slave;

   
   
	----------------------------
	--	   I2C Master Core
	----------------------------
	I2CM : i2c_master_top
		generic map ('1')
		port map (
			wb_clk_i  => wb_clk_i,   -- master clock input
			wb_rst_i  => wb_rst_i,   -- synchronous active high reset
			arst_i => '0',    -- asynchronous reset
			wb_adr_i => i2c_wb_adr,	-- lower address bits
			wb_dat_i => i2c_wb_dat_i,	-- Databus input
			wb_dat_o => i2c_wb_dat_o,	-- Databus output
			wb_we_i => i2c_wb_we,	-- Write enable input
			wb_stb_i => i2c_wb_stb,	-- Strobe signals / core select signal
			wb_cyc_i => i2c_wb_cyc,	-- Valid bus cycle input
			wb_ack_o => i2c_wb_ack,	-- Bus cycle acknowledge output
			wb_inta_o => i2c_wb_inta,	-- interrupt request output signal
			scl_pad_i => scl_pad_i,	-- i2c clock line input
			scl_pad_o => scl_pad_o,	-- i2c clock line output
			scl_padoen_o => scl_padoen_o,	-- i2c clock line output enable, active low
			sda_pad_i => sda_pad_i,	-- i2c data line input
			sda_pad_o => sda_pad_o,	-- i2c data line output
			sda_padoen_o => sda_padoen_o);	-- i2c data line output enable, active low

end Behavioral;

