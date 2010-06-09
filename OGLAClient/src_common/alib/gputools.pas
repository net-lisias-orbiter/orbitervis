//############################################################################// 
unit gputools;
interface
uses asys,ActiveX;
//############################################################################// 
function get_gpu_name:string;    
function get_gpu_string(what:string):string;
function get_gpu_dword(what:string):dword;
//############################################################################//
implementation
//############################################################################//              
const
CLSID_WbemLocator:TGUID='{4590f811-1d3a-11d0-891f-00aa004b2e24}';   
IID_IWbemLocator:TGUID='{dc12a687-737f-11cf-884d-00aa004b2e24}';
WBEM_FLAG_RETURN_IMMEDIATELY=16;
WBEM_FLAG_FORWARD_ONLY=32;
WBEM_INFINITE=-1;
//############################################################################//  
type name_variant=packed record
 vt,r1,r2,r3:word;
 s:widestring;
end;
dword_variant=packed record
 vt,r1,r2,r3:word;
 d:dword;
end;

wbelink=record
 ploc:pointer;
 psvc:pointer;
 penum:pointer;  
 pclsobj:pointer; 

 ConnectServer:function(ploc:pointer;const Namespace:WideString;const User,Password,Locale:pointer;SecurityFlags:integer;const authority:pointer;ctx:pointer;var serv:pointer):hresult;stdcall;
 release:function(x:pointer):integer;stdcall;
 ExecQuery:function(psvc:pointer;const QueryLanguage,strQuery:WideString;Flags:integer;ctx:pointer;var ppenum:pointer):hresult;stdcall;
 Next:function(penum:pointer;timeout:integer;count:dword;var pclsobj:pointer;var returned:dword):hresult;stdcall;
 Get:function(pclsobj:pointer;name:widestring;flags:integer;pval,ptype:pointer;plFlavor:pinteger):hresult;stdcall;       
end;
pwbelink=^wbelink;
//############################################################################// 
function gpu_link(var w:wbelink):boolean;
var hr:hresult;
begin 
 result:=false;
 hr:=CoInitializeEx(0,COINIT_MULTITHREADED);     
 if failed(hr)then exit;
 hr:=CoInitializeSecurity(nil,-1,nil,nil,0,3,nil,0,nil); 
 if failed(hr)then exit;

 hr:=CoCreateInstance(CLSID_WbemLocator,nil,CLSCTX_INPROC_SERVER,IID_IWbemLocator,w.ploc);
 if failed(hr)then exit;

 w.ConnectServer:=pointer(pdword(pdword(w.ploc)^+$0C)^);
           
 hr:=w.ConnectServer(w.ploc,'ROOT\CIMV2',nil,nil,nil,0,0,0,w.psvc);
 if failed(hr)then exit;

 hr:=CoSetProxyBlanket(iinterface(w.psvc),10,0,nil,3,3,nil,0);
 if failed(hr)then exit;

 w.penum:=nil; 
 w.ExecQuery:=pointer(pdword(pdword(w.psvc)^+$50)^);   
 hr:=w.ExecQuery(w.psvc,'WQL','SELECT * FROM Win32_VideoController',WBEM_FLAG_FORWARD_ONLY or WBEM_FLAG_RETURN_IMMEDIATELY,nil,w.penum);
 if failed(hr)then exit;

 w.Next:=pointer(pdword(pdword(w.penum)^+$10)^);  
 result:=true; 
end;
//############################################################################// 
procedure gpu_clear(var w:wbelink);
begin
 w.release:=pointer(pdword(pdword(w.psvc)^+$08)^);
 w.release(w.psvc);
 w.release:=pointer(pdword(pdword(w.ploc)^+$08)^);
 w.release(w.ploc);
 CoUninitialize;
end;
//############################################################################// 
function get_gpu_string(what:string):string;
var hr:hresult;
name:name_variant;
return:dword;
w:wbelink;      
begin
 result:=''; 
 return:=0; 
 if not gpu_link(w) then exit;
 
 while w.penum<>nil do begin
  hr:=w.Next(w.penum,WBEM_INFINITE,1,w.pclsobj,return);
  if return=0 then break;
           
  w.Get:=pointer(pdword(pdword(w.pclsobj)^+$10)^);   
  hr:=w.Get(w.pclsobj,what,0,@name,0,0);
  if failed(hr)then continue;
  if name.vt<>8 then continue;
  result:=name.s;
 end;  

 gpu_clear(w);
end; 
//############################################################################// 
function get_gpu_dword(what:string):dword;
var hr:hresult;
val:dword_variant;
return:dword;
w:wbelink;      
begin
 result:=0; 
 return:=0; 
 if not gpu_link(w) then exit;
 
 while w.penum<>nil do begin
  hr:=w.Next(w.penum,WBEM_INFINITE,1,w.pclsobj,return);
  if return=0 then break;
           
  w.Get:=pointer(pdword(pdword(w.pclsobj)^+$10)^);   
  hr:=w.Get(w.pclsobj,what,0,@val,0,0);
  if failed(hr)then continue;
  if val.vt<>3 then continue;
  result:=val.d;
 end;  

 gpu_clear(w);
end;   
//############################################################################// 
function get_gpu_name:string;
begin
 {
 result:=get_gpu_string('Name');
 result:=get_gpu_string('VideoModeDescription');
 result:=get_gpu_string('VideoProcessor');
 result:=get_gpu_string('InstalledDisplayDrivers');
 result:=get_gpu_string('DriverVersion');
 result:=get_gpu_string('Description');
 result:=get_gpu_string('AdapterCompatibility');
 }
 //result:=stri(get_gpu_dword('AdapterRAM'));  
 result:=get_gpu_string('Name');
end;
//############################################################################// 
end.         
//############################################################################//