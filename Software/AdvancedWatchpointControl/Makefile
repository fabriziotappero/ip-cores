
JC = javac
JAVA = java
SRCPATH = src/advancedWatchpointControl/
DSTPATH = bin/advancedWatchpointControl/
JFLAGS = -g  -d $(DSTPATH) -cp swt.jar


CLASSES = \
	$(SRCPATH)AdvancedWatchpointControl.java \
	$(SRCPATH)ReadRegisterTransaction.java \
	$(SRCPATH)registerInterpreter.java \
	$(SRCPATH)guiControlGroup.java \
	$(SRCPATH)RegisterObserver.java \
	$(SRCPATH)guiCountRegsGroup.java \
	$(SRCPATH)rspCoder.java \
	$(SRCPATH)guiDCRGroup.java \
	$(SRCPATH)targetDebugRegisterSet.java \
	$(SRCPATH)guiServerGroup.java \
	$(SRCPATH)TargetRunningTransaction.java \
	$(SRCPATH)LogMessageObserver.java \
	$(SRCPATH)TargetTransaction.java \
	$(SRCPATH)mainControl.java \
	$(SRCPATH)targetTransactor.java \
	$(SRCPATH)NetworkStatusObserver.java \
	$(SRCPATH)WriteRegisterTransaction.java \
	$(SRCPATH)networkSystem.java

default: AdvancedWatchpointControl.jar

run: AdvancedWatchpointControl.jar
	$(JAVA) -jar AdvancedWatchpointControl.jar &

AdvancedWatchpointControl.jar: $(CLASSES)
	$(JC) $(JFLAGS) $(CLASSES)
	jar cvfm AdvancedWatchpointControl.jar manifest -C bin/advancedWatchpointControl/ .

clean:
	$(RM) $(DSTPATH)*.class
	$(RM) AdvancedWatchpointControl.jar
