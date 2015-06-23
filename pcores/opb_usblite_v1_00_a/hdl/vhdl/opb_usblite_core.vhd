--
--    opb_usblite - opb_uartlite replacement
--
--    opb_usblite is using components from Rudolf Usselmann see
--    http://www.opencores.org/cores/usb_phy/
--    and Joris van Rantwijk see http://www.xs4all.nl/~rjoris/fpga/usb.html
--
--    Copyright (C) 2010 Ake Rehnman
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Lesser General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Lesser General Public License for more details.
--
--    You should have received a copy of the GNU Lesser General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity OPB_USBLITE_Core is
  generic (
    C_PHYMODE :       std_logic := '1';
    C_VENDORID :      std_logic_vector(15 downto 0) := X"1234";
    C_PRODUCTID :     std_logic_vector(15 downto 0) := X"5678";
    C_VERSIONBCD :    std_logic_vector(15 downto 0) := X"0200";
    C_SELFPOWERED :   boolean := false;
    C_RXBUFSIZE_BITS: integer range 7 to 12 := 10;
    C_TXBUFSIZE_BITS: integer range 7 to 12 := 10 
    );
  port (
    Clk   : in std_logic;
    Reset : in std_logic;
    Usb_Clk : in std_logic;
    -- OPB signals
    OPB_CS : in std_logic;
    OPB_ABus : in std_logic_vector(0 to 1);
    OPB_RNW  : in std_logic;
    OPB_DBus : in std_logic_vector(7 downto 0);
    SIn_xferAck : out std_logic;
    SIn_DBus    : out std_logic_vector(7 downto 0);
    Interrupt : out std_logic;
    -- USB signals
		txdp : out std_logic;
		txdn : out std_logic;
		txoe : out std_logic;
		rxd : in std_logic;
		rxdp : in std_logic;
		rxdn : in std_logic
  );
end entity OPB_USBLITE_Core;

library unisim;
use unisim.all;

architecture akre of OPB_USBLITE_Core is

