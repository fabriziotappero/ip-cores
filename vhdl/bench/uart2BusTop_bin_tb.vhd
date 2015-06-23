-----------------------------------------------------------------------------------------
-- uart test bench   
--
-----------------------------------------------------------------------------------------
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library work;
use work.uart2BusTop_pkg.all;
use work.helpers_pkg.all;

-----------------------------------------------------------------------------------------
-- test bench implementation 
entity uart2BusTop_bin_tb is
end uart2BusTop_bin_tb;

architecture behavior of uart2BusTop_bin_tb is

  procedure sendSerial(data : integer; baud : in real; parity : in integer; stopbit : in real; bitnumber : in integer; baudError : in real; signal txd : inout std_logic) is

    variable shiftreg : std_logic_vector(7 downto 0);
    variable bitTime  : time;

    begin
      bitTime := 1000 ms / (baud + baud * baudError / 100.0);
      shiftreg := std_logic_vector(to_unsigned(data, shiftreg'length));
      txd <= '0';
      wait for bitTime;
      for index in 0 to bitnumber loop
        txd <= shiftreg(index);
        wait for bitTime;
      end loop;
      txd <= '1';
      wait for stopbit * bitTime;
    end procedure;

  procedure recvSerial( signal rxd : in std_logic; baud : in real; parity : in integer; stopbit : in real; bitnumber : in integer; baudError : in real; signal data : inout std_logic_vector(7 downto 0)) is

    variable bitTime  : time;

    begin
      bitTime := 1000 ms / (baud + baud * baudError / 100.0);
      wait until (rxd = '0');
      wait for bitTime / 2;
      wait for bitTime;
      for index in 0 to bitnumber loop
        data <= rxd & data(7 downto 1);
        wait for bitTime;
      end loop;
      wait for stopbit * bitTime;
    end procedure;

  -- Inputs
  signal clr            : std_logic := '0';
  signal clk            : std_logic := '0';
  signal serIn          : std_logic := '0';
  signal intRdData      : std_logic_vector(7 downto 0) := (others => '0');

 	-- Outputs
  signal serOut         : std_logic;
  signal intAddress     : std_logic_vector(7 downto 0);
  signal intWrData      : std_logic_vector(7 downto 0);
  signal intWrite       : std_logic;
  signal intRead        : std_logic;
  signal recvData       : std_logic_vector(7 downto 0);
  signal newRxData      : std_logic;
  signal intAccessReq   : std_logic;
  signal intAccessGnt   : std_logic;
  signal counter        : integer;
  
  constant BAUD_115200  : real := 115200.0;
  constant BAUD_38400   : real := 38400.0;
  constant BAUD_28800   : real := 28800.0;
  constant BAUD_19200   : real := 19200.0;
  constant BAUD_9600    : real := 9600.0;
  constant BAUD_4800    : real := 4800.0;
  constant BAUD_2400    : real := 2400.0;
  constant BAUD_1200    : real := 1200.0;
  
  constant NSTOPS_1     : real := 1.0;
  constant NSTOPS_1_5   : real := 1.5;
  constant NSTOPS_2     : real := 2.0;
  
  constant PARITY_NONE  : integer := 0;
  constant PARITY_EVEN  : integer := 1;
  constant PARITY_ODD   : integer := 2;
  constant PARITY_MARK  : integer := 3;
  constant PARITY_SPACE : integer := 4;
  
  constant NBITS_7      : integer := 6;
  constant NBITS_8      : integer := 7;
  
  begin
    -- Instantiate the Unit Under Test (UUT)
    uut : uart2BusTop
      port map
      (
        clr => clr,
        clk => clk,
        serIn => serIn,
        serOut => serOut,
        intAccessReq => intAccessReq,
        intAccessGnt => intAccessGnt,
        intRdData => intRdData,
        intAddress => intAddress,
        intWrData => intWrData,
        intWrite => intWrite,
        intRead => intRead
      );

    rfm : regFileModel
    port map
    (
      clr => clr,
      clk => clk,
      intRdData => intRdData,
      intAddress => intAddress,
      intWrData => intWrData,
      intWrite => intWrite,
      intRead => intRead);

    -- just to create a delay similar to simulate a bus arbitrer
    process (clr, clk)
    begin
      if (clr = '1') then
        intAccessGnt <= '0';
        counter <= 0;
      elsif (rising_edge(clk)) then
        if (counter = 0) then
          if ((intAccessReq = '1') and (intAccessGnt = '0')) then
            counter <= 500;
          end if;
          intAccessGnt <= '0';
        elsif (counter = 1) then
          counter <= counter - 1;
          intAccessGnt <= '1';
        else
          counter <= counter - 1;
        end if;
      end if;
    end process;

    -- clock generator - 25MHz clock 
    process
    begin
      clk <= '0';
      wait for 20 ns;
      clk <= '1';
      wait for 20 ns;
    end process;

    -- reset process definitions
    process
    begin
      clr <= '1';
      wait for 40 ns;
      clr <= '0';
      wait;
    end process;

    --------------------------------------------------------------------
    -- test bench receiver 
    process

    begin
      newRxData <= '0';
      recvData <= (others => '0');
      wait until (clr = '0');
      loop
        recvSerial(serOut, BAUD_115200, PARITY_NONE, NSTOPS_1, NBITS_8, 0.0, recvData);
        newRxData <= '1';
        wait for 25 ns;
        newRxData <= '0';
      end loop;
    end process;

    --------------------------------------------------------------------
    -- uart transmit - test bench control 
    process

      type     dataFile is file of character;
      file     testBinaryFile : dataFile open READ_MODE is "../test.bin";
      variable charBuf        : character;
      variable fileLength     : integer;
      variable byteIndex      : integer;
      variable txLength       : integer;
      variable rxLength       : integer;
      variable tempLine       : line;

    begin
	  -- default value of serial output 
      serIn <= '1';
      -- binary mode simulation 
      write(tempLine, string'("Starting binary mode simulation"));
      writeline(output, tempLine);
      wait until (clr = '0');
      wait until (rising_edge(clk));
      for index in 0 to 99 loop
        wait until (rising_edge(clk));
      end loop;
	  -- in binary simulation mode the first two byte contain the file length (MSB first) 
      read(testBinaryFile, charBuf);
      fileLength := character'pos(charBuf);
      read(testBinaryFile, charBuf);
      fileLength := 256 * fileLength + character'pos(charBuf);
      write(tempLine, string'("File length: "));
      write(tempLine, fileLength);
      writeline(output, tempLine);
	  -- send entire file to uart 
      byteIndex := 0;
      while (byteIndex < fileLength) loop
        -- each "record" in the binary starts with two bytes: the first is the number 
        -- of bytes to transmit and the second is the number of received bytes to wait 
        -- for before transmitting the next command. 
        read(testBinaryFile, charBuf);
        txLength := character'pos(charBuf);
        read(testBinaryFile, charBuf);
        rxLength := character'pos(charBuf);
        write(tempLine, string'("Executing command with "));
        write(tempLine, txLength);
        write(tempLine, string'(" tx bytes and "));
        write(tempLine, rxLength);
        write(tempLine, string'(" rx bytes"));
        writeline(output, tempLine);
        byteIndex := byteIndex + 2;
		-- transmit command 
        while (txLength > 0) loop
		  -- read next byte from file and transmit it 
          read(testBinaryFile, charBuf);
          byteIndex := byteIndex + 1;
          sendSerial(character'pos(charBuf), BAUD_115200, PARITY_NONE, NSTOPS_1, NBITS_8, 0.0, serIn);
		  -- update tx_len
          txLength := txLength - 1;
        end loop;
		-- wait for received bytes
        while (rxLength > 0) loop
          wait until (newRxData = '1');
          wait until (newRxData = '0');
          rxLength := rxLength - 1;
        end loop;
        write(tempLine, string'("Command finished"));
        writeline(output, tempLine);
      end loop;
      wait;
    end process;
  end;
