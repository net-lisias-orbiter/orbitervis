//############################################################################//
unit lzw;
interface
uses asys,classes;  
//############################################################################//    
type lossrange=0..4;  
procedure decodeLZW(src,dst:pointer;sni,sd:integer);
procedure encodeLZW(src,dst:pointer;var siz:dword);
procedure encodeLZWloss(src,dst:pointer;smoothRange:lossrange;var siz:dword);
//############################################################################//
implementation  
//############################################################################//
const
clearcode=256;
eoicode=257;

type
lzwtrec=record
 index,prefix:word;
 suffix,firstbyte:byte;
end;
pcluster=^tcluster;
tcluster=record
 index:word;
 next:pcluster;
end;
lzwrec=record
 code_addr,dest:pbyte;
 code_len,borrowed_bits:byte;
 last_entry:dword;
 btrd:dword;
 lzwtable:array[0..4095]of lzwtrec;
 clusters:array[0..4095]of pcluster;
end;
//############################################################################//
function concatenation(var lzw:lzwrec;pprefix:word;lastbyte:byte;index:word):lzwtrec;
begin         
 result.suffix:=lastbyte;
 if pprefix=clearcode then begin
  result.index:=lastbyte;
  result.firstbyte:=lastbyte;
  result.prefix:=pprefix;
 end else begin
  result.index:=index;
  result.firstbyte:=lzw.lzwtable[pprefix].firstbyte;
  result.prefix:=lzw.lzwtable[pprefix].index;
 end;   
end;
//############################################################################//
procedure initialize(var lzw:lzwrec);
var i:integer;
begin       
 lzw.last_entry:=257;lzw.code_len:=9;
 for i:=0 to 255 do with lzw.lzwtable[i] do begin
  index:=i;prefix:=256;
  suffix:=i;firstbyte:=i;
 end;
 for i:=256 to 4095 do with lzw.lzwtable[i] do begin
  index:=i;prefix:=256;
  suffix:=0;firstbyte:=0;
 end;      
end;
//############################################################################//
procedure Releaseclusters(var lzw:lzwrec);
var i:integer;
workcluster:pcluster;
begin
 for i:=0 to 4095 do begin
  while assigned(lzw.clusters[i]) do begin
  {
   workcluster:=lzw.clusters[i];
   lzw.clusters[i]:=lzw.clusters[i].next;
   dispose(workcluster);
  }     
   workcluster:=lzw.clusters[i].next;
   lzw.clusters[i].next:=nil;
   dispose(lzw.clusters[i]);
   lzw.clusters[i]:=workcluster;
  end;
 end;   
end;
//############################################################################//
procedure clearclusters(var lzw:lzwrec);
var i:integer;
begin
 for i:=0 to 4095 do lzw.clusters[i]:=nil;   
end;      
//############################################################################//
procedure writebytes(var lzw:lzwrec;entry:lzwtrec);
begin
 if entry.prefix=clearcode then begin
  lzw.dest^:=entry.suffix;
  inc(lzw.dest);
 end else begin
  writebytes(lzw,lzw.lzwtable[entry.prefix]);
  lzw.dest^:=entry.suffix;
  inc(lzw.dest);
 end;    
end;  
//############################################################################//
procedure Addentry(var lzw:lzwrec;entry:lzwtrec);
begin
 lzw.lzwtable[entry.index]:=entry;
 lzw.last_entry:=entry.index;
 case lzw.last_entry of
  510,1022,2046:inc(lzw.code_len);
  4093:lzw.code_len:=9;
 end;
end;
//############################################################################//
{$ifndef wince}{$define i386}{$endif}
{$ifdef i386}
function GetNextcode(var lzw:lzwrec):word; assembler;
// eAX contains self reference
asm
 push ebx
 push edx
 
 mov  ebx,[lzw.code_addr]
 mov  ch,16
 add  ch,[lzw.borrowed_bits]
 sub  ch,[lzw.code_len]
 cmp  ch,8
 jg   @@twobytes
 jmp  @@threebytes

@@twobytes:
 mov  dh,[ebx]
 mov  dl,[ebx+1]
 mov  cl,8
 sub  cl,[lzw.borrowed_bits]
 shl  dh,cl
 shr  dh,cl
 mov  cl,[lzw.borrowed_bits]
 add  cl,8
 sub  cl,[lzw.code_len]
 shr  dl,cl
 shl  dl,cl
 shr  dx,cl
 mov  byte [lzw.borrowed_bits],cl
 inc  [lzw.code_addr]
 jmp  @@finished

