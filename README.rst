Chips-2.0 Demo for ATLYS Development Card
=========================================

:Author: Jonathan P Dawson
:Date: 2013-10-15
:email: chips@jondawson.org.uk


This project is intended to demonstrate the capabilities of the `Chips-2.0 <http:pyandchips.org>`_  development environment. The project is targets the Xilinx Spartan 6 device, and more specifically, the Digilent ATLYS development platform. The demo implements a TCP/IP socket interface, and a simple web application. So far the demonstration has been tested on a Ubuntu Linux only. Some users have reported success using windows.

Dependencies
============

You will need:

+ Xilinx ISE 12.0 or later (webpack edition is free)
+ Python 2.7 or later (but not Python 3)
+ Chips-2.0 (Included)
+ Digilent `ATLYS <http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,400,836&Prod=ATLYS&CFID=3188339&CFTOKEN=15014968>`_  Spartan 6 Development Kit.
+ Digilent ADEPT2 `utility <http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,66,828&Prod=ADEPT2>`_ 
+ git

Install
=======

Clone the git the repository with git::

    $ git clone https://github.com/dawsonjon/Chips-Demo.git
    $ cd Chips-Demo
    $ git submodule init
    $ git submodule update

Chips Compile
=============

To compile the c code in chips, issue the following command in the project folder::

    $ ./atlys.py compile

Build in ISE 
============

Edit the Xilinx variable in the scripts/user_settings to point to the Xilinx ISE install directory. Then build the design using the following command::

    $ ./atlys.py build

Download to ATLYS 
=================

Power up the ATLYS, and connect the JTAG USB cable to your PC. Run the download command::

    $ ./atlys.py download

You can complete all three steps in one go using the *all* option::

    $ ./atlys.py all

Setup and Test
==============

::
        
        +----------------+                 +----------------+
        | PC             |                 | Digilent ATLYS |
        |                |   POWER =======>o                |
        |                |                 |                |
        |          USB   o<===============>o JTAG USB       |
        |                |                 |                |
        |          ETH0  o<===============>o ETHERNET       |
        |                |                 |                |
        | 192.168.1.0    |                 | 192.168.1.1    |
        +----------------+                 +----------------+

..

Connect the Ethernet port to ATLYS, using a crossed over Ethernet cable.

Using the script, configure Ethernet port with IP address 192.168.1.0 and subnet mask 255.255.255.0. Turn off TCP Window Scaling and TCP time stamps::

    $ ./configure_network

Verify connection using ping command::

    $ ping 192.168.1.1
    PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
    64 bytes from 192.168.1.1: icmp_req=1 ttl=255 time=0.253 ms
    64 bytes from 192.168.1.1: icmp_req=2 ttl=255 time=0.371 ms
    64 bytes from 192.168.1.1: icmp_req=3 ttl=255 time=0.382 ms
    64 bytes from 192.168.1.1: icmp_req=4 ttl=255 time=0.250 ms
    ^C
    --- 192.168.1.1 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3000ms
    rtt min/avg/max/mdev = 0.250/0.314/0.382/0.062 ms

Connect to 192.168.1.1 using your favourite browser.

.. image:: https://raw.github.com/dawsonjon/Chips-Demo/master/images/screenshot.png
        :width: 75%
