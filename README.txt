--*************************************************************************
-- Project    : AES128                                                    *
--                                                                        *
-- Block Name : README.txt                                                *
--                                                                        *
-- Author     : Hemanth Satyanarayana                                     *
--                                                                        *
-- Email      : hemanth@opencores.org                                     *
--                                                                        *
-- Description: General Readme file                                       *
--                                                                        *
--                         .                                              *
--                                                                        *
-- Revision History                                                       *
-- |-----------|-------------|---------|---------------------------------|*
-- |   Name    |    Date     | Version |          Revision details       |*
-- |-----------|-------------|---------|---------------------------------|*
-- | Hemanth   | 15-Dec-2004 | 1.1.1.1 |            Uploaded             |*
-- |-----------|-------------|---------|---------------------------------|*
--                                                                        *
--  Refer FIPS-197 document for details                                   *
--*************************************************************************
--                                                                        *
-- Copyright (C) 2004 Author                                              *
--                                                                        *
-- This source file may be used and distributed without                   *
-- restriction provided that this copyright statement is not              *
-- removed from the file and that any derivative work contains            *
-- the original copyright notice and the associated disclaimer.           *
--                                                                        *
-- This source file is free software; you can redistribute it             *
-- and/or modify it under the terms of the GNU Lesser General             *
-- Public License as published by the Free Software Foundation;           *
-- either version 2.1 of the License, or (at your option) any             *
-- later version.                                                         *
--                                                                        *
-- This source is distributed in the hope that it will be                 *
-- useful, but WITHOUT ANY WARRANTY; without even the implied             *
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                *
-- PURPOSE.  See the GNU Lesser General Public License for more           *
-- details.                                                               *
--                                                                        *
-- You should have received a copy of the GNU Lesser General              *
-- Public License along with this source; if not, download it             *
-- from http://www.opencores.org/lgpl.shtml                               *
--                                                                        *
--*************************************************************************

PROJECT AES128
--------------
This project is the hardware implementation of the 
Advanced Encryption Standard with a key size of 128 bits.
The implementation adheres to the FIPS-197 document which explains the same.
The core can do both encryption as well as decryption.

The documents aes_arch.doc and aes_tb_readme.txt give further details of
the rtl implementation and test bench respectively.

This code was written originally with 128 bit ports for both input and key
but later converted to 64 bits each to save on i/o pins. It can be reverted back
easily if one just changes the port widths and dispenses with the load signal in 
the top module and making approriate changes in process where load is used.

Synthesis results have been included for Xilinx Spartan-3 device.

The directory structure of the project is as under-

AES128
  |
  |
  ------ DOC [Contains Fips document and architecture details]
  |       
  |
  ------ RTL [Contains RTL modules]
  |
  |
  ------ SIM [Simulation folder containing test scripts and results]
  |
  |
  ------ SYNTH [Synthesis related documents]
  |
  |
  ------ TB  [Test Bench modules and TB readme file]
  |
  |
  ------ TB RESULTS [TB results stored here also]
  |
  |
  ------ TB SCRIPTS [TB test scripts stored here also]
  |
  |
  ------ README FILE [The file you are reading now]
  
  The verification is done generally in the simulation folder which should contain all the 
  required test scripts. An additional simulation script called "aescomp&run.do" is included
  in the sim folder which can be used optionally to test the core if using ModelSim simulator.
  Else simulate the individual TBs from sim folder for the time mentioned in the above script.