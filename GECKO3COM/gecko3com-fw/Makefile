FW_DIR = firmware/src
DOC_DIR = doc


all : fw doc 

fw :
	cd $(FW_DIR) && $(MAKE) iic

doc :
	cd $(DOC_DIR) && $(MAKE)

clean :
	cd $(FW_DIR) && $(MAKE) clean
	cd $(DOC_DIR) && $(MAKE) clean

run : all

.PHONY : clean all fw doc
