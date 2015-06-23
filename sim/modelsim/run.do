# To run this example, bring up the simulator and type the following at the prompt:
#     do run.do
# or, to run from a shell, type the following at the shell prompt:
#     vsim -c -do run.do
# (omit the "-c" to see the GUI while running from the shell)
# Remove the "quit -f" command from this file to view the results in the GUI.


onbreak {resume}

# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../../rtl/gng.v
vlog ../../rtl/gng_coef.v
vlog ../../rtl/gng_ctg.v
vlog ../../rtl/gng_interp.v
vlog ../../rtl/gng_lzd.v
vlog ../../rtl/gng_smul_16_18.v
vlog ../../rtl/gng_smul_16_18_sadd_37.v
vlog ../../tb/tb_gng.sv


# Simulate the design.
vsim -novopt -c tb_gng
run -all

quit -f
