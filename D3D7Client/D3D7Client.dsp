# Microsoft Developer Studio Project File - Name="D3D7Client" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=D3D7Client - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "D3D7Client.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "D3D7Client.mak" CFG="D3D7Client - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "D3D7Client - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "D3D7Client - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "D3D7Client - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "D3D7CLIENT_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "c:\mssdk\include" /I "..\..\Orbitersdk\include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "D3D7CLIENT_EXPORTS" /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x809 /d "NDEBUG"
# ADD RSC /l 0x809 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib ddraw.lib d3dim.lib dxguid.lib orbiter.lib orbitersdk.lib /nologo /dll /machine:I386 /libpath:"c:\mssdk\lib" /libpath:"..\..\Orbitersdk\lib"
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Desc=Copying DLL
PostBuild_Cmds=copy Release\D3D7Client.dll ..\..\Modules\Plugin
# End Special Build Tool

!ELSEIF  "$(CFG)" == "D3D7Client - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "..\..\Modules\Plugin"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "D3D7CLIENT_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /GX /ZI /Od /I "c:\mssdk\include" /I "..\..\Orbitersdk\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "D3D7CLIENT_EXPORTS" /FD /GZ /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x809 /d "_DEBUG"
# ADD RSC /l 0x809 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib ddraw.lib d3dim.lib dxguid.lib orbiter.lib orbitersdk.lib /nologo /dll /debug /machine:I386 /pdbtype:sept /libpath:"c:\mssdk\lib" /libpath:"..\..\Orbitersdk\lib"

!ENDIF 

# Begin Target

# Name "D3D7Client - Win32 Release"
# Name "D3D7Client - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\Camera.cpp
# End Source File
# Begin Source File

SOURCE=.\CelSphere.cpp
# End Source File
# Begin Source File

SOURCE=.\CloudMgr.cpp
# End Source File
# Begin Source File

SOURCE=.\D3D7Client.cpp
# End Source File
# Begin Source File

SOURCE=.\D3D7Client.rc
# End Source File
# Begin Source File

SOURCE=.\D3D7Enum.cpp
# End Source File
# Begin Source File

SOURCE=.\D3D7Frame.cpp
# End Source File
# Begin Source File

SOURCE=.\D3D7Util.cpp
# End Source File
# Begin Source File

SOURCE=.\DlgMgr.cpp
# End Source File
# Begin Source File

SOURCE=.\HazeMgr.cpp
# End Source File
# Begin Source File

SOURCE=.\Light.cpp
# End Source File
# Begin Source File

SOURCE=.\Mesh.cpp
# End Source File
# Begin Source File

SOURCE=.\MeshMgr.cpp
# End Source File
# Begin Source File

SOURCE=.\Particle.cpp
# End Source File
# Begin Source File

SOURCE=.\RingMgr.cpp
# End Source File
# Begin Source File

SOURCE=.\Scene.cpp
# End Source File
# Begin Source File

SOURCE=.\SurfMgr.cpp
# End Source File
# Begin Source File

SOURCE=.\Texture.cpp
# End Source File
# Begin Source File

SOURCE=.\TileMgr.cpp
# End Source File
# Begin Source File

SOURCE=.\VBase.cpp
# End Source File
# Begin Source File

SOURCE=.\VideoTab.cpp
# End Source File
# Begin Source File

SOURCE=.\VObject.cpp
# End Source File
# Begin Source File

SOURCE=.\VPlanet.cpp
# End Source File
# Begin Source File

SOURCE=.\VVessel.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\Camera.h
# End Source File
# Begin Source File

SOURCE=.\CelSphere.h
# End Source File
# Begin Source File

SOURCE=.\CloudMgr.h
# End Source File
# Begin Source File

SOURCE=.\D3D7Client.h
# End Source File
# Begin Source File

SOURCE=.\D3D7Enum.h
# End Source File
# Begin Source File

SOURCE=.\D3D7Frame.h
# End Source File
# Begin Source File

SOURCE=.\D3D7Util.h
# End Source File
# Begin Source File

SOURCE=.\DlgMgr.h
# End Source File
# Begin Source File

SOURCE=.\HazeMgr.h
# End Source File
# Begin Source File

SOURCE=.\Light.h
# End Source File
# Begin Source File

SOURCE=.\Mesh.h
# End Source File
# Begin Source File

SOURCE=.\MeshMgr.h
# End Source File
# Begin Source File

SOURCE=.\Particle.h
# End Source File
# Begin Source File

SOURCE=.\resource.h
# End Source File
# Begin Source File

SOURCE=.\RingMgr.h
# End Source File
# Begin Source File

SOURCE=.\Scene.h
# End Source File
# Begin Source File

SOURCE=.\SurfMgr.h
# End Source File
# Begin Source File

SOURCE=.\Texture.h
# End Source File
# Begin Source File

SOURCE=.\TileMgr.h
# End Source File
# Begin Source File

SOURCE=.\VBase.h
# End Source File
# Begin Source File

SOURCE=.\VideoTab.h
# End Source File
# Begin Source File

SOURCE=.\VObject.h
# End Source File
# Begin Source File

SOURCE=.\VPlanet.h
# End Source File
# Begin Source File

SOURCE=.\VVessel.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