component usb_serial is

    generic (

        -- Vendor ID to report in device descriptor.
        VENDORID :      std_logic_vector(15 downto 0);

        -- Product ID to report in device descriptor.
        PRODUCTID :     std_logic_vector(15 downto 0);

        -- Product version to report in device descriptor.
        VERSIONBCD :    std_logic_vector(15 downto 0);

        -- Support high speed mode.
        HSSUPPORT :     boolean := false;

        -- Set to true if the device never draws power from the USB bus.
        SELFPOWERED :   boolean := false;

        -- Size of receive buffer as 2-logarithm of the number of bytes.
        -- Must be at least 10 (1024 bytes) for high speed support.
        RXBUFSIZE_BITS: integer range 7 to 12 := 11;

        -- Size of transmit buffer as 2-logarithm of the number of bytes.
        TXBUFSIZE_BITS: integer range 7 to 12 := 10 
    );
    
    port (

        -- 60 MHz UTMI clock.
        CLK :           in  std_logic;

        -- Synchronous reset; clear buffers and re-attach to the bus.
        RESET :         in  std_logic;

        -- High for one clock when a reset signal is detected on the USB bus.
        -- Note: do NOT wire this signal to RESET externally.
        USBRST :        out std_logic;

        -- High when the device is operating (or suspended) in high speed mode.
        HIGHSPEED :     out std_logic;

        -- High while the device is suspended.
        -- Note: This signal is not synchronized to CLK.
        -- It may be used to asynchronously drive the UTMI SuspendM pin.
        SUSPEND :       out std_logic;

        -- High when the device is in the Configured state.
        ONLINE :        out std_logic;

        -- High if a received byte is available on RXDAT.
        RXVAL :         out std_logic;

        -- Received data byte, valid if RXVAL is high.
        RXDAT :         out std_logic_vector(7 downto 0);

        -- High if the application is ready to receive the next byte.
        RXRDY :         in  std_logic;

        -- Number of bytes currently available in receive buffer.
        RXLEN :         out std_logic_vector((RXBUFSIZE_BITS-1) downto 0);

        -- High if the application has data to send.
        TXVAL :         in  std_logic;

        -- Data byte to send, must be valid if TXVAL is high.
        TXDAT :         in  std_logic_vector(7 downto 0);

        -- High if the entity is ready to accept the next byte.
        TXRDY :         out std_logic;

        -- Number of free byte positions currently available in transmit buffer.
        TXROOM :        out std_logic_vector((TXBUFSIZE_BITS-1) downto 0);

        -- Temporarily suppress transmissions at the outgoing endpoint.
        -- This gives the application an oppertunity to fill the transmit
        -- buffer in order to blast data efficiently in big chunks.
        TXCORK :        in  std_logic;

        PHY_DATAIN :    in  std_logic_vector(7 downto 0);
	      PHY_DATAOUT :   out std_logic_vector(7 downto 0);
	      PHY_TXVALID :   out std_logic;
	      PHY_TXREADY :   in  std_logic;
	      PHY_RXACTIVE :  in  std_logic;
	      PHY_RXVALID :   in  std_logic;
	      PHY_RXERROR :   in  std_logic;
	      PHY_LINESTATE : in  std_logic_vector(1 downto 0);
	      PHY_OPMODE :    out std_logic_vector(1 downto 0);
        PHY_XCVRSELECT: out std_logic;
        PHY_TERMSELECT: out std_logic;
	      PHY_RESET :     out std_logic 
	    );
  end component usb_serial;

  component usb_phy is
    port (
      clk : in std_logic;
      rst : in std_logic;
      phy_tx_mode : in std_logic;
      usb_rst : out std_logic;
	
		-- Transciever Interface
		  txdp : out std_logic;
		  txdn : out std_logic;
		  txoe : out std_logic;
		  rxd : in std_logic;
		  rxdp : in std_logic;
		  rxdn : in std_logic;

		-- UTMI Interface
		  DataOut_i : in std_logic_vector (7 downto 0);
		  TxValid_i : in std_logic;
		  TxReady_o : out std_logic;
		  RxValid_o : out std_logic;
		  RxActive_o : out std_logic;
		  RxError_o : out std_logic;
		  DataIn_o : out std_logic_vector (7 downto 0);
		  LineState_o : out std_logic_vector (1 downto 0)
    );
  end component usb_phy;
  
  constant RX_FIFO_ADR    : std_logic_vector(0 to 1) := "00";
  constant TX_FIFO_ADR    : std_logic_vector(0 to 1) := "01";
  constant STATUS_REG_ADR : std_logic_vector(0 to 1) := "10";
  constant CTRL_REG_ADR   : std_logic_vector(0 to 1) := "11";
  
  --  ADDRESS MAP
  --  ===========
  --  RX FIFO      base + $0
  --  TX FIFO      base + $4
  --  CONTROL REG  base + $8
  --  STATUS REG   base + $C


  -- Read Only
  signal status_Reg : std_logic_vector(7 downto 0);
  -- bit 0 rx_Data_Present
  -- bit 1 rx_Buffer_Full
  -- bit 2 tx_Buffer_Empty
  -- bit 3 tx_Buffer_Full
  -- bit 4 interrupt flag
  -- bit 5 not used
  -- bit 6 online flag
  -- bit 7 suspend flag  
  
  -- Write Only
  -- bit 0   Reset_TX_FIFO -- not used
  -- bit 1   Reset_RX_FIFO -- not used
  -- bit 2-3 Dont'Care
  -- bit 4   enable_rxinterrupts
  -- bit 5   Dont'Care
  -- bit 6   enable_txinterrupts
  -- bit 7   tx_enable -- not used
  
  signal enable_txinterrupts : std_logic;
  signal enable_rxinterrupts : std_logic;
  
  signal read_RX_FIFO      : std_logic;
  signal reset_RX_FIFO     : std_logic;
  signal TX_EN : std_logic;
  signal write_TX_FIFO   : std_logic;
  signal reset_TX_FIFO   : std_logic;
  signal tx_BUFFER_FULL  : std_logic;
  signal tx_Buffer_Empty : std_logic;
  signal rx_Data_Present  : std_logic;
  signal rx_BUFFER_FULL : std_logic;

  signal xfer_Ack     : std_logic;
  signal xfer_Ack1 : std_logic;
  signal xfer_Ack2 : std_logic;
  signal Interrupt_r : std_logic;
  
  signal read_rx_fifo_r : std_logic;
  signal read_rx_fifo_rr : std_logic;
  signal read_rx_fifo_rrr : std_logic;
  signal write_tx_fifo_r : std_logic;
  signal write_tx_fifo_rr : std_logic;
  signal write_tx_fifo_rrr : std_logic;

  signal usbrst : std_logic;
  signal rxval : std_logic;
  
  signal rxdat : std_logic_vector (7 downto 0);
  signal rxrdy : std_logic;
  signal txval : std_logic;
  signal txempty : std_logic;
  signal txfull : std_logic;
  signal rxfull : std_logic;
  signal txdat : std_logic_vector (7 downto 0);
  signal txrdy : std_logic;
  
  signal phy_datain : std_logic_vector (7 downto 0);
	signal phy_dataout : std_logic_vector (7 downto 0);
	signal phy_txvalid : std_logic;
	signal phy_txready : std_logic;
	signal phy_rxactive : std_logic;
	signal phy_rxvalid : std_logic;
	signal phy_rxerror : std_logic;
	signal phy_linestate : std_logic_vector (1 downto 0);
	signal phy_reset : std_logic;
	signal phy_resetn : std_logic;
	signal phy_usb_rst : std_logic;
	
  signal highspeed : std_logic;
  signal suspend : std_logic;
  signal online : std_logic;
  signal rxlen : std_logic_vector((C_RXBUFSIZE_BITS-1) downto 0);
  signal txroom : std_logic_vector((C_TXBUFSIZE_BITS-1) downto 0);
  
	attribute TIG : string; 
	attribute TIG of Reset : signal is "yes";
	attribute TIG of write_TX_FIFO : signal is "yes";
	attribute TIG of read_RX_FIFO  : signal is "yes";
	attribute TIG of rxdat : signal is "yes";
	attribute TIG of txdat : signal is "yes";
	attribute TIG of rxval : signal is "yes";
	attribute TIG of txrdy : signal is "yes";
	attribute TIG of txempty : signal is "yes";
	attribute TIG of txfull : signal is "yes";
	attribute TIG of rxfull : signal is "yes";
	
	attribute TIG of online : signal is "yes";
	attribute TIG of suspend : signal is "yes";
	
  constant C_TXFULL : std_logic_vector((C_TXBUFSIZE_BITS-1) downto 0) := (others=>'0');	
  constant C_TXEMPTY : std_logic_vector((C_TXBUFSIZE_BITS-1) downto 0) := (others=>'1');	
  constant C_RXFULL : std_logic_vector((C_RXBUFSIZE_BITS-1) downto 0) := (others=>'1');	
  constant C_RXEMPTY : std_logic_vector((C_RXBUFSIZE_BITS-1) downto 0) := (others=>'0');	
    
