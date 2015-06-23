library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package pkt_desc_pkg is

type pkt_desc is record
    pkt : unsigned(31 downto 0);
    seq : unsigned(15 downto 0);
    valid : std_logic;
    confirmed : std_logic;
    sent : std_logic;
    flushed : std_logic;
end record;

constant pkt_desc_width : integer := 52;

function pkt_desc_to_stlv(
  constant din : pkt_desc)
  return std_logic_vector;

function stlv_to_pkt_desc(
  constant din : std_logic_vector)
  return pkt_desc;

end pkt_desc_pkg;

package body pkt_desc_pkg is

function pkt_desc_to_stlv(
  constant din : pkt_desc)
  return std_logic_vector is
  variable res : std_logic_vector(51 downto 0);
begin
  res(31 downto 0) := std_logic_vector(din.pkt);
  res(47 downto 32) := std_logic_vector(din.seq);
  res(48) := din.valid;
  res(49) := din.confirmed;
  res(50) := din.sent;
  res(51) := din.flushed;
  return res;
end pkt_desc_to_stlv;

function stlv_to_pkt_desc(
  constant din : std_logic_vector)
  return pkt_desc is
  variable res : pkt_desc;
begin
  res.pkt:=unsigned(din(31 downto 0));
  res.seq:=unsigned(din(47 downto 32));
  res.valid := din(48);
  res.confirmed := din(49);
  res.sent := din(50);
  res.flushed := din(51);
  return res;
end stlv_to_pkt_desc;

end pkt_desc_pkg;
