//############################################################################// 
// AlgorLib: Math 
// Made in 2002-2010 by Artyom Litvinovich
//############################################################################// 
{$ifdef FPC}{$MODE delphi}{$endif}
unit maths;
interface
uses math,asys;

const 
Gconst:double=6.67259e-11;
le:double= 9460800000000000;
lef:double=946080000;
lec:double=0.0000001;
eps:double=0.00001;
au :double=1.49597870691e11;
parsec:double=3.0858e16;

half_pi=pi/2;
sqrt2=1.4142135623730950488016887242097;
trad=1/180*pi;
                         
type vec2 =record x,y:double;end;
type mvec2=record x,y:single;end; 
type ivec2=record x,y:integer;end; 
type vec  =record x,y,z:double;end;
type mvec =record x,y,z:single;end;  
type ivec =record x,y,z:integer;end;
type quat =record x,y,z,w:double;end;
type mquat=record x,y,z,w:single;end;
type iquat=record x,y,z,w:integer;end;
type vec5 =record x,y,z,w,t:double;end;
type mvec5=record x,y,z,w,t:single;end;
type ivec5=record x,y,z,w,t:integer;end;
pvec2=^vec2;pmvec2=^mvec2;pivec2=^ivec2;
pvec =^vec; pmvec= ^mvec; pivec= ^ivec;
pquat=^quat;pmquat=^mquat;piquat=^iquat;  
pvec5=^vec5;pmvec5=^mvec5;pivec5=^ivec5; 
vec2ar=array[0..100000]of vec2;pvec2ar=^vec2ar;
ivec2ar=array[0..100000]of ivec2;pivec2ar=^ivec2ar;
vecar=array[0..100000]of vec;pvecar=^vecar;
mvecar=array[0..100000]of mvec;pmvecar=^mvecar;
mquatar=array[0..100000]of mquat;pmquatar=^mquatar;
aovec2 =array of vec2;
aomvec2=array of mvec2;
aoivec2=array of ivec2;
aovec  =array of vec;
aomvec =array of mvec;
aoivec =array of ivec;
aoquat =array of quat;
aomquat=array of mquat;   
aoiquat=array of iquat;   
aovec5 =array of vec5;
aomvec5=array of mvec5;
aoivec5=array of ivec5;

vec2a =array[0..1] of double;
mvec2a=array[0..1] of single;
veca  =array[0..2] of double;
mveca =array[0..2] of single;
quata =array[0..3] of double; 
mquata=array[0..3] of single; 
vec5a =array[0..4] of double;
mvec5a=array[0..4] of single;
pveca=^veca;
                   
mat2 =array[0..1] of vec2;
mat2a=array[0..1] of vec2a;
mat  =array[0..2] of vec;
mata =array[0..2] of veca;
mmatq =array[0..3] of mquat;
matq =array[0..3] of quat;
matqa=array[0..3] of quata;
mat5 =array[0..4] of vec5;
mat5a=array[0..4] of vec5a;
pmat2=^mat2;pmat2a=^mat2a;
pmat =^mat; pmata =^mata;
pmatq=^matq;pmatqa=^matqa;  
pmat5=^mat5;pmat5a=^mat5a;  
matn =array[0..8] of double;


type arrdbl=array of double;

const
zvec2:vec2=(x:0;y:0);
zvec:vec=(x:0;y:0;z:0);
evec:vec=(x:1;y:1;z:1);
equat:quat=(x:0;y:0;z:0;w:1);
zmvec:mvec=(x:0;y:0;z:0);
emvec:mvec=(x:1;y:1;z:1);

//####################################################################################//
//##################################### General ######################################//
//####################################################################################// 
function inbox(p,bh,bl:vec):boolean;  
function incube(p,b:vec;s:double):boolean;
function nbool(b:boolean):integer;  
function zchk(n:double):double;{$ifndef ape3}{$ifdef FPC}inline;{$endif}{$endif}
procedure swapd(var a,b:double);
procedure swapi(var a,b:integer);
function max2(a,b:double):double;
function max2i(a,b:integer):integer;
function min2(a,b:double):double;   
function min2i(a,b:integer):integer;
function max3(a,b,c:double):double; 
function max3i(a,b,c:integer):integer;
function min3(a,b,c:double):double;
function min3i(a,b,c:integer):integer;
function min6(a,b,c,d,e,f:double):double;
function min6n(a,b,c,d,e,f:double):integer;
function deg2rad(dg:double):double;
function hitrunc(par:double):integer;
function inrect(x,y,x1,y1,x2,y2:integer):boolean;     
function inrects(x,y,x1,y1,xs,ys:integer):boolean;
function getrtang(pmx,pmy,wx,wy:double):double;
function pow(a,x:double):double;      
function is_pot(x:integer):boolean;
function upround_pot(x:integer):integer;
function powi(a,x:double):integer;
function sgn(a:double):integer;
function sgna(a:integer):integer;
function arctan2(y,x:real):real;
function arctan21(sy,cy:real):real;
function angnmr(ang:double):double;
function cntfrac(v:double):dword;
//####################################################################################//
//###################################### Vector ######################################//
//####################################################################################//   
function tivec2(x,y:integer):ivec2;
function tivec (x,y,z:integer):ivec;

function tvec2(x,y:double):vec2;
function tvec (x,y,z:double):vec;
function tquat(x,y,z,w:double):quat;    
function tvec5(x,y,z,w,t:double):vec5;     
function tvec2a(x,y:double):vec2a;    
function tveca (x,y,z:double):veca;    
function tquata(x,y,z,w:double):quata;    
function tvec5a(x,y,z,w,t:double):vec5a;   
function tmvec2(x,y:double):mvec2;    
function tmvec (x,y,z:double):mvec;    
function tmquat(x,y,z,w:double):mquat;    
function tmvec5(x,y,z,w,t:double):mvec5;     
function tmvec2a(x,y:double):mvec2a;    
function tmveca (x,y,z:double):mveca;    
function tmquata(x,y,z,w:double):mquata;    
function tmvec5a(x,y,z,w,t:double):mvec5a;   
  
function v2m(v:vec2):mvec2;overload; 
function v2m(v:vec ):mvec ;overload; 
function v2m(v:quat):mquat;overload; 
function v2m(v:vec5):mvec5;overload;  
function m2v(v:mvec2):vec2;overload; 
function m2v(v:mvec ):vec ;overload; 
function m2v(v:mquat):quat;overload; 
function m2v(v:mvec5):vec5;overload;   
     
function v4v3(v:quat):vec;  
function v3v4(v:vec;w:double):quat;

function modv (v:vec2):double;overload;
function modv (v:vec ):double;overload;
function modv (v:quat):double;overload;
function modv (v:vec5):double;overload;  
function modv (v:mvec2):double;overload;
function modv (v:mvec ):double;overload;
function modv (v:mquat):double;overload;
function modv (v:mvec5):double;overload;
function modvs(v:vec2):double;overload;
function modvs(v:vec ):double;overload;
function modvs(v:quat):double;overload;
function modvs(v:vec5):double;overload;
function modvs(v:mvec2):double;overload;
function modvs(v:mvec ):double;overload;
function modvs(v:mquat):double;overload;
function modvs(v:mvec5):double;overload;
function nrvec(v:vec2):vec2;overload;
function nrvec(v:vec ):vec ;overload;
function nrvec(v:quat):quat;overload;
function nrvec(v:vec5):vec5;overload;
function nrvec(v:mvec2):mvec2;overload;
function nrvec(v:mvec ):mvec ;overload;
function nrvec(v:mquat):mquat;overload;
function nrvec(v:mvec5):mvec5;overload;

function vcmp (v1,v2:vec2):boolean;overload;
function vcmp (v1,v2:vec ):boolean;overload;
function vcmp (v1,v2:quat):boolean;overload;
function vcmp (v1,v2:vec5):boolean;overload;   
function vcmp (v1,v2:mvec ):boolean;overload;
function vdst (v1,v2:vec2):double;overload;
function vdst (v1,v2:vec ):double;overload;
function vdst (v1,v2:quat):double;overload;
function vdst (v1,v2:vec5):double;overload;
function vdsts(v1,v2:vec2):double;overload;
function vdsts(v1,v2:vec ):double;overload;
function vdsts(v1,v2:quat):double;overload;
function vdsts(v1,v2:vec5):double;overload;  
function vdsts(v1,v2:mvec ):double;overload;
function vcollin(v1,v2,v3:vec):boolean;overload;
function vcollin(v1,v2,v3:mvec):boolean;overload;
function vcoplan(v1,v2,v3,v4:vec):boolean;overload;
function vcoplan(v1,v2,v3,v4:mvec):boolean;overload;
function vmid2(v1,v2:vec2):vec2;overload;
function vmid2(v1,v2:vec ):vec ;overload;
function vmid2(v1,v2:quat):quat;overload;
function vmid2(v1,v2:vec5):vec5;overload;
function vmid3(v1,v2,v3:vec2):vec2;overload;
function vmid3(v1,v2,v3:vec ):vec ;overload;
function vmid3(v1,v2,v3:quat):quat;overload;
function vmid3(v1,v2,v3:vec5):vec5;overload;
function vmid4(v1,v2,v3,v4:vec2):vec2;overload;
function vmid4(v1,v2,v3,v4:vec ):vec ;overload;
function vmid4(v1,v2,v3,v4:quat):quat;overload;
function vmid4(v1,v2,v3,v4:vec5):vec5;overload;
function vmid5(v1,v2,v3,v4,v5:vec2):vec2;overload;
function vmid5(v1,v2,v3,v4,v5:vec ):vec ;overload;
function vmid5(v1,v2,v3,v4,v5:quat):quat;overload;
function vmid5(v1,v2,v3,v4,v5:vec5):vec5;overload;

//function vmulv(v1,v2:vec2):vec2;overload;
function vmulv(v1,v2:vec ):vec ;overload;
function vmulv(v1,v2:quat):quat;overload;
//function vmulv(v1,v2:vec5):vec5;overload;
//function vmulv(v1,v2:mvec2):mvec2;overload;
function vmulv(v1,v2:mvec ):mvec ;overload;
function vmulv(v1,v2:mquat):mquat;overload;
//function vmulv(v1,v2:mvec5):mvec5;overload;
function smulv(v1,v2:vec2):double;overload;
function smulv(v1,v2:vec ):double;overload;
function smulv(v1,v2:quat):double;overload;
function smulv(v1,v2:vec5):double;overload;
function smulv(v1,v2:mvec2):double;overload;
function smulv(v1,v2:mvec ):double;overload;
function smulv(v1,v2:mquat):double;overload;
function smulv(v1,v2:mvec5):double;overload;
function nmulv(v:vec2;a:double):vec2;overload;
function nmulv(v:vec ;a:double):vec ;overload;
function nmulv(v:quat;a:double):quat;overload;
function nmulv(v:vec5;a:double):vec5;overload;
function nmulv(v:mvec2;a:double):mvec2;overload;
function nmulv(v:mvec ;a:double):mvec ;overload;
function nmulv(v:mquat;a:double):mquat;overload;
function nmulv(v:mvec5;a:double):mvec5;overload;
function addv (v1,v2:vec2):vec2;overload;
function addv (v1,v2:vec ):vec ;overload;
function addv (v1,v2:quat):quat;overload;
function addv (v1,v2:vec5):vec5;overload;
function addv (v1,v2:mvec2):mvec2;overload;
function addv (v1,v2:mvec ):mvec ;overload;
function addv (v1,v2:mquat):mquat;overload;
function addv (v1,v2:mvec5):mvec5;overload;
function subv (v1,v2:vec2):vec2;overload;
function subv (v1,v2:vec ):vec ;overload;
function subv (v1,v2:quat):quat;overload;
function subv (v1,v2:vec5):vec5;overload;
function subv (v1,v2:mvec2):mvec2;overload;
function subv (v1,v2:mvec ):mvec ;overload;
function subv (v1,v2:mquat):mquat;overload;
function subv (v1,v2:mvec5):mvec5;overload;


function subv (v1,v2:ivec ):ivec ;overload; 
function vmulv(v1,v2:ivec ):ivec ;overload; 
function smulv(v1,v2:ivec ):integer;overload; 
function nmulv(v:ivec ;a:double):ivec  ;overload; 
function nmulv(v:ivec ;a:integer):ivec ;overload; 
          

function addv(v1:vec;v2:veca):vec;overload;   
function subv(v1:vec;v2:veca):vec;overload;

function perpv(v1,v2:vec):vec;overload;
function perpv(v1,v2:mvec):mvec;overload;

function lmulv(v1,v2:vec2):vec2;overload;
function lmulv(v1,v2:vec ):vec ;overload;
function lmulv(v1,v2:quat):quat;overload;
function lmulv(v1,v2:vec5):vec5;overload; 
function lmulv(v1,v2:mvec ):mvec ;overload;
function ldivv(v1,v2:vec2):vec2;overload;
function ldivv(v1,v2:vec ):vec ;overload;
function ldivv(v1,v2:quat):quat;overload;
function ldivv(v1,v2:vec5):vec5;overload; 
function ldivv(v1,v2:mvec ):mvec ;overload;
function naddv(v1:vec2;a:double):vec2;overload;
function naddv(v1:vec ;a:double):vec ;overload;
function naddv(v1:quat;a:double):quat;overload;
function naddv(v1:vec5;a:double):vec5;overload;
function nsubv(v1:vec2;a:double):vec2;overload;
function nsubv(v1:vec ;a:double):vec ;overload;
function nsubv(v1:quat;a:double):quat;overload;
function nsubv(v1:vec5;a:double):vec5;overload;

procedure vrot(var v:vec2;e:double);overload;
procedure vrotz(var v:vec;e:double);overload;
procedure vroty(var v:vec;e:double);overload;
procedure vrotx(var v:vec;e:double);overload;
function  vrotf(v:vec2;e:double):vec2;overload;
function  vrotzf(v:vec;e:double):vec;overload;
function  vrotyf(v:vec;e:double):vec;overload;
function  vrotxf(v:vec;e:double):vec;overload;

procedure vrot(var v:mvec2;e:double);overload;
procedure vrotz(var v:mvec;e:double);overload;
procedure vroty(var v:mvec;e:double);overload;
procedure vrotx(var v:mvec;e:double);overload;
function  vrotf(v:mvec2;e:double):mvec2;overload;
function  vrotzf(v:mvec;e:double):mvec;overload;
function  vrotyf(v:mvec;e:double):mvec;overload;
function  vrotxf(v:mvec;e:double):mvec;overload;

