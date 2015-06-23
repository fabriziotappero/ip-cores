@rem Run software simulator in hands-off mode
..\..\tools\slite\slite\bin\Debug\slite.exe ^
    --bram=memtest.code ^
    --flash=flash.bin ^
    --trigger=bfc00000 ^
    --noprompt ^
    --small
    