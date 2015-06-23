# Microsoft Developer Studio Project File - Name="history_buffer_l3_tb" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=history_buffer_l3_tb - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "history_buffer_l3_tb.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "history_buffer_l3_tb.mak" CFG="history_buffer_l3_tb - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "history_buffer_l3_tb - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "history_buffer_l3_tb - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "history_buffer_l3_tb - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x1009 /d "NDEBUG"
# ADD RSC /l 0x1009 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "history_buffer_l3_tb - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GR /GX /ZI /Od /I "D:\systemc-2.0.1\include" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /D "SYSTEMC_SIM" /YX /FD /GZ /c
# ADD BASE RSC /l 0x1009 /d "_DEBUG"
# ADD RSC /l 0x1009 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib D:\systemc-2.0.1\msvc60\systemc\Debug\systemc.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "history_buffer_l3_tb - Win32 Release"
# Name "history_buffer_l3_tb - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Group "core_synth_cpp"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\rtl\systemc\core_synth\ht_type_include.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\rtl\systemc\core_synth\synth_control_packet.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\rtl\systemc\core_synth\synth_datatypes.cpp
# End Source File
# End Group
# Begin Group "core_cpp"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\core\ControlPacket.cpp
# End Source File
# Begin Source File

SOURCE=..\..\core\ht_datatypes.cpp
# End Source File
# Begin Source File

SOURCE=..\..\core\PacketContainer.cpp
# End Source File
# Begin Source File

SOURCE=..\..\core\RequestPacket.cpp
# End Source File
# Begin Source File

SOURCE=..\..\core\ResponsePacket.cpp
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\..\rtl\systemc\flow_control_l2\history_buffer_l3.cpp
# End Source File
# Begin Source File

SOURCE=.\history_buffer_l3_tb.cpp
# End Source File
# Begin Source File

SOURCE=.\main.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Group "core_h"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\core\ControlPacket.h
# End Source File
# Begin Source File

SOURCE=..\..\core\ht_datatypes.h
# End Source File
# Begin Source File

SOURCE=..\..\core\InfoPacket.h
# End Source File
# Begin Source File

SOURCE=..\..\core\PacketContainer.h
# End Source File
# Begin Source File

SOURCE=..\..\core\RequestPacket.h
# End Source File
# Begin Source File

SOURCE=..\..\core\require.h
# End Source File
# Begin Source File

SOURCE=..\..\core\ReservedPacket.h
# End Source File
# Begin Source File

SOURCE=..\..\core\ResponsePacket.h
# End Source File
# End Group
# Begin Group "core_synth_h"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\rtl\systemc\core_synth\constants.h
# End Source File
# Begin Source File

SOURCE=..\..\..\rtl\systemc\core_synth\ht_type_include.h
# End Source File
# Begin Source File

SOURCE=..\..\..\rtl\systemc\core_synth\synth_control_packet.h
# End Source File
# Begin Source File

SOURCE=..\..\..\rtl\systemc\core_synth\synth_datatypes.h
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\..\rtl\systemc\flow_control_l2\history_buffer_l3.h
# End Source File
# Begin Source File

SOURCE=.\history_buffer_l3_tb.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