procedure vrotix(var v:ivec;e:double);

procedure vrec2sph(var v:vec;r:double);  
function trr2l(v:vec):vec; 
function trv2p(v:vec;tm:mat):vec;
function trp2v(v:vec;tm:mat):vec;

function vrec2sphv(v:vec):vec;
function vsph2rec(r,lat,lon:double):vec;  
function vsph2recml(r,lat,lon:double):vec; 
function bilbmat(cv:vec):mat;    
function getrtmat1(v:vec):mat;
procedure getloclatlonhdg(lat,lon,hdg,rad:double;var v:vec;var r:mat);
function getrcbrv(vrp,vrv:vec;prmat:mat;pr,prtr:double):vec;
function getrcbrvglobal(vrp,vrv:vec;prmat:mat;pr,prtr:double):vec;
function rcbrv2global(prv,vrp,vrv:vec;prmat:mat;pr,prtr:double):vec;

procedure gvec(var x:double;var y:double;var z:double;a:vec);
procedure vreps(var v:vec;e:double);
{
function vec34(a:vec):vec4;
function vec32(a:vec):vec2;
function vec23(a:vec2):vec;
procedure vscale(var v:vec;a,b,c:double);
}
//####################################################################################//
//################################ Quat and etc ######################################//
//####################################################################################// 

function emat:mat;
function ematq:matq;
function emat5:mat5;
function emat5z:mat5;
                           
function matq2mmatq(a:matq):mmatq;
function epsmat(a:mat):mat;
function rvmat(b:vec;a:mat):vec; overload;
function rvmat(b:vec;a:matq):vec;overload;  
function rvmat(b:quat;a:mat5):quat;overload;  
function lvmat(a:mat;b:vec):vec; overload;
function lvmat(a:matq;b:vec):vec;overload;   
function lvmat(a:mat5;b:quat):quat;overload;   
function rvmat(b:quat;a:matq):quat;overload; 
function lvmat(a:matq;b:quat):quat;overload; 
function trmat(tm:mat):mat; 
function atmat(a:vec):mat;
function atmatz(a:vec):mat;
function tamat(a:mat):vec;   
function tamatz(a:mat):vec;
function mulm(a,b:mat):mat;overload;     
function mulm(a,b:matq):matq;overload;    
function mulm(a,b:mat5):mat5;overload;     
procedure rtmatx(var a:mat;an:double);
procedure rtmaty(var a:mat;an:double);
procedure rtmatz(var a:mat;an:double);
procedure rtmataa(var a:mat;an:double;ax:vec);
function vecs2mat(f,up:vec):mat;
function vecs2matz(f,up:vec):mat;
function v2vrotmat(v1,v2:vec):mat;  

procedure RotateVector(var vector:vec;const axis:vec;angle:double);overload;       
procedure RotateVector(var vector:mvec;const axis:vec;angle:double);overload;
function quat2rotm(q:quat):mat;
function quat2orotm(q:quat):mat;        
function quat2rotmz(q:quat):mat;
function rotm2quat(a:mat):quat;
function rotm2quatz(a:mat):quat;
{
function CreateRotationMatrix(const axis:vec;angle:double):matq;
function VectorTransform(const V:quata;const M:matq):quata;
}
function trquat(x,y,z:double):quat;
function vtrquat(a:vec):quat;
procedure getqaa(q:quat;var v:vec;var ang:double);
function qrot(iv:vec;iq:quat):vec;  
function qunrot(iv:vec;iq:quat):vec;  
function qrotvec(v:vec;q:quat):vec;  
function qunrotvec(v:vec;q:quat):vec;  
function qmul(q1,q2:quat):quat; 
function qinv(q:quat):quat;
 
function pntipoly(x,y:double;n:integer;var xpo,ypo:arrdbl):boolean;
{
function pntitri(x,y:double;a,b,c:vec2):boolean;
          }                                      
function p_intri(n,vx,vy,vz,p:mvec):boolean;
function line2sph(v1,v2,v3:vec;r:double;var px:vec):double;

function t2lccnt(A,B,C,D,E:vec;var alt:double):boolean;         
function t2lcc(A,B,C,D,E:vec;var alt:double;r:double):boolean;
     

var lrndseed:cardinal;
oldlrndseed:cardinal;
function lrandom(l:integer):integer;overload;
//function lrandom(l:int64):int64;overload;
function lrandom:double;overload;
          
//####################################################################################//
//####################################################################################//
//####################################################################################//
//####################################################################################//
//####################################################################################//
//####################################################################################//

implementation
//############################################################################//
//################################# Math #####################################//
//############################################################################//
              
function inbox(p,bh,bl:vec):boolean;
begin
 result:=false;
 if(p.x>=bh.x)and(p.x<=bl.x)and(p.y>=bh.y)and(p.y<=bl.y)and(p.z>=bh.z)and(p.z<=bl.z)then result:=true;
end;   
function incube(p,b:vec;s:double):boolean;
begin
 result:=(p.x>=b.x-s)and(p.x<b.x+s)and(p.y>=b.y-s)and(p.y<b.y+s)and(p.z>=b.z-s)and(p.z<b.z+s);
end;
function nbool(b:boolean):integer;begin result:=ord(b)*2-1;end;   

function zchk(n:double):double;{$ifndef ape3}{$ifdef FPC}inline;{$endif}{$endif}
begin
 if abs(n)<eps then result:=eps else result:=n;
end;

procedure swapd(var a,b:double);
var c:double;
begin 
 c:=a;a:=b;b:=c;
end;
procedure swapi(var a,b:integer);
var c:integer;
begin 
 c:=a;a:=b;b:=c;
end;

function max2(a,b:double):double;
begin
 if a>b then result:=a else result:=b;
end;
function max2i(a,b:integer):integer;
begin
 if a>b then result:=a else result:=b;
end;
function min2(a,b:double):double;
begin
 if a<b then result:=a else result:=b;
end;
function min2i(a,b:integer):integer;
begin
 if a<b then result:=a else result:=b;
end;
function max3(a,b,c:double):double;
begin
 if a>b then result:=a else result:=b;
 if c>result then result:=c;
end;
function max3i(a,b,c:integer):integer;
begin
 if a>b then result:=a else result:=b;
 if c>result then result:=c;
end;
function min3(a,b,c:double):double;
begin
 if a<b then result:=a else result:=b;
 if c<result then result:=c;
end;
function min3i(a,b,c:integer):integer;
begin
 if a<b then result:=a else result:=b;
 if c<result then result:=c;
end;
function min6(a,b,c,d,e,f:double):double;
begin
 if a<b then result:=a else result:=b;
 if c<result then result:=c;
 if d<result then result:=d;
 if e<result then result:=e;
 if f<result then result:=f;
end;
function min6n(a,b,c,d,e,f:double):integer;
var mi:double;
begin
 if a<b then begin result:=0; mi:=a; end else begin result:=1; mi:=b; end;
 if c<mi then begin result:=2; mi:=c; end;
 if d<mi then begin result:=3; mi:=d; end;
 if e<mi then begin result:=4; mi:=e; end;
 if f<mi then begin result:=5; end;//mi:=f; end;
end;
    
//##############################################################################

function deg2rad(dg:double):double;
begin
 result:=(dg*pi)/180;
end;

function hitrunc(par:double):integer;
var st:integer;
begin
  st:=trunc(par);
  if frac(par)>0 then st:=st+1;
{
  str(par,st); }
  result:=st;
end;

//##############################################################################

function inrect(x,y,x1,y1,x2,y2:integer):boolean;
begin
 if (x>=x1)and(x<=x2)and(y>=y1)and(y<=y2)then result:=true else result:=false;
end;
function inrects(x,y,x1,y1,xs,ys:integer):boolean;
begin
 if (x>=x1)and(x<=x1+xs)and(y>=y1)and(y<=y1+ys)then result:=true else result:=false;
end;

function getrtang(pmx,pmy,wx,wy:double):double;
var dx,dy:double;
begin
 result:=0;
 if(pmx=wx)and(pmy=wy)then result:=0;
 if(pmx=wx)and(pmy>wy)then result:=180;
 if(pmx=wx)and(pmy<wy)then result:=0;  
 if(pmx<wx)and(pmy=wy)then result:=270;
 if(pmx>wx)and(pmy=wy)then result:=90;
 if(pmx>wx)and(pmy<wy)then begin
  dx:=pmx-wx;
  dy:=wy-pmy;
  result:=arctan(dx/dy)*180/pi;
 end;
 if(pmx>wx)and(pmy>wy)then begin
  dx:=pmx-wx;
  dy:=pmy-wy;
  result:=90+arctan(dy/dx)*180/pi;
 end;
 if(pmx<wx)and(pmy>wy)then begin
  dx:=wx-pmx;
  dy:=pmy-wy;
  result:=180+arctan(dx/dy)*180/pi;
 end;
 if(pmx<wx)and(pmy<wy)then begin
  dx:=wx-pmx;
  dy:=wy-pmy;
  result:=270+arctan(dy/dx)*180/pi;
 end;
end;
 
//##############################################################################

function pow(a,x:double):double;
var res:double;
begin
 res:=1;
 if a>0 then res:=exp(x*ln(a));
 result:=res;
end;
        
function is_pot(x:integer):boolean;
begin
 result:=(x>1)and((x and (x-1))=0);
end;    
function upround_pot(x:integer):integer;
begin
 result:=x;
 if(x>2)and(x<4)then result:=4;
 if(x>4)and(x<8)then result:=8;
 if(x>8)and(x<16)then result:=16;
 if(x>16)and(x<32)then result:=32;
 if(x>32)and(x<64)then result:=64;
 if(x>64)and(x<128)then result:=128;
 if(x>128)and(x<256)then result:=256;
 if(x>256)and(x<512)then result:=512;
 if(x>512)and(x<1024)then result:=1024;
 if(x>1024)and(x<2048)then result:=2048;
 if(x>2048)and(x<4096)then result:=4096;
end;     

function sgn(a:double):integer;
begin
 result:=0;
 if a<0 then result:=-1;
 if a>=0 then result:=1;
end;
function sgna(a:integer):integer;
begin
 result:=0;
 if a<0 then result:=-1;
 if a>0 then result:=1;
end;
 
//##############################################################################

function powi(a,x:double):integer;
var res:double;
begin
 res:=1;
 if a>0 then res:=exp(x*ln(a));
 result:=round(res);
end;
   
//##############################################################################

function arctan2(y,x:real):real;
begin
 result:=0;
 if x=0.0 then begin
  if y=0.0 then else if y > 0.0 then arctan2 := half_pi else arctan2 := -half_pi
 end else begin if x > 0.0 then arctan2 := arctan( y / x )
 else if x < 0.0 then begin
   if y >= 0.0 then arctan2 := arctan( y / x ) + pi else arctan2 := arctan( y / x ) - pi
  end;
 end;
end;
    
//##############################################################################

function arctan21(sy,cy:real):real;
var atn:double;
begin  
 result:=0;
 if cy=0.0 then begin
  if sy=0 then result:=0;
  if sy<0 then result:=3*half_pi;
  if sy>0 then result:=half_pi;
 end else {cos g is not zero} begin
  atn:=arctan(sy/cy);
  if cy<0 then atn:=atn+pi;
  if (cy>0)and(sy<0) then atn:=atn+2*pi;
  result:=atn;
 end
end;  
    
//############################################################################//

function angnmr(ang:double):double;
begin
 result:=ang-(int(ang/(2*pi))*2*pi);
end;        
//############################################################################//
function cntfrac(v:double):dword;
var k:integer;
begin
 //v:=fabs(v);
 v:=abs(v); 
 v:=v-trunc(v);
 result:=0;
 k:=1;
 //while(v<1000)and(result<3)do begin v:=v*10;inc(result);end;
 while k<=3 do begin 
  v:=v*10;
  if v>=1 then result:=k;
  if abs(v-round(v))<eps then exit;
  v:=v-trunc(v);
  inc(k);
 end;
end;      

//############################################################################//
//############################################################################//
//############################# Vector #######################################//
//############################################################################//
//############################################################################//
function tivec2(x,y:integer):ivec2;          begin result.x:=x;result.y:=y;end;
function tivec (x,y,z:integer):ivec;         begin result.x:=x;result.y:=y;result.z:=z;end;

function tvec2(x,y:double):vec2;          begin result.x:=x;result.y:=y;end;  
function tvec (x,y,z:double):vec;         begin result.x:=x;result.y:=y;result.z:=z;end;     
function tquat(x,y,z,w:double):quat;      begin result.x:=x;result.y:=y;result.z:=z;result.w:=w;end;     
function tvec5(x,y,z,w,t:double):vec5;    begin result.x:=x;result.y:=y;result.z:=z;result.w:=w;result.t:=t;end;    
function tvec2a(x,y:double):vec2a;        begin result[0]:=x;result[1]:=y;end;  
function tveca (x,y,z:double):veca;       begin result[0]:=x;result[1]:=y;result[2]:=z;end;     
function tquata(x,y,z,w:double):quata;    begin result[0]:=x;result[1]:=y;result[2]:=z;result[3]:=w;end;     
function tvec5a(x,y,z,w,t:double):vec5a;  begin result[0]:=x;result[1]:=y;result[2]:=z;result[3]:=w;result[4]:=t;end;    
function tmvec2(x,y:double):mvec2;        begin result.x:=x;result.y:=y;end;  
function tmvec (x,y,z:double):mvec;       begin result.x:=x;result.y:=y;result.z:=z;end;     
function tmquat(x,y,z,w:double):mquat;    begin result.x:=x;result.y:=y;result.z:=z;result.w:=w;end;     
function tmvec5(x,y,z,w,t:double):mvec5;  begin result.x:=x;result.y:=y;result.z:=z;result.w:=w;result.t:=t;end;
function tmvec2a(x,y:double):mvec2a;      begin result[0]:=x;result[1]:=y;end;  
function tmveca (x,y,z:double):mveca;     begin result[0]:=x;result[1]:=y;result[2]:=z;end;     
function tmquata(x,y,z,w:double):mquata;  begin result[0]:=x;result[1]:=y;result[2]:=z;result[3]:=w;end;     
function tmvec5a(x,y,z,w,t:double):mvec5a;begin result[0]:=x;result[1]:=y;result[2]:=z;result[3]:=w;result[4]:=t;end;  
  
