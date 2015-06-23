-- ------------------------------------------------------------------------
-- Copyright (C) 2005 Arif Endro Nugroho
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY ARIF ENDRO NUGROHO "AS IS" AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ARIF ENDRO NUGROHO BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
-- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-- 
-- End Of License.
-- ------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity modelsim_bench is
end modelsim_bench;

architecture structural of modelsim_bench is

  component mini_aes
    port (
      clock          : in  std_logic;
      clear          : in  std_logic;
      load_i         : in  std_logic;
      enc            : in  std_logic;
      key_i          : in  std_logic_vector (007 downto 000);
      data_i         : in  std_logic_vector (007 downto 000);
      data_o         : out std_logic_vector (007 downto 000);
      done_o         : out std_logic
      );
  end component;
--
  component input
    port (
      clock          : out std_logic;
      load           : out std_logic;
      done           : in  std_logic;
      test_iteration : out integer;
      key_i_byte     : out std_logic_vector (007 downto 000);
      data_i_byte    : out std_logic_vector (007 downto 000);
      cipher_o_byte  : out std_logic_vector (007 downto 000)
      );
  end component;
--
  component output
    port (
      clock          : in  std_logic;
      clear          : in  std_logic;
      load           : in  std_logic;
      enc            : in  std_logic;
      done           : in  std_logic;
      test_iteration : in  integer;
      verifier       : in  std_logic_vector (007 downto 000);
      data_o         : in  std_logic_vector (007 downto 000)
      );
  end component;

  signal load_enc           : std_logic;
  signal load_dec           : std_logic;
  signal clock_enc          : std_logic;
  signal clock_dec          : std_logic;
  signal done_dec           : std_logic;
  signal done_enc           : std_logic;
  signal test_iteration_enc : integer;
  signal test_iteration_dec : integer;
  signal cipher_o_enc       : std_logic_vector (007 downto 000);
  signal cipher_o_dec       : std_logic_vector (007 downto 000);
  signal data_i_enc         : std_logic_vector (007 downto 000);
  signal data_i_dec         : std_logic_vector (007 downto 000);
  signal data_o_enc         : std_logic_vector (007 downto 000);
  signal data_o_dec         : std_logic_vector (007 downto 000);
  signal key_i_enc          : std_logic_vector (007 downto 000);
  signal key_i_dec          : std_logic_vector (007 downto 000);

begin

  my_aes_enc    : mini_aes
    port map (
      clock          => clock_enc,
      clear          => '0',
      load_i         => load_enc,
      enc            => '0',
      key_i          => key_i_enc,
      data_i         => data_i_enc,
      data_o         => data_o_enc,
      done_o         => done_enc
      );
--
  my_aes_dec    : mini_aes
    port map (
      clock          => clock_dec,
      clear          => '0',
      load_i         => load_dec,
      enc            => '1',
      key_i          => key_i_dec,
      data_i         => cipher_o_dec,
      data_o         => data_o_dec,
      done_o         => done_dec
      );
--
  my_input_enc  : input
    port map (
      clock          => clock_enc,
      load           => load_enc,
      done           => done_enc,
      test_iteration => test_iteration_enc,
      key_i_byte     => key_i_enc,
      data_i_byte    => data_i_enc,
      cipher_o_byte  => cipher_o_enc
      );
  my_input_dec  : input
    port map (
      clock          => clock_dec,
      load           => load_dec,
      done           => done_dec,
      test_iteration => test_iteration_dec,
      data_i_byte    => data_i_dec,
      cipher_o_byte  => cipher_o_dec,
      key_i_byte     => key_i_dec
      );
--
  my_output_enc : output
    port map (
      clock          => clock_enc,
      clear          => '0',
      load           => load_enc,
      enc            => '0',
      done           => done_enc,
      test_iteration => test_iteration_enc,
      verifier       => cipher_o_enc,
      data_o         => data_o_enc
      );
--
  my_output_dec : output
    port map (
      clock          => clock_dec,
      clear          => '0',
      load           => load_dec,
      enc            => '1',
      done           => done_dec,
      test_iteration => test_iteration_dec,
      verifier       => data_i_dec,
      data_o         => data_o_dec
      );

end structural;
