//############################################################################//
unit raleysoft;
interface
uses raleydata,math,maths,strval,grph,grplib,bmp;  
//############################################################################// 
var ptrans,pirr,pins:pointer; 
etex:ptypspr;       
//############################################################################//
function do_scatter(coords,ray,cam,sun:vec;exposure:double):vec;        
procedure load_precomp_soft(trans,irr,ins:string);
//############################################################################//
procedure compute_transmittance(trans:string;xs,ys,samp:integer;ibetaR,ibetaMEx:vec;iHR,iHM:double);  
procedure compute_irradiance_inscatter(irr,ins:string);      
procedure comp_layer(layer:integer;var dhdH:quat;var r:double);
//############################################################################//
implementation  
//############################################################################//
function modgl(x,y:double):double;begin result:=x-y*floor(x/y);end;
function sqrtgl(x:double):double;begin if x>=0 then result:=sqrt(x) else result:=0;end;
function powgl(x,n:double):double;begin if x=0 then result:=0 else if n>0 then result:=pow(x,n) else result:=1/pow(x,-n);end; 
function step(edge,x:double):double;begin if x<=edge then result:=0 else result:=1;end; 
function max2v(x,y:quat):quat;begin result:=tquat(max2(x.x,y.x),max2(x.y,y.y),max2(x.z,y.z),max2(x.w,y.w));end; 
function maxv(x,y:vec):vec;begin result:=tvec(max2(x.x,y.x),max2(x.y,y.y),max2(x.z,y.z));end; 
function minv(x,y:vec):vec;begin result:=tvec(min2(x.x,y.x),min2(x.y,y.y),min2(x.z,y.z));end; 
function smoothstep(edge0,edge1,x:double):double;begin if x<=edge0 then result:=0 else if x>=edge1 then result:=1 else result:=(x-edge0)/(edge1-edge0);end;
function mix(x,y:quat;a:double):quat;begin result:=tquat(x.x*(1-a)+y.x*a,x.y*(1-a)+y.y*a,x.z*(1-a)+y.z*a,x.w*(1-a)+y.w*a);end; 
//############################################################################//
//############################################################################// 
//############################################################################//
//############################################################################// 
//############################################################################//
function trans(v:vec2):vec;
const
xs=TRANSMITTANCE_W;
ys=TRANSMITTANCE_H; 

var xh,yh,xl,yl:integer;
xf,yf,w1,w2,w3,w4:double;
vr:array[0..3]of vec;
begin
 if v.x>1 then v.x:=1;if v.y>1 then v.y:=1;if v.x<0 then v.x:=0;if v.y<0 then v.y:=0;
 {
 xh:=floor(v.x*xs);
 yh:=floor(v.y*ys);
 result:=m2v(pmvecar(ptrans)[xh+yh*xs]);     
 }
 xf:=v.x*xs;yf:=v.y*ys;
 xh:=ceil(xf);yh:=ceil(yf);
 xl:=floor(xf);yl:=floor(yf);   
 if xh>=xs then xh:=xs-1;if yh>=ys then yh:=ys-1;if xh<0 then xh:=0;if yh<0 then yh:=0;  
 if xl>=xs then xl:=xs-1;if yl>=ys then yl:=ys-1;if xl<0 then xl:=0;if yl<0 then yl:=0;
 xf:=frac(xf);yf:=frac(yf);
	w1:=(1-xf)*(1-yf);
	w2:=xf*(1-yf);
	w3:=(1-xf)*yf;
	w4:=xf*yf;
         
 vr[0]:=m2v(pmvecar(ptrans)[xl+yl*xs]);
 vr[1]:=m2v(pmvecar(ptrans)[xh+yl*xs]);
 vr[2]:=m2v(pmvecar(ptrans)[xl+yh*xs]);
 vr[3]:=m2v(pmvecar(ptrans)[xh+yh*xs]);
 
 result.x:=vr[0].x*w1+vr[1].x*w2+vr[2].x*w3+vr[3].x*w4;
 result.y:=vr[0].y*w1+vr[1].y*w2+vr[2].y*w3+vr[3].y*w4;
 result.z:=vr[0].z*w1+vr[1].z*w2+vr[2].z*w3+vr[3].z*w4;
