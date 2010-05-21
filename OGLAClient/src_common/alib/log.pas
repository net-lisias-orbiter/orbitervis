//############################################################################//
unit log;
interface
uses {$ifdef win32}windows,{$endif}asys,sysutils,parser; 
//############################################################################//
type lngtyp=record
 txt,nm:string;
end;
//############################################################################//
var log_file_name:string;   
lang:array of lngtyp;  
lngsiz:integer;
errcnt:integer=0;
crash:boolean=false;
//############################################################################//
procedure set_log(n:string); 
procedure wr_log(sys,err:string;hlt:boolean=false);      
procedure bigerror(n:dword;msg:string);
procedure stderr(dev,proc:string);   
   
procedure wrln_dbg(s,err:string);
procedure wr_dbg(s,err:string);   
procedure haltprog;
//############################################################################// 
function  po(inp:string):string;              
procedure load_lang(dir,nam:string);   
//############################################################################//
implementation 
{
const
errs:array[0..4]of string=(
'Unnamed error'#13#10'Thread 1'#13#10'Planet module',
'Unnamed error'#13#10'Thread 2'#13#10'Planet module',
'Error loading textures (Out of memory?)'#13#10'Thread 1'#13#10'Planet init section',
'Error loading heightmaps (Out of memory?)'#13#10'Thread 1'#13#10'Planet init section',
'Error loading global texture (Out of memory?)'#13#10'Thread 1'#13#10'Planet module LoadTex');
}    
//############################################################################//
const
errs:array[0..1]of string=('OpenGL init failed|Ошибка инициализации OpenGL','Rendering error|Ошибка рендеринга');
{$ifdef win32}crlf:string=#13#10;{$else}crlf:string=#10;{$endif}
//############################################################################//
//Error report message thread
var
smerr:string;
smms:dword;
procedure smm;
begin
 sleep(1000);
 {$ifdef win32}
 if smms=999 then begin
  if messagebox(0,pchar('Critical error in OGLA.dll, terminating. See ogla.log for details for developer.'+crlf+'Критическая ошибка в OGLA.dll. Подробности для разработчика в ogla.log.'+crlf+crlf+'Error|Ошибка: "'+smerr+'"'),pchar('OGLA: Error|Ошибка'),MB_ICONERROR or MB_OK or MB_TOPMOST)=0 then;
 end else begin
  if messagebox(0,pchar('Critical error in OGLA.dll, terminating. See ogla.log for details for developer.'+crlf+'Критическая ошибка в OGLA.dll. Подробности для разработчика в ogla.log.'+crlf+crlf+'Error|Ошибка: "'+errs[smms]+'"'),pchar('OGLA: Error|Ошибка'),MB_ICONERROR or MB_OK or MB_TOPMOST)=0 then;
 end;
 {$endif}
 crash:=true;
 halt; 
end;                                                                  
//############################################################################//  
procedure set_log(n:string);
begin
 log_file_name:=n;
end;
//############################################################################//
function trims(s:string;n:integer):string;
begin
 result:=s;
 while length(result)<n do result:=result+' ';
end;
//############################################################################//
procedure wr_log(sys,err:string;hlt:boolean=false);
var t:text;
begin
 {$I-}
 assignfile(t,log_file_name);
 if fileexists(log_file_name) then append(t) else rewrite(t);
 writeln(t,DateToStr(date),'-',TimeToStr(time),':[',trims(sys,10),']:',err);
 closefile(t);
 if ioresult<>0 then ;
 {$I+}
 if hlt then halt;
end;      
//############################################################################//
procedure wrln_dbg(s,err:string);begin exit;wr_log(s,err);{$ifdef CONDEBUG}writeln(s);{$endif}end;
procedure wr_dbg(s,err:string);begin exit;wr_log(s,err);{$ifdef CONDEBUG}write(s);{$endif}end;
procedure haltprog;
begin
 {$ifdef win32}exitprocess(0);{$endif}
 halt;
end; 
//############################################################################//
procedure bigerror(n:dword;msg:string);
var tha:thandle;
begin
 smms:=n;
 smerr:=msg;
 {$ifdef win32}BeginThread(nil,0,@smm,@n,0,tha);{$else}BeginThread(@smm,@n);{$endif}
 EndThread(0);
end;      
//############################################################################//
procedure stderr(dev,proc:string);
begin  
 wr_log(dev,'Error: '+proc);
 errcnt:=errcnt+1;
 if errcnt>20 then begin
  smerr:='Last Error|Последняя ошибка: '+dev+': Error: '+proc;
  bigerror(999,proc);
 end;
end;
//############################################################################//
procedure load_lang(dir,nam:string);
var i:integer;
psr:preca;
f:string;
begin psr:=nil; try
 f:=dir+nam+'.lng';
 if not vfexists(f)then f:=dir+'eng.lng';
 if not vfexists(f)then exit;

 psr:=parsecfg(f,true);
 lngsiz:=length(psr);
 setlength(lang,lngsiz);
 for i:=0 to length(psr)-1 do with psr[i] do begin lang[i].nm:=par;lang[i].txt:=props;end;       
   
 except wr_log('INIT','load_lang',true); end; 
end;    
//############################################################################// 
function po(inp:string):string;
var i:integer;
begin
 po:=inp;
 for i:=0 to lngsiz-1 do if lang[i].nm=inp then begin po:=lang[i].txt; exit; end;
end; 
//############################################################################//
begin
 log_file_name:='thelog.log';
end.
//############################################################################//