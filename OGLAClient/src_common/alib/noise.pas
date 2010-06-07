//############################################################################//
//Made in 2002-2010 by Artyom Litvinovich
//AlgorLib: Perlin Noise
//############################################################################//
unit noise;
{$ifdef fpc}{$mode delphi}{$endif}
interface     
uses asys,math,maths;  
//############################################################################//
const gtbs=256;
mask=gtbs-1; 

crs=128;
crs2=crs div 2;
type crrec=packed record
 px,py,pz:byte;
 r,s:single;
end;
pcrrec=^crrec;

type noirec=record
 seed:cardinal;
 fgrad:array[0..gtbs*3-1]of single;
 perm:array[0..gtbs-1]of Byte;     
 ci,ni:boolean;       
 crtab:array of crrec;
 crbit:array[0..crs-1]of array[0..crs-1]of array[0..crs-1]of byte;
end;
pnoirec=^noirec;

var
defnoi:noirec;
//############################################################################//
//procedure pnoiCreate(seed:integer);
function pnoinoise(noi:pnoirec;x,y,z:single):single; 
//function pnoinoise(p:vec):single;    
function pcnoinoise(noi:pnoirec;x,y,z:single):single;  
//procedure cnoise_create(seed:cardinal);  
//############################################################################//
function cratertf(r,aas,bbs,ccs,dds,scl:double):double;
function craterdeftf(r,s,scl:double):double;      
function craterstf(noi:pnoirec;a:vec;scal:double;bd:integer;dsp:vec):double;
function craterbltf(r,s,scl,b:double):double;    
function crater_sbase_tf(r,s,scl,b:double):double;     
//############################################################################//    
var expa:array of double; 
implementation  
//############################################################################//
//############################################################################//
//############################################################################//
procedure pnoisgrads(noi:pnoirec);
var i:integer;
z,r,th:single;
begin
 for i:=0 to gtbs-1 do begin
  z:=1-2*lrandom;
  r:=sqrt(1-z*z);
  th:=2*PI*lrandom;
  noi.fgrad[i*3]:=r*cos(th);
  noi.fgrad[i*3+1]:=r*sin(th);
  noi.fgrad[i*3+2]:=z;
 end;
end;
//############################################################################//   
//############################################################################//
procedure pnoiCreate(noi:pnoirec);
var i:integer;
s:cardinal;
begin
 s:=lrndseed;
 lrndseed:=noi.seed;
 for i:=0 to gtbs-1 do noi.perm[i]:=lrandom(256);
 pnoisgrads(noi);    
 lrndseed:=s;  
 noi.ni:=true;
end;       
//############################################################################//
//1.00  
//0.84  
//0.77
function pnoinoise(noi:pnoirec;x,y,z:single):single;
var ix,iy,iz,ix1,iy1,iz1,iyz,iy1z,iyz1,iy1z1:integer;
fx0,fx1,fy0,fy1,fz0,fz1:single;
wx,wy,wz:single;
vx0,vx1,vy0,vy1,vz0,vz1:single;   
var g:array[0..7]of integer;
begin 
 if not noi.ni then pnoiCreate(noi);
 ix:=integer(trunc(x));if frac(x)<0 then dec(ix);ix1:=ix+1;  
 iy:=integer(trunc(y));if frac(y)<0 then dec(iy);iy1:=iy+1;
 iz:=integer(trunc(z));if frac(z)<0 then dec(iz);iz1:=noi.perm[(iz+1) and mask];

 fx0:=x-ix; fy0:=y-iy; fz0:=z-iz;
 fx1:=fx0-1;fy1:=fy0-1;fz1:=fz0-1;      
 
 wx:=fx0*fx0*(3-2*fx0);
 wy:=fy0*fy0*(3-2*fy0);
 wz:=fz0*fz0*(3-2*fz0);  
 
 iz:=noi.perm[iz and mask];
 iyz:=noi.perm[(iy+iz)and mask];
 iy1z:=noi.perm[(iy1+iz)and mask];
 iyz1:=noi.perm[(iy+iz1)and mask];
 iy1z1:=noi.perm[(iy1+iz1)and mask];

 g[0]:=noi.perm[(ix+iyz)and mask]*3; 
 g[1]:=noi.perm[(ix1+iyz)and mask]*3; 
 g[2]:=noi.perm[(ix+iy1z)and mask]*3;   
 g[3]:=noi.perm[(ix1+iy1z)and mask]*3;  
 g[4]:=noi.perm[(ix+iyz1)and mask]*3; 
 g[5]:=noi.perm[(ix1+iyz1)and mask]*3;  
 g[6]:=noi.perm[(ix+iy1z1)and mask]*3; 
 g[7]:=noi.perm[(ix1+iy1z1)and mask]*3;
 
 vx0:=noi.fgrad[g[0]]*fx0+noi.fgrad[g[0]+1]*fy0+noi.fgrad[g[0]+2]*fz0;
 vx1:=noi.fgrad[g[1]]*fx1+noi.fgrad[g[1]+1]*fy0+noi.fgrad[g[1]+2]*fz0; 
 vy0:=vx0+wx*(vx1-vx0);

 vx0:=noi.fgrad[g[2]]*fx0+noi.fgrad[g[2]+1]*fy1+noi.fgrad[g[2]+2]*fz0;
 vx1:=noi.fgrad[g[3]]*fx1+noi.fgrad[g[3]+1]*fy1+noi.fgrad[g[3]+2]*fz0; 
 vy1:=vx0+wx*(vx1-vx0);
 vz0:=vy0+wy*(vy1-vy0);
                            
 vx0:=noi.fgrad[g[4]]*fx0+noi.fgrad[g[4]+1]*fy0+noi.fgrad[g[4]+2]*fz1;
 vx1:=noi.fgrad[g[5]]*fx1+noi.fgrad[g[5]+1]*fy0+noi.fgrad[g[5]+2]*fz1; 
 vy0:=vx0+wx*(vx1-vx0);
                   
 vx0:=noi.fgrad[g[6]]*fx0+noi.fgrad[g[6]+1]*fy1+noi.fgrad[g[6]+2]*fz1;
 vx1:=noi.fgrad[g[7]]*fx1+noi.fgrad[g[7]+1]*fy1+noi.fgrad[g[7]+2]*fz1; 
 vy1:=vx0+wx*(vx1-vx0);
 vz1:=vy0+wy*(vy1-vy0);
                
 result:=vz0+wz*(vz1-vz0);  