end;
//############################################################################//
function refl(v:vec2):quat;
var xh,yh,xl,yl:integer;
xf,yf,w1,w2,w3,w4:double;
vr:array[0..3]of quat;    
function tcrgbaql(v:crgba):quat;
begin      
 result.x:=v[2]/255; 
 result.y:=v[1]/255;
 result.z:=v[0]/255;  
 result.w:=v[3]/255;
end;   
begin   
 if v.x>1 then v.x:=1;if v.y>1 then v.y:=1;if v.x<0 then v.x:=0;if v.y<0 then v.y:=0;
 {
 xh:=floor(v.x*etex.xs);
 yh:=floor(v.y*etex.ys);
 result:=tcrgbaql(pbcrgba(etex.srf)[xh+yh*etex.xs]);
 }
 xf:=v.x*etex.xs;yf:=v.y*etex.ys;
 xh:=ceil(xf);yh:=ceil(yf);
 xl:=floor(xf);yl:=floor(yf);   
 if xh>=etex.xs then xh:=etex.xs-1;if yh>=etex.ys then yh:=etex.ys-1;if xh<0 then xh:=0;if yh<0 then yh:=0;  
 if xl>=etex.xs then xl:=etex.xs-1;if yl>=etex.ys then yl:=etex.ys-1;if xl<0 then xl:=0;if yl<0 then yl:=0;
 xf:=frac(xf);yf:=frac(yf);
	w1:=(1-xf)*(1-yf);
	w2:=xf*(1-yf);
	w3:=(1-xf)*yf;
	w4:=xf*yf;
         
 vr[0]:=tcrgbaql(pbcrgba(etex.srf)[xl+yl*etex.xs]);
 vr[1]:=tcrgbaql(pbcrgba(etex.srf)[xh+yl*etex.xs]);
 vr[2]:=tcrgbaql(pbcrgba(etex.srf)[xl+yh*etex.xs]);
 vr[3]:=tcrgbaql(pbcrgba(etex.srf)[xh+yh*etex.xs]);
 
 result.x:=vr[0].x*w1+vr[1].x*w2+vr[2].x*w3+vr[3].x*w4;
 result.y:=vr[0].y*w1+vr[1].y*w2+vr[2].y*w3+vr[3].y*w4;
 result.z:=vr[0].z*w1+vr[1].z*w2+vr[2].z*w3+vr[3].z*w4;
 result.w:=vr[0].w*w1+vr[1].w*w2+vr[2].w*w3+vr[3].w*w4;
end;
//############################################################################//
function irr(v:vec2):vec; 
const 
xs=SKY_W;
ys=SKY_H; 
var xh,yh:integer;
begin    
 if v.x>1 then v.x:=1;if v.y>1 then v.y:=1;if v.x<0 then v.x:=0;if v.y<0 then v.y:=0;
 xh:=floor(v.x*xs);
 yh:=floor(v.y*ys);   
 if xh>=xs then xh:=xs-1;if yh>=ys then yh:=ys-1;
 if xh<0 then xh:=0;if yh<0 then yh:=0;
 result:=m2v(pmvecar(pirr)[xh+yh*xs]);
end;   
//############################################################################//
function ins(v:vec):quat;
const 
xs=RES_MU_S*RES_NU;
ys=RES_MU;
zs=RES_R;
var xh,yh,xl,yl,z:integer;
xf,yf,w1,w2,w3,w4:double;
vr:array[0..3]of quat;
begin  
 if v.x>1 then v.x:=1;if v.y>1 then v.y:=1;if v.z>1 then v.z:=1;if v.x<0 then v.x:=0;if v.y<0 then v.y:=0;if v.z<0 then v.z:=0; 
 {
 xh:=floor(v.x*xs);
 yh:=floor(v.y*ys);
 z:=floor(v.z*zs);
 result:=m2v(pmquatar(pins)[xh+yh*xs+z*xs*ys]);
 }                     
 z:=floor(v.z*zs);
 xf:=v.x*xs;yf:=v.y*ys;
 xh:=ceil(xf);yh:=ceil(yf);
 if xh>=xs then xh:=xs-1;if yh>=ys then yh:=ys-1;if xh<0 then xh:=0;if yh<0 then yh:=0;  
 //if xl>=xs then xl:=xs-1;if yl>=ys then yl:=ys-1;if xl<0 then xl:=0;if yl<0 then yl:=0;
 xl:=floor(xf);yl:=floor(yf);
              
 xf:=frac(xf);yf:=frac(yf);
	w1:=(1-xf)*(1-yf);
	w2:=xf*(1-yf);
	w3:=(1-xf)*yf;
	w4:=xf*yf;
         
 vr[0]:=m2v(pmquatar(pins)[xl+yl*xs+z*xs*ys]);
 vr[1]:=m2v(pmquatar(pins)[xh+yl*xs+z*xs*ys]);
 vr[2]:=m2v(pmquatar(pins)[xl+yh*xs+z*xs*ys]);
 vr[3]:=m2v(pmquatar(pins)[xh+yh*xs+z*xs*ys]);
 
 result.x:=vr[0].x*w1+vr[1].x*w2+vr[2].x*w3+vr[3].x*w4;
 result.y:=vr[0].y*w1+vr[1].y*w2+vr[2].y*w3+vr[3].y*w4;
 result.z:=vr[0].z*w1+vr[1].z*w2+vr[2].z*w3+vr[3].z*w4;
 result.w:=vr[0].w*w1+vr[1].w*w2+vr[2].w*w3+vr[3].w*w4;
