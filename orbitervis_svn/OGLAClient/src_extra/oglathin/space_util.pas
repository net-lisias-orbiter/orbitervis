//############################################################################//
// SpaceWay space maths
// Made in 2005-2010 by Artyom Litvinovich
// Since 2009 based on KOST code by C J Plooy (cornware-cjp@lycos.nl) 
//############################################################################//

unit space_util;
interface
uses asys,maths,math;
//############################################################################//
type
kostElements=record
 a:double;     //Semi-major axis
 e:double;     //Eccentricity
 i:double;     //Inclination
 theta:double; //Longitude of ascending node
 omegab:double;//Longitude of periapsis
 L:double;     //Mean longitude at epoch
end;
pkostElements=^kostElements;

kostOrbitParam=record
//Same as ORBITPARAM
 SMi:double; //semi-minor axis
 PeD:double; //periapsis distance
 ApD:double; //apoapsis distance
 MnA:double; //mean anomaly
 TrA:double; //true anomaly
 MnL:double; //mean longitude
 TrL:double; //true longitude
 EcA:double; //eccentric anomaly
 Lec:double; //linear eccentricity
 T:double;   //orbit period
 PeT:double; //time to next periapsis passage
 ApT:double; //time to next apoapsis passage
 
//Additional
 AgP:double; //argument of periapsis
 
end;
pkostOrbitParam=^kostOrbitParam;

kostOrbitShape=record
 pe,ap,dn,an:vec;

 points:array of vec;
 numPoints:dword;
end;
pkostOrbitShape=^kostOrbitShape;
//############################################################################//
procedure kostStateVector2Elements(mu:double;pos,vel:vec;elements:pkostElements;params:pkostOrbitParam); 
procedure kostElements2Shape(elements:pkostElements;shape:pkostOrbitShape);  
  
function kostMakeXRotm(angle:double):mat;
function kostMakeYRotm(angle:double):mat;
function kostMakeZRotm(angle:double):mat;
//############################################################################//
implementation      
//############################################################################//
var dummy:kostOrbitParam;
//############################################################################//
function acosh(x:double):double;begin result:=ln(x+sqrt(x*x-1));end;
function asinh(x:double):double;begin result:=ln(x+sqrt(x*x+1));end;
function kostMakeXRotm(angle:double):mat;
begin
 result[0].x:=1;result[0].y:=0;         result[0].z:= 0;
 result[1].x:=0;result[1].y:=cos(angle);result[1].z:=-sin(angle);
 result[2].x:=0;result[2].y:=sin(angle);result[2].z:= cos(angle);
end;
function kostMakeYRotm(angle:double):mat;
begin
 result[0].x:= cos(angle);result[0].y:=0;result[0].z:=sin(angle);
 result[1].x:= 0;         result[1].y:=1;result[1].z:=0;
 result[2].x:=-sin(angle);result[2].y:=0;result[2].z:=cos(angle);
end;
function kostMakeZRotm(angle:double):mat;
begin
 result[0].x:=cos(angle);result[0].y:=-sin(angle);result[0].z:=0;
 result[1].x:=sin(angle);result[1].y:= cos(angle);result[1].z:=0;
 result[2].x:=0;         result[2].y:= 0;         result[2].z:=1;
