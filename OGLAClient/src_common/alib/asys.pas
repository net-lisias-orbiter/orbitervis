//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: General definitions 
//############################################################################//
unit asys;
//CPUX86_64
{$ifdef fpc}{$mode delphi}{$endif}
{$ifdef win32}{$define i386}{$define windows}{$endif}
{$ifdef cpu86}{$define i386}{$endif}
interface
{$ifndef ape3}uses 
{$ifdef windows}windows,{$endif}
{$ifdef unix}pthreads,{$endif}
sysutils;{$endif}

const
{$ifdef win32}
CH_SLASH='\';
crlf=#13#10;
{$else}
CH_SLASH='/';
crlf=#10;
{$endif}   
 
Mb=1024*1024;
Kb=1024;

type
int8=shortint;
int16=smallint;
int32=integer; 
//int64=int64;
//byte=byte;
//word=word; 
dword=cardinal;  
qword=int64;

{$ifndef CPUX86_64}
intptr=dword;
{$else}
intptr=PtrUInt;
{$endif}


type 
astr=array of string;
aint=array of int32;   
adouble=array of double;
abyte=array of byte;
aword=array of word;
adword=array of dword;
apointer=array of pointer;
acardinal=array of cardinal; 
aointeger=array of int32;
aosingle=array of single;
aoboolean=array of boolean; 
                    
papointer=^apointer;
paointeger=^aointeger;      
pbytebool=^bytebool;  
padword=^adword;      
pastr=^astr;          
pdword=^dword;
pqword=^qword;     


bytea=array[0..maxint-1]of byte;
pbytea=^bytea; 
chara=array[0..maxint-1]of char;
pchara=^chara; 
worda=array[0..maxint div 2-1]of word;
pworda=^worda;    
dworda=array[0..maxint div 4-1]of dword;
pdworda=^dworda;
dwordap=array[0..maxint div 4-1]of pdworda;
ppdworda=^dwordap;  
inta=array[0..maxint div 4-1]of integer;
pinta=^inta;
smallinta=array[0..maxint div 4-1]of smallint;
psmallinta=^smallinta;
shortinta=array[0..maxint div 4-1]of shortint;
pshortinta=^shortinta;
singlea=array[0..maxint div 4-1]of single;
psinglea=^singlea;
doublea=array[0..maxint div 8-1]of double;
pdoublea=^doublea;
pointera=array[0..maxint div 16-1]of pointer;
ppointera=^pointera;

ppinteger=^pinteger; 
apinteger=array[0..1000]of pinteger;
papinteger=^apinteger;

sortcomparefunc=function(a,b:pointer):int32;

{$ifndef ape3}
function getdate:string;
function getdatestamp:string;
{$endif}

procedure mkpc(var c:pchar;s:integer);
procedure stpc(var c:pchar;s:string);
procedure mspc(var c:pchar;n:integer;s:string);
function ppcn2astr(s:ppchar;n:integer):astr;
function ppcz2astr(s:ppchar):astr;     
function pca2astr(s:pchar):astr;
function astr2msppc(s:astr):ppchar;
function astr2msppcz(s:astr):ppchar;
function msppc(s:integer):ppchar;
procedure frppc(c:ppchar;s:integer);  
procedure ub1;


function isf(flags:dword;bit:dword):boolean;
procedure setf(var flags:dword;bit:dword);
procedure unsf(var flags:dword;bit:dword);    
procedure bolf(var flags:dword;bit:dword;b:boolean);

{$ifndef ape3}
type mutex_typ={$ifdef windows}thandle{$else}tpthreadmutex{$endif};
function mutex_create:mutex_typ;
procedure mutex_lock(var m:mutex_typ);      
procedure mutex_release(var m:mutex_typ);    
procedure mutex_free(var m:mutex_typ);
{$endif}    
       
//##############################################################################    
{$ifndef ape3}
{$ifndef VFS} 
const attall=faanyfile;
attdir=fadirectory;
type vfile=file;

vdirtyp=record
 name:string;
 attr:word;
 size:dword;
 hr,min,sec:byte;
 num,mon:byte;
 yr:word;
 db:array of byte;
end;
avdirtyp=array of vdirtyp;
pvdirtyp=^vdirtyp;

