################################################################################
##            _   _            __   ____                                      ##
##           / / | |          / _| |  __|                                     ##
##           | |_| |  _   _  / /   | |_                                       ##
##           |  _  | | | | | | |   |  _|                                      ##
##           | | | | | |_| | \ \_  | |__                                      ##
##           |_| |_| \_____|  \__| |____| microLab                            ##
##                                                                            ##
##           Bern University of Applied Sciences (BFH)                        ##
##           Quellgasse 21                                                    ##
##           Room HG 4.33                                                     ##
##           2501 Biel/Bienne                                                 ##
##           Switzerland                                                      ##
##                                                                            ##
##           http://www.microlab.ch                                           ##
################################################################################

CC = sdcc
AS = asx8051
ASFLAGS = -plosgff
CFLAGS = --opt-code-size --no-xinit-opt -mmcs51 --model-small
#For the memory model following assumptions have been made:
#0x0000-0x0FFF 4 kbyte code memory
#0x1000-0x1FFF 4 kbyte data memory
#0xE000-0xE1FF 512 bytes USB descriptor tables
MEMOPTS = --code-loc 0x0000 --code-size 0x1000 \
          --xram-loc 0x1000 --xram-size 0x1000 \
          --iram-size 0x100 --data-loc 0x08\
          --stack-size 0x80 --stack-loc 0x80 --no-pack-iram\
          -Wl '-b USBDESCSEG=0xE000'
LDFLAGS=$(MEMOPTS) -L ${LIB_DIR}
SANDBOXDIR = sandbox
INCLUDE_DIR = c/include
LIB_DIR = lib
LIB = libfx2
PACKAGE = libfx2.lib
TARGETDIR = firmware


SEARCH_DIR = ${addprefix -I./,$(INCLUDE_DIR)}
FIRMWARE_OBJ = vectors.rel usb_descriptors.rel startup.rel gecko4com_main.rel
LIB_OBJ = i2c.rel delay.rel fx2utils.rel isr.rel timer.rel usb_common.rel

all : clean firmware.hex

$(SANDBOXDIR) :
	mkdir -p $(SANDBOXDIR)

$(SANDBOXDIR)/%.a51 : asm/%.a51
	cd $(SANDBOXDIR); ln -s ../$< . ; cd ..

$(SANDBOXDIR)/%.rel : $(SANDBOXDIR)/%.a51
	$(AS) $(ASFLAGS) $<

$(SANDBOXDIR)/%.rel : c/%.c
	pwd ; $(CC) -c $(CFLAGS) $(SEARCH_DIR) $< -o $@
        

$(LIB_DIR)/$(PACKAGE) : ${addprefix $(SANDBOXDIR)/,$(LIB_OBJ)}
	mkdir -p $(LIB_DIR); for obj in $^; do sdcclib $@ $$obj; done

firmware.hex : ${addprefix $(SANDBOXDIR)/,$(FIRMWARE_OBJ)} ${LIB_DIR}/${PACKAGE}
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(SANDBOXDIR)/temp.hex $+;\
        packihx $(SANDBOXDIR)/temp.hex > $(TARGETDIR)/$@; rm $(SANDBOXDIR)/temp.*

clean : sandbox
	mkdir -p $(SANDBOXDIR) $(LIBDIR);cd $(SANDBOXDIR) ; ls | grep -v svn | xargs rm -rf ; \
        cd .. ; cd $(LIB_DIR) ; ls | grep -v svn | xargs rm -rf ; cd ..\
        rm -rf $(TARGETDIR)/firmware.hex
        
