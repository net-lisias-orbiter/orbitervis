//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: PNG loader 
//############################################################################//
unit png;
{$ifdef fpc}{$mode delphi}{$endif}
interface
uses asys,sysutils,grph,grplib,mzlib,math{$ifdef VFS},vfs,vfsutils{$endif}{$ifdef THEAPE},akernel,vfsint{$endif};
{define pngdbg} 
//############################################################################//
function ldpngbuf(buf:pointer;bs:integer;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer; 
function ispngbuf(buf:pointer;bs:integer):boolean;        
function ldpng(fn:string;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;  
function ispng(fn:string):boolean;        
function ispng8(fn:string):boolean;                               
function ldpng8(fn:string;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer;var cpal:pallette):pointer;  
//############################################################################//
//############################################################################//
implementation
{$ifdef VFS} 
function vfpos(var f:vfile):integer;
begin
 result:=f.pos;
end;    
{$endif}
//############################################################################//
const pngid:array[0..7]of byte=(137,80,78,71,13,10,26,10);

type
a4c=array[0..3]of char;
pnghdr=array[0..7]of byte;
ppnghdr=^pnghdr;
pngchkhdr=record
 lng:dword;
 tp:a4c;
end;

pngchklf=record
 lng:dword;
 tp:a4c;
 aux,pri,res,stc:boolean;
 dat:pointer;
 crc:dword;
end;

pngihdr=packed record
 wid,hei:dword;
 bit,cltyp,comp,filt,intl:byte;
end;
ppngihdr=^pngihdr;

pngpaltyp=array of crgb;

type a4b=array[0..3]of byte;
pa4b=^a4b;
//############################################################################//
//############################################################################//
function dwle2be(d:dword):dword;
var c:a4b;
begin
 c:=a4b(d);
 a4b(result)[0]:=c[3];
 a4b(result)[1]:=c[2];
 a4b(result)[2]:=c[1];
 a4b(result)[3]:=c[0];
end;
//############################################################################//
function PaethPredictor(a,b,c:Byte):Byte;
var p,pa,pb,pc:Integer;
begin
 //a=left, b=above, c=upper left
 p:=a+b-c;        //initial estimate
 pa:=abs(p-a);    //distances to a, b, c
 pb:=abs(p-b);
 pc:=abs(p-c);
 //return nearest of a, b, c, breaking ties in order a, b, c
 if(pa<=pb)and(pa<=pc)then result:=a else if pb<=pc then result:=b else result:=c;
end;
//############################################################################//
procedure pngApplyFilter(Filter:Byte;Line,PrevLine,Target:PByte;BPP,BytesPerRow:integer);
// Applies the filter given in Filter to all bytes in Line (eventually using PrevLine).
// Note: The filter type is assumed to be of filter mode 0, as this is the only one currently
//       defined in PNG.
//       in opposition to the PNG documentation different identifiers are used here.
//       Raw refers to the current, not yet decoded value. decoded refers to the current, already
//       decoded value (this one is called "raw" in the docs) and Prior is the current value in the
//       previous line. For the Paeth prediction scheme a fourth pointer is used (Priordecoded) to describe
//       the value in the previous line but less the BPP value (Prior[x - BPP]).      
var i:integer;
Raw,decoded,Prior,Priordecoded,TargetRun:PByte;
begin
 case Filter of
  //0:Move(Line^,Target^,BytesPerRow);//no filter, just copy data
  1:begin //subtraction filter
   Raw:=Line;
   TargetRun:=Target;
   //Transfer BPP bytes without filtering. This mimics the effect of bytes left to the
   //scanline being zero.
   //move(Raw^,TargetRun^,BPP);

   //Now do rest of the line
   decoded:=TargetRun;
   inc(Raw,BPP);
   inc(TargetRun,BPP);
   dec(BytesPerRow,BPP);
   while BytesPerRow>0 do begin
    TargetRun^:=Byte(Raw^+decoded^);
    inc(Raw);inc(decoded);inc(TargetRun);dec(BytesPerRow);
   end;
  end;
  2:begin //Up filter
   Raw:=Line;
   Prior:=PrevLine;
   TargetRun:=Target;
   while BytesPerRow>0 do begin
    TargetRun^:=Byte(Raw^+Prior^);
    inc(Raw);
    inc(Prior);
    inc(TargetRun);
    dec(BytesPerRow);
   end;
  end;
  3:begin //average filter
   //first handle BPP virtual pixels to the left
   Raw:=Line;
   decoded:=Line;
   Prior:=PrevLine;
   TargetRun:=Target;
   for i:=0 to BPP-1 do begin
    TargetRun^:=Byte(Raw^+Floor(Prior^/2));
    inc(Raw);inc(Prior);inc(TargetRun);
   end;
   dec(BytesPerRow,BPP);

   //now do rest of line
   while BytesPerRow>0 do begin
    TargetRun^:=Byte(Raw^+Floor((decoded^+Prior^)/2));
    inc(Raw);inc(decoded);inc(Prior);inc(TargetRun);dec(BytesPerRow);
   end;
  end;
  4:begin //paeth prediction
   //again, start with first BPP pixel which would refer to non-existing pixels to the left
   Raw:=Line;
   decoded:=Target;
   Prior:=PrevLine;
   Priordecoded:=PrevLine;
   TargetRun:=Target;
   for i:=0 to BPP-1 do begin
    TargetRun^:=Byte(Raw^+PaethPredictor(0,Prior^,0));
    inc(Raw);inc(Prior);inc(TargetRun);
   end;
   dec(BytesPerRow,BPP);

   //finally do rest of line
   while BytesPerRow>0 do begin
    TargetRun^:=Byte(Raw^+PaethPredictor(decoded^,Prior^,Priordecoded^));
    inc(Raw);inc(decoded);inc(Prior);inc(Priordecoded);inc(TargetRun);dec(BytesPerRow);
   end;
  end;
 end;
end;
//############################################################################//
//############################################################################//
//############################################################################//  
function ispng(fn:string):boolean;
var f:vfile;
pngh:pnghdr;
i:integer;
begin
 result:=true;  
 vfopen(f,fn,1);
             
 if vffilesize(f)<=8 then begin vfclose(f); result:=false; exit; end;
 vfread(f,@pngh,8); 
 for i:=0 to 7 do if pngh[i]<>pngid[i] then result:=false;     
 vfclose(f);
end;
//############################################################################//  
function ispngbuf(buf:pointer;bs:integer):boolean;
var i:integer;
begin
 result:=false;
 if buf=nil then exit;
 if bs<=8 then exit;
 for i:=0 to 7 do if ppnghdr(buf)[i]<>pngid[i] then exit;
 result:=true;   
end;
//############################################################################//
//############################################################################//
function ispng8(fn:string):boolean;
var f:vfile;
pngh:pnghdr;
i:integer;
        
chh:pngchkhdr;
lng:integer;
 
begin
 result:=false;  
           
 if not vfopen(f,fn,1) then exit;
 if vffilesize(f)<=8 then begin vfclose(f);exit; end;

 //Header
 vfread(f,@pngh,8);  
 for i:=0 to 7 do if pngh[i]<>pngid[i] then begin vfclose(f);exit;end;  
 
 //Sections
 repeat 
  vfread(f,@chh,8);
  lng:=dwle2be(chh.lng);
  if lng=0 then begin vfclose(f);exit;end;
  if chh.tp='IHDR' then begin  
   vfseek(f,dword(vffilepos(f))+dword(lng+4));
  end else if chh.tp='IDAT' then begin  
   vfseek(f,dword(vffilepos(f))+dword(lng+4));
  end else if chh.tp='PLTE' then begin   
   result:=true; 
   vfclose(f);  
   exit;
   vfseek(f,dword(vffilepos(f))+dword(lng+4));
  end else begin
   vfseek(f,dword(vffilepos(f))+dword(lng+4));
  end;
 until vfeof(f); 
 
 vfclose(f);  
end;
//############################################################################//
//############################################################################//   
function ldpngbuf(buf:pointer;bs:integer;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;  
var pngh:pnghdr;
chh:pngchkhdr;
chs:array of pngchklf;
i,c,n,t:integer;

w,h,x,y:integer;
bc,ct,cp,fl,il:byte;
fi:byte;
ci:pcrgb;
co,ci4:pcrgba;
cb:byte;
idps,idls:array of integer;
cds,uds,pds,bpr,bpp:integer;
cmpdat:pointer;
grdat:pointer;
st:tzstate;
pal,cpal:pngpaltyp;

bp:dword;

procedure bufread(p:pointer;l:dword);
begin
 move(pbytea(buf)[bp],p^,l);
 bp:=bp+l;
end;

procedure freeall;
var i:integer;
begin
 for i:=0 to length(chs)-1 do if chs[i].dat<>nil then freemem(chs[i].dat);
 freemem(grdat);
 freemem(cmpdat);  
 setlength(pal,0);
 setlength(cpal,0);
 setlength(chs,0);
 setlength(idps,0);
 setlength(idls,0);
end;

begin   
 {$ifdef pngdbg}writeln('PNGBEGIN - ');{$endif}     
 wa:=not wa;
 bx:=0;by:=0;p:=nil;result:=nil;grdat:=nil;cmpdat:=nil;
 bc:=0;ct:=0;w:=-1;h:=-1;bp:=0;   
  
 //Header       
 bufread(@pngh,8);
 {$ifdef pngdbg}
 c:=0;
 for i:=0 to 7 do if pngh[i]<>pngid[i] then c:=-1;
 if c=0 then writeln('HDR OK') else writeln('HDR ERR');
 {$endif}

 //Sections
 repeat 
  c:=length(chs);setlength(chs,c+1);chs[c].dat:=nil;
  
  bufread(@chh,8);
  chs[c].lng:=dwle2be(chh.lng);
  chs[c].tp:=chh.tp;
  chs[c].aux:=(byte(chh.tp[0])and 32<>0);
  chs[c].pri:=(byte(chh.tp[1])and 32<>0);
  chs[c].res:=(byte(chh.tp[2])and 32<>0);
  chs[c].stc:=(byte(chh.tp[3])and 32<>0);

  {$ifdef pngdbg}
  write('"',chs[c].tp,'":L=',chs[c].lng);
  if chs[c].aux then write(':AUX') else write(':CRI');
  if chs[c].pri then write(':PRI') else write(':PUB');
  if chs[c].res then write(':RES') else write(':NRE');
  if chs[c].stc then write(':STC') else write(':USC');
  {$endif}
  
  if chs[c].tp='IHDR' then begin  
   {$ifdef pngdbg}writeln;if w<>-1 then writeln('Duplicate IHDR, using last.');{$endif}
   getmem(chs[c].dat,chs[c].lng);
  
   bufread(chs[c].dat,chs[c].lng);
   
   w:=dwle2be(ppngihdr(chs[c].dat).wid);
   h:=dwle2be(ppngihdr(chs[c].dat).hei);
   bc:=ppngihdr(chs[c].dat).bit;
   ct:=ppngihdr(chs[c].dat).cltyp;
   
   {$ifdef pngdbg}
   writeln('width =',w);
   writeln('height=',h);  
   cp:=ppngihdr(chs[c].dat).comp;  
   fl:=ppngihdr(chs[c].dat).filt;  
   il:=ppngihdr(chs[c].dat).intl;
   writeln('bit=',bc,':cltyp=',ct,':comp=',cp,':filt=',fl,':intl=',il);
   {$endif}
   bufread(@chs[c].crc,4); 
   {$ifdef pngdbg}writeln('CRC=',chs[c].crc);{$endif}
  end else if chs[c].tp='IDAT' then begin  
   n:=length(idps);
   setlength(idps,c+1);
   setlength(idls,c+1);
   idls[c]:=chs[c].lng;
   idps[c]:=bp;

   bp:=bp+chs[c].lng;

   bufread(@chs[c].crc,4); 
   {$ifdef pngdbg}writeln(':CRC=',chs[c].crc);{$endif}
  end else if chs[c].tp='PLTE' then begin    
   {$ifdef pngdbg}if chs[c].lng mod 3<>0 then writeln('Palette length wrong.');{$endif}
   setlength(pal,chs[c].lng div 3);
   setlength(cpal,chs[c].lng div 3);
       
   bufread(@cpal[0],chs[c].lng);  
   for i:=0 to chs[c].lng div 3-1 do begin
   {$ifdef BGR}   
    pal[i][0]:=cpal[i][2];
    pal[i][1]:=cpal[i][1];
    pal[i][2]:=cpal[i][0];
   {$else}
    pal[i][0]:=cpal[i][0];
    pal[i][1]:=cpal[i][1];
    pal[i][2]:=cpal[i][2];
   {$endif}  
   end;
   setlength(cpal,0);
   
   bufread(@chs[c].crc,4); 
   {$ifdef pngdbg}writeln(':CRC=',chs[c].crc);{$endif}
  end else begin
   bp:=bp+chs[c].lng;
   bufread(@chs[c].crc,4); 
   {$ifdef pngdbg}writeln(':CRC=',chs[c].crc);{$endif}
  end;
 until bp>=dword(bs-4); 

 //Verify
 if w=-1 then begin
  {$ifdef pngdbg}writeln('No IHDR found, unloadable.');{$endif} 
  freeall;
  exit;
 end;
       
 //Doload and process
 cds:=0;for i:=0 to length(idls)-1 do cds:=cds+idls[i];   
 {$ifdef pngdbg}writeln('Comp data length: ',cds);{$endif}
 getmem(cmpdat,cds);
 c:=0;
 for i:=0 to length(idls)-1 do begin 
  bp:=idps[i];
  bufread(@pbytea(cmpdat)[c],idls[i]); 
  c:=c+idls[i];
 end; 
 
 //Decode            
          if(ct=2)and(bc=8)then begin
  uds:=(w*h*3+h);    pds:=w*h*4;bpr:=3*w;                    bpp:=3;t:=28;
 end else if(ct=6)and(bc=8)then begin
  uds:=(w*h*4+h);    pds:=w*h*4;bpr:=4*w;                    bpp:=4;t:=68;
 end else if(ct=3)and(bc=8)then begin
  uds:=(w*h+h);      pds:=w*h*4;bpr:=w;                      bpp:=1;t:=38;
 end else if(ct=3)and(bc=4)then begin
  uds:=(w*h div 2+h);pds:=w*h*4;bpr:=w div 2+ord(w mod 2<>0);bpp:=1;t:=34;
 end else if(ct=3)and(bc=2)then begin
  uds:=(w*h div 4+h);pds:=w*h*4;bpr:=w div 4+ord(w mod 4<>0);bpp:=1;t:=32;
 end else if(ct=3)and(bc=1)then begin
  uds:=(w*h div 8+h);pds:=w*h*4;bpr:=w div 8+ord(w mod 8<>0);bpp:=1;t:=31;
 end else if(ct=0)and(bc=8)then begin
  uds:=(w*h+h);      pds:=w*h*4;bpr:=w;                      bpp:=1;t:=08;
 end else if(ct=0)and(bc=4)then begin
  uds:=(w*h div 2+h);pds:=w*h*4;bpr:=w div 2+ord(w mod 2<>0);bpp:=1;t:=04;
 end else if(ct=0)and(bc=2)then begin
  uds:=(w*h div 4+h);pds:=w*h*4;bpr:=w div 4+ord(w mod 4<>0);bpp:=1;t:=02;
 end else if(ct=0)and(bc=1)then begin
  uds:=(w*h div 8+h);pds:=w*h*4;bpr:=w div 8+ord(w mod 8<>0);bpp:=1;t:=01;
 end else begin{$ifdef pngdbg}writeln('Unsupported image mode: ct=',ct,' bc=',bc);{$endif}freeall;exit;end;
         
 //Decompress                 
 getmem(grdat,uds);
 fillchar(st,SizeOf(st),0);
 InflateInit(st);
                   
 st.NextInput:=cmpdat;
 st.AvailableInput:=cds;
 c:=InflateReset(st);
 if c=Z_OK then begin
  st.NextOutput:=grdat;
  st.AvailableOutput:=uds;
  //c:=
  Inflate(st,Z_PARTIAL_FLUSH);
  //if c<>1 then begin{$ifdef pngdbg}writeln('Zlib error: ',c);{$endif}freeall;exit;end;
 end else begin{$ifdef pngdbg}writeln('Zlib error: ',c);{$endif}Inflateend(st);freeall;exit;end;
 freemem(cmpdat);cmpdat:=nil;
 Inflateend(st);
            
 //Process            
 getmem(p,pds); 
 case t of
  28:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*w*3+y))^;
   pngApplyFilter(fi,@pbytea(grdat)[y*w*3+y+1],@pbytea(grdat)[(y-1)*w*3+y-1+1],@pbytea(grdat)[y*w*3+y+1],bpp,bpr);
   for x:=0 to w-1 do begin
    ci:=@pbytea(grdat)[1+x*3+y*w*3+y];
    co:=@pbytea(p)[(x+y*w)*4];   
    
    {$ifdef BGR}   
    co[0]:=ci[2];co[1]:=ci[1];co[2]:=ci[0]; 
    {$else}    
    co[2]:=ci[2];co[1]:=ci[1];co[0]:=ci[0]; 
    {$endif} 
    co[3]:=ord(not wa)*$FF;
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end;
  68:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*w*4+y))^;    
   pngApplyFilter(fi,@pbytea(grdat)[y*w*4+y+1],@pbytea(grdat)[(y-1)*w*4+y-1+1],@pbytea(grdat)[y*w*4+y+1],bpp,bpr);
   for x:=0 to w-1 do begin        
    ci4:=@pbytea(grdat)[1+x*4+y*w*4+y];
    co:=@pbytea(p)[(x+y*w)*4];   
             
    {$ifdef BGR}   
    co[2]:=ci4[0];co[1]:=ci4[1];co[0]:=ci4[2]; 
    {$else}    
    co[2]:=ci4[2];co[1]:=ci4[1];co[0]:=ci4[0];
    {$endif} 
    //co[3]:=ord(not wa)*$FF;
    //if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
    //if wtx then co[3]:=ci4[3];
    co[3]:=ci4[3];
   end;
  end;
  38:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*w+y))^;
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*w+y+1)),pbyte(intptr(grdat)+intptr((y-1)*w+y-1+1)),pbyte(intptr(grdat)+intptr(y*w+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin 
    cb:=pbytea(grdat)[1+x+y*w+y];
    co:=@pbytea(p)[(x+y*w)*4];    
    
    {$ifdef BGR}   
    co[2]:=pal[cb][2];co[1]:=pal[cb][1];co[0]:=pal[cb][0];
    {$else}    
    co[0]:=pal[cb][2];co[1]:=pal[cb][1];co[2]:=pal[cb][0];
    {$endif} 
    co[3]:=ord(not wa)*$FF; 
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end;
  34:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin
    cb:=pbytea(grdat)[1+x div 2+y*bpr+y];
    if x mod 2=1 then cb:=cb and $0F else cb:=cb shr 4;
    co:=@pbytea(p)[(x+y*w)*4];    
    
    co[2]:=pal[cb][2];co[1]:=pal[cb][1];co[0]:=pal[cb][0];  
    co[3]:=ord(not wa)*$FF;
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end;
  32:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin           
    cb:=pbytea(grdat)[1+x div 4+y*bpr+y];
    cb:=(cb shr (2*(3-(x mod 4))))and $03;   
    co:=@pbytea(p)[(x+y*w)*4];  
    
    co[2]:=pal[cb][2];co[1]:=pal[cb][1];co[0]:=pal[cb][0];  
    co[3]:=ord(not wa)*$FF;
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end;
  31:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin       
    cb:=pbytea(grdat)[1+x div 8+y*bpr+y];
    cb:=(cb shr (7-(x mod 8)))and $01;  
    co:=@pbytea(p)[(x+y*w)*4];  
    
    co[2]:=pal[cb][2];co[1]:=pal[cb][1];co[0]:=pal[cb][0];  
    co[3]:=ord(not wa)*$FF;
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end; 
  08:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*w+y))^;
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*w+y+1)),pbyte(intptr(grdat)+intptr((y-1)*w+y-1+1)),pbyte(intptr(grdat)+intptr(y*w+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin          
    cb:=pbytea(grdat)[1+x+y*w+y];
    co:=@pbytea(p)[(x+y*w)*4];
    
    co[2]:=cb;co[1]:=co[2];co[0]:=co[2];  
    co[3]:=ord(not wa)*$FF;
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end;
  04:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin         
    cb:=pbytea(grdat)[1+x div 4+y*bpr+y];
    if x mod 2=1 then cb:=cb and $0F else cb:=cb shr 4;
    co:=@pbytea(p)[(x+y*w)*4];
    
    co[2]:=16*cb;co[1]:=co[2];co[0]:=co[2];  
    co[3]:=ord(not wa)*$FF;
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end; 
  02:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin         
    cb:=pbytea(grdat)[1+x div 4+y*bpr+y];
    cb:=(cb shr (2*(3-(x mod 4))))and $03;
    co:=@pbytea(p)[(x+y*w)*4];
    
    co[2]:=64*cb;co[1]:=co[2];co[0]:=co[2];
    co[3]:=ord(not wa)*$FF;
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end;
  01:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin     
    cb:=pbytea(grdat)[1+x div 8+y*bpr+y];
    cb:=(cb shr (7-(x mod 8)))and $01;
    co:=@pbytea(p)[(x+y*w)*4]; 
    
    co[2]:=255*cb;co[1]:=co[2];co[0]:=co[2];  
    co[3]:=ord(not wa)*$FF;
    if wtx then if (trc[0]=co[0])and(trc[1]=co[1])and(trc[2]=co[2]) then co[3]:=$00;
   end;
  end;
 end;   
        
 //Fin. 
 bx:=w;by:=h;result:=p;
 freeall;            
end;    
//############################################################################//
//############################################################################//     
function ldpng(fn:string;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;  
var bs:integer;
fif:vfile;
buf:pointer;
begin   
 vfopen(fif,fn,1);
 bs:=vffilesize(fif);
 getmem(buf,bs+4);
 vfread(fif,buf,bs);
 vfclose(fif);
 result:=ldpngbuf(buf,bs,wtx,wa,trc,bx,by,p); 
 freemem(buf);
end;                                                                            
//############################################################################//
//############################################################################//
//############################################################################//  
function ldpng8(fn:string;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer;var cpal:pallette):pointer;  
var fif:vfile;
pngh:pnghdr;
chh:pngchkhdr;
chs:array of pngchklf;
i,c,n,t:integer;

w,h,x,y,yw:integer;
bc,ct,cp,fl,il:byte;
fi:byte;
ci:pbyte;
co:pbyte;
cb:byte;
idps,idls:array of integer;
cds,uds,pds,bpr,bpp:integer;
cmpdat:pointer;
grdat:pointer;
st:tzstate;
pal:pngpaltyp;

buf:pointer;
bp,bs:dword;

procedure bufread(p:pointer;l:dword);
begin
 move(pointer(dword(buf)+bp)^,p^,l);
 bp:=bp+l;
end;

procedure freeall;
var i:integer;
begin
 for i:=0 to length(chs)-1 do if chs[i].dat<>nil then freemem(chs[i].dat);
 freemem(grdat);
 freemem(cmpdat);
end;

begin    
 {$ifdef pngdbg}writeln('PNGBEGIN - ',fn);{$endif}     
 //wa:=not wa;
 bx:=0;by:=0;p:=nil;result:=nil;grdat:=nil;cmpdat:=nil;
 bc:=0;ct:=0;w:=-1;h:=-1;  
 
 if not vfopen(fif,fn,1) then exit;
 bs:=vffilesize(fif);
 getmem(buf,bs+4);
 vfread(fif,buf,bs);
 vfclose(fif);
 bp:=0;  

 //Header
 bufread(@pngh,8);
 {$ifdef pngdbg}
 c:=0;
 for i:=0 to 7 do if pngh[i]<>pngid[i] then c:=-1;
 if c=0 then writeln('HDR OK') else writeln('HDR ERR');{$endif}

 //Sections
 repeat 
  c:=length(chs);setlength(chs,c+1);chs[c].dat:=nil;
  
  bufread(@chh,8);
  chs[c].lng:=dwle2be(chh.lng);
  chs[c].tp:=chh.tp;
  chs[c].aux:=(byte(chh.tp[0])and 32<>0);
  chs[c].pri:=(byte(chh.tp[1])and 32<>0);
  chs[c].res:=(byte(chh.tp[2])and 32<>0);
  chs[c].stc:=(byte(chh.tp[3])and 32<>0);

  {$ifdef pngdbg}
  write('"',chs[c].tp,'":L=',chs[c].lng);
  if chs[c].aux then write(':AUX') else write(':CRI');
  if chs[c].pri then write(':PRI') else write(':PUB');
  if chs[c].res then write(':RES') else write(':NRE');
  if chs[c].stc then write(':STC') else write(':USC');
  {$endif}
  
  if chs[c].tp='IHDR' then begin  
   {$ifdef pngdbg}writeln;if w<>-1 then writeln('Duplicate IHDR, using last.');{$endif}
   getmem(chs[c].dat,chs[c].lng);
  
   bufread(chs[c].dat,chs[c].lng);
   
   w:=dwle2be(ppngihdr(chs[c].dat).wid);
   h:=dwle2be(ppngihdr(chs[c].dat).hei);
   bc:=ppngihdr(chs[c].dat).bit;
   ct:=ppngihdr(chs[c].dat).cltyp;
   {$ifdef pngdbg}
   cp:=ppngihdr(chs[c].dat).comp;
   fl:=ppngihdr(chs[c].dat).filt;
   il:=ppngihdr(chs[c].dat).intl;   
   {$endif}
   
   {$ifdef pngdbg}
   writeln('width =',w);
   writeln('height=',h);
   writeln('bit=',bc,':cltyp=',ct,':comp=',cp,':filt=',fl,':intl=',il);
   {$endif}
   bufread(@chs[c].crc,4); 
   {$ifdef pngdbg}writeln('CRC=',chs[c].crc);{$endif}
  end else if chs[c].tp='IDAT' then begin  
   //n:=length(idps);
   setlength(idps,c+1);
   setlength(idls,c+1);
   idls[c]:=chs[c].lng;
   idps[c]:=bp;

   bp:=bp+chs[c].lng;

   bufread(@chs[c].crc,4); 
   {$ifdef pngdbg}writeln(':CRC=',chs[c].crc);{$endif}
  end else if chs[c].tp='PLTE' then begin    
   {$ifdef pngdbg}if chs[c].lng mod 3<>0 then writeln('Palette length wrong.');{$endif}
   setlength(pal,chs[c].lng div 3);
       
   bufread(@pal[0],chs[c].lng); 
   for i:=0 to chs[c].lng div 3-1 do begin
    {$ifdef BGR}
    cpal[i][0]:=pal[i][2];
    cpal[i][1]:=pal[i][1];
    cpal[i][2]:=pal[i][0];
    {$else}
    cpal[i][0]:=pal[i][0];
    cpal[i][1]:=pal[i][1];
    cpal[i][2]:=pal[i][2];
    {$endif}
   end;
   
   

   bufread(@chs[c].crc,4); 
   {$ifdef pngdbg}writeln(':CRC=',chs[c].crc);{$endif}
  end else begin
   bp:=bp+chs[c].lng;
   bufread(@chs[c].crc,4); 
   {$ifdef pngdbg}writeln(':CRC=',chs[c].crc);{$endif}
  end;
 until bp>=bs-4;  

 //Verify
 if w=-1 then begin
  {$ifdef pngdbg}writeln('No IHDR found, unloadable.');{$endif} 
  freeall;
  exit;
 end;
       
 //Doload and process
 cds:=0;for i:=0 to length(idls)-1 do cds:=cds+idls[i];   
 {$ifdef pngdbg}writeln('Comp data length: ',cds);{$endif}
 getmem(cmpdat,cds);
 c:=0;
 for i:=0 to length(idls)-1 do begin 
  bp:=idps[i];
  bufread(@pbytea(cmpdat)[c],idls[i]); 
  c:=c+idls[i];
 end;   
 
 //Decode            
          if(ct=2)and(bc=8)then begin
  uds:=(w*h*3+h);    pds:=w*h*4;bpr:=3*w;                    bpp:=3;t:=28;
 end else if(ct=3)and(bc=8)then begin
  uds:=(w*h+h);      pds:=w*h*4;bpr:=w;                      bpp:=1;t:=38;
 end else if(ct=3)and(bc=4)then begin
  uds:=(w*h div 2+h);pds:=w*h*4;bpr:=w div 2+ord(w mod 2<>0);bpp:=1;t:=34;
 end else if(ct=3)and(bc=2)then begin
  uds:=(w*h div 4+h);pds:=w*h*4;bpr:=w div 4+ord(w mod 4<>0);bpp:=1;t:=32;
 end else if(ct=3)and(bc=1)then begin
  uds:=(w*h div 8+h);pds:=w*h*4;bpr:=w div 8+ord(w mod 8<>0);bpp:=1;t:=31;
 end else if(ct=0)and(bc=8)then begin
  uds:=(w*h+h);      pds:=w*h*4;bpr:=w;                      bpp:=1;t:=08;
 end else if(ct=0)and(bc=4)then begin
  uds:=(w*h div 2+h);pds:=w*h*4;bpr:=w div 2+ord(w mod 2<>0);bpp:=1;t:=04;
 end else if(ct=0)and(bc=2)then begin
  uds:=(w*h div 4+h);pds:=w*h*4;bpr:=w div 4+ord(w mod 4<>0);bpp:=1;t:=02;
 end else if(ct=0)and(bc=1)then begin
  uds:=(w*h div 8+h);pds:=w*h*4;bpr:=w div 8+ord(w mod 8<>0);bpp:=1;t:=01;
 end else begin{$ifdef pngdbg}writeln('Unsupported image mode: ct=',ct,' bc=',bc);{$endif}freeall;exit;end;
       
 //Decompress                 
 getmem(grdat,uds);
 fillchar(st,SizeOf(st),0);
 InflateInit(st);  

 st.NextInput:=cmpdat;
 st.AvailableInput:=cds;
 c:=InflateReset(st);
 if c=Z_OK then begin
  st.NextOutput:=grdat;
  st.AvailableOutput:=uds;
  Inflate(st,Z_PARTIAL_FLUSH);
 end else begin{$ifdef pngdbg}writeln('Zlib error: ',c);{$endif}freeall;exit;end;
 freemem(cmpdat);cmpdat:=nil;
          
 //Process            
 getmem(p,pds); 
 case t of
  28:for y:=0 to h-1 do begin  
   yw:=y*w;
   fi:=pbyte(intptr(grdat)+intptr(yw*3+y))^;
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*w*3+y+1)),pbyte(intptr(grdat)+intptr((y-1)*w*3+y-1+1)),pbyte(intptr(grdat)+intptr(y*w*3+y+1)),bpp,bpr);
   for x:=0 to w-1 do pbyte(intptr(p)+intptr((x+yw)))^:=pbyte(intptr(grdat)+intptr(1+x*3+yw*3+y))^;
  end;
  38:for y:=0 to h-1 do begin
   yw:=y*w;
   fi:=pbyte(intptr(grdat)+intptr(yw+y))^;
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*w+y+1)),pbyte(intptr(grdat)+intptr((y-1)*w+y-1+1)),pbyte(intptr(grdat)+intptr(y*w+y+1)),bpp,bpr);
   for x:=0 to w-1 do pbyte(intptr(p)+intptr((x+yw)))^:=pbyte(intptr(grdat)+intptr(1+x+yw+y))^; 
  end;
  34:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin
    cb:=pbyte(intptr(grdat)+intptr(1+x div 2+y*bpr+y))^;
    if x mod 2=1 then cb:=cb and $0F else cb:=cb shr 4;
    co:=pointer(intptr(p)+intptr((x+y*w)));   
    co^:=cb;
   end;
  end;
  32:for y:=0 to h-1 do begin
   freeall;
   p:=nil;result:=nil;
   exit;
   {
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin
    cb:=pbyte(intptr(grdat)+intptr(1+x div 4+y*bpr+y))^;
    cb:=(cb shr (2*(3-(x mod 4))))and $03;
    co:=pointer(intptr(p)+intptr((x+y*w)));   
    co^:=cb;
   end;
   }
  end;
  31:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin
    cb:=pbyte(intptr(grdat)+intptr(1+x div 8+y*bpr+y))^;
    cb:=(cb shr (7-(x mod 8)))and $01;
    co:=pointer(intptr(p)+intptr((x+y*w)));
    co^:=cb;
   end;
  end; 
  08:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*w+y))^;
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*w+y+1)),pbyte(intptr(grdat)+intptr((y-1)*w+y-1+1)),pbyte(intptr(grdat)+intptr(y*w+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin
    cb:=pbyte(intptr(grdat)+intptr(1+x+y*w+y))^;
    co:=pointer(intptr(p)+intptr((x+y*w)));  
    co^:=cb;
   end;
  end;
  04:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin
    cb:=pbyte(intptr(grdat)+intptr(1+x div 2+y*bpr+y))^;
    if x mod 2=1 then cb:=cb and $0F else cb:=cb shr 4;
    co:=pointer(intptr(p)+intptr((x+y*w)));
    co^:=cb;
   end;
  end; 
  02:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin
    cb:=pbyte(intptr(grdat)+intptr(1+x div 4+y*bpr+y))^;
    cb:=(cb shr (2*(3-(x mod 4))))and $03;
    co:=pointer(intptr(p)+intptr((x+y*w)));   
    co^:=64*cb;
   end;
  end;
  01:for y:=0 to h-1 do begin
   fi:=pbyte(intptr(grdat)+intptr(y*bpr+y))^;  
   pngApplyFilter(fi,pbyte(intptr(grdat)+intptr(y*bpr+y+1)),pbyte(intptr(grdat)+intptr((y-1)*bpr+y-1+1)),pbyte(intptr(grdat)+intptr(y*bpr+y+1)),bpp,bpr);
   for x:=0 to w-1 do begin
    cb:=pbyte(intptr(grdat)+intptr(1+x div 8+y*bpr+y))^;
    cb:=(cb shr (7-(x mod 8)))and $01;
    co:=pointer(intptr(p)+intptr((x+y*w)));     
    co^:=255*cb;
   end;
  end;
 end;
 
 //Fin. 
 bx:=w;by:=h;result:=p;
 freeall;            
end;                                                                            
//############################################################################//
begin  
 register_grfmt(ispng8,ispng,ldpng8,ldpng,nil,ispngbuf,nil,ldpngbuf);  
end.
//############################################################################//
//############################################################################//
