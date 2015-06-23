SPI_MASTER_ATLYS
================

This is a ISE 13.1 project to test the spi_master.vhd, spi_slave.vhd and grp_debouncer.vhd models in silicon.
The target board is a Digilent Atlys FPGA board (Spartan-6 @ 100MHz), and the circuit was tested at different SPI clock frequencies.
See the scope screenshots in the spi_master_scope_photos.zip file for each SPI frequency tested.
The circuit verifies both master and slave cores, with transmit and receive streams operating full-duplex at 50MHz of SPI clock.

This circuit also includes a very robust debouncing circuit to use with multiple inputs. The model, "grp_debouncer.vhd" is also published under a LGPL license.

The files are:
-------------

spi_master.vhd                  vhdl model for the spi_master interface
spi_slave.vhd                   vhdl model for the spi_slave interface
grp_debouncer.vhd               vhdl model for the switch debouncer
spi_master_atlys_top.vhd        vhdl model for the toplevel block to synthesize for the Atlys board
spi_master_atlys_test.vhd       testbench for the synthesizable toplevel 'spi_master_atlys_top.vhd'
spi_master_atlys.xise           ISE 13.1 project file
spi_master_atlys.ucf            pin lock constraints for the Atlys board
spi_master_scope_photos.zip     Tektronix MSO2014 screenshots for the verification tests
spi_master_envsettings.html     synthesis env settings, with the tools setup used
ATLYS_0x.SET                    Tek MSO2014 settings files with the debug pin names
spi_master_atlys_top_bit.zip    bitgen file to program the Atlys board


LICENSING
---------

This work is licensed as a LGPL work. If you find this licensing too restrictive for hardware, or it is not adequate for you, please get in touch with me and we can arrange a more suitable open source hardware licensing.



If you need assistance on putting this to work, please place a thread in the OpenCores forum, and I will be glad to answer, or send me e-mail: jdoin@opencores.org

If you find a bug or a design fault in the models, or if you have an issue that you like to be addressed, please open a bug/issue in the OpenCores bugtracker for this project, at 

		http://opencores.org/project,spi_master_slave,bugtracker

If you find this core useful, please let me know: jdoin@opencores.org

In any case, thank you very much for testing this core.


Jonny Doin
jdoin@opencores.org

