//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: DDS Loader/Saver 
//############################################################################//
unit dds;
interface
uses asys,sysutils,grph,grplib,maths,dxtc{$ifdef VFS},vfs,vfsutils{$endif};
//############################################################################//
type
TILEFILESPEC=packed record
 sid,                          //index for surface texture (-1: not present)
 midx,                         //index for land-water mask texture (-1: not present)
 eidx:integer;                 //index for elevation data blocks (not used yet; always -1)
 flags:dword;                  //tile flags: bit 0: has diffuse component; bit 1: has specular component; bit 2: has city lights
 subidx:array[0..3]of integer; //subtile indices
end;
LMASKFILEHEADER=packed record // file header for contents file at level 1-8
	id:array[0..7]of char;          //    ID+version string
	hsize,         //    header size
	flag,          //    bitflag content information
	npatch:dword;        //    number of patches
	minres,         //    min. resolution level
	maxres:byte;         //    max. resolution level
end;
//############################################################################//
function loaddds(fn:string;var width,height:integer;var p:pointer;var ct,len:integer;comp:boolean):boolean;  
function loadtex(fn:string;var width,height:aointeger;var count:integer;var p:apointer;var ct,len:aointeger;comp:boolean):boolean;
function loadltexoff(fn:string;o:integer;var p:pointer;comp:boolean):boolean;
function loadltexn(fn:string;n:integer;var p:pointer;comp:boolean):boolean;
function isdds(fn:string):boolean;     
function isdds_comp(fn:string):boolean;
                                                     