end;
//############################################################################//
function phaseFunctionR(mu:double):double;begin result:=(3/(16*pi))*(1+mu*mu);end;
function phaseFunctionM(mu:double):double;begin result:=1.5*1/(4*pi)*(1-mieG*mieG)*powgl(1+(mieG*mieG)-2*mieG*mu,-3/2)*(1+mu*mu)/(2+mieG*mieG);end;
function getMie(rayMie:quat):vec;begin result:=lmulv(nmulv(v4v3(rayMie),rayMie.w/max(rayMie.x,1e-4)),(tvec(betaR.x/betaR.x,betaR.x/betaR.y,betaR.x/betaR.z)));end;
function getIrradianceUV(r,muS:double):vec2;begin result:=tvec2((muS+0.2)/(1.0+0.2),(r-Rg)/(Rt-Rg));end;
function getTransmittanceUV(r,mu:double):vec2;begin result:=tvec2(arctan((mu+0.15)/(1+0.15)*tan(1.5))/1.5,sqrtgl((r-Rg)/(Rt-Rg)));end;
function irradiance(r,muS:double):vec;begin result:=irr(getIrradianceUV(r,muS));end;
function transmittance(r,mu:double):vec;begin result:=trans(getTransmittanceUV(r,mu));end;
function transmittanceWithShadow(r,mu:double):vec;begin if mu<-sqrtgl(1-(Rg/r)*(Rg/r)) then result:=zvec else result:=transmittance(r,mu);end;      
//############################################################################//
//############################################################################//
function opticalDepth(H,r,mu,d:double):double;
var a,x:double;
a01x,a01sx,a01sqx,yx,a01y,a01sy,a01sqy,yy:double;
begin
 a:=sqrtgl((0.5/H)*r);
 
 a01x:=a*mu;
 a01y:=a*(mu+d/r);
 a01sx:=sgn(a01x);
 a01sy:=sgn(a01y);
 a01sqx:=a01x*a01x;
 a01sqy:=a01y*a01y;   
 
 if a01sy>a01sx then x:=exp(a01sqx) else x:=0;
 
 yx:=a01sx/(2.3193*abs(a01x)+sqrtgl(1.52*a01sqx+4))*1;
 yy:=a01sy/(2.3193*abs(a01y)+sqrtgl(1.52*a01sqy+4))*exp(-d/H*(d/(2.0*r)+mu));
 
 result:=sqrtgl((6.2831*H)*r)*exp((Rg-r)/H)*(x+smulv(tvec2(yx,yy),tvec2(1,-1)));
end; 
//############################################################################//
function analyticTransmittance(r,mu,d:double):vec;
begin
 result:=addv(nmulv(betaR,-opticalDepth(HR,r,mu,d)),nmulv(betaMEx,-opticalDepth(HM,r,mu,d)));
 result:=tvec(exp(result.x),exp(result.y),exp(result.z));
