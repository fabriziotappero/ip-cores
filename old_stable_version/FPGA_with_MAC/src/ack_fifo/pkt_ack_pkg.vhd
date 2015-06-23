library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package pkt_ack_pkg is

type pkt_ack is record
    pkt : unsigned(7 downto 0);
    set : unsigned(15 downto 0);
    cmd : unsigned(7 downto 0);
end record;

constant pkt_ack_width : integer := 32;

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
  variable res : std_logic_vector(31 downto 0);
begin
  res(7 downto 0) := std_logic_vector(din.pkt);
  res(23 downto 8) := std_logic_vector(din.set);
  res(31 downto 24) := std_logic_vector(din.cmd);
  return res;
end pkt_ack_to_stlv;

function stlv_to_pkt_ack(
  constant din : std_logic_vector)
  return pkt_ack is
  variable res : pkt_ack;
begin
  res.pkt:=unsigned(din(7 downto 0));
  res.set:=unsigned(din(23 downto 8));
  res.cmd:=unsigned(din(31 downto 24));
  return res;
end stlv_to_pkt_ack;

end pkt_ack_pkg;
