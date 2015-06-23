@echo Loading %1
@for /F %%i in (%1) do @echo %%i > COM1
@echo Done
