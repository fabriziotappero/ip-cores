
--==========================================================================================================--
--                                                                                                          --
--  Copyright (C) 2011  by  Martin Neumann martin@neumanns-mail.de                                          --
--                                                                                                          --
--  This source file may be used and distributed without restriction provided that this copyright statement --
--  is not removed from the file and that any derivative work contains the original copyright notice and    --
--  the associated disclaimer.                                                                              --
--                                                                                                          --
--  This software is provided ''as is'' and without any express or implied warranties, including, but not   --
--  limited to, the implied warranties of merchantability and fitness for a particular purpose. In no event --
--  shall the author or contributors be liable for any direct, indirect, incidental, special, exemplary, or --
--  consequential damages (including, but not limited to, procurement of substitute goods or services; loss --
--  of use, data, or profits; or business interruption) however caused and on any theory of liability,      --
--  whether in  contract, strict liability, or tort (including negligence or otherwise) arising in any way  --
--  out of the use of this software, even if advised of the possibility of such damage.                     --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
--  File name   : usb_fs_port.vhdl                                                                         --
--  Author      : Martin Neumann  martin@neumanns-mail.de                                                   --
--  Description : Wrapper for a USB full speed slave operating at 60MHz clock frequency                     --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
-- Change history:                                                                                          --
--                                                                                                          --
--------------------------------------------------------------------------------------------------------------
-- Version:| Author:| Date:     | Comment:                                                                  --
--------------------------------------------------------------------------------------------------------------
--   1.0   | MN     |05 Mar 2011| Initial version                                                           --
--   1.1   | MN     |13 Feb 2012| added d_oe to entity, changed polarity of syncronized reset (reset_syc)   --
-- End change history                                                                                       --
--==========================================================================================================--

LIBRARY IEEE;
  USE   IEEE.std_logic_1164.all;

ENTITY usb_fs_port IS
  GENERIC (
    VENDORID        : STD_LOGIC_VECTOR(15 DOWNTO 0);
    PRODUCTID       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    VERSIONBCD      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SELFPOWERED     : BOOLEAN := FALSE;
    BUFSIZE_BITS    : INTEGER  RANGE 7 to 12 := 7);
  PORT (
    clk             : IN    STD_LOGIC;
    rst_neg_ext     : IN    STD_LOGIC;
    reset_syc       : OUT   STD_LOGIC;                                 -- RST_NEG_EXT inverted and streched to next clock
    d_pos           : INOUT STD_LOGIC;
    d_neg           : INOUT STD_LOGIC;
    d_oe            : OUT   STD_LOGIC;
    USB_rst         : OUT   STD_LOGIC;                                 -- USB reset detected (SE0 > 2.5 us)
    online          : OUT   STD_LOGIC;                                 -- High when the device is in Config state.
    RXval           : OUT   STD_LOGIC;                                 -- High if a received byte available on RXDAT.
    RXdat           : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);              -- Received data byte, valid if RXVAL is high.
    RXrdy           : IN    STD_LOGIC;                                 -- High if application is ready to receive.
    RXlen           : OUT   STD_LOGIC_VECTOR(BUFSIZE_BITS-1 DOWNTO 0); -- No of bytes available in receive buffer.
    TXval           : IN    STD_LOGIC;                                 -- High if the application has data to send.
    TXdat           : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);              -- Data byte to send, must be valid if TXVAL is high.
    TXrdy           : OUT   STD_LOGIC;                                 -- High if the entity is ready to accept the next byte.
    TXroom          : OUT   STD_LOGIC_VECTOR(BUFSIZE_BITS-1 DOWNTO 0); -- No of free bytes in transmit buffer.
    TXcork          : IN    STD_LOGIC;                                 -- Temp. suppress transmissions at the outgoing endpoint.
    FPGA_ready      : OUT   STD_LOGIC);                                -- connect FPGA_ready to the pullup resistor logic
END usb_fs_port;

ARCHITECTURE rtl OF usb_fs_port IS

  CONSTANT DriverMode    : STD_LOGIC := '1'; -- HIGH level for differential io mode (else single-ended)
  CONSTANT tx_wait       : STD_LOGIC := '0'; -- Don't suppress temporarily transmissions at the outgoing endpoint.

  SIGNAL  Phy_DataIn     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL  Phy_DataOut    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL  Phy_Linestate  : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL  Phy_Opmode     : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL  Phy_RxActive   : STD_LOGIC;
  SIGNAL  Phy_RxError    : STD_LOGIC;
  SIGNAL  Phy_RxValid    : STD_LOGIC;
  SIGNAL  Phy_Termselect : STD_LOGIC := 'L';
  SIGNAL  Phy_TxReady    : STD_LOGIC;
  SIGNAL  Phy_TxValid    : STD_LOGIC;
  SIGNAL  Phy_XcvrSelect : STD_LOGIC := 'L';
  SIGNAL  usb_rst_phy    : STD_LOGIC;
  SIGNAL  usb_rst_slv    : STD_LOGIC;
  SIGNAL  reset_int      : STD_LOGIC;
  SIGNAL  reset_tmp      : STD_LOGIC;
  SIGNAL  rxd            : STD_LOGIC;
  SIGNAL  txdn           : STD_LOGIC;
  SIGNAL  txdp           : STD_LOGIC;
  SIGNAL  txoe           : STD_LOGIC;

  FUNCTION neg(value : STD_LOGIC) RETURN STD_LOGIC IS
  BEGIN
    RETURN NOT value;
  END neg;

  FUNCTION is_valid(data : STD_LOGIC_VECTOR) RETURN BOOLEAN IS
    VARIABLE result : BOOLEAN;
  BEGIN
    result := TRUE;
    FOR i IN data'low TO data'high LOOP
      IF (data(i) ='W' OR data(i) ='Z' OR data(i) ='U' OR data(i) ='X') THEN
        result := FALSE;
      END IF;
    END LOOP;
    RETURN result;
  END is_valid;

