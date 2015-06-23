---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2000 Richard Herveille                        ----
----                    richard@asics.ws                         ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------
-- Package containing i2c master byte controller component. Component
-- declaration separated into this file by jan@gaisler.com.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package i2coc is
  component i2c_master_byte_ctrl is
   port (
     clk    : in std_logic;
     rst    : in std_logic;   -- active high reset
     nReset : in std_logic;   -- asynchornous active low reset
                              -- (not used in GRLIB)
     ena    : in std_logic; -- core enable signal
     
     clk_cnt : in std_logic_vector(15 downto 0);	-- 4x SCL

     -- input signals
     start,
     stop,
     read,
     write,
     ack_in : std_logic;
     din    : in std_logic_vector(7 downto 0);

     -- output signals
     cmd_ack  : out std_logic;
     ack_out  : out std_logic;
     i2c_busy : out std_logic;
     i2c_al   : out std_logic;
     dout     : out std_logic_vector(7 downto 0);

     -- i2c lines
     scl_i   : in std_logic;  -- i2c clock line input
     scl_o   : out std_logic; -- i2c clock line output
     scl_oen : out std_logic; -- i2c clock line output enable, active low
     sda_i   : in std_logic;  -- i2c data line input
     sda_o   : out std_logic; -- i2c data line output
     sda_oen : out std_logic  -- i2c data line output enable, active low
     );
  end component i2c_master_byte_ctrl;
end;
