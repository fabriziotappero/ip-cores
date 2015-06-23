--*************************************************************************
-- Project    : AES128                                                    *
--                                                                        *
-- Block Name : aes_tb_readme.txt                                         *
--                                                                        *
-- Author     : Hemanth Satyanarayana                                     *
--                                                                        *
-- Email      : hemanth@opencores.org                                     *
--                                                                        *
-- Description: File explaining the test procedure used for               *
--              testing the aes core.                                     *
--                                                                        *
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
AES TESTING
===========

The aes core is verified with three simple TB's as noted below.

TB aes_tester.vhd
This module is meant to test the aes core with different types of
input- as text or bits which makes it more general in nature. The 
input scripts for this test module are as follows -
  (a) coded_text.txt   :- Ascii text file to be encoded(constraints= max 6 lines of 40 characters each)
  (b) encoded_text.txt :- File with logical binary values to be decoded back to text.
  (c) aes_data_in.txt  :- File with a single 128 bit binary value to be encoded/decoded.
Note: For both encryption and decryption the key is fixed in this TB module.
      The keys for encrytion and decryption are inverses so that the original input is
      obtained back when decryption is done on encrypted input.(This aids easy verification)
      You can change the key value in the TB module if required.
      While reading coded_text.txt the tilde(~) is taken as the end of line character in TB.
      You need to set the mode for encryption or decryption in the TB itself depending on your input.
      
TB aes_fips_tester.vhd
This test module verifies the AES for FIPS tests called as Known Answer Tests (KAT). The FIPS specifies 
three types of tests for the ECB mode implementation of AES. Hence the following are the input files
for this TB -
  (a) ecb_tbl.txt:- This script is to test is to check the AES implementation for table KAT
                    It contains 128 sets of inputs, keys and cipher outputs to be verified.
  
  (b) ecb_vk.txt :- This script test the implementation for 128 mutually independent key vectors.
  
  (c) ecb_vt.txt :- This script tests the implementation for 128 mutually independent input vectors.
Note: For the above tests refer the FIPS document "katmct.pdf".
      For each of the scripts a corresponding report is generated.
      
TB aes_fips_mctester.vhd
This Tb is developed to subject the aes implementation to Monte-Carlo tests as described in the
"katmct.pdf". The input script for this test is as follows -
  (a) ecb_e_m.txt:- This file contains a set of 400 inputs, keys and cipher outputs. But each
                    succeeding input and key is the result of the previous case output cipher 
                    and key. Each of the 400 cases is run cyclically with new inputs as previous 
                    outputs for 10000 iterations for a combined run of 4000,000 iterations.
                    This test takes a long time to complete, so keep in mind your system performance
                    capabilities before running this test. 
Note: A report is produced with each of 400 test case results verified.

General Note: The format of all the above scripts should not be changed for proper working of TB. 

Put all the test scripts in the simulation folder and either edit and run tcl script "aescomp&run.do" 
or simulate each TB individually from simulation folder as per your requirement. Reports will be 
generated in the simulation folder.
The AES core has been verified successfully for all the above mentioned tests with each TB.

