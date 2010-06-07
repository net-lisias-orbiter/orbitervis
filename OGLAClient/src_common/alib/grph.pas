//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: Graph Main
//############################################################################//
unit grph;
{$ifdef fpc}{$mode delphi}{$endif}
{$ifdef ape3}{$define bgr}{$endif}
interface 
uses asys,maths;
type TShiftState=set of(ssShift,sslShift,ssrShift,ssAlt,sslAlt,ssrAlt,ssCtrl,sslCtrl,ssrCtrl,ssLeft,ssRight,ssMiddle,ssDouble,ssup,ssdown);
//############################################################################//
const
glgr_evclose=1;
glgr_evresize=2;  
glgr_evkeyup=3;
glgr_evkeydwn=4;   
glgr_evmsmove=5;  
glgr_evmsup=6;
glgr_evmsdwn=7;
//############################################################################//
type
crgb=array[0..2]of byte;
pcrgb=^crgb;                       
bcrgb=array[0..1000000]of crgb;  
pbcrgb=^bcrgb; 

crgba=array[0..3]of byte;
pcrgba=^crgba;             
crgbad=array[0..3]of single;
pcrgbad=^crgba;
acrgba=array of crgba;
bcrgba=array[0..1000000]of crgba;
pacrgba=^acrgba;
pbcrgba=^bcrgba; 

pallette=array[0..255]of crgba;
ppallette=^pallette;
pallette3=array[0..255]of crgb;     
ppallette3=^pallette3;
//############################################################################//
const  
gclz:crgb=(0,0,0);   
gclaz:crgba=(0,0,0,0);   
{$ifndef BGR}
gclwhite:crgba=(255,255,255,255);     
gclblack:crgba=(0,0,0,255);
gclred:crgba=(255,0,0,255);
gclgreen:crgba=(0,255,0,255);
gcllightgreen:crgba=(128,255,128,255);
gcldarkgreen:crgba=(0,128,0,255);
gclblue:crgba=(0,0,255,255);       
gcllightblue:crgba=(128,128,255,255);
gclgray:crgba=(128,128,128,255);  
gcllightgray:crgba=(200,200,200,255); 
gcldarkgray:crgba=(64,64,64,255);     
gclyellow:crgba=(255,255,0,255);
gclorange:crgba=(255,128,0,255);   
gclbrown:crgba=(150,75,0,255);   
gclcyan:crgba=(0,255,255,255);  
gclmagenta:crgba=(255,0,255,255);
{$else}  
gclwhite:crgba=(255,255,255,255);     
gclblack:crgba=(0,0,0,255);
gclred:crgba=(0,0,255,255);
gclgreen:crgba=(0,255,0,255);  
gcllightgreen:crgba=(128,255,128,255);
gcldarkgreen:crgba=(0,128,0,255);
gclblue:crgba=(255,0,0,255);
gcllightblue:crgba=(255,128,128,255);
gclgray:crgba=(128,128,128,255);   
gcllightgray:crgba=(200,200,200,255);  
gcldarkgray:crgba=(64,64,64,255);   
gclyellow:crgba=(0,255,255,255);
gclorange:crgba=(0,128,255,255);
gclbrown:crgba=(0,75,150,255);  
gclcyan:crgba=(255,255,0,255);
gclmagenta:crgba=(255,0,255,255);
{$endif}

const 
notx=$FFFFFFFF;       
//############################################################################//
//############################################################################//
type
NTVERTEX=packed record
 x,y,z:single;    //position
 nx,ny,nz:single; //normal
 tu,tv:single;    //texture coordinates
end;
pNTVERTEX=^NTVERTEX;
aNTVERTEX=array[0..10000000]of NTVERTEX;
paNTVERTEX=^aNTVERTEX;
//############################################################################//
pntyp=record
 nml:mvec;
 pos:mvec; 
 tng:mvec;
 tx,tx2:mvec2;
 cold:crgbad;
end;
ppntyp=^pntyp;     
aopntyp=array of pntyp;    
paopntyp=^aopntyp; 

