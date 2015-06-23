@rem Run software simulator in hands-off mode
..\..\tools\slite\slite\bin\Debug\slite.exe ^
    --bram=hello.code ^
    --trigger=bfc00000 ^
    --noprompt ^
    --nomips32 ^
    --map=hello.map ^
    --trace_log=trace_log.txt
    