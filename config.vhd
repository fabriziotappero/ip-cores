--this is place were configuration to the port MAC and IP AND subnet mask is written to all the load Balancer
LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;

package config is

	TYPE mac_type IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(47 DOWNTO 0);
	CONSTANT mac_array : mac_type:=(X"AAAAAAAAAAAA", X"BBBBBBBBBBBB", X"CCCCCCCCCCCC", X"DDDDDDDDDDDD");
	TYPE ip_type IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	CONSTANT ip_array : ip_type:=(X"C0A80101", X"C0A80201",X"C0A80301",X"C0A80401");
	TYPE subnet_type IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	CONSTANT subnet_array : subnet_type:=(X"FFFFFF00", X"FFFFFF00",X"FFFFFF00",X"FFFFFF00");
	TYPE vlan_type IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(11 DOWNTO 0);
	CONSTANT vlan_array : vlan_type:=(X"002", X"003",X"004",X"005");
	TYPE status_type IS ARRAY (0 TO 3) OF STD_LOGIC;
	CONSTANT status_array : status_type:=('1','1','0','0');
	--  DIST message configuration--------------
	--	DIST_MULTICAST_ALL
	--	DIST_MULTICAST_LB
	--	DIST_PORT
	--	|0 		 7|8 	  15|16 			  32|
	--	+---------+---------+-------------------+
	--	| VERSION | MSGType | NodeId 			|
	--	+---------+---------+-------------------+
	--	| Flags   | NodeType					|
	--	+---------+---------+-------------------+
	--	| MSGSeqnum 		| MSGLength 		|
	--	+-------------------+-------------------+
	CONSTANT VC_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0) :=X"010101010101";--255.255.255.255
	CONSTANT DIST_MULTICAST_ALL : STD_LOGIC_VECTOR(31 DOWNTO 0) :=X"FFFFFFFF";--255.255.255.255
	CONSTANT DIST_MULTICAST_LB  : STD_LOGIC_VECTOR(31 DOWNTO 0) :=X"EFFFFFFF";--239.255.255.255
	CONSTANT DIST_UNICAST_LB    : STD_LOGIC_VECTOR(31 DOWNTO 0) :=X"C0A80501";--192.168.5.1
	CONSTANT DIST_PORT			: STD_LOGIC_VECTOR(15 DOWNTO 0) :=X"8989";
	CONSTANT DIST_VER			: STD_LOGIC_VECTOR(7 DOWNTO 0)  :=X"01";
	CONSTANT DIST_MSGTYPE		: STD_LOGIC_VECTOR(7 DOWNTO 0)  :=X"01";--Hello Mesages
	CONSTANT NODE_ID			: STD_LOGIC_VECTOR(15 DOWNTO 0) :=X"4545";
	CONSTANT NODE_TYPE			: STD_LOGIC_VECTOR(23 DOWNTO 0) :=X"000003";--LoadBalancer
	CONSTANT AGING_TIMEOUT		: INTEGER						:=125000;--LoadBalancer
	CONSTANT TIMER_PERIOD		: INTEGER						:=5250000;	
	CONSTANT DEFAULT_INT_PORT			: STD_LOGIC_VECTOR(15 DOWNTO 0) :=X"0001";

end config; 

