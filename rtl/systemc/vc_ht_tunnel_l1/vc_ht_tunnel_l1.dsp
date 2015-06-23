# Microsoft Developer Studio Project File - Name="vc_ht_tunnel_l1" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=vc_ht_tunnel_l1 - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "vc_ht_tunnel_l1.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "vc_ht_tunnel_l1.mak" CFG="vc_ht_tunnel_l1 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "vc_ht_tunnel_l1 - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "vc_ht_tunnel_l1 - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "vc_ht_tunnel_l1 - Win32 Release"

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

!ELSEIF  "$(CFG)" == "vc_ht_tunnel_l1 - Win32 Debug"

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
# ADD CPP /nologo /W3 /Gm /GR /GX /ZI /Od /I "D:\systemc-2.0.1\src" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /D "SYSTEMC_SIM" /YX /FD /GZ /c
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

# Name "vc_ht_tunnel_l1 - Win32 Release"
# Name "vc_ht_tunnel_l1 - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Group "csr_l2_cpp"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=..\csr_l2\csr_l2.cpp
# End Source File
# End Group
# Begin Group "decoder_l2_cpp"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=..\decoder_l2\cd_cmd_buffer_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_cmdwdata_buffer_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_counter_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_history_rx_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_mux_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_nop_handler_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_packet_crc_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_state_machine_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\decoder_l2.cpp
# End Source File
# End Group
# Begin Group "reordering_l2_cpp"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=..\reordering_l2\address_manager_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\chain_marker_l4.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\entrance_reordering_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\fetch_packet_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\final_reordering_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\nophandler_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\nposted_vc_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\posted_vc_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\reordering_l2.cpp
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\response_vc_l3.cpp
# End Source File
# End Group
# Begin Group "databuffer_l2_cpp"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\databuffer_l2\databuffer_l2.cpp
# End Source File
# End Group
# Begin Group "userinterface_l2_cpp"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=..\userinterface_l2\userinterface_l2.cpp
# End Source File
# End Group
# Begin Group "flowcontrol_l2_cpp"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=..\flow_control_l2\fairness_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\fc_packet_crc_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\flow_control_l2.cpp
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\flow_control_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\history_buffer_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\multiplexer_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\nop_framer_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\rx_farend_cnt_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\user_fifo_l3.cpp
# End Source File
# End Group
# Begin Group "link_l2_cpp"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=..\link_l2\link_frame_rx_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\link_l2\link_frame_tx_l3.cpp
# End Source File
# Begin Source File

SOURCE=..\link_l2\link_l2.cpp
# End Source File
# End Group
# Begin Group "core_synth_cpp"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=..\core_synth\ht_type_include.cpp
# End Source File
# Begin Source File

SOURCE=..\core_synth\synth_control_packet.cpp
# End Source File
# Begin Source File

SOURCE=..\core_synth\synth_datatypes.cpp
# End Source File
# End Group
# Begin Group "errorhandler_l2_cpp"

# PROP Default_Filter "cpp"
# Begin Source File

SOURCE=..\errorhandler_l2\errorhandler_l2.cpp
# End Source File
# End Group
# Begin Source File

SOURCE=.\main.cpp
# End Source File
# Begin Source File

SOURCE=.\vc_ht_tunnel_l1.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Group "csr_l2_h"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\csr_l2\csr_l2.h
# End Source File
# End Group
# Begin Group "decoder_l2_h"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\decoder_l2\cd_cmd_buffer_l3.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_cmdwdata_buffer_l3.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_counter_l3.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_history_rx_l3.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_mux_l3.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_nop_handler_l3.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_packet_crc_l3.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_state_machine_l3.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\cd_test_vectors_gen.h
# End Source File
# Begin Source File

SOURCE=..\decoder_l2\decoder_l2.h
# End Source File
# End Group
# Begin Group "reordering_l2_h"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\reordering_l2\address_manager_l3.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\chain_marker_l4.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\entrance_reordering_l3.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\fetch_packet_l3.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\final_reordering_l3.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\nophandler_l3.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\nposted_vc_l3.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\posted_vc_l3.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\reordering_l2.h
# End Source File
# Begin Source File

SOURCE=..\reordering_l2\response_vc_l3.h
# End Source File
# End Group
# Begin Group "databuffer_l2_h"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\databuffer_l2\databuffer_l2.h
# End Source File
# End Group
# Begin Group "userinterface_h"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\userinterface_l2\userinterface_l2.h
# End Source File
# End Group
# Begin Group "flow_control_l2_h"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\flow_control_l2\fairness_l3.h
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\fc_packet_crc_l3.h
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\flow_control_l2.h
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\flow_control_l3.h
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\history_buffer_l3.h
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\multiplexer_l3.h
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\nop_framer_l3.h
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\rx_farend_cnt_l3.h
# End Source File
# Begin Source File

SOURCE=..\flow_control_l2\user_fifo_l3.h
# End Source File
# End Group
# Begin Group "link_l2_h"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\link_l2\link_frame_rx_l3.h
# End Source File
# Begin Source File

SOURCE=..\link_l2\link_frame_tx_l3.h
# End Source File
# Begin Source File

SOURCE=..\link_l2\link_l2.h
# End Source File
# End Group
# Begin Group "core_synth_h"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\core_synth\ht_type_include.h
# End Source File
# Begin Source File

SOURCE=..\core_synth\synth_control_packet.h
# End Source File
# Begin Source File

SOURCE=..\core_synth\synth_datatypes.h
# End Source File
# End Group
# Begin Group "errorhandler_l2_h"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\errorhandler_l2\errorhandler_l2.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\vc_ht_tunnel_l1.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
