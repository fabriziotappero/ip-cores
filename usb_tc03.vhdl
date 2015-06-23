--==========================================================================--
--                                                                          --
--  Copyright (C) 2011  by  Martin Neumann martin@neumanns-mail.de          --
--                                                                          --
--  File name   : usb_tc03.vhd                                              --
--  Author      : Martin Neumann  martin@neumanns-mail.de                   --
--  Description : Copy and rename this file to usb_stimuli.vhd              --
--                before running a new simulation!                          --
--                                                                          --
--==========================================================================--
--                                                                          --
-- Change history                                                           --
--                                                                          --
-- Version / date        Description                                        --
--                                                                          --
-- 01  15 Mar 2013 MN    Initial version                                    --
--                                                                          --
-- End change history                                                       --
--==========================================================================--

LIBRARY work, IEEE;
  USE IEEE.std_logic_1164.ALL;
  USE IEEE.std_logic_arith.ALL;
  USE work.usb_commands.ALL;

ENTITY USB_Stimuli IS PORT(
  -- Test Control Interface --
  USB             : OUT usb_action;
  rst_neg_ext     : OUT STD_LOGIC;
  t_no            : OUT NATURAL
);
END USB_Stimuli;

ARCHITECTURE sim OF usb_stimuli IS

BEGIN
--==========================================================================--
-- All outcommented procedure calls reflect the expected USB Slave response --
--==========================================================================--
  p_stimuli_data : PROCESS
  variable top : NATURAL;
  BEGIN
    list("**********************************");
    list("*                                *");
    list("*       Test USB FS SLAVE        *");
    list("* Init according to Win 7 driver *");
    list("*                                *");
    list("**********************************");
    rst_neg_ext <= '0';
    WAIT FOR 301 ns;
    rst_neg_ext <= '1';
    WAIT FOR 400 ns;
    --***************************************--
    list(T_No, 01);
    send_res(usb);
    sof_token(usb, X"55D");
    sof_token(usb, X"55E");
    sof_token(usb, X"55F");
    setup(usb, X"00",X"0"); -- GET_DESCRIPTOR
    send_D0   (usb, (X"80",X"06",X"00",X"01",X"00",X"00",X"40",X"00"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"00",X"0");
    wait_slv  (usb);
--  recv_D1   (usb, (X"12",X"01",X"10",X"01",X"02",X"00",X"00",X"40",
--                   X"9A",X"FB",X"9A",X"FB",X"20",X"00",X"00",X"00",
--                   X"00",X"01"));
    send_ACK  (usb);
    out_token(usb, X"00",X"0");
    send_D1   (usb);
    wait_slv  (usb);
--  recv_ACK  (usb);
    send_res(usb);
    list(T_No, 02);
    --***************************************--
    setup(usb, X"00",X"0"); -- SET_ADDRESS
    send_D0   (usb, (X"00",X"05",X"02",X"00",X"00",X"00",X"00",X"00"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"00",X"0");
    wait_slv  (usb);
--  recv_D1   (usb);
    send_ACK  (usb);
    list(T_No, 03);
    --***************************************--
    setup(usb, X"02",X"0"); -- GET_DESCRIPTOR 1
    send_D0   (usb, (X"80",X"06",X"00",X"01",X"00",X"00",X"12",X"00"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D1   (usb, (X"12",X"01",X"10",X"01",X"02",X"00",X"00",X"40",
--                   X"9A",X"FB",X"9A",X"FB",X"20",X"00",X"00",X"00",
--                   X"00",X"01"));
    send_ACK  (usb);
    out_token(usb, X"02",X"0");
    send_D1   (usb);
    wait_slv  (usb);
--  recv_ACK  (usb);
    list(T_No, 04);
    --***************************************--
    setup(usb, X"02",X"0"); -- GET_DESCRIPTOR 2
    send_D0   (usb, (X"80",X"06",X"00",X"02",X"00",X"00",X"FF",X"00"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D1   (usb, (X"09",X"02",X"43",X"00",X"02",X"01",X"00",X"80",
--                   X"FA",X"09",X"04",X"00",X"00",X"01",X"02",X"02",
--                   X"01",X"00",X"05",X"24",X"00",X"10",X"01",X"04",
--                   X"24",X"02",X"00",X"05",X"24",X"06",X"00",X"01",
--                   X"05",X"24",X"01",X"00",X"01",X"07",X"05",X"82",
--                   X"03",X"08",X"00",X"FF",X"09",X"04",X"01",X"00",
--                   X"02",X"0A",X"00",X"00",X"00",X"07",X"05",X"81",
--                   X"02",X"40",X"00",X"00",X"07",X"05",X"01",X"02"));
    send_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D0   (usb, (X"40",X"00",X"00"));
    send_ACK  (usb);
    out_token(usb, X"02",X"0");
    send_D1   (usb);
    wait_slv  (usb);
--  recv_ACK  (usb);
    list(T_No, 05);
    --***************************************--
    setup(usb, X"02",X"0"); -- GET_DESCRIPTOR 1
    send_D0   (usb, (X"80",X"06",X"00",X"01",X"00",X"00",X"12",X"00"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D1   (usb, (X"12",X"01",X"10",X"01",X"02",X"00",X"00",X"40",
--                   X"9A",X"FB",X"9A",X"FB",X"20",X"00",X"00",X"00",
--                   X"00",X"01"));
    send_ACK  (usb);
    out_token(usb, X"02",X"0");
    send_D1   (usb);
    wait_slv  (usb);
--  recv_ACK  (usb);
    list(T_No, 06);
    --***************************************--
    setup(usb, X"02",X"0"); -- GET_DESCRIPTOR 2
    send_D0   (usb, (X"80",X"06",X"00",X"02",X"00",X"00",X"09",X"01"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D1   (usb, (X"09",X"02",X"43",X"00",X"02",X"01",X"00",X"80",
--                   X"FA",X"09",X"04",X"00",X"00",X"01",X"02",X"02",
--                   X"01",X"00",X"05",X"24",X"00",X"10",X"01",X"04",
--                   X"24",X"02",X"00",X"05",X"24",X"06",X"00",X"01",
--                   X"05",X"24",X"01",X"00",X"01",X"07",X"05",X"82",
--                   X"03",X"08",X"00",X"FF",X"09",X"04",X"01",X"00",
--                   X"02",X"0A",X"00",X"00",X"00",X"07",X"05",X"81",
--                   X"02",X"40",X"00",X"00",X"07",X"05",X"01",X"02"));
    send_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D0   (usb, (X"40",X"00",X"00"));
    send_ACK  (usb);
    out_token(usb, X"02",X"0");
    send_D1   (usb);
    wait_slv  (usb);
--  recv_ACK  (usb);
    list(T_No, 07);
    --***************************************--
    setup(usb, X"02",X"0"); -- SET_CONFIGURATION
    send_D0   (usb, (X"00",X"09",X"01",X"00",X"00",X"00",X"00",X"00"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D1   (usb);
    send_ACK  (usb);
    list(T_No, 08);
    --***************************************--
    setup(usb, X"02",X"0");
    send_D0   (usb, (X"A1",X"21",X"00",X"00",X"00",X"00",X"07",X"00"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D1   (usb);
    send_ACK  (usb);
    out_token(usb, X"02",X"0");
    send_D1   (usb);
    wait_slv  (usb);
--  recv_ACK  (usb);
    list(T_No, 09);
    --***************************************--
    setup(usb, X"02",X"0");
    send_D0   (usb, (X"21",X"22",X"00",X"00",X"00",X"00",X"00",X"00"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    in_token(usb, X"02",X"0");
    wait_slv  (usb);
--  recv_D1   (usb);
    send_ACK  (usb);
    list("write and read 3x 64 bytes to - from engine 1");
--==========================================================================--
--  Win 7 configuration sequence has been completed - applicatioon starting --
--  First engine 1 transfer after setup -> data toggle bit starts with 0 !! --
--==========================================================================--
    list(T_No, 10);
    out_token(usb, X"02",X"1");
    send_D0   (usb, (X"00",X"01",X"02",X"03",X"04",X"05",X"06",X"07",
                     X"08",X"09",X"0A",X"0B",X"0C",X"0D",X"0E",X"0F",
                     X"10",X"11",X"12",X"13",X"14",X"15",X"16",X"17",
                     X"18",X"19",X"1A",X"1B",X"1C",X"1D",X"1E",X"1F",
                     X"20",X"21",X"22",X"23",X"24",X"25",X"26",X"27",
                     X"28",X"29",X"2A",X"2B",X"2C",X"2D",X"2E",X"2F",
                     X"30",X"31",X"32",X"33",X"34",X"35",X"36",X"37",
                     X"38",X"39",X"3A",X"3B",X"3C",X"3D",X"3E",X"3F"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    out_token(usb, X"02",X"1");
    send_D1   (usb, (X"40",X"41",X"42",X"43",X"44",X"45",X"46",X"47",
                     X"48",X"49",X"4A",X"4B",X"4C",X"4D",X"4E",X"4F",
                     X"50",X"51",X"52",X"53",X"54",X"55",X"56",X"57",
                     X"58",X"59",X"5A",X"5B",X"5C",X"5D",X"5E",X"5F",
                     X"60",X"61",X"62",X"63",X"64",X"65",X"66",X"67",
                     X"68",X"69",X"6A",X"6B",X"6C",X"6D",X"6E",X"6F",
                     X"70",X"71",X"72",X"73",X"74",X"75",X"76",X"77",
                     X"78",X"79",X"7A",X"7B",X"7C",X"7D",X"7E",X"7F"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    out_token(usb, X"02",X"1");
    send_D0   (usb, (X"80",X"81",X"82",X"83",X"84",X"85",X"86",X"87",
                     X"88",X"89",X"8A",X"8B",X"8C",X"8D",X"8E",X"8F",
                     X"90",X"91",X"92",X"93",X"94",X"95",X"96",X"97",
                     X"98",X"99",X"9A",X"9B",X"9C",X"9D",X"9E",X"9F",
                     X"A0",X"A1",X"A2",X"A3",X"A4",X"A5",X"A6",X"A7",
                     X"A8",X"A9",X"AA",X"AB",X"AC",X"AD",X"AE",X"AF",
                     X"B0",X"B1",X"B2",X"B3",X"B4",X"B5",X"B6",X"B7",
                     X"B8",X"B9",X"BA",X"BB",X"BC",X"BD",X"BE",X"BF"));
    wait_slv  (usb);
--  recv_ACK  (usb);
    list(T_No, 11);
    list("read 1st 64 bytes");
    in_token(usb, X"02",X"1");
    wait_slv  (usb);
 -- recv_D0   (usb, (X"00",X"10",X"20",X"30",X"40",X"50",X"60",X"70",
 --                  X"80",X"90",X"A0",X"B0",X"C0",X"D0",X"E0",X"F0",
 --                  X"01",X"11",X"21",X"31",X"41",X"51",X"61",X"71",
 --                  X"81",X"91",X"A1",X"B1",X"C1",X"D1",X"E1",X"F1",
 --                  X"02",X"12",X"22",X"32",X"42",X"52",X"62",X"72",
 --                  X"82",X"92",X"A2",X"B2",X"C2",X"D2",X"E2",X"F2",
 --                  X"03",X"13",X"23",X"33",X"43",X"53",X"63",X"73",
 --                  X"83",X"93",X"A3",X"B3",X"C3",X"D3",X"E3",X"F3"));
    send_ACK  (usb);
    list("read 2nd 64 bytes");
    in_token(usb, X"02",X"1");
    wait_slv  (usb);
 -- recv_D1   (usb, (X"04",X"14",X"24",X"34",X"44",X"54",X"64",X"74",
 --                  X"84",X"94",X"A4",X"B4",X"C4",X"D4",X"E4",X"F4",
 --                  X"05",X"15",X"25",X"35",X"45",X"55",X"65",X"75",
 --                  X"85",X"95",X"A5",X"B5",X"C5",X"D5",X"E5",X"F5",
 --                  X"06",X"16",X"26",X"36",X"46",X"56",X"66",X"76",
 --                  X"86",X"96",X"A6",X"B6",X"C6",X"D6",X"E6",X"F6",
 --                  X"07",X"17",X"27",X"37",X"47",X"57",X"67",X"77",
 --                  X"87",X"97",X"A7",X"B7",X"C7",X"D7",X"E7",X"F7"));
    send_ACK  (usb);
    in_token(usb, X"02",X"1");
    wait_slv  (usb);
 -- recv_D0   (usb, (X"08",X"18",X"28",X"38",X"48",X"58",X"68",X"78",
 --                  X"88",X"98",X"A8",X"B8",X"C8",X"D8",X"E8",X"F8",
 --                  X"09",X"19",X"29",X"39",X"49",X"59",X"69",X"79",
 --                  X"89",X"99",X"A9",X"B9",X"C9",X"D9",X"E9",X"F9",
 --                  X"0A",X"1A",X"2A",X"3A",X"4A",X"5A",X"6A",X"7A",
 --                  X"8A",X"9A",X"AA",X"BA",X"CA",X"DA",X"EA",X"FA",
 --                  X"0B",X"1B",X"2B",X"3B",X"4B",X"5B",X"6B",X"7B",
 --                  X"8B",X"9B",X"AB",X"BB",X"CB",X"DB",X"EB",X"FB"));
    send_ACK  (usb);
    list("write and read 1x 64 bytes to - from engine 1");
    --**************************************************--
    list(T_No, 32);
    out_token(usb, X"02",X"1");
    send_D1   (usb, (X"C0",X"C1",X"C2",X"C3",X"C4",X"C5",X"C6",X"C7",
                     X"C8",X"C9",X"CA",X"CB",X"CC",X"CD",X"CE",X"CF",
                     X"D0",X"D1",X"D2",X"D3",X"D4",X"D5",X"D6",X"D7",
                     X"D8",X"D9",X"DA",X"DB",X"DC",X"DD",X"DE",X"DF",
                     X"E0",X"E1",X"E2",X"E3",X"E4",X"E5",X"E6",X"E7",
                     X"E8",X"E9",X"EA",X"EB",X"EC",X"ED",X"EE",X"EF",
                     X"F0",X"F1",X"F2",X"F3",X"F4",X"F5",X"F6",X"F7",
                     X"F8",X"F9",X"FA",X"FB",X"FC",X"FD",X"FE",X"FF"));
    wait_slv  (usb);
    list(T_No, 13);
    in_token(usb, X"02",X"1");
    wait_slv  (usb);
 -- recv_D1   (usb, (X"0C",X"1C",X"2C",X"3C",X"4C",X"5C",X"6C",X"7C",
 --                  X"8C",X"9C",X"AC",X"BC",X"CC",X"DC",X"EC",X"FC",
 --                  X"0D",X"1D",X"2D",X"3D",X"4D",X"5D",X"6D",X"7D",
 --                  X"8D",X"9D",X"AD",X"BD",X"CD",X"DD",X"ED",X"FD",
 --                  X"0E",X"1E",X"2E",X"3E",X"4E",X"5E",X"6E",X"7E",
 --                  X"8E",X"9E",X"AE",X"BE",X"CE",X"DE",X"EE",X"FE",
 --                  X"0F",X"1F",X"2F",X"3F",X"4F",X"5F",X"6F",X"7F",
 --                  X"8F",X"9F",X"AF",X"BF",X"CF",X"DF",X"EF",X"FF"));
    send_ACK  (usb);
    list(T_No, 14);
    list("test for more data - nothing");
    in_token(usb, X"02",X"1");
    wait_slv  (usb);
 -- recv_D0   (usb);
    send_ACK  (usb);

    ASSERT FALSE REPORT"End of Test" SEVERITY FAILURE;
  END PROCESS;

END sim;