end;   
//############################################################################//
function texture4D(r,mu,muS,nu:double):quat;
var H,rho,rmu,delta,uR,uMu,uMuS,lerp,uNu,k:double;
cst:quat;
begin 
 H:=sqrtgl(Rt*Rt-Rg*Rg); 
 rho:=sqrtgl(r*r-Rg*Rg); 

 rmu:=r*mu;        
 delta:=rmu*rmu-r*r+Rg*Rg; 

 if(rmu<0)and(delta>0)then cst:=tquat(1,0,0,0.5-0.5/RES_MU)
                      else cst:=tquat(-1,H*H,H,0.5+0.5/RES_MU);
                 
 uR:=0.5/RES_R+rho/H*(1-1/RES_R);  
 k:=rho+cst.z;
 if abs(k)<0.001 then k:=0.001;
 uMu:=cst.w+(rmu*cst.x+sqrtgl(delta+cst.y))/k*(0.5-1/RES_MU);    
 uMuS:=0.5/RES_MU_S+(arctan(max(muS,-0.1975)*tan(1.26*1.1))/1.1+(1-0.26))*0.5*(1-1/RES_MU_S);   

 lerp:=(nu+1)/2*(RES_NU-1); 
 uNu:=floor(lerp);   
 lerp:=lerp-uNu;    
 
 result:=addv(nmulv(ins(tvec((uNu+uMuS)/RES_NU,uMu,uR)),(1-lerp)),
              nmulv(ins(tvec((uNu+uMuS+1)/RES_NU,uMu,uR)),lerp));   
end;
//############################################################################//
//############################################################################//
function inscatter(var x:vec;var t:double;v,s:vec;var r,mu:double;var attenuation:vec):vec;
const EPS=0.004;
var d,nu,muS,phaseR,phaseM,r0,rMu0,mu0,muS0,muHoriz,a:double;
inscatt,inScatter0,inScatter1,inScatterA,inScatterB:quat;
x0:vec;
begin 
 r:=modv(x);
 mu:=smulv(x,v)/r;
 d:=-r*mu-sqrtgl(r*r*(mu*mu-1)+Rt*Rt);  
 if d>0 then begin
  //if x in space and ray intersects atmosphere
  //move x to nearest intersection of ray with top atmosphere boundary
  x:=addv(x,nmulv(v,d));
  t:=t-d;
  mu:=(r*mu+d)/Rt;
  r:=Rt;
 end;  
 if r<=Rt then begin 
  //if ray intersects atmosphere
  nu:=smulv(v,s);                
  muS:=smulv(x,s)/r;         
  phaseR:=phaseFunctionR(nu);   
  phaseM:=phaseFunctionM(nu);  
  inscatt:=max2v(texture4D(r,mu,muS,nu),tquat(0,0,0,0)); 
  if t>0 then begin   
   x0:=addv(x,nmulv(v,t)); 
   r0:=modv(x0);      
   rMu0:=smulv(x0,v);  
   mu0:=rMu0/r0;    
   muS0:=smulv(x0,s)/r0; 

   //avoids imprecision problems in transmittance computations based on textures
   attenuation:=analyticTransmittance(r,mu,t);
   if r0>Rg+0.01 then begin
    //computes S[L]-T(x,x0)S[L]|x0
    inscatt:=max2v(subv(inscatt,lmulv(tquat(attenuation.x,attenuation.y,attenuation.z,attenuation.x),texture4D(r0,mu0,muS0,nu))),tquat(0,0,0,0));
         
    //avoids imprecision problems near horizon by interpolating between two points above and below horizon
    muHoriz:=-sqrtgl(1-(Rg/r)*(Rg/r));
    if abs(mu-muHoriz)<EPS then begin
     a:=((mu-muHoriz)+EPS)/(2*EPS);
     
     mu:=muHoriz-EPS;
     r0:=sqrtgl(r*r+t*t+2.0*r*t*mu);
     mu0:=(r*mu+t)/r0;
     inScatter0:=texture4D(r,mu,muS,nu);
     inScatter1:=texture4D(r0,mu0,muS0,nu); 
     inScatterA:=max2v(subv(inScatter0,lmulv(tquat(attenuation.x,attenuation.y,attenuation.z,attenuation.x),inScatter1)),tquat(0,0,0,0));
     
     mu:=muHoriz+EPS;
     r0:=sqrtgl(r*r+t*t+2.0*r*t*mu);   
     mu0:=(r*mu+t)/r0;
     inScatter0:=texture4D(r,mu,muS,nu);
     inScatter1:=texture4D(r0,mu0,muS0,nu);
     inScatterB:=max2v(subv(inScatter0,lmulv(tquat(attenuation.x,attenuation.y,attenuation.z,attenuation.x),inScatter1)),tquat(0,0,0,0));

     inscatt:=mix(inScatterA,inScatterB,a);
    end;
    
   end;
  end;  
  //avoids imprecision problems in Mie scattering when sun is below horizon
  inscatt.w:=inscatt.w*smoothstep(0,0.02,muS);
  result:=maxv(addv(nmulv(v4v3(inscatt),phaseR),nmulv(getMie(inscatt),phaseM)),zvec);
 end else result:=zvec;//x in space and ray looking in space 
 result:=nmulv(result,IiSun);  