end;                                                                          
//############################################################################//
//############################################################################//
//############################################################################//    
//############################################################################//
//############################################################################//
function kfrac(x:single):single;
begin
 if x<0 then result:=1+frac(x) else result:=frac(x);
end;
//############################################################################//
function cratertf(r,aas,bbs,ccs,dds,scl:double):double;
begin    
 result:=0;
 if(r<dds)then begin
  r:=1-r/dds;
  result:=scl/2*sqr(r)-2*scl;
 end else if(r<dds+ccs)then begin
  r:=(pi/2)*(r-dds)/ccs;
  result:=-2*scl*cos(r);
 end else if(r<dds+ccs+bbs)then begin
  r:=(pi/2)*(r-dds-ccs)/bbs;  
  result:=scl*sin(r);
 end else if(r<dds+ccs+bbs+aas)then begin
  r:=(pi/2)*(r-dds-ccs-bbs)/aas;
  result:=scl*cos(r);
 end;
end;     
//############################################################################//
function craterdeftf(r,s,scl:double):double;
begin
 //result:=cratertf(r,s*0.1,s*0.2,s*0.6,s*0.1,scl);
 result:=cratertf(r/s,0.05,0.2,0.65,0.1,scl);
 //result:=cos((r/s)*40*pi);
end;  
//############################################################################//
function craterstf(noi:pnoirec;a:vec;scal:double;bd:integer;dsp:vec):double;
var i:integer;  
d:double;
begin
 result:=0;
 for i:=0 to bd-1 do begin
  d:=1/(scal/expa[i]);
  result:=result+pcnoiNoise(noi,dsp.x*a.x*d,dsp.y*a.y*d,dsp.z*a.z*d)/expa[i];
 end; 
 if result>1 then result:=1;
end; 
//############################################################################//
function craterbltf(r,s,scl,b:double):double;
var e,d:double;
begin
 e:=cratertf(r,0.2*s,0.2*s,0.6*s,0,100);
 if e<0 then d:=(e*20)*100 else if r>=0.8*s then d:=(b*((r-0.8*s)/(0.2*s))+(e/100)*scl)*100 else d:=e*scl;
 
 result:=d/100;
end; 
//############################################################################//
function crater_sbase(r,aas,bbs,ccs,dds,scl:double):double;
//var p:integer;
begin
 if(r<dds)and(dds>0)then begin
  r:=r;
  result:=scl*sqr((dds-r)/dds);
  exit;
 end;
 if(r>=dds)and(r<dds+ccs-10)then begin
  //r:=r-dds;
  result:=-0.1;
  exit;
 end;
 if(r>=dds+ccs-10)and(r<dds+ccs)then begin
  r:=r-dds-ccs+10;
  result:=-0.1*((10-r)/10);
  exit;
 end;
 if(r>=dds+ccs)and(r<dds+ccs+bbs)then begin
  r:=r-dds-ccs;
  result:=scl*sin((r/(bbs/2))*(pi/4));
  exit;
 end;
 if(r>dds+ccs+bbs)and(r<dds+ccs+bbs+aas)and(aas>0)then begin
  r:=r-dds-ccs-bbs;
  result:=scl*sin( ((aas-r)/aas)*(pi/2));
  exit;
 end;
 result:=0;