@@threebytes:
 mov  dh,[ebx]
 mov  dl,[ebx+1]
 push eax
 mov  ah,[lzw.borrowed_bits]
 mov  al,[ebx + 2]
 mov  cl,8
 sub  cl,ah
 shl  dx,cl
 shr  dx,cl
 mov  cl,ch
 shr  al,cl
 mov  ch,8
 sub  ch,cl
 xchG cl,ch
 shl  dx,cl 
 xor  ah,ah
 or   dx,ax
 pop  eax
 mov  byte [lzw.borrowed_bits],ch
 add  [lzw.code_addr],2
@@finished:    // ax already contains result
 mov  [result],dx
 pop  edx
 pop  ebx
end;
{$else}
function GetNextcode(var lzw:lzwrec):word;
begin
 result:=0;   
end;
{$endif}
//############################################################################//
procedure decodeLZW(src,dst:pointer;sni,sd:integer);
var lzw:lzwrec;
fcode,oldcode:word;
begin
 lzw.dest:=dst;
 lzw.borrowed_bits:=8;
 lzw.code_len:=9;
 lzw.btrd:=0;
 lzw.code_addr:=src;
 initialize(lzw);
 oldcode:=256;
 fcode:=GetNextcode(lzw);
 while fcode<>eoicode do begin
  if integer(dword(lzw.code_addr)-dword(src))>=sni then begin
   pbyte(src)^:=0;
   exit;
  end;
  if integer(dword(lzw.dest)-dword(dst))>=sd then begin  
   pbyte(src)^:=0;
   exit;
  end;
  if fcode=clearcode then begin
   initialize(lzw);
   fcode:=GetNextcode(lzw);
   if fcode=eoicode then break;
   writebytes(lzw,lzw.lzwtable[fcode]);
   oldcode:=fcode;
  end else begin
   if fcode<=lzw.last_entry then begin   
    writebytes(lzw,lzw.lzwtable[fcode]);
    Addentry(lzw,concatenation(lzw,oldcode,lzw.lzwtable[fcode].firstbyte,lzw.last_entry+1));
    oldcode:=fcode;
   end else begin
    if fcode>(lzw.last_entry+1) then break else begin   
     writebytes(lzw,concatenation(lzw,oldcode, lzw.lzwtable[oldcode].firstbyte, lzw.last_entry + 1));
     Addentry(lzw,concatenation(lzw,oldcode, lzw.lzwtable[oldcode].firstbyte, lzw.last_entry + 1));
     oldcode:=fcode;
    end;
   end;
  end;
  fcode:=GetNextcode(lzw);
 end;   
end;
//############################################################################//
procedure writecodetostream(var lzw:lzwrec;code:word);
var t1,t2:word;
tb:byte;
begin
 if lzw.code_len>=lzw.borrowed_bits+8 then begin
  t1:=lzw.code_len-lzw.borrowed_bits-8; 
  tb:=lo(code-(code and($FFFF shl t1)))shl(8-t1);
  t2:=code shr t1;

  lzw.dest^:=lzw.dest^ or hi(t2);
  inc(lzw.dest); 
  lzw.dest^:=lzw.dest^ or lo(t2);   
  inc(lzw.dest); 
  lzw.dest^:=lzw.dest^ or tb; 
  
  lzw.borrowed_bits:=8-t1;
 end else begin
  t2:=lzw.borrowed_bits-lzw.code_len+8;
  t1:=code shl t2;
  lzw.dest^:=lzw.dest^ or hi(t1);
  inc(lzw.dest);      
  lzw.dest^:=lzw.dest^ or lo(t1);
  lzw.borrowed_bits:=t2;
 end;
end;
//############################################################################//
function codefromstring(var lzw:lzwrec;str:lzwtrec):word;
var workcluster:pcluster;
begin
 if str.prefix=256 then result:=str.index else begin
  workcluster:=lzw.clusters[str.prefix];
  if workcluster=nil then result:=4095 else begin  
   while assigned(workcluster.Next)do begin
    if str.suffix<>lzw.lzwtable[workcluster.index].suffix then workcluster:=workcluster.Next else break;
   end;    
   if str.suffix=lzw.lzwtable[workcluster.index].suffix then result:=workcluster.index else result:=4095;   
  end;
 end;
