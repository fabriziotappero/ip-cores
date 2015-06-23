------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 30.06.2004 15:43:52
-- File                 : idct_fifo.vhd
-- Design               : VHDL Entity DCT_RC_DA.idct_fifo.rtl
------------------------------------------------------------------------------
-- Description  : Non-generic FIFO -buffer between Inverse quantizer and IDCT
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY idct;
USE idct.IDCT_pkg.all;

ENTITY IDCT_fifo IS
   GENERIC( 
      dataw_g      : integer := 0;
      fifo_depth_g : integer := 0
   );
   PORT( 
      clk              : IN     std_logic;
      rst_n            : IN     std_logic;
      -- input data bus
      data_in          : IN     std_logic_vector (dataw_g-1 DOWNTO 0);
      -- input status ('1' if block is capable of receiving 8 datawords)
      ready8           : OUT    std_logic;
      -- write signal for input data
      wr_in            : IN     std_logic;
      -- output data bus
      data_out         : OUT    std_logic_vector (dataw_g-1 DOWNTO 0);
      -- output status (set to '1', if next block is capable of receiving 8 datawords)
      next_block_ready : IN     std_logic;
      -- write signal for output data
      wr_out           : OUT    std_logic
   );

-- Declarations

END IDCT_fifo ;

--
ARCHITECTURE rtl OF IDCT_fifo IS
  CONSTANT max_data : integer := (2**fifo_depth_g)-1;

  --maximum datacount where ready8 is still active
  CONSTANT safe_fill : integer := max_data-8;

  TYPE FIFOram_type IS ARRAY (((2**fifo_depth_g) -1) DOWNTO 0)
    OF std_logic_vector(dataw_g-1 DOWNTO 0);
  SIGNAL FIFOram_table : FIFOram_type;  -- := (OTHERS => (OTHERS => '0'));

  SIGNAL wraddr_r : unsigned(fifo_depth_g-1 DOWNTO 0);
  SIGNAL rdaddr_r : unsigned(fifo_depth_g-1 DOWNTO 0);

  SIGNAL data_counter_r : unsigned(fifo_depth_g-1 DOWNTO 0);

  SIGNAL output_counter_r : unsigned(2 DOWNTO 0);
  SIGNAL wr_out_r         : std_logic;
  SIGNAL out_active_r     : std_logic;

BEGIN
  -- purpose: main process
  -- type   : sequential
  -- inputs : clk, rst_n
  -- outputs: 
  clocked : PROCESS (clk, rst_n)
  BEGIN  -- PROCESS clocked
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      data_counter_r <= (OTHERS => '0');
      rdaddr_r       <= (OTHERS => '0');
      wraddr_r       <= (OTHERS => '0');
      wr_out_r       <= '0';

    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge

      IF (out_active_r = '1' AND wr_in = '1') THEN
        wr_out_r       <= '1';
        data_counter_r <= data_counter_r;
        wraddr_r       <= wraddr_r + 1;
        rdaddr_r       <= rdaddr_r + 1;
      ELSIF (out_active_r = '1') THEN
        wr_out_r       <= '1';
        data_counter_r <= data_counter_r - 1;
        rdaddr_r       <= rdaddr_r + 1;
      ELSIF (wr_in = '1') THEN
        wr_out_r       <= '0';
        data_counter_r <= data_counter_r + 1;
        wraddr_r       <= wraddr_r + 1;
      ELSE
        wr_out_r       <= '0';
        data_counter_r <= data_counter_r;
      END IF;

    END IF;
  END PROCESS clocked;

  -- purpose: sends data to fifo output
  -- type   : sequential
  -- inputs : clk, rst_n
  -- outputs: 
  output_ctrl : PROCESS (clk, rst_n)
  BEGIN  -- PROCESS output_ctrl
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      out_active_r   <= '0';
      output_counter_r   <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      IF (output_counter_r /= 0 AND data_counter_r /= 0) THEN
        --send data
        out_active_r     <= '1';
        output_counter_r <= output_counter_r - 1;
      ELSIF (next_block_ready = '1' AND data_counter_r /= 0) THEN
        --begin sending if there is enough data and next block is ready
        out_active_r     <= '1';
        output_counter_r <= conv_unsigned(7, 3);
      ELSE
        out_active_r     <= '0';
        output_counter_r <= output_counter_r;
      END IF;
    END IF;
  END PROCESS output_ctrl;

  wr_out <= wr_out_r;

-- purpose: activates ready to receive signal
-- type : combinational
-- inputs : data_counter_r
-- outputs: ready8
  input_active : PROCESS (data_counter_r)
  BEGIN  -- PROCESS input
    IF (data_counter_r < safe_fill) THEN
      ready8 <= '1';
    ELSE
      ready8 <= '0';
    END IF;
  END PROCESS input_active;

-- purpose: reads data from fifo
-- type : sequential
-- inputs : clk, rst_n
-- outputs:
  data_to_output : PROCESS (clk)
  BEGIN  -- PROCESS data_to_output
    IF clk'event AND clk = '1' THEN     -- rising clock edge
      data_out <= FIFOram_table(CONV_INTEGER(unsigned(rdaddr_r)));
    END IF;
  END PROCESS data_to_output;

-- purpose: writes data to fifo
-- type : sequential
-- inputs : clk
-- outputs:
  data_to_input : PROCESS (clk)
  BEGIN  -- PROCESS data_to_input
    IF clk'event AND clk = '1' THEN     -- rising clock edge
      IF (wr_in = '1') THEN
        FIFOram_table(CONV_INTEGER(unsigned(wraddr_r))) <= data_in;
      END IF;
    END IF;
  END PROCESS data_to_input;

END rtl;