end;
//############################################################################//
function crater_sbase_tf(r,s,scl,b:double):double;
var e,d:double;
begin
 e:=crater_sbase(r,0.2*s,0.2*s,0.6*s,0,100);
 if e<0 then d:=(e*20)*100 else if r>=0.8*s then d:=(b*((r-0.8*s)/(0.2*s))+(e/100)*scl)*100 else d:=e*scl;
 
 result:=d/100;
end;   
//############################################################################//
procedure cnoise_create(noi:pnoirec;fake:boolean=true);       
var xi,yi,zi,i,j,n:integer;
k,t:single;
v:pcrrec;
sd:cardinal;
begin   
 if not defnoi.ci then fake:=false;
 if fake then begin
  setlength(noi.crtab,50); 
  for i:=0 to length(noi.crtab)-1 do noi.crtab[i]:=defnoi.crtab[i];    
  for zi:=0 to crs-1 do for yi:=0 to crs-1 do for xi:=0 to crs-1 do noi.crbit[zi][yi][xi]:=defnoi.crbit[zi][yi][xi];   
  for i:=0 to length(noi.crtab)-1 do noi.crtab[i].r:=defnoi.crtab[i].r;  
  noi.ci:=true;
  exit;
 end;
 sd:=lrndseed;
 lrndseed:=noi.seed;
 setlength(noi.crtab,50);
 for i:=0 to length(noi.crtab)-1 do begin
  v:=@noi.crtab[i];
  v.px:=lrandom(crs);
  v.py:=lrandom(crs);
  v.pz:=lrandom(crs);
  v.r:=0.1+lrandom*0.1;
  n:=round(v.r*crs);      
  if v.px<=n then v.px:=n+1;
  if v.py<=n then v.py:=n+1;
  if v.pz<=n then v.pz:=n+1;
  if v.px>=crs-n-1 then v.px:=crs-n-2;
  if v.py>=crs-n-1 then v.py:=crs-n-2;
  if v.pz>=crs-n-1 then v.pz:=crs-n-2; 
  v.s:=0.5+lrandom*0.5;
 end;
  
 for zi:=0 to crs-1 do for yi:=0 to crs-1 do for xi:=0 to crs-1 do begin
  k:=1e32;n:=-1;
  for i:=0 to length(noi.crtab)-1 do begin
   t:=sqr(xi-noi.crtab[i].px)+sqr(yi-noi.crtab[i].py)+sqr(zi-noi.crtab[i].pz);
   if t<k then begin k:=t;n:=i;end;
  end;
  assert(n<>-1);
  noi.crbit[zi][yi][xi]:=n;
 end;
  
 for i:=0 to length(noi.crtab)-1 do begin
  k:=1e32;
  for j:=0 to length(noi.crtab)-1 do if i<>j then begin  
   t:=sqr(noi.crtab[j].px-noi.crtab[i].px)+sqr(noi.crtab[j].py-noi.crtab[i].py)+sqr(noi.crtab[j].pz-noi.crtab[i].pz);
   if t<k then k:=t;
  end;
  noi.crtab[i].r:=min2(noi.crtab[i].r,(sqrt(k)/crs)/2);
 end;
 noi.ci:=true;
 lrndseed:=sd;
end;
//############################################################################//
function pcnoinoise(noi:pnoirec;x,y,z:single):single;
var k:single;
v:pcrrec;
begin //k:=0;try
 if not noi.ci then cnoise_create(noi);
 v:=@noi.crtab[noi.crbit[round(kfrac(z)*(crs-1))][round(kfrac(y)*(crs-1))][round(kfrac(x)*(crs-1))]]; 
 k:=sqrt(sqr(v.px/(crs-1)-kfrac(x))+sqr(v.py/(crs-1)-kfrac(y))+sqr(v.pz/(crs-1)-kfrac(z)));
 if k<v.r then result:=craterdeftf(k,v.r,v.s) else result:=0;
 //except  writeln(noi.ci,dword(@noi),dword(@v),k,x,y,z);end;
