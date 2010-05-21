//############################################################################//
// SpaceWay Orbit MFD
// Made in 2005-2010 by Artyom Litvinovich
// Since 2009 based on FreeOrbitMFD code by C J Plooy (cornware-cjp@lycos.nl) 
//############################################################################//
unit orbitscr;
interface
uses asys,grph,strval,maths,space_util,mfd_api;
//############################################################################//
var orbit_info:mfdtyp;
//############################################################################//
implementation
//############################################################################//
const
eFEcliptic=0;
eFEquator=1;
eFMax=2;

ePFrame=0;
ePShip=1;
ePTarget=2;
ePMax=3;

eMBoth=0;
eMList=1;
eMGraphics=2;
eMMax=3;
//############################################################################//
type   
orbdatarec=record
 title:string;
 pos,vel:vec;
 elements:kostElements;
 params:kostOrbitParam;
 shape:kostOrbitShape;
end;
porbdatarec=^orbdatarec;

omfdrec=record
 ves,ref,tgt:pobjtype;
 showalt:boolean;
 frame,prj,mode:integer;

 xs,ys:integer;

 ves_data,tgt_data:orbdatarec;
 orb_scale:double;
end;
pomfdrec=^omfdrec;
//############################################################################// 
var omfddat:omfdrec;  
//############################################################################//    
//############################################################################//                                             
procedure deinitomfdinst(p:pomfdrec);
begin
 //De-allocate shape points:
 setlength(p.ves_data.shape.points,0);
 setlength(p.tgt_data.shape.points,0);
end;
//############################################################################//
//############################################################################//  
procedure calcorb_scaleAndRange(p:pomfdrec);
var points:array of vec;
largest,rad,len_2d:double;
i:integer;
v:pvec;
begin
 //We're looking at 2D coordinates only, so 3D relationships like |PeD| <= |Dst| can not be used.

 setlength(points,2);
 points[0]:=p.ves_data.pos;
 points[1]:=p.ves_data.shape.pe;
 if p.ves_data.elements.e<1 then begin     
  setlength(points,3);
  points[2]:=p.ves_data.shape.ap;
 end;

 if p.tgt<>nil then begin       
  setlength(points,length(points)+2);
  points[length(points)-2]:=p.tgt_data.pos;
  points[length(points)-1]:=p.tgt_data.shape.pe;
  if p.tgt_data.elements.e<1 then begin        
   setlength(points,length(points)+1);
   points[length(points)-1]:=p.tgt_data.shape.ap;
  end;
 end;

 largest:=0;
 for i:=0 to length(points)-1 do begin
  v:=@points[i];
  len_2d:=v.x*v.x+v.y*v.y;
  if len_2d>largest then largest:=len_2d;
 end;
 largest:=sqrt(largest);//Turn length^2 into length
 
 //Last 'point': size of the planet
 rad:=p.ref.r;
 if rad>largest then largest:=rad;
 
 p.orb_scale:=0.45*p.xs/largest;
