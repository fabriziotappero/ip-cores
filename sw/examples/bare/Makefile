all: hw

hw: drivertest.bin plustest.bin ocgfxmesh.bin demo.bin

sw: drivertest plustest ocgfxmesh demo

#ocgfx3d.bin

INCLUDE = -I../../drivers/gfx/bare

TILE_SRC = ../../drivers/gfx/bare/orgfx_tileset.c
FONT_SRC = ../../drivers/gfx/bare/orgfx_bitmap_font.c
VFONT_SRC = ../../drivers/gfx/bare/orgfx_vector_font.c
3D_SRC = ../../drivers/gfx/bare/orgfx_3d.c

HW_SRC = ../../drivers/gfx/bare/orgfx.c ../../drivers/gfx/bare/orgfx_plus.c
SW_SRC = ../../drivers/gfx/bare/orgfx_sw.c

SDL = -lSDL -lSDL_image -g

vgatest.bin:
	or32-elf-gcc -o vgatest vgatest.c
	or32-elf-objcopy -O binary vgatest
	bin2binsizeword vgatest vgatest.bin
	mv vgatest.bin ../../../../../../ORGFXSoC/orpsocv2/boards/xilinx/atlys/backend/par/run/	

drivertest.bin:
	or32-elf-gcc -o drivertest drivertest.c $(INCLUDE) $(HW_SRC)
	or32-elf-objcopy -O binary drivertest
	bin2binsizeword drivertest drivertest.bin
	mv drivertest.bin ../../../../../../ORGFXSoC/orpsocv2/boards/xilinx/atlys/backend/par/run/

drivertest:
	gcc -o drivertest drivertest.c $(INCLUDE) $(SW_SRC) $(SDL)

plustest.bin:
	or32-elf-gcc -o plustest plustest.c $(INCLUDE) $(HW_SRC)
	or32-elf-objcopy -O binary plustest
	bin2binsizeword plustest plustest.bin
	mv plustest.bin ../../../../../../ORGFXSoC/orpsocv2/boards/xilinx/atlys/backend/par/run/

plustest:
	gcc -o plustest plustest.c $(INCLUDE) $(SW_SRC) $(SDL)

#ocgfx3d.bin:
#	or32-elf-gcc -o ocgfx3d ocgfx3d.c $(INCLUDE) ../../drivers/gfx/bare/oc_gfx.c ../../drivers/gfx/bare/oc_gfx_plus.c ../../drivers/gfx/bare/oc_gfx_3d.c -lm
#	or32-elf-objcopy -O binary ocgfx3d
#	bin2binsizeword ocgfx3d ocgfx3d.bin
#	mv ocgfx3d.bin ../../../../orpsocv2/boards/xilinx/atlys/backend/par/run/

ocgfxmesh.bin:
	or32-elf-gcc -o ocgfxmesh ocgfxmesh.c $(INCLUDE) $(HW_SRC) $(3D_SRC) $(TILE_SRC) $(FONT_SRC) $(VFONT_SRC) -lm
	or32-elf-objcopy -O binary ocgfxmesh
	./bin2binsizeword ocgfxmesh ocgfxmesh.bin
	mv ocgfxmesh.bin ../../../../../../ORGFXSoC/orpsocv2/boards/xilinx/atlys/backend/par/run/

ocgfxmesh:
	gcc -o ocgfxmesh ocgfxmesh.c $(INCLUDE) $(SW_SRC) $(3D_SRC) $(TILE_SRC) $(FONT_SRC) $(VFONT_SRC) $(SDL)

demo.bin:
	or32-elf-gcc -o demo demo.c $(INCLUDE) $(HW_SRC) $(3D_SRC) $(TILE_SRC) $(FONT_SRC) -lm
	or32-elf-objcopy -O binary demo
	bin2binsizeword demo demo.bin
	mv demo.bin ../../../../../../ORGFXSoC/orpsocv2/boards/xilinx/atlys/backend/par/run/

demo:
	gcc -o demo demo.c $(INCLUDE) $(SW_SRC) $(3D_SRC) $(TILE_SRC) $(FONT_SRC) $(SDL)

clean:
	rm -f vgatest.bin drivertest.bin plustest.bin ocgfxmesh.bin demo.bin
	rm -f drivertest plustest ocgfxmesh demo
