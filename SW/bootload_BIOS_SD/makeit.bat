@echo off

    if exist "bootstrap.obj" del "bootstrap.obj"
    if exist "bootstrap.com" del "bootstrap.com"

    \masm32\bin\ml /AT /c /Fl bootstrap.asm
    if errorlevel 1 goto errasm

    \masm32\bin\link16 /TINY bootstrap,bootstrap.com,,,,
    if errorlevel 1 goto errlink
    dir "bootstrap.*"
    goto TheEnd

  :errlink
    echo _
    echo Link error
    goto TheEnd

  :errasm
    echo _
    echo Assembly Error
    goto TheEnd
    
  :TheEnd

pause
