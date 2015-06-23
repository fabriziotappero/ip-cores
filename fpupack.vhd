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

package fpupack is

    -- count the number of zeros starting from the left
    function count_l_zeros (signal s_vector: std_logic_vector) return std_logic_vector;
    function count_zeros_mul (signal s_vector: std_logic_vector) return std_logic_vector;
    
end fpupack;

package body fpupack is
    
	function count_l_zeros (signal s_vector: std_logic_vector) return std_logic_vector is
		variable v_count : std_logic_vector(5 downto 0);	
	begin
		v_count := "000000";
		for i in s_vector'range loop
			case s_vector(i) is
				when '0' => v_count := v_count + "000001";
				when others => exit;
			end case;
		end loop;
		return v_count;	
	end count_l_zeros;
		
	-- count the zeros from the left for multiply
	function count_zeros_mul (signal s_vector: std_logic_vector) return std_logic_vector is
		variable v_count : std_logic_vector(5 downto 0);	
	begin
		v_count := "000000";
		for i in 105 downto 52 loop
			case s_vector(i) is
				when '0' => v_count := v_count + "000001";
				when others => exit;
			end case;
		end loop;
		return v_count;	
	end count_zeros_mul;
end fpupack;