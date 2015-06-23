---------------------------------------------------------------------------------------------------
--
-- Title       : cfft
-- Design      : cfft
-- Author      : ZHAO Ming
-- email        : sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : cfft.vhd
-- Generated   : Thu Oct  3 03:03:58 2002
--
---------------------------------------------------------------------------------------------------
--
-- Description : radix 4 1024 point FFT input 12 bit Output 14 bit with 
--               limit and overfall processing internal
--
--              The gain is 0.0287 for FFT and 29.4 for IFFT
--
--                              The output is 4-based reversed ordered, it means
--                              a0a1a2a3a4a5a6a7a8a9 => a8a9a6a7a4a5aa2a3a0a1
--                              
--
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
--
-- port :
--                      clk : main clk          -- I have test 90M with Xilinx virtex600E
--                      rst : globe reset   -- '1' for reset
--                      start : start fft       -- one clock '1' before data input
--                      invert : '0' for fft and '1' for ifft, it is sampled when start is '1' 
--                      Iin,Qin : data input-- following start immediately, input data
--                              -- power should not be too big
--                      inputbusy : if it change to '0' then next fft is enable
--                      outdataen : when it is '1', the valid data is output
--                      Iout,Qout : fft data output when outdataen is '1'                                                                      
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :    0
-- Revision Number :    1
-- Version         :    1.1.0
-- Date            :    Oct 17 2002
-- Modifier        :    ZHAO Ming 
-- Desccription    :    Data width configurable 
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :    0
-- Revision Number :    2
-- Version         :    1.2.0
-- Date            :    Oct 18 2002
-- Modifier        :    ZHAO Ming 
-- Desccription    :    Point configurable
--                      FFT Gain                IFFT GAIN
--                               256    0.0698                  17.9
--                              1024    0.0287                  29.4
--                              4096    0.0118                  48.2742
--                   
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :    0
-- Revision Number :    3
-- Version         :    1.3.0
-- Date            :    Nov 19 2002
-- Modifier        :    ZHAO Ming 
-- Desccription    :    add output data position indication 
--                   
--
---------------------------------------------------------------------------------------------------
  
  library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.STD_LOGIC_ARITH.all;
  use IEEE.STD_LOGIC_UNSIGNED.all;

  entity cfft is
    generic (
	   Tx_nRx : natural :=1; -- tx = 1, rx = 0
      WIDTH : natural := 12;
      POINT : natural := 64;
      STAGE : natural := 3              -- STAGE=log4(POINT)
      );
    port(
      rst         : in  std_logic;
      Iin         : in  std_logic_vector(WIDTH-1 downto 0);
      Qin         : in  std_logic_vector(WIDTH-1 downto 0);
      Iout        : out std_logic_vector(WIDTH+1 downto 0);
      Qout        : out std_logic_vector(WIDTH+1 downto 0);
      factorstart : in  std_logic;
      cfft4start  : in  std_logic;

      ClkIn : in std_logic;

      sel_mux     : in std_logic;
      inv         : in std_logic;

      wen_in     : in std_logic;
      addrin_in  : in std_logic_vector(2*stage-Tx_nRx downto 0);
      addrout_in : in std_logic_vector(2*stage-Tx_nRx downto 0);

      wen_proc     : in std_logic;
      addrin_proc  : in std_logic_vector(2*stage-1 downto 0);
      addrout_proc : in std_logic_vector(2*stage-1 downto 0);

      wen_out     : in std_logic;
      addrin_out  : in std_logic_vector(2*stage-1 downto 0);
      addrout_out : in std_logic_vector(2*stage-1 downto 0));

  end cfft;


  architecture cfft of cfft is

    component mux
      generic (
        width : natural);
      port (
        inRa : in  std_logic_vector(WIDTH-1 downto 0);
        inIa : in  std_logic_vector(WIDTH-1 downto 0);
        inRb : in  std_logic_vector(WIDTH-1 downto 0);
        inIb : in  std_logic_vector(WIDTH-1 downto 0);
        outR : out std_logic_vector(WIDTH-1 downto 0);
        outI : out std_logic_vector(WIDTH-1 downto 0);

		  clk  : in  std_logic;
        sel  : in  std_logic);
    end component;

    component conj
      generic (
        width : natural);
      port (

		  inR : in  std_logic_vector(WIDTH-1 downto 0);
        inI : in  std_logic_vector(WIDTH-1 downto 0);
        outR : out std_logic_vector(WIDTH-1 downto 0);
        outI : out std_logic_vector(WIDTH-1 downto 0);

		  clk  : in  std_logic;
        conj  : in  std_logic);
    end component;

    component ram
      generic (
        width      : natural;
        depth      : natural;
        Addr_width : natural);
      port (
        clkin   : in  std_logic;
        wen     : in  std_logic;
        addrin  : in  std_logic_vector(Addr_width-1 downto 0);
        dinR    : in  std_logic_vector(width-1 downto 0);
        dinI    : in  std_logic_vector(width-1 downto 0);
        clkout  : in  std_logic;
        addrout : in  std_logic_vector(Addr_width-1 downto 0);
        doutR   : out std_logic_vector(width-1 downto 0);
        doutI   : out std_logic_vector(width-1 downto 0));
    end component;

    component cfft4
      generic (
        width : natural
        );
      port(
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
		  invert : in std_logic;
        I     : in  std_logic_vector(WIDTH-1 downto 0);
        Q     : in  std_logic_vector(WIDTH-1 downto 0);
        Iout  : out std_logic_vector(WIDTH+1 downto 0);
        Qout  : out std_logic_vector(WIDTH+1 downto 0)
        );
    end component;

    component div4limit
      generic (
        WIDTH : natural
        );
      port(
        clk : in  std_logic;
        D   : in  std_logic_vector(WIDTH+3 downto 0);
        Q   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component mulfactor
      generic (
        WIDTH : natural;
        STAGE : natural
        );
      port(
        clk   : in  std_logic;
        rst   : in  std_logic;
        angle : in  signed(2*STAGE-1 downto 0);
        I     : in  signed(WIDTH+1 downto 0);
        Q     : in  signed(WIDTH+1 downto 0);
        Iout  : out signed(WIDTH+3 downto 0);
        Qout  : out signed(WIDTH+3 downto 0)
        );
    end component;

    component rofactor
      generic (
        POINT : natural;
        STAGE : natural
        );
      port(
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
		  invert : in std_logic;
        angle : out std_logic_vector(2*STAGE-1 downto 0)
        );
    end component; 


    component blockdram
      generic (
        depth  : natural;
        Dwidth : natural;
        Awidth : natural);
      port (
        clkin   : in  std_logic;
        wen     : in  std_logic;
        addrin  : in  std_logic_vector(Awidth-1 downto 0);
        din     : in  std_logic_vector(Dwidth-1 downto 0);
        clkout  : in  std_logic;
        addrout : in  std_logic_vector(Awidth-1 downto 0);
        dout    : out std_logic_vector(Dwidth-1 downto 0));
    end component;
      
    signal MuxInRa, MuxInIa, MuxInRb, MuxInIb : std_logic_vector(WIDTH-1 downto 0)    := (others  => '0');
    signal conjInR, conjInI                   : std_logic_vector(WIDTH-1 downto 0)    := (others  => '0');      
    signal cfft4InR, cfft4InI                 : std_logic_vector(WIDTH-1 downto 0)    := (others  => '0');
    signal cfft4outR, cfft4outI               : std_logic_vector(WIDTH+1 downto 0)    := (others  => '0');
    signal MulOutR, MulOutI                   : signed(WIDTH+3 downto 0)              := (others  => '0');
    signal fftR, fftI                         : std_logic_vector(WIDTH-1 downto 0)    := (others  => '0');
    signal angle                              : std_logic_vector(2*STAGE-1 downto 0 ) := ( others => '0');
	 signal invert : std_logic;

  begin

TX:if Tx_nRx = 1 generate
    RamIn : ram
      generic map (
        width      => WIDTH,
        depth      => POINT,
        Addr_width => 2*STAGE)
      port map (
        clkin   => ClkIn,
        wen     => wen_in,
        addrin  => addrin_in,
        dinR    => Iin,
        dinI    => Qin,
        clkout  => ClkIn,
        addrout => addrout_in,
        doutR   => MuxInRa,
        doutI   => MuxInIa);

	 RamOut : ram
      generic map (
        width      => WIDTH+2,
        depth      => POINT,
        Addr_width => 2*STAGE)
      port map (
        clkin   => ClkIn,
        wen     => wen_out,
        addrin  => addrin_out,
        dinR    => cfft4outR,
        dinI    => cfft4outR,
        clkout  => ClkIn,
        addrout => addrout_out,
        doutR   => Iout,
        doutI   => open);
end generate;

RX:if Tx_nRx = 0 generate
    RamIn : ram
      generic map (
        width      => WIDTH,
        depth      => 2*POINT,
        Addr_width => 2*STAGE+1)
      port map (
        clkin   => ClkIn,
        wen     => wen_in,
        addrin  => addrin_in,
        dinR    => Iin,
        dinI    => Qin,
        clkout  => ClkIn,
        addrout => addrout_in,
        doutR   => MuxInRa,
        doutI   => open);

        MuxinIa <= (others => '0');

	 RamOut : ram
      generic map (
        width      => WIDTH+2,
        depth      => POINT,
        Addr_width => 2*STAGE)
      port map (
        clkin   => ClkIn,
        wen     => wen_out,
        addrin  => addrin_out,
        dinR    => cfft4outR,
        dinI    => cfft4outR,
        clkout  => ClkIn,
        addrout => addrout_out,
        doutR   => Iout,
        doutI   => Qout);

end generate;


    RamProc : ram
      generic map (
        width      => WIDTH,
        depth      => POINT,
        Addr_width => 2*STAGE)
      port map (
        clkin   => ClkIn,
        wen     => wen_proc,
        addrin  => addrin_proc,
        dinR    => fftR,
        dinI    => fftI,
        clkout  => ClkIn,
        addrout => addrout_proc,
        doutR   => MuxInRb,
        doutI   => MuxInIb);

    mux_1 : mux
      generic map (
        width => width)
      port map (
        inRa => MuxInRa,
        inIa => MuxInIa,
        inRb => MuxInRb,
        inIb => MuxInIb,
        outR => conjInR,
        outI => conjInI,
		  clk  => clkin,
        sel  => sel_mux);

invert <= (inv and conv_std_logic_vector(Tx_nRx,1)(0));

    conj_1: conj
      generic map (
        width => width)
      port map (

        inR   => conjInR,
        inI   => conjInI,
        outR  => cfft4InR,
        outI  => cfft4InI,
		  clk   => Clkin,
        conj  => invert);

    acfft4 : cfft4
      generic map (
        WIDTH => WIDTH
        )
      port map (
        clk   => ClkIn,
        rst   => rst,
        start => cfft4start,
		  invert => conv_std_logic_vector(Tx_nRx,1)(0),
        I     => cfft4InR,
        Q     => cfft4InI,
        Iout  => cfft4outR,
        Qout  => cfft4outI
        );

    amulfactor : mulfactor
      generic map (
        WIDTH => WIDTH,
        STAGE => STAGE
        )
      port map (
        clk   => ClkIn,
        rst   => rst,
        angle => signed(angle),
        I     => signed(cfft4outR),
        Q     => signed(cfft4outI),
        Iout  => MulOutR,
        Qout  => MulOutI
        );

    arofactor : rofactor
      generic map (
        POINT => POINT,
        STAGE => STAGE
        )
      port map (
        clk   => ClkIn,
        rst   => rst,
        start => factorstart,
		  invert => conv_std_logic_vector(Tx_nRx,1)(0), -- IFFT
        angle => angle
        );

    Rlimit : div4limit
      generic map (
        WIDTH => WIDTH
        )
      port map (
        clk => ClkIn,
        D   => std_logic_vector(MulOutR),
        Q   => fftR
        );
    Ilimit : div4limit
      generic map (
        WIDTH => WIDTH
        )
      port map (
        clk => ClkIn,
        D   => std_logic_vector(MulOutI),
        Q   => fftI
        );
    
  end cfft;