function v2m(v:vec2):mvec2;begin result.x:=v.x;result.y:=v.y;end; 
function v2m(v:vec ):mvec ;begin result.x:=v.x;result.y:=v.y;result.z:=v.z;end; 
function v2m(v:quat):mquat;begin result.x:=v.x;result.y:=v.y;result.z:=v.z;result.w:=v.w;end; 
function v2m(v:vec5):mvec5;begin result.x:=v.x;result.y:=v.y;result.z:=v.z;result.w:=v.w;result.t:=v.t;end; 
function m2v(v:mvec2):vec2;begin result.x:=v.x;result.y:=v.y;end; 
function m2v(v:mvec ):vec ;begin result.x:=v.x;result.y:=v.y;result.z:=v.z;end; 
function m2v(v:mquat):quat;begin result.x:=v.x;result.y:=v.y;result.z:=v.z;result.w:=v.w;end; 
function m2v(v:mvec5):vec5;begin result.x:=v.x;result.y:=v.y;result.z:=v.z;result.w:=v.w;result.t:=v.t;end; 
//############################################################################//                       
function v4v3(v:quat):vec;begin result.x:=v.x;result.y:=v.y;result.z:=v.z;end;                      
function v3v4(v:vec;w:double):quat;begin result.x:=v.x;result.y:=v.y;result.z:=v.z;result.w:=w;end; 
//############################################################################//
function modv (v:vec2) :double;begin result:=sqrt(sqr(v.x)+sqr(v.y));end;
function modv (v:vec ) :double;begin result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z));end;
function modv (v:quat) :double;begin result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z)+sqr(v.w));end;
function modv (v:vec5) :double;begin result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z)+sqr(v.w)+sqr(v.t));end;    
function modv (v:mvec2):double;begin result:=sqrt(sqr(v.x)+sqr(v.y));end;
function modv (v:mvec ):double;begin result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z));end;
function modv (v:mquat):double;begin result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z)+sqr(v.w));end;
function modv (v:mvec5):double;begin result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z)+sqr(v.w)+sqr(v.t));end;
function modvs(v:vec2) :double;begin result:=sqr(v.x)+sqr(v.y)end;
function modvs(v:vec ) :double;begin result:=sqr(v.x)+sqr(v.y)+sqr(v.z)end;
function modvs(v:quat) :double;begin result:=sqr(v.x)+sqr(v.y)+sqr(v.z)+sqr(v.w)end;
function modvs(v:vec5) :double;begin result:=sqr(v.x)+sqr(v.y)+sqr(v.z)+sqr(v.w)+sqr(v.t);end;  
function modvs(v:mvec2):double;begin result:=sqr(v.x)+sqr(v.y)end;
function modvs(v:mvec ):double;begin result:=sqr(v.x)+sqr(v.y)+sqr(v.z)end;
function modvs(v:mquat):double;begin result:=sqr(v.x)+sqr(v.y)+sqr(v.z)+sqr(v.w)end;
function modvs(v:mvec5):double;begin result:=sqr(v.x)+sqr(v.y)+sqr(v.z)+sqr(v.w)+sqr(v.t);end;   
function nrvec(v:vec2):vec2;  
var md:double;
begin
 md:=modv(v);
 if abs(md)<eps then begin result:=v; exit; end;
 result.x:=v.x/md;result.y:=v.y/md;
end;
function nrvec(v:vec):vec; 
var md:double;
begin
 md:=modv(v);
 if abs(md)<eps then begin result:=v; exit; end;
 result.x:=v.x/md;result.y:=v.y/md;result.z:=v.z/md;
end;
function nrvec(v:quat):quat; 
var md:double;
begin
 md:=modv(v);
 if abs(md)<eps then begin result:=v; exit; end;
 result.x:=v.x/md;result.y:=v.y/md;result.z:=v.z/md;result.w:=v.w/md;
end;
function nrvec(v:vec5):vec5; 
var md:double;
begin
 md:=modv(v);
 if abs(md)<eps then begin result:=v; exit; end;
 result.x:=v.x/md;result.y:=v.y/md;result.z:=v.z/md;result.w:=v.w/md;result.t:=v.t/md;
end;

function nrvec(v:mvec2):mvec2;  
var md:double;
begin
 md:=modv(v);
 if abs(md)<eps then begin result:=v; exit; end;
 result.x:=v.x/md;result.y:=v.y/md;
end;
function nrvec(v:mvec):mvec; 
var md:double;
begin
 md:=modv(v);
 if abs(md)<eps then begin result:=v; exit; end;
 result.x:=v.x/md;result.y:=v.y/md;result.z:=v.z/md;
end;
function nrvec(v:mquat):mquat; 
var md:double;
begin
 md:=modv(v);
 if abs(md)<eps then begin result:=v; exit; end;
 result.x:=v.x/md;result.y:=v.y/md;result.z:=v.z/md;result.w:=v.w/md;
end;
function nrvec(v:mvec5):mvec5; 
var md:double;
begin
 md:=modv(v);
 if abs(md)<eps then begin result:=v; exit; end;
 result.x:=v.x/md;result.y:=v.y/md;result.z:=v.z/md;result.w:=v.w/md;result.t:=v.t/md;
end;
//############################################################################// 
//############################################################################// 
function vcmp (v1,v2:vec2):boolean;begin result:=(abs(v1.x-v2.x)<eps)and(abs(v1.y-v2.y)<eps);end;
function vcmp (v1,v2:vec ):boolean;begin result:=(abs(v1.x-v2.x)<eps)and(abs(v1.y-v2.y)<eps)and(abs(v1.z-v2.z)<eps);end;
function vcmp (v1,v2:quat):boolean;begin result:=(abs(v1.x-v2.x)<eps)and(abs(v1.y-v2.y)<eps)and(abs(v1.z-v2.z)<eps)and(abs(v1.w-v2.w)<eps);end;
function vcmp (v1,v2:vec5):boolean;begin result:=(abs(v1.x-v2.x)<eps)and(abs(v1.y-v2.y)<eps)and(abs(v1.z-v2.z)<eps)and(abs(v1.w-v2.w)<eps)and(abs(v1.t-v2.t)<eps);end;
function vcmp (v1,v2:mvec ):boolean;begin result:=(abs(v1.x-v2.x)<eps)and(abs(v1.y-v2.y)<eps)and(abs(v1.z-v2.z)<eps);end;
function vdst (v1,v2:vec2):double;begin result:=sqrt(sqr(v1.x-v2.x)+sqr(v1.y-v2.y));end;
function vdst (v1,v2:vec ):double;begin result:=sqrt(sqr(v1.x-v2.x)+sqr(v1.y-v2.y)+sqr(v1.z-v2.z));end;
function vdst (v1,v2:quat):double;begin result:=sqrt(sqr(v1.x-v2.x)+sqr(v1.y-v2.y)+sqr(v1.z-v2.z)+sqr(v1.w-v2.w));end;
function vdst (v1,v2:vec5):double;begin result:=sqrt(sqr(v1.x-v2.x)+sqr(v1.y-v2.y)+sqr(v1.z-v2.z)+sqr(v1.w-v2.w)+sqr(v1.t-v2.t));end;
function vdsts(v1,v2:vec2):double;begin result:=sqr(v1.x-v2.x)+sqr(v1.y-v2.y);end;
function vdsts(v1,v2:vec ):double;begin result:=sqr(v1.x-v2.x)+sqr(v1.y-v2.y)+sqr(v1.z-v2.z);end;
function vdsts(v1,v2:quat):double;begin result:=sqr(v1.x-v2.x)+sqr(v1.y-v2.y)+sqr(v1.z-v2.z)+sqr(v1.w-v2.w);end;
function vdsts(v1,v2:vec5):double;begin result:=sqr(v1.x-v2.x)+sqr(v1.y-v2.y)+sqr(v1.z-v2.z)+sqr(v1.w-v2.w)+sqr(v1.t-v2.t);end;
function vdsts(v1,v2:mvec ):double;begin result:=sqr(v1.x-v2.x)+sqr(v1.y-v2.y)+sqr(v1.z-v2.z);end;  
   
function vcollin(v1,v2,v3:mvec):boolean;begin result:=abs( (v2.y-v1.y)*(v1.z-v3.z)-(v2.z-v1.z)*(v1.y-v3.y))+abs(-(v2.x-v1.x)*(v1.z-v3.z)+(v2.z-v1.z)*(v1.x-v3.x))+abs( (v2.x-v1.x)*(v1.y-v3.y)-(v2.y-v1.y)*(v1.x-v3.x))<eps;end;
function vcollin(v1,v2,v3:vec ):boolean;begin result:=abs( (v2.y-v1.y)*(v1.z-v3.z)-(v2.z-v1.z)*(v1.y-v3.y))+abs(-(v2.x-v1.x)*(v1.z-v3.z)+(v2.z-v1.z)*(v1.x-v3.x))+abs( (v2.x-v1.x)*(v1.y-v3.y)-(v2.y-v1.y)*(v1.x-v3.x))<eps;end;
function vcoplan(v1,v2,v3,v4:vec):boolean;begin result:=abs(smulv(subv(v3,v1),vmulv(subv(v2,v1),subv(v4,v3))))<eps;end;
function vcoplan(v1,v2,v3,v4:mvec):boolean;begin result:=abs(smulv(subv(v3,v1),vmulv(subv(v2,v1),subv(v4,v3))))<eps;end;
 
function vmid2(v1,v2:vec2):vec2;begin result.x:=(v1.x+v2.x)/2;result.y:=(v1.y+v2.y)/2;end;
function vmid2(v1,v2:vec ):vec ;begin result.x:=(v1.x+v2.x)/2;result.y:=(v1.y+v2.y)/2;result.z:=(v1.z+v2.z)/2;end;
function vmid2(v1,v2:quat):quat;begin result.x:=(v1.x+v2.x)/2;result.y:=(v1.y+v2.y)/2;result.z:=(v1.z+v2.z)/2;result.w:=(v1.w+v2.w)/2;end;
function vmid2(v1,v2:vec5):vec5;begin result.x:=(v1.x+v2.x)/2;result.y:=(v1.y+v2.y)/2;result.z:=(v1.z+v2.z)/2;result.w:=(v1.w+v2.w)/2;result.t:=(v1.t+v2.t)/2;end;
function vmid3(v1,v2,v3:vec2):vec2;begin result.x:=(v1.x+v2.x+v3.x)/3;result.y:=(v1.y+v2.y+v3.y)/3;end;
function vmid3(v1,v2,v3:vec ):vec ;begin result.x:=(v1.x+v2.x+v3.x)/3;result.y:=(v1.y+v2.y+v3.y)/3;result.z:=(v1.z+v2.z+v3.z)/3;end;
function vmid3(v1,v2,v3:quat):quat;begin result.x:=(v1.x+v2.x+v3.x)/3;result.y:=(v1.y+v2.y+v3.y)/3;result.z:=(v1.z+v2.z+v3.z)/3;result.w:=(v1.w+v2.w+v3.w)/3;end;
function vmid3(v1,v2,v3:vec5):vec5;begin result.x:=(v1.x+v2.x+v3.x)/3;result.y:=(v1.y+v2.y+v3.y)/3;result.z:=(v1.z+v2.z+v3.z)/3;result.w:=(v1.w+v2.w+v3.w)/3;result.t:=(v1.t+v2.t+v3.t)/3;end;
function vmid4(v1,v2,v3,v4:vec2):vec2;begin result.x:=(v1.x+v2.x+v3.x+v4.x)/4;result.y:=(v1.y+v2.y+v3.y+v4.y)/4;end;
function vmid4(v1,v2,v3,v4:vec ):vec ;begin result.x:=(v1.x+v2.x+v3.x+v4.x)/4;result.y:=(v1.y+v2.y+v3.y+v4.y)/4;result.z:=(v1.z+v2.z+v3.z+v4.z)/4;end;
function vmid4(v1,v2,v3,v4:quat):quat;begin result.x:=(v1.x+v2.x+v3.x+v4.x)/4;result.y:=(v1.y+v2.y+v3.y+v4.y)/4;result.z:=(v1.z+v2.z+v3.z+v4.z)/4;result.w:=(v1.w+v2.w+v3.w+v4.w)/4;end;
function vmid4(v1,v2,v3,v4:vec5):vec5;begin result.x:=(v1.x+v2.x+v3.x+v4.x)/4;result.y:=(v1.y+v2.y+v3.y+v4.y)/4;result.z:=(v1.z+v2.z+v3.z+v4.z)/4;result.w:=(v1.w+v2.w+v3.w+v4.w)/4;result.z:=(v1.t+v2.t+v3.t+v4.t)/4;end;
function vmid5(v1,v2,v3,v4,v5:vec2):vec2;begin result.x:=(v1.x+v2.x+v3.x+v4.x+v5.x)/5;result.y:=(v1.y+v2.y+v3.y+v4.y+v5.y)/5;end;
function vmid5(v1,v2,v3,v4,v5:vec ):vec ;begin result.x:=(v1.x+v2.x+v3.x+v4.x+v5.x)/5;result.y:=(v1.y+v2.y+v3.y+v4.y+v5.y)/5;result.z:=(v1.z+v2.z+v3.z+v4.z+v5.z)/5;end;
function vmid5(v1,v2,v3,v4,v5:quat):quat;begin result.x:=(v1.x+v2.x+v3.x+v4.x+v5.x)/5;result.y:=(v1.y+v2.y+v3.y+v4.y+v5.y)/5;result.z:=(v1.z+v2.z+v3.z+v4.z+v5.z)/5;result.w:=(v1.w+v2.w+v3.w+v4.w+v5.w)/5;end;
function vmid5(v1,v2,v3,v4,v5:vec5):vec5;begin result.x:=(v1.x+v2.x+v3.x+v4.x+v5.x)/5;result.y:=(v1.y+v2.y+v3.y+v4.y+v5.y)/5;result.z:=(v1.z+v2.z+v3.z+v4.z+v5.z)/5;result.w:=(v1.w+v2.w+v3.w+v4.w+v5.w)/5;result.t:=(v1.t+v2.t+v3.t+v4.t+v5.t)/5;end;
//############################################################################//
//############################################################################//
//function vmulv(v1,v2:vec2):vec2;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;end;
function vmulv(v1,v2:vec ):vec ;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;result.z:=v1.x*v2.y-v1.y*v2.x;end;
function vmulv(v1,v2:quat):quat;begin result.x:=v1.w*v2.x+v1.x*v2.w+v1.y*v2.z-v1.z*v2.y;result.y:=v1.w*v2.y+v1.y*v2.w+v1.z*v2.x-v1.x*v2.z;result.z:=v1.w*v2.z+v1.z*v2.w+v1.x*v2.y-v1.y*v2.x;result.w:=v1.w*v2.w-v1.x*v2.x-v1.y*v2.y-v1.z*v2.z;end;
//function vmulv(v1,v2:vec5):vec5;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;result.z:=v1.x*v2.y-v1.y*v2.x;end;
//function vmulv(v1,v2:mvec2):mvec2;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;result.z:=v1.x*v2.y-v1.y*v2.x;end;
function vmulv(v1,v2:mvec ):mvec ;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;result.z:=v1.x*v2.y-v1.y*v2.x;end;
function vmulv(v1,v2:mquat):mquat;begin result.x:=v1.w*v2.x+v1.x*v2.w+v1.y*v2.z-v1.z*v2.y;result.y:=v1.w*v2.y+v1.y*v2.w+v1.z*v2.x-v1.x*v2.z;result.z:=v1.w*v2.z+v1.z*v2.w+v1.x*v2.y-v1.y*v2.x;result.w:=v1.w*v2.w-v1.x*v2.x-v1.y*v2.y-v1.z*v2.z;end;
//function vmulv(v1,v2:mvec5):mvec5;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;result.z:=v1.x*v2.y-v1.y*v2.x;end;

