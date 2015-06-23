------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 07.07.2004 11:18:21
-- File                 : dctQidct_core_tester.vhd
-- Design               : VHDL Entity dctQidct_core_tester.beh
------------------------------------------------------------------------------
-- Description  : Tester for DCT+Quantizer+InverseQuantizer+IDCT
--
-- This tester reads test data from input file (dctQidct_test_input.txt and
-- dctQidct_quant_input.txt), and
-- feeds it to DUT. Data is fed "randomly" according to control file
-- (dctQidct_input_ctrl.txt) .
--
-- DUT outputs are collected to files (dctQidct_quant_output.txt and
-- dctQidct_idct_output.txt). Output control signal are controlled "randomly"
-- according to control files (dctQidct_output1_ctrl.txt and
-- dctQidct_output2_ctrl.txt).
-- 
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY dct;
USE dct.DCT_pkg.all;
LIBRARY idct;
USE idct.IDCT_pkg.all;
LIBRARY quantizer;
USE quantizer.Quantizer_pkg.all;
LIBRARY common_da;
LIBRARY std;
USE std.TEXTIO.all;

ENTITY dctQidct_core_tester IS
   PORT( 
      data_idct_out         : IN     std_logic_vector (IDCT_resultw_co-1 DOWNTO 0);
      data_quant_out        : IN     std_logic_vector (QUANT_resultw_co-1 DOWNTO 0);
      dct_ready4column_out  : IN     std_logic;
      wr_IDCT_out           : IN     std_logic;
      wr_Q_out              : IN     std_logic;
      QP                    : OUT    std_logic_vector (4 DOWNTO 0);
      chroma                : OUT    std_logic;
      clk                   : OUT    std_logic;
      data_dct_in           : OUT    std_logic_vector (DCT_inputw_co-1 DOWNTO 0);
      idct_ready4column_in  : OUT    std_logic;
      intra                 : OUT    std_logic;
      loadQP                : OUT    std_logic;
      quant_ready4column_in : OUT    std_logic;
      rst_n                 : OUT    std_logic;
      wr_dct_in             : OUT    std_logic
   );

-- Declarations

END dctQidct_core_tester ;

--
ARCHITECTURE beh OF dctQidct_core_tester IS
  CONSTANT period : time := 50 ns;
  --internal clock signal

  SIGNAL test_clk   : std_logic := '0';
  --internal reset signal
  SIGNAL test_rst_n : std_logic := '0';
  SIGNAL counter    : integer   := 0;

  --registered signal for DUT data input
  SIGNAL data_dct_in_r           : std_logic_vector(DCT_inputw_co-1 DOWNTO 0);
  --registerd signal for DUT wr_in
  SIGNAL wr_dct_in_r             : std_logic;
  --registered signals for DUT ready4column inputs
  SIGNAL idct_ready4column_in_r  : std_logic := '1';
  SIGNAL quant_ready4column_in_r : std_logic := '1';

  SIGNAL input_counter   : integer := 0;
  SIGNAL element_counter : integer := 0;
  SIGNAL output1_counter : integer := 8;
  SIGNAL output2_counter : integer := 8;

  -- boolean value, required for initial reset
  SIGNAL system_reseted : std_logic := '0';

  SIGNAL InputFinished       : std_logic := '0';
  SIGNAL LastQuantOutCounter : integer   := 0;
  SIGNAL LastIdctOutCounter  : integer   := 0;

  SIGNAL QP_r : std_logic_vector(4 DOWNTO 0);
  SIGNAL intra_r : std_logic;
  SIGNAL chroma_r : std_logic;
  SIGNAL loadQP_r : std_logic;
  