end;
//############################################################################//
//############################################################################//
//############################################################################//
{
// coherent noise function over 1, 2 or 3 dimensions 
// (copyright Ken Perlin)

const
B=$100;
BM=$ff;
N=$1000;
NP=12;
NM=$fff;

var 
p:array[0..B+B+2-1]of integer;
g3:array[0..B + B + 2-1]of array[0..3-1]of single;
g2:array[0..B + B + 2-1]of array[0..2-1]of single;
g1:array[0..B + B + 2-1]of single;



//#define s_curve(t) ( t * t * (3. - 2. * t) )
//#define lerp(t, a, b) ( a + t * (b - a) )
//#define setup(i,b0,b1,r0,r1)\
//	t = vec[i] + N;\
//	b0 = ((int)t) & BM;\
//	b1 = (b0+1) & BM;\
//	r0 = t - (int)t;\
//	r1 = r0 - 1.;

function noise3(vc:vec):single;
var bx0,bx1,by0,by1,bz0,bz1,b00,b10,b01,b11:integer;
rx0,rx1,ry0,ry1,rz0,rz1,sy,sz,a,b,c,d,t,u,v:single;
q:psingle;
i,j:integer; 
begin
 t:=vc.x+N;
 bx0:=(floor(t))and BM;
 bx1:=(bx0+1)and BM;
 rx0:=t-floor(t);
 rx1:=rx0-1;
 
 t:=vc.y+N;
 by0:=(floor(t))and BM;
 by1:=(by0+1)and BM;
 ry0:=t-floor(t);
 ry1:=ry0-1;
 
 t:=vc.z+N;
 bz0:=(floor(t))and BM;
 bz1:=(bz0+1)and BM;
 rz0:=t-floor(t);
 rz1:=rz0-1;
 
 i:=p[bx0];
 j:=p[bx1];

 b00:=p[i+by0];
 b10:=p[j+by0];
 b01:=p[i+by1];
 b11:=p[j+by1];

 t :=rx0*rx0*(3-2*rx0);
 sy:=ry0*ry0*(3-2*ry0);
 sz:=rz0*rz0*(3-2*rz0);

#define at3(rx,ry,rz) ( rx * q[0] + ry * q[1] + rz * q[2] )

	q = g3[ b00 + bz0 ] ; u = at3(rx0,ry0,rz0);
	q = g3[ b10 + bz0 ] ; v = at3(rx1,ry0,rz0);
	a = lerp(t, u, v);

	q = g3[ b01 + bz0 ] ; u = at3(rx0,ry1,rz0);
	q = g3[ b11 + bz0 ] ; v = at3(rx1,ry1,rz0);
	b = lerp(t, u, v);

	c = lerp(sy, a, b);

	q = g3[ b00 + bz1 ] ; u = at3(rx0,ry0,rz1);
	q = g3[ b10 + bz1 ] ; v = at3(rx1,ry0,rz1);
	a = lerp(t, u, v);

	q = g3[ b01 + bz1 ] ; u = at3(rx0,ry1,rz1);
	q = g3[ b11 + bz1 ] ; v = at3(rx1,ry1,rz1);
	b = lerp(t, u, v);

	d = lerp(sy, a, b);

	return lerp(sz, c, d);
end

static void normalize2(float v[2])
begin
	float s;

	s = sqrt(v[0] * v[0] + v[1] * v[1]);
	v[0] = v[0] / s;
	v[1] = v[1] / s;
end

static void normalize3(float v[3])
begin
	float s;

	s = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
	v[0] = v[0] / s;
	v[1] = v[1] / s;
	v[2] = v[2] / s;
end

procedure setn;
var i,j,k:integer;
begin
 for(i:=0 to B-1 do begin
  p[i]:=i;
  g1[i]:=(random(B+B)-B)/B;

  for j:=0 to 2-1 do g2[i][j]:=((random(B + B)) - B) / B;
  normalize2(g2[i]);

  for j:=0 to 3-1 do g3[i][j]:=((random(B + B)) - B) / B;
		normalize3(g3[i]);
	end

	while (--i) begin
		k = p[i];
		p[i] = p[j = random() % B];
		p[j] = k;
	end

	for (i = 0 ; i < B + 2 ; i++) begin
		p[B + i] = p[i];
		g1[B + i] = g1[i];
		for (j = 0 ; j < 2 ; j++)
			g2[B + i][j] = g2[i][j];
		for (j = 0 ; j < 3 ; j++)
			g3[B + i][j] = g3[i][j];
	end
end;
}
//############################################################################//  
var i:integer;
begin     
 setlength(expa,33);
 for i:=0 to 32 do expa[i]:=pow(2,i); 

 defnoi.ci:=false;
 defnoi.ni:=false;  
 defnoi.seed:=10;
 pnoicreate(@defnoi);
 {$ifdef cnoipregen}cnoise_create(@defnoi,false);{$endif}
end.  
//############################################################################//