function vmulv(v1,v2:ivec ):ivec ;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;result.z:=v1.x*v2.y-v1.y*v2.x;end;
                
function smulv(v1,v2:vec2):double;begin result:=v1.x*v2.x+v1.y*v2.y;end;
function smulv(v1,v2:vec ):double;begin result:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;end;
function smulv(v1,v2:quat):double;begin result:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z+v1.w*v2.w;end;    
function smulv(v1,v2:vec5):double;begin result:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z+v1.w*v2.w+v1.t*v2.t;end;
function smulv(v1,v2:mvec2):double;begin result:=v1.x*v2.x+v1.y*v2.y;end;
function smulv(v1,v2:mvec ):double;begin result:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;end;
function smulv(v1,v2:mquat):double;begin result:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z+v1.w*v2.w;end;
function smulv(v1,v2:mvec5):double;begin result:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z+v1.w*v2.w+v1.t*v2.t;end;

function smulv(v1,v2:ivec ):integer;begin result:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;end;

function nmulv(v:vec2;a:double):vec2;begin result.x:=a*v.x;result.y:=a*v.y;end;
function nmulv(v:vec ;a:double):vec ;begin result.x:=a*v.x;result.y:=a*v.y;result.z:=a*v.z;end;
function nmulv(v:quat;a:double):quat;begin result.x:=a*v.x;result.y:=a*v.y;result.z:=a*v.z;result.w:=a*v.w;end;  
function nmulv(v:vec5;a:double):vec5;begin result.x:=a*v.x;result.y:=a*v.y;result.z:=a*v.z;result.w:=a*v.w;result.t:=a*v.t;end;  
function nmulv(v:mvec2;a:double):mvec2;begin result.x:=a*v.x;result.y:=a*v.y;end;
function nmulv(v:mvec ;a:double):mvec ;begin result.x:=a*v.x;result.y:=a*v.y;result.z:=a*v.z;end;
function nmulv(v:mquat;a:double):mquat;begin result.x:=a*v.x;result.y:=a*v.y;result.z:=a*v.z;result.w:=a*v.w;end;
function nmulv(v:mvec5;a:double):mvec5;begin result.x:=a*v.x;result.y:=a*v.y;result.z:=a*v.z;result.w:=a*v.w;result.t:=a*v.t;end;
                
function nmulv(v:ivec ;a:double):ivec  ;begin result.x:=round(a*v.x);result.y:=round(a*v.y);result.z:=round(a*v.z);end;     
function nmulv(v:ivec ;a:integer):ivec ;begin result.x:=a*v.x;result.y:=a*v.y;result.z:=a*v.z;end;
     
function addv(v1,v2:vec2):vec2;begin result.x:=v1.x+v2.x;result.y:=v1.y+v2.y;end;
function addv(v1,v2:vec ):vec ;begin result.x:=v1.x+v2.x;result.y:=v1.y+v2.y;result.z:=v1.z+v2.z;end;
function addv(v1,v2:quat):quat;begin result.x:=v1.x+v2.x;result.y:=v1.y+v2.y;result.z:=v1.z+v2.z;result.w:=v1.w+v2.w;end;  
function addv(v1,v2:vec5):vec5;begin result.x:=v1.x+v2.x;result.y:=v1.y+v2.y;result.z:=v1.z+v2.z;result.w:=v1.w+v2.w;result.t:=v1.t+v2.t;end;
function addv(v1,v2:mvec2):mvec2;begin result.x:=v1.x+v2.x;result.y:=v1.y+v2.y;end;
function addv(v1,v2:mvec ):mvec ;begin result.x:=v1.x+v2.x;result.y:=v1.y+v2.y;result.z:=v1.z+v2.z;end;
function addv(v1,v2:mquat):mquat;begin result.x:=v1.x+v2.x;result.y:=v1.y+v2.y;result.z:=v1.z+v2.z;result.w:=v1.w+v2.w;end;
function addv(v1,v2:mvec5):mvec5;begin result.x:=v1.x+v2.x;result.y:=v1.y+v2.y;result.z:=v1.z+v2.z;result.w:=v1.w+v2.w;result.t:=v1.t+v2.t;end;        
function subv(v1,v2:vec2):vec2;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;end;
function subv(v1,v2:vec ):vec ;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;result.z:=v1.z-v2.z;end;
function subv(v1,v2:quat):quat;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;result.z:=v1.z-v2.z;result.w:=v1.w-v2.w;end;  
function subv(v1,v2:vec5):vec5;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;result.z:=v1.z-v2.z;result.w:=v1.w-v2.w;result.t:=v1.t-v2.t;end;
function subv(v1,v2:mvec2):mvec2;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;end;
function subv(v1,v2:mvec ):mvec ;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;result.z:=v1.z-v2.z;end;
function subv(v1,v2:mquat):mquat;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;result.z:=v1.z-v2.z;result.w:=v1.w-v2.w;end;
function subv(v1,v2:mvec5):mvec5;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;result.z:=v1.z-v2.z;result.w:=v1.w-v2.w;result.t:=v1.t-v2.t;end;

function subv(v1,v2:ivec ):ivec ;begin result.x:=v1.x-v2.x;result.y:=v1.y-v2.y;result.z:=v1.z-v2.z;end;
          
function addv(v1:vec;v2:veca):vec;begin result.x:=v1.x+v2[0];result.y:=v1.y+v2[1];result.z:=v1.z+v2[2];end;   
function subv(v1:vec;v2:veca):vec;begin result.x:=v1.x-v2[0];result.y:=v1.y-v2[1];result.z:=v1.z-v2[2];end;

function perpv(v1,v2:vec):vec;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;result.z:=v1.x*v2.y-v1.y*v2.x;result:=nrvec(result);end;
function perpv(v1,v2:mvec):mvec;begin result.x:=v1.y*v2.z-v1.z*v2.y;result.y:=-v1.x*v2.z+v1.z*v2.x;result.z:=v1.x*v2.y-v1.y*v2.x;result:=nrvec(result);end;

function lmulv(v1,v2:vec2):vec2;begin result.x:=v1.x*v2.x;result.y:=v1.y*v2.y;end;
function lmulv(v1,v2:vec ):vec ;begin result.x:=v1.x*v2.x;result.y:=v1.y*v2.y;result.z:=v1.z*v2.z;end;
function lmulv(v1,v2:quat):quat;begin result.x:=v1.x*v2.x;result.y:=v1.y*v2.y;result.z:=v1.z*v2.z;result.w:=v1.w*v2.w;end;
function lmulv(v1,v2:vec5):vec5;begin result.x:=v1.x*v2.x;result.y:=v1.y*v2.y;result.z:=v1.z*v2.z;result.w:=v1.w*v2.w;result.t:=v1.t*v2.t;end;
function lmulv(v1,v2:mvec ):mvec ;begin result.x:=v1.x*v2.x;result.y:=v1.y*v2.y;result.z:=v1.z*v2.z;end;
function ldivv(v1,v2:vec2):vec2;begin result.x:=v1.x/v2.x;result.y:=v1.y/v2.y;end;
function ldivv(v1,v2:vec ):vec ;begin result.x:=v1.x/v2.x;result.y:=v1.y/v2.y;result.z:=v1.z/v2.z;end;
function ldivv(v1,v2:quat):quat;begin result.x:=v1.x/v2.x;result.y:=v1.y/v2.y;result.z:=v1.z/v2.z;result.w:=v1.w/v2.w;end;
function ldivv(v1,v2:vec5):vec5;begin result.x:=v1.x/v2.x;result.y:=v1.y/v2.y;result.z:=v1.z/v2.z;result.w:=v1.w/v2.w;result.t:=v1.t/v2.t;end;
function ldivv(v1,v2:mvec ):mvec ;begin result.x:=v1.x/v2.x;result.y:=v1.y/v2.y;result.z:=v1.z/v2.z;end;
function naddv(v1:vec2;a:double):vec2;begin result.x:=v1.x+a;result.y:=v1.y+a;end;
function naddv(v1:vec ;a:double):vec ;begin result.x:=v1.x+a;result.y:=v1.y+a;result.z:=v1.z+a;end;
function naddv(v1:quat;a:double):quat;begin result.x:=v1.x+a;result.y:=v1.y+a;result.z:=v1.z+a;result.w:=v1.w+a;end;
function naddv(v1:vec5;a:double):vec5;begin result.x:=v1.x+a;result.y:=v1.y+a;result.z:=v1.z+a;result.w:=v1.w+a;result.t:=v1.t+a;end;
function nsubv(v1:vec2;a:double):vec2;begin result.x:=v1.x-a;result.y:=v1.y-a;end;
function nsubv(v1:vec ;a:double):vec ;begin result.x:=v1.x-a;result.y:=v1.y-a;result.z:=v1.z-a;end;
function nsubv(v1:quat;a:double):quat;begin result.x:=v1.x-a;result.y:=v1.y-a;result.z:=v1.z-a;result.w:=v1.w-a;end;
function nsubv(v1:vec5;a:double):vec5;begin result.x:=v1.x-a;result.y:=v1.y-a;result.z:=v1.z-a;result.w:=v1.w-a;result.t:=v1.t-a;end;

//############################################################################// 
//############################################################################// 
procedure vrot(var v:vec2;e:double);
var c,s,tx:extended;
begin
 if e=0 then exit;
 sincos(e,s,c);
 tx:=v.x;
 v.x:=tx*c-v.y*s;
 v.y:=tx*s+v.y*c;
end;   
procedure vrotz(var v:vec;e:double);
var c,s,tx:extended;
begin
 if e=0 then exit;
 sincos(e,s,c);
 tx:=v.x;
 v.x:=tx*c-v.y*s;
 v.y:=tx*s+v.y*c;
end;    
procedure vroty(var v:vec;e:double);
var c,s,tx:extended;
begin
 if e=0 then exit;
 sincos(e,s,c);
 tx:=v.x;
 v.x:=tx*c+v.z*s;
 v.z:=-tx*s+v.z*c;
end;
procedure vrotx(var v:vec;e:double);
var c,s,ty:extended;
begin
 if e=0 then exit;
 sincos(e,s,c);
 ty:=v.y;
 v.y:=ty*c-v.z*s;
 v.z:=ty*s+v.z*c;
end;    
//############################################################################// 
procedure vrotix(var v:ivec;e:double);
var c,s,ty:extended;
begin
 if e=0 then exit;
 sincos(e,s,c);
 ty:=v.y;
 v.y:=round(ty*c-v.z*s);
 v.z:=round(ty*s+v.z*c);
end;    
//############################################################################// 
function vrotf(v:vec2;e:double):vec2;
var c,s,tx:double;
begin     
 result:=v;
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 result.x:=tx*c-v.y*s;
 result.y:=tx*s+v.y*c;
end;  
function vrotzf(v:vec;e:double):vec;
var c,s,tx:double;
begin     
 result:=v;
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 result.x:=tx*c-v.y*s;
 result.y:=tx*s+v.y*c;
 result.z:=v.z;
end;    
function vrotyf(v:vec;e:double):vec;
var c,s,tx:double;
begin    
 result:=v;
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 result.x:=tx*c+v.z*s;
 result.y:=v.y;
 result.z:=-tx*s+v.z*c;
end;
function vrotxf(v:vec;e:double):vec;
var c,s,ty:double;
begin
 result:=v;
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 ty:=v.y;             
 result.x:=v.x;
 result.y:=ty*c-v.z*s;
 result.z:=ty*s+v.z*c;
end;
procedure vrot(var v:mvec2;e:double);
var c,s,tx:double;
begin
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 v.x:=tx*c-v.y*s;
 v.y:=tx*s+v.y*c;
end;   
procedure vrotz(var v:mvec;e:double);
var c,s,tx:double;
begin
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 v.x:=tx*c-v.y*s;
 v.y:=tx*s+v.y*c;
end;    
procedure vroty(var v:mvec;e:double);
var c,s,tx:double;
begin
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 v.x:=tx*c+v.z*s;
 v.z:=-tx*s+v.z*c;
end;
procedure vrotx(var v:mvec;e:double);
var c,s,ty:double;
begin
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 ty:=v.y;
 v.y:=ty*c-v.z*s;
 v.z:=ty*s+v.z*c;
end;        

function vrotf(v:mvec2;e:double):mvec2;
var c,s,tx:double;
begin     
 result:=v;
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 result.x:=tx*c-v.y*s;
 result.y:=tx*s+v.y*c;
end;  
function vrotzf(v:mvec;e:double):mvec;
var c,s,tx:double;
begin     
 result:=v;
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 result.x:=tx*c-v.y*s;
 result.y:=tx*s+v.y*c;
 result.z:=v.z;
end;    
function vrotyf(v:mvec;e:double):mvec;
var c,s,tx:double;
begin    
 result:=v;
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 tx:=v.x;
 result.x:=tx*c+v.z*s;
 result.y:=v.y;
 result.z:=-tx*s+v.z*c;
