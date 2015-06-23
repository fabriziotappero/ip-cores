DMT Transceiver Project

July 11th, 2010

I started out this project as a very general idea to develop hardware
description of core parts for an ADSL modem. At that time I started out
with Verilog as HDL.

The Constellation Encoder is a first product of this.

Now I am more specific and my goal is to create the Central Office side
(ATU-C) of an ADSL modem. The reason for that is that ADSL has been
widely used and the customer side modems (ATU-R) are widespread. However
Central Office side modems are only available as a whole DSLAM, with
mini DSLAMs starting with at least a dozen lines. For home use there
might be the interest to connect an old ADSL modem for a point-to-point
connection and that is what this project could provide the hardware for.

It is a slow pace project and as such will progress rather slow.

For the HDL side I decided to switch to MyHDL (http://www.myhdl.org) My
idea is to create convertible RTL code and self-checking testbenches in
MyHDL. All MyHDL code will now go into the myhdl folder.


File structure
==============

File structure is now as follows:


.
|-- const_encoder
|   |-- doc
|   |   `-- ConstSpec.pdf
|   |-- Makefile
|   |-- rtl
|   |   |-- const_enc.v
|   |   |-- defs.vh
|   |   |-- fifo.v
|   |   |-- generic_dpram.v
|   |   `-- parameters.vh
|   `-- tb
|       |-- const_map_data.v
|       |-- tb_const_enc.v
|       `-- tb_fifo.v
|-- gpl.txt
`-- myhdl


const_encoder: 	Contains the old Verilog code for the Constellation
		Encoder
myhdl:		Contains the future MyHDL code