function storememDDSt1f32(p:pointer;xr,yr:integer;rev,bgr:boolean;var buf:pointer;var bs:integer):boolean; 
function storememDDSt5f32(p:pointer;xr,yr:integer;rev,bgr:boolean;var buf:pointer;var bs:integer):boolean;   
function storeDDSt1f32(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
function storeDDSt3f32(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
function storeDDSt5f32(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;            
//############################################################################//
//############################################################################//
implementation    
//############################################################################//
const               
DDSD_CAPS       =$00000001;
DDSD_HEIGHT     =$00000002;
DDSD_WIDTH      =$00000004;
DDSD_PITCH      =$00000008;
DDSD_PIXELFORMAT=$00001000;
DDSD_MIPMAPCOUNT=$00020000;
DDSD_LINEARSIZE =$00080000;
DDSD_DEPTH      =$00800000;

DDPF_ALPHAPIXELS=$00000001;
DDPF_FOURCC     =$00000004;
DDPF_INDEXED    =$00000020; 
DDPF_RGB        =$00000040;

DDSCAPS_COMPLEX =$00000008;
DDSCAPS_TEXTURE =$00001000;
DDSCAPS_MIPMAP  =$00400000;

DDSCAPS2_CUBEMAP          =$00000200;
DDSCAPS2_CUBEMAP_POSITIVEX=$00000400;
DDSCAPS2_CUBEMAP_NEGATIVEX=$00000800;
DDSCAPS2_CUBEMAP_POSITIVEY=$00001000;
DDSCAPS2_CUBEMAP_NEGATIVEY=$00002000;
DDSCAPS2_CUBEMAP_POSITIVEZ=$00004000;
DDSCAPS2_CUBEMAP_NEGATIVEZ=$00008000;
DDSCAPS2_VOLUME           =$00200000;  

FOURCC_DXT1=$31545844; // 'DXT1'
FOURCC_DXT3=$33545844; // 'DXT3'
FOURCC_DXT5=$35545844; // 'DXT5'
//############################################################################//
type
TDDPIXELFORMAT=record
 dwSize,dwFlags,dwFourCC,dwRGBBitCount,dwRBitMask,dwGBitMask,dwBBitMask,dwABitMask:Cardinal;
end;

TDDCAPS2=record
 dwCaps1,dwCaps2:Cardinal;
 Reserved:array[0..1]of Cardinal;
end;

TDDSURFACEDESC2=record
 dwSize,dwFlags,dwHeight,dwWidth,dwPitchOrLinearSize,dwDepth,dwMipMapCount:Cardinal;
 dwReserved1:array[0..10]of Cardinal;
 ddpfPixelFormat:TDDPIXELFORMAT;
 ddsCaps:TDDCAPS2;
 dwReserved2:Cardinal;
end;

TDDSHeader=record
 Magic:Cardinal;
 SurfaceFormat:TDDSURFACEDESC2;
end;
TFOURCC=array[0..3]of char;
//############################################################################//
//############################################################################//
function getbfm(mask:dword):integer;
var i:integer;
begin result:=0;
 if mask=0 then result:=0 else for i:=0 to 31 do if(mask and (1 shl i))<>0 then begin result:=i;exit;end;
end;     
//############################################################################//
function fileeof(handle:thandle):boolean;
var siz,pos:dword;
begin                       
 pos:=fileseek(handle,0,1);
 siz:=fileseek(handle,0,2);
 fileseek(handle,pos,0);
 result:=pos>=siz;
end;
//############################################################################//
//############################################################################//
function isdds(fn:string):boolean;
var header:TDDSHeader;
{$ifndef VFS}h:integer;{$else}f:vfile;{$endif}
begin  
 {$ifndef VFS}
 result:=false;

 h:=fileopen(fn,0);
 fileread(h,header,Sizeof(TDDSHeader));
 fileclose(h);
 
 if TFOURCC(header.Magic)<>'DDS ' then exit;
 result:=true;
 {$else}
 result:=false;       
 if not vfopen(f,fn,1) then exit; 
 if vffilesize(f)<=Sizeof(TDDSHeader) then begin vfclose(f); exit; end;
 vfread(f,@header,Sizeof(TDDSHeader));
 vfclose(f);
 
 if TFOURCC(header.Magic)<>'DDS ' then exit;
 result:=true;
 {$endif}
end;
//############################################################################//
function isdds_comp(fn:string):boolean;
var header:TDDSHeader;
{$ifndef VFS}h:integer;{$else}f:vfile;{$endif}
begin     
 result:=false;   
 {$ifndef VFS}
 h:=fileopen(fn,0);
 fileread(h,header,Sizeof(TDDSHeader));
 fileclose(h);
 {$else}     
 if not vfopen(f,fn,1) then exit; 
 if vffilesize(f)<=Sizeof(TDDSHeader) then begin vfclose(f); exit; end;
 vfread(f,@header,Sizeof(TDDSHeader));
 vfclose(f);
 {$endif}   
 if TFOURCC(header.Magic)<>'DDS ' then exit;
 if (header.SurfaceFormat.ddpfPixelFormat.dwFlags and DDPF_FOURCC)<=0 then exit;
 result:=true;
end;
//############################################################################//
//############################################################################//
function loadddsbase(var f:integer;var wr,hr:integer;var p:pointer;var ct,len:integer;comp:boolean):boolean;
var header:TDDSHeader;
i,j,rowSize,ddsPixelSize,imgPixelSize:integer;
buf:pbytea;
col:pdword;
rs,rm,gs,gm,bs,bm,ash,aml:byte;
trans:boolean;
cr:pcrgba;
begin             
 result:=false;
 
 fileread(f,header,sizeof(TDDSHeader));
 if TFOURCC(header.Magic)<>'DDS ' then exit;

 with header.SurfaceFormat do begin
  if (ddsCaps.dwCaps1 and DDSCAPS_TEXTURE)=0 then exit;
  //if (ddsCaps.dwCaps1 and DDSCAPS_MIPMAP)<>0 then exit;
  trans:=(ddpfPixelFormat.dwFlags and DDPF_ALPHAPIXELS)>0;

  wr:=dwWidth;
  hr:=dwHeight;

  if dwPitchOrLinearSize=0 then dwPitchOrLinearSize:=wr*hr; 
  
  if (ddpfPixelFormat.dwFlags and DDPF_FOURCC)>0 then begin
   if not comp then begin   
    getmem(buf,dwPitchOrLinearSize); 
    fileread(f,buf[0],dwPitchOrLinearSize);   
    getmem(p,wr*4*hr);
    try
     case ddpfPixelFormat.dwFourCC of
      FOURCC_DXT1:DecodeDXT1toBitmap32(buf,p,wr,hr,trans);
      FOURCC_DXT3:DecodeDXT3toBitmap32(buf,p,wr,hr);
      FOURCC_DXT5:DecodeDXT5toBitmap32(buf,p,wr,hr);
      else exit; 
     end;
     result:=true;
    finally
     freemem(buf);
    end;
   end else begin  
    getmem(p,dwPitchOrLinearSize);
    fileread(f,p^,dwPitchOrLinearSize);
    len:=dwPitchOrLinearSize;  
    case ddpfPixelFormat.dwFourCC of
     FOURCC_DXT1:ct:=1;
     FOURCC_DXT3:ct:=3;
     FOURCC_DXT5:ct:=5;
     else ct:=99;
    end;             
    result:=true;
   end;
  end else begin   
   imgPixelSize:=4;
   ddsPixelSize:=(ddpfPixelFormat.dwRGBBitCount div 8);
   rowSize:=ddsPixelSize*integer(dwWidth);

   rs:=getbfm(ddpfPixelFormat.dwRBitMask);
   gs:=getbfm(ddpfPixelFormat.dwGBitMask);
   bs:=getbfm(ddpfPixelFormat.dwBBitMask);
   if trans then ash:=getbfm(ddpfPixelFormat.dwABitMask)else ash:=0;
   rm:=1;gm:=1;bm:=1;aml:=1;

   if (ddpfPixelFormat.dwRBitMask shr rs)>0 then rm:=255 div(ddpfPixelFormat.dwRBitMask shr rs);
   if (ddpfPixelFormat.dwGBitMask shr gs)>0 then gm:=255 div(ddpfPixelFormat.dwGBitMask shr gs);
   if (ddpfPixelFormat.dwBBitMask shr bs)>0 then bm:=255 div(ddpfPixelFormat.dwBBitMask shr bs);
   if trans then if (ddpfPixelFormat.dwABitMask shr ash)>0 then aml:=255 div(ddpfPixelFormat.dwABitMask shr ash);
                  
   getmem(p,hr*wr*4);
   getmem(buf,rowSize);
   for j:=0 to hr-1 do begin   
    fileread(f,buf[0],rowSize);
    for i:=0 to wr-1 do begin
     col:=@buf[ddsPixelSize*i];
     cr:=pcrgba(intptr(p)+intptr(4*j*wr+imgPixelSize*i));
     {$ifndef BGR}
                   cr^[2]:= bm*(col^ and ddpfPixelFormat.dwBBitMask)shr bs;
                   cr^[1]:= gm*(col^ and ddpfPixelFormat.dwGBitMask)shr gs;
                   cr^[0]:= rm*(col^ and ddpfPixelFormat.dwRBitMask)shr rs;  
     {$else}
                   cr^[2]:= bm*(col^ and ddpfPixelFormat.dwBBitMask)shr bs;
                   cr^[1]:= gm*(col^ and ddpfPixelFormat.dwGBitMask)shr gs;
                   cr^[0]:= rm*(col^ and ddpfPixelFormat.dwRBitMask)shr rs;              
     {$endif}
     if trans then cr^[3]:=aml*(col^ and ddpfPixelFormat.dwABitMask)shr ash else cr^[3]:=255;            
    end;
   end;
   freemem(buf);   
   result:=true; 
  end;
 end;
 
 {$ifdef BGR} 
 for i:=0 to hr-1 do for j:=0 to wr-1 do begin 
  cr:=pcrgba(intptr(p)+intptr(j*4+i*wr*4));
  cr[3]:=255;
  bs:=cr[2];
  cr[2]:=cr[0];
  cr[0]:=bs;
 end;     
 {$endif}
   
end;
//############################################################################//
//############################################################################//
function Loaddds(fn:string;var width,height:integer;var p:pointer;var ct,len:integer;comp:boolean):boolean;
var f:integer; 
begin            
 f:=fileopen(fn,0);
 result:=Loadddsbase(f,width,height,p,ct,len,comp);
 fileclose(f);
end;            
//############################################################################//     
function lddds(fn:string;wtx,wa:boolean;trc:crgb;var width,height:integer;var p:pointer):pointer;  
var f:integer; 
ct,len:integer;
begin            
 f:=fileopen(fn,0);
 Loadddsbase(f,width,height,p,ct,len,false);
 result:=p;
 fileclose(f);
end;                                                  
//############################################################################//
//############################################################################//
function Loadltexoff(fn:string;o:integer;var p:pointer;comp:boolean):boolean;
var f:integer; 
width,height,ct,len:integer;
begin    
 result:=false;
 if not fileexists(fn) then exit; 
 f:=fileopen(fn,0);

 fileseek(f,o,0);
 result:=Loadddsbase(f,width,height,p,ct,len,comp);
 
 fileclose(f);
end;                                              
//############################################################################//
//############################################################################//
function Loadltexn(fn:string;n:integer;var p:pointer;comp:boolean):boolean;
var f,ps:integer; 
width,height,ct,len:integer;
begin    
 result:=false;
 if not fileexists(fn) then exit; 
 f:=fileopen(fn,0);

 ps:=32896*n;
 fileseek(f,ps,0);
 result:=Loadddsbase(f,width,height,p,ct,len,comp);
 
 fileclose(f);
end;
//############################################################################//
//############################################################################//
function Loadtex(fn:string;var width,height:aointeger;var count:integer;var p:apointer;var ct,len:aointeger;comp:boolean):boolean;
var f:integer; 
begin    
 result:=false;
 if not fileexists(fn) then exit;
 
 f:=fileopen(fn,0);

 count:=0;
 result:=true;  
 while not fileeof(f) do begin  
  setlength(width,count+1); 
  setlength(height,count+1);
  setlength(p,count+1);   
  setlength(ct,count+1);
  setlength(len,count+1);

  result:=result and Loadddsbase(f,width[count],height[count],p[count],ct[count],len[count],comp);
  count:=count+1;
 end;
 fileclose(f);
end;  
//############################################################################//
//############################################################################//
function storememDDSt1f32(p:pointer;xr,yr:integer;rev,bgr:boolean;var buf:pointer;var bs:integer):boolean;
var header:TDDSHeader;
begin    
 result:=false;
 if((xr mod 4)<>0)or((yr mod 4)<>0)then exit;
 if (xr<4)or(yr<4)then exit;
                                  
 fillchar(header,sizeof(header),0);
 header.Magic:=$20534444; //"DDS "
 header.SurfaceFormat.dwSize:=124;

 header.SurfaceFormat.ddsCaps.dwCaps1:=DDSCAPS_TEXTURE;
 header.SurfaceFormat.dwFlags:=DDSD_PIXELFORMAT or DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_LINEARSIZE;

 header.SurfaceFormat.dwWidth:=xr;
 header.SurfaceFormat.dwHeight:=yr;
 header.SurfaceFormat.dwPitchOrLinearSize:=xr*yr div 2;
  
 header.SurfaceFormat.ddpfPixelFormat.dwSize:=sizeof(header.SurfaceFormat.ddpfPixelFormat);
 header.SurfaceFormat.ddpfPixelFormat.dwFlags:=DDPF_FOURCC;
 header.SurfaceFormat.ddpfPixelFormat.dwFourCC:=FOURCC_DXT1;
 getmem(buf,header.SurfaceFormat.dwPitchOrLinearSize+SizeOf(header));
 move(header,buf^,SizeOf(header));
 
 fillchar(pointer(intptr(buf)+SizeOf(header))^,header.SurfaceFormat.dwPitchOrLinearSize,0);
 EncodeBitmap32toDXT1(p,pointer(intptr(buf)+SizeOf(header)),xr,yr);
 bs:=header.SurfaceFormat.dwPitchOrLinearSize+SizeOf(header);
 result:=true;
end;
//############################################################################//
//############################################################################//
function storeDDSt1f32(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
var f:vfile;         
header:TDDSHeader;
buf:pointer;
begin    
 result:=false;
 if((xr mod 4)<>0)or((yr mod 4)<>0)then exit;
 if (xr<4)or(yr<4)then exit;
 if not vfopen(f,fn,2)then exit;
                                  
 fillchar(header,sizeof(header),0);
 header.Magic:=$20534444; //"DDS "
 header.SurfaceFormat.dwSize:=124;

 header.SurfaceFormat.ddsCaps.dwCaps1:=DDSCAPS_TEXTURE;
 header.SurfaceFormat.dwFlags:=DDSD_PIXELFORMAT or DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_LINEARSIZE;

 header.SurfaceFormat.dwWidth:=xr;
 header.SurfaceFormat.dwHeight:=yr;
 header.SurfaceFormat.dwPitchOrLinearSize:=xr*yr div 2;
  
 header.SurfaceFormat.ddpfPixelFormat.dwSize:=sizeof(header.SurfaceFormat.ddpfPixelFormat);
 header.SurfaceFormat.ddpfPixelFormat.dwFlags:=DDPF_FOURCC;
 header.SurfaceFormat.ddpfPixelFormat.dwFourCC:=FOURCC_DXT1;
 vfwrite(f,@header,SizeOf(header));
 
 getmem(buf,header.SurfaceFormat.dwPitchOrLinearSize); 
 fillchar(buf^,header.SurfaceFormat.dwPitchOrLinearSize,0);
 EncodeBitmap32toDXT1(p,buf,xr,yr);
 vfwrite(f,buf,header.SurfaceFormat.dwPitchOrLinearSize);

 freemem(buf);
 vfclose(f);
 result:=true;
end;
//############################################################################//
function storeDDSt3f32(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
var f:vfile;         
header:TDDSHeader;
buf:pointer;
begin    
 result:=false;
 if((xr mod 4)<>0)or((yr mod 4)<>0)then exit;
 if (xr<4)or(yr<4)then exit;
 if not vfopen(f,fn,2)then exit;
                                  
 fillchar(header,sizeof(header),0);
 header.Magic:=$20534444; //"DDS "
 header.SurfaceFormat.dwSize:=124;

 header.SurfaceFormat.ddsCaps.dwCaps1:=DDSCAPS_TEXTURE;
 header.SurfaceFormat.dwFlags:=DDSD_PIXELFORMAT or DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_LINEARSIZE;

 header.SurfaceFormat.dwWidth:=xr;
 header.SurfaceFormat.dwHeight:=yr;
 header.SurfaceFormat.dwPitchOrLinearSize:=xr*yr;
  
 header.SurfaceFormat.ddpfPixelFormat.dwSize:=sizeof(header.SurfaceFormat.ddpfPixelFormat);
 header.SurfaceFormat.ddpfPixelFormat.dwFlags:=DDPF_FOURCC;
 header.SurfaceFormat.ddpfPixelFormat.dwFourCC:=FOURCC_DXT3;
 vfwrite(f,@header,SizeOf(header));
 
 getmem(buf,header.SurfaceFormat.dwPitchOrLinearSize); 
 fillchar(buf^,header.SurfaceFormat.dwPitchOrLinearSize,0);
 EncodeBitmap32toDXT3(p,buf,xr,yr);
 vfwrite(f,buf,header.SurfaceFormat.dwPitchOrLinearSize);

 freemem(buf);
 vfclose(f);
 result:=true;
end;
//############################################################################//
function storememDDSt5f32(p:pointer;xr,yr:integer;rev,bgr:boolean;var buf:pointer;var bs:integer):boolean;
var header:TDDSHeader;
begin    
 result:=false;
 if((xr mod 4)<>0)or((yr mod 4)<>0)then exit;
 if (xr<4)or(yr<4)then exit;
                                  
 fillchar(header,sizeof(header),0);
 header.Magic:=$20534444; //"DDS "
 header.SurfaceFormat.dwSize:=124;

 header.SurfaceFormat.ddsCaps.dwCaps1:=DDSCAPS_TEXTURE;
 header.SurfaceFormat.dwFlags:=DDSD_PIXELFORMAT or DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_LINEARSIZE;

 header.SurfaceFormat.dwWidth:=xr;
 header.SurfaceFormat.dwHeight:=yr;
 header.SurfaceFormat.dwPitchOrLinearSize:=xr*yr;
  
 header.SurfaceFormat.ddpfPixelFormat.dwSize:=sizeof(header.SurfaceFormat.ddpfPixelFormat);
 header.SurfaceFormat.ddpfPixelFormat.dwFlags:=DDPF_FOURCC;
 header.SurfaceFormat.ddpfPixelFormat.dwFourCC:=FOURCC_DXT5;
 header.SurfaceFormat.ddpfPixelFormat.dwRGBBitCount:=$200;
 getmem(buf,header.SurfaceFormat.dwPitchOrLinearSize+SizeOf(header));
 move(header,buf^,SizeOf(header));
           
 fillchar(pointer(intptr(buf)+SizeOf(header))^,header.SurfaceFormat.dwPitchOrLinearSize,0);
 EncodeBitmap32toDXT5(p,pointer(intptr(buf)+SizeOf(header)),xr,yr);
 bs:=header.SurfaceFormat.dwPitchOrLinearSize+SizeOf(header);
 result:=true;
end;
//############################################################################//
function storeDDSt5f32(fn:string;p:pointer;xr,yr:integer;rev,bgr:boolean):boolean;
var f:vfile;         
header:TDDSHeader;
buf:pointer;
begin    
 result:=false;
 if((xr mod 4)<>0)or((yr mod 4)<>0)then exit;
 if (xr<4)or(yr<4)then exit;
 if not vfopen(f,fn,2)then exit;
                                  
 fillchar(header,sizeof(header),0);
 header.Magic:=$20534444; //"DDS "
 header.SurfaceFormat.dwSize:=124;

 header.SurfaceFormat.ddsCaps.dwCaps1:=DDSCAPS_TEXTURE;
 header.SurfaceFormat.dwFlags:=DDSD_PIXELFORMAT or DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_LINEARSIZE;

 header.SurfaceFormat.dwWidth:=xr;
 header.SurfaceFormat.dwHeight:=yr;
 header.SurfaceFormat.dwPitchOrLinearSize:=xr*yr;
  
 header.SurfaceFormat.ddpfPixelFormat.dwSize:=sizeof(header.SurfaceFormat.ddpfPixelFormat);
 header.SurfaceFormat.ddpfPixelFormat.dwFlags:=DDPF_FOURCC;
 header.SurfaceFormat.ddpfPixelFormat.dwFourCC:=FOURCC_DXT5;
 header.SurfaceFormat.ddpfPixelFormat.dwRGBBitCount:=$200;
 vfwrite(f,@header,SizeOf(header));
 
 getmem(buf,header.SurfaceFormat.dwPitchOrLinearSize); 
 fillchar(buf^,header.SurfaceFormat.dwPitchOrLinearSize,0);
 EncodeBitmap32toDXT5(p,buf,xr,yr);
 vfwrite(f,buf,header.SurfaceFormat.dwPitchOrLinearSize);

 freemem(buf);
 vfclose(f);
 result:=true;
end;
//############################################################################//
begin    
 register_grfmt(nil,isdds,nil,lddds,nil,nil,nil,nil); 
end.  
//############################################################################//

