end;
function vrotxf(v:mvec;e:double):mvec;
var c,s,ty:double;
begin
 result:=v;
 if e=0 then exit;
 c:=cos(e);
 s:=sin(e);
 ty:=v.y;             
 result.x:=v.x;
 result.y:=ty*c-v.z*s;
 result.z:=ty*s+v.z*c;
end;
//############################################################################// 
function vrec2sphv(v:vec):vec;
var t:vec;
a1,a2,h,m,n,r:double;
begin
 r:=1;
 a1:=v.y/sqrt(sqr(v.x)+sqr(v.z));
 a2:=v.z/v.x;
 h:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z))-r;
 m:=arctan(a1);
 n:=arctan(a2);
 if (v.x>0)and(v.z>0) then begin n:=n; end;
 if (v.x<0)and(v.z>0) then begin n:=n+pi; end;
 if (v.x<0)and(v.z<0) then begin n:=n-pi; end;
 if (v.x>0)and(v.z<0) then begin n:=n; end;

 t.x:=m;
 t.y:=n;
 t.z:=h;
 result:=t;
end;
procedure vrec2sph(var v:vec;r:double);
var t:vec;
a1,a2,h,m,n:double;
begin
 if (v.x=0) and (v.y=0) then a1:=1e100 else a1:=v.z/sqrt(sqr(v.x)+sqr(v.y));
 if v.x=0 then a2:=1e100 else a2:=v.y/v.x;
 h:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z))-r;
 m:=arctan(a1);
 n:=arctan(a2);
 if (v.x>0)and(v.y>0) then begin n:=n; end;
 if (v.x<0)and(v.y>0) then begin n:=n+pi; end;
 if (v.x<0)and(v.y<0) then begin n:=n-pi; end;
 if (v.x>0)and(v.y<0) then begin n:=n; end;

 t.x:=m;
 t.y:=n;
 t.z:=h;
 v:=t;
end;
function trr2l(v:vec):vec;       
begin 
 result.x:=v.x; 
 result.y:=v.z;
 result.z:=v.y;
end;
function trv2p(v:vec;tm:mat):vec; begin result:=rvmat(v,tm); end;
function trp2v(v:vec;tm:mat):vec; begin result:=lvmat(tm,v); end;  
//############################################################################//
function vsph2rec(r,lat,lon:double):vec;
begin
 result.x:=r*cos(lat)*cos(lon);
 result.z:=r*cos(lat)*sin(lon);
 result.y:=r*sin(lat);
end;  
function vsph2recml(r,lat,lon:double):vec;
begin
 result.x:=r*cos(lat)*cos(lon);
 result.y:=r*cos(lat)*sin(lon);
 result.z:=r*sin(lat);
end;  
//############################################################################//
function bilbmat(cv:vec):mat;   
var xh,yh,zh:vec;
begin
 xh:=nrvec(perpv(cv,tvec(1,1,1)));
 yh:=nrvec(cv);
 zh:=nrvec(vmulv(xh,yh));

 result[0].x:=xh.x;result[1].x:=xh.y;result[2].x:=xh.z;
 result[0].y:=yh.x;result[1].y:=yh.y;result[2].y:=yh.z;
 result[0].z:=zh.x;result[1].z:=zh.y;result[2].z:=zh.z;
end;
//############################################################################//
function getrtmat1(v:vec):mat;
begin
 v:=trr2l(nrvec(v));
 vrec2sph(v,1);
 result:=emat;   
 rtmaty(result,-(v.y+pi/2));
 rtmatx(result,(pi/2-v.x));
end;
//############################################################################//
procedure getloclatlonhdg(lat,lon,hdg,rad:double;var v:vec;var r:mat);
begin
 r:=emat;   
 rtmaty(r,-(lon+pi/2));
 rtmatx(r,(pi/2-lat));
 rtmaty(r,hdg);
 v:=vsph2rec(rad,lat,lon); 
end;  
//############################################################################//
function getrcbrv(vrp,vrv:vec;prmat:mat;pr,prtr:double):vec;
var sp:vec;
rtv,tsr:double;
rm:mat;
begin
 sp:=trr2l(rvmat(vrp,prmat));  
 vrec2sph(sp,pr);  
 rtv:=pr*2*pi/prtr;
 tsr:=rtv*cos(sp.x);

 getloclatlonhdg(sp.x,sp.y,-pi/2,pr,sp,rm);   
 result:=addv(rvmat(rvmat(vrv,prmat),rm),tvec(0,0,tsr));
end;   
//############################################################################//
function getrcbrvglobal(vrp,vrv:vec;prmat:mat;pr,prtr:double):vec;
var sp:vec;
rtv,tsr:double;
rm:mat;
begin
 sp:=trr2l(rvmat(vrp,prmat));  
 vrec2sph(sp,pr);  
 rtv:=pr*2*pi/prtr;
 tsr:=rtv*cos(sp.x);

 getloclatlonhdg(sp.x,sp.y,-pi/2,pr,sp,rm);   
 result:=lvmat(prmat,lvmat(rm,addv(rvmat(rvmat(vrv,prmat),rm),tvec(0,0,tsr)))); 
end; 
//############################################################################//
function rcbrv2global(prv,vrp,vrv:vec;prmat:mat;pr,prtr:double):vec;
var sp:vec;
rtv,tsr:double;
rm:mat;
begin
 sp:=trr2l(rvmat(vrp,prmat));  
 vrec2sph(sp,pr);  
 rtv:=pr*2*pi/prtr;
 tsr:=rtv*cos(sp.x);

 getloclatlonhdg(sp.x,sp.y,-pi/2,pr,sp,rm);
 result:=lvmat(prmat,lvmat(rm,subv(prv,tvec(0,0,tsr))));   
end;
//############################################################################//
//############################################################################// 
function vec32(a:vec):vec2;
begin
 result.x:=a.x;
 result.y:=a.y;
end;
function vec34(a:vec):quat;
begin
 result.x:=a.x;
 result.y:=a.y;
 result.z:=a.z;
 result.w:=0;
end;
     
//##############################################################################

function vec23(a:vec2):vec;
begin
 result.x:=a.x;
 result.y:=a.y;
 result.z:=0;
end;

//##############################################################################
procedure gvec(var x:double;var y:double;var z:double;a:vec);begin x:=a.x;y:=a.y;z:=a.z;end;
procedure vreps(var v:vec;e:double);
var t:double;
begin
 t:=1/e;
 v.x:=round(v.x*t)/t;
 v.y:=round(v.y*t)/t;
 v.z:=round(v.z*t)/t;
end;

procedure vscale(var v:vec;a,b,c:double);
begin
 v.x:=v.x*a;
 v.y:=v.y*b;
 v.z:=v.z*c;
end; 

function vteps(v:vec):vec;overload;begin if abs(v.x)<eps then v.x:=0;if abs(v.y)<eps then v.y:=0;if abs(v.z)<eps then v.z:=0;end; 
function vteps(v:quat):quat;overload;begin if abs(v.x)<eps then v.x:=0;if abs(v.y)<eps then v.y:=0;if abs(v.z)<eps then v.z:=0;if abs(v.w)<eps then v.w:=0;end; 
function vteps(v:mat):mat;overload;
begin 
 if abs(v[0].x)<eps then v[0].x:=0;if abs(v[0].y)<eps then v[0].y:=0;if abs(v[0].z)<eps then v[0].z:=0;
 if abs(v[1].x)<eps then v[1].x:=0;if abs(v[1].y)<eps then v[1].y:=0;if abs(v[1].z)<eps then v[1].z:=0;
 if abs(v[2].x)<eps then v[2].x:=0;if abs(v[2].y)<eps then v[2].y:=0;if abs(v[2].z)<eps then v[2].z:=0;
 result:=v;
end; 

//############################################################################//
//############################################################################// 
//############################### Matrices ###################################//
//############################################################################//
//############################################################################//

function emat:mat;overload;
begin
 result[0].x:=1; result[0].y:=0; result[0].z:=0;
 result[1].x:=0; result[1].y:=1; result[1].z:=0;
 result[2].x:=0; result[2].y:=0; result[2].z:=1;
end;
function ematq:matq;overload;
begin
 result[0].x:=1; result[0].y:=0; result[0].z:=0; result[0].w:=0;
 result[1].x:=0; result[1].y:=1; result[1].z:=0; result[1].w:=0;
 result[2].x:=0; result[2].y:=0; result[2].z:=1; result[2].w:=0;
 result[3].x:=0; result[3].y:=0; result[3].z:=0; result[3].w:=1;
end;
function emat5:mat5;overload;
begin
 result[0].x:=1; result[0].y:=0; result[0].z:=0; result[0].w:=0; result[0].t:=0;
 result[1].x:=0; result[1].y:=1; result[1].z:=0; result[1].w:=0; result[1].t:=0;
 result[2].x:=0; result[2].y:=0; result[2].z:=1; result[2].w:=0; result[2].t:=0;
 result[3].x:=0; result[3].y:=0; result[3].z:=0; result[3].w:=1; result[3].t:=0;
 result[4].x:=0; result[4].y:=0; result[4].z:=0; result[4].w:=0; result[4].t:=1;
end;
function emat5z:mat5;overload;
begin
 result[0].x:=1; result[0].y:=0; result[0].z:=0; result[0].w:=0; result[0].t:=0;
 result[1].x:=0; result[1].y:=1; result[1].z:=0; result[1].w:=0; result[1].t:=0;
 result[2].x:=0; result[2].y:=0; result[2].z:=1; result[2].w:=0; result[2].t:=0;
 result[3].x:=0; result[3].y:=0; result[3].z:=0; result[3].w:=1; result[3].t:=0;
 result[4].x:=0; result[4].y:=0; result[4].z:=0; result[4].w:=0; result[4].t:=1;
end;

function matq2mmatq(a:matq):mmatq;
begin
 result[0]:=tmquat(a[0].x,a[0].y,a[0].z,a[0].w);
 result[1]:=tmquat(a[1].x,a[1].y,a[1].z,a[1].w);
 result[2]:=tmquat(a[2].x,a[2].y,a[2].z,a[2].w);
 result[3]:=tmquat(a[3].x,a[3].y,a[3].z,a[3].w);
end;

function rvmat(b:vec;a:mat):vec;
begin
 result.x:=a[0].x*b.x+a[1].x*b.y+a[2].x*b.z;
 result.y:=a[0].y*b.x+a[1].y*b.y+a[2].y*b.z;
 result.z:=a[0].z*b.x+a[1].z*b.y+a[2].z*b.z;
end;
function lvmat(a:mat;b:vec):vec;
begin
 result.x:=a[0].x*b.x+a[0].y*b.y+a[0].z*b.z;
 result.y:=a[1].x*b.x+a[1].y*b.y+a[1].z*b.z;
 result.z:=a[2].x*b.x+a[2].y*b.y+a[2].z*b.z;
end;  
function rvmat(b:quat;a:matq):quat;
begin
 result.x:=a[0].x*b.x+a[1].x*b.y+a[2].x*b.z+a[3].x*b.w;
 result.y:=a[0].y*b.x+a[1].y*b.y+a[2].y*b.z+a[3].y*b.w;
 result.z:=a[0].z*b.x+a[1].z*b.y+a[2].z*b.z+a[3].z*b.w;
 result.w:=a[0].w*b.x+a[1].w*b.y+a[2].w*b.z+a[3].w*b.w;
end;
function lvmat(a:matq;b:quat):quat;
begin
 result.x:=a[0].x*b.x+a[0].y*b.y+a[0].z*b.z+a[0].w*b.w;
 result.y:=a[1].x*b.x+a[1].y*b.y+a[1].z*b.z+a[1].w*b.w;
 result.z:=a[2].x*b.x+a[2].y*b.y+a[2].z*b.z+a[2].w*b.w;
 result.w:=a[3].x*b.x+a[3].y*b.y+a[3].z*b.z+a[3].w*b.w;
end;  
function rvmat(b:vec;a:matq):vec;
begin
 result.x:=a[0].x*b.x+a[1].x*b.y+a[2].x*b.z;
 result.y:=a[0].y*b.x+a[1].y*b.y+a[2].y*b.z;
 result.z:=a[0].z*b.x+a[1].z*b.y+a[2].z*b.z;
end;
function lvmat(a:matq;b:vec):vec;
begin
 result.x:=a[0].x*b.x+a[0].y*b.y+a[0].z*b.z+a[0].w;
 result.y:=a[1].x*b.x+a[1].y*b.y+a[1].z*b.z+a[1].w;
 result.z:=a[2].x*b.x+a[2].y*b.y+a[2].z*b.z+a[2].w;
end;      
function rvmat(b:quat;a:mat5):quat;
begin
 result.x:=a[0].x*b.x+a[1].x*b.y+a[2].x*b.z+a[3].x*b.w;
 result.y:=a[0].y*b.x+a[1].y*b.y+a[2].y*b.z+a[3].y*b.w;
 result.z:=a[0].z*b.x+a[1].z*b.y+a[2].z*b.z+a[3].z*b.w;
 result.w:=a[0].w*b.x+a[1].w*b.y+a[2].w*b.z+a[3].w*b.w;
end;
function lvmat(a:mat5;b:quat):quat;
begin
 result.x:=a[0].x*b.x+a[0].y*b.y+a[0].z*b.z+a[0].w*b.w+a[0].t;
 result.y:=a[1].x*b.x+a[1].y*b.y+a[1].z*b.z+a[1].w*b.w+a[1].t;
 result.z:=a[2].x*b.x+a[2].y*b.y+a[2].z*b.z+a[2].w*b.w+a[2].t;
 result.w:=a[3].x*b.x+a[3].y*b.y+a[3].z*b.z+a[3].w*b.w+a[3].t;
end;     
      
function trmat(tm:mat):mat;
begin
 result[0].x:=tm[0].x; result[0].y:=tm[1].x; result[0].z:=tm[2].x;
 result[1].x:=tm[0].y; result[1].y:=tm[1].y; result[1].z:=tm[2].y;
 result[2].x:=tm[0].z; result[2].y:=tm[1].z; result[2].z:=tm[2].z;
end;   