end;
//############################################################################//
const 
VERYSMALL=1e-6;
M_PI=3.1415926535897932384626433832795;
M_TWOPI=M_PI*2;
GRAVITATIONAL_CONSTANT=6.67259e-11;
ASTRONOMICAL_UNIT=1.49597870691e11;
PARSEC=3.0858e16;
//############################################################################//
procedure kostStateVector2Elements(mu:double;pos,vel:vec;elements:pkostElements;params:pkostOrbitParam);
var h,n,e:vec;
absh,absn,absr,abse,Eb,tPe,tmp:double;
isEquatorial,isCircular,isHyperbola:boolean;
begin
 if params=nil then params:=@dummy;

 h:=vmulv(pos,vel);
 n:=tvec(-h.y,h.x,0);

 absh:=modv(h);
 absn:=modv(n);

 absr:=modv(pos);

 //Alternative formula for e:
 //e=(v x h)/mu-r/|r|

 e:=vmulv(vel,h);
 e:=nmulv(e,(absr/mu));
 e:=subv(e,pos);
 e:=nmulv(e,(1/absr));

 abse:=modv(e);

 isEquatorial:=absn<VERYSMALL;
 isCircular:=abse<VERYSMALL;
 isHyperbola:=abse>=1;

 Eb:=0.5*modvs(vel)-mu/absr;

 //SMa
 elements.a:=-mu/(2.0*Eb);

 //Ecc
 elements.e:=abse;

 //dp=a*(1-e)
 //da=a*(1+e)
 params.PeD:=elements.a*(1-elements.e);
 params.ApD:=elements.a*(1+elements.e);

 //Inc
 elements.i:=arccos(h.z/absh);

 //LAN
 if isEquatorial then begin
  elements.theta:=0;
 end else begin
  elements.theta:=arccos(n.x/absn);
  if n.y<0 then elements.theta:=M_TWOPI-elements.theta;
 end;

 //AgP
 params.AgP:=0;
 if isCircular then begin
  params.AgP:=0;
 end else if isEquatorial then begin
  params.AgP:=arccos(e.x/abse);
  if e.z<0 then params.AgP:=M_TWOPI-params.AgP;
 end else begin
  params.AgP:=arccos(smulv(n,e)/(absn*abse));
  if e.z<0 then params.AgP:=M_TWOPI-params.AgP;
 end;

 //TrA
 if isCircular then begin
  if isEquatorial then begin
   params.TrA:=arccos(pos.x/absr);
   if vel.x>0 then params.TrA:=M_TWOPI-params.TrA;
  end else begin
   params.TrA:=arccos(smulv(n,pos)/(absn*absr));
   if smulv(n,vel)>0 then params.TrA:=M_TWOPI-params.TrA;
  end;
 end else begin
  tmp:=smulv(e,pos)/(abse*absr);

  //Avoid arccos out of range:
       if tmp<=-1 then params.TrA:=M_PI
  else if tmp>=1  then params.TrA:=0
                  else params.TrA:=arccos(tmp);

  if smulv(pos,vel)<0 then params.TrA:=M_TWOPI-params.TrA;
 end;

 //Lec
 params.Lec:=elements.a*elements.e;

 //SMi
 //b^2=a^2*(1-e^2)
 if isHyperbola then begin
  params.SMi:=sqrt(elements.a*elements.a*(elements.e*elements.e-1));
 end else begin
  params.SMi:=sqrt(elements.a*elements.a*(1-elements.e*elements.e));
 end;

 //LPe
 elements.omegab:=elements.theta+params.AgP;
 if elements.omegab>M_TWOPI then elements.omegab:=elements.omegab-int(elements.omegab/M_TWOPI)*M_TWOPI;
 
 //EcA
 if isHyperbola then begin
  params.EcA:=arccosh((1-absr/elements.a)/elements.e);
 end else if isCircular then begin
  params.EcA:=0;
 end else begin
  tmp:=(1-absr/elements.a)/elements.e;

  //Avoid arccos out of range:
       if tmp<=-1 then params.EcA:=M_PI
  else if tmp>=1  then params.EcA:=0
                  else params.EcA:=arccos(tmp);
 end;

 if isHyperbola then begin
  //Copy sign from sin(TrA)
  if sin(params.TrA)*params.EcA<0 then params.EcA:=-params.EcA;
 end else begin
  //Same rule basically,but with EcA in 0..2pi range
  if sin(params.TrA)<0 then params.EcA:=M_TWOPI-params.EcA;
 end;

 //MnA
 if isHyperbola then begin
  params.MnA:=elements.e*sinh(params.EcA)-params.EcA;
 end else begin
  params.MnA:=params.EcA-elements.e*sin(params.EcA);
 end;

 //MnL
 elements.L:=params.MnA+elements.omegab;
 if elements.L>M_TWOPI then elements.L:=elements.L-int(elements.L/M_TWOPI)*M_TWOPI;

 //TrL
 params.TrL:=elements.omegab+params.TrA;
 if params.TrL>M_TWOPI then params.TrL:=params.TrL-int(params.TrL/M_TWOPI)*M_TWOPI;

 //T=2*pi*sqrt(a^3/mu)
 //fabs is for supporting hyperbola
 params.T:=M_TWOPI*sqrt(abs(elements.a*elements.a*elements.a/mu));

 //Calculating PeT and ApT:
 tPe:=params.MnA*params.T/M_TWOPI;//Time since last Pe

 if isHyperbola then begin
  params.PeT:=-tPe;
 end else begin
  params.PeT:=params.T-tPe;
 end;

 params.ApT:=0.5*params.T-tPe;
 if params.ApT<0 then params.ApT:=params.ApT+params.T;