end;
//############################################################################//
procedure calcDisplayData(p:pomfdrec);
var refOrientation:mat;
refMu:double;
begin     
 //EQU frame orientation
 refOrientation:=trmat(p.ref.rotm);

 refMu:=gconst*(p.ref.m+p.ves.m);

 p.ves_data.pos:=subv(p.ves.pos,p.ref.pos);
 p.ves_data.vel:=subv(p.ves.vel,p.ref.vel);
  
 //To the frame coordinate system:
 if p.frame=eFEquator then begin
  p.ves_data.pos:=lvmat(refOrientation,p.ves_data.pos);
  p.ves_data.vel:=lvmat(refOrientation,p.ves_data.vel);
 end;

 //Transform to standard right-handed coordinate system: y-> z, z-> y
 swapd(p.ves_data.pos.y,p.ves_data.pos.z);
 swapd(p.ves_data.vel.y,p.ves_data.vel.z);

 //Calculate orbital elements
 kostStateVector2Elements(refMu,p.ves_data.pos,p.ves_data.vel,@p.ves_data.elements,@p.ves_data.params);
 
 if p.tgt<>nil then begin
  refMu:=gconst*(p.ref.m+p.tgt.m);
          
  p.tgt_data.pos:=subv(p.tgt.pos,p.ref.pos);
  p.tgt_data.vel:=subv(p.tgt.vel,p.ref.vel);

  //To the frame coordinate system:
  if p.frame=eFEquator then begin
   p.tgt_data.pos:=lvmat(refOrientation,p.tgt_data.pos);
   p.tgt_data.vel:=lvmat(refOrientation,p.tgt_data.vel);
  end;

  //Transform to standard right-handed coordinate system: y-> z, z-> y  
  swapd(p.tgt_data.pos.y,p.tgt_data.pos.z);
  swapd(p.tgt_data.vel.y,p.tgt_data.vel.z);

  //Calculate orbital elements
  kostStateVector2Elements(refMu,p.tgt_data.pos,p.tgt_data.vel,@p.tgt_data.elements,@p.tgt_data.params);
 end;
end;  
//############################################################################//
procedure projectData(p:pomfdrec;data:porbdatarec);
var projElems:kostElements;
rmat,LAN,Inc:mat;
i:integer;
begin
 if p.prj=ePframe then exit;//Already good-> nothing to do

 case p.prj of
  ePShip:projElems:=p.ves_data.elements;
  ePTarget:projElems:=p.tgt_data.elements; 
  else exit;
 end;

 lan:=kostMakeZRotm(-projElems.theta);
 inc:=kostMakeXRotm(-projElems.i);
 rmat:=mulm(trmat(LAN),mulm(Inc,LAN));

 data.pos:=lvmat(rmat,data.pos);
 data.vel:=lvmat(rmat,data.vel);
 data.shape.pe :=lvmat(rmat,data.shape.pe);
 data.shape.ap :=lvmat(rmat,data.shape.ap);
 data.shape.dn :=lvmat(rmat,data.shape.dn);
 data.shape.an :=lvmat(rmat,data.shape.an);
 for i:=0 to data.shape.numPoints-1 do data.shape.points[i]:=lvmat(rmat, data.shape.points[i]);
end;
//############################################################################//
function calcGContribution(p:pomfdrec;var makeRed:boolean):double;
var Gref,Gtot,Gobj:double;
i:integer;
pos:vec;
begin
 makeRed:=false;
 Gref:=p.ref.m/modvs(p.ves_data.pos);
 Gtot:=0;//in (m/s^2)/G,not in Newton!

 for i:=0 to swmg_planets_cnt-1 do begin
  pos:=subv(p.ves.pos,swmg_planets[i].pos);

  Gobj:=swmg_planets[i].m/modvs(pos);
  if(Gobj>Gref)and(swmg_planets[i].id<>p.ref.id)then makeRed:=true;

  Gtot:=Gtot+Gobj;
 end; 
 
 result:=Gref/Gtot;