function atmat(a:vec):mat;
var sinx,siny,sinz,cosx,cosy,cosz:double;
begin
 sinx:=sin(a.x);cosx:=cos(a.x);
 siny:=sin(a.y);cosy:=cos(a.y);
 sinz:=sin(a.z);cosz:=cos(a.z);

 //syz:=siny*sinz;
 //cxz:=cosx*cosz;
 //sxcz:=sinx*cosz;

 result[0].x:=cosy*cosz;
 result[0].y:=cosy*sinz;
 result[0].z:=-siny;
 result[1].x:=cosz*sinx*siny-sinz*cosx;
 result[1].y:=sinx*siny*sinz+cosx*cosz;
 result[1].z:=sinx*cosy;
 result[2].x:=cosx*siny*cosz+sinz*sinx;
 result[2].y:=sinz*cosx*siny-sinx*cosz;
 result[2].z:=cosx*cosy;
end;
function atmatz(a:vec):mat;
var sinx,siny,sinz,cosx,cosy,cosz:double;
begin
 sinx:=sin(-a.x);cosx:=cos(-a.x);
 siny:=sin(-a.y);cosy:=cos(-a.y);
 sinz:=sin(a.z);cosz:=cos(a.z);

 //syz:=siny*sinz;
 //cxz:=cosx*cosz;
 //sxcz:=sinx*cosz;

 result[0].x:=cosy*cosz;
 result[0].y:=cosy*sinz;
 result[0].z:=-siny;
 result[1].x:=cosz*sinx*siny-sinz*cosx;
 result[1].y:=sinx*siny*sinz+cosx*cosz;
 result[1].z:=sinx*cosy;
 result[2].x:=cosx*siny*cosz+sinz*sinx;
 result[2].y:=sinz*cosx*siny-sinx*cosz;
 result[2].z:=cosx*cosy;
end;

function tamat(a:mat):vec;
begin
 result.x:=arctan2(a[1].z,a[2].z);
 result.y:=-arcsin(a[0].z);
 result.z:=arctan2(a[0].y,a[0].x);
end; 
function tamatz(a:mat):vec;
begin
 result.x:=-arctan2(a[1].z,a[2].z);
 result.y:=arcsin(a[0].z);
 result.z:=arctan2(a[0].y,a[0].x);
end;     

function mulm(a,b:mat):mat;overload; 
begin
 result[0].x:=a[0].x*b[0].x+a[0].y*b[1].x+a[0].z*b[2].x;
 result[0].y:=a[0].x*b[0].y+a[0].y*b[1].y+a[0].z*b[2].y;
 result[0].z:=a[0].x*b[0].z+a[0].y*b[1].z+a[0].z*b[2].z;
 result[1].x:=a[1].x*b[0].x+a[1].y*b[1].x+a[1].z*b[2].x;
 result[1].y:=a[1].x*b[0].y+a[1].y*b[1].y+a[1].z*b[2].y;
 result[1].z:=a[1].x*b[0].z+a[1].y*b[1].z+a[1].z*b[2].z;
 result[2].x:=a[2].x*b[0].x+a[2].y*b[1].x+a[2].z*b[2].x;
 result[2].y:=a[2].x*b[0].y+a[2].y*b[1].y+a[2].z*b[2].y;
 result[2].z:=a[2].x*b[0].z+a[2].y*b[1].z+a[2].z*b[2].z;
end;
function mulm(a,b:matq):matq;overload; 
begin
 result[0].x:=a[0].x*b[0].x+a[0].y*b[1].x+a[0].z*b[2].x+a[0].w*b[3].x;
 result[0].y:=a[0].x*b[0].y+a[0].y*b[1].y+a[0].z*b[2].y+a[0].w*b[3].y;
 result[0].z:=a[0].x*b[0].z+a[0].y*b[1].z+a[0].z*b[2].z+a[0].w*b[3].z;
 result[0].w:=a[0].x*b[0].w+a[0].y*b[1].w+a[0].z*b[2].w+a[0].w*b[3].w;
 result[1].x:=a[1].x*b[0].x+a[1].y*b[1].x+a[1].z*b[2].x+a[1].w*b[3].x;
 result[1].y:=a[1].x*b[0].y+a[1].y*b[1].y+a[1].z*b[2].y+a[1].w*b[3].y;
 result[1].z:=a[1].x*b[0].z+a[1].y*b[1].z+a[1].z*b[2].z+a[1].w*b[3].z;
 result[1].w:=a[1].x*b[0].w+a[1].y*b[1].w+a[1].z*b[2].w+a[1].w*b[3].w;
 result[2].x:=a[2].x*b[0].x+a[2].y*b[1].x+a[2].z*b[2].x+a[2].w*b[3].x;
 result[2].y:=a[2].x*b[0].y+a[2].y*b[1].y+a[2].z*b[2].y+a[2].w*b[3].y;
 result[2].z:=a[2].x*b[0].z+a[2].y*b[1].z+a[2].z*b[2].z+a[2].w*b[3].z;
 result[2].w:=a[2].x*b[0].w+a[2].y*b[1].w+a[2].z*b[2].w+a[2].w*b[3].w;
 result[3].x:=a[3].x*b[0].x+a[3].y*b[1].x+a[3].z*b[2].x+a[3].w*b[3].x;
 result[3].y:=a[3].x*b[0].y+a[3].y*b[1].y+a[3].z*b[2].y+a[3].w*b[3].y;
 result[3].z:=a[3].x*b[0].z+a[3].y*b[1].z+a[3].z*b[2].z+a[3].w*b[3].z;
 result[3].w:=a[3].x*b[0].w+a[3].y*b[1].w+a[3].z*b[2].w+a[3].w*b[3].w;
end;      
function mulm(a,b:mat5):mat5;overload; 
begin
 result[0].x:=a[0].x*b[0].x+a[0].y*b[1].x+a[0].z*b[2].x+a[0].w*b[3].x+a[0].t*b[4].x;
 result[0].y:=a[0].x*b[0].y+a[0].y*b[1].y+a[0].z*b[2].y+a[0].w*b[3].y+a[0].t*b[4].y;
 result[0].z:=a[0].x*b[0].z+a[0].y*b[1].z+a[0].z*b[2].z+a[0].w*b[3].z+a[0].t*b[4].z;
 result[0].w:=a[0].x*b[0].w+a[0].y*b[1].w+a[0].z*b[2].w+a[0].w*b[3].w+a[0].t*b[4].w;
 result[0].t:=a[0].x*b[0].t+a[0].y*b[1].t+a[0].z*b[2].t+a[0].w*b[3].t+a[0].t*b[4].t;
 result[1].x:=a[1].x*b[0].x+a[1].y*b[1].x+a[1].z*b[2].x+a[1].w*b[3].x+a[1].t*b[4].x;
 result[1].y:=a[1].x*b[0].y+a[1].y*b[1].y+a[1].z*b[2].y+a[1].w*b[3].y+a[1].t*b[4].y;
 result[1].z:=a[1].x*b[0].z+a[1].y*b[1].z+a[1].z*b[2].z+a[1].w*b[3].z+a[1].t*b[4].z;
 result[1].w:=a[1].x*b[0].w+a[1].y*b[1].w+a[1].z*b[2].w+a[1].w*b[3].w+a[1].t*b[4].w;
 result[1].t:=a[1].x*b[0].t+a[1].y*b[1].t+a[1].z*b[2].t+a[1].w*b[3].t+a[1].t*b[4].t;
 result[2].x:=a[2].x*b[0].x+a[2].y*b[1].x+a[2].z*b[2].x+a[2].w*b[3].x+a[2].t*b[4].x;
 result[2].y:=a[2].x*b[0].y+a[2].y*b[1].y+a[2].z*b[2].y+a[2].w*b[3].y+a[2].t*b[4].y;
 result[2].z:=a[2].x*b[0].z+a[2].y*b[1].z+a[2].z*b[2].z+a[2].w*b[3].z+a[2].t*b[4].z;
 result[2].w:=a[2].x*b[0].w+a[2].y*b[1].w+a[2].z*b[2].w+a[2].w*b[3].w+a[2].t*b[4].w;
 result[2].t:=a[2].x*b[0].t+a[2].y*b[1].t+a[2].z*b[2].t+a[2].w*b[3].t+a[2].t*b[4].t;
 result[3].x:=a[3].x*b[0].x+a[3].y*b[1].x+a[3].z*b[2].x+a[3].w*b[3].x+a[3].t*b[4].x;
 result[3].y:=a[3].x*b[0].y+a[3].y*b[1].y+a[3].z*b[2].y+a[3].w*b[3].y+a[3].t*b[4].y;
 result[3].z:=a[3].x*b[0].z+a[3].y*b[1].z+a[3].z*b[2].z+a[3].w*b[3].z+a[3].t*b[4].z;
 result[3].w:=a[3].x*b[0].w+a[3].y*b[1].w+a[3].z*b[2].w+a[3].w*b[3].w+a[3].t*b[4].w;
 result[3].t:=a[3].x*b[0].t+a[3].y*b[1].t+a[3].z*b[2].t+a[3].w*b[3].t+a[3].t*b[4].t;
 result[4].x:=a[4].x*b[0].x+a[4].y*b[1].x+a[4].z*b[2].x+a[4].w*b[3].x+a[4].t*b[4].x;
 result[4].y:=a[4].x*b[0].y+a[4].y*b[1].y+a[4].z*b[2].y+a[4].w*b[3].y+a[4].t*b[4].y;
 result[4].z:=a[4].x*b[0].z+a[4].y*b[1].z+a[4].z*b[2].z+a[4].w*b[3].z+a[4].t*b[4].z;
 result[4].w:=a[4].x*b[0].w+a[4].y*b[1].w+a[4].z*b[2].w+a[4].w*b[3].w+a[4].t*b[4].w;
 result[4].t:=a[4].x*b[0].t+a[4].y*b[1].t+a[4].z*b[2].t+a[4].w*b[3].t+a[4].t*b[4].t;
end;

function epsmat(a:mat):mat;
var i:integer;
begin
 for i:=0 to 2 do begin
  result[i].x:=a[i].x;if abs(a[i].x)<eps then result[i].x:=0;
  result[i].y:=a[i].y;if abs(a[i].y)<eps then result[i].y:=0;
  result[i].z:=a[i].z;if abs(a[i].z)<eps then result[i].z:=0;
 end;
end;

procedure rtmatx(var a:mat;an:double);
var result:mat;
begin
 result[0].x:=a[0].x*1+a[0].y*0      +a[0].z*0;
 result[0].y:=a[0].x*0+a[0].y*cos(an)-a[0].z*sin(an);
 result[0].z:=a[0].x*0+a[0].y*sin(an)+a[0].z*cos(an);
 result[1].x:=a[1].x*1+a[1].y*0      +a[1].z*0;
 result[1].y:=a[1].x*0+a[1].y*cos(an)-a[1].z*sin(an);
 result[1].z:=a[1].x*0+a[1].y*sin(an)+a[1].z*cos(an);
 result[2].x:=a[2].x*1+a[2].y*0      +a[2].z*0;
 result[2].y:=a[2].x*0+a[2].y*cos(an)-a[2].z*sin(an);
 result[2].z:=a[2].x*0+a[2].y*sin(an)+a[2].z*cos(an);
 a:=result;
end;
procedure rtmaty(var a:mat;an:double);
var result:mat;
begin
 result[0].x:=a[0].x*cos(an)+a[0].y*0-a[0].z*sin(an);
 result[0].y:=a[0].x*0      +a[0].y*1+a[0].z*0;
 result[0].z:=a[0].x*sin(an)+a[0].y*0+a[0].z*cos(an);
 result[1].x:=a[1].x*cos(an)+a[1].y*0-a[1].z*sin(an);
 result[1].y:=a[1].x*0      +a[1].y*1+a[1].z*0;
 result[1].z:=a[1].x*sin(an)+a[1].y*0+a[1].z*cos(an);
 result[2].x:=a[2].x*cos(an)+a[2].y*0-a[2].z*sin(an);
 result[2].y:=a[2].x*0      +a[2].y*1+a[2].z*0;
 result[2].z:=a[2].x*sin(an)+a[2].y*0+a[2].z*cos(an);
 a:=result;
end;
procedure rtmatz(var a:mat;an:double);
var result:mat;
begin
 result[0].x:= a[0].x*cos(an)-a[0].y*sin(an)-a[0].z*0;
 result[0].y:= a[0].x*sin(an)+a[0].y*cos(an)+a[0].z*0;
 result[0].z:= a[0].x*0      +a[0].y*0      +a[0].z*1;
 result[1].x:= a[1].x*cos(an)-a[1].y*sin(an)-a[1].z*0;
 result[1].y:= a[1].x*sin(an)+a[1].y*cos(an)+a[1].z*0;
 result[1].z:= a[1].x*0      +a[1].y*0      +a[1].z*1;
 result[2].x:= a[2].x*cos(an)-a[2].y*sin(an)-a[2].z*0;
 result[2].y:= a[2].x*sin(an)+a[2].y*cos(an)+a[2].z*0;
 result[2].z:= a[2].x*0      +a[2].y*0      +a[2].z*1;
 a:=result;
end;

procedure rtmataa(var a:mat;an:double;ax:vec);
var c,cb,s,xs,ys,zs,xc,yc,zc,xyc,yzc,zxc:double;
result:mat;
begin
 c:=cos(an);s:=sin(an);Cb:=1-c;
 xs:=ax.x*s;   ys:=ax.y*s;   zs:=ax.z*s;
 xC:=ax.x*Cb;  yC:=ax.y*Cb;  zC:=ax.z*Cb;
 xyC:=ax.x*yC; yzC:=ax.y*zC; zxC:=ax.z*xC;
 result[0].x:=ax.x*xC+c; result[0].y:=xyC-zs;    result[0].z:=zxC+ys;
 result[1].x:=xyC+zs;    result[1].y:=ax.y*yC+c; result[1].z:=yzC-xs;
 result[2].x:=zxC-ys;    result[2].y:=yzC+xs;    result[2].z:=ax.z*zC+c;
 a:=result;
end;

function vecs2mat(f,up:vec):mat;
var s,u:vec;
m:mat;
begin
 result:=emat;
 
 f:=nrvec(f);
 up:=vmulv(vmulv(f,up),f);
 if (up.x=0)and(up.y=0)and(up.z=0)then exit;
 up:=nrvec(up);

 s:=vmulv(f,up);
 u:=vmulv(s,f);
 
 m[0].x:=s.x;
 m[1].x:=s.y;
 m[2].x:=s.z;
		
 m[0].y:=f.x;
 m[1].y:=f.y;
 m[2].y:=f.z;
		
 m[0].z:=u.x;
 m[1].z:=u.y;
 m[2].z:=u.z;
 
 result:=m;