end;
//############################################################################//
//ground radiance at end of ray x+tv,when sun in directions attenuated bewteen ground and viewer (=R[L0]+R[L*])
function groundColor(x:vec;t:double;v,s:vec;r,mu:double;attenuation:vec):vec;
var x0,n,sunLight,groundSkyLight,groundColor,h:vec;
coords:vec2;
reflectance:quat;
r0,muS,fresnel,waterBrdf:double; 
begin
 if t>0 then begin
  //if ray hits ground surface
  //ground reflectance at end of ray,x0
  x0:=addv(x,nmulv(v,t));
  r0:=modv(x0);
  n:=nmulv(x0,1/r0);
  
  coords:=addv(nmulv(lmulv(tvec2(arctan2(n.y,n.x),arccos(n.z)),tvec2(0.5,1)),1/pi),tvec2(0.5,0));
  reflectance:=lmulv(refl(coords),tquat(0.2,0.2,0.2,1));
  if r0>Rg+0.01 then reflectance:=tquat(0.4,0.4,0.4,0);
   
  //direct sun light (radiance) reaching x0
  muS:=smulv(n,s);
  sunLight:=transmittanceWithShadow(r0,muS);
  
  //precomputed sky light (irradiance) at x0
  groundSkyLight:=irradiance(r0,muS);

  //light reflected at x0
  groundColor:=nmulv(lmulv(v4v3(reflectance),addv(nmulv(sunLight,max2(muS,0)),groundSkyLight)),IiSun/pi);
      
  //water specular color due to sunLight
  if reflectance.w>0 then begin
   h:=nrvec(subv(s,v));
   fresnel:=0.02+0.98*powgl(1-smulv(nmulv(v,-1),h),5);
   waterBrdf:=fresnel*powgl(max(smulv(h,n),0),150);
   groundColor:=addv(groundColor,nmulv(sunLight,reflectance.w*max(waterBrdf,0)*IiSun));
  end;
     
  result:=lmulv(attenuation,groundColor);
  
 end else result:=zvec; //ray looking at the sky
end;
//############################################################################//
function sunColor(x:vec;t:double;v,s:vec;r,mu:double):vec;        
var transmittance:vec;
isun:double;
begin       
 result:=zvec;
 if t<=0 then begin                        
  isun:=step(cos(pi/360),smulv(v,s))*IiSun;
  if isun=0 then exit;
  if r<=Rt then transmittance:=transmittanceWithShadow(r,mu)
           else transmittance:=tvec(1,1,1);
  result:=nmulv(transmittance,isun);
 end;
end;
//############################################################################//
function HDR(L:vec;exposure:double):vec;
begin
 result:=nmulv(L,exposure);
 if result.x<1.413 then result.x:=powgl(result.x*0.38317,1.0/2.2) else result.x:=1.0-exp(-result.x);
 if result.y<1.413 then result.y:=powgl(result.y*0.38317,1.0/2.2) else result.y:=1.0-exp(-result.y);
 if result.z<1.413 then result.z:=powgl(result.z*0.38317,1.0/2.2) else result.z:=1.0-exp(-result.z);
