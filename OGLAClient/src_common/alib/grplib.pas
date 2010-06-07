//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: Graphics Lib 
//############################################################################//
unit grplib;
{$ifdef FPC}{$MODE delphi}{$endif}
interface
uses asys,grph,maths,sysutils,strval{$ifdef VFS},vfs,vfsutils{$endif}{$ifdef ape3},vfsint,akernel{$endif};
//############################################################################//
function LoadBitmap (filename:string;var width,height:integer;var pdata:pointer):pointer; overload; 
function LoadBitmap_mem(b:pointer;bs:integer;var width,height:integer;var pdata:pointer):pointer;
function LoadBitmap (filename:string;var width,height:integer;trc:crgb;var pdata:pointer):pointer; overload;
function LoadBitmap8(filename:string;var width,height:integer;var pData:pointer;var cl:pallette):pointer; overload;
function LoadBitmap8(filename:string;var width,height:integer;trc:crgb;var pData:pointer;var cl:pallette):pointer; overload;
function LoadBitmap8(filename:string;var width,height:integer;var pData:pointer;var cl:pallette3):pointer; overload;
function LoadBitmap8(filename:string;var width,height:integer;trc:crgb;var pData:pointer;var cl:pallette3):pointer; overload;
        
procedure tx_swap_bgr(p:pointer;x,y:integer);
procedure rot_msh(var msh:typmsh;ang:double;axis:integer);
procedure rot_mshgrp(var g:typmshgrp;ang:double;axis:integer);
procedure shift_mshgrp(var g:typmshgrp;sh:mvec);
procedure scale_mshgrp(var g:typmshgrp;scl:mvec);

{$ifndef fpcfix}function loadmsh(msh:ptypmsh;fn,txdir:string):integer; {$endif}