end;

function vecs2matz(f,up:vec):mat;
var s,u:vec;
m:mat;
begin
 result:=emat;

 f:=nrvec(f);
 up:=vmulv(vmulv(f,up),f);
 if (up.x=0)and(up.y=0)and(up.z=0)then exit;
 up:=nrvec(up);

 s:=vmulv(f,up);
 u:=vmulv(s,f);
 
 m[0].x:=s.x;
 m[1].x:=s.y;
 m[2].x:=s.z;
		
 m[0].y:=f.x;
 m[1].y:=f.y;
 m[2].y:=f.z;
		
 m[0].z:=u.x;
 m[1].z:=u.y;
 m[2].z:=u.z;
 
 result:=epsmat(mulm(m,atmat(tvec(pi/2,0,pi))));
end;

function v2vrotmat(v1,v2:vec):mat;
var fv,tv,vs,v,vt:vec;
ca:double;
begin
 fv:=nrvec(v1);
 tv:=nrvec(v2);

 vs:=vmulv(fv,tv); // axis multiplied by sin

 v:=nrvec(vs);// axis of rotation
 ca:=smulv(fv,tv); // cos angle

 vt:=nmulv(v,(1-ca));

 result[0].x:=vt.x*v.x+ca;
 result[1].y:=vt.y*v.y+ca;
 result[2].z:=vt.z*v.z+ca;

 vt.x:=vt.x*v.y;
 vt.z:=vt.z*v.x;
 vt.y:=vt.y*v.z;

 result[0].y:=vt.x-vs.z;
 result[0].z:=vt.z+vs.y;
 result[1].x:=vt.x+vs.z;
 result[1].z:=vt.y-vs.x;
 result[2].x:=vt.z-vs.y;
 result[2].y:=vt.y+vs.x;
end;
        {
function tmul(A, const VECTOR3 &b):vec;

	return _V (
		A.m11*b.x + A.m21*b.y + A.m31*b.z,
		A.m12*b.x + A.m22*b.y + A.m32*b.z,
		A.m13*b.x + A.m23*b.y + A.m33*b.z);
    }


//############################################################################//
//############################################################################//  
function CreateRotationMatrix(const axis:vec;angle:double):matqa;
var cosine,sine,one_minus_cosine:extended;
begin
 SinCos(angle,sine,cosine);
 one_minus_cosine:=1-cosine;

 Result[0,0]:=(one_minus_cosine*axis.x*axis.x)+cosine;
 Result[0,1]:=(one_minus_cosine*axis.x*axis.y)-(axis.z*sine);
 Result[0,2]:=(one_minus_cosine*axis.z*axis.x)+(axis.y*sine);
 Result[0,3]:=0;

 Result[1,0]:=(one_minus_cosine*axis.x*axis.y)+(axis.z*sine);
 Result[1,1]:=(one_minus_cosine*axis.y*axis.y)+cosine;
 Result[1,2]:=(one_minus_cosine*axis.y*axis.z)-(axis.x*sine);
 Result[1,3]:=0;

 Result[2,0]:=(one_minus_cosine*axis.z*axis.x)-(axis.y*sine);
 Result[2,1]:=(one_minus_cosine*axis.y*axis.z)+(axis.x*sine);
 Result[2,2]:=(one_minus_cosine*axis.z*axis.z)+cosine;
 Result[2,3]:=0;

 Result[3,0]:=0;
 Result[3,1]:=0;
 Result[3,2]:=0;
 Result[3,3]:=1;
end; 
//############################################################################//        
function quat2rotm(q:quat):mat;
begin
 result[0]:=tvec(1-2*q.y*q.y-2*q.z*q.z,2*q.x*q.y  -2*q.z*q.w,2*q.x*q.z  +2*q.y*q.w);
 result[1]:=tvec(2*q.x*q.y  +2*q.z*q.w,1-2*q.x*q.x-2*q.z*q.z,2*q.y*q.z  -2*q.x*q.w);
 result[2]:=tvec(2*q.x*q.z  -2*q.y*q.w,2*q.y*q.z  +2*q.x*q.w,1-2*q.x*q.x-2*q.y*q.y);
end;
//############################################################################//        
function quat2orotm(q:quat):mat;
var axis,upv,rotv:vec;
ang:double;
begin
 getqaa(q,axis,ang);
 upv:=tvec(0,1,0);rotv:=tvec(0,0,1);
 rotatevector(upv,axis,ang);
 rotatevector(rotv,axis,ang);

 result:=vecs2mat(rotv,upv);
 rtmatz(result,pi);   
 rtmaty(result,-pi/2);
end;
//############################################################################//        
function quat2rotmz(q:quat):mat;
var axis,upv,rotv:vec;
ang:double;
begin
 getqaa(q,axis,ang);
 upv:=tvec(0,1,0);rotv:=tvec(0,0,1);
 rotatevector(upv,axis,ang);
 rotatevector(rotv,axis,ang);

 result:=vecs2mat(rotv,upv);  
 {
 rtmatx(result,-pi/2);  
 rtmatz(result,pi);     
 rtmaty(result,-pi/2);  
 }
 result:=epsmat(result);
end;
//##############################################################################

function VectorTransform(const V:quata;const M:matqa):quata;
begin
 Result[0]:=V[0]*M[0,0]+V[1]*M[1,0]+V[2]*M[2,0]+V[3]*M[3,0];
 Result[1]:=V[0]*M[0,1]+V[1]*M[1,1]+V[2]*M[2,1]+V[3]*M[3,1];
 Result[2]:=V[0]*M[0,2]+V[1]*M[1,2]+V[2]*M[2,2]+V[3]*M[3,2];
 Result[3]:=V[0]*M[0,3]+V[1]*M[1,3]+V[2]*M[2,3]+V[3]*M[3,3];
end;
            
//##############################################################################          
procedure RotateVector(var vector:vec;const axis:vec;angle:double);
var rotMatrix:matqa;
tve:quata;
begin
 rotMatrix:=CreateRotationMatrix(axis,Angle);
 tve[0]:=vector.x; tve[1]:=vector.y; tve[2]:=vector.z; tve[3]:=0;
 tve:=VectorTransform(tve,rotMatrix);
 vector.x:=tve[0]; vector.y:=tve[1]; vector.z:=tve[2];
end;       
//##############################################################################          
procedure RotateVector(var vector:mvec;const axis:vec;angle:double);
var rotMatrix:matqa;
tve:quata;
begin
 rotMatrix:=CreateRotationMatrix(axis,Angle);
 tve[0]:=vector.x; tve[1]:=vector.y; tve[2]:=vector.z; tve[3]:=0;
 tve:=VectorTransform(tve,rotMatrix);
 vector.x:=tve[0]; vector.y:=tve[1]; vector.z:=tve[2];
end;
           
//############################################################################//
//############################################################################//
//############################### Quaternion #################################//
//############################################################################//
//############################################################################//
           
function trquat(x,y,z:double):quat;
var ex,ey,ez:double;
cr,cp,cy,sr,sp,sy,cpcy,spsy:double;
begin
 ex:=x/2; ey:=y/2; ez:=z/2;
 cr:=cos(ex); cp:=cos(ey); cy:=cos(ez);
 sr:=sin(ex); sp:=sin(ey); sy:=sin(ez);

 cpcy:=cp*cy;
 spsy:=sp*sy;

 result.x:=sr*cpcy-cr*spsy;
 result.y:=cr*sp*cy+sr*cp*sy;
 result.z:=cr*cp*sy-sr*sp*cy;
 result.w:=cr*cpcy+sr*spsy;

 result:=nrvec(result); 
end;          
//##############################################################################
function rotm2quat(a:mat):quat;
var ta:vec;
begin                        
 rtmaty(a,pi/2); 
 rtmatx(a,-pi/2); 
 ta:=tamat(vteps(a));
 result:=vmulv(trquat(0,0,0),trquat(ta.x,ta.y,ta.z));
end;
//##############################################################################
function rotm2quatz(a:mat):quat;
var ta:vec;
begin             
 ta:=tamat(vteps(a));
 result:=trquat(ta.x,ta.y,ta.z);
end;
//##############################################################################
function vtrquat(a:vec):quat;begin result:=trquat(a.x,a.y,a.z);end;
//############################################################################//
//############################################################################//
procedure getqaa(q:quat;var v:vec;var ang:double);
var temp_angle,scale:double;
begin
 temp_angle:=arccos(q.w);
 scale:=sqrt(sqr(q.x)+sqr(q.y)+sqr(q.z));

 if (scale=0) then begin
  ang:=0;
  v.x:=0;
  v.y:=0;
  v.z:=1;    
  v:=nrvec(v);
 end else begin
  ang:=temp_angle*2.0;
  v.x:=q.x/scale;
  v.y:=q.y/scale;
  v.z:=q.z/scale;
  v:=nrvec(v);
 end;
end;
//############################################################################//
function qrot(iv:vec;iq:quat):vec;
var tv,axis:vec;
ang:double;
tq:quat;
begin
 tv:=iv;
 tq:=qmul(trquat(iv.x,iv.y,iv.z),iq);
 getqaa(tq,axis,ang);
 rotatevector(tv,axis,ang);
 result:=tv;
end;
//############################################################################//
function qunrot(iv:vec;iq:quat):vec;
var tv,axis:vec;
ang:double;
tq:quat;
begin
 tv:=iv;
 tq:=qmul(trquat(iv.x,iv.y,iv.z),iq);
 getqaa(tq,axis,ang);
 rotatevector(tv,axis,-ang);
 result:=tv;
end;
//############################################################################//
function qrotvec(v:vec;q:quat):vec;
var axis:vec;
ang:double;
begin
 getqaa(q,axis,ang);
 rotatevector(v,axis,ang);
 result:=v;
end;
//############################################################################//
function qunrotvec(v:vec;q:quat):vec;
var axis:vec;
ang:double;
begin
 getqaa(q,axis,ang);
 rotatevector(v,axis,-ang);
 result:=v;
end;
//############################################################################//
function qmul(q1,q2:quat):quat;
begin
 result.w:=q1.w*q2.w-q1.x*q2.x-q1.y*q2.y-q1.z*q2.z;
 result.x:=q1.w*q2.x+q1.x*q2.w+q1.y*q2.z-q1.z*q2.y;
 result.y:=q1.w*q2.y+q1.y*q2.w+q1.z*q2.x-q1.x*q2.z;
 result.z:=q1.w*q2.z+q1.z*q2.w+q1.x*q2.y-q1.y*q2.x;
end;
//############################################################################//
function qinv(q:quat):quat;
begin
 result.x:=-q.x;
 result.y:=-q.y;
 result.z:=-q.z;
 result.w:=q.w;
end;
//############################################################################//
//############################################################################//
//############################################################################//            
//############################################################################//
//############################################################################//
//############################# Geometry #####################################//
//############################################################################//
//############################################################################//  
//############################################################################//
//############################################################################//
function line2sph(v1,v2,v3:vec;r:double;var px:vec):double;
var a,b,c,u1,u2:double;
p1,p2:vec;
begin
 a:=sqr(v2.x-v1.x)+sqr(v2.y-v1.y)+sqr(v2.z-v1.z);
 b:=2*((v2.x-v1.x)*(v1.x-v3.x)+(v2.y-v1.y)*(v1.y-v3.y)+(v2.z-v1.z)*(v1.z-v3.z));
 c:=sqr(v3.x)+sqr(v3.y)+sqr(v3.z)+sqr(v1.x)+sqr(v1.y)+sqr(v1.z)-2*(v3.x*v1.x+v3.y*v1.y+v3.z*v1.z)-sqr(r); 
 result:=b*b-4*a*c;
 if result>=0 then begin 
  u1:=(-b+sqrt(result))/(2*a); u2:=(-b-sqrt(result))/(2*a); 
  p1.x:=v1.x+u1*(v2.x-v1.x);
  p1.y:=v1.y+u1*(v2.y-v1.y);
  p1.z:=v1.z+u1*(v2.z-v1.z);
  p2.x:=v1.x+u2*(v2.x-v1.x);
  p2.y:=v1.y+u2*(v2.y-v1.y);
  p2.z:=v1.z+u2*(v2.z-v1.z);
  px:=addv(p1,nmulv(subv(p2,p1),0.5));
 end;
end;
//############################################################################//
function pntipoly(x,y:double;n:integer;var xpo,ypo:arrdbl):boolean;
var i:integer;
begin
 result:=false;
 for i:=0 to n-1 do if not((y>ypo[i])xor(y<=ypo[i+1]))then if x-xpo[i]<(y-ypo[i])*(xpo[i+1]-xpo[i])/(ypo[i+1]-ypo[i]) then result:=not result;
end;
//############################################################################//
function pntitri(x,y:double;a,b,c:vec2):boolean;
var i:integer;
xpi,ypi:array[0..3]of double;
begin
 xpi[0]:=a.x;
 xpi[1]:=b.x;
 xpi[2]:=c.x;
 xpi[3]:=a.x;
 ypi[0]:=a.y;
 ypi[1]:=b.y;
 ypi[2]:=c.y;
 ypi[3]:=a.y;
 result:=false;
 for i:=0 to 2 do if not ((y>ypi[i]) xor (y<=ypi[i+1])) then if x-xpi[i]<(y-ypi[i])*(xpi[i+1]-xpi[i])/(ypi[i+1]-ypi[i]) then result:=not result;
end;
//############################################################################//
function p_intri(n,vx,vy,vz,p:mvec):boolean;
var l1,l2,l3:mvec;
angle,dot1,dot2,dot3:single;
begin
 l1:=nrvec(subv(vx,p));
 l2:=nrvec(subv(vy,p));
 l3:=nrvec(subv(vz,p));

 dot1:=smulv(l1,l2);
 dot2:=smulv(l2,l3);
 dot3:=smulv(l3,l1);

 angle:=arccos(dot1)+arccos(dot2)+arccos(dot3);

 result:=abs(angle-2*pi)<0.01;
