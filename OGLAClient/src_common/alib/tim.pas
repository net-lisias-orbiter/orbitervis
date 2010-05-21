//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: Timer 
//############################################################################//
unit tim;                         
//{$define i386}
//{$define timdebug}
{$ifdef win32}{$define windows}{$endif}
{$ifdef fpc}{$mode delphi}{$endif}
interface
{$ifdef windows}uses windows;{$endif}
{$ifdef unix}uses dos,baseunix,sysutils,unix;{$endif}         
//############################################################################//
type tbfa=array[0..49]of int64;
//############################################################################//
var {$ifdef windows}str,fin:array[0..100]of Int64; frq:int64;{$endif}
dowrtim:boolean;   
//############################################################################//
procedure tbfp(var tbf:tbfa;var rs:int64);{$ifdef FPC}inline;{$endif}  
procedure tbcl(var tbf:tbfa);{$ifdef FPC}inline;{$endif}

procedure stdt(d:integer);{$ifdef FPC}inline;{$endif}
procedure wrdt(d:integer); overload;{$ifdef FPC}inline;{$endif}
procedure wrdt(d:integer;st:string); overload;{$ifdef FPC}inline;{$endif}
function rtdt(d:integer):Int64;{$ifdef FPC}inline;{$endif}  
{$ifdef i386}
function rdtsc:Int64;{$ifdef FPC}inline;{$endif}  
{$endif}              
function getdt:integer;
procedure freedt(n:integer);
//############################################################################//
implementation   
//############################################################################//
var dtts:array[0..100]of int64;
dtused:array[0..100]of boolean;
//############################################################################//
{$ifdef i386}
function rdtsc:Int64;  
asm  
 rdtsc  
 mov    dword ptr [Result], eax  
 mov    dword ptr [Result + 4], edx
end;
{$endif}
//############################################################################//
procedure tbcl(var tbf:tbfa);{$ifdef FPC}inline;{$endif}
var i:integer;
begin
 for i:=0 to 49 do tbf[i]:=0;
end;       
//############################################################################//
procedure tbfp(var tbf:tbfa;var rs:int64);{$ifdef FPC}inline;{$endif}
var i:integer;
begin
 for i:=1 to 49 do tbf[i-1]:=tbf[i];
 tbf[49]:=rs;
 rs:=0;
 //for i:=0 to 49 do rs:=rs+tbf[i];          
 //rs:=rs div 50;
 for i:=0 to 49 do if tbf[i]>rs then rs:=tbf[i];
end;
//############################################################################//
{$ifdef unix}
function getuscount:int64;{$ifdef FPC}inline;{$endif}
var tv:TimeVal;
begin
 FPGetTimeOfDay(@tv,nil);
 result:=tv.tv_Sec*1000000+tv.tv_uSec;
end;
{$endif}
//############################################################################//
procedure stdt(d:integer);{$ifdef FPC}inline;{$endif}
begin     
 if not dtused[d] then begin
  {$ifdef unix}writeln('TIM! (',d,')');{$else}messagebox(0,'TIM!','Programmer error',MB_OK);{$endif}
  dtts[d]:=0
 end;
 {$ifdef windows}QueryPerformanceCounter(str[d]);{$endif}
 //str[d]:=gettickcount*1000;
 {$ifdef unix}dtts[d]:=getuscount;{$endif}   
 {$ifdef timdebug}dtts[d]:=0;{$endif}
end;   
//############################################################################//
procedure wrdt(d:integer); overload;{$ifdef FPC}inline;{$endif}
begin
 if dowrtim then writeln(rtdt(d)-dtts[d],' ms');
end;    
//############################################################################//
procedure wrdt(d:integer;st:string); overload;{$ifdef FPC}inline;{$endif}
begin
 if dowrtim then writeln(st,': ',rtdt(d)-dtts[d],' ms');
end;     
//############################################################################//
function rtdt(d:integer):Int64;{$ifdef FPC}inline;{$endif}
begin
 {$ifdef windows}
 QueryPerformanceCounter(fin[d]); 
 result:=round((fin[d]-str[d])/frq*1000000);
 {$ifdef timdebug}dtts[d]:=dtts[d]+100;result:=dtts[d];{$endif}
 {$endif}
 //result:=gettickcount*1000-str[d];
 {$ifdef unix}result:=getuscount-dtts[d];{$endif}
end; 
//############################################################################//
function getdt:integer;
var i:integer;
begin
 result:=0;
 for i:=100 downto 0 do if not dtused[i] then begin dtused[i]:=true;result:=i;exit;end;
end;
//############################################################################//
procedure freedt(n:integer);begin dtused[n]:=false;end;
//############################################################################//
var i:integer;
begin
 for i:=0 to 100 do dtused[i]:=false;
 dtused[0]:=true;
 {$ifdef windows}QueryPerformanceFrequency(frq);{$endif}
 dowrtim:=false;
 stdt(0);
end.   
//############################################################################//

