-- portable sine table without silicon vendor macros.
-- (c) 2005... Gerhard Hoffmann, Ulm, Germany   opencores@hoffmann-hochfrequenz.de
--
-- V1.0  2010-nov-22  published under BSD license
-- V1.1  2011-feb-08  U_rom_dly_c cosine latency was off by 1. 
-- V1.2  2001-apr-04  corrected latency of block rom
--
-- In Crawford, Frequency Synthesizer Handbook is the Sunderland technique
-- to compress the table size up to 1/12th counted in storage bits by decomposing to 2 smaller ROMs. 
-- This has not yet been expoited here. 1/50 should be possible, too.
--
-- I'm more interested in low latency because latency introduces an unwelcome 
-- dead time in wideband PLLs / phase demodulators. That also rules out the CORDIC for me.
-- As long as it fits into a reasonable amount of block rams that's ok.
--
-- TODO: BCD version, so we can do a DDS that delivers EXACTLY 10 MHz out for 100 MHz in.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity sintab is
   generic (
      pipestages: integer range 0 to 10
   );
   port (
      clk:        in  std_logic;
      ce:         in  std_logic := '1';
      rst:        in  std_logic := '0';

      theta:      in  unsigned;
      sine:       out signed
   );  
end entity sintab;



architecture rtl of sintab is


-- pipeline delay distribution. 
-- address and output stage are just conditional two's complementers/subtractors
-- The ROM will consume most of the pipeline delay. Xilinx block rams won't do
-- without some latency. During synthesis, the register balancer will shift 
-- pipe stages anyway to its taste, but at least it gets a good start.

type delaytable is array(0 to 10) of integer;

constant in_pipe:  delaytable := ( 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1);
constant adr_pipe: delaytable := ( 0, 0, 0, 1, 1, 1, 1, 2, 2, 3, 3);
constant rom_pipe: delaytable := ( 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4);
constant out_pipe: delaytable := ( 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2);

--    total delay                  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10



constant verbose:            boolean := false;