begin  -- architecture akre

  -----------------------------------------------------------------------------
  -- Instanciating Components
  -----------------------------------------------------------------------------
  
  usb_serial_inst : usb_serial
    generic map (
        VENDORID => C_VENDORID,
        PRODUCTID => C_PRODUCTID,
        VERSIONBCD => C_VERSIONBCD,
        HSSUPPORT => false,
        SELFPOWERED => C_SELFPOWERED,
        RXBUFSIZE_BITS => C_RXBUFSIZE_BITS,
        TXBUFSIZE_BITS => C_TXBUFSIZE_BITS
    )
    port map (
        CLK => usb_clk, --in
        RESET => reset, --in
        USBRST => usbrst, --out
        HIGHSPEED => highspeed, --out
        SUSPEND => suspend, --out
        ONLINE => online, --out
        RXVAL => rxval, --out
        RXDAT => rxdat, --out
        RXRDY => rxrdy, --in
        RXLEN => rxlen, --out
        TXVAL => txval, --in
        TXDAT => txdat, --in
        TXRDY => txrdy, --out
        TXROOM => txroom, --out
        TXCORK => '0', --in
        PHY_DATAIN => phy_datain, --in
	      PHY_DATAOUT => phy_dataout, --out
	      PHY_TXVALID => phy_txvalid, --out
	      PHY_TXREADY => phy_txready, --in
	      PHY_RXACTIVE => phy_rxactive, --in
	      PHY_RXVALID => phy_rxvalid, --in
	      PHY_RXERROR => phy_rxerror, --in
	      PHY_LINESTATE => phy_linestate, --in
	      PHY_OPMODE  => open, --out
        PHY_XCVRSELECT => open, --out
        PHY_TERMSELECT => open, --out
	      PHY_RESET => phy_reset --out
	    );

  phy_resetn <= not(phy_reset);

  usb_phy_inst : usb_phy
    port map(
      clk => Usb_Clk, --in 48MHz
      rst => phy_resetn, --in
      phy_tx_mode => C_PHYMODE, --in
      usb_rst => phy_usb_rst, --out
		  txdp => txdp, --out
		  txdn => txdn, --out
		  txoe => txoe, --out
		  rxd => rxd, --in
		  rxdp => rxdp, --in
		  rxdn => rxdn, --in
		  DataOut_i => phy_dataout, --in
		  TxValid_i => phy_txvalid, --in
		  TxReady_o => phy_txready, --out
		  RxValid_o => phy_rxvalid, --out
		  RxActive_o => phy_rxactive, --out
		  RxError_o => phy_rxerror, --out
		  DataIn_o => phy_datain, --out
		  LineState_o => phy_linestate --out
    );  
    
  -----------------------------------------------------------------------------
  -- Status register / Control register
  -----------------------------------------------------------------------------
  status_Reg(0) <= rx_Data_Present;
  status_Reg(1) <= rx_BUFFER_FULL;
  status_Reg(2) <= tx_Buffer_Empty;
  status_Reg(3) <= tx_BUFFER_FULL;
  status_Reg(4) <= Interrupt_r;
  status_Reg(5) <= '0';
  status_Reg(6) <= online;
  status_Reg(7) <= suspend;

                    
  -----------------------------------------------------------------------------
  -- Control / Status Register Handling 
  -----------------------------------------------------------------------------

  process (clk, reset) is
  begin 
    if (reset = '1') then                 -- asynchronous reset (active high)
      reset_TX_FIFO     <= '1';
      reset_RX_FIFO     <= '1';
      enable_rxinterrupts <= '0';
      enable_txinterrupts <= '0';
      TX_EN <= '0';
      xfer_Ack2 <= '0';
    elsif (clk'event and clk = '1') then  -- rising clock edge
      reset_TX_FIFO <= '0';
      reset_RX_FIFO <= '0';
      xfer_Ack2 <= '0';
      if (OPB_CS = '1') and (OPB_RNW = '0') and (OPB_ABus = CTRL_REG_ADR) then
        reset_TX_FIFO       <= OPB_DBus(0);
        reset_RX_FIFO       <= OPB_DBus(1);
        enable_rxinterrupts <= OPB_DBus(4);
        enable_txinterrupts <= OPB_DBus(6);
        TX_EN               <= OPB_DBus(7);
        xfer_Ack2 <= '1';
      end if;
      if (OPB_CS = '1') and (OPB_RNW = '1') and (OPB_ABus = STATUS_REG_ADR) then
        xfer_Ack2 <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Interrupt handling
  -----------------------------------------------------------------------------
      
  process (clk, reset)
  begin
    if reset = '1' then                 -- asynchronous reset (active high)
      Interrupt_r <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      Interrupt_r <= (enable_rxinterrupts and rx_Data_Present) or 
                     (enable_txinterrupts and tx_Buffer_Empty);
    end if;
  end process;
  
  Interrupt <= Interrupt_r;
  
  -----------------------------------------------------------------------------
  -- Handling the OPB bus interface
  -----------------------------------------------------------------------------
    
  process (clk, OPB_CS) is
  begin
    if (OPB_CS='0') then
      xfer_Ack <= '0';
      SIn_DBus <= (others => '0');
    elsif (clk'event and clk='1') then
      xfer_Ack <= xfer_Ack1 or xfer_Ack2;
      SIn_DBus <= (others => '0');
      if (OPB_RNW='1') then
        if (OPB_ABus = STATUS_REG_ADR) then
          SIn_DBus(7 downto 0) <= status_reg;
        else
          SIn_DBus(7 downto 0) <= rxdat;
        end if;
      end if;
    end if;
  end process;
  
  SIn_xferAck <= xfer_Ack;

  -----------------------------------------------------------------------------
  -- Generating read and write pulses to the FIFOs
  -----------------------------------------------------------------------------
    
  process(clk,reset)
  begin
    if (reset='1') then
      read_RX_FIFO <= '0';
      write_TX_FIFO <= '0';
      xfer_Ack1 <= '0';
    elsif (clk'event and clk='1') then
      tx_BUFFER_EMPTY <= txempty;
      tx_BUFFER_FULL <= txfull;
      rx_Data_Present <= rxval;
      rx_Buffer_Full <= rxfull;
      write_TX_FIFO <= '0';
      read_RX_FIFO <= '0';
      xfer_Ack1 <= '0';
      if (OPB_CS='1' and OPB_RNW='0' and OPB_ABus=TX_FIFO_ADR) then
        txdat <= OPB_DBus(7 downto 0);
        write_TX_FIFO <= '1';
        xfer_Ack1 <= '1';
      end if;
      if (OPB_CS='1' and OPB_RNW='1' and OPB_ABus=RX_FIFO_ADR) then
        read_RX_FIFO <= '1';
        xfer_Ack1 <= '1';
      end if;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Synchronization logic across clock domains 
  -----------------------------------------------------------------------------
    
  process(usb_clk, reset)
  begin
    if (reset='1') then
  		read_RX_FIFO_r <= '0';
  		read_RX_FIFO_rr <= '0';
  		read_RX_FIFO_rrr <= '0';
  		write_TX_FIFO_r <= '0';
  		write_TX_FIFO_rr <= '0';
  		write_TX_FIFO_rrr <= '0';
    elsif (usb_clk'event and usb_clk='1') then
      rxrdy <= '0';
      txval <= '0';
      txfull <= '0';
      rxfull <= '0';
      txfull <= '0';
      txempty <= '0';
      if (rxlen = C_RXFULL) then
        rxfull <= '1';
      end if;
      if (txroom = C_TXFULL) then
--        txfull <= '1';
        txfull <= online and not(suspend);
      end if;
      if (txroom = C_TXEMPTY) then
        txempty <= '1';
      end if;
      write_TX_FIFO_r <= write_TX_FIFO;
      write_TX_FIFO_rr <= write_TX_FIFO_r;
      write_TX_FIFO_rrr <= write_TX_FIFO_rr;
      read_RX_FIFO_r <= read_RX_FIFO;
      read_RX_FIFO_rr <= read_RX_FIFO_r;
      read_RX_FIFO_rrr <= read_RX_FIFO_rr;
      if (read_RX_FIFO_rrr='1' and read_RX_FIFO_rr='0') then
        rxrdy <= '1';
      end if;
      if (write_TX_FIFO_rrr='1' and write_TX_FIFO_rr='0') then
        txval <= '1';
      end if;      
    end if;
  end process;
  
end architecture akre;



