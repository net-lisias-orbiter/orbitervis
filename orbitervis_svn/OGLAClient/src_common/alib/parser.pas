//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: CFG parser 
//############################################################################//
unit parser;
{$ifdef fpc}{$mode delphi}{$endif}
interface
uses asys,{$ifdef VFS}vfs,{$endif}maths,strval;
//############################################################################//
type parserectyp=record
 par,props,src:string;
 propn:integer;
 propb:boolean;
 propd:double; 
 propv2:vec2; 
 propv4:quat; 
 propv5:vec5;
 propv:vec;
end;
preca=array of parserectyp;
ppreca=^preca;
//############################################################################//
function parsecfg(f:pointer;bs:dword;lg:boolean;ec:char='='):preca;overload;
function parsecfg(f:string;lg:boolean;ec:char='='):preca; overload;
function parsecfg(f:astr;lg:boolean;ec:char='='):preca; overload;
//############################################################################//
implementation

const digits:set of char=['0'..'9','-','+'];
type string250=string[250];
//############################################################################//
//0.398-0.400
//for j:=0 to 10 do begin
// stdt(11);
// for i:=0 to 1000 do loadsetup;
// writeln(rtdt(11));
//end;
function parsecfg(f:pointer;bs:dword;lg:boolean;ec:char='='):preca; overload;
var str1,str2,str3:string250;
ch:char;
i2,i3,mc,pvnm,ls1:integer;
bp:dword;
comm,comme,fss,penm:boolean;

procedure readtln(var s:string250;var l:integer);
var b:char;
begin
 s:='';l:=0;
 repeat
  b:=pchar(intptr(f)+bp)^;bp:=bp+1;
  if(b<>#$0D)and(b<>#$0A)then begin s:=s+b;l:=l+1;end;
 until(bp>=bs)or(b=#$0A)or(l>=250);
end;

begin
 if bs=0 then exit;
 bp:=0;mc:=0;
 comm:=false;
 repeat
  comme:=false;
  str1:='';str2:='';str3:='';
  penm:=false;pvnm:=0;
  readtln(str1,ls1);
  if ls1>2 then if (copy(str1,0,2)<>'//')and(str1[1]<>';') then begin

   for i2:=1 to ls1 do begin
    ch:=str1[i2];
    if not comm then begin 
     case ch of
      ' ':if not lg then continue;
      #9 :continue;
      '{':begin comm:=true; continue; end;
      else if ch=ec then break;
     end;
     str2:=str2+ch;
    end else if ch='}' then begin if i2=ls1 then comme:=true; comm:=false; end;
   end;
   fss:=true;
   
   for i3:=i2+1 to ls1 do begin
    ch:=str1[i3];
    if not comm then begin
     if (copy(str1,i3,2)='//')or(ch=';') then break;
     case ch of
      ' ':if fss or (not lg) then continue else pvnm:=pvnm+1;
      '.':penm:=true;
      'e':penm:=true;
      ',':pvnm:=pvnm+1;
      #9 :if fss or (not lg) then continue;
      '{':begin comm:=true; if i3=ls1 then comme:=true; continue; end;
     end;
     fss:=false;
     str3:=str3+ch;
    end else if ch='}' then begin if i3=ls1 then comme:=true; comm:=false; end;
   end;

   
   if (not comm)xor(comme) then begin
    setlength(result,mc+1);
    result[mc].par:=str2;
    result[mc].props:=str3;   
    result[mc].src:=str1;
    if length(str3)>0 then if str3[1] in digits then begin
     result[mc].propn:=vali(str3);
     if penm then result[mc].propd:=vale(str3)
     else result[mc].propd:=result[mc].propn;
     if pvnm>=4 then result[mc].propv5:=valvec5(str3);
     if pvnm>=2 then result[mc].propv:=valvec(str3);
     if pvnm>=1 then result[mc].propv2:=valvec2(str3);
     if pvnm>=3 then result[mc].propv4:=valquat(str3);
     result[mc].propb:=result[mc].propn>0;
    end;
    mc:=mc+1;
   end;
  end;
 until bp>=bs;
end;
//############################################################################//
//############################################################################//
{$ifdef VFS}
function parsecfg(f:string;lg:boolean;ec:char='='):preca; overload;
var vf:vfile;
p:pointer;
begin
 if not vfopen(vf,f,1) then exit;
 if vf.inf.size=0 then begin vfclose(vf);exit; end;
 getmem(p,vf.inf.size);
 vfread(vf,p,vf.inf.size);
 vfclose(vf);
 result:=parsecfg(p,vf.inf.size,lg,ec);
 freemem(p);
end;
{$else}
function parsecfg(f:string;lg:boolean;ec:char='='):preca; overload;
var vf:file;
p:pointer;
begin
 {$i-}
 assignfile(vf,f);
 reset(vf,1); 
 if ioresult<>0 then exit;  
 {$i+}
 getmem(p,filesize(vf));
 blockread(vf,p^,filesize(vf));
 result:=parsecfg(p,filesize(vf),lg,ec);
 freemem(p);
 closefile(vf);
end;
{$endif} 
function parsecfg(f:astr;lg:boolean;ec:char='='):preca; overload;
var p:pointer;
i,l,k:integer;
begin
 l:=0;
 for i:=0 to length(f)-1 do l:=l+length(f[i]);
 l:=l+2*length(f); 
 getmem(p,l);
 k:=0;
 for i:=0 to length(f)-1 do begin
  move(f[i][1],pbyte(intptr(p)+intptr(k))^,length(f[i]));
  k:=k+length(f[i])+2;
  pbyte(intptr(p)+intptr(k-2))^:=$0D;
  pbyte(intptr(p)+intptr(k-1))^:=$0A;
 end;

 result:=parsecfg(p,l,lg,ec);
 freemem(p);
end;
//############################################################################//
begin
end.  
//############################################################################//
