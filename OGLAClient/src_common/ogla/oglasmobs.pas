//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA graphics one
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglasmobs;
interface
uses asys,grph,maths,ogladata;
//############################################################################// 
procedure smob_animate(ves:poglas_smob;an:dword;state:double);      
procedure calcveshi(scn:poglascene;var shi,shj:aointeger);    
function ves_thatisvis(scn:poglascene;i,j,p:integer):boolean;
//############################################################################// 
var mgxform:function(obj:pointer;mgt:pointer):mgroup_transform;cdecl;
var mgxformput:procedure(obj:pointer;mgt:pointer;grp:pmgroup_transform);cdecl;
//############################################################################// 
implementation    
//############################################################################// 
procedure smob_animate_transform_point(p:pvec;tr:pmgroup_transform;ds,s0,s1:double);
var v:vec;   
sx,sy,sz:double;
begin
 case tr.tp of
  1:begin
   v:=subv(p^,tr.ref);
   rotatevector(v,tr.axis,-tr.angle*ds);
   p^:=addv(v,tr.ref);
  end;
  2:p^:=addv(p^,nmulv(tr.shift,ds));    
  3:begin        
   sx:=((s1*(tr.scale.x-1)+1)/(s0*(tr.scale.x-1)+1));
   sy:=((s1*(tr.scale.y-1)+1)/(s0*(tr.scale.y-1)+1));
   sz:=((s1*(tr.scale.z-1)+1)/(s0*(tr.scale.z-1)+1));

   p^.x:=p^.x*sx+tr.ref.x*(1-sx);
   p^.y:=p^.y*sy+tr.ref.y*(1-sy);
   p^.z:=p^.z*sz+tr.ref.z*(1-sz);
  end;
 end;
end;    
//############################################################################// 
procedure smob_animate_transform_direction(p:pvec;tr:pmgroup_transform;normalise:boolean;ds,s0,s1:double);  
begin
 case tr.tp of
  1:rotatevector(p^,tr.axis,-tr.angle*ds);  
 end;
 if normalise then p^:=nrvec(p^);
end;     
//############################################################################// 
procedure smob_animate_transform_group(ves:poglas_smob;mn,gn:dword;tr:pmgroup_transform;s0,s1,ds:double);
var ve:pdraw_rec;
i:integer;
g:ptypmshgrp;
v:vec;
sx,sy,sz:double;
begin
 ve:=ves.draw;
 g:=@ve.mshs[mn].grp[gn];
 g.static:=false;
 for i:=0 to length(g.pnts)-1 do case tr.tp of    
  1:begin
   v:=subv(m2v(g.pnts[i].pos),tr.ref);
   rotatevector(v,tr.axis,-tr.angle*ds);
   g.pnts[i].pos:=v2m(addv(v,tr.ref));
   v:=m2v(g.pnts[i].nml);
   rotatevector(v,tr.axis,-tr.angle*ds);
   g.pnts[i].nml:=v2m(v);
  end; 
  2:g.pnts[i].pos:=v2m(addv(m2v(g.pnts[i].pos),nmulv(tr.shift,ds)));
  3:begin        
   sx:=((s1*(tr.scale.x-1)+1)/(s0*(tr.scale.x-1)+1));
   sy:=((s1*(tr.scale.y-1)+1)/(s0*(tr.scale.y-1)+1));
   sz:=((s1*(tr.scale.z-1)+1)/(s0*(tr.scale.z-1)+1));

   g.pnts[i].pos.x:=g.pnts[i].pos.x*sx+tr.ref.x*(1-sx);
   g.pnts[i].pos.y:=g.pnts[i].pos.y*sy+tr.ref.y*(1-sy);
   g.pnts[i].pos.z:=g.pnts[i].pos.z*sz+tr.ref.z*(1-sz);
  end;
 end;
 case tr.tp of  
  1:begin
   v:=subv(g.center,tr.ref);
   rotatevector(v,tr.axis,-tr.angle*ds);
   g.center:=addv(v,tr.ref);
  end;  
  2:g.center:=addv(g.center,nmulv(tr.shift,ds));
  3:begin        
   sx:=((s1*(tr.scale.x-1)+1)/(s0*(tr.scale.x-1)+1));
   sy:=((s1*(tr.scale.y-1)+1)/(s0*(tr.scale.y-1)+1));
   sz:=((s1*(tr.scale.z-1)+1)/(s0*(tr.scale.z-1)+1));

   g.center.x:=g.center.x*sx+tr.ref.x*(1-sx);
   g.center.y:=g.center.y*sy+tr.ref.y*(1-sy);
   g.center.z:=g.center.z*sz+tr.ref.z*(1-sz);
  end;
 end;
end;      
//############################################################################// 
procedure smob_animate_comp(ves:poglas_smob;comp:panimationcomp;tr:pmgroup_transform;s0,s1,ds:double);
var ve:pdraw_rec;
trl,trc:mgroup_transform;
child:panimationcomp;
i:integer;
vtx:pvecar;
begin
 ve:=ves.draw;
 trl:=mgxform(ves.ob,comp.trans);
 
 if integer(trl.mesh)=-1 then begin // transform a list of individual vertices
  vtx:=pvecar(trl.grp);
  for i:=0 to trl.ngrp-1 do smob_animate_transform_point(@(vtx[i]),tr,ds,s0,s1);
 end else begin                              // transform mesh groups
  if trl.mesh>=dword(ve.nmesh) then exit; // mesh index out of range
  if trl.grp<>nil then begin // animate individual mesh groups
   for i:=0 to trl.ngrp-1 do smob_animate_transform_group(ves,trl.mesh,pdworda(trl.grp)[i],tr,s0,s1,ds);
  end else begin          // animate complete mesh
  end;
 end;
     
 // recursively transform all child animations
 for i:=0 to comp.nchildren-1 do begin
  child:=comp.children[i];
  smob_animate_comp(ves,child,tr,s0,s1,ds); 
   
  trc:=mgxform(ves.ob,child.trans);
  case trc.tp of
   0:; 
   1:begin
    smob_animate_transform_point(@trc.ref,tr,ds,s0,s1);
    smob_animate_transform_direction(@trc.axis,tr,true,ds,s0,s1);
   end;
   2:smob_animate_transform_direction(@trc.shift,tr,false,ds,s0,s1);
   3:smob_animate_transform_point(@trc.ref,tr,ds,s0,s1);
  end;   
  mgxformput(ves.ob,child.trans,@trc);
 end;  
