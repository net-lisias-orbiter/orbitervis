::Windows build script
@echo off
set path=..\..\fpc\bin\i386-win32;%path%
cd src_extra\oglathin
fpc -CX -XX -O3 -OG -Or -Xs -Mdelphi -dorulex -dno_render -Fu..\..\rsrc -Fu..\..\src_common\alib\synapse -Fu..\..\src_common\alib -Fu..\..\src_common\alibc -Fu..\..\src_common\alib\glgr -Fu..\..\src_common\alib\pck -Fu..\..\src_common\dynplnt -Fu..\..\src_common\ogla -Fu..\..\src -Fi..\..\rsrc -Fi. -Fi..\..\src -FU..\..\rsrc\units oglathin.dpr
move oglathin.exe ..\..\..\.. >nul
del std.or ogla.dll
echo Done.
pause