function vfopen(var f:file;n:string;m:integer):boolean;
procedure vfclose(var f:file);
procedure vfread(var f:file;p:pointer;s:int32);
procedure vfwrite(var f:file;p:pointer;s:int32);
procedure vfseek(var f:file;p:int32);
function vffilepos(var f:file):int32;
function vfeof(var f:file):boolean; 
function vfexists(s:string):boolean; 
function vfmkdir(s:string):boolean;   
function vffilesize(var f:vfile):int32;
function vffind(nam:string;attr:word):avdirtyp;
function vffind_arr(nam:string;attr:word):avdirtyp;
{$endif}    
{$endif}    
//##############################################################################
procedure qsort(lst:ppointera;l,r:integer;cmp:sortcomparefunc); 
procedure qsort_ptr_dbl(var a:apointer;var b:adouble;s,n:integer);     
//##############################################################################
{$ifndef ape3}
function DateTimeToUnix(ConvDate: TDateTime):Longint;
function UnixToDateTime(USec:Longint):TDateTime; 
{$endif}       
//############################################################################//
procedure fastMove(const source;var dest;count:integer);{$ifndef ape3}{$ifdef i386}assembler;{$endif}{$endif}
//##############################################################################
implementation       
//############################################################################//  
{$ifdef ape3}procedure fastMove(const source;var dest;count:Integer);begin move(source,dest,count);end;{$else}
 {$ifndef i386}
 procedure fastMove(const source;var dest;count:integer);
 begin
  move(source,dest,count);
 end;    
 {$else}
 {$I i386.inc}
 {$I fastmove.inc}  
 {$endif}  
{$endif}
//##############################################################################
{$ifndef ape3}
var UnixStartDate:TDateTime=25569.0;  
//##############################################################################
function getdate:string;begin getdate:=DateTimeToStr(date+time);end;   
function getdatestamp:string;begin DateTimeToString(result,'yymmdd_hh-nn-ss-zzz',date+time); end;
{$endif}

procedure ub1;
begin
{$ifdef i386}
asm
 mov ebx,0
 mov [ebx],55
end;
{$endif}
end;

procedure mkpc(var c:pchar;s:integer);begin getmem(c,s); fillchar(c^,s,0);end;
procedure stpc(var c:pchar;s:string);var i:integer;begin for i:=0 to length(s)-1 do c[i]:=s[i+1]; end;
procedure mspc(var c:pchar;n:integer;s:string);
var i:integer;
begin 
 getmem(c,n); 
 fillchar(c^,n,0);
 for i:=0 to length(s)-1 do c[i]:=s[i+1]; 
end;
function ppcn2astr(s:ppchar;n:integer):astr;
var i:integer;
begin
 setlength(result,n);
 for i:=0 to n-1 do result[i]:=ppchar(intptr(s)+intptr(i)*4)^;
end;
function ppcz2astr(s:ppchar):astr;
var n:integer;
begin
 n:=0;
 repeat
  if ppchar(intptr(s)+intptr(n)*4)^=nil then exit;
  setlength(result,intptr(n)+1);
  result[n]:=ppchar(intptr(s)+intptr(n)*4)^;
  n:=n+1;
 until false;
end;   
function pca2astr(s:pchar):astr;
var n,c:integer;
begin
 n:=0;
 c:=0;
 repeat
  if pdword(intptr(s)+intptr(n))^=0 then exit;
  setlength(result,c+1);
  result[c]:=pchar(intptr(s)+intptr(n+4));
  c:=c+1;
  n:=n+pinteger(intptr(s)+intptr(n))^+5;
 until false;
end;
function astr2msppc(s:astr):ppchar;
var i:integer;
begin
 getmem(result,length(s)*4);
 for i:=0 to length(s)-1 do mspc(ppchar(intptr(result)+intptr(i)*4)^,255,s[i]);
end;
function astr2msppcz(s:astr):ppchar;
var i:integer;
begin
 getmem(result,length(s)*4+4);
 for i:=0 to length(s)-1 do mspc(ppchar(intptr(result)+intptr(i)*4)^,255,s[i]);
 ppchar(intptr(result)+intptr(length(s)*4))^:=nil;
end;
function msppc(s:integer):ppchar;
var i:integer;
begin
 getmem(result,s*4);
 for i:=0 to s-1 do mspc(ppchar(intptr(result)+intptr(i)*4)^,255,'');
end;
procedure frppc(c:ppchar;s:integer);
var i:integer;
begin
 for i:=0 to s-1 do freemem(ppchar(intptr(c)+intptr(i)*4)^);
 freemem(c);
end;
//##############################################################################
{$ifndef ape3}
{$ifndef VFS} 
function vfopen(var f:file;n:string;m:integer):boolean;
begin
 if n[1]='/' then n:=copy(n,2,10000);
 if m=1 then if not fileexists(n) then begin result:=false; exit; end;
 assignfile(f,n);
 if m=1 then reset(f,1); 
 if m=2 then rewrite(f,1); 
 result:=true;
end;
procedure vfclose(var f:file);
begin
 closefile(f);
end;
procedure vfread(var f:file;p:pointer;s:integer);
begin
 blockread(f,p^,s);
end;
procedure vfwrite(var f:file;p:pointer;s:integer);
begin
 blockwrite(f,p^,s);
