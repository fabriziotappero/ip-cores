---------------------------------------------------------------------
----                                                             ----
----  FPU                                                        ----
----  Floating Point Unit (Double precision)                     ----
----                                                             ----
----  Author: David Lundgren                                     ----
----          davidklun@gmail.com                                ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2009 David Lundgren                           ----
----                  davidklun@gmail.com                        ----
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

library  ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fpupack.all;

package comppack is


--- Component Declarations ---	
	
	component fpu_add is
	 PORT( 
      clk : IN     std_logic;
      rst : IN     std_logic;
      enable  : IN     std_logic;
      opa : IN     std_logic_vector (63 DOWNTO 0);
      opb : IN     std_logic_vector (63 DOWNTO 0);
      sign : OUT    std_logic;
      sum_3 : OUT    std_logic_vector (55 DOWNTO 0);
      exponent_2 : OUT    std_logic_vector (10 DOWNTO 0)
   );
	end component;
	
	component fpu_sub is 
		 PORT( 
	  clk : IN     std_logic;
      rst : IN     std_logic;
      enable  : IN     std_logic;
      opa : IN     std_logic_vector (63 DOWNTO 0);
      opb : IN     std_logic_vector (63 DOWNTO 0);
      fpu_op : IN     std_logic_vector (2 DOWNTO 0);
      sign : OUT    std_logic;
      diff_2 : OUT    std_logic_vector (55 DOWNTO 0);
      exponent_2 : OUT    std_logic_vector (10 DOWNTO 0)
   );
	end component;
	
	component fpu_mul is
	port(
		    clk : IN     std_logic;
      		rst : IN     std_logic;
      		enable  : IN     std_logic;
      		opa : IN     std_logic_vector (63 DOWNTO 0);
      		opb : IN     std_logic_vector (63 DOWNTO 0);
      		sign : OUT    std_logic;
      		product_7 : OUT    std_logic_vector (55 DOWNTO 0);
      		exponent_5 : OUT    std_logic_vector (11 DOWNTO 0)
		);
	end component;
	
	component fpu_div is
	port(
		   	clk, rst, enable : IN     std_logic;
      		opa, opb : IN     std_logic_vector (63 DOWNTO 0);
      		sign : OUT    std_logic;
      		mantissa_7 : OUT    std_logic_vector (55 DOWNTO 0);
      		exponent_out : OUT    std_logic_vector (11 DOWNTO 0)
			 );
	end component;
	
	component fpu_round is
	port(
			   	clk, rst, enable : IN     std_logic;
     			round_mode : IN     std_logic_vector (1 DOWNTO 0);
     			sign_term : IN    std_logic;
     			mantissa_term : IN     std_logic_vector (55 DOWNTO 0);
     			exponent_term : IN     std_logic_vector (11 DOWNTO 0);
     			round_out : OUT    std_logic_vector (63 DOWNTO 0);
     			exponent_final : OUT    std_logic_vector (11 DOWNTO 0)
			 );
	end component;
	
	component fpu_exceptions is
	port(
			  clk, rst, enable : IN     std_logic;
   			  rmode : IN     std_logic_vector (1 DOWNTO 0);
   			  opa, opb, in_except : IN     std_logic_vector (63 DOWNTO 0);
   			  exponent_in : IN     std_logic_vector (11 DOWNTO 0);
   			  mantissa_in : IN     std_logic_vector (1 DOWNTO 0);
   			  fpu_op : IN     std_logic_vector (2 DOWNTO 0);
   			  out_fp : OUT    std_logic_vector (63 DOWNTO 0);
   			  ex_enable, underflow, overflow, inexact : OUT    std_logic;
   			  exception, invalid : OUT    std_logic
		);
	end component;
	
	
		
end comppack;