
--==========================================================================================================--
--                                                                                                          --
--  Copyright (C) 2011  by  Martin Neumann martin@neumanns-mail.de                                          --
--                                                                                                          --
--  This source file may be used and distributed without restriction provided that this copyright statement --
--  is not removed from the file and that any derivative work contains the original copyright notice and    --
--  the associated disclaimer.                                                                              --
--                                                                                                          --
--  This software is provided ''as is'' and without any expressed or implied warranties, including, but not --
--  limited to, the implied warranties of merchantability and fitness for a particular purpose. In no event --
--  shall the author or contributors be liable for any direct, indirect, incidental, special, exemplary, or --
--  consequential damages (including, but not limited to, procurement of substitute goods or services; loss --
--  of use, data, or profits; or business interruption) however caused and on any theory of liability,      --
--  whether in  contract, strict liability, or tort (including negligence or otherwise) arising in any way  --
--  out of the use of this software, even if advised of the possibility of such damage.                     --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
--  File name   : USB_tb.vhd                                                                                --
--  Author      : Martin Neumann  martin@neumanns-mail.de                                                   --
--  Description : USB test bench - an example how to use the usb_master files together an US application.   --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
-- Change history                                                                                           --
--                                                                                                          --
-- Version / date        Description                                                                        --
--                                                                                                          --
-- 01  05 Mar 2011 MN    Initial version                                                                    --
-- 02  15 Apr 2013 MN    Simplified                                                                         --
--                                                                                                          --
-- End change history                                                                                       --
--==========================================================================================================--

LIBRARY work, IEEE;
  USE IEEE.std_logic_1164.ALL;
  USE work.usb_commands.ALL;

ENTITY usb_tb IS
END usb_tb;

ARCHITECTURE sim OF usb_tb IS

  CONSTANT BUFSIZE_BITS : Integer := 8;
  TYPE   outp_mode  IS(RECV, SEND);
  SIGNAL clk_60mhz      : STD_LOGIC;
  SIGNAL fpga_ready     : STD_LOGIC;
  SIGNAL online         : STD_LOGIC;
  SIGNAL outp_cntl      : outp_mode;
  SIGNAL outp_reg       : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL rst_neg_ext    : STD_LOGIC;
  SIGNAL reset_sync     : STD_LOGIC;
  SIGNAL rxdat          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL rxlen          : STD_LOGIC_VECTOR(BUFSIZE_BITS-1 DOWNTO 0);
  SIGNAL rxrdy          : STD_LOGIC;
  SIGNAL rxval          : STD_LOGIC;
  SIGNAL txcork         : STD_LOGIC;
  SIGNAL txdat          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL txrdy          : STD_LOGIC;
  SIGNAL txroom         : STD_LOGIC_VECTOR(BUFSIZE_BITS-1 DOWNTO 0);
  SIGNAL txval          : STD_LOGIC;
  SIGNAL usb_dn         : STD_LOGIC := 'L';
  SIGNAL usb_dp         : STD_LOGIC := 'Z'; -- allow forcing 'H', avoid 'X'
  SIGNAL usb_rst        : STD_LOGIC;

BEGIN

  p_clk_60MHz : PROCESS
  BEGIN
    clk_60MHz <= '0';
    WAIT FOR 2 ns;
    While true loop
      clk_60MHz <= '0';
      WAIT FOR 8000 ps;
      clk_60MHz <= '1';
      WAIT FOR 8667 ps; -- 60 MHz
  --  WAIT FOR 8393 ps; -- 61 MHz
  --  WAIT FOR 8949 ps; -- 59 MHz
    end loop;
  END PROCESS;

  usb_fs_master : ENTITY work.usb_fs_master
  PORT MAP (
    rst_neg_ext => rst_neg_ext,
    usb_Dp      => usb_dp,
    usb_Dn      => usb_dn
  );

  usb_dp <= 'L' WHEN reset_sync ='1' OR FPGA_ready ='0' ELSE 'H' after 10 ns;
  usb_dn <= 'L';

  usb_fs_slave_1 : ENTITY work.usb_fs_port
  GENERIC MAP(
    VENDORID        => X"FB9A",
    PRODUCTID       => X"FB9A",
    VERSIONBCD      => X"0020",
    SELFPOWERED     => FALSE,
    BUFSIZE_BITS    => BUFSIZE_BITS)
  PORT MAP(
    clk             => clk_60MHz,     -- i
    rst_neg_ext     => rst_neg_ext,   -- i
    reset_syc       => reset_sync,    -- o  positive active, streched to the next clock
    d_pos           => usb_dp,        -- io Pos USB data line
    d_neg           => usb_dn,        -- io Neg USB data line
    d_oe            => OPEN,
    USB_rst         => USB_rst,       -- o  USB reset detected (SE0 > 2.5 us)
    online          => online,        -- o  High when the device is in Config state.
    RXval           => RXval,         -- o  High if a received byte available on RXDAT.
    RXdat           => RXdat,         -- o  Received data byte, valid if RXVAL is high.
    RXrdy           => RXrdy,         -- i  High if application is ready to receive.
    RXlen           => RXlen,         -- o  No of bytes available in receive buffer.
    TXval           => TXval,         -- i  High if the application has data to send.
    TXdat           => TXdat,         -- i  Data byte to send, must be valid if TXVAL is high.
    TXrdy           => TXrdy,         -- o  High if the entity is ready to accept the next byte.
    TXroom          => TXroom,        -- o  No of free bytes in transmit buffer.
    TXcork          => TXcork,        -- i  Temp. suppress transmissions at the outgoing endpoint.
    FPGA_ready      => FPGA_ready     -- o  Connect FPGA_ready to the pullup resistor logic
  );

  TXcork     <= '0';    -- Don't hold TX transmission
  TXdat      <= outp_reg;

  simple_application : process (clk_60MHz, reset_sync)
  -- returns received bytes with twisted high - and low order nibbles --
  begin
    if reset_sync ='1' then
      outp_cntl <= RECV;
      outp_reg  <= (OTHERS => '0');
      TXval     <= '0';
      RXrdy     <= '0';
    elsif rising_edge(clk_60MHz) then
      if outp_cntl = RECV then
        TXval <= '0';
        if RXval = '1' then
          RXrdy     <= '0';
          outp_reg  <= RXdat(3 DOWNTO 0) & RXdat(7 DOWNTO 4);
          outp_cntl <= SEND;
        else
        --  RXrdy     <= online;
        RXrdy     <= '1';
          outp_cntl <= RECV;
        end if;
      else -- outp_cntl = SEND
        if TXrdy = '1' then
          TXval     <= '1';
          RXrdy     <= '1';
          outp_cntl <= RECV;
        else
          TXval     <= '0';
          RXrdy     <= '0';
          outp_cntl <= SEND;
        end if;
      end if;
    end if;
  end process;

END sim;