end;   
//############################################################################//
function do_scatter(coords,ray,cam,sun:vec;exposure:double):vec;  
var r,mu,t,a,b,c,d:double;
cone:boolean;
v,x,g,attenuation,inscatterCol,groundCol,sunCol:vec; 
begin 
 x:=cam;   
 v:=nrvec(ray);
   
 r:=modv(x);
 mu:=smulv(x,v)/r;
 t:=r*r*(mu*mu-1)+Rg*Rg;
 if t<=0 then t:=-0.00000001 else t:=-r*mu-sqrt(t);
 
 g:=subv(x,tvec(0,0,Rg+10));
 a:=v.x*v.x+v.y*v.y-v.z*v.z;
 b:=2*(g.x*v.x+g.y*v.y-g.z*v.z);
 c:=g.x*g.x+g.y*g.y-g.z*g.z;
 d:=-(b+sqrtgl(b*b-4*a*c))/(2*a);
 cone:=(d>0)and(abs(x.z+d*v.z-Rg)<=10);
 
 if t>0 then begin
  if cone and(d<t)then t:=d;
 end else if cone then t:=d;
  
 inscatterCol:=inscatter(x,t,v,sun,r,mu,attenuation);
 groundCol:=groundColor(x,t,v,sun,r,mu,attenuation);
 sunCol:=sunColor(x,t,v,sun,r,mu);

 result:=HDR(addv(sunCol,addv(groundCol,inscatterCol)),exposure);  
      
 //coords.x:=coords.x*0.5+0.5;
 //coords.y:=coords.y*0.5+0.5;
 //result:=nmulv(irr(tvec2(coords.x,coords.y)),5);
 //result:=nmulv(m2v(pmvecar(pirr)[round(coords.x+coords.y*SKY_W)]),5);
 //result:=m2v(pmvecar(ptrans)[round(coords.x*TRANSMITTANCE_W)+round(coords.y*TRANSMITTANCE_H)*TRANSMITTANCE_W]);
 //result:=ray;
 //result:=x;
 //result:=tvec(t/r,t/r,t/r);
end; 
//############################################################################//      
//############################################################################//  
//############################################################################//
//############################################################################//
function limit(r,mu:double):double;
var delta2,din:double;
begin
 result:=-r*mu+sqrtgl(r*r*(mu*mu-1)+RL*RL);
 delta2:=r*r*(mu*mu-1)+Rg*Rg;
 if delta2>=0 then begin
  din:=-r*mu-sqrtgl(delta2);
  if din>=0 then result:=min2(result,din);
 end;
end;
//############################################################################//
procedure getTransmittanceRMu(x,y,xs,ys:integer;var r,muS:double);
begin
 r:=(y+0.5)/ys;
 muS:=(x+0.5)/xs;
 r:=Rg+(r*r)*(Rt-Rg);
 muS:=-0.15+tan(1.5*muS)/tan(1.5)*(1+0.15);
end;                           
procedure getIrradianceRMuS(x,y,xs,ys:integer;var r,muS:double);
begin
 r:=Rg+(y-0.5)/(ys-1)*(Rt-Rg);
 muS:=-0.2+(x-0.5)/(xs-1)*(1+0.2);
end;
//############################################################################//
//############################################################################//
function opticalDepth_analytic(samp:integer;H,r,mu:double):double;
var dx,yi,xj,yj:double;
i:integer;
begin
 result:=0;
 dx:=limit(r,mu)/samp;
 yi:=exp(-(r-Rg)/H);
 for i:=1 to samp do begin
  xj:=i*dx;
  yj:=exp(-(sqrt(r*r+xj*xj+2*xj*r*mu)-Rg)/H);
  result:=result+(yi+yj)/2*dx;
  yi:=yj;
 end;
 if mu<-sqrtgl(1-(Rg/r)*(Rg/r)) then result:=1e9;
end;  
//############################################################################//
procedure compute_transmittance(trans:string;xs,ys,samp:integer;ibetaR,ibetaMEx:vec;iHR,iHM:double);
var r,muS:double;
x,y:integer;
p:pmvecar;
c:pbcrgba;
fb:file;
depth:vec;
begin  
 getmem(p,xs*ys*4*3); 
 
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  getTransmittanceRMu(x,y,xs,ys,r,muS);
  depth:=addv(nmulv(ibetaR,opticalDepth_analytic(samp,iHR,r,muS)),nmulv(ibetaMEx,opticalDepth_analytic(samp,iHM,r,muS)));
  p[x+y*xs]:=tmvec(exp(-depth.x),exp(-depth.y),exp(-depth.z));
 end;                 
 assignfile(fb,trans);rewrite(fb,1);blockwrite(fb,p^,xs*ys*4*3);closefile(fb);
             
 getmem(c,xs*ys*4);     
 for y:=0 to ys-1 do for x:=0 to xs-1 do c[x+y*xs]:=tcrgba(round(p[x+y*xs].z*255),round(p[x+y*xs].y*255),round(p[x+y*xs].x*255),255);
 storeBMP32(trans+'.bmp',c,xs,ys,true,false);  
 freemem(c);
  
 //freemem(p);
 ptrans:=p;
