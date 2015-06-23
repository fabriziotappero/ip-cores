#copy master source files to a single directory. Makes it easier to build SOPC component

CVS_DIR=../RTL
SOPC_DIR=Altera/sopcCompProj/src

all:
	mkdir $(SOPC_DIR)
	make copyRTLtoSOPC

copyRTLtoSOPC:
	cp -u -v -p $(CVS_DIR)/buffers/*.v $(SOPC_DIR)
	cp -u -v -p $(CVS_DIR)/busInterface/*.v $(SOPC_DIR)
	cp -u -v -p $(CVS_DIR)/hostController/*.v $(SOPC_DIR)
	cp -u -v -p $(CVS_DIR)/hostSlaveMux/*.v $(SOPC_DIR)
	cp -u -v -p $(CVS_DIR)/include/*.v $(SOPC_DIR)
	cp -u -v -p $(CVS_DIR)/serialInterfaceEngine/*.v $(SOPC_DIR)
	cp -u -v -p $(CVS_DIR)/slaveController/*.v $(SOPC_DIR)
	cp -u -v -p $(CVS_DIR)/wrapper/*.v $(SOPC_DIR)




