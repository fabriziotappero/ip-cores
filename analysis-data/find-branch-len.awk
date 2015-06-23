# Print out a list of jump distances for l.bf and l.bnf (in bytes)

# For now we ignore l.j and l.jal, since these more generally refer to
# external names and will need relocating. Apply to the full disassembly
# listing, where lines are of the form:

#       e4:	10 00 00 39 	l.bf 1c8 <_wait_input+0x140>

/(l\.bf)|(l\.bnf)/ { 
    src = strtonum (sprintf ("0x%s", substr ($1, 0, 8)))
    dst = strtonum (sprintf ("0x%s", $7))

#   printf ("%s %d %d %d\n", $6, src, dst, dst - src)
    printf ("%d\n", dst - src)
          
}
