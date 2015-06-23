------------------------------------------------------------------------------
-- TUT / DCS
-------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 22.06.2004 09:26:51
-- File                 : IQuant.vhd
-- Design               : MPEG4 Quantizer / Inverse Quantizer (H263 -method)
------------------------------------------------------------------------------
-- Description  :
-- Performs MPEG4 quantization and inverse quantization (H263 -method)
--
-- Quantization is defined as follows:
-- 1) If intra frame and DC -coefficient, then
--    qcoeff(0) = coeff(0)//dc_scaler, 
--    where dc_scaler depends on QP as explained in following table
--
--                  dc_scaler
-- ---------------------------------------------------
-- QP          | 1->4  | 5->8    | 9->24   | 25->31   |           
-- ---------------------------------------------------
-- LUMINANCE   |  8    |  2*QP   | QP+8    | 2*QP-16  |
-- CHROMINANCE |  8    |     (QP+13)/2     | QP-6     |
-- ---------------------------------------------------

-- 2) If intra frame and AC -coefficient, then
-- qcoeff(i) = sign(coeff(i)) * abs(coeff(i)/(2*QP)), where i=(1->63)
-- 3) If inter frame, then
-- qcoeff(i) = sign(coeff(i)) * (abs(coeff(i))-QP/2)/(2*QP), where i=(0->63)
--
-- For intra-DC frame, qcoeff(0) is clipped to a range from 1 to 254.
-- Otherwise qcoeff(i) is clipped between -127 and 127
--
-- Inverse quantization is defined as follows:
-- 1) If intra frame and DC -coefficient, then
-- rcoeff(0) = dc_scaler*qcoeff(0)
-- 2) otherwise
-- rcoeff(i) = sign(qcoeff(i))*(QP*(2*abs(qcoeff(i)+1)), if QP is odd
-- rcoeff(i) = sign(qcoeff(i))*(QP*(2*abs(qcoeff(i)+1) - 1), if QP is even
--
-- rcoeff(i) is NOT clipped between -2048 and 2047, however if input data is
-- true output of DCT, it is not needed.
--
-- sign(x) = 0, if x=0
-- 1, if x>0
-- -1, if x<0
-- This implementation of quantizer/inverse quantizer is pipelined. It can be
-- used at data rate.
------------------------------------------------------------------------------
-- Version history:
-- 1.0 Initial version
-- 1.1 Quantizer parameter input modified.
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY quantizer;
USE quantizer.Quantizer_pkg.ALL;

ENTITY IQuant IS
  GENERIC(
    qmulw_g   :     integer := 16
    );
  PORT(
    clk       : IN  std_logic;
    rst_n     : IN  std_logic;
    --'1' if input data is to be quantized
    --as DC -coefficient
    dc        : IN  std_logic;
    --when active, loads new QP+intra+chroma into quantizer
    loadQP    : IN  std_logic;
    --as intra -coefficient
    intra     : IN  std_logic;
    --'1' if input data is to be quantized as a chrominance block
    chroma    : IN  std_logic;
    -- Quantizer parameter
    qp        : IN  std_logic_vector (4 DOWNTO 0);
    --write in
    wr_in     : IN  std_logic;
    --input coefficient
    coeff_in  : IN  std_logic_vector (QUANT_inputw_co-1 DOWNTO 0);
    --quantized coefficient
    rcoeff    : OUT std_logic_vector (IQUANT_resultw_co-1 DOWNTO 0);
    --inverse quantized coefficient
    qcoeff    : OUT std_logic_vector (QUANT_resultw_co-1 DOWNTO 0);
    --quantized coefficient write out
    q_wr_out  : OUT std_logic;
    --inverse quantized coefficient write out
    iq_wr_out : OUT std_logic
    );

-- Declarations

END IQuant;


ARCHITECTURE rtl OF IQuant IS

  --constant coefficients (1/(QP))
  TYPE Rom32x16 IS ARRAY (0 TO 31) OF unsigned(16-1 DOWNTO 0);
  CONSTANT ROM_INV_QP : Rom32x16 := (
    conv_unsigned(16384, 16),
    conv_unsigned(65535, 16),
    conv_unsigned(32768, 16),
    conv_unsigned(21845, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(13107, 16),
    conv_unsigned(10923, 16),
    conv_unsigned(9362, 16),
    conv_unsigned(8192, 16),
    conv_unsigned(7282, 16),
    conv_unsigned(6554, 16),
    conv_unsigned(5958, 16),
    conv_unsigned(5461, 16),
    conv_unsigned(5041, 16),
    conv_unsigned(4681, 16),
    conv_unsigned(4369, 16),
    conv_unsigned(4096, 16),
    conv_unsigned(3855, 16),
    conv_unsigned(3641, 16),
    conv_unsigned(3449, 16),
    conv_unsigned(3277, 16),
    conv_unsigned(3121, 16),
    conv_unsigned(2979, 16),
    conv_unsigned(2849, 16),
    conv_unsigned(2731, 16),
    conv_unsigned(2621, 16),
    conv_unsigned(2521, 16),
    conv_unsigned(2427, 16),
    conv_unsigned(2341, 16),
    conv_unsigned(2260, 16),
    conv_unsigned(2185, 16),
    conv_unsigned(2114, 16));

  --constant coefficients 2*(1/DCscaler)
  TYPE Rom64x16 IS ARRAY (0 TO 63) OF unsigned(16-1 DOWNTO 0);
  CONSTANT ROM_INV_DCSCALER : Rom64x16 := (
    conv_unsigned(0, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(13108, 16),
    conv_unsigned(10922, 16),
    conv_unsigned(9362, 16),
    conv_unsigned(8192, 16),
    conv_unsigned(7710, 16),
    conv_unsigned(7282, 16),
    conv_unsigned(6898, 16),
    conv_unsigned(6554, 16),
    conv_unsigned(6242, 16),
    conv_unsigned(5958, 16),
    conv_unsigned(5698, 16),
    conv_unsigned(5462, 16),
    conv_unsigned(5242, 16),
    conv_unsigned(5042, 16),
    conv_unsigned(4854, 16),
    conv_unsigned(4682, 16),
    conv_unsigned(4520, 16),
    conv_unsigned(4370, 16),
    conv_unsigned(4228, 16),
    conv_unsigned(4096, 16),
    conv_unsigned(3856, 16),
    conv_unsigned(3640, 16),
    conv_unsigned(3450, 16),
    conv_unsigned(3276, 16),
    conv_unsigned(3120, 16),
    conv_unsigned(2978, 16),
    conv_unsigned(2850, 16),
    conv_unsigned(0, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(16384, 16),
    conv_unsigned(14564, 16),
    conv_unsigned(14564, 16),
    conv_unsigned(13108, 16),
    conv_unsigned(13108, 16),
    conv_unsigned(11916, 16),
    conv_unsigned(11916, 16),
    conv_unsigned(10922, 16),
    conv_unsigned(10922, 16),
    conv_unsigned(10082, 16),
    conv_unsigned(10082, 16),
    conv_unsigned(9362, 16),
    conv_unsigned(9362, 16),
    conv_unsigned(8738, 16),
    conv_unsigned(8738, 16),
    conv_unsigned(8192, 16),
    conv_unsigned(8192, 16),
    conv_unsigned(7710, 16),
    conv_unsigned(7710, 16),
    conv_unsigned(7282, 16),
    conv_unsigned(7282, 16),
    conv_unsigned(6898, 16),
    conv_unsigned(6554, 16),
    conv_unsigned(6242, 16),
    conv_unsigned(5958, 16),
    conv_unsigned(5698, 16),
    conv_unsigned(5462, 16),
    conv_unsigned(5242, 16));


  --constant coefficients (DCscaler)
  TYPE Rom64x6 IS ARRAY (0 TO 63) OF unsigned(6-1 DOWNTO 0);
  CONSTANT ROM_DCSCALER : Rom64x6 := (
    conv_unsigned(0, 6),
    conv_unsigned(8, 6),
    conv_unsigned(8, 6),
    conv_unsigned(8, 6),
    conv_unsigned(8, 6),
    conv_unsigned(10, 6),
    conv_unsigned(12, 6),
    conv_unsigned(14, 6),
    conv_unsigned(16, 6),
    conv_unsigned(17, 6),
    conv_unsigned(18, 6),
    conv_unsigned(19, 6),
    conv_unsigned(20, 6),
    conv_unsigned(21, 6),
    conv_unsigned(22, 6),
    conv_unsigned(23, 6),
    conv_unsigned(24, 6),
    conv_unsigned(25, 6),
    conv_unsigned(26, 6),
    conv_unsigned(27, 6),
    conv_unsigned(28, 6),
    conv_unsigned(29, 6),
    conv_unsigned(30, 6),
    conv_unsigned(31, 6),
    conv_unsigned(32, 6),
    conv_unsigned(34, 6),
    conv_unsigned(36, 6),
    conv_unsigned(38, 6),
    conv_unsigned(40, 6),
    conv_unsigned(42, 6),
    conv_unsigned(44, 6),
    conv_unsigned(46, 6),
    conv_unsigned(0, 6),
    conv_unsigned(8, 6),
    conv_unsigned(8, 6),
    conv_unsigned(8, 6),
    conv_unsigned(8, 6),
    conv_unsigned(9, 6),
    conv_unsigned(9, 6),
    conv_unsigned(10, 6),
    conv_unsigned(10, 6),
    conv_unsigned(11, 6),
    conv_unsigned(11, 6),
    conv_unsigned(12, 6),
    conv_unsigned(12, 6),
    conv_unsigned(13, 6),
    conv_unsigned(13, 6),
    conv_unsigned(14, 6),
    conv_unsigned(14, 6),
    conv_unsigned(15, 6),
    conv_unsigned(15, 6),
    conv_unsigned(16, 6),
    conv_unsigned(16, 6),
    conv_unsigned(17, 6),
    conv_unsigned(17, 6),
    conv_unsigned(18, 6),
    conv_unsigned(18, 6),
    conv_unsigned(19, 6),
    conv_unsigned(20, 6),
    conv_unsigned(21, 6),
    conv_unsigned(22, 6),
    conv_unsigned(23, 6),
    conv_unsigned(24, 6),
    conv_unsigned(25, 6));

--registered input
  SIGNAL coeff_in_r : std_logic_vector(QUANT_inputw_co-1 DOWNTO 0);
--register DC-signal
  SIGNAL DC_r : std_logic;
  
--result of abs(2*coeff_in)
  SIGNAL abs_input   : unsigned(QUANT_inputw_co DOWNTO 0);
--registered abs_input
  SIGNAL abs_input_r : unsigned(QUANT_inputw_co DOWNTO 0);

--result of quantizer "pre-subtraction"
  SIGNAL q_pre_sub   : unsigned(QUANT_inputw_co DOWNTO 0);
--registered q_pre_sub
  SIGNAL q_pre_sub_r : unsigned(QUANT_inputw_co DOWNTO 0);

  SIGNAL quantizer_multiplier   : unsigned(qmulw_g-1 DOWNTO 0);
  SIGNAL quantizer_multiplier_r : unsigned(qmulw_g-1 DOWNTO 0);

  SIGNAL invquant_multiplier   : unsigned(5 DOWNTO 0);
  SIGNAL invquant_multiplier_r : unsigned(5 DOWNTO 0);

--sign of input coefficient, sign <= sign(coeff_in)
  SIGNAL sign : std_logic;

--'1' if quantized data is zero
  SIGNAL zero_quant : std_logic;

--result of quantizer multiplication
  SIGNAL q_mul   : unsigned(QUANT_resultw_co+2 DOWNTO 0);
--registered q_mul
  SIGNAL q_mul_r : unsigned(QUANT_resultw_co+2 DOWNTO 0);

--result of clipping
  SIGNAL q_clip   : unsigned(QUANT_resultw_co-1 DOWNTO 0);
--registered q_clip
  SIGNAL q_clip_r : unsigned(QUANT_resultw_co-1 DOWNTO 0);

--result of quantizer
  SIGNAL q_result   : std_logic_vector(QUANT_resultw_co-1 DOWNTO 0);
--registered q_result
  SIGNAL q_result_r : std_logic_vector(QUANT_resultw_co-1 DOWNTO 0);


--QP loaded into input registers
  SIGNAL QP_loaded     : std_logic_vector(4 DOWNTO 0);
--chroma loaded into input register
  SIGNAL chroma_loaded : std_logic;
--intra loaded into input register
  SIGNAL intra_loaded  : std_logic;

--Active QP
  SIGNAL QP_active     : std_logic_vector(4 DOWNTO 0);
--Active chroma
  SIGNAL chroma_active : std_logic;
--Active intra
  SIGNAL intra_active  : std_logic;



--inverse of QP
  SIGNAL inv_QP : unsigned(qmulw_g-1 DOWNTO 0);

--inverse of DCscaler
  SIGNAL inv_DCscaler : unsigned(qmulw_g-1 DOWNTO 0);

--DCscaler
  SIGNAL DCscaler : unsigned(5 DOWNTO 0);

--result of of inv_quantizer multiplication
  SIGNAL iq_mul   : unsigned(IQUANT_resultw_co DOWNTO 0);
--registered iq_mul
  SIGNAL iq_mul_r : unsigned(IQUANT_resultw_co DOWNTO 0);

--result of of inv_quantizer "post-subtraction"
  SIGNAL iq_post_sub   : unsigned(IQUANT_resultw_co-1 DOWNTO 0);
--registered iq_post_sub
  SIGNAL iq_post_sub_r : unsigned(IQUANT_resultw_co-1 DOWNTO 0);

--registered rom addressess
  SIGNAL addr_inv_qp_r       : std_logic_vector(4 DOWNTO 0);
  SIGNAL addr_inv_dcscaler_r : std_logic_vector(5 DOWNTO 0);
  SIGNAL addr_DCscaler_r     : std_logic_vector(5 DOWNTO 0);

--delay lines
  SIGNAL sign_delay_r     : std_logic_vector(5 DOWNTO 0);
  SIGNAL out_delay_r      : std_logic_vector(6 DOWNTO 0);
  SIGNAL intra_dc_delay_r : std_logic_vector(4 DOWNTO 0);
  SIGNAL r_zero_delay_r   : std_logic_vector(1 DOWNTO 0);

BEGIN

  -- purpose: registered address for ROM access
  -- type   : sequential
  -- inputs : clk, addr
  -- outputs: addr_r
  address_clk : PROCESS (clk)
  BEGIN  -- PROCESS address_clk
    IF clk'event AND clk = '1' THEN     -- rising clock edge
      addr_inv_qp_r       <= QP_active;
      addr_inv_dcscaler_r <= chroma_active & QP_active;
      addr_DCscaler_r     <= chroma_active & QP_active;
    END IF;
  END PROCESS address_clk;

  clocked : PROCESS (clk, rst_n)
  BEGIN  -- PROCESS clocked
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      coeff_in_r <= (OTHERS => '0');

      abs_input_r <= (OTHERS => '0');
      q_pre_sub_r <= (OTHERS => '0');
      q_mul_r     <= (OTHERS => '0');
      q_clip_r    <= (OTHERS => '0');
      q_result_r  <= (OTHERS => '0');

      iq_mul_r      <= (OTHERS => '0');
      iq_post_sub_r <= (OTHERS => '0');

      out_delay_r      <= (OTHERS => '0');
      sign_delay_r     <= (OTHERS => '0');
      intra_dc_delay_r <= (OTHERS => '0');
      r_zero_delay_r   <= (OTHERS => '0');

      quantizer_multiplier_r <= (OTHERS => '0');
      invquant_multiplier_r  <= (OTHERS => '0');

    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      quantizer_multiplier_r <= quantizer_multiplier;
      invquant_multiplier_r  <= invquant_multiplier;

      --to decrease switching activity (=power consumption)
      --input register is hold constant when valid data is not available.
      IF (wr_in = '1') THEN
        coeff_in_r           <= coeff_in;
        DC_r <= DC;
      ELSE
        coeff_in_r           <= coeff_in_r;
        DC_r <= DC_r;
      END IF;

      --clk0
      out_delay_r(0)      <= wr_in;

      
      --clk1
      abs_input_r         <= abs_input;
      sign_delay_r(0)     <= sign;
      intra_dc_delay_r(0) <= DC_r AND intra_active;
      out_delay_r(1)      <= out_delay_r(0);

      --clk2
      q_pre_sub_r         <= q_pre_sub;
      sign_delay_r(1)     <= sign_delay_r(0);
      intra_dc_delay_r(1) <= intra_dc_delay_r(0);
      out_delay_r(2)      <= out_delay_r(1);

      --clk3
      q_mul_r             <= q_mul;
      sign_delay_r(2)     <= sign_delay_r(1);
      intra_dc_delay_r(2) <= intra_dc_delay_r(1);
      out_delay_r(3)      <= out_delay_r(2);

      --clk4
      q_clip_r            <= q_clip;
      sign_delay_r(3)     <= sign_delay_r(2);
      intra_dc_delay_r(3) <= intra_dc_delay_r(2);
      out_delay_r(4)      <= out_delay_r(3);

      --clk5
      q_result_r          <= q_result;
      iq_mul_r            <= iq_mul;
      sign_delay_r(4)     <= sign_delay_r(3);
      intra_dc_delay_r(4) <= intra_dc_delay_r(3);
      out_delay_r(5)      <= out_delay_r(4);
      r_zero_delay_r(0)   <= zero_quant;

      --clk6
      iq_post_sub_r     <= iq_post_sub;
      sign_delay_r(5)   <= sign_delay_r(4);
      out_delay_r(6)    <= out_delay_r(5);
      r_zero_delay_r(1) <= r_zero_delay_r(0);

    END IF;
  END PROCESS clocked;

  -- purpose: loads QP value when loadQP active, bypass loaded QP value to QP_
  -- active register, when DC active
  QP_loader : PROCESS (clk, rst_n)
  BEGIN  -- PROCESS QP_loader
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      QP_loaded     <= (OTHERS => '0');
      chroma_loaded <= '0';
      intra_loaded  <= '0';

      QP_active     <= (OTHERS => '0');
      chroma_active <= '0';
      intra_active  <= '0';

    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      IF (DC = '1') THEN
        QP_active     <= QP_loaded;
        chroma_active <= chroma_loaded;
        intra_active  <= intra_loaded;
      END IF;

      IF (loadQP = '1') THEN
        QP_loaded     <= QP;
        chroma_loaded <= chroma;
        intra_loaded  <= intra;
      END IF;

    END IF;
  END PROCESS QP_loader;


  qcoeff    <= q_result_r;
  Q_wr_out  <= out_delay_r(5);          --quantized value is ready after 6
                                        --clock cycles
  IQ_wr_out <= out_delay_r(6);          --inverse quantized value is ready
                                        --after 7 clock cycles


-- purpose: fetch DCscaler from ROM
  DCscaler_from_ROM  : PROCESS (addr_DCscaler_r)
    VARIABLE address : integer;
  BEGIN
    --address := conv_integer(unsigned(addr_DCscaler_r));
    address := 1; 					-- LM 12.6.2013 changed dcscaler to constant 8
	DCscaler <= ROM_DCSCALER(address);
  END PROCESS DCscaler_from_ROM;

-- purpose: fetch Inv_QP from ROM
  Inv_QP_from_ROM    : PROCESS (addr_inv_qp_r)
    VARIABLE address : integer;
  BEGIN
    address := conv_integer(unsigned(addr_inv_qp_r));
    inv_QP <= ROM_INV_QP(address);
  END PROCESS Inv_QP_from_ROM;

-- purpose: fetch Inv_dcscaler from ROM
  Inv_DCscaler_from_ROM : PROCESS (addr_inv_dcscaler_r)
    VARIABLE address    : integer;
  BEGIN
    --address := conv_integer(unsigned(addr_inv_dcscaler_r));
    address := 1; 					-- LM 12.6.2013 changed dcscaler to constant 8
	inv_DCscaler <= ROM_INV_DCSCALER(address);  
  END PROCESS Inv_DCscaler_from_ROM;


  -- purpose: datapath for MPEG4 Quantizer
  datapath_quantizer        : PROCESS (coeff_in_r, abs_input_r, q_pre_sub_r,
                                       q_mul_r, q_clip_r, intra_dc_delay_r,
                                       Inv_DCscaler, Inv_QP, sign_delay_r,
                                       QP_active,
                                       intra_active, quantizer_multiplier_r)
    VARIABLE temp_input     : signed(QUANT_inputw_co DOWNTO 0);
    VARIABLE pre_subtracted : unsigned(QUANT_inputw_co+1 DOWNTO 0);
    VARIABLE pre_subtractor : unsigned(QUANT_inputw_co+1 DOWNTO 0);
    VARIABLE pre_sub_result : unsigned(QUANT_inputw_co+1 DOWNTO 0);

    VARIABLE temp_clip   : unsigned(QUANT_resultw_co+2 DOWNTO 0);
    VARIABLE temp_result : signed(QUANT_resultw_co-1 DOWNTO 0);
    VARIABLE temp_mul    : unsigned(QUANT_inputw_co+qmulw_g DOWNTO 0);
  BEGIN  -- PROCESS datapath_quantizer

-------------------------------------------------------------------------------
-- PIPELINE STAGE 1
-- take absolute value from input, and multiply it by two
-------------------------------------------------------------------------------
    --sign of input coefficient
    sign <= coeff_in_r(QUANT_inputw_co-1);

    temp_input := conv_signed(signed(coeff_in_r), QUANT_inputw_co+1);
    --multiply input by 2
    temp_input := SHL(temp_input, conv_unsigned(1, 1));
    --take absolute value
    abs_input <= conv_unsigned(ABS(temp_input), QUANT_inputw_co+1);

-------------------------------------------------------------------------------
-- PIPELINE STAGE 2
-- if inter frame subtract QP from result of previous stage
-- if intra frame, do nothing
-------------------------------------------------------------------------------
    IF (intra_active = '0') THEN
      --if INTER frame, subtract QP from 2*coeff_in
      pre_subtractor := conv_unsigned(unsigned(QP_active), QUANT_inputw_co+2);
    ELSE
      --if INTRA frame, subtract nothing
      pre_subtractor := (OTHERS => '0');
    END IF;

    --add one bit to left
    pre_subtracted := conv_unsigned(abs_input_r, QUANT_inputw_co+2);
    pre_sub_result := pre_subtracted - pre_subtractor;

    IF (pre_sub_result(QUANT_inputw_co+1) = '1') THEN
      --if pre_subtracted < pre_subtractor
      q_pre_sub <= (OTHERS => '0');
    ELSE
      q_pre_sub <= pre_sub_result(QUANT_inputw_co DOWNTO 0);
    END IF;



-------------------------------------------------------------------------------
-- PIPELINE STAGE 3
-- multiply result from previous stage with inverse of QP or DCscaler
-------------------------------------------------------------------------------

    --choose quantizer_multiplier
    IF (intra_dc_delay_r(0) = '1') THEN
      quantizer_multiplier <= Inv_DCscaler;
    ELSE
      quantizer_multiplier <= Inv_QP;
    END IF;

    temp_mul := quantizer_multiplier_r * q_pre_sub_r;
    --remove fraction point, and divide by two
    temp_mul := SHR(temp_mul, conv_unsigned(qmulw_g+1, 5));
    q_mul <= temp_mul(QUANT_resultw_co+2 DOWNTO 0);

-------------------------------------------------------------------------------
-- PIPELINE STAGE 4
-- Clip result to specified range
-------------------------------------------------------------------------------
    temp_clip := q_mul_r;

    IF (intra_dc_delay_r(2) = '1') THEN
      --round
      temp_clip := temp_clip + conv_unsigned(1, QUANT_resultw_co+3);
      temp_clip := SHR(temp_clip, conv_unsigned(1, 1));

      IF (temp_clip > 254) THEN
        q_clip <= conv_unsigned(254, QUANT_resultw_co);
      ELSIF (temp_clip = 0) THEN
        q_clip <= conv_unsigned(1, QUANT_resultw_co);
      ELSE
        q_clip <= conv_unsigned(temp_clip(QUANT_resultw_co-1 DOWNTO 0),
                                QUANT_resultw_co);
      END IF;

    ELSE
      --truncate instead of round
      temp_clip := SHR(temp_clip, conv_unsigned(1, 1));
      IF (temp_clip > 127) THEN
        q_clip <= conv_unsigned(127, QUANT_resultw_co);
      ELSE
        q_clip <= conv_unsigned(temp_clip(QUANT_resultw_co-1 DOWNTO 0),
                                QUANT_resultw_co);
      END IF;
    END IF;

-------------------------------------------------------------------------------
-- PIPELINE STAGE 5
-- multiply result from previous stage with sign(coeff_in)
-- check, if quantizer result is zero (and save this information)
-------------------------------------------------------------------------------
    IF (sign_delay_r(3) = '0') THEN     --positive
      q_result <= conv_std_logic_vector(q_clip_r, QUANT_resultw_co);
    ELSE
      --negative
      temp_result := signed(q_clip_r);
      temp_result := -temp_result;
      q_result <= conv_std_logic_vector(temp_result, QUANT_resultw_co);
    END IF;

    IF (q_clip_r = 0) THEN
      zero_quant <= '1';
    ELSE
      zero_quant <= '0';
    END IF;
  END PROCESS datapath_quantizer;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

  -- purpose: datapath for MPEG4 Inverse Quantizer
  datapath_invquantizer : PROCESS (q_clip_r, iq_mul_r, iq_post_sub_r,
                                   QP_active,
                                   intra_dc_delay_r, DCscaler, r_zero_delay_r,
                                   sign_delay_r, invquant_multiplier_r)

    VARIABLE temp_pre_add    : unsigned(QUANT_resultw_co DOWNTO 0);
    VARIABLE temp_mul        : unsigned(QUANT_resultw_co+6 DOWNTO 0);
    VARIABLE temp_subtractor : unsigned(IQUANT_resultw_co-1 DOWNTO 0);
    VARIABLE temp_output     : signed(IQUANT_resultw_co-1 DOWNTO 0);
  BEGIN  -- PROCESS datapath_invquantizer
-------------------------------------------------------------------------------
-- PIPELINE STAGE 1
-- Multiply input by 2.
-- If not INTRA-DC coefficient, add +1 to input,
-- Multiply with QP or DCscaler
-------------------------------------------------------------------------------
    temp_pre_add(QUANT_resultw_co DOWNTO 1) := q_clip_r;
    temp_pre_add(0)                         := NOT(intra_dc_delay_r(3));

--choose multiplier
    IF (intra_dc_delay_r(2) = '1') THEN
      invquant_multiplier <= conv_unsigned(DCscaler, 6);
    ELSE
      invquant_multiplier <= conv_unsigned(unsigned(QP_active), 6);
    END IF;

    temp_mul := invquant_multiplier_r * temp_pre_add;
    iq_mul <= temp_mul(IQUANT_resultw_co DOWNTO 0);

-------------------------------------------------------------------------------
-- PIPELINE STAGE 2
-- If QP is even, subtract by one
-------------------------------------------------------------------------------
    IF (intra_dc_delay_r(4) = '1') THEN
      --IF INTRA-DC coefficient divide by 2
      iq_post_sub <= iq_mul_r(IQUANT_resultw_co DOWNTO 1);
    ELSE
      --subtract one, if QP is even
      temp_subtractor    := (OTHERS => '0');
      temp_subtractor(0) := NOT QP_active(0);
      iq_post_sub <= iq_mul_r(IQUANT_resultw_co-1 DOWNTO 0)-temp_subtractor;
    END IF;

-------------------------------------------------------------------------------
-- PIPELINE STAGE 3
-- Multiply result with sign.
-------------------------------------------------------------------------------
    IF (r_zero_delay_r(1) = '1') THEN
      --if quantized value was zero, inverse quantized value must also be zero
      rcoeff   <= (OTHERS => '0');
    ELSE
      IF (sign_delay_r(5) = '0') THEN
        --positive
        rcoeff <= conv_std_logic_vector(iq_post_sub_r, IQUANT_resultw_co);
      ELSE
        --negative
        temp_output := signed(iq_post_sub_r);
        temp_output := -temp_output;
        rcoeff <= conv_std_logic_vector(temp_output, IQUANT_resultw_co);
      END IF;
    END IF;
  END PROCESS datapath_invquantizer;
END rtl;