textyp=record
 tx,xs,ys:cardinal;
 p:pointer;
 nam:string[64];
 uv:integer;
end;
ptextyp=^textyp; 
      
bpntyp=array[0..100000]of pntyp; 
pbpntyp=^bpntyp;

typmshgrp=record
 //Orbiter:
 //Vessel      0x00000001  Do not use this group to render ground shadows
 //Vessel      0x00000002  Do not render this group
 //Vessel      0x00000004  Do not apply lighting when rendering this group
 //Vessel      0x00000008  Texture blending directive: additive with background
 flags:dword;
 
 nam:string;
 pnts:aopntyp;
 trng:aointeger;
 typ:integer;
 
 trngpl:aoquat;
 trngplv:aoboolean; 
 trngpln:aointeger;
 trngpls:aosingle;
 plcl:boolean;

 shava:array of mvec;
 shacnt:integer;
 
 dif,nml,lth:textyp;
 
 boundbox:array[0..1]of vec;
 center:vec;
 
 col,cole,cols:crgba;  
 spow:single;
 siz:double;
 static,vboreset:boolean;
 tag:integer;
 orbTexIdx,orbMtrlIdx,xmit_tx:dword;
end;
ptypmshgrp=^typmshgrp;
typmsh=record
 used:boolean;
 fnam,txdir:string;  
 txs:array of string;
 flg:byte;
 grc:integer;
 grp:array of typmshgrp;
 txc:integer;
 prlt,off:vec;
 siz:double;
 need_fin:boolean;
end;
ptypmsh=^typmsh;
//############################################################################//
mgroup_transform=record
 tp:integer;
 mesh,ngrp:dword;
 grp:pdword;

 ref,axis,scale,shift:vec;
 angle:single;
end;
pmgroup_transform=^mgroup_transform;
//############################################################################//
//############################################################################//
shortvid8frmtyp=record
 tp:integer;
 frm:pbytea;
 //fdl:
end;
pshortvid8frmtyp=shortvid8frmtyp;
shortvid8typ=record
 used:boolean;
 frmc,dtms:integer;
 wid,hei:integer;
 
 frms:array of shortvid8frmtyp; 
 pal:pallette3;
end;
pshortvid8typ=^shortvid8typ;

shortvid32frmtyp=record
 tp:integer;
 frm:pbcrgba;
end;
pshortvid32frmtyp=shortvid32frmtyp;
shortvid32typ=record
 used:boolean;
 frmc,dtms:integer;
 wid,hei:integer;
 
 frms:array of shortvid32frmtyp; 
end;
pshortvid32typ=^shortvid32typ;                        
//############################################################################//
//############################################################################//
type 
typspr=record
 srf:pointer;
 xp,yp,xs,ys,cx,cy,tp,bpp:integer;      
 tx:cardinal;

 ldd:boolean;
 lfn:string;
 ltyp:integer;
 lsc,lscx,lscy:integer;
end;
ptypspr=^typspr;
aptypspr=array of ptypspr;

typuspr=record
 sprc:array of typspr;
 cnt:integer;
 ex:boolean;
end;        
ptypuspr=^typuspr;

palxtyp=array[0..255]of byte;
ppalxtyp=^palxtyp;

fontinfo=packed record
 width,offset:integer;
end;
afontinfo=array[0..1000000]of fontinfo;
pafontinfo=^afontinfo;

mgfont=packed record
 num,height,spacing:integer;
 info:pafontinfo;
 data:pbytea;
end;
pmgfont=^mgfont;    
//############################################################################//
startyp=packed record
 destr:dword;
 mag:dword;
 gps:array of mvec;
 col,pcol:array of crgbad;   
 idx:array of word;
 cnt:integer;
 pick:boolean;
 cgps:vec;
 rad:double;