end;
//############################################################################//
//############################################################################//
       {
function t2lcc(A,B,C,d,e:vec;var alt:double):boolean;
var p1,p2,p3,p4,p,cr:vec;
delta,u,v,t:double;
begin
 p1:=subv(d,a);
 p2:=subv(e,d);
 p3:=subv(b,a);
 p4:=subv(c,a);

 cr:=vmulv(p3,p4);
 delta:=smulv(p2,cr);
 if (delta=0) then begin result:=false; alt:=0; exit; end;

 t:=smulv(p1,cr)/delta;
 if (t<=0)or(t>=1) then begin result:=false; alt:=0; exit; end;

 cr:=vmulv(p1,p4);
 u:=smulv(p2,cr)/delta;
 if (u<=0)or(u>=1) then begin result:=false; alt:=0; exit; end;

 cr:=vmulv(p3,p1);
 v:=smulv(p2,cr)/delta;
 if (v<=0)or(v>=1) then begin result:=false; alt:=0; exit; end;

 if (u+v)>1 then begin result:=false; alt:=0; exit; end;

 p:=addv(addv(a,nmulv(p3,u)),nmulv(p4,v));
 alt:=sqrt(sqr(p.x-d.x)+sqr(p.y-d.y)+sqr(p.z-d.z));
 result:=true;
end;  }
function t2lcc(A,B,C,D,E:vec;var alt:double;r:double):boolean;
var p1,p2,p3,p4,p:vec;
delta,u,v:double;
begin
 p1:=subv(d,a);
 p2:=subv(e,d);
 p3:=subv(b,a);
 p4:=subv(c,a);

 delta:=smulv(p2,vmulv(p3,p4));
 if (delta=0) then begin result:=false; alt:=0; exit; end;

 u:=smulv(p2,vmulv(p1,p4))/delta;
 if (u<=0)or(u>=1) then begin result:=false; alt:=0; exit; end;

 v:=smulv(p2,vmulv(p3,p1))/delta;
 if (v<=0)or(v>=1) then begin result:=false; alt:=0; exit; end;

 if (u+v)>1 then begin result:=false; alt:=0; exit; end;

 p:=addv(addv(a,nmulv(p3,u)),nmulv(p4,v));
 alt:=sqrt(sqr(p.x)+sqr(p.y)+sqr(p.z))-r;
 result:=true;
end;
//############################################################################//
function t2lccnt(A,B,C,D,E:vec;var alt:double):boolean;
var p1,p2,p3,p4,p,cr:vec;
delta,u,v:double;
begin
 p1:=subv(d,a);
 p2:=subv(e,d);
 p3:=subv(b,a);
 p4:=subv(c,a);

 cr:=vmulv(p3,p4);
 delta:=smulv(p2,cr);
 if (delta=0) then begin result:=false; alt:=0; exit; end;

 cr:=vmulv(p1,p4);
 u:=smulv(p2,cr)/delta;
 if (u<=0)or(u>=1) then begin result:=false; alt:=0; exit; end;

 cr:=vmulv(p3,p1);
 v:=smulv(p2,cr)/delta;
 if (v<=0)or(v>=1) then begin result:=false; alt:=0; exit; end;

 if (u+v)>1 then begin result:=false; alt:=0; exit; end;

 p:=addv(addv(a,nmulv(p3,u)),nmulv(p4,v));
 alt:=sqrt(sqr(p.x-d.x)+sqr(p.y-d.y)+sqr(p.z-d.z));
 result:=true;
end;
        {
function t2lccu(A,B,C,D,E:vec;var alt:double):boolean;
var p1,p2,p3,p4,cr,p:vec;
delta,t,u,v:double;
begin
 p1:=subv(d,a);
 p2:=subv(e,d);
 p3:=subv(b,a);
 p4:=subv(c,a);

 cr:=vmulv(p3,p4);
 delta:=smulv(p2,cr);
 if (delta=0) then begin result:=false; alt:=0; exit; end;

 t:=smulv(p1,cr)/delta;
 if (t<=0)or(t>=1) then begin result:=false; alt:=0; exit; end;

 cr:=vmulv(p1,p4);
 u:=smulv(p2,cr)/delta;
 if (u<=0)or(u>=1) then begin result:=false; alt:=0; exit; end;

 cr:=vmulv(p3,p1);
 v:=smulv(p2,cr)/delta;
 if (v<=0)or(v>=1) then begin result:=false; alt:=0; exit; end;

 if (u+v)>1 then begin result:=false; alt:=0; exit; end;

 p:=addv(addv(a,nmulv(p3,u)),nmulv(p4,v));
 alt:=p.z;
 result:=true;
end;     }

{
Тогда:
D+(D-E)*t =A + (B-A)*u + (C-A)*v (Система трех уравнений с тремя неизвестными, если говорить про координаты x,y,z)
Обозначим для простоты:
p1=D - A
p2=E - D
p3=B - A
p4=C - A
delta=Dot (p2, Cross(p3, p4) );
Если delta равна нулю, то отрезок параллелен плоскости треугольника, иначе:
t=(Dot( p1, Cross(p3, p4) ) / delta;
Если t не находится в интервале от (0, 1), то отрезок не пересекает плоскость треугольника, иначе:
u=(Dot( p2, Cross(p1, p4) ) / delta;
Если u не находится в интервале от (0, 1), то отрезок не пересекает треугольник, иначе:
v=(Dot( p2, Cross(p3, p1) ) / delta;
Если v не находится в интервале от (0, 1), то отрезок не пересекает треугольник, иначе:
Если (u + v) > 1, то отрезок не пересекает треугольник, иначе:
Отрезок пересекает треугольник, и точка пересечения:
P=A + p3*u + p4*v;
}

//##############################################################################

function lfi(pa,pb,pc,p1,p2,nn:vec;var p:vec):boolean;
var
 d,a1,a2,a3,total,denom,mu:double;
 pa1,pa2,pa3,n:vec;
begin
   //Calculate the parameters for the plane
   n.x:=(pb.y-pa.y)*(pc.z-pa.z)-(pb.z-pa.z)*(pc.y-pa.y);
   n.y:=(pb.z-pa.z)*(pc.x-pa.x)-(pb.x-pa.x)*(pc.z-pa.z);
   n.z:=(pb.x-pa.x)*(pc.y-pa.y)-(pb.y-pa.y)*(pc.x-pa.x);
   n:=nrvec(n);
   d:=-n.x*pa.x-n.y*pa.y-n.z*pa.z;

   // Calculate the position on the line that intersects the plane */
   denom:=n.x*(p2.x-p1.x)+n.y*(p2.y-p1.y)+n.z*(p2.z-p1.z);
   if abs(denom)<eps then begin         // Line and plane don't intersect */
    result:=false;
    exit;
   end;
   mu:=-(d+n.x*p1.x+n.y*p1.y+n.z*p1.z)/denom;
   p.x:=p1.x+mu*(p2.x-p1.x);
   p.y:=p1.y+mu*(p2.y-p1.y);
   p.z:=p1.z+mu*(p2.z-p1.z);
   if (mu<0)or(mu>1) then begin   // Intersection not along line segment */
    result:=false;
    exit;
   end;
   // Determine whether or not the intersection point is bounded by pa,pb,pc */
   pa1.x:=pa.x-p.x;
   pa1.y:=pa.y-p.y;
   pa1.z:=pa.z-p.z;
   pa1:=nrvec(pa1);
   pa2.x:=pb.x-p.x;
   pa2.y:=pb.y-p.y;
   pa2.z:=pb.z-p.z;
   pa2:=nrvec(pa2);
   pa3.x:=pc.x-p.x;
   pa3.y:=pc.y-p.y;
   pa3.z:=pc.z-p.z;
   pa3:=nrvec(pa3);
   a1:=pa1.x*pa2.x+pa1.y*pa2.y+pa1.z*pa2.z;
   a2:=pa2.x*pa3.x+pa2.y*pa3.y+pa2.z*pa3.z;
   a3:=pa3.x*pa1.x+pa3.y*pa1.y+pa3.z*pa1.z;
   total:=arccos(a1)+arccos(a2)+arccos(a3);
   if abs(total-2*pi)>eps then begin
    result:=false;
    exit;
   end;
   result:=true;
end;











 {
 int LineFacet(p1,p2,pa,pb,pc,p)
XYZ p1,p2,pa,pb,pc,*p;

   double d;
   double a1,a2,a3;
   double total,denom,mu;
   XYZ n,pa1,pa2,pa3;

   /* Calculate the parameters for the plane */
   n.x=(pb.y - pa.y)*(pc.z - pa.z) - (pb.z - pa.z)*(pc.y - pa.y);
   n.y=(pb.z - pa.z)*(pc.x - pa.x) - (pb.x - pa.x)*(pc.z - pa.z);
   n.z=(pb.x - pa.x)*(pc.y - pa.y) - (pb.y - pa.y)*(pc.x - pa.x);
   Normalise(&n);
   d=- n.x * pa.x - n.y * pa.y - n.z * pa.z;

   /* Calculate the position on the line that intersects the plane */
   denom=n.x * (p2.x - p1.x) + n.y * (p2.y - p1.y) + n.z * (p2.z - p1.z);
   if (ABS(denom) < EPS)         /* Line and plane don't intersect */
      return(FALSE);
   mu=- (d + n.x * p1.x + n.y * p1.y + n.z * p1.z) / denom;
   p->x=p1.x + mu * (p2.x - p1.x);
   p->y=p1.y + mu * (p2.y - p1.y);
   p->z=p1.z + mu * (p2.z - p1.z);
   if (mu < 0 || mu >; 1)   /* Intersection not along line segment */
      return(FALSE);

   /* Determine whether or not the intersection point is bounded by pa,pb,pc */
   pa1.x=pa.x - p->x;
   pa1.y=pa.y - p->y;
   pa1.z=pa.z - p->z;
   Normalise(&pa1);
   pa2.x=pb.x - p->x;
   pa2.y=pb.y - p->y;
   pa2.z=pb.z - p->z;
   Normalise(&pa2);
   pa3.x=pc.x - p->x;
   pa3.y=pc.y - p->y;
   pa3.z=pc.z - p->z;
   Normalise(&pa3);
   a1=pa1.x*pa2.x + pa1.y*pa2.y + pa1.z*pa2.z;
   a2=pa2.x*pa3.x + pa2.y*pa3.y + pa2.z*pa3.z;
   a3=pa3.x*pa1.x + pa3.y*pa1.y + pa3.z*pa1.z;
   total=(acos(a1) + acos(a2) + acos(a3)) * RTOD;
   if (ABS(total - 360) > EPS)
      return(FALSE);

   return(TRUE);
}


{$R-} {range checking off}
{$Q-} {overflow checking off}
     {
//Period parameter
const MT19937N=624;

type tMT19937StateArray=array[0..MT19937N-1]of integer; //the array for the state vector

//Period parameters 
const
MT19937M=397;
MT19937MATRIX_A  =$9908b0df;  //constant vector a
MT19937UPPER_MASK=$80000000;  //most significant w-r bits
MT19937LOWER_MASK=$7fffffff;  // east significant r bits

//Tempering parameters
TEMPERING_MASK_B=$9d2c5680;
TEMPERING_MASK_C=$efc60000;


var 
mt:tMT19937StateArray;
mti:integer=MT19937N+1; //mti=MT19937N+1 means mt[] is not initialized

//Initializing the array with a seed
procedure sgenrand_MT19937(seed:integer);
var i:integer;
begin
 mt[0]:=seed;
 for i:=1 to MT19937N-1 do begin
  mt[i]:=1812433253*(mt[i-1]xor(mt[i-1] shr 30))+i;
  //See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. 
  //In the previous versions, MSBs of the seed affect   
  //only MSBs of the array mt[].                        
  //2002/01/09 modified by Makoto Matsumoto            
 end;
 mti:=MT19937N;
end;

function genrand_MT19937:integer;
const mag01:array[0..1]of integer=(0,integer(MT19937MATRIX_A));
var y,kk:integer;
begin
 if(mti>=MT19937N)or(lrndseed<>oldlrndseed)then begin //generate MT19937N integers at one time 
  //if mti=(MT19937N+1)then begin    //if sgenrand_MT19937() has not been called,
   sgenrand_MT19937(lrndseed);   // default initial seed is used
   //hack: randseed is not used more than once in this algorithm. Most 
   //user changes are re-initialising reandseed with the value it had 
   //at the start -> with the "not", we will detect this change.      
   //Detecting other changes is not useful, since the generated       
   //numbers will be different anyway.                                
   //lrndseed:=not(lrndseed);
   oldlrndseed:=lrndseed;
  //end;
  for kk:=0 to MT19937N-MT19937M-1 do begin
   y:=(mt[kk] and MT19937UPPER_MASK) or (mt[kk+1] and MT19937LOWER_MASK);
   mt[kk]:=mt[kk+MT19937M] xor (y shr 1) xor mag01[y and $00000001];
  end;
  for kk:= MT19937N-MT19937M to MT19937N-2 do begin
   y:=(mt[kk] and MT19937UPPER_MASK) or (mt[kk+1] and MT19937LOWER_MASK);
   mt[kk]:=mt[kk+(MT19937M-MT19937N)] xor (y shr 1) xor mag01[y and $00000001];
  end;
  y:=(mt[MT19937N-1] and MT19937UPPER_MASK) or (mt[0] and MT19937LOWER_MASK);
  mt[MT19937N-1]:=mt[MT19937M-1] xor (y shr 1) xor mag01[y and $00000001];
  mti:=0;
 end;
 y:=mt[mti];inc(mti);
 y:=y xor (y shr 11);
 y:=y xor (y shl 7)  and TEMPERING_MASK_B;
 y:=y xor (y shl 15) and TEMPERING_MASK_C;
 y:=y xor (y shr 18);
 result:=y;
end;

function lrandom(l:integer):integer;overload;
begin
 result:=integer((int64(cardinal(genrand_MT19937))*l) shr 32);
end;
function lrandom(l:int64):int64;overload;
begin
 result:=int64((qword(cardinal(genrand_MT19937)) or ((qword(cardinal(genrand_MT19937)) shl 32))) and $7fffffffffffffff) mod l;
end;
function lrandom:extended;overload;
begin
 result:=cardinal(genrand_MT19937)*(1.0/(int64(1) shl 32));
end;  }
        
{$Q-}
function lrandom:double; overload;
begin
 lrndseed:=lrndseed*1103515245+12345;
 result:=(lrndseed/4294967296);
end;
function lrandom(l:integer):integer; overload;
begin
 result:=round(lrandom*(l-1));
end;
{
function lrandom(l:int64):int64; overload;
begin
 result:=round(lrandom*(l-1));
end;
}
{$Q+}

begin
end.



