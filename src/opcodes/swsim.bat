@rem Run software simulator in hands-off mode
..\..\tools\slite\slite\bin\Debug\slite.exe ^
    --bram=opcodes.bin ^
    --trigger=bfc00000 ^
    --noprompt ^
    --nomips32
    