end;
//############################################################################//
//############################################################################//
procedure kostElements2Shape(elements:pkostElements;shape:pkostOrbitShape);
var i:integer;
multiplier,AgP,maxTrA,dTrA,TrA,absr:double;
direction:vec;
AgPMat,LANMat,IncMat,transform:mat;
begin
 //Some utility values:
 multiplier:=elements.a*(1-elements.e*elements.e);
 AgP:=elements.omegab-elements.theta;

 //First:Orbit in its own coordinate system:
 //Pe,Ap
 shape.pe:=tvec(elements.a*(1-elements.e),0,0);
 shape.ap:=tvec(-elements.a*(1+elements.e),0,0);

 //Points
 if shape.numPoints=1 then begin
  shape.points[0]:=shape.pe;
 end else if shape.numPoints>1 then begin
  //Range of angles
  maxTrA:=M_PI;
  if elements.e>=1 then begin
   maxTrA:=arccos(-1/elements.e);

  //Make it a bit smaller to avoid division by zero:
   maxTrA:=maxTrA*(shape.numPoints/(shape.numPoints+1));
  end;

  //Angle change per segment
  dTrA:=(2*maxTrA)/(shape.numPoints-1);

  TrA:=-maxTrA;
  for i:=0 to shape.numPoints-1 do begin
   absr:=abs(multiplier/(1+elements.e*cos(TrA)));

   direction:=tvec(cos(TrA),sin(TrA),0);
   shape.points[i]:=nmulv(direction,absr);

   TrA:=TrA+dTrA;
  end;
 end;

 //AN
 TrA:=-AgP;
 absr:=multiplier/(1+elements.e*cos(TrA));

 if absr<=0 then begin
  shape.an:=tvec(0,0,0);
 end else begin
  direction:=tvec(cos(TrA),sin(TrA),0);
  shape.an:=nmulv(direction,absr);
 end;

 //DN
 TrA:=M_PI-AgP;
 absr:=multiplier/(1+elements.e*cos(TrA));

 if absr<=0 then begin
  shape.dn:=tvec(0,0,0);
 end else begin
  direction:=tvec(cos(TrA),sin(TrA),0);
  shape.dn:=nmulv(direction,absr);
 end;

 //Then:rotate the coordinates:
 begin
  AgPMat:=kostMakeZRotm(AgP);
  IncMat:=kostMakeXRotm(elements.i);
  LANMat:=kostMakeZRotm(elements.theta);

  //Now,global=LANMat*IncMat*AgPMat*local:
  transform:=mulm(LANMat   ,IncMat);
  transform:=mulm(transform,AgPMat);

  shape.pe:=lvmat(transform,shape.pe);
  shape.ap:=lvmat(transform,shape.ap);
  shape.an:=lvmat(transform,shape.an);
  shape.dn:=lvmat(transform,shape.dn);

  if shape.numPoints<>0 then for i:=0 to shape.numPoints-1 do shape.points[i]:=lvmat(transform,shape.points[i]);
 end;
end;     
//############################################################################//
begin
end. 
//############################################################################//
