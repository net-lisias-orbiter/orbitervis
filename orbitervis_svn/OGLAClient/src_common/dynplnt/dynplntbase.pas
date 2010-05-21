//############################################################################//
// Orulex: Dynamic planet definitions
// Released under GNU General Public License
// Made in 2006-2010 by Artyom Litvinovich
//############################################################################//
unit dynplntbase;
{$ifdef fpc}{$mode delphi}{$endif}
interface
uses {$ifdef win32}windows,{$endif}sysutils,asys,maths,grph,polis,dds,noir,noise;
//############################################################################//  
const 
BUCK_CNT=4000;
PLT_RES=9;
PLT_ETEX_RES=512;
rplspcount=(PLT_RES-1)*(PLT_RES-1)*2*3;
blkpcount=(PLT_RES-1)*(PLT_RES-1)*2;

TILEX_9_CNT=1456;
TILEX_10_CNT=2523;
TILEX_11_CNT=11179;

MAQ_SIZ=40000;

QRC_MAG=$94834756;
DRLS_MAG=$23673321;
TEX_MAG=$5754316;
BLK_MAG=$FC7594FE;
//############################################################################//  
type
pqrtree=^qrtree;
pqrc=^qrc;     
pdrlstyp=^drlstyp;
qrc=record
 mag:dword;
 i:pqrtree;
 p:integer;
 u:boolean;
 nx,px:pqrc;
end;    
apqrc=array[0..BUCK_CNT]of pqrc;

drlstyp=record  
 mag:dword;
 tr:pqrtree;
 pr,nx:pdrlstyp;
end;

cratertyp=record
 pos:vec;
 lat,lon:double;
 siz,siz2,h:double;
 a,b,c,d:double;
end;

srbtyp=record
 used,ch:boolean;
 name:string;
 pos:vec;
 posl:vec2;
 r,ro,r2,h:double;
 t:integer;
end;

hmaptyp=record
 used:boolean;
 lth,ltl,lnh,lnl,sln,slt:double;
 scl:double;
 w,h,op:integer;
 dat:array of smallint;
 nam:string;
 tp,flg:integer;
end; 
phmaptyp=^hmaptyp;
cmaptyp=record
 used,ck:boolean;
 lth,ltl,lnh,lnl,sln,slt:double;
 w,h,op:integer;
 dat:array of crgba;
 nam:string;
 tp,pri:integer;
end; 
pcmaptyp=^cmaptyp;
flattyp=record
 used:boolean;
 lth,ltl,lnh,lnl:double;
 nam:string;
end; 
pflattyp=^flattyp;

textyp=record     
 mag:dword;
 used,ld,fin:boolean;
 tx:pbcrgba;  
 gltx,gletx:dword;
 id,vn:vec;
 gy,uc,lv:integer;
end;
ptextyp=^textyp;

qrtree=record 
 mag:dword;
 used,fin:boolean;
 bs:pqrtree;
 rcn:array[1..4]of vec;
 cnt,rcnt,dir:vec;
 mshd,msh,msh_base:array[0..PLT_RES*PLT_RES-1]of NTVERTEX;
 mshr:array[0..PLT_RES*PLT_RES-1]of boolean;
 
 refpts,nrefpts:array[0..rplspcount-1]of smallint;

 dxx,dyx,dzx,dxy,dyy,dzy,u,f:double;
 dxxt,dyxt,dzxt,dxyt,dyyt,dzyt,ut:double;
 txo,tyo:double;  
 c:array[1..4]of pqrtree;
 vn:vec;
 
 vbo:cardinal;
 id:vec;
 siz,lvc:double;
 lv,qrt,pris,prim,prit,q:integer; 
 own_tex,draw_tex:ptextyp;  
 mqp,sqp,tqp:pqrc; 
 dr,tr:pdrlstyp;   
 n:array[1..4]of pqrtree;

 cld,crd,crdf:boolean;

 vrr:double;
 dm:vec;
end;
 
tilextyp=record
 used,ld:boolean;
 lv:double;
 lth,lnh,ltl,lnl,sln,slt:double;
 dat:array of crgba;
end;
      
proampl=^roampl;
pmaqrec=^maqrec;
maqrec=record
 tp:integer;
 rt:pqrtree;cn:integer;cnt,dir:vec;qrt,lv,q:integer;
