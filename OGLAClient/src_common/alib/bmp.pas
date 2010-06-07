//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: BMP Loader
//############################################################################//
unit bmp;
{$ifdef FPC}{$MODE delphi}{$endif}
{$ifdef ape3}{$define bgr}{$endif}
interface
uses grph{$ifdef ape3},vfsint{$endif},grplib,asys{$ifdef VFS},vfs,vfsutils{$endif};      
//############################################################################//

type
BITMAPFILEHEADER=packed record
 bfType:Word;
 bfSize:DWORD;
 bfReserved1:Word;
 bfReserved2:Word;
 bfOffBits:DWORD;
end;
BITMAPINFOHEADER=packed record
 biSize:DWORD;
 biWidth:Longint;
 biHeight:Longint;
 biPlanes:Word;
 biBitCount:Word;
 biCompression:DWORD;
 biSizeImage:DWORD;
 biXPelsPerMeter:Longint;
 biYPelsPerMeter:Longint;
 biClrUsed:DWORD;
 biClrImportant:DWORD;
end; 
RGBQUAD=packed record
 rgbBlue:Byte;
 rgbGreen:Byte;
 rgbRed:Byte;
 rgbReserved:Byte;
end; 
//############################################################################//

function  IsBMP(Filename:string):boolean;     
function  IsBMP8(Filename:string):boolean; 
procedure LoadBMP32(Filename:string;wtx,wa:boolean;trc:crgb;var Width,Height,rWidth,rHeight:integer;var bd:integer;var pData:pointer); 
procedure LoadBMP8(Filename:string;wtx,wa:boolean;trc:crgb;var Width,Height:integer;var bd:integer;var pData:pointer;var cl:pallette); 
function  storeBMP32(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
function  storeBMP24(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
function  storeBMP8(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean;pal:pallette):boolean;
function  ldbmp32(filename:string;wtx,wa:boolean;trc:crgb;var width,height:integer;var pdata:pointer):pointer;  
//############################################################################//
implementation
//############################################################################//
const cpow:array[0..16]of cardinal=(1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536);  
//############################################################################//
function getcpow(a:cardinal):cardinal;
var i:integer;
begin
 result:=1;
 for i:=0 to 16-1 do if (a>cpow[i])and(a<=cpow[i+1]) then result:=cpow[i+1];
end;  
//############################################################################//  
procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: DWORD);
begin
 Move(Source^, Destination^, Length);
end; 
//############################################################################// 
function IsBMP(Filename:string):boolean; 
var
FileHeader:BITMAPFILEHEADER; 
InfoHeader:BITMAPINFOHEADER;  
BitmapFile:vfile;
begin  
 result:=false;  
 if not vfopen(BitmapFile,Filename,1) then exit;
 if vffilesize(bitmapfile)<SizeOf(FileHeader)+SizeOf(InfoHeader) then begin vfclose(bitmapfile);exit; end;
 // Get header information
 vfRead(BitmapFile,@FileHeader,SizeOf(FileHeader));  
 vfRead(BitmapFile,@InfoHeader,SizeOf(InfoHeader));

 result:=true;
 if(FileHeader.bftype<>$4D42)then result:=false;
 if(InfoHeader.biBitCount<>32)and(InfoHeader.biBitCount<>24)and(InfoHeader.biBitCount<>8)and(InfoHeader.biBitCount<>4)and(InfoHeader.biBitCount<>1) then result:=false;
 vfclose(bitmapfile);
end;
//############################################################################//
function IsBMP8(Filename:string):boolean; 
var
FileHeader:BITMAPFILEHEADER; 
InfoHeader:BITMAPINFOHEADER;  
BitmapFile:vfile;
begin  
 result:=false;  
 if not vfopen(BitmapFile,Filename,1) then exit;
 // Get header information
 vfRead(BitmapFile,@FileHeader,SizeOf(FileHeader));  
 vfRead(BitmapFile,@InfoHeader,SizeOf(InfoHeader));

 result:=true;
 if(FileHeader.bftype<>$4D42)then result:=false;
 if(InfoHeader.biBitCount<>8)and(InfoHeader.biBitCount<>4)and(InfoHeader.biBitCount<>1)then result:=false;
 vfclose(bitmapfile);
end;
//############################################################################//
//############################################################################//
procedure LoadBMP32(Filename:String;wtx,wa:boolean;trc:crgb;var Width,Height,rWidth,rHeight:integer;var bd:integer;var pData:pointer);
var
FileHeader:BITMAPFILEHEADER;
InfoHeader:BITMAPINFOHEADER;
Palette:array of RGBQUAD;
  
BitmapLength,rblen,rwid,rhei:integer;
PaletteLength:cardinal;

//ReadBytes:cardinal;
//Front:pbyte;
//Back:pbyte;
//Temp:byte;
i,j:integer;
rdat:pointer;

//dww,
dhh:integer;

//var
fct:crgb;
//fc:crgba;
c1:pcrgba;
c11:pcrgba;
c2:pcrgb;
c3:pbyte;
c4:pdword;
c:byte;
BitmapFile:vfile;

begin
 wa:=not wa;
 if not vfopen(BitmapFile,Filename,1) then begin
  Width:=0;
  Height:=0;
  rWidth:=0;
  rHeight:=0;
  bd:=0;
  pData:=nil;
  exit;
 end;

 // Get header information
 vfRead(BitmapFile,@FileHeader,SizeOf(FileHeader));
 vfRead(BitmapFile,@InfoHeader,SizeOf(InfoHeader));

 if (InfoHeader.biBitCount<>32)and(InfoHeader.biBitCount<>24)and(InfoHeader.biBitCount<>8)and(InfoHeader.biBitCount<>4)and(InfoHeader.biBitCount<>1) then begin
  pdata:=nil;
  exit;
 end;

 // Get palette
 PaletteLength:=InfoHeader.biClrUsed*4;
 if InfoHeader.biBitCount=8 then if PaletteLength=0 then PaletteLength:=256*4;
 if InfoHeader.biBitCount=4 then if PaletteLength=0 then PaletteLength:=16*4;
 if InfoHeader.biBitCount=1 then if PaletteLength=0 then PaletteLength:=2*4;
 SetLength(Palette,PaletteLength div 4);
 if PaletteLength<>0 then vfRead(BitmapFile,@Palette[0],PaletteLength);

 Width:=InfoHeader.biWidth;
 Height:=InfoHeader.biHeight;
 BitmapLength:=InfoHeader.biSizeImage;
 //if BitmapLength=0 then BitmapLength:=Width*height*InfoHeader.biBitCount Div 8;
 if BitmapLength=0 then BitmapLength:=Fileheader.bfsize-Fileheader.bfoffbits;

 // Get the actual pixel data
 GetMem(pData,BitmapLength);
 vfRead(BitmapFile,pData,BitmapLength);

 vfClose(BitmapFile);
 bd:=InfoHeader.biBitCount;

 rwidth:=width;
 rheight:=height;
 rhei:=height;
 rwid:=width;

// fc[0]:=trc[0];
// fc[1]:=trc[1];
// fc[2]:=trc[2];
// fc[3]:=ord(not wtx)*$FF;
 fct[0]:=trc[0];
 fct[1]:=trc[1];
 fct[2]:=trc[2];


 if bd=1 then begin
  rblen:=rwid*rhei*4;
  GetMem(rdat,rblen);
  dhh:=(rhei-height)*4*rwid;

  for i:=0 to height-1 do begin
   for j:=0 to width-1 do begin
    c1:=Pointer(intptr(rdat)+intptr((height-i-1)*rwid*4+dhh+j*4));
    c4:=Pointer(intptr(pdata)+intptr(i*((width div 32)*4+4*ord(width mod 32 <>0))+(j div 32)*4));
    c3:=Pointer(intptr(c4)+intptr((j div 8)mod 4));
    if c3^ and ($80 shr (j mod 8))=0 then begin;
     c1[0]:=$00;
     c1[1]:=$00;
     c1[2]:=$00;
    end else begin
     c1[0]:=$FF;
     c1[1]:=$FF;
     c1[2]:=$FF;
    end;
    c1[3]:=ord(not wa)*$FF;
    if wtx then if (fct[0]=c1[0])and(fct[1]=c1[1])and(fct[2]=c1[2]) then c1[3]:=$00;
   end;
  end;



  freemem(pdata);
  getmem(pData,rblen);
  CopyMemory(pdata,rdat,rblen);
  freemem(rdat);
  height:=rhei;
  width:=rwid;
 end;

 if bd=4 then begin
  rblen:=rwid*rhei*4;
  GetMem(rdat,rblen);
  dhh:=(rhei-height)*4*rwid;

  for i:=0 to height-1 do begin
   for j:=0 to width-1 do begin
    c1:=Pointer(intptr(rdat)+intptr((height-i-1)*rwid*4+dhh+j*4));
    c4:=Pointer(intptr(pdata)+intptr(i*((width div 8)*4+4*ord(width mod 8 <>0))+(j div 8)*4));
    c3:=Pointer(intptr(c4)+intptr((j div 2)mod 4));
    c:=0;
    if j mod 2=0 then c:=c3^ shr 4;
    if j mod 2=1 then c:=c3^and $0F;

    {$ifndef BGR}
    c1[0]:=palette[c].rgbRed;
    c1[1]:=palette[c].rgbGreen;
    c1[2]:=palette[c].rgbBlue;
    {$else}                   
    c1[2]:=palette[c].rgbRed;
    c1[1]:=palette[c].rgbGreen;
    c1[0]:=palette[c].rgbBlue;
    {$endif}
     
    c1[3]:=ord(not wa)*$FF;
    if wtx then if (fct[0]=c1[0])and(fct[1]=c1[1])and(fct[2]=c1[2]) then c1[3]:=$00;
   end;
  end;

  freemem(pdata);
  getmem(pData,rblen);
  CopyMemory(pdata,rdat,rblen);
  freemem(rdat);
  height:=rhei;
  width:=rwid;
 end;

 if bd=8 then begin
  rblen:=rwid*rhei*4;
  GetMem(rdat,rblen);
  dhh:=(rhei-height)*4*rwid;

  for i:=0 to height-1 do begin
   for j:=0 to width-1 do begin
    c1:=Pointer(intptr(rdat)+intptr((height-i-1)*rwid*4+dhh+j*4));
    c3:=Pointer(intptr(pdata)+intptr(i*width+j+(width mod 4)*i));   
    {$ifndef BGR}
    c1[0]:=palette[c3^].rgbRed;
    c1[1]:=palette[c3^].rgbGreen;
    c1[2]:=palette[c3^].rgbBlue;  
    {$else}                   
    c1[2]:=palette[c3^].rgbRed;
    c1[1]:=palette[c3^].rgbGreen;
    c1[0]:=palette[c3^].rgbBlue;  
    {$endif}
    c1[3]:=ord(not wa)*$FF;
    if wtx then if (fct[0]=c1[0])and(fct[1]=c1[1])and(fct[2]=c1[2]) then c1[3]:=$00;
   end;
  end;


  freemem(pdata);
  getmem(pData,rblen);
  CopyMemory(pdata,rdat,rblen);
  freemem(rdat);
  height:=rhei;
  width:=rwid;
 end;

 if bd=24 then begin        
  rblen:=rwid*rhei*4;
  GetMem(rdat,rblen);
  for i:=0 to height-1 do begin
   for j:=0 to width-1 do begin
    c1:=Pointer(intptr(rdat)+intptr((height-i-1)*rwid*4+j*4));
    c2:=Pointer(intptr(pdata)+intptr(i*width*3+j*3+(width mod 4)*i));
    {$ifndef BGR}
    c1[0]:=c2[2];
    c1[1]:=c2[1];
    c1[2]:=c2[0];      
    {$else}                   
    c1[0]:=c2[0];
    c1[1]:=c2[1];
    c1[2]:=c2[2];  
    {$endif}
    c1[3]:=ord(not wa)*$FF;
    if wtx then if (fct[0]=c2[0])and(fct[1]=c2[1])and(fct[2]=c2[2]) then c1[3]:=$00;
   end;
  end;
        
  freemem(pdata);
  getmem(pData,rblen);
  CopyMemory(pdata,rdat,rblen);
  freemem(rdat);
  height:=rhei;
  width:=rwid;
 end;
  
 if bd=32 then begin        
  rblen:=rwid*rhei*4;
  GetMem(rdat,rblen);
  for i:=0 to height-1 do begin
   for j:=0 to width-1 do begin
    c1:=Pointer(intptr(rdat)+intptr((height-i-1)*rwid*4+j*4));
    c11:=Pointer(intptr(pdata)+intptr(i*width*4+j*4+(width mod 4)*i));
    {$ifndef BGR}
    c1[0]:=c11[2];
    c1[1]:=c11[1];
    c1[2]:=c11[0];      
    {$else}        
    c1[0]:=c11[0];
    c1[1]:=c11[1];
    c1[2]:=c11[2]; 
    {$endif}
    c1[3]:=c11[3];
    //if wtx then if (fct[0]=c2[0])and(fct[1]=c2[1])and(fct[2]=c2[2]) then c1[3]:=$00;
   end;
  end;

  freemem(pdata);
  getmem(pData,rblen);
  CopyMemory(pdata,rdat,rblen);
  freemem(rdat);
  height:=rhei;
  width:=rwid;
 end;
end;
//############################################################################//
//############################################################################//
procedure LoadBMP8(Filename:string;wtx,wa:boolean;trc:crgb;var width,height:integer;var bd:integer;var pData:pointer;var cl:pallette); 
var fh:BITMAPFILEHEADER;
ih:BITMAPINFOHEADER;
pal:array of RGBQUAD;
  
bmplen,rblen,i,j:integer;
pallen:dword;

rdat:pointer;

//fct:crgb;
//fc:crgba;
c1:pbyte;
c3:pbyte;
c4:pdword;
f:vfile;

begin
 //wa:=not wa;
 if not vfopen(f,Filename,1) then begin
  Width:=0;
  Height:=0;
  bd:=0;
  pData:=nil;
  exit;
 end;

  // Get header information
  vfRead(f,@fh,sizeof(fh));
  vfRead(f,@ih,sizeof(ih));

  if(ih.biBitCount<>8)and(ih.biBitCount<>4)and(ih.biBitCount<>1) then begin
   pdata:=nil;
   exit;
  end;

  // Get palette
  pallen:=ih.biClrUsed*4;
  if ih.biBitCount=8 then if pallen=0 then pallen:=256*4;
  if ih.biBitCount=4 then if pallen=0 then pallen:=16*4;
  if ih.biBitCount=1 then if pallen=0 then pallen:=2*4;
  setlength(pal,pallen div 4);
  vfread(f,@cl[0],pallen);

  width:=ih.biwidth;
  height:=ih.biheight;
  bmplen:=ih.biSizeImage;
  //if bmplen=0 then bmplen:=Width*height*ih.biBitCount Div 8;
  if bmplen=0 then bmplen:=fh.bfsize-fh.bfoffbits;

  // Get the actual pixel data
  getmem(pdata,bmplen);
  vfread(f,pdata,bmplen);

  vfclose(f);
  bd:=ih.biBitCount;

//  fc[0] :=trc[0];fc[1] :=trc[1];fc[2] :=trc[2];fc[3]:=ord(not wtx)*$FF;
//  fct[0]:=trc[0];fct[1]:=trc[1];fct[2]:=trc[2];

          
  if bd=1 then begin   
   rblen:=width*height;
   GetMem(rdat,rblen);

   for i:=0 to height-1 do begin
    for j:=0 to width-1 do begin
     c1:=Pointer(intptr(rdat)+intptr((height-i-1)*width+j));
     c4:=Pointer(intptr(pdata)+intptr(i*((width div 32)*4+4*ord(width mod 32 <>0))+(j div 32)*4));
     c3:=Pointer(intptr(c4)+intptr((j div 8)mod 4));
     if c3^ and ($80 shr (j mod 8))=0 then begin;
      c1^:=0;
     end else begin
      c1^:=1;
     end;
    end;
   end;

   freemem(pdata);
   getmem(pData,rblen);
   CopyMemory(pdata,rdat,rblen);
   freemem(rdat);  
  end;

  if bd=4 then begin
   rblen:=width*height;
   GetMem(rdat,rblen);

   for i:=0 to height-1 do begin
    for j:=0 to width-1 do begin
     c1:=Pointer(intptr(rdat)+intptr((height-i-1)*width+j));
     c3:=Pointer(intptr(pdata)+intptr(i*((width div 8)*4+4*ord(width mod 8 <>0))+(j div 8)*4));
     c1^:=c3^;
    end;
   end;


   freemem(pdata);
   getmem(pData,rblen);
   CopyMemory(pdata,rdat,rblen);
   freemem(rdat);
  end;

  if bd=8 then begin  
   rblen:=width*height;
   getmem(rdat,rblen);
   for i:=0 to height-1 do begin     
    move(pointer(intptr(pdata)+intptr((height-i-1)*width))^,pointer(intptr(rdat) +intptr(i*width+(width mod 4)*i))^,width);
   end;

   freemem(pdata);
   pdata:=rdat;
   //rdat:=nil;  
  end; 
     
  {
  if bd=24 then begin        
   rblen:=rwid*rhei*4;
   GetMem(rdat,rblen);
   dhh:=0;
   dww:=width*4;
   for i:=0 to height-1 do begin
    for j:=0 to width-1 do begin
     c1:=Pointer(intptr(rdat)+(height-i-1)*rwid*4+j*4);
     c2:=Pointer(intptr(pdata)+i*width*3+j*3+(width mod 4)*i);
     c1[0]:=c2[2];
     c1[1]:=c2[1];
     c1[2]:=c2[0];
     c1[3]:=ord(not wa)*$FF;
     if wtx then if (fct[0]=c2[0])and(fct[1]=c2[1])and(fct[2]=c2[2]) then c1[3]:=$00;
    end;
   end;

   freemem(pdata);
   getmem(pData,rblen);
   CopyMemory(pdata,rdat,rblen);
   freemem(rdat);
   height:=rhei;
   width:=rwid;
  end;
  }
end;
//############################################################################//
//############################################################################//
function storeBMP32(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
var f:vfile;  
fh:BITMAPFILEHEADER;
ih:BITMAPINFOHEADER;
i,j:integer;
pp:pointer;
c1,c2:pcrgba;
begin  
 result:=false;
 if not vfopen(f,fn,2) then exit;

 fh.bftype:=19778;
 fh.bfsize:=xr*yr*4;
 fh.bfReserved1:=0;
 fh.bfReserved2:=0;
 fh.bfoffbits:=54;
   
 ih.biBitCount:=32;
 ih.biWidth:=xr;
 ih.biheight:=yr;
 ih.biSizeImage:=xr*yr*4;
 ih.biSize:=SizeOf(Ih); 
 ih.biPlanes:=1; 
 ih.biCompression:=0; 
 ih.biXPelsPerMeter:=1000; 
 ih.biYPelsPerMeter:=1000; 
 ih.biClrUsed:=0; 
 ih.biClrImportant:=0; 
   
 vfwrite(f,@fh,SizeOf(Fh));
 vfwrite(f,@ih,SizeOf(Ih));
 if bgr then begin
  getmem(pp,xr*4);
  for i:=yr-1 downto 0 do begin
   for j:=0 to xr-1 do begin
    c1:=Pointer(intptr(p)+intptr((j+i*xr)*4));
    c2:=Pointer(intptr(pp)+intptr(j*4));
    c2[0]:=c1[2];
    c2[1]:=c1[1];
    c2[2]:=c1[0];
    c2[3]:=c1[3];
    //if wtx then if (fct[0]=c2[0])and(fct[1]=c2[1])and(fct[2]=c2[2]) then c1[3]:=$00;
   end;
   vfwrite(f,pp,xr*4);
  end;
  freemem(pp);
 end else begin
  if not rev then vfwrite(f,p,xr*yr*4) else for i:=yr-1 downto 0 do vfwrite(f,pointer(intptr(p)+intptr(i*xr*4)),xr*4);
 end;
 vfclose(f);
 result:=true;
end;
//############################################################################//
//############################################################################//
function storeBMP24(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
var f:vfile;  
fh:BITMAPFILEHEADER;
ih:BITMAPINFOHEADER;
i,j:integer;
pp:pointer;
c1,c2:pcrgb;
begin  
 result:=false;
 if not vfopen(f,fn,2) then exit;

 fh.bftype:=19778;
 fh.bfsize:=xr*yr*3;
 fh.bfReserved1:=0;
 fh.bfReserved2:=0;
 fh.bfoffbits:=54;
   
 ih.biBitCount:=24;
 ih.biWidth:=xr;
 ih.biheight:=yr;
 ih.biSizeImage:=xr*yr*3;
 ih.biSize:=SizeOf(Ih); 
 ih.biPlanes:=1; 
 ih.biCompression:=0; 
 ih.biXPelsPerMeter:=1000; 
 ih.biYPelsPerMeter:=1000; 
 ih.biClrUsed:=0; 
 ih.biClrImportant:=0; 
   
 vfwrite(f,@fh,SizeOf(Fh));
 vfwrite(f,@ih,SizeOf(Ih));
 if bgr then begin
  getmem(pp,xr*3);
  for i:=yr-1 downto 0 do begin
   for j:=0 to xr-1 do begin
    c1:=Pointer(intptr(p)+intptr((j+i*xr)*3));
    c2:=Pointer(intptr(pp)+intptr(j*3));
    c2[0]:=c1[2];
    c2[1]:=c1[1];
    c2[2]:=c1[0];
   end;
   vfwrite(f,pp,xr*3);
  end;
  freemem(pp);
 end else begin
  if not rev then vfwrite(f,p,xr*yr*3) else for i:=yr-1 downto 0 do vfwrite(f,pointer(intptr(p)+intptr(i*xr*3)),xr*3);
 end;
 vfclose(f);
 result:=true;
end;
//############################################################################//
//############################################################################//
function storeBMP8(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean;pal:pallette):boolean;
var f:vfile;  
fh:BITMAPFILEHEADER;
ih:BITMAPINFOHEADER;
i:integer;
cl:byte;
begin  
 result:=false;
 if not vfopen(f,fn,2) then exit;

 fh.bftype:=19778;
 fh.bfsize:=xr*yr;
 fh.bfReserved1:=0;
 fh.bfReserved2:=0;
 fh.bfoffbits:=54+1024;
                       
 ih.biSize:=SizeOf(Ih); 
 ih.biWidth:=xr;
 ih.biheight:=yr;      
 ih.biPlanes:=1; 
 ih.biBitCount:=8;     
 ih.biCompression:=0; 
 ih.biSizeImage:=0;
 ih.biXPelsPerMeter:=0; 
 ih.biYPelsPerMeter:=0; 
 ih.biClrUsed:=0; 
 ih.biClrImportant:=0; 
   
 vfwrite(f,@fh,SizeOf(Fh));
 vfwrite(f,@ih,SizeOf(Ih));

 
 if bgr then for i:=0 to 255 do begin 
  cl:=pal[i][0];
  pal[i][0]:=pal[i][2];
  pal[i][2]:=cl;
 end;
 
 vfwrite(f,@pal,1024);
 if not rev then vfwrite(f,p,xr*yr) else for i:=yr-1 downto 0 do vfwrite(f,pointer(intptr(p)+intptr(i*xr)),xr);

 {
 if bgr then begin
  getmem(pp,xr*4);
  for i:=yr-1 downto 0 do begin
   for j:=0 to xr-1 do begin
    c1:=Pointer(intptr(p)+intptr((j+i*xr)*4));
    c2:=Pointer(intptr(pp)+intptr(j*4));
    c2[0]:=c1[2];
    c2[1]:=c1[1];
    c2[2]:=c1[0];
    c2[3]:=c1[3];
    //if wtx then if (fct[0]=c2[0])and(fct[1]=c2[1])and(fct[2]=c2[2]) then c1[3]:=$00;
   end;
   vfwrite(f,pp,xr*4);
  end;
  freemem(pp);
 end else begin
  if not rev then vfwrite(f,p,xr*yr*4) else for i:=yr-1 downto 0 do vfwrite(f,pointer(intptr(p)+intptr(i*xr*4)),xr*4);
 end;
 }         
 vfclose(f);
 result:=true;
end;
//############################################################################//  
//############################################################################//                               
function ldbmp8(filename:string;wtx,wa:boolean;trc:crgb;var width,height:integer;var pdata:pointer;var cl:pallette):pointer;  
var bd:integer;
begin
 Loadbmp8(filename,wtx,wa,trc,width,height,bd,pdata,cl);   
 result:=pdata;
end;
//############################################################################//                               
function ldbmp32(filename:string;wtx,wa:boolean;trc:crgb;var width,height:integer;var pdata:pointer):pointer;  
var bd,rwid,rhei:integer;
begin
 Loadbmp32(filename,wtx,wa,trc,width,height,rwid,rhei,bd,pdata);   
 result:=pdata;
end;
//############################################################################//
begin   
 register_grfmt(isbmp8,isbmp,ldbmp8,ldbmp32,nil,nil,nil,nil);
end.  
//############################################################################//