signal   piped_theta:        unsigned(theta'range);   -- pipelined input

signal   rom_address:        unsigned(theta'high-2 downto 0); 
signal   piped_rom_address:  unsigned(theta'high-2 downto 0);


signal   piped_abs_sin:      unsigned(sine'high-1 downto 0);

signal   piped_invert:       std_logic;
signal   sig_sin:            signed(sine'range);

----------------------------------------------------------------------------------------------------
--
-- The sine lookup table and how it is initialized.
--
--
-- the sine lookup table is unsigned because we store one quarter wave only.
type sintab is array (0 to (2**(theta'length-2)) -1) of unsigned(sine'length-2 downto 0);


function sine_at_middle_of_bin( bin: integer; rom_words: integer) return real is
  variable x:  real;
begin
    x := (real(bin) + 0.5) * MATH_PI / 2.0 / real(rom_words);
    return sin(x);  
end;


function init_sin(verbose: boolean; rom_words: integer; bits_per_uword: integer) return sintab is
  variable s: sintab;
  variable y: real;   
  constant scalefactor: real := real((2 ** bits_per_uword)-1);

  begin
     if verbose
     then
       report "initializing sine table:    rom_words = " 
            & integer'image(rom_words)
            & "   rom bits per unsigned word = "
            & integer'image(bits_per_uword)
            & "    scalefactor = "
            & real'image(scalefactor);
     end if;
     
     for i in 0 to rom_words-1 loop
       y := sine_at_middle_of_bin(i, rom_words);
       s(i) := to_unsigned(integer( round(y * scalefactor )), bits_per_uword);
       
       if verbose
       then
         report "i = "                & integer'image(i) 
            & "  exact sin y = "      & real'image(y)
            & "  exact scaled y = "   & real'image(y*scalefactor)
            & "  rounded int s(i) = " & integer'image( to_integer(s(i)))
            & "  error = "            & real'image(y*scalefactor - real(to_integer(s(i))))
            ;
        end if;
      end loop;
      
  return s;
end function init_sin;


-- The 'constant' is important here.  It tells the synthesizer that 
-- all the computations can be done at compile time.

constant sinrom:  sintab := init_sin(verbose, 2 ** (theta'length-2), sine'length-1);


----------------------------------------------------------------------------------------------------
--
-- convert phase input to ROM address.
--
-- theta has an address range from 0 to a little less than 2 Pi. (full circle)
-- "a little less than 2 pi" is represented as all ones.
-- The look up table goes only from 0 to a little less than 1/2 Pi. (quarter circle)
-- The two highest bits of theta determine only the quadrant
-- and are implemented by address mirroring and sign change.

-- address mirroring    hi bits      sine    cosine
-- 1st quarter wave     00           no      yes
-- 2nd quarter wave     01           yes     no
-- 3rd quarter wave     10           no      yes
-- 4th quarter wave     11           yes     no
  
function reduce_sin_address (theta: unsigned) return unsigned is

   variable quarterwave_address: unsigned(theta'high-2 downto 0);
   variable mirrored:            boolean;
   variable forward_address:     unsigned(theta'high-2 downto 0);
   variable backward_address:    unsigned(theta'high-2 downto 0);
   
begin

  -- the highest bit makes no difference on the abs. value of the sine
  -- it just negates the value if set. This is done on the output side
  -- after the ROM.
   
  mirrored := ((theta(theta'high) = '0') and (theta(theta'high-1) = '1'))  -- 2nd quadr.
           or ((theta(theta'high) = '1') and (theta(theta'high-1) = '1')); -- 4th quadr.
  
  forward_address    :=                      theta(theta'high-2 downto 0);
  backward_address   := unsigned(-1 -signed( theta(theta'high-2 downto 0)));  
  
  if mirrored then
    quarterwave_address := backward_address;
  else
    quarterwave_address := forward_address;
  end if;

  if verbose
  then
    report "theta = "                   & integer'image(to_integer(theta)) 
         & "   forward: "               & integer'image(to_integer(forward_address))
         & "   backward: "              & integer'image(to_integer(backward_address))
         & "   Quarterwave address = "  & integer'image(to_integer(quarterwave_address))
         & "   mirrored: "              & boolean'image(mirrored);
  end if;
  return quarterwave_address;
end reduce_sin_address;


begin

-- input delay stage

u_adr:	entity work.unsigned_pipestage
generic map (
  n_stages	=> in_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => theta,
  o   => piped_theta
);

----------------------------------------------------------------------------------------------------
-- propagate the information whether we will have to invert the output

u_inv:	entity work.sl_pipestage
generic map (
  n_stages	=> adr_pipe(pipestages) + rom_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => std_logic(piped_theta(piped_theta'high)),   -- sine is neg. for 2nd half of cycle
  o   => piped_invert                                -- i.e. when the highest input bit is set.
);

----------------------------------------------------------------------------------------------------
--
-- address folding with potential pipe stage
--

rom_address <= reduce_sin_address(piped_theta);

u_pip_adr:	entity work.unsigned_pipestage
generic map (
  n_stages	=> adr_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => rom_address,
  o   => piped_rom_address
);

--------------------------------------------------------------------------------
--
-- ROM access

dist_rom: if rom_pipe(pipestages) = 0
generate  -- a distributed ROM if no latency is allowed
begin
  piped_abs_sin <= sinrom(to_integer(piped_rom_address));
end generate;



block_rom: if rom_pipe(pipestages) > 0
generate 
  
  signal   abs_sin:  unsigned(sine'high-1 downto 0);

begin
  -- Xilinx XST 12.3 needs a clocked process to infer
  -- BlockRam/ROM. It does not see that it could generate block ROM 
  -- if it propagated a pipestage. 
  u_rom: process(clk) is 
  begin
    if rising_edge(clk)
    then
      abs_sin <= sinrom(to_integer(piped_rom_address));
    end if;
  end process;
 
 
  -- additional rom pipeline delay if needed
  u_rom_dly:	entity work.unsigned_pipestage
  generic map (
    n_stages	=> rom_pipe(pipestages)-1
  )
  Port map ( 
    clk => clk,
    ce  => ce,
    rst => rst,

    i   => abs_sin,
    o   => piped_abs_sin
  );
end generate;

 
--------------------------------------------------------------------------------
--
-- conditional output inversion
-- table entries are unsigned. Make them one bit larger
-- so that we have a home for the sign bit.


   sig_sin <= -signed(resize(piped_abs_sin, sine'length)) when piped_invert = '1'
          else 
               signed(resize(piped_abs_sin, sine'length));



u_2:	entity work.signed_pipestage
generic map (
  n_stages	=> out_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => sig_sin,
  o   => sine
);


END ARCHITECTURE rtl;






-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------


-- same game again for sine and cosine at the same time. 
-- Does not take more ROM bits, the ROM is just split in two
-- for the first and second part of the address range.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity sincostab is
   generic (
      pipestages: integer range 0 to 10
   );
   port (
      clk:        in  std_logic;
      ce:         in  std_logic := '1';
      rst:        in  std_logic := '0';

      theta:      in  unsigned;
      sine:       out signed;
      cosine:     out signed
   );  
end entity sincostab;



architecture rtl of sincostab is

type delaytable is array(0 to 10) of integer;

constant in_pipe:  delaytable := ( 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1);
constant adr_pipe: delaytable := ( 0, 0, 0, 1, 1, 1, 1, 2, 2, 3, 3);
constant rom_pipe: delaytable := ( 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4);
constant out_pipe: delaytable := ( 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2);

--    total delay                  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10



constant verbose:              boolean := true;

signal   piped_theta:          unsigned(theta'range);   -- pipelined input

signal   ras:                  unsigned(theta'high-2 downto 0); -- rom address for sine
signal   rac:                  unsigned(theta'high-2 downto 0); -- rom address for cos

signal   pras:                 unsigned(theta'high-2 downto 0); -- pipelined rom addresses
signal   prac:                 unsigned(theta'high-2 downto 0);

signal   piped_abs_sin:        unsigned(sine'high-1 downto 0);
signal   piped_abs_cos:        unsigned(cosine'high-1 downto 0);

signal   piped_invert_the_sin: std_logic;
signal   sig_sin:              signed(sine'range);

signal   invert_the_cos:       std_logic;
signal   piped_invert_the_cos: std_logic;
signal   sig_cos:              signed(cosine'range);

----------------------------------------------------------------------------------------------------
--
-- The sine lookup table and how it is initialized.
--
--
-- the sine lookup table is unsigned because we store one quarter wave only.

type sintab is array (0 to (2**(theta'length-3)) -1) of unsigned(sine'length-2 downto 0);



function sine_at_middle_of_bin( bin: integer; rom_words: integer) return real is
  variable x:  real;
begin
    x := (real(bin) + 0.5) * MATH_PI / 2.0 / real(rom_words);
    return sin(x);  
end;



-- initialize sine table for 0 to 44 degrees

function init_sin1(verbose: boolean; rom_words: integer; bits_per_uword: integer) return sintab is
  variable s: sintab;
  variable y: real;   
  constant scalefactor: real := real((2 ** bits_per_uword)-1);

  begin
     if verbose
     then
       report "initializing sine table:    rom_words = " 
            & integer'image(rom_words)
            & "   rom bits per unsigned word = "
            & integer'image(bits_per_uword)
            & "    scalefactor = "
            & real'image(scalefactor);
     end if;
     
     for i in 0 to (rom_words/2)-1 loop
       y := sine_at_middle_of_bin(i, rom_words);
       s(i) := to_unsigned(integer( round(y * scalefactor )), bits_per_uword);
       
       if verbose
       then
         report "i = "                & integer'image(i) 
            & "  exact sin y = "      & real'image(y)
            & "  exact scaled y = "   & real'image(y*scalefactor)
            & "  rounded int s(i) = " & integer'image( to_integer(s(i)))
            & "  error = "            & real'image(y*scalefactor - real(to_integer(s(i))))
            ;
        end if;
      end loop;
      
  return s;
end function init_sin1;



-- initialize sine table for 45 to 89 degrees

function init_sin2(verbose: boolean; rom_words: integer; bits_per_uword: integer) return sintab is
  variable s: sintab;
  variable y: real;   
  constant scalefactor: real := real((2 ** bits_per_uword)-1);

  begin
     if verbose
     then
       report "initializing sine table:    rom_words = " 
            & integer'image(rom_words)
            & "   rom bits per unsigned word = "
            & integer'image(bits_per_uword)
            & "    scalefactor = "
            & real'image(scalefactor);
     end if;
     
     for i in rom_words/2 to rom_words-1 loop
       y := sine_at_middle_of_bin(i, rom_words);
       s(i - (rom_words/2)) := to_unsigned(integer( round(y * scalefactor )), bits_per_uword);
       
       if verbose
       then
         report "i = "                & integer'image(i) 
            & "  exact sin y = "      & real'image(y)
            & "  exact scaled y = "   & real'image(y*scalefactor)
            & "  rounded int s(i) = " & integer'image( to_integer(s(i-rom_words/2)))
            & "  error = "            & real'image(y*scalefactor - real(to_integer(s(i-rom_words/2))))
            ;
        end if;
      end loop;
      
  return s;
end function init_sin2;





-- The 'constant' is important here.  It tells the synthesizer that 
-- all the computations can be done at compile time.

constant rom1:  sintab := init_sin1(verbose, 2 ** (theta'length-2), sine'length-1);
constant rom2:  sintab := init_sin2(verbose, 2 ** (theta'length-2), sine'length-1);

----------------------------------------------------------------------------------------------------
--
-- convert phase input to ROM address.
--
-- theta has an address range from 0 to a little less than 2 Pi. (full circle)
-- "a little less than 2 pi" is represented as all ones.
-- The look up table goes only from 0 to a little less than 1/2 Pi. (quarter circle)
-- The two highest bits of theta determine only the quadrant
-- and are implemented by address mirroring and sign change.

-- address mirroring    hi bits      sine    cosine
-- 1st quarter wave     00           no      yes
-- 2nd quarter wave     01           yes     no
-- 3rd quarter wave     10           no      yes
-- 4th quarter wave     11           yes     no


function reduce_sin_address (theta: unsigned) return unsigned is

   variable quarterwave_address: unsigned(theta'high-2 downto 0);
   variable mirrored:            boolean;
   variable forward_address:     unsigned(theta'high-2 downto 0);
   variable backward_address:    unsigned(theta'high-2 downto 0);
   constant verbose:             boolean := false;
   
begin

  -- the highest bit makes no difference on the abs. value of the sine
  -- it just negates the value if set. This is done on the output side
  -- after the ROM.
   
  mirrored := ((theta(theta'high) = '0') and (theta(theta'high-1) = '1'))  -- 2nd quadr.
           or ((theta(theta'high) = '1') and (theta(theta'high-1) = '1')); -- 4th quadr.
  
  forward_address    := theta(theta'high-2 downto 0);
  backward_address   := unsigned(-1 -signed( theta(theta'high-2 downto 0)));  
  
  if mirrored then
    quarterwave_address := backward_address;
  else
    quarterwave_address := forward_address;
  end if;

  if verbose
  then
    report "sin theta = "               & integer'image(to_integer(theta)) 
         & "   forward: "               & integer'image(to_integer(forward_address))
         & "   backward: "              & integer'image(to_integer(backward_address))
         & "   Quarterwave address = "  & integer'image(to_integer(quarterwave_address))
         & "   mirrored: "              & boolean'image(mirrored);
  end if;
  return quarterwave_address;
end reduce_sin_address;

 
 
function reduce_cos_address (theta: unsigned) return unsigned is

   variable quarterwave_address: unsigned(theta'high-2 downto 0);
   variable mirrored:            boolean;
   variable forward_address:     unsigned(theta'high-2 downto 0);
   variable backward_address:    unsigned(theta'high-2 downto 0);
   constant verbose:             boolean := false;
     
begin
 
  mirrored := ((theta(theta'high) = '0') and (theta(theta'high-1) = '0'))  -- 1st quadr.
           or ((theta(theta'high) = '1') and (theta(theta'high-1) = '0')); -- 3th quadr.
  
  forward_address    := theta(theta'high-2 downto 0);
  backward_address   := unsigned(-1 -signed( theta(theta'high-2 downto 0)));  
  
  if mirrored then
    quarterwave_address := backward_address;
  else
    quarterwave_address := forward_address;
  end if;

  if verbose
  then
    report "cos theta = "               & integer'image(to_integer(theta)) 
         & "   forward: "               & integer'image(to_integer(forward_address))
         & "   backward: "              & integer'image(to_integer(backward_address))
         & "   Quarterwave address = "  & integer'image(to_integer(quarterwave_address))
         & "   mirrored: "              & boolean'image(mirrored);
  end if;
  return quarterwave_address;
end reduce_cos_address;



----------------------------------------------------------------------------------------------------

BEGIN
   
   
-- this assertion might be relaxed, but I see no justification
-- for the extra testing.
   
assert sine'length = cosine'length
  report "sincostab: sine and cosine length do not match: "
       & integer'image(sine'length)
       & " vs. "
       & integer'image(cosine'length)
  severity error;
   
   
----------------------------------------------------------------------------------------------------
--
-- input delay stage

u_adr:	entity work.unsigned_pipestage
generic map (
  n_stages	=> in_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => theta,
  o   => piped_theta
);

----------------------------------------------------------------------------------------------------
-- propagate the information whether we will have to invert the output

u_invs:	entity work.sl_pipestage
generic map (
  n_stages	=> adr_pipe(pipestages) + rom_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => std_logic(piped_theta(piped_theta'high)),   -- sine is neg. for 2nd half of cycle
  o   => piped_invert_the_sin
);


invert_the_cos <= std_logic(piped_theta(piped_theta'high) xor piped_theta(piped_theta'high-1)); 

u_invc:	entity work.sl_pipestage
generic map (
  n_stages	=> adr_pipe(pipestages) + rom_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => invert_the_cos,
  o   => piped_invert_the_cos
);

----------------------------------------------------------------------------------------------------
--
-- address folding with potential pipe stage
--

ras <= reduce_sin_address(piped_theta);
rac <= reduce_cos_address(piped_theta);

u_pip_adrs:	entity work.unsigned_pipestage
generic map (
  n_stages	=> adr_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => ras,
  o   => pras
);


u_pip_adrc:	entity work.unsigned_pipestage
generic map (
  n_stages	=> adr_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => rac,
  o   => prac
);



--------------------------------------------------------------------------------
--
-- ROM access
--

distrib_rom: if rom_pipe(pipestages) = 0
generate  -- a distributed ROM if no latency is allowed
begin
 
  piped_abs_sin <= rom1(to_integer(pras(pras'high-1 downto 0))) 
                when pras(pras'high) = '0' else 
                   rom2(to_integer(pras(pras'high-1 downto 0)));

  piped_abs_cos <= rom1(to_integer(prac(prac'high-1 downto 0)))
                when prac(prac'high) = '0' else 
                   rom2(to_integer(prac(prac'high-1 downto 0)));

end generate;



block_rom: if rom_pipe(pipestages) > 0
generate 

  signal   rom_out1: unsigned(sine'high-1 downto 0);
  signal   rom_out2: unsigned(sine'high-1 downto 0);
  
  signal   abs_sin:  unsigned(sine'high-1 downto 0);  -- abs of sine at mux output
  signal   abs_cos:  unsigned(sine'high-1 downto 0);
  
begin
  -- Xilinx XST 12.3 needs a clocked process to infer BlockRam/ROM. 
  -- It does not see that it could generate block ROM if it propagated a pipestage. 
  
  u_rom: process(clk) is 
  begin 
    if rising_edge(clk)
    then
      rom_out1 <= rom1(to_integer(pras(pras'high-1 downto 0)));
      rom_out2 <= rom2(to_integer(prac(prac'high-1 downto 0)));
    end if;
  end process;

  abs_sin <= rom_out1 when pras(pras'high) = '0'
        else rom_out2;

  abs_cos <= rom_out1 when prac(prac'high) = '0'
        else rom_out2;
 
  
  -- more rom pipeline stages when needed
  u_rom_dly_s:	entity work.unsigned_pipestage
  generic map (
    n_stages	=> rom_pipe(pipestages)-1          -- 0 is allowed.
  )
  Port map ( 
    clk => clk,
    ce  => ce,
    rst => rst,
  
    i   => abs_sin,
    o   => piped_abs_sin
  );


  u_rom_dly_c:	entity work.unsigned_pipestage
  generic map (
    n_stages	=> rom_pipe(pipestages)-1
  )
  Port map ( 
    clk => clk,
    ce  => ce,
    rst => rst,
  
    i   => abs_cos,
    o   => piped_abs_cos
  );

end generate;


--------------------------------------------------------------------------------
--
-- conditional output inversion
-- table entries are unsigned. Convert them to signed and make them one bit larger
-- so that we have a home for the sign bit.

   sig_sin <= -signed(resize(piped_abs_sin, sine'length)) when piped_invert_the_sin = '1'
          else 
               signed(resize(piped_abs_sin, sine'length));


   sig_cos <= -signed(resize(piped_abs_cos, cosine'length)) when piped_invert_the_cos = '1'
          else 
               signed(resize(piped_abs_cos, cosine'length));



u_os:	entity work.signed_pipestage
generic map (
  n_stages	=> out_pipe(pipestages)
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => sig_sin,
  o   => sine
);   


u_oc:	entity work.signed_pipestage
generic map (
  n_stages	=> out_pipe(pipestages)
)
Port map (
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => sig_cos,
  o   => cosine
);

END ARCHITECTURE rtl;

-------------------------------------------------------------------------------
-- That could be driven further to 4 or even 8 phases, so that we could support
-- downconverters for 4 and 8 lane GigaSample ADCs with polyphase filters to
-- combine the lanes, without spending more on the ROM. It remains to be seen 
-- if the resulting routing congestion is worth the ROM bits conserved. 
-- But then, at these clock rates, the neccessary number of bits per bus shrinks 
-- because ADC makers have their own little problems, too ;-)
-- And it has the potential drawback for very fast frequency chirps, that the
-- instantaneous frequency jumps for groups of 8 samples at a time.
-- (Ignore these musings if you are in math or robotics!)