end;
//############################################################################//
procedure drawDisplayData(p:pomfdrec;dr:pdrwinfo;x,y:integer;data:porbdatarec;cl:crgba);
const ss:array[0..18]of string=('-----------','SMa ','SMi ','PeR ','ApR ','Rad ','Ecc ',
'T   ','PeT ','ApT ','Vel ','Inc ','LAN ','LPe ','AgP ','TrA ','TrL ','MnA ','MnL ');
var lines:array[0..18]of string;
i,txtPos,txtIncr:integer;
refR:double;
begin    
 for i:=0 to 19-1 do lines[i]:=ss[i];

 lines[0]:='--'+data.title+'--';
  
 lines[1]:=lines[1]+strcv(data.elements.a);//SMa
 lines[2]:=lines[2]+strcv(data.params.SMi);//SMi
 lines[3]:=lines[3]+strcv(data.params.PeD);//PeR
 lines[4]:=lines[4]+strcv(data.params.ApD);//ApR
 lines[5]:=lines[5]+strcv(modv(data.pos));//Rad
 lines[6]:=lines[6]+stre(data.elements.e,cntfrac(data.elements.e));//Ecc
 lines[7]:=lines[7]+strcv(data.params.T );//T
 lines[8]:=lines[8]+strcv(data.params.PeT);//PeT
 lines[9]:=lines[9]+strcv(data.params.ApT);//ApT
 lines[10]:=lines[10]+strcv(modv(data.vel));//Vel
 lines[11]:=lines[11]+stre(data.elements.i*(180/PI))+'°';//Inc 
 lines[12]:=lines[12]+stre(data.elements.theta*(180/PI))+'°';//LAN
 lines[13]:=lines[13]+stre(data.elements.omegab*(180/PI))+'°';//LPe
 lines[14]:=lines[14]+stre(data.params.AgP*(180/PI))+'°';//AgP
 lines[15]:=lines[15]+stre(data.params.TrA*(180/PI))+'°';//TrA
 lines[16]:=lines[16]+stre(data.params.TrL*(180/PI))+'°';//TrL
 lines[17]:=lines[17]+stre(data.params.MnA*(180/PI))+'°';//MnA
 lines[18]:=lines[18]+stre(data.elements.L*(180/PI))+'°';//MnL

 //Convert to Alt:
 if p.showalt then begin
  lines[3]:='PeA ';
  lines[4]:='ApA ';
  lines[5]:='Alt ';

  refR:=p.ref.r;
  lines[3]:=lines[3]+strcv(data.params.PeD-refR);//PeA
  lines[4]:=lines[4]+strcv(data.params.ApD-refR);//ApA
  lines[5]:=lines[5]+strcv(modv(data.pos)-refR);//Alt
 end;
 
 //Some data is not available for hyperbola:
 if data.elements.e>=1 then begin
  lines[ 4]:=ss[ 4]+' N/A';//ApR
  lines[ 7]:=ss[ 4]+' N/A';//T
  lines[ 9]:=ss[ 4]+' N/A';//ApT
  lines[18]:=ss[ 4]+' N/A';//MnL
 end;
 
 txtPos:=y;
 txtIncr:=(p.ys-10) div 22;

 for i:=0 to 19-1 do begin swmg_text(dr,lines[i],x,txtPos,cl);txtPos:=txtPos+txtIncr;end;
end;
//############################################################################//
procedure drawOrbitShape(p:pomfdrec;dr:pdrwinfo;cl:crgba;data:porbdatarec);
var pt:vec;
po,pn:ivec2;
i,x,y:integer;
hasDN,hasAN:boolean;
begin
 //Orbit shape:
 for i:=0 to data.shape.numPoints-1 do begin
  pt:=nmulv(data.shape.points[i],p.orb_scale);
  pn.x:=p.xs div 2+round(pt.x);
  pn.y:=p.ys div 2-round(pt.y);//Flipped y-axis
  if i<>0 then swmg_line(dr,po.x,po.y,pn.x,pn.y,cl);
  po:=pn;
 end;

 //Object line:
 pt:=nmulv(data.pos,p.orb_scale);
 swmg_line(dr,p.xs div 2,p.ys div 2,p.xs div 2+round(pt.x),p.ys div 2-round(pt.y),cl);
  
 hasDN:=modvs(data.shape.dn)>0.1;
 hasAN:=modvs(data.shape.an)>0.1;

 //Pe
 pt:=nmulv(data.shape.pe,p.orb_scale);
 x:=p.xs div 2+round(pt.x);
 y:=p.ys div 2-round(pt.y);//Flipped y-axis
 for i:=0 to 3 do swmg_ellipse(dr,x-3+i,y-3+i,x+4-i,y+4-i,cl);

 //Ap
 if data.elements.e<1 then begin
  pt:=nmulv(data.shape.ap,p.orb_scale);
  x:=p.xs div 2+round(pt.x);
  y:=p.ys div 2-round(pt.y);//Flipped y-axis
  swmg_ellipse(dr,x-3,y-3,x+4,y+4,cl);
 end;

 //DN
 if hasDN then begin
  pt:=nmulv(data.shape.dn,p.orb_scale);
  x:=p.xs div 2+round(pt.x);
  y:=p.ys div 2-round(pt.y);//Flipped y-axis
  swmg_sqr(dr,x-3,y-3,7,7,gclaz,cl);
 end;
 
 //AN
 if hasAN then begin
  pt:=nmulv(data.shape.an,p.orb_scale);
  x:=p.xs div 2+round(pt.x);
  y:=p.ys div 2-round(pt.y);//Flipped y-axis
  swmg_sqr(dr,x-3,y-3,7,7,cl,cl);
 end;
 {
 //Line between DN and AN
 if(hasDN and hasAN)then begin
 //Dashed pen:
  HPEN pen=CreatePen(PS_DOT,1,color);
  HPEN oldpen=(HPEN)SelectObject(hDC,pen);

  pt=data.shape.dn*p.orb_scale;
  MoveToEx(hDC, p.xs div 2+round(pt.x),p.ys div 2-round(pt.y),nil);

  pt=data.shape.an*p.orb_scale;
  LineTo( hDC, p.xs div 2+round(pt.x),p.ys div 2-round(pt.y));

  SelectObject(hDC,oldpen);
  DeleteObject(pen);
 end;
 }