end; 
//############################################################################//
//############################################################################//
function transmittance3(r,mu,d:double):vec;
var r1,mu1:double;
begin
 r1:=sqrtgl(r*r+d*d+2.0*r*mu*d);
 mu1:=(r*mu+d)/r1;
 if mu>0 then result:=minv(ldivv(transmittance(r,mu),transmittance(r1,mu1)),evec)
         else result:=minv(ldivv(transmittance(r1,-mu1),transmittance(r,-mu)),evec);
end;
//############################################################################//
procedure integrand(r,mu,muS,nu,t:double;var ray,mie:vec);
var ri,muSi:double;
ti:vec;
begin
 ray:=zvec;
 mie:=zvec;
 ri:=sqrtgl(r*r+t*t+2*r*mu*t);
 muSi:=(nu*t+muS*r)/ri;
 ri:=max(Rg,ri);
 if muSi>=-sqrtgl(1-Rg*Rg/(ri*ri)) then begin
  ti:=lmulv(transmittance3(r,mu,t),transmittance(ri,muSi));
  ray:=nmulv(ti,exp(-(ri-Rg)/HR));
  mie:=nmulv(ti,exp(-(ri-Rg)/HM));
 end;
end;

procedure inscatter_analytic(r,mu,muS,nu:double;var ray,mie:vec);
var dx,xj:double;
rayi,miei,rayj,miej:vec;
i:integer;
begin
 ray:=zvec;
 mie:=zvec;
 dx:=limit(r,mu)/INSCATTER_INTEGRAL_SAMPLES;
 //xi:=0;
 integrand(r,mu,muS,nu,0.0,rayi,miei);
 for i:=1 to INSCATTER_INTEGRAL_SAMPLES do begin
  xj:=i*dx;
  integrand(r,mu,muS,nu,xj,rayj,miej);
  ray:=addv(ray,nmulv(addv(rayi,rayj),1/2*dx));
  mie:=addv(mie,nmulv(addv(miei,miej),1/2*dx));
  //xi:=xj;
  rayi:=rayj;
  miei:=miej;
 end;
 ray:=lmulv(ray,betaR);
 mie:=lmulv(mie,betaMSca);
end;
procedure getMuMuSNu(xx,yy:integer;r:double;dhdH:quat;var mu,muS,nu:double);
var x,y,d:double;
begin
 x:=xx-0.5;
 y:=yy-0.5;
 if y<RES_MU/2 then begin
  d:=1-y/(RES_MU/2-1);
  d:=min(max(dhdH.z,d*dhdH.w),dhdH.w*0.999);
  mu:=(Rg*Rg-r*r-d*d)/(2*r*d);
  mu:=min(mu,-sqrt(1-(Rg/r)*(Rg/r))-0.001);
 end else begin
  d:=(y-RES_MU/2)/(RES_MU/2-1);
  d:=min(max(dhdH.x,d*dhdH.y),dhdH.y*0.999);
  mu:=(Rt*Rt-r*r-d*d)/(2*r*d);
 end;
 muS:=modgl(x,RES_MU_S)/(RES_MU_S-1);
 muS:=tan((2*muS-1+0.26)*1.1)/tan(1.26*1.1);
 nu:=-1+floor(x/RES_MU_S)/(RES_NU-1)*2;
end;        
//############################################################################//
procedure comp_layer(layer:integer;var dhdH:quat;var r:double);
var dmin,dmax,dminp,dmaxp:double;
begin
 r:=layer/(RES_R-1.0);
 r:=r*r;
 if layer=0 then begin
  r:=sqrt(Rg*Rg+r*(Rt*Rt-Rg*Rg))+0.01;
 end else begin        
  if layer=RES_R-1 then r:=sqrt(Rg*Rg+r*(Rt*Rt-Rg*Rg))-0.001
                   else r:=sqrt(Rg*Rg+r*(Rt*Rt-Rg*Rg))+0;
 end;
 dmin:=Rt-r;
 dmax:=sqrt(r*r-Rg*Rg)+sqrt(Rt*Rt-Rg*Rg);
 dminp:=r-Rg;
 dmaxp:=sqrt(r*r-Rg*Rg);
 dhdH:=tquat(dmin,dmax,dminp,dmaxp);
end;  
//############################################################################//
procedure compute_irradiance_inscatter(irr,ins:string);
var r,muS,mu,nu:double;
x,y:integer;
xs,ys,zs:integer;
de,dsr,dsm:pmvecar;
c:pbcrgba;
fb:file;
t:vec; 
ray,mie:vec;