BEGIN

  --generate clock signal
  Clock              : PROCESS
    VARIABLE clk_tmp : std_logic := '0';
  BEGIN
    WHILE (true) LOOP
      WAIT FOR PERIOD/2;
      clk_tmp                    := NOT (clk_tmp);
      test_clk <= clk_tmp;
    END LOOP;
  END PROCESS;

  --assign to DUT clk
  clk <= test_clk;

  --generate asynchronous reset
  reset : PROCESS (test_clk)
  BEGIN  -- PROCESS reset

    IF test_clk'event AND test_clk = '1' THEN  -- rising clock edge
      IF (system_reseted = '0') THEN
        --apply reset
        test_rst_n     <= '0';
        system_reseted <= '1';
      ELSE
        test_rst_n     <= '1';
      END IF;
    END IF;
  END PROCESS reset;

  --assign to DUT rst_n
  rst_n <= test_rst_n;


  --feed input data!
  datain                : PROCESS (test_clk, test_rst_n)
    FILE File_DataIn    : text;
    FILE File_QuantIn   : text;
    FILE File_ControlIn : text;


    VARIABLE files_open : integer := 0;
    --temporary variables
    VARIABLE integerin  : integer;
    VARIABLE linein     : line;
    VARIABLE temp_data  : signed(DCT_inputw_co-1 DOWNTO 0);

  BEGIN  -- PROCESS datain
    IF (test_rst_n = '0') THEN
      QP_r <= (OTHERS => '0');
      intra_r <= '0';
      chroma_r <= '0';
      --open files
      IF (files_open = 0) THEN
        File_open(File_DataIn, "testdata/dctQidct_data_input.txt", read_mode);
        File_open(File_QuantIn, "testdata/dctQidct_quant_input.txt", read_mode);
        File_open(File_ControlIn, "testdata/dctQidct_input_ctrl.txt", read_mode);
        files_open := 1;
      END IF;

    ELSIF (test_clk = '1' AND test_clk'event) THEN
      wr_dct_in_r <= '0';

      --if end of control -file is reached, re-read it.
      IF (endfile(File_ControlIn)) THEN
        File_close(File_ControlIn);
        File_open(File_ControlIn, "testdata/dctQidct_input_ctrl.txt", read_mode);
      END IF;

      --if end of input -file is reached, test is stopped
      IF (endfile(File_DataIn)) THEN
        InputFinished <= '1';
      END IF;

      loadQP_r <= '0';                  --default assingment
      QP_r <= (OTHERS => '0');
      intra_r <= '0';
      chroma_r <= '0';
              
      IF (element_counter = 64) THEN
        --entire block has been sent. Send block information.

          IF (NOT endfile(File_QuantIn)) THEN
            READLINE(File_QuantIn, linein);

            READ(linein, integerin);    --read QP
            QP_r   <= conv_std_logic_vector(integerin, 5);

            READ(linein, integerin);    --read intra
            IF (integerin = 1) THEN
              intra_r <= '1';
            ELSE
              intra_r <= '0';
            END IF;
            
            READ(linein, integerin);    --read chroma
            IF (integerin = 1) THEN
              chroma_r <= '1';
            ELSE
              chroma_r <= '0';
            END IF;
          END IF;

          loadQP_r     <= '1';          
          element_counter <= 0;
          
      ELSIF (input_counter /= 0) THEN
        --row/column transmission is not complete. Send new data if it is available.

        --read "random" '0' or '1' from control file
        READLINE(File_ControlIn, linein);
        READ(linein, integerin);
        IF (integerin = 1) THEN
          --new data available, send data value
          IF (NOT ENDFILE(File_DataIn)) THEN
            READLINE(File_DataIn, linein);
            READ(linein, integerin);    --read data value
            data_dct_in_r   <= conv_std_logic_vector(integerin, DCT_inputw_co);
            wr_dct_in_r     <= '1';
            input_counter   <= input_counter - 1;
            element_counter <= element_counter + 1;
          END IF;
        END IF;

      ELSIF (dct_ready4column_out = '1') THEN
        --DUT is ready to receive new column/row
        input_counter <= 8;
      ELSE
        --do nothing
      END IF;
    END IF;
  END PROCESS datain;

  --assign registers to DUT input
  wr_dct_in   <= wr_dct_in_r;
  data_dct_in <= data_dct_in_r;

  QP <= QP_r;
  intra <= intra_r;
  chroma <= chroma_r;
  loadQP <= loadQP_r;
            

  dataout : PROCESS (test_clk, test_rst_n)
    --quantized output values from DUT -> file

    FILE File_QuantOut : text;
    FILE File_IdctOut  : text;
    FILE Fileout1_ctrl : text;
    FILE Fileout2_ctrl : text;

    VARIABLE files_open : integer := 0;
    --temporary variables
    VARIABLE integerout : integer;
    VARIABLE LineOut    : line;

    VARIABLE integerin : integer;
    VARIABLE linein    : line;

  BEGIN  -- PROCESS dataout

    IF (test_rst_n = '0') THEN
      --open files
      IF (files_open = 0) THEN
        File_open(File_QuantOut, "testdata/dctQidct_quantized_test_output.txt", write_mode);
        File_open(File_IdctOut, "testdata/dctQidct_idct_test_output.txt", write_mode);

        File_open(Fileout1_ctrl, "testdata/dctQidct_output1_ctrl.txt", read_mode);
        File_open(Fileout2_ctrl, "testdata/dctQidct_output2_ctrl.txt", read_mode);
        files_open := 1;
      END IF;

    ELSIF (test_clk = '1' AND test_clk'event) THEN


      --if end of control -file is reached, re-read it.
      IF (endfile(fileout1_ctrl)) THEN
        File_close(fileout1_ctrl);
        File_open(fileout1_ctrl, "testdata/dctQidct_output1_ctrl.txt", read_mode);
      END IF;

      --if end of control -file is reached, re-read it.
      IF (endfile(fileout2_ctrl)) THEN
        File_close(fileout2_ctrl);
        File_open(fileout2_ctrl, "testdata/dctQidct_output2_ctrl.txt", read_mode);
      END IF;

      ASSERT (NOT (LastIdctOutCounter = 64))
        REPORT "TEST FINISHED : Analyze output data with matlab-script 'dctQidct_analyze_vectors'"
        SEVERITY failure;

      IF (wr_Q_out = '1') THEN
        --there is valid data on quantizer output!
        IF (output1_counter /= 0) THEN
          --write it to file, if we are capable of receiving it!
          integerout := conv_integer(signed(data_quant_out));
          WRITE(LineOut, integerout, left, 6);
          WRITELINE(File_QuantOut, lineout);
          output1_counter         <= output1_counter - 1;
          quant_ready4column_in_r <= '0';

          --if last block
          IF (InputFinished = '1') THEN
            LastQuantOutCounter <= LastQuantOutCounter + 1;
          END IF;
        END IF;
      END IF;

      IF (output1_counter = 0) THEN
        --column/row is received. Check if we are ready to receive another one.

        --read random '1' or '0' from input file
        READLINE(fileout1_ctrl, linein);
        READ(linein, integerin);
        IF (integerin = 1) THEN
          quant_ready4column_in_r <= '1';
          output1_counter         <= 8;
        END IF;
      END IF;

      IF (wr_IDCT_out = '1') THEN
        --there is valid data on IDCT output
        IF (output2_counter /= 0) THEN
          --write it to file, if we are capable of receiving it!
          integerout := conv_integer(signed(data_idct_out));
          WRITE(LineOut, integerout, left, 6);
          WRITELINE(File_IdctOut, lineout);
          output2_counter        <= output2_counter - 1;
          idct_ready4column_in_r <= '0';

          --last block
          IF (LastQuantOutCounter = 64) THEN
            LastIdctOutCounter <= LastIdctOutCounter + 1;
          END IF;
        END IF;
      END IF;

      IF (output2_counter = 0) THEN
        --column/row is received. Check if we are ready to receive another one.

        --read random '1' or '0' from input file
        READLINE(fileout2_ctrl, linein);
        READ(linein, integerin);
        IF (integerin = 1) THEN
          idct_ready4column_in_r <= '1';
          output2_counter        <= 8;
        END IF;

      END IF;

    END IF;
  END PROCESS dataout;



  idct_ready4column_in  <= idct_ready4column_in_r;
  quant_ready4column_in <= quant_ready4column_in_r;

END beh;