BEGIN

  p_rst_neg : PROCESS(rst_neg_ext, clk)
  BEGIN
    IF rst_neg_ext ='0' THEN
      reset_tmp <= '1';
      reset_int <= '1';
    ELSIF clk'EVENT AND clk ='1' THEN
      reset_tmp <= NOT rst_neg_ext;
      reset_int <= reset_tmp;
    END IF;
  END PROCESS;

  reset_syc <= reset_int;

  rxd         <= d_pos AND NOT d_neg;
  usb_rst     <= usb_rst_phy OR usb_rst_slv;

  d_oe  <= NOT txoe;
  d_pos <= txdp WHEN txoe = '0' ELSE 'Z';
  d_neg <= txdn WHEN txoe = '0' ELSE 'Z';

  usb_phy_1 : ENTITY work.usb_phy       --Open Cores USB Phy, designed by Rudolf Usselmanns
  GENERIC MAP (
    usb_rst_det      => TRUE
  )
  PORT MAP (
    clk              => clk,            -- i
    rst              => neg(reset_int), -- i
    phy_tx_mode      => DriverMode,     -- i
    usb_rst          => usb_rst_phy,    -- o
    txdp             => txdp,           -- o
    txdn             => txdn,           -- o
    txoe             => txoe,           -- o
    rxd              => rxd,            -- i
    rxdp             => d_pos,          -- i
    rxdn             => d_neg,          -- i
    DataOut_i        => Phy_DataOut,    -- i (7 downto 0);
    TxValid_i        => Phy_TxValid,    -- i
    TxReady_o        => Phy_TxReady,    -- o
    DataIn_o         => Phy_DataIn,     -- o (7 downto 0);
    RxValid_o        => Phy_RxValid,    -- o
    RxActive_o       => Phy_RxActive,   -- o
    RxError_o        => Phy_RxError,    -- o
    LineState_o      => Phy_LineState   -- o (1 downto 0)
  );

  usb_serial_1 : ENTITY work.usb_serial -- Joris van Rantwijk's USB Serial
  GENERIC MAP (
    VENDORID        => VENDORID,
    PRODUCTID       => PRODUCTID,
    VERSIONBCD      => VERSIONBCD,
    HSSUPPORT       => FALSE,
    SELFPOWERED     => SELFPOWERED,
    RXBUFSIZE_BITS  => BUFSIZE_BITS,
    TXBUFSIZE_BITS  => BUFSIZE_BITS)
  PORT MAP (
    clk             => clk,              -- i 60 MHz UTMI clock.
    reset           => reset_int,        -- i Synchronous reset; clear buffers and re-attach to the bus.
    usbrst          => usb_rst_slv,      -- o High for one clock when a reset signal is detected on the USB bus.
    highspeed       => OPEN,             -- o High when the device is operating (or suspended) in high speed mode.
    suspend         => OPEN,             -- o High if device suspended, drive asynchronously the UTMI SuspendM pin.
    online          => online,           -- o High when the device is in the Configured state.
    RXval           => RXval,            -- o High if a received byte is available on RXDAT.
    RXdat           => RXdat,            -- o (7 downto 0) - Received data byte, valid if RXVAL is high.
    RXrdy           => RXrdy,            -- i High if the application is ready to receive the next byte.
    RXlen           => RXlen,            -- o (RXBUFSIZE_BITS-1  downto 0) - No of bytes available in receive buffer.
    TXval           => TXval,            -- i High if the application has data to send.
    TXdat           => TXdat,            -- i (7 downto 0) - Data byte to send, must be valid if TXVAL is high.
    TXrdy           => TXrdy,            -- o High if the entity is ready to accept the next byte.
    TXroom          => TXroom,           -- o (TXBUFSIZE_BITS-1 downto 0) - No of free bytes in transmit buffer.
    TXcork          => TXcork,           -- i Temporarily suppress transmissions at the outgoing endpoint.
    Phy_DataIn      => Phy_DataIn,       -- i (7 downto 0)
    Phy_DataOut     => Phy_DataOut,      -- o (7 downto 0)
    Phy_TxValid     => Phy_TxValid,      -- o
    Phy_TxReady     => Phy_TxReady,      -- i
    Phy_RxActive    => Phy_RxActive,     -- i
    Phy_RxValid     => Phy_RxValid,      -- i
    Phy_RxError     => Phy_RxError,      -- i
    Phy_LineState   => Phy_LineState,    -- i (1 downto 0)
    Phy_OPmode      => Phy_OPmode,       -- o (1 downto 0)     Phy_OPmode "01" -> non-driving
    Phy_xcvrselect  => OPEN,             -- o                  Phy_OPmode "00" -> normal
    Phy_termselect  => FPGA_ready,       -- o                  Phy_OPmode "10" -> disable bit stuffing
    Phy_reset       => OPEN              -- o );
  );

  p_tx_data_valid : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF TXval = '1' THEN
        ASSERT is_valid(TXdat) REPORT "USB_FS_port: TX input has invalid data" SEVERITY ERROR;
      END IF;
    END IF;
  END PROCESS;

END rtl;

