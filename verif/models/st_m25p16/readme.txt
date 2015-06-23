REV 1.2 according to Datasheet M25P16 REV 2.0 (24 November 2003)



======================================================================================= 
WARNING : These Verilog models are provided "as is" without warranty of any kind, 
including, but not limited to, any implied warranty of merchantability and fitness 
for a particular purpose.
=======================================================================================
 
 
 
 
 PROJECT ARCHITECTURE
 
 Parameter.v
 |
 TestBench.v
 |--------------> M25Pxx.v
 |                |--------------> memory_access.v
 |                |--------------> internal_logic.v
 |                |--------------> acdc_check.v
 |                |--------------> parameter.v
 |
 |--------------> M25Pxx_driver.v
 
 
 The project should be compiled in the following order :
 
    - parameter.v          : define all constants
    - memory_access.v      : perform read/write operations
    - internal_logic.v     : describe internal working
    - acdc_check.v         : check if timings respect datasheet.
    - m25pxx.v             : external description of Serial Flash
    - m25pxx_driver.v      : stimuli + library of operations example
    - testbench.v          : a testbench example
 
 
 
 
 TECHNICAL SUPPORT
 
 For current information on M25Pxx products, please consult our pages on the world wide web:
 www.st.com/eeprom
 
 If you have any questions or suggestions concerning the matters raised in this document, please send
 them to the following electronic mail addresses:
           apps.eeprom@st.com (for application support)
           ask.memory@st.com (for general enquiries)