end;
//############################################################################//
//############################################################################//
procedure orbitdraw(dr:pdrwinfo;p:pomfdrec);
var s:string;
radius:integer;
makeRed:boolean;
Gpart:double;
cl:crgba;
begin          
 if p.ves=nil then begin  
  swmg_textcnt(dr,'No target',dr.xs div 2,dr.ys div 2,gclgreen);
  swmg_textcnt(dr,'Orbit Tool',dr.xs div 2,10,gclgreen);
  exit;
 end; 
 if p.ref=nil then p.ref:=p.ves.ref;
 if p.ref=nil then begin  
  swmg_textcnt(dr,'Interstellar',dr.xs div 2,dr.ys div 2,gclgreen);
  swmg_textcnt(dr,'Orbit Tool',dr.xs div 2,10,gclgreen);
  exit;
 end; 
 
 //Calculating orbital data
 calcDisplayData(p);
 
 if p.ref<>nil then s:='Orbit'+': '+p.ref.name else s:='N/A'; 
 swmg_text(dr,s,2,1,gclwhite);
 
 //frame, prj indicators
 s:='ECL';
 if p.frame=eFEquator then s:='EQU';
 swmg_text(dr,s,round(0.718*p.xs)-2,1,gclwhite);

 if p.prj=ePShip   then s:='SHP';
 if p.prj=ePTarget then s:='TGT';  
 swmg_text(dr,s,round(0.924*p.xs)-2,1,gclwhite);
 
 swmg_text(dr,'Frm',round(0.629*p.xs)-2,1,gclgray);
 swmg_text(dr,'Prj',round(0.830*p.xs)-2,1,gclgray);

 
 //G-field contribution indicator
 makeRed:=false;
 Gpart:=calcGContribution(p,makeRed);

 //Variable color:
 if makeRed then cl:=gclred 
            else if Gpart<0.8 then cl:=tcrgba($AC,$AC,0,255)
                              else cl:=tcrgba($00,$EC,0,255);
   
 swmg_text(dr,'G '+stre(Gpart),round(0.423*p.xs),p.ys-15,cl);
 
 //Graphical visualisation
 if(p.mode=eMGraphics)or(p.mode=eMBoth)then begin
  kostElements2Shape(@p.ves_data.elements,@p.ves_data.shape);
  projectData(p,@p.ves_data);

  if p.tgt<>nil then begin
   kostElements2Shape(@p.tgt_data.elements,@p.tgt_data.shape);
   projectData(p,@p.tgt_data);
  end;

  calcorb_scaleAndRange(p);

  drawOrbitShape(p,dr,tcrgba($00,$E6,$00,255),@p.ves_data);
  if p.tgt<>nil then drawOrbitShape(p,dr,tcrgba($AC,$AC,$00,255),@p.tgt_data);

  //Planet surface:
  radius:=round(p.orb_scale*p.ref.r);
  if radius>0 then swmg_ellipse(dr,p.xs div 2-radius,p.ys div 2-radius,p.xs div 2+radius,p.ys div 2+radius,tcrgba($8C,$8E,$8C,255));
 end;
   
 //Orbital element lists
 if(p.mode=eMList)or(p.mode=eMBoth)then begin
  p.ves_data.title:='OSC.EL.';
  drawDisplayData(p,dr,3,16,@p.ves_data,tcrgba(0,$e6,0,255));

  
  if p.tgt<>nil then begin
   p.tgt_data.title:=p.tgt.name;
   drawDisplayData(p,dr,3+round(0.69*p.xs),16,@p.tgt_data,tcrgba($AC,$AC,0,255));
  end
 end;
