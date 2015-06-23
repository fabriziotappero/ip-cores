-- <File header>
-- Project
--    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
--    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
--    The increase in speed comes from a relatively deep pipeline. The original
--    AVR core has only two pipeline stages (fetch and execute), while pAVR has
--    6 pipeline stages:
--       1. PM    (read Program Memory)
--       2. INSTR (load Instruction)
--       3. RFRD  (decode Instruction and read Register File)
--       4. OPS   (load Operands)
--       5. ALU   (execute ALU opcode or access Unified Memory)
--       6. RFWR  (write Register File)
-- Version
--    0.32
-- Date
--    2002 August 07
-- Author
--    Doru Cuturela, doruu@yahoo.com
-- License
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 2 of the License, or
--    (at your option) any later version.
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--    You should have received a copy of the GNU General Public License
--    along with this program; if not, write to the Free Software
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-- </File header>



-- <File info>
-- This is the main test entity. It embedds a pAVR controller, its Program
--    Memory and a muxer for taking/getting Program Memory access to/from pAVR.
-- This entity implements the following behavior:
--    - 1. reset all registers.
--       For the easyness of debugging, they are resetted to a particular non-zero
--       value (0x77).
--       Funny enough, the registers are initialized by pAVR itself, by providing
--       to it code for that.
--    - 2. load the Program Memory with pAVR's program.
--       This section is tagged. By using the TagScan utility, this architecture
--       is automatically modified so that an external binary file is transposed
--       into VHDL statements that load the Program Memory.
--       This section rewrites the code from the previous section (register
--       loading).
--    - 3. Finally, release the reset lines and let pAVR do its job.
-- Note
--    Care has NOT been taken not to generate latches all over these tests.
--    They ARE generated, there are even 3 state latches, for the ease of testing.
--    However, care HAS BEEN taken in pAVR sources that no latches should be
--    generated there. That is because pAVR is meant to be synthesizable, while
--    pAVR tests are not.
-- To do
--    - Afer resetting registers, but before loading binary file, pAVR executes
--       instructions that are made of Xs. It happens that the instruction decoder
--       decodes these into nops, so it's OK, but not nice. This must be corrected.
-- </File info>



-- <File body>
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;
use work.test_pavr_util.all;
use work.test_pavr_constants.all;


entity test_pavr is
end;


architecture test_pavr_arch of test_pavr is
   signal clk, res, syncres: std_logic;

   -- Clock counter
   -- Maximum number of testing clocks: 2 billions instructions. Should be enough...
   signal main_clk_cnt, run_clk_cnt: std_logic_vector(30 downto 0);

   -- Instruction counter
   signal instr_cnt: std_logic_vector(30 downto 0);

   -- Signals to control the mixture formed by pAVR, Program Memory and muxers.
   signal pm_sel:  std_logic;
   signal pm_di:   std_logic_vector(15 downto 0);
   signal pm_wr:   std_logic;
   signal pm_addr: std_logic_vector(21 downto 0);
   signal pa:      std_logic_vector(7 downto 0);

   -- pAVR controller-related connectivity
   signal pavr_pavr_res:     std_logic;
   signal pavr_pavr_syncres: std_logic;
   signal pavr_pavr_pm_addr: std_logic_vector(21 downto 0);
   signal pavr_pavr_pm_do:   std_logic_vector(15 downto 0);
   signal pavr_pavr_pm_wr:   std_logic;
   signal pavr_pavr_inc_instr_cnt: std_logic_vector(1 downto 0);

   -- PM-related connectivity
   signal pm_pavr_pm_wr:   std_logic;
   signal pm_pavr_pm_addr: std_logic_vector(21 downto 0);
   signal pm_pavr_pm_di:   std_logic_vector(15 downto 0);
   signal pm_pavr_pm_do:   std_logic_vector(15 downto 0);

   -- Declare the pAVR controller.
   component pavr
   port(
      pavr_clk:      in    std_logic;
      pavr_res:      in    std_logic;
      pavr_syncres:  in    std_logic;
      pavr_pm_addr:  out   std_logic_vector(21 downto 0);
      pavr_pm_do:    in    std_logic_vector(15 downto 0);
      pavr_pm_wr:    out   std_logic;
      pavr_pa:       inout std_logic_vector(7 downto 0);
      pavr_inc_instr_cnt: out std_logic_vector(1 downto 0)
   );
   end component;
   for all: pavr use entity work.pavr(pavr_arch);

   -- Declare the Program Memory.
   component pavr_pm
   port(
      pavr_pm_clk:  in  std_logic;
      pavr_pm_wr:   in  std_logic;
      pavr_pm_addr: in  std_logic_vector(21 downto 0);
      pavr_pm_di:   in  std_logic_vector(15 downto 0);
      pavr_pm_do:   out std_logic_vector(15 downto 0)
   );
   end component;
   for all: pavr_pm use entity work.pavr_pm(pavr_pm_arch);