end;
//############################################################################//
procedure Addtableentry(var lzw:lzwrec;entry:lzwtrec);
var workcluster:pcluster;
begin
 lzw.lzwtable[entry.index]:=entry;
 lzw.last_entry:=entry.index;
 if lzw.clusters[lzw.lzwtable[lzw.last_entry].prefix]=nil then begin
  new(lzw.clusters[lzw.lzwtable[lzw.last_entry].prefix]);
  lzw.clusters[lzw.lzwtable[lzw.last_entry].prefix].index:=lzw.last_entry;
  lzw.clusters[lzw.lzwtable[lzw.last_entry].prefix].Next:=nil;
 end else begin
  workcluster:=lzw.clusters[lzw.lzwtable[lzw.last_entry].prefix];
  while assigned(workcluster.Next) do workcluster:=workcluster.Next;
  new(workcluster.Next);
  workcluster.Next.index:=lzw.last_entry;
  workcluster.Next.Next:=nil;
 end;
end;
//############################################################################//
var k:integer;
procedure encodeLZW(src,dst:pointer;var siz:dword);
var vprefix,currentry:lzwtrec;
currcode:word;
i:integer;
stream:pbytea;
lzw:lzwrec;
begin      
 fillchar(lzw,sizeof(lzw),0);
 lzw.dest:=dst;
 fillchar(lzw.dest^,siz,0);
 initialize(lzw);
 clearclusters(lzw);
 lzw.borrowed_bits:=8;
 writecodetostream(lzw,clearcode);
 lzw.code_addr:=src;
 stream:=src;
 lzw.btrd:=0;
 vprefix:=lzw.lzwtable[clearcode];
 for i:=0 to siz-1 do begin
  if i=235612 then begin
   k:=9;
  end;
  currentry:=concatenation(lzw,vprefix.index,stream[i],lzw.last_entry+1);
  currcode:=codefromstring(lzw,currentry);
  if currcode<=lzw.last_entry then vprefix:=lzw.lzwtable[currcode] else begin
   writecodetostream(lzw,vprefix.index);
   Addtableentry(lzw,currentry);
   vprefix:=lzw.lzwtable[stream[i]];
   case lzw.last_entry of
    511,1023,2047:inc(lzw.code_len);
    4093:begin
     writecodetostream(lzw,clearcode);
     lzw.code_len:=9;
     Releaseclusters(lzw);
     lzw.last_entry:=eoicode;
    end;
   end;
  end;                     //235555
 end;
 writecodetostream(lzw,codefromstring(lzw,vprefix));
 writecodetostream(lzw,eoicode);
 Releaseclusters(lzw);
 siz:=1+dword(lzw.dest)-dword(dst);
end;
//############################################################################//
procedure encodeLZWloss(src,dst:pointer;smoothRange:lossrange;var siz:dword);
var cbyte,byteMask:byte;
vprefix,currentry:lzwtrec;
currcode:word;
i:integer;
stream:pbytea;
lzw:lzwrec;
begin
 byteMask:=($ff shr smoothRange) shl smoothRange;
 lzw.dest:=dst;
 initialize(lzw);
 Clearclusters(lzw);
 lzw.borrowed_bits:=8;
 writecodetostream(lzw,clearcode);
 lzw.code_addr:=src;
 stream:=src;
 lzw.btrd:=0;
 vprefix:=lzw.lzwtable[clearcode];
 for i:=0 to  siz-1 do begin
  cbyte:=stream[i] and byteMask;
  currentry:=concatenation(lzw,vprefix.index,cbyte,lzw.last_entry+1);
  currcode:=codefromstring(lzw,currentry);
  if currcode<=lzw.last_entry then vprefix:=lzw.lzwtable[currcode] else begin
   writecodetostream(lzw,vprefix.index);
   Addtableentry(lzw,currentry);
   vprefix:=lzw.lzwtable[cbyte];
   case lzw.last_entry of
    511,1023,2047:inc(lzw.code_len);
    4093:begin
     writecodetostream(lzw,clearcode);
     lzw.code_len:=9;
     Releaseclusters(lzw);
     lzw.last_entry:=eoicode;
    end;
   end;
  end;
 end;
 writecodetostream(lzw,codefromstring(lzw,vprefix));
 writecodetostream(lzw,eoicode);
 Releaseclusters(lzw);
 siz:=1+dword(lzw.dest)-dword(dst);
end;
//############################################################################//
begin
end.
//############################################################################//