end;
pstartyp=^startyp;     
aopstartyp=array of pstartyp;    
paopstartyp=^aopstartyp;   
//############################################################################//
var
gfsx,gfsy,gfx,gfy:integer;  
scrx,scry,scrbit,scrbitbin:integer;
fnt:array of ptypspr;   
mgfnt:array of mgfont;                   
thepal:pallette3;  
//############################################################################//
//############################################################################//
var ildmsg:procedure(s,c:string;ld:boolean);
//############################################################################//
function tcrgb(r,g,b:byte):crgb;
function tcrgba(r,g,b,a:byte):crgba; 
function tdcrgba(r,g,b,a:single):crgba;
function tvcrgba(v:vec):crgba;
function crgba2mquat(c:crgba):mquat;
function tvcrgbad(v:vec):crgbad;
function tcrgbav(v:crgba):vec;  
function tcrgbaq(v:crgba):quat;   
function tcrgbad(r,g,b,a:single):crgbad;
function dw2crgb(a:longword):crgb;
function dw2crgba(a:longword):crgba;
function crgb2dw(a:crgb):longword;
function crgba2dw(a:crgba):longword;  
function nata(a:crgb):crgba;  

function mercl(c1,c2:crgba;r:single):crgba;
function subcl(c1,c2:crgba):crgba;
function addcl(c1,c2:crgba):crgba;
function nmulcl(c1:crgba;n:single):crgba;
function subcld(c1,c2:crgba):crgbad;
function addcld(c1,c2:crgba):crgbad;
function nmulcld(c1:crgba;n:single):crgbad;

function crgbaccmp(a,b:crgba):boolean;   
function td2crgba(v:crgbad):crgba;  
function tcrgba2d(v:crgba):crgbad;

function bchcrgba(c:boolean;t,f:crgba):crgba;
                                      
function tpntyps(p,n:vec;tx0,ty0:single):pntyp;
                                      
procedure mkcln_grptex(t:ptextyp);
procedure mkcln_msh(mt:ptypmsh);     
procedure mkcln_mshgrp(g:ptypmshgrp);               
procedure cln_mshgrp(g:ptypmshgrp);
procedure copy_msh(var mt,mf:typmsh);     
procedure copy_msh_grp(var gt,gf:typmshgrp);
//############################################################################//
implementation
//############################################################################//
function crgbaccmp(a,b:crgba):boolean;
begin
 result:=(a[0]=b[0])and(a[1]=b[1])and(a[2]=b[2]);
end;
function tcrgb(r,g,b:byte):crgb;
begin     
{$ifndef BGR}
 result[0]:=r;
 result[1]:=g;
 result[2]:=b;    
{$else}  
 result[2]:=r;
 result[1]:=g;
 result[0]:=b;
{$endif}
end;
function tcrgba(r,g,b,a:byte):crgba;
begin     
{$ifndef BGR}
 result[0]:=r;
 result[1]:=g;
 result[2]:=b;
 result[3]:=a;    
{$else}  
 result[2]:=r;
 result[1]:=g;
 result[0]:=b;
 result[3]:=a;  
{$endif}
end;
function tcrgbad(r,g,b,a:single):crgbad;
begin     
{$ifndef BGR}
 result[0]:=r;
 result[1]:=g;
 result[2]:=b;
 result[3]:=a;    
{$else}  
 result[2]:=r;
 result[1]:=g;
 result[0]:=b;
 result[3]:=a;
{$endif}
end;
function tdcrgba(r,g,b,a:single):crgba;
begin      
{$ifndef BGR}
 result[0]:=round(r*255);
 result[1]:=round(g*255);
 result[2]:=round(b*255);
 result[3]:=round(a*255);   
{$else}   
 result[2]:=round(r*255);
 result[1]:=round(g*255);
 result[0]:=round(b*255);
 result[3]:=round(a*255);  
{$endif}
end;    
function td2crgba(v:crgbad):crgba;
begin      
 result[0]:=round(v[0]*255);
 result[1]:=round(v[1]*255);
 result[2]:=round(v[2]*255);
 result[3]:=round(v[3]*255); 
end;    
function crgba2mquat(c:crgba):mquat;   
begin      
 result.x:=c[0]/255;
 result.y:=c[1]/255;
 result.z:=c[2]/255;
 result.w:=c[3]/255; 