dhdH:quat;
layer,k:integer;
begin  
 //deltaETexture
 //irradiance1    
 xs:=SKY_W;
 ys:=SKY_H;    
 getmem(pirr,xs*ys*4*3);
 getmem(de,xs*ys*4*3); 
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  getIrradianceRMuS(x,y,xs,ys,r,muS);
  t:=nmulv(transmittance(r,muS),max2(muS,0));
  de[x+y*xs]:=v2m(t);  
  //copy irradiance
  k:=0;      
  pmvecar(pirr)[x+y*xs]:=nmulv(de[x+y*xs],k);
 end;        
 getmem(c,xs*ys*4);
 for y:=0 to ys-1 do for x:=0 to xs-1 do c[x+y*xs]:=tcrgba(round(de[x+y*xs].z*255),round(de[x+y*xs].y*255),round(de[x+y*xs].x*255),255);
 storeBMP32('deltae.bmp',c,xs,ys,true,false); 
 freemem(c);  
 
 //inscatter1
 xs:=RES_MU_S*RES_NU;
 ys:=RES_MU; 
 zs:=RES_R;       
 getmem(pins,xs*ys*zs*4*33);
 getmem(dsr,xs*ys*zs*4*3);
 getmem(dsm,xs*ys*zs*4*3);  
 
 for layer:=0 to zs-1 do begin
  comp_layer(layer,dhdH,r);
  for y:=0 to ys-1 do for x:=0 to xs-1 do begin 
   getMuMuSNu(x,y,r,dhdH,mu,muS,nu);
   inscatter_analytic(r,mu,muS,nu,ray,mie);
   dsr[x+y*xs+layer*xs*ys]:=v2m(ray);
   dsm[x+y*xs+layer*xs*ys]:=v2m(mie); 
   pmquatar(pins)[x+y*xs+layer*xs*ys]:=tmquat(ray.x,ray.y,ray.z,mie.x);
  end;      
  for y:=0 to ys-1 do for x:=0 to xs-1 do c[x+y*xs]:=tcrgba(round(dsr[x+y*xs+layer*xs*ys].z*255),round(dsr[x+y*xs+layer*xs*ys].y*255),round(dsr[x+y*xs+layer*xs*ys].x*255),255);
  storeBMP32('deltasr-'+stri(layer)+'.bmp',c,xs,ys,true,false); 
  for y:=0 to ys-1 do for x:=0 to xs-1 do c[x+y*xs]:=tcrgba(round(dsm[x+y*xs+layer*xs*ys].z*255),round(dsm[x+y*xs+layer*xs*ys].y*255),round(dsm[x+y*xs+layer*xs*ys].x*255),255);
  storeBMP32('deltasm-'+stri(layer)+'.bmp',c,xs,ys,true,false); 
 end;

 
 {
 assignfile(fb,irr);rewrite(fb,1);blockwrite(fb,p^,xs*ys*4*3);closefile(fb);
           
 getmem(c,xs*ys*4);      
 for y:=0 to ys-1 do for x:=0 to xs-1 do c[x+y*xs]:=tcrgba(round(p[x+y*xs].z*255),round(p[x+y*xs].y*255),round(p[x+y*xs].x*255),255);
 storeBMP32(irr+'.bmp',c,xs,ys,true,false); 
 freemem(c); 

 pirr:=p;
 }
end;        
//############################################################################//
procedure load_precomp_soft(trans,irr,ins:string);
var fb:file;
xs,ys,zs:integer;
begin       
 xs:=TRANSMITTANCE_W;
 ys:=TRANSMITTANCE_H;
 getmem(ptrans,xs*ys*4*3); 
 assignfile(fb,trans);reset(fb,1);blockread(fb,ptrans^,xs*ys*4*3);closefile(fb);
         
 xs:=SKY_W;
 ys:=SKY_H;
 getmem(pirr,xs*ys*4*3); 
 assignfile(fb,irr);reset(fb,1);blockread(fb,pirr^,xs*ys*4*3);closefile(fb);
           
 xs:=RES_MU_S*RES_NU;
 ys:=RES_MU;
 zs:=RES_R;
 getmem(pins,xs*ys*zs*4*4); 
 assignfile(fb,ins);reset(fb,1);blockread(fb,pins^,xs*ys*zs*4*4);closefile(fb);
end;    
//############################################################################//
//############################################################################//
begin
end.   
//############################################################################//
