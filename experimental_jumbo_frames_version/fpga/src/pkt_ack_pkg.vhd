library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package pkt_ack_pkg is

type pkt_ack is record
    pkt : unsigned(31 downto 0);
    seq : unsigned(15 downto 0);
    cmd : unsigned(15 downto 0);
end record;

constant pkt_ack_width : integer := 64;

function pkt_ack_to_stlv(
  constant din : pkt_ack)
  return std_logic_vector;

function stlv_to_pkt_ack(
  constant din : std_logic_vector)
  return pkt_ack;

end pkt_ack_pkg;

package body pkt_ack_pkg is

function pkt_ack_to_stlv(
  constant din : pkt_ack)
  return std_logic_vector is
  variable res : std_logic_vector(63 downto 0);
begin
  res(31 downto 0) := std_logic_vector(din.pkt);
  res(47 downto 32) := std_logic_vector(din.seq);
  res(63 downto 48) := std_logic_vector(din.cmd);
  return res;
end pkt_ack_to_stlv;

function stlv_to_pkt_ack(
  constant din : std_logic_vector)
  return pkt_ack is
  variable res : pkt_ack;
begin
  res.pkt:=unsigned(din(31 downto 0));
  res.seq:=unsigned(din(47 downto 32));
  res.cmd:=unsigned(din(63 downto 48));
  return res;
end stlv_to_pkt_ack;

end pkt_ack_pkg;