procedure grlditherfls32b8(p:pointer;o,xs,ys:integer);
procedure grldithergra32b8(p:pointer;o,xs,ys:integer);
procedure grlditherbay32b8(p:pointer;o,xs,ys:integer);
procedure grlditherthr32b8(p:pointer;o,xs,ys:integer);
procedure grlditherrnd32b8(p:pointer;o,xs,ys:integer);
procedure smootfilter(p:pbcrgba;xs,ys:integer);
//############################################################################//
type 
grfmt_is=function(fn:string):boolean;
grfmt_ld8=function(fn:string;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer;var cpal:pallette):pointer;  
grfmt_ld32=function(fn:string;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;  
grfmt_memis  =function(b:pointer;bs:integer):boolean;
grfmt_memld8 =function(b:pointer;bs:integer;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer;var cpal:pallette):pointer;  
grfmt_memld32=function(b:pointer;bs:integer;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;  

grfmt_rec=record
 is32,is8:grfmt_is;
 ld32:grfmt_ld32;
 ld8:grfmt_ld8;
 
 memis32,memis8:grfmt_memis;
 memld32:grfmt_memld32;
 memld8:grfmt_memld8;
end;
var
grfmt:array of grfmt_rec;
//############################################################################//
procedure register_grfmt(i8,i32:grfmt_is;l8:grfmt_ld8;l32:grfmt_ld32;mi8,mi32:grfmt_memis;ml8:grfmt_memld8;ml32:grfmt_memld32);
//############################################################################//
implementation                                                      
//############################################################################//               
procedure register_grfmt(i8,i32:grfmt_is;l8:grfmt_ld8;l32:grfmt_ld32;mi8,mi32:grfmt_memis;ml8:grfmt_memld8;ml32:grfmt_memld32);
var c:integer;
begin
 c:=length(grfmt);
 setlength(grfmt,c+1);
 grfmt[c].is32:=i32;
 grfmt[c].is8 :=i8;
 grfmt[c].ld32:=l32;
 grfmt[c].ld8 :=l8;
 grfmt[c].memis32:=mi32;
 grfmt[c].memis8 :=mi8;
 grfmt[c].memld32:=ml32;
 grfmt[c].memld8 :=ml8;
end;
//############################################################################//    
const 
TEX2_MULTIPLIER=4; 
      
detab:array[0..15]of array[0..15]of byte=(
  (   0,192, 48,240, 12,204, 60,252,  3,195, 51,243, 15,207, 63,255 ),
  ( 128, 64,176,112,140, 76,188,124,131, 67,179,115,143, 79,191,127 ),
  (  32,224, 16,208, 44,236, 28,220, 35,227, 19,211, 47,239, 31,223 ),
  ( 160, 96,144, 80,172,108,156, 92,163, 99,147, 83,175,111,159, 95 ),
  (   8,200, 56,248,  4,196, 52,244, 11,203, 59,251,  7,199, 55,247 ),
  ( 136, 72,184,120,132, 68,180,116,139, 75,187,123,135, 71,183,119 ),
  (  40,232, 24,216, 36,228, 20,212, 43,235, 27,219, 39,231, 23,215 ),
  ( 168,104,152, 88,164,100,148, 84,171,107,155, 91,167,103,151, 87 ),
  (   2,194, 50,242, 14,206, 62,254,  1,193, 49,241, 13,205, 61,253 ),
  ( 130, 66,178,114,142, 78,190,126,129, 65,177,113,141, 77,189,125 ),
  (  34,226, 18,210, 46,238, 30,222, 33,225, 17,209, 45,237, 29,221 ),
  ( 162, 98,146, 82,174,110,158, 94,161, 97,145, 81,173,109,157, 93 ),
  (  10,202, 58,250,  6,198, 54,246,  9,201, 57,249,  5,197, 53,245 ),
  ( 138, 74,186,122,134, 70,182,118,137, 73,185,121,133, 69,181,117 ),
  (  42,234, 26,218, 38,230, 22,214, 41,233, 25,217, 37,229, 21,213 ),
  ( 170,106,154, 90,166,102,150, 86,169,105,153, 89,165,101,149, 85 )
); 
//############################################################################//
var rndtab:array[0..30]of array[0..30]of byte;
//############################################################################//
function  rndn(c:double):double;begin result:=(lrandom-0.5)*2*c;end;       
procedure makerndt;var x,y:integer;begin for x:=0 to 30 do for y:=0 to 30 do rndtab[x][y]:=random(255);end;  
//############################################################################//
//############################################################################//                    
function LoadBitmap_mem(b:pointer;bs:integer;var width,height:integer;var pdata:pointer):pointer;
var i:integer;
begin        
 pdata:=nil;result:=nil;  
 if b=nil then exit;           
 for i:=0 to length(grfmt)-1 do if assigned(grfmt[i].memis32) then if grfmt[i].memis32(b,bs) then begin    
  result:=grfmt[i].memld32(b,bs,false,true,gclz,width,height,pdata);
  exit;
 end; 
end;        
//############################################################################//
function LoadBitmap(filename:string;var width,height:integer;trc:crgb;var pdata:pointer):pointer; overload; 
var i:integer;
begin        
 pdata:=nil;result:=nil;             
 if not vfexists(filename) then exit;  
 for i:=0 to length(grfmt)-1 do if assigned(grfmt[i].is32) then if grfmt[i].is32(filename) then begin    
  result:=grfmt[i].ld32(filename,true,true,trc,width,height,pdata);
  exit;
 end; 
end;         
//############################################################################//
function LoadBitmap(filename:string;var width,height:integer;var pData:pointer):pointer; overload;
begin result:=LoadBitmap(filename,width,height,gclz,pdata);end;
//############################################################################//
function LoadBitmap8(filename:string;var width,height:integer;trc:crgb;var pData:pointer;var cl:pallette):pointer; overload;
var i:integer;
begin        
 pdata:=nil;result:=nil;             
 if not vfexists(filename) then exit;  
 for i:=0 to length(grfmt)-1 do if assigned(grfmt[i].is8) then if grfmt[i].is8(filename) then begin    
  result:=grfmt[i].ld8(filename,true,true,trc,width,height,pdata,cl);
  exit;
 end;  
end;      
//############################################################################//
function LoadBitmap8(filename:string;var width,height:integer;var pData:pointer;var cl:pallette):pointer; overload;
begin result:=LoadBitmap8(filename,width,height,gclz,pData,cl);end;
//############################################################################//
function LoadBitmap8(filename:string;var width,height:integer;var pData:pointer;var cl:pallette3):pointer; overload; 
var pl:pallette;
i:integer;
begin
 result:=LoadBitmap8(filename,width,height,pData,pl);
 for i:=0 to 255 do begin cl[i][0]:=pl[i][0];cl[i][1]:=pl[i][1];cl[i][2]:=pl[i][2];end;
end;
//############################################################################//
function LoadBitmap8(filename:string;var width,height:integer;trc:crgb;var pData:pointer;var cl:pallette3):pointer; overload;
var pl:pallette;
i:integer;
begin
 result:=LoadBitmap8(filename,width,height,trc,pData,pl);
 for i:=0 to 255 do begin cl[i][0]:=pl[i][0];cl[i][1]:=pl[i][1];cl[i][2]:=pl[i][2];end;
end;
//############################################################################//
//############################################################################//
procedure tx_swap_bgr(p:pointer;x,y:integer);
var xx,yy:integer;
c:pcrgba;
b:byte;
begin
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
  c:=@pbcrgba(p)[xx+yy*x];
  b:=c[0]; 
  c[0]:=c[2];
  c[2]:=b;
 end;
end;   
//############################################################################//
//############################################################################//
procedure rot_msh(var msh:typmsh;ang:double;axis:integer);
var i,j:integer;
begin
 if ang=0 then exit;
 if msh.used then for i:=0 to length(msh.grp)-1 do case axis of
  0:for j:=0 to length(msh.grp[i].pnts)-1 do begin vrotx(msh.grp[i].pnts[j].pos,ang);vrotx(msh.grp[i].pnts[j].nml,ang);end;
  1:for j:=0 to length(msh.grp[i].pnts)-1 do begin vroty(msh.grp[i].pnts[j].pos,ang);vroty(msh.grp[i].pnts[j].nml,ang);end;
  2:for j:=0 to length(msh.grp[i].pnts)-1 do begin vrotz(msh.grp[i].pnts[j].pos,ang);vrotz(msh.grp[i].pnts[j].nml,ang);end;
 end;
end;
//############################################################################//
procedure rot_mshgrp(var g:typmshgrp;ang:double;axis:integer);
var j:integer;
begin
 if ang=0 then exit;
 case axis of
  0:for j:=0 to length(g.pnts)-1 do begin vrotx(g.pnts[j].pos,ang);vrotx(g.pnts[j].nml,ang);end;
  1:for j:=0 to length(g.pnts)-1 do begin vroty(g.pnts[j].pos,ang);vroty(g.pnts[j].nml,ang);end;
  2:for j:=0 to length(g.pnts)-1 do begin vrotz(g.pnts[j].pos,ang);vrotz(g.pnts[j].nml,ang);end;
 end;
end;
//############################################################################//
procedure shift_mshgrp(var g:typmshgrp;sh:mvec);
var i:integer;
begin
 for i:=0 to length(g.pnts)-1 do g.pnts[i].pos:=addv(g.pnts[i].pos,sh);
 g.center:=addv(g.center,m2v(sh));
end;
//############################################################################//
procedure scale_mshgrp(var g:typmshgrp;scl:mvec);
var i:integer;
begin
 for i:=0 to length(g.pnts)-1 do begin
  g.pnts[i].pos.x:=g.pnts[i].pos.x*scl.x;
  g.pnts[i].pos.y:=g.pnts[i].pos.y*scl.y;
  g.pnts[i].pos.z:=g.pnts[i].pos.z*scl.z;
 end;
end;
//############################################################################//
//############################################################################//
//############################################################################//
{$ifndef fpcfix}
//3.156
//0.414
function loadmsh(msh:ptypmsh;fn,txdir:string):integer;
var f:vfile;
pn,tn,gn,ptx,pty,ptz,cm,mc,i,ii,j,k:integer;
clt,cst,ct,tc:dword;
str1,str2,mn:string;  
fnm:mvec;
mvv,mvvgl,mvvgh:vec;
nnm,l,ntx2:boolean;
pnt:ppntyp;

mats:array of matq;
spw:array of vec5;
txi:array of pointer;
txx,txy:array of integer;

buf:pchara;
bs,bp:dword;

str1c:array[0..255]of char;
cs:integer;  
spc:array[0..9]of array[0..255]of char;
spcs:array[0..9]of integer;
c:char;

procedure readtln;
var c:char;
begin
 str1:='';
 while bp<bs do begin
  c:=buf[bp];                
  bp:=bp+1;
  if c=#10 then exit;
  if c<>#13 then str1:=str1+c;
 end;
end;
procedure readtlnc;
var c:char;
begin
 str1c[0]:=#0;
 cs:=0;
 while bp<bs do begin
  c:=buf[bp];                
  bp:=bp+1;
  if c=#10 then exit;
  if c<>#13 then begin str1c[cs]:=c;str1c[cs+1]:=#0;cs:=cs+1;end;
 end;
end;
function decomment(s:string):string;
var i:integer;
begin
 for i:=1 to length(s) do if s[i]=';' then begin result:=trim(copy(s,1,i-1));exit;end;
 result:=trim(s);
end;
function slash_lin(s:string):string;
var i:integer;
begin
 result:=s;
 for i:=1 to length(s) do if s[i]='\' then result[i]:='/';
end;

begin 
 tn:=0;pn:=0;gn:=-1;mc:=0;result:=0;
 if msh=nil then exit;
 
 if not vfexists(fn) then exit;
 vfopen(f,fn,1);
 bs:=vffilesize(f);
 bp:=0;
 getmem(buf,bs);
 vfread(f,buf,bs);
 vfclose(f);

 //////////////////////////
 //Header
 while bp<bs do begin
  readtln;
  if copy(str1,1,6)='GROUPS' then begin gn:=vali(decomment(copy(str1,8,length(str1)-7)));break;end;
 end;
 if(gn=-1)or(gn>32768)then begin freemem(buf);exit;end;

 setlength(msh.grp,gn);
 msh.grc:=gn;
 msh.flg:=0;
 msh.txc:=0;
 msh.siz:=0;
 mvv:=tvec(0,0,0);
 msh.fnam:=fn;
 msh.txdir:=txdir;   
 msh.need_fin:=true;
 setlength(msh.txs,0);
  
 ct:=notx;
 clt:=notx;
 cst:=notx;
 cm:=255;    
 //////////////////////////
 //Groups
 for ii:=0 to gn-1 do begin
  nnm:=false;
  //ntx2:=false;  
  mkcln_grptex(@msh.grp[ii].dif);
  mkcln_grptex(@msh.grp[ii].nml);
  mkcln_grptex(@msh.grp[ii].lth);  
  msh.grp[ii].col:=tcrgba(255,255,255,255); 
  msh.grp[ii].vboreset:=false;
  mvvgh:=tvec(-1e100,-1e100,-1e100);
  mvvgl:=tvec(1e100,1e100,1e100);
  
  repeat
   readtln;
   if copy(str1,1,4)='GEOM' then begin
    str2:=copy(str1,6,length(str1)-5);
    i:=getfsymp(str2,' ');
    pn:=vali(copy(str2,1,i-1));
    str2:=copy(str2,i+1,length(str2)-i);
    i:=getfsymp(str2,' ');
    if i<>0 then tn:=vali(copy(str2,1,i-1));
    if i=0 then tn:=vali(str2); 
    break;
   end;
   if copy(str1,1, 8)='MATERIAL'       then cm :=vali(decomment(copy(str1,10,length(str1)- 9)));
   if copy(str1,1, 7)='TEXTURE'        then ct :=vali(decomment(copy(str1, 9,length(str1)- 8)));
   if copy(str1,1,12)='LIGHTTEXTURE'   then clt:=vali(decomment(copy(str1,14,length(str1)-13)));
   if copy(str1,1,14)='NMLSPECTEXTURE' then cst:=vali(decomment(copy(str1,16,length(str1)-15)));
   if copy(str1,1, 8)='NONORMAL'       then nnm:=true;
   if copy(str1,1, 7)='LIGHTUV'        then msh.grp[ii].lth.uv:=vali(decomment(copy(str1, 9,length(str1)- 8)))-1;
   if copy(str1,1, 6)='DIFFUV'         then msh.grp[ii].dif.uv:=vali(decomment(copy(str1, 8,length(str1)- 7)))-1;
   if copy(str1,1, 5)='NMLUV'          then msh.grp[ii].nml.uv:=vali(decomment(copy(str1, 7,length(str1)- 6)))-1;
  until bp>=bs;
  if cm=0 then cm:=255;
  if ct=0 then ct:=notx;
  if clt=0 then clt:=notx;
  if cst=0 then cst:=notx;

  setlength(msh.grp[ii].pnts,pn);
  setlength(msh.grp[ii].trng,tn*3);
  msh.grp[ii].col:=tcrgba(255,255,255,cm);
  msh.grp[ii].dif.tx:=ct;
  msh.grp[ii].lth.tx:=clt;
  msh.grp[ii].nml.tx:=cst;

  for i:=0 to pn-1 do begin
   pnt:=@msh.grp[ii].pnts[i];
   readtlnc;  
     
   k:=0;l:=true;
   for j:=0 to 9 do spcs[j]:=0;
   for j:=0 to cs-1 do begin
    c:=str1c[j];
    if(c=' ')or(c=#9) then begin
     if not l then begin spc[k][spcs[k]]:=#0;k:=k+1;end;
     l:=true;
     continue;
    end;
    spc[k][spcs[k]]:=c;
    spcs[k]:=spcs[k]+1;
    spc[k][spcs[k]]:=#0;
    l:=false;
   end;     
   
   pnt.pos.x:=valep(spc[0]);
   pnt.pos.y:=valep(spc[1]);
   pnt.pos.z:=valep(spc[2]);
   nnm:=spc[5][0]=#0;
   //ntx2:=((spc[9][0]=#0)and(not nnm))or(spc[7][0]=#0);

   if abs(pnt.pos.x)>mvv.x then mvv.x:=abs(pnt.pos.x);
   if abs(pnt.pos.y)>mvv.y then mvv.y:=abs(pnt.pos.y);
   if abs(pnt.pos.z)>mvv.z then mvv.z:=abs(pnt.pos.z);
   if pnt.pos.x>mvvgh.x then mvvgh.x:=pnt.pos.x;
   if pnt.pos.y>mvvgh.y then mvvgh.y:=pnt.pos.y;
   if pnt.pos.z>mvvgh.z then mvvgh.z:=pnt.pos.z;
   if pnt.pos.x<mvvgl.x then mvvgl.x:=pnt.pos.x;
   if pnt.pos.y<mvvgl.y then mvvgl.y:=pnt.pos.y;
   if pnt.pos.z<mvvgl.z then mvvgl.z:=pnt.pos.z;

   j:=3;
   if not nnm then begin
    pnt.nml.x:=valep(spc[3]);
    pnt.nml.y:=valep(spc[4]);
    pnt.nml.z:=valep(spc[5]);
    j:=6;
   end else pnt.nml:=tmvec(0,0,0);
   if spc[j][0]=#0 then j:=0;
   
   if j<>0 then begin   
    pnt.tx.x:=valep(spc[j]);
    pnt.tx.y:=valep(spc[j+1]);
   end else begin
    pnt.tx.x:=0;
    pnt.tx.y:=0;
   end; 
   j:=j+2;  
   if spc[j][0]=#0 then j:=0;
   if j<>0 then begin   
    pnt.tx2.x:=valep(spc[j]);
    pnt.tx2.y:=valep(spc[j+1]);
   end else begin
    pnt.tx2.x:=0;
    pnt.tx2.y:=0;
   end;
  end;
  msh.grp[ii].boundbox[0]:=mvvgl;
  msh.grp[ii].boundbox[1]:=mvvgh;
  msh.grp[ii].center:=addv(nmulv(subv(mvvgh,mvvgl),0.5),mvvgl);    
  msh.grp[ii].siz:=max2(modv(mvvgh),modv(mvvgl));
      
  for i:=0 to tn-1 do begin
   readtlnc;  
           
   k:=0;l:=true;
   for j:=0 to 2 do spcs[j]:=0;
   for j:=0 to cs-1 do begin
    c:=str1c[j];
    if(c=' ')or(c=#9) then begin
     if not l then begin spc[k][spcs[k]]:=#0;k:=k+1;end;
     l:=true;
     continue;
    end;
    spc[k][spcs[k]]:=c;
    spcs[k]:=spcs[k]+1;
    spc[k][spcs[k]]:=#0;
    l:=false;
   end;   
   
   ptx:=vali(spc[0]);
   pty:=vali(spc[1]);
   ptz:=vali(spc[2]);

   msh.grp[ii].trng[i*3+0]:=ptx;
   msh.grp[ii].trng[i*3+1]:=pty;
   msh.grp[ii].trng[i*3+2]:=ptz;
                   
   if nnm then begin
    fnm.x:=msh.grp[ii].pnts[ptx].pos.y*(msh.grp[ii].pnts[pty].pos.z-msh.grp[ii].pnts[ptz].pos.z)+msh.grp[ii].pnts[pty].pos.y*(msh.grp[ii].pnts[ptz].pos.z-msh.grp[ii].pnts[ptx].pos.z)+msh.grp[ii].pnts[ptz].pos.y*(msh.grp[ii].pnts[ptx].pos.z-msh.grp[ii].pnts[pty].pos.z);
    fnm.y:=msh.grp[ii].pnts[ptx].pos.z*(msh.grp[ii].pnts[pty].pos.x-msh.grp[ii].pnts[ptz].pos.x)+msh.grp[ii].pnts[pty].pos.z*(msh.grp[ii].pnts[ptz].pos.x-msh.grp[ii].pnts[ptx].pos.x)+msh.grp[ii].pnts[ptz].pos.z*(msh.grp[ii].pnts[ptx].pos.x-msh.grp[ii].pnts[pty].pos.x);
    fnm.z:=msh.grp[ii].pnts[ptx].pos.x*(msh.grp[ii].pnts[pty].pos.y-msh.grp[ii].pnts[ptz].pos.y)+msh.grp[ii].pnts[pty].pos.x*(msh.grp[ii].pnts[ptz].pos.y-msh.grp[ii].pnts[ptx].pos.y)+msh.grp[ii].pnts[ptz].pos.x*(msh.grp[ii].pnts[ptx].pos.y-msh.grp[ii].pnts[pty].pos.y);
    msh.grp[ii].pnts[ptx].nml:=addv(msh.grp[ii].pnts[ptx].nml,fnm);
    msh.grp[ii].pnts[pty].nml:=addv(msh.grp[ii].pnts[pty].nml,fnm);
    msh.grp[ii].pnts[ptz].nml:=addv(msh.grp[ii].pnts[ptz].nml,fnm);
   end;
  end;
 end;
 //////////////////////////
 //Footer
 while bp<bs do begin
  readtln;
  if copy(str1,1,9)='MATERIALS' then begin mc:=vali(decomment(copy(str1,11,length(str1)-10)));break;end;
 end;

 setlength(mats,mc);
 setlength(spw,mc);
 cm:=0;
 while bp<bs do begin
  readtln;
  if copy(str1,1,9)='MATERIAL ' then begin
   mn:=copy(str1,10,length(str1)-9);  
    
   readtln; mats[cm][0]:=valquat(str1);
   readtln; mats[cm][1]:=valquat(str1);
   readtln; mats[cm][2]:=valquat(str1);spw[cm]:=valvec5(str1);
   readtln; mats[cm][3]:=valquat(str1);
 
   if cm=mc-1 then break;
   cm:=cm+1;
  end;
 end;
  
 tc:=0;
 while bp<bs do begin
  readtln;
  if copy(str1,1,8)='TEXTURES' then begin tc:=vali(decomment(copy(str1,10,length(str1)-9)));break;end;
 end;

 setlength(msh.txs,tc);
 setlength(txi,tc);
 setlength(txx,tc);
 setlength(txy,tc);
 ct:=0;
 if tc<>0 then repeat   
  readtln;
  if copy(str1,length(str1)-1,2)=' D' then str1:=copy(str1,1,length(str1)-2);
  msh.txs[ct]:=str1;

  LoadBitmap(slash_lin(txdir+msh.txs[ct]),txx[ct],txy[ct],txi[ct]);

  if ct=tc-1 then break;
  ct:=ct+1;
 until false;
 msh.txc:=tc;
  

 for i:=0 to gn-1 do begin
  cm:=msh.grp[i].col[3];
  ct:=msh.grp[i].dif.tx;   
  clt:=msh.grp[i].lth.tx;  
  cst:=msh.grp[i].nml.tx;   
  if (ct>0)and(ct<=dword(length(txi))) then begin
   msh.grp[i].dif.p:=txi[ct-1];
   msh.grp[i].dif.xs:=txx[ct-1];
   msh.grp[i].dif.ys:=txy[ct-1];    
   //msh.grp[i].dif.nam:=txs[cst-1];
  end else msh.grp[i].dif.tx:=notx;   
  if (clt>0)and(clt<=dword(length(txi))) then begin
   msh.grp[i].lth.p:=txi[clt-1];
   msh.grp[i].lth.xs:=txx[clt-1];
   msh.grp[i].lth.ys:=txy[clt-1];    
   //msh.grp[i].lth.nam:=txs[cst-1];
  end else msh.grp[i].lth.tx:=notx;  
  if (cst>0)and(cst<=dword(length(txi))) then begin
   msh.grp[i].nml.p:=txi[cst-1];
   msh.grp[i].nml.xs:=txx[cst-1];
   msh.grp[i].nml.ys:=txy[cst-1];
   //msh.grp[i].nml.nam:=txs[cst-1];
  end else msh.grp[i].nml.tx:=notx;   
  if (cm<>255)and(cm<>0)and(cm<=length(mats))then begin
   msh.grp[i].col:=tdcrgba(mats[cm-1][0].x,mats[cm-1][0].y,mats[cm-1][0].z,mats[cm-1][0].w);
   msh.grp[i].cols:=tdcrgba(mats[cm-1][2].x,mats[cm-1][2].y,mats[cm-1][2].z,mats[cm-1][2].w);
   msh.grp[i].cole:=tdcrgba(mats[cm-1][3].x,mats[cm-1][3].y,mats[cm-1][3].z,mats[cm-1][3].w);
   msh.grp[i].spow:=spw[cm-1].t;
  end else msh.grp[i].col:=tdcrgba(0.5,0.5,0.5,1);
 end;

 result:=1;
 msh.used:=true;
 msh.siz:=modv(mvv);
 freemem(buf);
end;
{$endif}
//############################################################################//    
//############################################################################//    
//############################################################################//    
procedure grlditherbay32b8(p:pointer;o,xs,ys:integer);
var c:pcrgba;
x,y:integer;
begin
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin  
  c:=pointer(intptr(p)+intptr((x+y*xs)*4));
  c[o]:=255*trunc((c[o]/255)+detab[x mod 16][y mod 16]/255);
 end;
end;
//############################################################################//    
procedure grlditherthr32b8(p:pointer;o,xs,ys:integer);
var c:pcrgba;
x,y:integer;
begin
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin  
  c:=pointer(intptr(p)+intptr((x+y*xs)*4));
  c[o]:=255*ord(c[o]>127);
 end;
end;
//############################################################################//    
procedure grlditherrnd32b8(p:pointer;o,xs,ys:integer);
var c:pcrgba;
x,y:integer;
begin
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin  
  c:=pointer(intptr(p)+intptr((x+y*xs)*4));
  c[o]:=255*ord(c[o]>rndtab[x mod 31][y mod 31]);
 end;
end;
//############################################################################//    
//############################################################################//            
procedure grldithergra32b8(p:pointer;o,xs,ys:integer);
var c:pcrgba;
op,np:integer;
x,y,x1,d:integer;
qe:integer;

procedure ptb(var a:byte;b:integer);
begin  
 if a+b<0 then a:=0 
 else if a+b>255 then a:=255
 else a:=a+b; 
end;

begin  
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin c:=pointer(intptr(p)+intptr((x+y*xs)*4));c[o]:=c[o] shr 2;end;
  
 x:=-1;
 for y:=0 to ys-1 do for x1:=0 to xs-1 do begin  
  d:=+1*ord((y mod 2)=0)-1*ord((y mod 2)=1);  
  x:=x+d;
  if x1=0 then if d=-1 then x:=xs-1 else x:=0;  
  c:=pointer(intptr(p)+intptr((x+y*xs)*4));
   
  op:=c[o];
  np:=255*ord(op>127);
  c[o]:=np;
  qe:=op-np;
        
  if(x+d<=xs-1)and(x>=-d)then ptb(pcrgba(intptr(p)+intptr(((x+d)+(y+0)*xs)*4))[o],(7*qe)shr 4);
  if y<ys-1 then begin
   if (x-d<=xs-1)and(x>=d) then ptb(pcrgba(intptr(p)+intptr(((x-d)+(y+1)*xs)*4))[o],(3*qe)shr 4);
   ptb(pcrgba(intptr(p)+intptr(((x+0)+(y+1)*xs)*4))[o],(5*qe)shr 4);
   if (x+d<=xs-1)and(x>=-d) then ptb(pcrgba(intptr(p)+intptr(((x+d)+(y+1)*xs)*4))[o],(1*qe)shr 4);
  end;   
  
 end;
end;
//############################################################################//    
//############################################################################//    
procedure grlditherfls32b8(p:pointer;o,xs,ys:integer);
var c:pcrgba;
op,np:integer;
x,y,x1,d:integer;
qe:integer;

procedure ptb(var a:byte;b:integer);
begin          
 if a+b<0 then a:=0 
 else if a+b>255 then a:=255
 else a:=a+b;   
end;

begin
 x:=-1;    
 for y:=0 to ys-1 do for x1:=0 to xs-1 do begin  
  d:=+1*ord((y mod 2)=0)-1*ord((y mod 2)=1);  
  x:=x+d;
  if x1=0 then if d=-1 then x:=xs-1 else x:=0;  
  c:=pointer(intptr(p)+intptr((x+y*xs)*4));
   
  op:=c[o];
  np:=255*ord(op>127);
  c[o]:=np;
  qe:=op-np;
          
  if(x+d<=xs-1)and(x>=-d)then ptb(pcrgba(intptr(p)+intptr(((x+d)+(y+0)*xs)*4))[o],(7*qe)div 16);
  if y<ys-1 then begin
   if (x-d<=xs-1)and(x>=d) then ptb(pcrgba(intptr(p)+intptr(((x-d)+(y+1)*xs)*4))[o],(3*qe)div 16);
   ptb(pcrgba(intptr(p)+intptr(((x+0)+(y+1)*xs)*4))[o],(5*qe)div 16);
   if (x+d<=xs-1)and(x>=-d) then ptb(pcrgba(intptr(p)+intptr(((x+d)+(y+1)*xs)*4))[o],(1*qe)div 16);
  end; 
      
 end;   
end;      
//############################################################################//
procedure smootfilter(p:pbcrgba;xs,ys:integer);
var i,x,y,o:integer;
xf:matn;
pb:pbcrgba;
f,s:double;
begin
 getmem(pb,xs*ys*4);
 move(p^,pb^,xs*ys*4);
 o:=3;s:=0;
 for i:=0 to 8 do begin xf[i]:=1;s:=s+xf[i];end;
 {
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  f:=  xf[0]*pb[(y-1+ord(y=0))*xs+(xs+x-1+(xs shr 1)*ord(y=0))mod xs][o];
  f:=f+xf[1]*pb[(y-1+ord(y=0))*xs+(x+(xs shr 1)*ord(y=0))mod xs][o]; 
  f:=f+xf[2]*pb[(y-1+ord(y=0))*xs+(xs+x+1+(xs shr 1)*ord(y=0))mod xs][o];

  f:=f+xf[3]*pb[y*xs+(xs+x-1)mod xs][o];
  f:=f+xf[4]*pb[y*xs+x][o];
  f:=f+xf[5]*pb[y*xs+(xs+x+1)mod xs][o];
  
  f:=f+xf[6]*pb[(y+1+ord(y=ys-1))*xs+(xs+x-1+(xs shr 1)*ord(y=ys-1))mod xs][o];
  f:=f+xf[7]*pb[(y+1+ord(y=ys-1))*xs+(x+(xs shr 1)*ord(y=ys-1))mod xs][o];
  f:=f+xf[8]*pb[(y+1+ord(y=ys-1))*xs+(xs+x+1+(xs shr 1)*ord(y=ys-1))mod xs][o];

  p[y*xs+x][o]:=round(f/s);
 end; 
  } 
 for y:=1 to ys-2 do for x:=1 to xs-2 do begin
  f:=  xf[0]*pb[(y-1)*xs+x-1][o];
  f:=f+xf[1]*pb[(y-1)*xs+x][o]; 
  f:=f+xf[2]*pb[(y-1)*xs+x+1][o];

  f:=f+xf[3]*pb[y*xs+x-1][o];
  f:=f+xf[4]*pb[y*xs+x][o];
  f:=f+xf[5]*pb[y*xs+x+1][o];
  
  f:=f+xf[6]*pb[(y+1)*xs+x-1][o];
  f:=f+xf[7]*pb[(y+1)*xs+x][o];
  f:=f+xf[8]*pb[(y+1)*xs+x+1][o];

  p[y*xs+x][o]:=round(f/s);
 end;  
end;
//############################################################################//    
//############################################################################//    
begin
 makerndt;
end.
//############################################################################//    