end;
roampl=record 
 used,lded,predone:boolean;
 firstrun,basck:boolean;
 id:intptr;

 noi:noirec;
 
 name:string;
 radius,altitude_limit,blend_limit:double;
 bels,mtex:boolean;
 specpow,ospecpow:double;
 speccol,ospeccol:vec;
 tfuncs,cfuncs:string;
 tfuncc,cfuncc:codt;
 levlimit,cratercnt,refidx:integer;
 aoff,texture_range_factor,noilv,sbcrlev:double;
 level_of_global_heightmap,glhmop,glhmtr:integer;
 
 tex_cnt:integer;
 seed,deftxn,terid:integer;
 
 ccampos,campos:vec;
 xa,ya:double;
 tm:mat;
 lp:vec;
 
 main_queue_time_slice,priorities_time_slice,balancing_time_slice,textures_time_slice:int64;
 tottim,stat_main_queue,stat_priorities,stat_balancing,fnctim,fnccltim:int64;
 blcount,polycount,drpolycount,maxpolycount,maxblcount:integer;
 
 texture_res:integer;
 fgeth:function(cp:proampl;a:vec;var b:double):vec;
 fgetc:function(cp:proampl;a:vec;lv:double;lvl:integer):crgba;
 fgetv:function(cp:proampl;a:vec):crgba;

 clo:array[0..2]of double;
 cfo:array[0..10]of double;
 cfi:array[0..10]of dword;
 hfo:array[0..10]of double;
 hfi:array[0..10]of dword;
 curvs:array[0..9]of adouble;
 grads:array[0..10]of array of noirgradpoint;
 cld_col:crgba;
 cld_prc:double;
 maxgenlv,maxcloudgenlv:integer;
  
 maq:array[0..MAQ_SIZ-1]of maqrec;
 maqc,maqt,maqs:integer;
 qrs:array[0..5]of pqrtree;
 sq,mq,tq:apqrc;
 sqm,mqm,tqm:pqrc;
 tqmi:integer;
 drst,trst,lsrtu:pdrlstyp;

 
 srbs:array of srbtyp;
 craters:array of cratertyp;
 cmap:array of cmaptyp;
 hmap:array of hmaptyp;
 flat:array of flattyp;
 bhmap:hmaptyp;

 tilexspc:array of TILEFILESPEC;
 tilex:array of tilextyp;
 tlnum:integer;
 tilexfn:string;

 texex,texnd,texture_gen_order:integer;
 prtex:array of ptextyp;
 txw,txh,txs:array of integer;
 txc,txhf:integer;
 tx:array of array of crgba;
 
 texdir,hmapdir:string;
end;

typocfg=record
 hmapdir,texdir,cfgdir,bcfgdir:string; 
 maxpolycount,textures_time_slice,balancing_time_slice,main_queue_time_slice,priorities_time_slice,levlimit,global_heightmap_limit,refidx,texture_res:integer;
 multithreaded:boolean;
 texture_gen_order:integer;
 texture_range_factor:double;
end;
//############################################################################//  
var
rplspoints:array[0..rplspcount-1]of smallint;

tthmx:mutex_typ;
 
ocfg:typocfg;  

etx:array[0..3]of cardinal;
dt1,dt21,dt22,dt23:integer;   
//############################################################################//  
apln:proampl=nil;      
imakepln:procedure(cp:proampl;nam:string;rad:double);
        
orutes,oruclr:boolean;
//cfgnf:boolean;

tthhd:integer;
//tthid:intptr;  
orulexlog_name:string='orulex.log';
//############################################################################//  
function  trims(s:string;n:integer):string;                   
procedure dp_thr_term;
//############################################################################//  
implementation 
//############################################################################//
function trims(s:string;n:integer):string;
begin
 result:=s;
 while length(result)<n do result:=result+' ';
end;    
//############################################################################//                       
procedure dp_thr_term;
begin
 if ocfg.multithreaded then begin
  oruclr:=true;
  while oruclr do sleep(0);
  apln:=nil;
  orutes:=true;
 end;     
end;
//############################################################################//
begin       
 ocfg.multithreaded:=false;
end.
//############################################################################//  

