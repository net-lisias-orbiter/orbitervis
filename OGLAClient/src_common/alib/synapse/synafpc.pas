//############################################################################//
{$IFDEF FPC}{$modE DELPHI}{$ENDIF}
{$H+}
//############################################################################//
unit synafpc;
interface
uses {$IFDEF FPC}dynlibs,sysutils;{$ELSE}{$IFDEF WIN32}Windows;{$ELSE}SysUtils;{$ENDIF}{$ENDIF}
//############################################################################//
{$IFDEF FPC}
type TLibHandle=dynlibs.TLibHandle;
//############################################################################//
function LoadLibrary(moduleName:PChar):TLibHandle;
function FreeLibrary(module:TLibHandle):LongBool;
function GetProcAddress(module:TLibHandle; Proc:PChar):Pointer;
function GetmoduleFileName(module:TLibHandle; Buffer:PChar; BufLen:integer):integer;    
//############################################################################//
{$ELSE}
type
TLibHandle=Hmodule;
{$IFDEF VER100}dword=dword;{$ENDIF}
{$ENDIF}
//############################################################################//
procedure Sleep(milliseconds:Cardinal);
//############################################################################//
implementation
//############################################################################//
{$IFDEF FPC} 
function LoadLibrary(moduleName:PChar):TLibHandle;begin result:=dynlibs.LoadLibrary(modulename);end;
function FreeLibrary(module:TLibHandle):LongBool;begin result:=dynlibs.UnloadLibrary(module);end;
function GetProcAddress(module:TLibHandle; Proc:PChar):Pointer;begin result:=dynlibs.GetProcedureAddress(module,Proc);end;
function GetmoduleFileName(module:TLibHandle; Buffer:PChar; BufLen:integer):integer;begin result:=0;end;  
{$ENDIF}
//############################################################################//
procedure Sleep(milliseconds:Cardinal);begin{$IFDEF WIN32}{$IFDEF FPC}sysutils.sleep(milliseconds);{$ELSE}windows.sleep(milliseconds);{$ENDIF}{$ELSE}sysutils.sleep(milliseconds);{$ENDIF}end;
//############################################################################//
end. 
//############################################################################//