end; 
function tcrgba2d(v:crgba):crgbad;
begin      
 result[0]:=v[0]/255;
 result[1]:=v[1]/255;
 result[2]:=v[2]/255;
 result[3]:=v[3]/255; 
end; 
function tvcrgba(v:vec):crgba;   
begin    
 if v.x>1 then v.x:=1;
 if v.y>1 then v.y:=1;
 if v.z>1 then v.z:=1; 
 if v.x<0 then v.x:=0;
 if v.y<0 then v.y:=0;
 if v.z<0 then v.z:=0;  
{$ifndef BGR}
 result[0]:=round(v.x*255);
 result[1]:=round(v.y*255);
 result[2]:=round(v.z*255);
 result[3]:=255;           
{$else}  
 result[2]:=round(v.x*255);
 result[1]:=round(v.y*255);
 result[0]:=round(v.z*255); 
 result[3]:=255;           
{$endif}
end;  
function tvcrgbad(v:vec):crgbad;   
begin      
{$ifndef BGR}
 result[0]:=v.x;
 result[1]:=v.y;
 result[2]:=v.z;
 result[3]:=255;           
{$else}  
 result[2]:=v.x;
 result[1]:=v.y;
 result[0]:=v.z; 
 result[3]:=255;           
{$endif}
end;   
function tcrgbav(v:crgba):vec;
begin      
{$ifndef BGR}
 result.x:=v[0]/255;
 result.y:=v[1]/255;
 result.z:=v[2]/255;
{$else}  
 result.x:=v[2]/255;
 result.y:=v[1]/255;
 result.z:=v[0]/255;         
{$endif}
end;  
function tcrgbaq(v:crgba):quat;
begin      
{$ifndef BGR}
 result.x:=v[0]/255;
 result.z:=v[2]/255;
{$else}  
 result.x:=v[2]/255;
 result.z:=v[0]/255;         
{$endif}       
 result.y:=v[1]/255; 
 result.w:=v[3]/255;
end;   

function nata(a:crgb):crgba;
begin     
 result[0]:=a[0];
 result[1]:=a[1];
 result[2]:=a[2];
 result[3]:=255;  
end;

function mercl(c1,c2:crgba;r:single):crgba;
var e:single;
begin
 e:=(c1[0]/255)*r+(c2[0]/255)*(1-r);if e>1 then e:=1;result[0]:=round(e*255);
 e:=(c1[1]/255)*r+(c2[1]/255)*(1-r);if e>1 then e:=1;result[1]:=round(e*255);
 e:=(c1[2]/255)*r+(c2[2]/255)*(1-r);if e>1 then e:=1;result[2]:=round(e*255);
 result[3]:=255;
end;    
function subcl(c1,c2:crgba):crgba;
begin
 result[0]:=(c1[0]-c2[0]);
 result[1]:=(c1[1]-c2[1]);
 result[2]:=(c1[2]-c2[2]);
 result[3]:=255;
end;
function addcl(c1,c2:crgba):crgba;
begin
 result[0]:=(c1[0]+c2[0]);
 result[1]:=(c1[1]+c2[1]);
 result[2]:=(c1[2]+c2[2]);
 result[3]:=255;
end;
function nmulcl(c1:crgba;n:single):crgba;
begin
 result[0]:=round(c1[0]*n);
 result[1]:=round(c1[1]*n);
 result[2]:=round(c1[2]*n);
 result[3]:=255;
end;     
function subcld(c1,c2:crgba):crgbad;
begin
 result[0]:=(c1[0]-c2[0])/255;
 result[1]:=(c1[1]-c2[1])/255;
 result[2]:=(c1[2]-c2[2])/255;
 result[3]:=255;
end;
function addcld(c1,c2:crgba):crgbad;
begin
 result[0]:=(c1[0]+c2[0])/255;
 result[1]:=(c1[1]+c2[1])/255;
 result[2]:=(c1[2]+c2[2])/255;
 result[3]:=1;