end;     
//############################################################################//        
procedure smob_animate(ves:poglas_smob;an:dword;state:double);
var a:panimation; 
ac:panimationcomp;
vd:pdraw_rec;
tr:mgroup_transform;
i,ii:integer;
s0,s1,ds:double;
begin 
 a:=@ves.draw.anim[an];
 vd:=ves.draw;
 for ii:=0 to a.ncomp-1 do begin
  if state>vd.animstate[an] then i:=ii else i:=a.ncomp-dword(ii)-1;
  ac:=a.comp[i];
  tr:=mgxform(ves.ob,ac.trans);
  //if(mshidx<>maxint)and(dword(mshidx)<>tr.mesh)then continue;
  s0:=vd.animstate[an]; // current animation state in the visual
  if s0<ac.state0 then s0:=ac.state0 else if s0>ac.state1 then s0:=ac.state1;
  s1:=state;           // required animation state
  if s1<ac.state0 then s1:=ac.state0 else if s1>ac.state1 then s1:=ac.state1;
  ds:=s1-s0;
  if ds=0 then continue; // nothing to do for this component
  ds:=ds/(ac.state1-ac.state0);   // stretch to range 0..1 
    
  s0:=(s0-ac.state0)/(ac.state1-ac.state0);
  s1:=(s1-ac.state0)/(ac.state1-ac.state0);

  smob_animate_comp(ves,ac,@tr,s0,s1,ds);
 end;
end;    
//############################################################################// 
//Vessels visibility queue
procedure calcveshi(scn:poglascene;var shi,shj:aointeger);
var i,j,p,c:integer;   
cp,vc:boolean;
begin
 setlength(shi,0);
 for p:=0 to 1 do for i:=0 to length(scn.smobs)-1 do if scn.smobs[i]<>nil then {if scn.smobs[i].tp=SMOB_VESSEL then }if scn.smobs[i].draw<>nil then begin    
  if scn.smobs[i].draw.drmsh then begin
   cp:=scn.smobs[i].draw.cp;
	  vc:=cp and scn.invc;
      
   if scn.smobs[i].draw.nmesh>0 then for j:=0 to scn.smobs[i].draw.nmesh-1 do begin
    if(scn.smobs[i].draw.mshv[j] and MESHVIS_NEVER)<>0 then continue;
     
    if p=0 then begin
     if cp then continue;
     if((scn.smobs[i].draw.mshv[j] and MESHVIS_EXTERNAL)=0)and((scn.smobs[i].draw.mshv[j] and MESHVIS_EXTPASS)=0) then continue;
    end;  
    if p=1 then begin
     if not cp then continue;
     if(scn.smobs[i].draw.mshv[j] and MESHVIS_EXTPASS)<>0 then continue; 
     if((scn.smobs[i].draw.mshv[j] and MESHVIS_COCKPIT)=0)and((not vc)or((scn.smobs[i].draw.mshv[j] and MESHVIS_VC)=0)) then continue;
    end; 
    
    c:=length(shi);
    setlength(shi,c+1);
    setlength(shj,c+1);
    shi[c]:=i;shj[c]:=j;
   end;   
  end;
 end;  
end;
//############################################################################//
function ves_thatisvis(scn:poglascene;i,j,p:integer):boolean;
var cp,vc:boolean;  
v:dword;
begin    
 result:=false; 
 if scn.smobs[i]=nil then exit;
 cp:=scn.smobs[i].draw.cp;
 vc:=cp and scn.invc;
 v:=scn.smobs[i].draw.mshv[j];

 if cp then begin
  if(p=1)and((v and MESHVIS_EXTPASS)<>0)then exit;
  if not((v and MESHVIS_COCKPIT)<>0)then begin
   if (not vc) or (not((v and MESHVIS_VC)<>0)) then exit;
  end;
 end else begin
  if not((v and MESHVIS_EXTERNAL)<>0)then exit;
 end; 
 result:=true;


  {
 result:=false; 
 if scn.smobs[i]=nil then exit;
 cp:=scn.smobs[i].draw.cp;
 vc:=cp and scn.invc;
 if(scn.smobs[i].draw.mshv[j] and MESHVIS_NEVER)<>0 then exit;
 if p=0 then begin
  if cp then exit;
  if((scn.smobs[i].draw.mshv[j] and MESHVIS_EXTERNAL)=0)and((scn.smobs[i].draw.mshv[j] and MESHVIS_EXTPASS)=0) then exit;
 end;  
 if p=1 then begin
  if not cp then exit;
  if(scn.smobs[i].draw.mshv[j] and MESHVIS_EXTPASS)<>0 then exit;
  if((scn.smobs[i].draw.mshv[j] and MESHVIS_COCKPIT)=0)and(((not vc)and(not vcon))or((scn.smobs[i].draw.mshv[j] and MESHVIS_VC)=0)) then exit;
 end; 
 result:=true;
 }
end;
//############################################################################// 
begin
end.
//############################################################################//

    