end;
procedure vfseek(var f:file;p:integer);
begin
 seek(f,p);
end;   
function vffilepos(var f:file):integer;
begin
 result:=filepos(f);
end;
function vfeof(var f:file):boolean;
begin
 result:=eof(f);
end;
function vfexists(s:string):boolean;
begin    
 if s[1]='/' then s:=copy(s,2,10000);
 result:=fileexists(s);
end; 
function vfmkdir(s:string):boolean;
begin
 result:=true;
 mkdir(s);
end; 
function vffilesize(var f:vfile):integer;
begin
 result:=filesize(f);
end;  
function vffind(nam:string;attr:word):avdirtyp;
var srch:TSearchRec;
mc:integer;
begin     
 setlength(result,0);
 mc:=0;

 if findfirst(nam,faanyfile,srch)<>0 then begin findclose(srch);exit;end;
 repeat
  setlength(result,mc+1);
  result[mc].name:=srch.name;
  result[mc].size:=srch.size;
  result[mc].attr:=srch.Attr and fadirectory;
  mc:=mc+1;      
  if findnext(srch)<>0 then begin findclose(srch);exit;end;
 until false;  
end;     
function vffind_arr(nam:string;attr:word):avdirtyp;
begin
 result:=vffind(nam,attr);
end;
{$endif}   
{$endif}
//##############################################################################
procedure qsort(lst:ppointera;l,r:integer;cmp:sortcomparefunc);
var i,j:integer;
p,q:pointer;
begin
 repeat
  i:=L;j:=R;
  p:=lst^[(l+r)div 2];
  repeat
   while cmp(p,lst^[i])>0 do i:=i+1;
   while cmp(p,lst^[j])<0 do j:=j-1;
   if i<=j then begin
    q:=lst^[i];
    lst^[i]:=lst^[j];
    lst^[j]:=q;
    i:=i+1;
    j:=j-1;
   end;
  until i>j;
  if l<j then qsort(lst,l,j,cmp);
  l:=i;
 until i>=r;
end;  
//############################################################################// 
procedure qsort_ptr_dbl(var a:apointer;var b:adouble;s,n:integer);
var i,j:integer;
tp:pointer;
td,pd:double;
begin
 i:=s;j:=n;
 if n<=0 then exit;
 pd:=b[n shr 1];
 repeat
  while b[i]<pd do i:=i+1;
  while b[j]>pd do j:=j-1;
  if i<=j then begin
   tp:=a[i];td:=b[i]; 
   a[i]:=a[j];b[i]:=b[j]; 
   a[j]:=tp;b[j]:=td;
   i:=i+1; j:=j-1;
  end;
 until i>j;
 if j>0 then qsort_ptr_dbl(a,b,0,j);
 if n>i then qsort_ptr_dbl(a,b,i,n-i);
end; 
//##############################################################################    
{$ifndef ape3}
{$ifdef windows}    
function mutex_create:mutex_typ;   
begin              
 //result:=CreateSemaphore(nil,1,1,nil);
 result:=CreateMutex(nil,true,nil);
end;
procedure mutex_lock(var m:mutex_typ);  
begin
 WaitForSingleObject(m,INFINITE);
end;
procedure mutex_release(var m:mutex_typ); 
begin
 releasemutex(m); 
 //ReleaseSemaphore(m,1,nil); 
end;   
procedure mutex_free(var m:mutex_typ); 
begin
 CloseHandle(m);
end;
{$endif}
{$ifdef unix}  
//FIX!
function mutex_create:mutex_typ;   
begin
 pthread_mutex_init(@result,nil);
end;
procedure mutex_lock(var m:mutex_typ);  
begin
 pthread_mutex_lock(m);
end;
procedure mutex_release(var m:mutex_typ); 
begin
 pthread_mutex_unlock(m);
end;   
procedure mutex_free(var m:mutex_typ); 
begin
end;
{$endif}  
{$endif}
//##############################################################################   
function  isf(flags:dword;bit:dword):boolean;begin result:=(flags and bit)<>0;end;   
procedure setf(var flags:dword;bit:dword);begin flags:=flags or bit;end;
procedure unsf(var flags:dword;bit:dword);begin flags:=flags and(not bit);end;
procedure bolf(var flags:dword;bit:dword;b:boolean);begin if b then setf(flags,bit)else unsf(flags,bit);end;
//############################################################################## 
{$ifndef ape3}
function DateTimeToUnix(ConvDate: TDateTime):Longint;begin result:=Round((ConvDate-UnixStartDate)*86400); end; 
function UnixToDateTime(USec:Longint):TDateTime;begin result:=(Usec/86400)+UnixStartDate; end;   
{$endif}  
//##############################################################################
begin
end.
//##############################################################################