end;
function nmulcld(c1:crgba;n:single):crgbad;
begin
 result[0]:=c1[0]*n/255;
 result[1]:=c1[1]*n/255;
 result[2]:=c1[2]*n/255;
 result[3]:=1;
end; 


function dw2crgb(a:longword):crgb; begin end;
function dw2crgba(a:longword):crgba; begin end;
function crgb2dw(a:crgb):longword; begin result:=0; end;
function crgba2dw(a:crgba):longword; begin result:=0; end;
function bchcrgba(c:boolean;t,f:crgba):crgba;begin if c then result:=t else result:=f;end;


function tpntyps(p,n:vec;tx0,ty0:single):pntyp;
begin
 result.pos:=v2m(p);
 result.nml:=v2m(n);
 if tx0>=1 then tx0:=0.998;
 if ty0>=1 then ty0:=0.998;
 if tx0<=0 then tx0:=0.002;
 if ty0<=0 then ty0:=0.002;
 result.tx.x:=tx0;
 result.tx.y:=ty0;
 result.cold:=tcrgbad(255,255,255,255);
end;
//############################################################################//
procedure mkcln_grptex(t:ptextyp);
begin
 t.tx:=notx;
 t.p:=nil;
 t.uv:=0;
end;      
//############################################################################//
procedure mkcln_msh(mt:ptypmsh);
begin
 mt.used:=true;
 mt.flg:=0;
 mt.siz:=0;
 mt.txc:=0;
 mt.off:=zvec;
 mt.prlt:=zvec;
 mt.grc:=0;
 setlength(mt.grp,mt.grc);
end;  
//############################################################################//
procedure mkcln_mshgrp(g:ptypmshgrp);
begin
 g.col:=gclwhite;  
 g.cole:=gclblack;  
 g.cols:=gclaz;       
 g.spow:=0;    
 mkcln_grptex(@g.dif);
 mkcln_grptex(@g.nml);
 mkcln_grptex(@g.lth);
 g.flags:=0;
 g.siz:=0;
 g.center:=zvec;
 g.vboreset:=false;
 g.static:=false;
end;
//############################################################################//
procedure cln_mshgrp(g:ptypmshgrp);
begin
 setlength(g.trng,0);
 setlength(g.pnts,0);
 mkcln_mshgrp(g);
end;   
//############################################################################//  
procedure nul_ildmsg(s,c:string;ld:boolean);
begin

end;   
//############################################################################//  
procedure copy_msh_grp(var gt,gf:typmshgrp);
var j:integer;
begin
 gt.nam:=gf.nam; 

 setlength(gt.pnts,length(gf.pnts));
 for j:=0 to length(gf.pnts)-1 do gt.pnts[j]:=gf.pnts[j];
 setlength(gt.trng,length(gf.trng));   
 for j:=0 to length(gf.trng)-1 do gt.trng[j]:=gf.trng[j];
 
 gt.dif:=gf.dif;
 gt.nml:=gf.nml;
 gt.lth:=gf.lth;  
 gt.flags:=gf.flags;
 
 gt.col:=gf.col;
 gt.cole:=gf.cole;
 gt.cols:=gf.cols;
 gt.spow:=gf.spow;
 gt.static:=gf.static;
 gt.tag:=gf.tag;
 gt.orbTexIdx:=gf.orbTexIdx;
end;   
//############################################################################//
procedure copy_msh(var mt,mf:typmsh);
var i:integer;
begin
 mt.used:=mf.used;
 mt.off:=mf.off;
 if not mf.used then exit;
 mt.flg:=mf.flg;mt.siz:=mf.siz;mt.txc:=mf.txc;mt.prlt:=mf.prlt;mt.grc:=mf.grc;
 setlength(mt.grp,mt.grc);
 for i:=0 to mt.grc-1 do copy_msh_grp(mt.grp[i],mf.grp[i]); 
end;    
//############################################################################//
begin
 ildmsg:=nul_ildmsg;
end.
//############################################################################//

 