begin

   -- Instantiate the pAVR controller.
   pavr_instance1: pavr
   port map(
      clk,
      pavr_pavr_res,
      pavr_pavr_syncres,
      pavr_pavr_pm_addr,
      pavr_pavr_pm_do,
      pavr_pavr_pm_wr,
      pa,
      pavr_pavr_inc_instr_cnt
   );

   -- Instantiate the Program Memory.
   pavr_pm_instance1: pavr_pm
   port map(
      clk,
      pm_pavr_pm_wr,
      pm_pavr_pm_addr,
      pm_pavr_pm_di,
      pm_pavr_pm_do
   );

   generate_clock:
   process
   begin
      clk <= '1';
      wait for 50 ns;
      clk <= '0';
      wait for 50 ns;
   end process generate_clock;


   generate_reset:
   process
   begin
      --res <= '0';
      --wait for 100 ns;
      res <= '1';
      wait for 110 ns;
      res <= '0';
      wait for 1000000 sec;
   end process generate_reset;


   generate_sync_reset:
   process
   begin
      --syncres <= '0';
      --wait for 300 ns;
      syncres <= '1';
      wait for 310 ns;
      syncres <= '0';
      wait for 1000000 sec;
   end process generate_sync_reset;


   test_main:
   process(clk, res, syncres,
           pm_di, pm_addr, pavr_pavr_res, pavr_pavr_syncres,
           main_clk_cnt, run_clk_cnt, instr_cnt,
           pavr_pavr_inc_instr_cnt
          )
      variable tmpv1: std_logic_vector(pm_di'length+pm_addr'length-1 downto 0);  -- This will generate a latch, but who cares? this is not intended to be synthesized.
   begin
      if res='1' then
         -- Async reset

         -- Reset the controller in turn.
         pavr_pavr_res <= '1';

         main_clk_cnt <= int_to_std_logic_vector(0, main_clk_cnt'length);
         run_clk_cnt  <= int_to_std_logic_vector(0, run_clk_cnt'length);
         instr_cnt    <= int_to_std_logic_vector(0, instr_cnt'length);
      elsif clk'event and clk='1' then
         -- Clock counter
         main_clk_cnt <= main_clk_cnt+1;
         run_clk_cnt  <= run_clk_cnt+1;

         -- Instruction counter
         case pavr_pavr_inc_instr_cnt is
            when "01" =>
               instr_cnt <= instr_cnt+1;
            when "10" =>
               instr_cnt <= instr_cnt+2;
            when "11" =>
               instr_cnt <= instr_cnt-1;
            when others =>
               null;
         end case;

         -- Set up Program Memory and let pAVR do its job.
         if (std_logic_vector_to_nat(main_clk_cnt)>=3 and std_logic_vector_to_nat(main_clk_cnt)<35) or
            (std_logic_vector_to_nat(main_clk_cnt)>=100 and std_logic_vector_to_nat(main_clk_cnt)<
         -- The following tagged lines are written automatically, based on the binary file,
         --    by using the tagScan utility.
-- <Clk Cnt>
964
-- </Clk Cnt>
            ) then
            -- Set up Program Memory.
            case std_logic_vector_to_nat(main_clk_cnt) is
               -- Initialize all 32 registers to 0x77.
               when  3 => tmpv1 := pm_setup( 0, 16#e747#);
               when  4 => tmpv1 := pm_setup( 1, 16#2e04#);
               when  5 => tmpv1 := pm_setup( 2, 16#2e14#);
               when  6 => tmpv1 := pm_setup( 3, 16#2e24#);
               when  7 => tmpv1 := pm_setup( 4, 16#2e34#);
               when  8 => tmpv1 := pm_setup( 5, 16#2e44#);
               when  9 => tmpv1 := pm_setup( 6, 16#2e54#);
               when 10 => tmpv1 := pm_setup( 7, 16#2e64#);
               when 11 => tmpv1 := pm_setup( 8, 16#2e74#);
               when 12 => tmpv1 := pm_setup( 9, 16#2e84#);
               when 13 => tmpv1 := pm_setup(10, 16#2e94#);
               when 14 => tmpv1 := pm_setup(11, 16#2ea4#);
               when 15 => tmpv1 := pm_setup(12, 16#2eb4#);
               when 16 => tmpv1 := pm_setup(13, 16#2ec4#);
               when 17 => tmpv1 := pm_setup(14, 16#2ed4#);
               when 18 => tmpv1 := pm_setup(15, 16#2ee4#);
               when 19 => tmpv1 := pm_setup(16, 16#2ef4#);
               when 20 => tmpv1 := pm_setup(17, 16#2f04#);
               when 21 => tmpv1 := pm_setup(18, 16#2f14#);
               when 22 => tmpv1 := pm_setup(19, 16#2f24#);
               when 23 => tmpv1 := pm_setup(20, 16#2f34#);
               when 24 => tmpv1 := pm_setup(21, 16#2f54#);
               when 25 => tmpv1 := pm_setup(22, 16#2f64#);
               when 26 => tmpv1 := pm_setup(23, 16#2f74#);
               when 27 => tmpv1 := pm_setup(24, 16#2f84#);
               when 28 => tmpv1 := pm_setup(25, 16#2f94#);
               when 29 => tmpv1 := pm_setup(26, 16#2fa4#);
               when 30 => tmpv1 := pm_setup(27, 16#2fb4#);
               when 31 => tmpv1 := pm_setup(28, 16#2fc4#);
               when 32 => tmpv1 := pm_setup(29, 16#2fd4#);
               when 33 => tmpv1 := pm_setup(30, 16#2fe4#);
               when 34 => tmpv1 := pm_setup(31, 16#2ff4#);
               -- The following tagged lines are written automatically, based on the binary file,
               --    by using the tagScan utility.
-- <Instructions>
               when 100 => tmpv1 := pm_setup(0, 16#940c#);
               when 101 => tmpv1 := pm_setup(1, 16#0030#);
               when 102 => tmpv1 := pm_setup(2, 16#940c#);
               when 103 => tmpv1 := pm_setup(3, 16#0050#);
               when 104 => tmpv1 := pm_setup(4, 16#940c#);
               when 105 => tmpv1 := pm_setup(5, 16#0050#);
               when 106 => tmpv1 := pm_setup(6, 16#940c#);
               when 107 => tmpv1 := pm_setup(7, 16#0050#);
               when 108 => tmpv1 := pm_setup(8, 16#940c#);
               when 109 => tmpv1 := pm_setup(9, 16#0050#);
               when 110 => tmpv1 := pm_setup(10, 16#940c#);
               when 111 => tmpv1 := pm_setup(11, 16#0050#);
               when 112 => tmpv1 := pm_setup(12, 16#940c#);
               when 113 => tmpv1 := pm_setup(13, 16#0050#);
               when 114 => tmpv1 := pm_setup(14, 16#940c#);
               when 115 => tmpv1 := pm_setup(15, 16#0050#);
               when 116 => tmpv1 := pm_setup(16, 16#940c#);
               when 117 => tmpv1 := pm_setup(17, 16#0050#);
               when 118 => tmpv1 := pm_setup(18, 16#940c#);
               when 119 => tmpv1 := pm_setup(19, 16#0050#);
               when 120 => tmpv1 := pm_setup(20, 16#940c#);
               when 121 => tmpv1 := pm_setup(21, 16#0050#);
               when 122 => tmpv1 := pm_setup(22, 16#940c#);
               when 123 => tmpv1 := pm_setup(23, 16#0050#);
               when 124 => tmpv1 := pm_setup(24, 16#940c#);
               when 125 => tmpv1 := pm_setup(25, 16#0050#);
               when 126 => tmpv1 := pm_setup(26, 16#940c#);
               when 127 => tmpv1 := pm_setup(27, 16#0050#);
               when 128 => tmpv1 := pm_setup(28, 16#940c#);
               when 129 => tmpv1 := pm_setup(29, 16#0050#);
               when 130 => tmpv1 := pm_setup(30, 16#940c#);
               when 131 => tmpv1 := pm_setup(31, 16#0050#);
               when 132 => tmpv1 := pm_setup(32, 16#940c#);
               when 133 => tmpv1 := pm_setup(33, 16#0050#);
               when 134 => tmpv1 := pm_setup(34, 16#940c#);
               when 135 => tmpv1 := pm_setup(35, 16#0050#);
               when 136 => tmpv1 := pm_setup(36, 16#940c#);
               when 137 => tmpv1 := pm_setup(37, 16#0050#);
               when 138 => tmpv1 := pm_setup(38, 16#940c#);
               when 139 => tmpv1 := pm_setup(39, 16#0050#);
               when 140 => tmpv1 := pm_setup(40, 16#940c#);
               when 141 => tmpv1 := pm_setup(41, 16#0050#);
               when 142 => tmpv1 := pm_setup(42, 16#940c#);
               when 143 => tmpv1 := pm_setup(43, 16#0050#);
               when 144 => tmpv1 := pm_setup(44, 16#940c#);
               when 145 => tmpv1 := pm_setup(45, 16#0050#);
               when 146 => tmpv1 := pm_setup(46, 16#940c#);
               when 147 => tmpv1 := pm_setup(47, 16#0050#);
               when 148 => tmpv1 := pm_setup(48, 16#2411#);
               when 149 => tmpv1 := pm_setup(49, 16#be1f#);
               when 150 => tmpv1 := pm_setup(50, 16#efcf#);
               when 151 => tmpv1 := pm_setup(51, 16#e0df#);
               when 152 => tmpv1 := pm_setup(52, 16#bfde#);
               when 153 => tmpv1 := pm_setup(53, 16#bfcd#);
               when 154 => tmpv1 := pm_setup(54, 16#e010#);
               when 155 => tmpv1 := pm_setup(55, 16#e6a0#);
               when 156 => tmpv1 := pm_setup(56, 16#e0b0#);
               when 157 => tmpv1 := pm_setup(57, 16#ece0#);
               when 158 => tmpv1 := pm_setup(58, 16#e0f6#);
               when 159 => tmpv1 := pm_setup(59, 16#ef0f#);
               when 160 => tmpv1 := pm_setup(60, 16#9503#);
               when 161 => tmpv1 := pm_setup(61, 16#bf0b#);
               when 162 => tmpv1 := pm_setup(62, 16#c004#);
               when 163 => tmpv1 := pm_setup(63, 16#95c8#);
               when 164 => tmpv1 := pm_setup(64, 16#920d#);
               when 165 => tmpv1 := pm_setup(65, 16#9631#);
               when 166 => tmpv1 := pm_setup(66, 16#f3c8#);
               when 167 => tmpv1 := pm_setup(67, 16#36a0#);
               when 168 => tmpv1 := pm_setup(68, 16#07b1#);
               when 169 => tmpv1 := pm_setup(69, 16#f7c9#);
               when 170 => tmpv1 := pm_setup(70, 16#e011#);
               when 171 => tmpv1 := pm_setup(71, 16#e6a0#);
               when 172 => tmpv1 := pm_setup(72, 16#e0b0#);
               when 173 => tmpv1 := pm_setup(73, 16#c001#);
               when 174 => tmpv1 := pm_setup(74, 16#921d#);
               when 175 => tmpv1 := pm_setup(75, 16#35a1#);
               when 176 => tmpv1 := pm_setup(76, 16#07b1#);
               when 177 => tmpv1 := pm_setup(77, 16#f7e1#);
               when 178 => tmpv1 := pm_setup(78, 16#940c#);
               when 179 => tmpv1 := pm_setup(79, 16#0052#);
               when 180 => tmpv1 := pm_setup(80, 16#940c#);
               when 181 => tmpv1 := pm_setup(81, 16#0000#);
               when 182 => tmpv1 := pm_setup(82, 16#eecf#);
               when 183 => tmpv1 := pm_setup(83, 16#e0df#);
               when 184 => tmpv1 := pm_setup(84, 16#bfde#);
               when 185 => tmpv1 := pm_setup(85, 16#bfcd#);
               when 186 => tmpv1 := pm_setup(86, 16#8219#);
               when 187 => tmpv1 := pm_setup(87, 16#821a#);
               when 188 => tmpv1 := pm_setup(88, 16#e040#);
               when 189 => tmpv1 := pm_setup(89, 16#e050#);
               when 190 => tmpv1 := pm_setup(90, 16#821b#);
               when 191 => tmpv1 := pm_setup(91, 16#821c#);
               when 192 => tmpv1 := pm_setup(92, 16#2f24#);
               when 193 => tmpv1 := pm_setup(93, 16#2f35#);
               when 194 => tmpv1 := pm_setup(94, 16#0f22#);
               when 195 => tmpv1 := pm_setup(95, 16#1f33#);
               when 196 => tmpv1 := pm_setup(96, 16#0f22#);
               when 197 => tmpv1 := pm_setup(97, 16#1f33#);
               when 198 => tmpv1 := pm_setup(98, 16#2ff3#);
               when 199 => tmpv1 := pm_setup(99, 16#2fe2#);
               when 200 => tmpv1 := pm_setup(100, 16#5ae0#);
               when 201 => tmpv1 := pm_setup(101, 16#4fff#);
               when 202 => tmpv1 := pm_setup(102, 16#e080#);
               when 203 => tmpv1 := pm_setup(103, 16#e090#);
               when 204 => tmpv1 := pm_setup(104, 16#e0a0#);
               when 205 => tmpv1 := pm_setup(105, 16#e0b0#);
               when 206 => tmpv1 := pm_setup(106, 16#8380#);
               when 207 => tmpv1 := pm_setup(107, 16#8391#);
               when 208 => tmpv1 := pm_setup(108, 16#83a2#);
               when 209 => tmpv1 := pm_setup(109, 16#83b3#);
               when 210 => tmpv1 := pm_setup(110, 16#2ff3#);
               when 211 => tmpv1 := pm_setup(111, 16#2fe2#);
               when 212 => tmpv1 := pm_setup(112, 16#53ec#);
               when 213 => tmpv1 := pm_setup(113, 16#4fff#);
               when 214 => tmpv1 := pm_setup(114, 16#8380#);
               when 215 => tmpv1 := pm_setup(115, 16#8391#);
               when 216 => tmpv1 := pm_setup(116, 16#83a2#);
               when 217 => tmpv1 := pm_setup(117, 16#83b3#);
               when 218 => tmpv1 := pm_setup(118, 16#5f2c#);
               when 219 => tmpv1 := pm_setup(119, 16#4f3f#);
               when 220 => tmpv1 := pm_setup(120, 16#818b#);
               when 221 => tmpv1 := pm_setup(121, 16#819c#);
               when 222 => tmpv1 := pm_setup(122, 16#9601#);
               when 223 => tmpv1 := pm_setup(123, 16#838b#);
               when 224 => tmpv1 := pm_setup(124, 16#839c#);
               when 225 => tmpv1 := pm_setup(125, 16#9705#);
               when 226 => tmpv1 := pm_setup(126, 16#f31c#);
               when 227 => tmpv1 := pm_setup(127, 16#5f4b#);
               when 228 => tmpv1 := pm_setup(128, 16#4f5f#);
               when 229 => tmpv1 := pm_setup(129, 16#81e9#);
               when 230 => tmpv1 := pm_setup(130, 16#81fa#);
               when 231 => tmpv1 := pm_setup(131, 16#9631#);
               when 232 => tmpv1 := pm_setup(132, 16#83e9#);
               when 233 => tmpv1 := pm_setup(133, 16#83fa#);
               when 234 => tmpv1 := pm_setup(134, 16#9735#);
               when 235 => tmpv1 := pm_setup(135, 16#f294#);
               when 236 => tmpv1 := pm_setup(136, 16#e686#);
               when 237 => tmpv1 := pm_setup(137, 16#e696#);
               when 238 => tmpv1 := pm_setup(138, 16#e6a6#);
               when 239 => tmpv1 := pm_setup(139, 16#e3bf#);
               when 240 => tmpv1 := pm_setup(140, 16#9380#);
               when 241 => tmpv1 := pm_setup(141, 16#0078#);
               when 242 => tmpv1 := pm_setup(142, 16#9390#);
               when 243 => tmpv1 := pm_setup(143, 16#0079#);
               when 244 => tmpv1 := pm_setup(144, 16#93a0#);
               when 245 => tmpv1 := pm_setup(145, 16#007a#);
               when 246 => tmpv1 := pm_setup(146, 16#93b0#);
               when 247 => tmpv1 := pm_setup(147, 16#007b#);
               when 248 => tmpv1 := pm_setup(148, 16#821d#);
               when 249 => tmpv1 := pm_setup(149, 16#821e#);
               when 250 => tmpv1 := pm_setup(150, 16#8219#);
               when 251 => tmpv1 := pm_setup(151, 16#821a#);
               when 252 => tmpv1 := pm_setup(152, 16#e020#);
               when 253 => tmpv1 := pm_setup(153, 16#e030#);
               when 254 => tmpv1 := pm_setup(154, 16#832f#);
               when 255 => tmpv1 := pm_setup(155, 16#8738#);
               when 256 => tmpv1 := pm_setup(156, 16#8729#);
               when 257 => tmpv1 := pm_setup(157, 16#873a#);
               when 258 => tmpv1 := pm_setup(158, 16#821b#);
               when 259 => tmpv1 := pm_setup(159, 16#821c#);
               when 260 => tmpv1 := pm_setup(160, 16#818f#);
               when 261 => tmpv1 := pm_setup(161, 16#8598#);
               when 262 => tmpv1 := pm_setup(162, 16#0f88#);
               when 263 => tmpv1 := pm_setup(163, 16#1f99#);
               when 264 => tmpv1 := pm_setup(164, 16#0f88#);
               when 265 => tmpv1 := pm_setup(165, 16#1f99#);
               when 266 => tmpv1 := pm_setup(166, 16#2ff9#);
               when 267 => tmpv1 := pm_setup(167, 16#2fe8#);
               when 268 => tmpv1 := pm_setup(168, 16#5be8#);
               when 269 => tmpv1 := pm_setup(169, 16#4fff#);
               when 270 => tmpv1 := pm_setup(170, 16#87ef#);
               when 271 => tmpv1 := pm_setup(171, 16#8bf8#);
               when 272 => tmpv1 := pm_setup(172, 16#2f28#);
               when 273 => tmpv1 := pm_setup(173, 16#2f39#);
               when 274 => tmpv1 := pm_setup(174, 16#532c#);
               when 275 => tmpv1 := pm_setup(175, 16#4f3f#);
               when 276 => tmpv1 := pm_setup(176, 16#872b#);
               when 277 => tmpv1 := pm_setup(177, 16#873c#);
               when 278 => tmpv1 := pm_setup(178, 16#8589#);
               when 279 => tmpv1 := pm_setup(179, 16#859a#);
               when 280 => tmpv1 := pm_setup(180, 16#0f88#);
               when 281 => tmpv1 := pm_setup(181, 16#1f99#);
               when 282 => tmpv1 := pm_setup(182, 16#0f88#);
               when 283 => tmpv1 := pm_setup(183, 16#1f99#);
               when 284 => tmpv1 := pm_setup(184, 16#878d#);
               when 285 => tmpv1 := pm_setup(185, 16#879e#);
               when 286 => tmpv1 := pm_setup(186, 16#81e9#);
               when 287 => tmpv1 := pm_setup(187, 16#81fa#);
               when 288 => tmpv1 := pm_setup(188, 16#9730#);
               when 289 => tmpv1 := pm_setup(189, 16#f409#);
               when 290 => tmpv1 := pm_setup(190, 16#c19a#);
               when 291 => tmpv1 := pm_setup(191, 16#812b#);
               when 292 => tmpv1 := pm_setup(192, 16#813c#);
               when 293 => tmpv1 := pm_setup(193, 16#1521#);
               when 294 => tmpv1 := pm_setup(194, 16#0531#);
               when 295 => tmpv1 := pm_setup(195, 16#f409#);
               when 296 => tmpv1 := pm_setup(196, 16#c194#);
               when 297 => tmpv1 := pm_setup(197, 16#9734#);
               when 298 => tmpv1 := pm_setup(198, 16#f409#);
               when 299 => tmpv1 := pm_setup(199, 16#c191#);
               when 300 => tmpv1 := pm_setup(200, 16#3024#);
               when 301 => tmpv1 := pm_setup(201, 16#0531#);
               when 302 => tmpv1 := pm_setup(202, 16#f409#);
               when 303 => tmpv1 := pm_setup(203, 16#c18d#);
               when 304 => tmpv1 := pm_setup(204, 16#85eb#);
               when 305 => tmpv1 := pm_setup(205, 16#85fc#);
               when 306 => tmpv1 := pm_setup(206, 16#8180#);
               when 307 => tmpv1 := pm_setup(207, 16#8191#);
               when 308 => tmpv1 := pm_setup(208, 16#81a2#);
               when 309 => tmpv1 := pm_setup(209, 16#81b3#);
               when 310 => tmpv1 := pm_setup(210, 16#e626#);
               when 311 => tmpv1 := pm_setup(211, 16#e636#);
               when 312 => tmpv1 := pm_setup(212, 16#e646#);
               when 313 => tmpv1 := pm_setup(213, 16#e35f#);
               when 314 => tmpv1 := pm_setup(214, 16#2f68#);
               when 315 => tmpv1 := pm_setup(215, 16#2f79#);
               when 316 => tmpv1 := pm_setup(216, 16#2f8a#);
               when 317 => tmpv1 := pm_setup(217, 16#2f9b#);
               when 318 => tmpv1 := pm_setup(218, 16#940e#);
               when 319 => tmpv1 := pm_setup(219, 16#030f#);
               when 320 => tmpv1 := pm_setup(220, 16#2e26#);
               when 321 => tmpv1 := pm_setup(221, 16#2e37#);
               when 322 => tmpv1 := pm_setup(222, 16#2e48#);
               when 323 => tmpv1 := pm_setup(223, 16#2e59#);
               when 324 => tmpv1 := pm_setup(224, 16#85ef#);
               when 325 => tmpv1 := pm_setup(225, 16#89f8#);
               when 326 => tmpv1 := pm_setup(226, 16#8c60#);
               when 327 => tmpv1 := pm_setup(227, 16#8c71#);
               when 328 => tmpv1 := pm_setup(228, 16#8c82#);
               when 329 => tmpv1 := pm_setup(229, 16#8c93#);
               when 330 => tmpv1 := pm_setup(230, 16#e020#);
               when 331 => tmpv1 := pm_setup(231, 16#e030#);
               when 332 => tmpv1 := pm_setup(232, 16#ec40#);
               when 333 => tmpv1 := pm_setup(233, 16#e450#);
               when 334 => tmpv1 := pm_setup(234, 16#2d99#);
               when 335 => tmpv1 := pm_setup(235, 16#2d88#);
               when 336 => tmpv1 := pm_setup(236, 16#2d77#);
               when 337 => tmpv1 := pm_setup(237, 16#2d66#);
               when 338 => tmpv1 := pm_setup(238, 16#940e#);
               when 339 => tmpv1 := pm_setup(239, 16#030f#);
               when 340 => tmpv1 := pm_setup(240, 16#2ea6#);
               when 341 => tmpv1 := pm_setup(241, 16#2eb7#);
               when 342 => tmpv1 := pm_setup(242, 16#2ec8#);
               when 343 => tmpv1 := pm_setup(243, 16#2ed9#);
               when 344 => tmpv1 := pm_setup(244, 16#85ef#);
               when 345 => tmpv1 := pm_setup(245, 16#89f8#);
               when 346 => tmpv1 := pm_setup(246, 16#80e4#);
               when 347 => tmpv1 := pm_setup(247, 16#80f5#);
               when 348 => tmpv1 := pm_setup(248, 16#8106#);
               when 349 => tmpv1 := pm_setup(249, 16#8117#);
               when 350 => tmpv1 := pm_setup(250, 16#a584#);
               when 351 => tmpv1 := pm_setup(251, 16#a595#);
               when 352 => tmpv1 := pm_setup(252, 16#a5a6#);
               when 353 => tmpv1 := pm_setup(253, 16#a5b7#);
               when 354 => tmpv1 := pm_setup(254, 16#2f28#);
               when 355 => tmpv1 := pm_setup(255, 16#2f39#);
               when 356 => tmpv1 := pm_setup(256, 16#2f4a#);
               when 357 => tmpv1 := pm_setup(257, 16#2f5b#);
               when 358 => tmpv1 := pm_setup(258, 16#2f91#);
               when 359 => tmpv1 := pm_setup(259, 16#2f80#);
               when 360 => tmpv1 := pm_setup(260, 16#2d7f#);
               when 361 => tmpv1 := pm_setup(261, 16#2d6e#);
               when 362 => tmpv1 := pm_setup(262, 16#940e#);
               when 363 => tmpv1 := pm_setup(263, 16#0273#);
               when 364 => tmpv1 := pm_setup(264, 16#2ee6#);
               when 365 => tmpv1 := pm_setup(265, 16#2ef7#);
               when 366 => tmpv1 := pm_setup(266, 16#2f08#);
               when 367 => tmpv1 := pm_setup(267, 16#2f19#);
               when 368 => tmpv1 := pm_setup(268, 16#85ef#);
               when 369 => tmpv1 := pm_setup(269, 16#89f8#);
               when 370 => tmpv1 := pm_setup(270, 16#8984#);
               when 371 => tmpv1 := pm_setup(271, 16#8995#);
               when 372 => tmpv1 := pm_setup(272, 16#89a6#);
               when 373 => tmpv1 := pm_setup(273, 16#89b7#);
               when 374 => tmpv1 := pm_setup(274, 16#2f28#);
               when 375 => tmpv1 := pm_setup(275, 16#2f39#);
               when 376 => tmpv1 := pm_setup(276, 16#2f4a#);
               when 377 => tmpv1 := pm_setup(277, 16#2f5b#);
               when 378 => tmpv1 := pm_setup(278, 16#2f91#);
               when 379 => tmpv1 := pm_setup(279, 16#2f80#);
               when 380 => tmpv1 := pm_setup(280, 16#2d7f#);
               when 381 => tmpv1 := pm_setup(281, 16#2d6e#);
               when 382 => tmpv1 := pm_setup(282, 16#940e#);
               when 383 => tmpv1 := pm_setup(283, 16#0273#);
               when 384 => tmpv1 := pm_setup(284, 16#2ee6#);
               when 385 => tmpv1 := pm_setup(285, 16#2ef7#);
               when 386 => tmpv1 := pm_setup(286, 16#2f08#);
               when 387 => tmpv1 := pm_setup(287, 16#2f19#);
               when 388 => tmpv1 := pm_setup(288, 16#85ef#);
               when 389 => tmpv1 := pm_setup(289, 16#89f8#);
               when 390 => tmpv1 := pm_setup(290, 16#8d84#);
               when 391 => tmpv1 := pm_setup(291, 16#8d95#);
               when 392 => tmpv1 := pm_setup(292, 16#8da6#);
               when 393 => tmpv1 := pm_setup(293, 16#8db7#);
               when 394 => tmpv1 := pm_setup(294, 16#2f28#);
               when 395 => tmpv1 := pm_setup(295, 16#2f39#);
               when 396 => tmpv1 := pm_setup(296, 16#2f4a#);
               when 397 => tmpv1 := pm_setup(297, 16#2f5b#);
               when 398 => tmpv1 := pm_setup(298, 16#2f91#);
               when 399 => tmpv1 := pm_setup(299, 16#2f80#);
               when 400 => tmpv1 := pm_setup(300, 16#2d7f#);
               when 401 => tmpv1 := pm_setup(301, 16#2d6e#);
               when 402 => tmpv1 := pm_setup(302, 16#940e#);
               when 403 => tmpv1 := pm_setup(303, 16#0273#);
               when 404 => tmpv1 := pm_setup(304, 16#2fb9#);
               when 405 => tmpv1 := pm_setup(305, 16#2fa8#);
               when 406 => tmpv1 := pm_setup(306, 16#2f97#);
               when 407 => tmpv1 := pm_setup(307, 16#2f86#);
               when 408 => tmpv1 := pm_setup(308, 16#2f28#);
               when 409 => tmpv1 := pm_setup(309, 16#2f39#);
               when 410 => tmpv1 := pm_setup(310, 16#2f4a#);
               when 411 => tmpv1 := pm_setup(311, 16#2f5b#);
               when 412 => tmpv1 := pm_setup(312, 16#2d9d#);
               when 413 => tmpv1 := pm_setup(313, 16#2d8c#);
               when 414 => tmpv1 := pm_setup(314, 16#2d7b#);
               when 415 => tmpv1 := pm_setup(315, 16#2d6a#);
               when 416 => tmpv1 := pm_setup(316, 16#940e#);
               when 417 => tmpv1 := pm_setup(317, 16#0272#);
               when 418 => tmpv1 := pm_setup(318, 16#2ea6#);
               when 419 => tmpv1 := pm_setup(319, 16#2eb7#);
               when 420 => tmpv1 := pm_setup(320, 16#2ec8#);
               when 421 => tmpv1 := pm_setup(321, 16#2ed9#);
               when 422 => tmpv1 := pm_setup(322, 16#85ef#);
               when 423 => tmpv1 := pm_setup(323, 16#89f8#);
               when 424 => tmpv1 := pm_setup(324, 16#80e0#);
               when 425 => tmpv1 := pm_setup(325, 16#80f1#);
               when 426 => tmpv1 := pm_setup(326, 16#8102#);
               when 427 => tmpv1 := pm_setup(327, 16#8113#);
               when 428 => tmpv1 := pm_setup(328, 16#8580#);
               when 429 => tmpv1 := pm_setup(329, 16#8591#);
               when 430 => tmpv1 := pm_setup(330, 16#85a2#);
               when 431 => tmpv1 := pm_setup(331, 16#85b3#);
               when 432 => tmpv1 := pm_setup(332, 16#2f28#);
               when 433 => tmpv1 := pm_setup(333, 16#2f39#);
               when 434 => tmpv1 := pm_setup(334, 16#2f4a#);
               when 435 => tmpv1 := pm_setup(335, 16#2f5b#);
               when 436 => tmpv1 := pm_setup(336, 16#2f91#);
               when 437 => tmpv1 := pm_setup(337, 16#2f80#);
               when 438 => tmpv1 := pm_setup(338, 16#2d7f#);
               when 439 => tmpv1 := pm_setup(339, 16#2d6e#);
               when 440 => tmpv1 := pm_setup(340, 16#940e#);
               when 441 => tmpv1 := pm_setup(341, 16#0273#);
               when 442 => tmpv1 := pm_setup(342, 16#2ee6#);
               when 443 => tmpv1 := pm_setup(343, 16#2ef7#);
               when 444 => tmpv1 := pm_setup(344, 16#2f08#);
               when 445 => tmpv1 := pm_setup(345, 16#2f19#);
               when 446 => tmpv1 := pm_setup(346, 16#85ef#);
               when 447 => tmpv1 := pm_setup(347, 16#89f8#);
               when 448 => tmpv1 := pm_setup(348, 16#a580#);
               when 449 => tmpv1 := pm_setup(349, 16#a591#);
               when 450 => tmpv1 := pm_setup(350, 16#a5a2#);
               when 451 => tmpv1 := pm_setup(351, 16#a5b3#);
               when 452 => tmpv1 := pm_setup(352, 16#2f28#);
               when 453 => tmpv1 := pm_setup(353, 16#2f39#);
               when 454 => tmpv1 := pm_setup(354, 16#2f4a#);
               when 455 => tmpv1 := pm_setup(355, 16#2f5b#);
               when 456 => tmpv1 := pm_setup(356, 16#2f91#);
               when 457 => tmpv1 := pm_setup(357, 16#2f80#);
               when 458 => tmpv1 := pm_setup(358, 16#2d7f#);
               when 459 => tmpv1 := pm_setup(359, 16#2d6e#);
               when 460 => tmpv1 := pm_setup(360, 16#940e#);
               when 461 => tmpv1 := pm_setup(361, 16#0273#);
               when 462 => tmpv1 := pm_setup(362, 16#2ee6#);
               when 463 => tmpv1 := pm_setup(363, 16#2ef7#);
               when 464 => tmpv1 := pm_setup(364, 16#2f08#);
               when 465 => tmpv1 := pm_setup(365, 16#2f19#);
               when 466 => tmpv1 := pm_setup(366, 16#85ef#);
               when 467 => tmpv1 := pm_setup(367, 16#89f8#);
               when 468 => tmpv1 := pm_setup(368, 16#a980#);
               when 469 => tmpv1 := pm_setup(369, 16#a991#);
               when 470 => tmpv1 := pm_setup(370, 16#a9a2#);
               when 471 => tmpv1 := pm_setup(371, 16#a9b3#);
               when 472 => tmpv1 := pm_setup(372, 16#2f28#);
               when 473 => tmpv1 := pm_setup(373, 16#2f39#);
               when 474 => tmpv1 := pm_setup(374, 16#2f4a#);
               when 475 => tmpv1 := pm_setup(375, 16#2f5b#);
               when 476 => tmpv1 := pm_setup(376, 16#2f91#);
               when 477 => tmpv1 := pm_setup(377, 16#2f80#);
               when 478 => tmpv1 := pm_setup(378, 16#2d7f#);
               when 479 => tmpv1 := pm_setup(379, 16#2d6e#);
               when 480 => tmpv1 := pm_setup(380, 16#940e#);
               when 481 => tmpv1 := pm_setup(381, 16#0273#);
               when 482 => tmpv1 := pm_setup(382, 16#2fb9#);
               when 483 => tmpv1 := pm_setup(383, 16#2fa8#);
               when 484 => tmpv1 := pm_setup(384, 16#2f97#);
               when 485 => tmpv1 := pm_setup(385, 16#2f86#);
               when 486 => tmpv1 := pm_setup(386, 16#e020#);
               when 487 => tmpv1 := pm_setup(387, 16#e030#);
               when 488 => tmpv1 := pm_setup(388, 16#e040#);
               when 489 => tmpv1 := pm_setup(389, 16#e35f#);
               when 490 => tmpv1 := pm_setup(390, 16#2f68#);
               when 491 => tmpv1 := pm_setup(391, 16#2f79#);
               when 492 => tmpv1 := pm_setup(392, 16#2f8a#);
               when 493 => tmpv1 := pm_setup(393, 16#2f9b#);
               when 494 => tmpv1 := pm_setup(394, 16#940e#);
               when 495 => tmpv1 := pm_setup(395, 16#030f#);
               when 496 => tmpv1 := pm_setup(396, 16#2fb9#);
               when 497 => tmpv1 := pm_setup(397, 16#2fa8#);
               when 498 => tmpv1 := pm_setup(398, 16#2f97#);
               when 499 => tmpv1 := pm_setup(399, 16#2f86#);
               when 500 => tmpv1 := pm_setup(400, 16#2f28#);
               when 501 => tmpv1 := pm_setup(401, 16#2f39#);
               when 502 => tmpv1 := pm_setup(402, 16#2f4a#);
               when 503 => tmpv1 := pm_setup(403, 16#2f5b#);
               when 504 => tmpv1 := pm_setup(404, 16#2d9d#);
               when 505 => tmpv1 := pm_setup(405, 16#2d8c#);
               when 506 => tmpv1 := pm_setup(406, 16#2d7b#);
               when 507 => tmpv1 := pm_setup(407, 16#2d6a#);
               when 508 => tmpv1 := pm_setup(408, 16#940e#);
               when 509 => tmpv1 := pm_setup(409, 16#0272#);
               when 510 => tmpv1 := pm_setup(410, 16#2fb9#);
               when 511 => tmpv1 := pm_setup(411, 16#2fa8#);
               when 512 => tmpv1 := pm_setup(412, 16#2f97#);
               when 513 => tmpv1 := pm_setup(413, 16#2f86#);
               when 514 => tmpv1 := pm_setup(414, 16#e925#);
               when 515 => tmpv1 := pm_setup(415, 16#e635#);
               when 516 => tmpv1 := pm_setup(416, 16#e048#);
               when 517 => tmpv1 := pm_setup(417, 16#e35d#);
               when 518 => tmpv1 := pm_setup(418, 16#2f68#);
               when 519 => tmpv1 := pm_setup(419, 16#2f79#);
               when 520 => tmpv1 := pm_setup(420, 16#2f8a#);
               when 521 => tmpv1 := pm_setup(421, 16#2f9b#);
               when 522 => tmpv1 := pm_setup(422, 16#940e#);
               when 523 => tmpv1 := pm_setup(423, 16#030f#);
               when 524 => tmpv1 := pm_setup(424, 16#2fb9#);
               when 525 => tmpv1 := pm_setup(425, 16#2fa8#);
               when 526 => tmpv1 := pm_setup(426, 16#2f97#);
               when 527 => tmpv1 := pm_setup(427, 16#2f86#);
               when 528 => tmpv1 := pm_setup(428, 16#2f28#);
               when 529 => tmpv1 := pm_setup(429, 16#2f39#);
               when 530 => tmpv1 := pm_setup(430, 16#2f4a#);
               when 531 => tmpv1 := pm_setup(431, 16#2f5b#);
               when 532 => tmpv1 := pm_setup(432, 16#2d95#);
               when 533 => tmpv1 := pm_setup(433, 16#2d84#);
               when 534 => tmpv1 := pm_setup(434, 16#2d73#);
               when 535 => tmpv1 := pm_setup(435, 16#2d62#);
               when 536 => tmpv1 := pm_setup(436, 16#940e#);
               when 537 => tmpv1 := pm_setup(437, 16#0272#);
               when 538 => tmpv1 := pm_setup(438, 16#2fb9#);
               when 539 => tmpv1 := pm_setup(439, 16#2fa8#);
               when 540 => tmpv1 := pm_setup(440, 16#2f97#);
               when 541 => tmpv1 := pm_setup(441, 16#2f86#);
               when 542 => tmpv1 := pm_setup(442, 16#85eb#);
               when 543 => tmpv1 := pm_setup(443, 16#85fc#);
               when 544 => tmpv1 := pm_setup(444, 16#8380#);
               when 545 => tmpv1 := pm_setup(445, 16#8391#);
               when 546 => tmpv1 := pm_setup(446, 16#83a2#);
               when 547 => tmpv1 := pm_setup(447, 16#83b3#);
               when 548 => tmpv1 := pm_setup(448, 16#2f28#);
               when 549 => tmpv1 := pm_setup(449, 16#2f39#);
               when 550 => tmpv1 := pm_setup(450, 16#2f4a#);
               when 551 => tmpv1 := pm_setup(451, 16#2f5b#);
               when 552 => tmpv1 := pm_setup(452, 16#2d99#);
               when 553 => tmpv1 := pm_setup(453, 16#2d88#);
               when 554 => tmpv1 := pm_setup(454, 16#2d77#);
               when 555 => tmpv1 := pm_setup(455, 16#2d66#);
               when 556 => tmpv1 := pm_setup(456, 16#940e#);
               when 557 => tmpv1 := pm_setup(457, 16#0273#);
               when 558 => tmpv1 := pm_setup(458, 16#2fb9#);
               when 559 => tmpv1 := pm_setup(459, 16#2fa8#);
               when 560 => tmpv1 := pm_setup(460, 16#2f97#);
               when 561 => tmpv1 := pm_setup(461, 16#2f86#);
               when 562 => tmpv1 := pm_setup(462, 16#85ef#);
               when 563 => tmpv1 := pm_setup(463, 16#89f8#);
               when 564 => tmpv1 := pm_setup(464, 16#8f80#);
               when 565 => tmpv1 := pm_setup(465, 16#8f91#);
               when 566 => tmpv1 := pm_setup(466, 16#8fa2#);
               when 567 => tmpv1 := pm_setup(467, 16#8fb3#);
               when 568 => tmpv1 := pm_setup(468, 16#852f#);
               when 569 => tmpv1 := pm_setup(469, 16#8938#);
               when 570 => tmpv1 := pm_setup(470, 16#5f2c#);
               when 571 => tmpv1 := pm_setup(471, 16#4f3f#);
               when 572 => tmpv1 := pm_setup(472, 16#872f#);
               when 573 => tmpv1 := pm_setup(473, 16#8b38#);
               when 574 => tmpv1 := pm_setup(474, 16#858b#);
               when 575 => tmpv1 := pm_setup(475, 16#859c#);
               when 576 => tmpv1 := pm_setup(476, 16#9604#);
               when 577 => tmpv1 := pm_setup(477, 16#878b#);
               when 578 => tmpv1 := pm_setup(478, 16#879c#);
               when 579 => tmpv1 := pm_setup(479, 16#85ed#);
               when 580 => tmpv1 := pm_setup(480, 16#85fe#);
               when 581 => tmpv1 := pm_setup(481, 16#9634#);
               when 582 => tmpv1 := pm_setup(482, 16#87ed#);
               when 583 => tmpv1 := pm_setup(483, 16#87fe#);
               when 584 => tmpv1 := pm_setup(484, 16#812b#);
               when 585 => tmpv1 := pm_setup(485, 16#813c#);
               when 586 => tmpv1 := pm_setup(486, 16#5f2f#);
               when 587 => tmpv1 := pm_setup(487, 16#4f3f#);
               when 588 => tmpv1 := pm_setup(488, 16#832b#);
               when 589 => tmpv1 := pm_setup(489, 16#833c#);
               when 590 => tmpv1 := pm_setup(490, 16#3025#);
               when 591 => tmpv1 := pm_setup(491, 16#0531#);
               when 592 => tmpv1 := pm_setup(492, 16#f40c#);
               when 593 => tmpv1 := pm_setup(493, 16#cecc#);
               when 594 => tmpv1 := pm_setup(494, 16#818f#);
               when 595 => tmpv1 := pm_setup(495, 16#8598#);
               when 596 => tmpv1 := pm_setup(496, 16#9605#);
               when 597 => tmpv1 := pm_setup(497, 16#838f#);
               when 598 => tmpv1 := pm_setup(498, 16#8798#);
               when 599 => tmpv1 := pm_setup(499, 16#85e9#);
               when 600 => tmpv1 := pm_setup(500, 16#85fa#);
               when 601 => tmpv1 := pm_setup(501, 16#9635#);
               when 602 => tmpv1 := pm_setup(502, 16#87e9#);
               when 603 => tmpv1 := pm_setup(503, 16#87fa#);
               when 604 => tmpv1 := pm_setup(504, 16#8129#);
               when 605 => tmpv1 := pm_setup(505, 16#813a#);
               when 606 => tmpv1 := pm_setup(506, 16#5f2f#);
               when 607 => tmpv1 := pm_setup(507, 16#4f3f#);
               when 608 => tmpv1 := pm_setup(508, 16#8329#);
               when 609 => tmpv1 := pm_setup(509, 16#833a#);
               when 610 => tmpv1 := pm_setup(510, 16#3025#);
               when 611 => tmpv1 := pm_setup(511, 16#0531#);
               when 612 => tmpv1 := pm_setup(512, 16#f40c#);
               when 613 => tmpv1 := pm_setup(513, 16#ce9c#);
               when 614 => tmpv1 := pm_setup(514, 16#818d#);
               when 615 => tmpv1 := pm_setup(515, 16#819e#);
               when 616 => tmpv1 := pm_setup(516, 16#9601#);
               when 617 => tmpv1 := pm_setup(517, 16#838d#);
               when 618 => tmpv1 := pm_setup(518, 16#839e#);
               when 619 => tmpv1 := pm_setup(519, 16#9705#);
               when 620 => tmpv1 := pm_setup(520, 16#f40c#);
               when 621 => tmpv1 := pm_setup(521, 16#ce8c#);
               when 622 => tmpv1 := pm_setup(522, 16#8219#);
               when 623 => tmpv1 := pm_setup(523, 16#821a#);
               when 624 => tmpv1 := pm_setup(524, 16#24ee#);
               when 625 => tmpv1 := pm_setup(525, 16#24ff#);
               when 626 => tmpv1 := pm_setup(526, 16#821b#);
               when 627 => tmpv1 := pm_setup(527, 16#821c#);
               when 628 => tmpv1 := pm_setup(528, 16#2d1f#);
               when 629 => tmpv1 := pm_setup(529, 16#2d0e#);
               when 630 => tmpv1 := pm_setup(530, 16#5c08#);
               when 631 => tmpv1 := pm_setup(531, 16#4f1e#);
               when 632 => tmpv1 := pm_setup(532, 16#2cce#);
               when 633 => tmpv1 := pm_setup(533, 16#2cdf#);
               when 634 => tmpv1 := pm_setup(534, 16#0ccc#);
               when 635 => tmpv1 := pm_setup(535, 16#1cdd#);
               when 636 => tmpv1 := pm_setup(536, 16#0ccc#);
               when 637 => tmpv1 := pm_setup(537, 16#1cdd#);
               when 638 => tmpv1 := pm_setup(538, 16#e6e0#);
               when 639 => tmpv1 := pm_setup(539, 16#e0f0#);
               when 640 => tmpv1 := pm_setup(540, 16#0ece#);
               when 641 => tmpv1 := pm_setup(541, 16#1edf#);
               when 642 => tmpv1 := pm_setup(542, 16#2dfd#);
               when 643 => tmpv1 := pm_setup(543, 16#2dec#);
               when 644 => tmpv1 := pm_setup(544, 16#9181#);
               when 645 => tmpv1 := pm_setup(545, 16#9191#);
               when 646 => tmpv1 := pm_setup(546, 16#91a1#);
               when 647 => tmpv1 := pm_setup(547, 16#91b1#);
               when 648 => tmpv1 := pm_setup(548, 16#2ece#);
               when 649 => tmpv1 := pm_setup(549, 16#2edf#);
               when 650 => tmpv1 := pm_setup(550, 16#e020#);
               when 651 => tmpv1 := pm_setup(551, 16#e030#);
               when 652 => tmpv1 := pm_setup(552, 16#e040#);
               when 653 => tmpv1 := pm_setup(553, 16#e453#);
               when 654 => tmpv1 := pm_setup(554, 16#2f68#);
               when 655 => tmpv1 := pm_setup(555, 16#2f79#);
               when 656 => tmpv1 := pm_setup(556, 16#2f8a#);
               when 657 => tmpv1 := pm_setup(557, 16#2f9b#);
               when 658 => tmpv1 := pm_setup(558, 16#940e#);
               when 659 => tmpv1 := pm_setup(559, 16#030f#);
               when 660 => tmpv1 := pm_setup(560, 16#2fb9#);
               when 661 => tmpv1 := pm_setup(561, 16#2fa8#);
               when 662 => tmpv1 := pm_setup(562, 16#2f97#);
               when 663 => tmpv1 := pm_setup(563, 16#2f86#);
               when 664 => tmpv1 := pm_setup(564, 16#2f68#);
               when 665 => tmpv1 := pm_setup(565, 16#2f79#);
               when 666 => tmpv1 := pm_setup(566, 16#2f8a#);
               when 667 => tmpv1 := pm_setup(567, 16#2f9b#);
               when 668 => tmpv1 := pm_setup(568, 16#940e#);
               when 669 => tmpv1 := pm_setup(569, 16#02b5#);
               when 670 => tmpv1 := pm_setup(570, 16#2fb9#);
               when 671 => tmpv1 := pm_setup(571, 16#2fa8#);
               when 672 => tmpv1 := pm_setup(572, 16#2f97#);
               when 673 => tmpv1 := pm_setup(573, 16#2f86#);
               when 674 => tmpv1 := pm_setup(574, 16#2ff1#);
               when 675 => tmpv1 := pm_setup(575, 16#2fe0#);
               when 676 => tmpv1 := pm_setup(576, 16#9381#);
               when 677 => tmpv1 := pm_setup(577, 16#2f0e#);
               when 678 => tmpv1 := pm_setup(578, 16#2f1f#);
               when 679 => tmpv1 := pm_setup(579, 16#812b#);
               when 680 => tmpv1 := pm_setup(580, 16#813c#);
               when 681 => tmpv1 := pm_setup(581, 16#5f2f#);
               when 682 => tmpv1 := pm_setup(582, 16#4f3f#);
               when 683 => tmpv1 := pm_setup(583, 16#832b#);
               when 684 => tmpv1 := pm_setup(584, 16#833c#);
               when 685 => tmpv1 := pm_setup(585, 16#3025#);
               when 686 => tmpv1 := pm_setup(586, 16#0531#);
               when 687 => tmpv1 := pm_setup(587, 16#f294#);
               when 688 => tmpv1 := pm_setup(588, 16#e085#);
               when 689 => tmpv1 := pm_setup(589, 16#e090#);
               when 690 => tmpv1 := pm_setup(590, 16#0ee8#);
               when 691 => tmpv1 := pm_setup(591, 16#1ef9#);
               when 692 => tmpv1 := pm_setup(592, 16#81e9#);
               when 693 => tmpv1 := pm_setup(593, 16#81fa#);
               when 694 => tmpv1 := pm_setup(594, 16#9631#);
               when 695 => tmpv1 := pm_setup(595, 16#83e9#);
               when 696 => tmpv1 := pm_setup(596, 16#83fa#);
               when 697 => tmpv1 := pm_setup(597, 16#9735#);
               when 698 => tmpv1 := pm_setup(598, 16#f40c#);
               when 699 => tmpv1 := pm_setup(599, 16#cfb6#);
               when 700 => tmpv1 := pm_setup(600, 16#cfff#);
               when 701 => tmpv1 := pm_setup(601, 16#852d#);
               when 702 => tmpv1 := pm_setup(602, 16#853e#);
               when 703 => tmpv1 := pm_setup(603, 16#5a20#);
               when 704 => tmpv1 := pm_setup(604, 16#4f3f#);
               when 705 => tmpv1 := pm_setup(605, 16#e080#);
               when 706 => tmpv1 := pm_setup(606, 16#e090#);
               when 707 => tmpv1 := pm_setup(607, 16#e0a0#);
               when 708 => tmpv1 := pm_setup(608, 16#e0b0#);
               when 709 => tmpv1 := pm_setup(609, 16#2ff3#);
               when 710 => tmpv1 := pm_setup(610, 16#2fe2#);
               when 711 => tmpv1 := pm_setup(611, 16#8380#);
               when 712 => tmpv1 := pm_setup(612, 16#8391#);
               when 713 => tmpv1 := pm_setup(613, 16#83a2#);
               when 714 => tmpv1 := pm_setup(614, 16#83b3#);
               when 715 => tmpv1 := pm_setup(615, 16#852d#);
               when 716 => tmpv1 := pm_setup(616, 16#853e#);
               when 717 => tmpv1 := pm_setup(617, 16#532c#);
               when 718 => tmpv1 := pm_setup(618, 16#4f3f#);
               when 719 => tmpv1 := pm_setup(619, 16#2ff3#);
               when 720 => tmpv1 := pm_setup(620, 16#2fe2#);
               when 721 => tmpv1 := pm_setup(621, 16#8380#);
               when 722 => tmpv1 := pm_setup(622, 16#8391#);
               when 723 => tmpv1 := pm_setup(623, 16#83a2#);
               when 724 => tmpv1 := pm_setup(624, 16#83b3#);
               when 725 => tmpv1 := pm_setup(625, 16#cf62#);
               when 726 => tmpv1 := pm_setup(626, 16#5850#);
               when 727 => tmpv1 := pm_setup(627, 16#2e19#);
               when 728 => tmpv1 := pm_setup(628, 16#d078#);
               when 729 => tmpv1 := pm_setup(629, 16#d001#);
               when 730 => tmpv1 := pm_setup(630, 16#c05e#);
               when 731 => tmpv1 := pm_setup(631, 16#17ba#);
               when 732 => tmpv1 := pm_setup(632, 16#0762#);
               when 733 => tmpv1 := pm_setup(633, 16#0773#);
               when 734 => tmpv1 := pm_setup(634, 16#0784#);
               when 735 => tmpv1 := pm_setup(635, 16#0795#);
               when 736 => tmpv1 := pm_setup(636, 16#f1b1#);
               when 737 => tmpv1 := pm_setup(637, 16#f488#);
               when 738 => tmpv1 := pm_setup(638, 16#f40e#);
               when 739 => tmpv1 := pm_setup(639, 16#9410#);
               when 740 => tmpv1 := pm_setup(640, 16#2e0b#);
               when 741 => tmpv1 := pm_setup(641, 16#2fba#);
               when 742 => tmpv1 := pm_setup(642, 16#2da0#);
               when 743 => tmpv1 := pm_setup(643, 16#2e06#);
               when 744 => tmpv1 := pm_setup(644, 16#2f62#);
               when 745 => tmpv1 := pm_setup(645, 16#2d20#);
               when 746 => tmpv1 := pm_setup(646, 16#2e07#);
               when 747 => tmpv1 := pm_setup(647, 16#2f73#);
               when 748 => tmpv1 := pm_setup(648, 16#2d30#);
               when 749 => tmpv1 := pm_setup(649, 16#2e08#);
               when 750 => tmpv1 := pm_setup(650, 16#2f84#);
               when 751 => tmpv1 := pm_setup(651, 16#2d40#);
               when 752 => tmpv1 := pm_setup(652, 16#2e09#);
               when 753 => tmpv1 := pm_setup(653, 16#2f95#);
               when 754 => tmpv1 := pm_setup(654, 16#2d50#);
               when 755 => tmpv1 := pm_setup(655, 16#27ff#);
               when 756 => tmpv1 := pm_setup(656, 16#2355#);
               when 757 => tmpv1 := pm_setup(657, 16#f0b9#);
               when 758 => tmpv1 := pm_setup(658, 16#1b59#);
               when 759 => tmpv1 := pm_setup(659, 16#f049#);
               when 760 => tmpv1 := pm_setup(660, 16#3e57#);
               when 761 => tmpv1 := pm_setup(661, 16#f098#);
               when 762 => tmpv1 := pm_setup(662, 16#9546#);
               when 763 => tmpv1 := pm_setup(663, 16#9537#);
               when 764 => tmpv1 := pm_setup(664, 16#9527#);
               when 765 => tmpv1 := pm_setup(665, 16#95a7#);
               when 766 => tmpv1 := pm_setup(666, 16#40f0#);
               when 767 => tmpv1 := pm_setup(667, 16#9553#);
               when 768 => tmpv1 := pm_setup(668, 16#f7c9#);
               when 769 => tmpv1 := pm_setup(669, 16#f076#);
               when 770 => tmpv1 := pm_setup(670, 16#0fba#);
               when 771 => tmpv1 := pm_setup(671, 16#1f62#);
               when 772 => tmpv1 := pm_setup(672, 16#1f73#);
               when 773 => tmpv1 := pm_setup(673, 16#1f84#);
               when 774 => tmpv1 := pm_setup(674, 16#f430#);
               when 775 => tmpv1 := pm_setup(675, 16#9587#);
               when 776 => tmpv1 := pm_setup(676, 16#9577#);
               when 777 => tmpv1 := pm_setup(677, 16#9567#);
               when 778 => tmpv1 := pm_setup(678, 16#95b7#);
               when 779 => tmpv1 := pm_setup(679, 16#40f0#);
               when 780 => tmpv1 := pm_setup(680, 16#9593#);
               when 781 => tmpv1 := pm_setup(681, 16#fa17#);
               when 782 => tmpv1 := pm_setup(682, 16#2e0f#);
               when 783 => tmpv1 := pm_setup(683, 16#9508#);
               when 784 => tmpv1 := pm_setup(684, 16#1bbf#);
               when 785 => tmpv1 := pm_setup(685, 16#27bb#);
               when 786 => tmpv1 := pm_setup(686, 16#0bba#);
               when 787 => tmpv1 := pm_setup(687, 16#0b62#);
               when 788 => tmpv1 := pm_setup(688, 16#0b73#);
               when 789 => tmpv1 := pm_setup(689, 16#0b84#);
               when 790 => tmpv1 := pm_setup(690, 16#cff6#);
               when 791 => tmpv1 := pm_setup(691, 16#f6de#);
               when 792 => tmpv1 := pm_setup(692, 16#c054#);
               when 793 => tmpv1 := pm_setup(693, 16#fb97#);
               when 794 => tmpv1 := pm_setup(694, 16#d042#);
               when 795 => tmpv1 := pm_setup(695, 16#379f#);
               when 796 => tmpv1 := pm_setup(696, 16#f038#);
               when 797 => tmpv1 := pm_setup(697, 16#e9fe#);
               when 798 => tmpv1 := pm_setup(698, 16#1bf9#);
               when 799 => tmpv1 := pm_setup(699, 16#2f98#);
               when 800 => tmpv1 := pm_setup(700, 16#2f87#);
               when 801 => tmpv1 := pm_setup(701, 16#2f76#);
               when 802 => tmpv1 := pm_setup(702, 16#2f6b#);
               when 803 => tmpv1 := pm_setup(703, 16#c005#);
               when 804 => tmpv1 := pm_setup(704, 16#c045#);
               when 805 => tmpv1 := pm_setup(705, 16#9596#);
               when 806 => tmpv1 := pm_setup(706, 16#9587#);
               when 807 => tmpv1 := pm_setup(707, 16#9577#);
               when 808 => tmpv1 := pm_setup(708, 16#9567#);
               when 809 => tmpv1 := pm_setup(709, 16#50f1#);
               when 810 => tmpv1 := pm_setup(710, 16#f7d0#);
               when 811 => tmpv1 := pm_setup(711, 16#f43e#);
               when 812 => tmpv1 := pm_setup(712, 16#9590#);
               when 813 => tmpv1 := pm_setup(713, 16#9580#);
               when 814 => tmpv1 := pm_setup(714, 16#9570#);
               when 815 => tmpv1 := pm_setup(715, 16#9561#);
               when 816 => tmpv1 := pm_setup(716, 16#4f7f#);
               when 817 => tmpv1 := pm_setup(717, 16#4f8f#);
               when 818 => tmpv1 := pm_setup(718, 16#4f9f#);
               when 819 => tmpv1 := pm_setup(719, 16#9508#);
               when 820 => tmpv1 := pm_setup(720, 16#959a#);
               when 821 => tmpv1 := pm_setup(721, 16#0fbb#);
               when 822 => tmpv1 := pm_setup(722, 16#1f66#);
               when 823 => tmpv1 := pm_setup(723, 16#1f77#);
               when 824 => tmpv1 := pm_setup(724, 16#1f88#);
               when 825 => tmpv1 := pm_setup(725, 16#2411#);
               when 826 => tmpv1 := pm_setup(726, 16#2399#);
               when 827 => tmpv1 := pm_setup(727, 16#f0a1#);
               when 828 => tmpv1 := pm_setup(728, 16#2388#);
               when 829 => tmpv1 := pm_setup(729, 16#f7b2#);
               when 830 => tmpv1 := pm_setup(730, 16#3f9f#);
               when 831 => tmpv1 := pm_setup(731, 16#f059#);
               when 832 => tmpv1 := pm_setup(732, 16#0fbb#);
               when 833 => tmpv1 := pm_setup(733, 16#f448#);
               when 834 => tmpv1 := pm_setup(734, 16#f421#);
               when 835 => tmpv1 := pm_setup(735, 16#2000#);
               when 836 => tmpv1 := pm_setup(736, 16#f411#);
               when 837 => tmpv1 := pm_setup(737, 16#ff60#);
               when 838 => tmpv1 := pm_setup(738, 16#c004#);
               when 839 => tmpv1 := pm_setup(739, 16#5f6f#);
               when 840 => tmpv1 := pm_setup(740, 16#4f7f#);
               when 841 => tmpv1 := pm_setup(741, 16#4f8f#);
               when 842 => tmpv1 := pm_setup(742, 16#4f9f#);
               when 843 => tmpv1 := pm_setup(743, 16#1f88#);
               when 844 => tmpv1 := pm_setup(744, 16#9597#);
               when 845 => tmpv1 := pm_setup(745, 16#9587#);
               when 846 => tmpv1 := pm_setup(746, 16#f997#);
               when 847 => tmpv1 := pm_setup(747, 16#9508#);
               when 848 => tmpv1 := pm_setup(748, 16#c019#);
               when 849 => tmpv1 := pm_setup(749, 16#2e05#);
               when 850 => tmpv1 := pm_setup(750, 16#2609#);
               when 851 => tmpv1 := pm_setup(751, 16#fa07#);
               when 852 => tmpv1 := pm_setup(752, 16#0f44#);
               when 853 => tmpv1 := pm_setup(753, 16#1f55#);
               when 854 => tmpv1 := pm_setup(754, 16#3f5f#);
               when 855 => tmpv1 := pm_setup(755, 16#f079#);
               when 856 => tmpv1 := pm_setup(756, 16#27aa#);
               when 857 => tmpv1 := pm_setup(757, 16#17a5#);
               when 858 => tmpv1 := pm_setup(758, 16#f008#);
               when 859 => tmpv1 := pm_setup(759, 16#e051#);
               when 860 => tmpv1 := pm_setup(760, 16#9547#);
               when 861 => tmpv1 := pm_setup(761, 16#0f88#);
               when 862 => tmpv1 := pm_setup(762, 16#1f99#);
               when 863 => tmpv1 := pm_setup(763, 16#3f9f#);
               when 864 => tmpv1 := pm_setup(764, 16#f031#);
               when 865 => tmpv1 := pm_setup(765, 16#27bb#);
               when 866 => tmpv1 := pm_setup(766, 16#17b9#);
               when 867 => tmpv1 := pm_setup(767, 16#f008#);
               when 868 => tmpv1 := pm_setup(768, 16#e091#);
               when 869 => tmpv1 := pm_setup(769, 16#9587#);
               when 870 => tmpv1 := pm_setup(770, 16#9508#);
               when 871 => tmpv1 := pm_setup(771, 16#919f#);
               when 872 => tmpv1 := pm_setup(772, 16#919f#);
               when 873 => tmpv1 := pm_setup(773, 16#c057#);
               when 874 => tmpv1 := pm_setup(774, 16#2766#);
               when 875 => tmpv1 := pm_setup(775, 16#2777#);
               when 876 => tmpv1 := pm_setup(776, 16#2788#);
               when 877 => tmpv1 := pm_setup(777, 16#2799#);
               when 878 => tmpv1 := pm_setup(778, 16#9508#);
               when 879 => tmpv1 := pm_setup(779, 16#2f59#);
               when 880 => tmpv1 := pm_setup(780, 16#2f48#);
               when 881 => tmpv1 := pm_setup(781, 16#2f37#);
               when 882 => tmpv1 := pm_setup(782, 16#2f26#);
               when 883 => tmpv1 := pm_setup(783, 16#dfdd#);
               when 884 => tmpv1 := pm_setup(784, 16#d001#);
               when 885 => tmpv1 := pm_setup(785, 16#cfc3#);
               when 886 => tmpv1 := pm_setup(786, 16#2399#);
               when 887 => tmpv1 := pm_setup(787, 16#f039#);
               when 888 => tmpv1 := pm_setup(788, 16#2355#);
               when 889 => tmpv1 := pm_setup(789, 16#f029#);
               when 890 => tmpv1 := pm_setup(790, 16#579f#);
               when 891 => tmpv1 := pm_setup(791, 16#575f#);
               when 892 => tmpv1 := pm_setup(792, 16#0f95#);
               when 893 => tmpv1 := pm_setup(793, 16#f413#);
               when 894 => tmpv1 := pm_setup(794, 16#f1ca#);
               when 895 => tmpv1 := pm_setup(795, 16#cfed#);
               when 896 => tmpv1 := pm_setup(796, 16#5891#);
               when 897 => tmpv1 := pm_setup(797, 16#3f9f#);
               when 898 => tmpv1 := pm_setup(798, 16#f3e1#);
               when 899 => tmpv1 := pm_setup(799, 16#2fa6#);
               when 900 => tmpv1 := pm_setup(800, 16#2400#);
               when 901 => tmpv1 := pm_setup(801, 16#2411#);
               when 902 => tmpv1 := pm_setup(802, 16#27bb#);
               when 903 => tmpv1 := pm_setup(803, 16#2766#);
               when 904 => tmpv1 := pm_setup(804, 16#2755#);
               when 905 => tmpv1 := pm_setup(805, 16#e0f8#);
               when 906 => tmpv1 := pm_setup(806, 16#95a6#);
               when 907 => tmpv1 := pm_setup(807, 16#f420#);
               when 908 => tmpv1 := pm_setup(808, 16#0e02#);
               when 909 => tmpv1 := pm_setup(809, 16#1e13#);
               when 910 => tmpv1 := pm_setup(810, 16#1fb4#);
               when 911 => tmpv1 := pm_setup(811, 16#1f65#);
               when 912 => tmpv1 := pm_setup(812, 16#0f22#);
               when 913 => tmpv1 := pm_setup(813, 16#1f33#);
               when 914 => tmpv1 := pm_setup(814, 16#1f44#);
               when 915 => tmpv1 := pm_setup(815, 16#1f55#);
               when 916 => tmpv1 := pm_setup(816, 16#95fa#);
               when 917 => tmpv1 := pm_setup(817, 16#f7a1#);
               when 918 => tmpv1 := pm_setup(818, 16#e0f8#);
               when 919 => tmpv1 := pm_setup(819, 16#2fe7#);
               when 920 => tmpv1 := pm_setup(820, 16#2777#);
               when 921 => tmpv1 := pm_setup(821, 16#e0f8#);
               when 922 => tmpv1 := pm_setup(822, 16#95e6#);
               when 923 => tmpv1 := pm_setup(823, 16#f420#);
               when 924 => tmpv1 := pm_setup(824, 16#0e13#);
               when 925 => tmpv1 := pm_setup(825, 16#1fb4#);
               when 926 => tmpv1 := pm_setup(826, 16#1f65#);
               when 927 => tmpv1 := pm_setup(827, 16#1f7a#);
               when 928 => tmpv1 := pm_setup(828, 16#0f33#);
               when 929 => tmpv1 := pm_setup(829, 16#1f44#);
               when 930 => tmpv1 := pm_setup(830, 16#1f55#);
               when 931 => tmpv1 := pm_setup(831, 16#1faa#);
               when 932 => tmpv1 := pm_setup(832, 16#95fa#);
               when 933 => tmpv1 := pm_setup(833, 16#f7a1#);
               when 934 => tmpv1 := pm_setup(834, 16#2ff8#);
               when 935 => tmpv1 := pm_setup(835, 16#2788#);
               when 936 => tmpv1 := pm_setup(836, 16#95f6#);
               when 937 => tmpv1 := pm_setup(837, 16#f420#);
               when 938 => tmpv1 := pm_setup(838, 16#0fb4#);
               when 939 => tmpv1 := pm_setup(839, 16#1f65#);
               when 940 => tmpv1 := pm_setup(840, 16#1f7a#);
               when 941 => tmpv1 := pm_setup(841, 16#1f8e#);
               when 942 => tmpv1 := pm_setup(842, 16#0f44#);
               when 943 => tmpv1 := pm_setup(843, 16#1f55#);
               when 944 => tmpv1 := pm_setup(844, 16#1faa#);
               when 945 => tmpv1 := pm_setup(845, 16#1fee#);
               when 946 => tmpv1 := pm_setup(846, 16#23ff#);
               when 947 => tmpv1 := pm_setup(847, 16#f7a1#);
               when 948 => tmpv1 := pm_setup(848, 16#2388#);
               when 949 => tmpv1 := pm_setup(849, 16#f41a#);
               when 950 => tmpv1 := pm_setup(850, 16#9593#);
               when 951 => tmpv1 := pm_setup(851, 16#f439#);
               when 952 => tmpv1 := pm_setup(852, 16#c008#);
               when 953 => tmpv1 := pm_setup(853, 16#0c00#);
               when 954 => tmpv1 := pm_setup(854, 16#1c11#);
               when 955 => tmpv1 := pm_setup(855, 16#1fbb#);
               when 956 => tmpv1 := pm_setup(856, 16#1f66#);
               when 957 => tmpv1 := pm_setup(857, 16#1f77#);
               when 958 => tmpv1 := pm_setup(858, 16#1f88#);
               when 959 => tmpv1 := pm_setup(859, 16#2801#);
               when 960 => tmpv1 := pm_setup(860, 16#9508#);
               when 961 => tmpv1 := pm_setup(861, 16#ef9f#);
               when 962 => tmpv1 := pm_setup(862, 16#ec80#);
               when 963 => tmpv1 := pm_setup(863, 16#9508#);
-- </Instructions>

               when others =>
                  null;
            end case;
            pm_sel   <= pm_sel_usr;
            pm_wr    <= '1';
            pm_addr  <= tmpv1(tmpv1'length-1 downto 16);
            pm_di    <= tmpv1(15 downto 0);
            -- Keep the controller in reset state until the Program Memory is prepared.
            pavr_pavr_res     <= '1';
            pavr_pavr_syncres <= '1';
         else
            pm_sel   <= pm_sel_pavr;
            pm_wr    <= '0';
            pm_addr  <= int_to_std_logic_vector(0, pm_addr'length);
            pm_di    <= int_to_std_logic_vector(0, pm_di'length);
            -- Now the Program Memory is prepared. Free the beast.
            pavr_pavr_res     <= '0';
            pavr_pavr_syncres <= '0';
         end if;

         if pavr_pavr_res='1' or pavr_pavr_syncres='1' then
            instr_cnt   <= int_to_std_logic_vector(0, instr_cnt'length);
            run_clk_cnt <= int_to_std_logic_vector(0, run_clk_cnt'length);
         end if;

         if syncres='1' then
            -- Sync reset

            -- Reset the controller in turn.
            pavr_pavr_syncres <= '1';

            main_clk_cnt <= int_to_std_logic_vector(0, main_clk_cnt'length);
            run_clk_cnt  <= int_to_std_logic_vector(0, run_clk_cnt'length);
            instr_cnt    <= int_to_std_logic_vector(0, instr_cnt'length);
         end if;
      end if;
   end process test_main;


   -- Connect components.
   select_muxers:
   process(pavr_pavr_pm_addr, pm_addr, pm_sel)
   begin
      if pm_sel=pm_sel_pavr then
         pm_pavr_pm_addr <= pavr_pavr_pm_addr;
      else
         pm_pavr_pm_addr <= pm_addr;
      end if;
   end process select_muxers;
   pm_pavr_pm_wr     <= pm_wr;
   pm_pavr_pm_di     <= pm_di;
   pavr_pavr_pm_do   <= pm_pavr_pm_do;

end;
-- </File body>