end;
//############################################################################//
//############################################################################//
procedure orbitinit(p:pomfdrec;xs,ys:integer;tgt:pobjtype);
begin
 p.ves:=tgt;
 p.xs:=xs;
 p.ys:=ys;

 //Allocate shape points:
 p.ves_data.shape.numPoints:=100;
 p.tgt_data.shape.numPoints:=100;
 
 setlength(p.ves_data.shape.points,p.ves_data.shape.numPoints);
 setlength(p.tgt_data.shape.points,p.tgt_data.shape.numPoints);

 //Initial mode:
 p.showalt:=true;
 p.frame  :=eFEcliptic;
 p.prj    :=ePShip;
 p.tgt    :=nil;
 p.mode   :=eMBoth;
 p.ref    :=nil;
end;
//############################################################################//
procedure orbittimer(p:pomfdrec;dt,st:double);begin end;     
//############################################################################//
procedure orbit_tgtcb(c:integer;p:pomfdrec);
begin
 if c<0 then exit;if c>=swmg_planets_cnt then exit;             
 p.tgt:=swmg_planets[c]; 
end;     
//############################################################################//
procedure orbit_refcb(c:integer;p:pomfdrec);
begin
 if c<0 then exit;if c>=swmg_planets_cnt then exit;             
 p.ref:=swmg_planets[c]; 
end; 
//############################################################################//
procedure orbitkeyinp(p:pomfdrec;tp,key:byte;shift:tshiftstate);
begin
 {$ifndef win32}
 case key of
  80:key:=ord('P');
  82:key:=ord('R');
  65:key:=ord('A');
  84:key:=ord('T');
  78:key:=ord('N');
  77:key:=ord('M');
  70:key:=ord('F');
  68:key:=ord('D');
  else key:=0;
 end;
 {$endif}
 case chr(key) of
  'R':mkcbcallback('Orbit tool ref:',@orbit_refcb,p);
  'A':p.ref:=p.ves.ref;
  'T':mkcbcallback('Orbit tool tgt:',@orbit_tgtcb,p);
  'N':begin
   p.tgt:=nil;
   if p.prj=ePTarget then p.prj:=ePframe;
  end;
  'M':begin
   p.mode:=p.mode+1;
   if p.mode=eMMax then p.mode:=eMBoth;
  end;
  'F':begin
   p.frame:=p.frame+1;
   if p.frame=eFMax then p.frame:=eFEcliptic;
  end;
  'P':begin
   p.prj:=p.prj+1;
   if p.prj=ePMax then p.prj:=ePframe;
   if(p.prj=ePTarget)and(p.tgt=nil)then p.prj:=ePframe;
  end;
  'D':p.showalt:=not p.showalt;
 end;
end;   
//############################################################################//   
begin
 orbit_info:=mkmfdtyp('Orbital',@omfddat,@orbitinit,@orbitdraw,@orbittimer,@orbitkeyinp);
end.   
//############################################################################//

