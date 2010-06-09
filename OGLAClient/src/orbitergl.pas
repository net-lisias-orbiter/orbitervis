//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLAClient Orbiter specific unit
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit orbitergl;
interface
uses sysutils,asys,maths,strval,grph,log,glras_surface,ogladata,oapi{$ifndef no_render},oglashaders,glgr,oglautil,oglacalc,oglasmobs,glpars{$endif};
             
const 
max_surf_dist=1e4;
max_centre_dist=0.9e6;

//Repository types 
type   
msmrec=record
 name:string;
 msh:ptypmsh;
 hnd:pointer;
end;
pmsmrec=^msmrec;

//Link types
type
basetp=record
 sbs,sas:ppointer;
 nsbs,nsas:dword;
end;
pbasetp=^basetp;

type StarRec=record
 lng,lat,mag:single;
end;
StarRenderPrm=record
	mag_hi,mag_lo,brt_min:double;
	map_log:boolean;
end;
pStarRenderPrm=^StarRenderPrm;
//############################################################################// 
var
//Default haze texture
dhtx:cardinal;  
//Mesh repository   
msm:array of pmsmrec; 
//Visuals
smobm:apdraw_rec; 

{$ifndef no_render}
//Callins
Rndspl:procedure(str:string;a:double=0;b:double=0;c:double=0);
Rndprg:procedure(str,cap:string;ld:boolean);

getbase:function(id:ohnd):pbasetp;cdecl; 
visop:procedure(tp:integer;ob:ohnd;vis:pointer);cdecl; 
getmsurf:function(tp,p:integer):pinteger;cdecl; 
getconfigparam:function(par:dword):pointer;cdecl; 
vcsurf:function(tp,n:integer;mf:pointer):pinteger;cdecl; 
          
//############################################################################//    

//Vessel and base state update              
procedure proc_smob(scn:poglascene);
//Add vessel mesh
procedure add_one_vessel_mesh(se:pdraw_rec;i:integer;dgfix:boolean);  
//Planet state update
procedure procplanets(scn:poglascene);
//Planet loading
procedure initplanets(scn:poglascene); 
//Add particle stream
procedure addpstrm(scn:poglascene;tp:integer;es:dword;pss:pPARTICLESTREAMSPEC;hVessel:ohnd;lvl:pdouble;ref,dir:pvec);
{$endif}
//############################################################################//
function  ldmsh(m:pointer;msmit:boolean=true;dgfix:boolean=false):ptypmsh;
procedure gethaze(h:poplhazetyp;po:ohnd;n:string);  
function  getmsh(m:pointer):ptypmsh;        
procedure freemsh(var m:ptypmsh);
//############################################################################//
implementation  
//############################################################################//
//############################################################################// 
// Haze parameters loading
procedure gethaze(h:poplhazetyp;po:ohnd;n:string);
var atmc:pATMCONST;
v:vec;
hd:double;
begin //try
 atmc:=oapiGetPlanetAtmConstants(po);
 if atmc<>nil then begin
  v:=pvec(oapiGetObjectParam(po,OBJPRM_PLANET_HAZECOLOUR))^;
  hd:=pdouble(oapiGetObjectParam(po,OBJPRM_PLANET_HAZEDENSITY))^;

  h.basecol:=tvcrgbad(v);
  h.hralt:=atmc^.horizonalt/h.rad;
  h.dens0:=(min2(1,(atmc.horizonalt/64e3)*hd));
 end else begin
  h.basecol:=tcrgbad(1,1,1,1);
  h.hralt:=0.01;
  h.dens0:=1;
 end;
 h.hasclouds:=pbytebool(oapiGetObjectParam(po,OBJPRM_PLANET_HASCLOUDS))^;
 if h.hasclouds then begin
  h.hshift:=pdouble(oapiGetObjectParam(po,OBJPRM_PLANET_HAZESHIFT))^;
  h.cloudalt:=pdouble(oapiGetObjectParam(po,OBJPRM_PLANET_CLOUDALT))^;
 end else h.hshift:=0;
 h.hscale:=1-pdouble(oapiGetObjectParam(po,OBJPRM_PLANET_HAZEEXTENT))^;
 //except stderr('ORBGL','Error in mkhaze'); end; 
end;   
//############################################################################// 
//Mesh reciever from Orbiter
function ldmsh(m:pointer;msmit:boolean=true;dgfix:boolean=false):ptypmsh;
var nm:pmsmrec;
gc,i,j:integer;
mg:pMESHGROUPEX;
gr:ptypmshgrp;
v:pNTVERTEX;
mt:pMATERIAL;
w:pword;
tx:psurfinfo;

v1,v2,tan:vec;
st1,st2:vec2;

begin i:=0;gc:=0; result:=nil; try 
 new(nm);      
 new(nm.msh);  
 if msmit then begin
  setlength(msm,length(msm)+1);
  msm[length(msm)-1]:=nm;
 end;            
 mkcln_msh(nm.msh);
 nm.msh.used:=false;  
 
 if m<>nil then begin
  gc:=oapiMeshGroupCount(m);   
  nm.hnd:=m;    
  nm.msh.used:=true;  
  setlength(nm.msh.grp,gc);    
  nm.msh.grc:=gc; 
  nm.msh.txc:=oapiMeshTextureCount(m)+1;   

  for i:=0 to gc-1 do begin  
   mg:=oapiMeshGroupEx(m,i);    
   gr:=@nm.msh.grp[i]; 
   mkcln_mshgrp(gr);  
                      
   setlength(gr.pnts,mg.nvtx);     
   setlength(gr.trng,mg.nidx); 
   gr.static:=msmit;   
   
   if mg.MtrlIdx<>$FFFFFFFF then begin    
    mt:=oapiMeshMaterial(m,mg.MtrlIdx);  
    if mt<>nil then gr.col:=tdcrgba(mt.diffuse.r,mt.diffuse.g,mt.diffuse.b,mt.diffuse.a);
    if mt<>nil then gr.cole:=tdcrgba(mt.emissive.r,mt.emissive.g,mt.emissive.b,mt.emissive.a);
    if mt<>nil then gr.cols:=tdcrgba(mt.specular.r,mt.specular.g,mt.specular.b,mt.specular.a);
    if mt<>nil then gr.spow:=mt.power;
   end;     
   if gr.spow=0 then gr.cols:=gclaz;                            
   gr.orbMtrlIdx:=mg.MtrlIdx; 
            
   v:=mg.vtx;   
   for j:=0 to mg.nvtx-1 do begin   
    gr.pnts[j].nml:=tmvec(v.nx,v.ny,v.nz);
    gr.pnts[j].pos:=tmvec(v.x,v.y,v.z);   
    gr.pnts[j].tng:=v2m(zvec);
         
    //FIXME: Crutch - DG HUD, HUD should ben non-Z
    if dgfix then 
     if i=136 then 
      if j in [2,3] then 
       if gr.pnts[j].pos.z-7.09<0.01 then 
        gr.pnts[j].pos.z:=7.02;
         
    if abs(gr.pnts[j].pos.x)>gr.siz then gr.siz:=abs(gr.pnts[j].pos.x);
    if abs(gr.pnts[j].pos.y)>gr.siz then gr.siz:=abs(gr.pnts[j].pos.y);
    if abs(gr.pnts[j].pos.z)>gr.siz then gr.siz:=abs(gr.pnts[j].pos.z);
    if gr.siz>nm.msh.siz then nm.msh.siz:=gr.siz;
    gr.pnts[j].tx.x:=v.tu;
    gr.pnts[j].tx.y:=v.tv;                                                                       
    v:=pointer(dword(v)+sizeof(NTVERTEX));
   end;     
   w:=pointer(mg.idx);   
   for j:=0 to mg.nidx-1 do gr.trng[j]:=pword(dword(w)+dword(sizeof(word)*j))^;
   for j:=0 to mg.nidx div 3-1 do begin       
    v1:=subv(m2v(gr.pnts[gr.trng[j*3+1]].pos),m2v(gr.pnts[gr.trng[j*3+0]].pos));
    v2:=subv(m2v(gr.pnts[gr.trng[j*3+2]].pos),m2v(gr.pnts[gr.trng[j*3+0]].pos));
    st1:=subv(m2v(gr.pnts[gr.trng[j*3+1]].tx),m2v(gr.pnts[gr.trng[j*3+0]].tx));
    st2:=subv(m2v(gr.pnts[gr.trng[j*3+2]].tx),m2v(gr.pnts[gr.trng[j*3+0]].tx));
    tan:=nrvec(subv(nmulv(v1,st2.y),nmulv(v2,st1.y)));
    gr.pnts[gr.trng[j*3+0]].tng:=v2m(addv(m2v(gr.pnts[gr.trng[j*3+0]].tng),tan));
    gr.pnts[gr.trng[j*3+1]].tng:=v2m(addv(m2v(gr.pnts[gr.trng[j*3+1]].tng),tan));
    gr.pnts[gr.trng[j*3+2]].tng:=v2m(addv(m2v(gr.pnts[gr.trng[j*3+2]].tng),tan));
   end; 
   for j:=0 to mg.nvtx-1 do gr.pnts[j].tng:=nrvec(gr.pnts[j].tng);                            
   gr.orbTexIdx:=mg.TexIdx; 
           
   gr.xmit_tx:=notx;
   if oapiGetTextureHandle(m,mg.TexIdx+1)<>nil then gr.xmit_tx:=pinteger(oapiGetTextureHandle(m,mg.TexIdx+1))^;            
   tx:=txget(oapiGetTextureHandle(m,mg.TexIdx+1));

   if tx<>nil then begin   
    assert(tx.mag=SURFH_MAG); 
    gr.dif.tx:=tx.tex;    
    gr.dif.xs:=tx.w;    
    gr.dif.ys:=tx.h;   
    gr.dif.p:=nil;   
   end;   
   gr.siz:=gr.siz*sqrt(2); 
  
  end;   
  nm.msh.siz:=nm.msh.siz*sqrt(2); 
 end;
 
 result:=nm.msh;
 if not msmit then begin   
  nm.msh:=nil;     
  dispose(nm);   
 end;    
   
 i:=-1;    
 except stderr('Graph','Error in ldmsh (i='+stri(i)+', gc='+stri(gc)+')'); end;  
end;   
//############################################################################//
//Search for mesh in repository
function getmsh(m:pointer):ptypmsh;
var i:integer;
begin
 result:=nil;
 for i:=0 to length(msm)-1 do if msm[i].hnd=m then begin result:=@msm[i].msh; exit; end;
end;   
//############################################################################// 
//Free mesh
procedure freemsh(var m:ptypmsh);
var i:integer;
begin //try          
 for i:=0 to length(m.grp)-1 do begin
  finalize(m.grp[i].pnts);
  finalize(m.grp[i].trng); 
  setlength(m.grp[i].pnts,0);
  setlength(m.grp[i].trng,0); 
 end;  
 finalize(m.grp);
 setlength(m.grp,0);  
 m:=nil;
  
 //except stderr('Graph','Error in freemsh'); end;  
end;      
{$ifndef no_render}  
//############################################################################// 
//Athmospherics loading
procedure setatmparam(scn:poglascene;pln:poglas_planet);
var atmp:pATMCONST;
cdist:double;
prm:ATMPARAM;
begin //try
 if pln.draw.atm then begin
  atmp:=oapiGetPlanetAtmConstants(pln.obj);
  cdist:=modv(pln.cpos);
  pln.draw.atmradlimit:=atmp.radlimit;
  pln.draw.clds.rot:=pdouble(oapiGetObjectParam(pln.obj,OBJPRM_PLANET_CLOUDROTATION))^;
  if cdist<(atmp^.radlimit)then begin
   oapiGetPlanetAtmParams(pln.obj,cdist,@prm);
   pln.draw.atmrho:=prm.rho;
   pln.draw.atmrho0:=atmp.rho0;
   pln.draw.atmcolor0:=tcrgbad(atmp.color0.x,atmp.color0.y,atmp.color0.z,1);
  end;
 end;
 //except stderr('ORBGL','Error in orbgetskycolor'); end; 
end;      
//############################################################################//
//############################################################################// 
//############################################################################// 
//############################################################################// 
procedure dbg_lights_for_dg(se:pdraw_rec); 
var i:integer;
begin
 se.lights_cnt:=lights_limit-4;
 setlength(se.lights,se.lights_cnt);  
  
 for i:=0 to se.lights_cnt div 2-1 do begin
  new(se.lights[i]);
  se.lights[i].ison:=true;
  se.lights[i].tp:=OGLA_LIGHT_SPOT;
  se.lights[i].rad:=10000;
  se.lights[i].bndtp:=0;
  se.lights[i].spot:=15;
  se.lights[i].pwr:=2000;   
  se.lights[i].setpwr:=1;   
  se.lights[i].pos:=tvec(60*sin((i/(se.lights_cnt div 2))*2*pi),40*cos((i/(se.lights_cnt div 2))*2*pi),-5);
  se.lights[i].dir:=tvec(0,0,1);
  se.lights[i].col:=tcrgba(128+random(128),random(255),random(255),255);    
 end;  
 for i:=se.lights_cnt div 2 to se.lights_cnt-1 do begin
  new(se.lights[i]);
  se.lights[i].ison:=true;
  se.lights[i].tp:=OGLA_LIGHT_SPOT;
  se.lights[i].rad:=10000;   
  se.lights[i].bndtp:=0;
  se.lights[i].spot:=15;
  se.lights[i].pwr:=2000;   
  se.lights[i].setpwr:=1;   
  se.lights[i].pos:=tvec(40*sin(((i-se.lights_cnt div 2)/(se.lights_cnt div 2))*2*pi),20*cos(((i-se.lights_cnt div 2)/(se.lights_cnt div 2))*2*pi),-5);
  se.lights[i].dir:=tvec(0,0,1);
  se.lights[i].col:=tcrgba(128+random(128),random(255),random(255),255);    
 end; 
end;          
//############################################################################// 
procedure add_one_vessel_mesh(se:pdraw_rec;i:integer;dgfix:boolean);
var hmesh:pointer;  
msh:ptypmsh;  
ofs:vec;
begin
 hMesh:=vesGetMeshTemplate(se.obj,i);
 msh:=getmsh(hMesh); 
          
 if(hmesh<>nil)and(msh<>nil)then begin
  //copy from preloaded template
  copy_msh(se.mshs[i]^,msh^);                                                                    
  vesGetMeshOffset(se.obj,i,@ofs); 
  se.mshs[i].off:=ofs;
 end else begin
  //load on the fly and discard after copying        
  hMesh:=vesCopyMeshFromTemplate(se.obj,i);
  if hMesh=nil then exit;                                                                         
  vesGetMeshOffset(se.obj,i,@ofs); 
  se.mshs[i]:=ldmsh(hMesh,true,dgfix);            
  se.mshs[i].off:=ofs;
  //oapiDeleteMesh(hMesh);
 end;   
 se.mshv[i]:=vesGetMeshVisibilityMode(se.obj,i);
end;
//############################################################################// 
//Vessels processing - load mesh from Orbiter    
function prcsmobmsh(v:pointer;nam,cnam:string;base:boolean):pdraw_rec;
var hmesh:pointer;
i:integer;
se:pdraw_rec;
anim:panimationa;
msh:ptypmsh;  
bt:basetp;  
begin i:=0; result:=nil; try
 se:=nil;
 for i:=0 to length(smobm)-1 do if smobm[i].obj=v then begin result:=smobm[i];exit;end;
 if se=nil then begin
  setlength(smobm,length(smobm)+1);
  new(smobm[length(smobm)-1]);
  se:=smobm[length(smobm)-1];
  result:=se;
 end;
 se.obj:=v; 
 se.semit:=0;   
 se.lights_cnt:=0;    
 setlength(se.lights,se.lights_cnt);  
 se.vc_shadows:=false;   
 se.nanim:=0;
 se.anim:=nil;

 if not base then begin   
  rndprg('Loading Vessel ('+nam+':'+cnam+')','',false);  
  se.nmesh:=vesGetMeshCount(se.obj);
 end else begin      
  rndprg('Loading Base ('+nam+')','',false);
  bt:=getbase(dword(v))^;
  se.nmesh:=bt.nsbs+bt.nsas; 
 end;
 
 setlength(se^.mshv,se.nmesh);
 setlength(se^.mshs,se.nmesh);

 if base then begin 
  for i:=0 to bt.nsbs-1 do begin
   hMesh:=ppointer(dword(bt.sbs)+dword(i*4))^;
   msh:=getmsh(hMesh);
   if(hmesh<>nil)and(msh<>nil)then begin
    se.mshs[i]:=msh;
   end else begin 
    se.mshs[i]:=ldmsh(hMesh);
   end;    
   se.mshv[i]:=MESHVIS_ALWAYS;
  end;  
     
  for i:=0 to bt.nsas-1 do begin
   hMesh:=ppointer(dword(bt.sas)+dword(i*4))^;
   msh:=getmsh(hMesh);
   if(hmesh<>nil)and(msh<>nil)then begin
    se.mshs[bt.nsbs+dword(i)]:=msh;
   end else begin 
    se.mshs[bt.nsbs+dword(i)]:=ldmsh(hMesh);
   end;   
   se.mshv[bt.nsbs+dword(i)]:=MESHVIS_ALWAYS;
  end;   
 end else begin
  for i:=0 to se.nmesh-1 do add_one_vessel_mesh(se,i,(lowercase(cnam)='deltaglider')or(lowercase(cnam)='dg-s'));
  se.nanim:=vesGetAnimPtr(se.obj,@anim);
  if se.nanim<>0 then begin 
   setlength(se.animstate,se.nanim);
   for i:=0 to se.nanim-1 do se.animstate[i]:=anim[i].defstate;
  end;
  se.anim:=anim;
 end;

 //if copy(nam,1,2)='GL' then dbg_lights_for_dg(se); 
 
 i:=-1; 
 except stderr('Graph','Error in prcsmobmsh (i='+stri(i)+')'); end; 
end;    
//############################################################################// 
//Vessels processing - load from Orbiter, update vectors   
//Surface base processing - load from Orbiter, update vectors
procedure proc_smob(scn:poglascene);    
const clnam='                                                                ';
var i,j,c,n,mfd,typ:integer;
smb:poglas_smob;   
ob:ohnd;
vs:pointer;
m:mat;   
tovis:boolean;  
p:array[0..255]of char;
tex:pinteger;
cnam:string;

hudspec:pVCHUDSPEC;
mfdspec:array[0..9]of pVCMFDSPEC;
sHUD:psurfinfo;
sMFD:array[0..9]of psurfinfo;
begin for i:=0 to 255 do p[i]:=#0; i:=0;typ:=0; vs:=nil; try
 //FIXME
 mgxform:=vesGetMGroup_Transform;
 mgxformput:=vesSetMGroup_Transform;

 for i:=0 to length(scn.smobs)-1 do if scn.smobs[i]<>nil then begin  
  c:=0;   
  for j:=0 to oapiGetObjectCount+oapiGetBaseCount(oapiCameraProxyGbody)-1 do begin   
   if j<oapiGetObjectCount then ob:=oapiGetObjectByIndex(j) else ob:=oapiGetBaseByIndex(oapiCameraProxyGbody,j-oapiGetObjectCount); 
   if scn.smobs[i].tp=SMOB_VESSEL then begin 
    if(oapiGetObjectType(ob)<>OBJTP_VESSEL)then continue;    
    vs:=oapiGetVesselInterface(ob);
    if scn.smobs[i].ob=vs then begin c:=1;break;end;
   end; 
   if scn.smobs[i].tp=SMOB_BASE then begin 
    if(oapiGetObjectType(ob)<>OBJTP_SURFBASE)then continue;  
    if oapiGetBasePlanet(ob)<>oapiCameraProxyGbody then continue;
    if scn.smobs[i].ob=pointer(ob) then begin c:=1;break;end;
   end;    
  end; 
  if c=0 then begin    
   ////FIXME: CTD?///visop(1,scn.smobs[i].id,nil);
   dispose(scn.smobs[i]);
   scn.smobs[i]:=nil;
  end;  
 end;
 
 //Vessel and base preprocess 
 for i:=0 to oapiGetObjectCount+oapiGetBaseCount(oapiCameraProxyGbody)-1 do begin
  if i<oapiGetObjectCount then ob:=oapiGetObjectByIndex(i) else ob:=oapiGetBaseByIndex(oapiCameraProxyGbody,i-oapiGetObjectCount);     
  if (oapiGetObjectType(ob)=OBJTP_VESSEL) then begin
   vs:=oapiGetVesselInterface(ob);                   
   typ:=SMOB_VESSEL; 
  end else if(oapiGetObjectType(ob)=OBJTP_SURFBASE)then begin
   if oapiGetBasePlanet(ob)<>oapiCameraProxyGbody then continue;
   vs:=pointer(ob);
   typ:=SMOB_BASE; 
  end else continue;

  tovis:=false;
  c:=get_smob_by_ob(scn,vs);
  if c=-1 then c:=get_free_smob(scn);
  if scn.smobs[c]=nil then begin
   new(scn.smobs[c]);
   scn.smobs[c].ob:=vs;
   scn.smobs[c].id:=ob;   
   scn.smobs[c].tp:=typ; 
   tovis:=true;
  end;

  smb:=scn.smobs[c];
  
  smb.name:=clnam;  
  oapiGetObjectName(smb.id,p,255);
  smb.name:=string(p);

  if typ=SMOB_VESSEL then begin                     
   cnam:=clnam;
   vesGetClassName(smb.ob,p);
   cnam:=string(p);
  end;
  
  oapiGetGlobalPos(smb.id,@smb.pos);     
  oapiGetRotationMatrix(smb.id,@m); 
  smb.rot:=tamat(m); 
  smb.rad:=oapigetsize(smb.id);    
  smb.cpos:=subv(smb.pos,scn.cam.pos);   

  smb.draw:=prcsmobmsh(smb.ob,smb.name,cnam,typ=SMOB_BASE); 

  for j:=0 to smb.draw.nmesh-1 do if smb.draw.mshs[j]<>nil then if smb.draw.mshs[j].siz>smb.rad then smb.rad:=smb.draw.mshs[j].siz;  
  smb.draw.apr:=getob_apr(scn,smb.pos,smb.rad);
  
  if typ=SMOB_VESSEL then begin
   smb.draw.cp:=oapiCameraInternal and (smb.id=oapiGetFocusObject);

   n:=vesGetExhaustCount(smb.ob);
   setlength(smb.draw.exh,n);
   for j:=0 to n-1 do begin 
    smb.draw.exh[j].lvl:=vesGetExhaustLevel(smb.ob,j);
    vesGetExhaustSpec(smb.ob,j,@smb.draw.exh[j].lscale,@smb.draw.exh[j].wscale,@smb.draw.exh[j].pos,@smb.draw.exh[j].dir,@tex);
    if tex=nil then smb.draw.exh[j].tex:=0 else begin
     shud:=txget(tex);
     if shud<>nil then begin
      assert(shud.mag=SURFH_MAG); 
      smb.draw.exh[j].tex:=shud.tex;
     end;
    end;
   end;
           
   if (oapiCockpitMode=COCKPIT_VIRTUAL)and smb.draw.cp then begin
    hudspec:=nil;
    sHUD:=txget(vcsurf(0,0,@hudspec));
    for mfd:=0 to 9 do sMFD[mfd]:=txget(vcsurf(1,mfd,@mfdspec[mfd]));

    if shud<>nil then begin
     assert(shud.mag=SURFH_MAG);
     smb.draw.mshs[hudspec.nmesh].grp[hudspec.ngroup].dif.tx:=shud.tex;
     smb.draw.mshs[hudspec.nmesh].grp[hudspec.ngroup].cole:=tcrgba(255,255,255,255);
     //FIXME: Crutch - HUD additive
     shud.additive:=true;
    end;   
    for mfd:=0 to 9 do if sMFD[mfd]<>nil then begin
     assert(sMFD[mfd].mag=SURFH_MAG);
     smb.draw.mshs[mfdspec[mfd].nmesh].grp[mfdspec[mfd].ngroup].dif.tx:=sMFD[mfd].tex;
    end;   
   end;

   for j:=0 to smb.draw.lights_cnt-1 do if smb.draw.lights[j]<>nil then case smb.draw.lights[j].bndtp of
    1:smb.draw.lights[j].setpwr:=vesGetThrusterGroupLevel(smb.ob,smb.draw.lights[j].bndob);
    2:if smb.draw.anim<>nil then smb.draw.lights[j].setpwr:=smb.draw.anim[smb.draw.lights[j].bndob].state;
    3:if smb.draw.anim<>nil then smb.draw.lights[j].setpwr:=1-smb.draw.anim[smb.draw.lights[j].bndob].state;
    4:if smb.draw.anim<>nil then smb.draw.lights[j].setpwr:=ord(smb.draw.anim[smb.draw.lights[j].bndob].state=1);
    5:if smb.draw.anim<>nil then smb.draw.lights[j].setpwr:=ord(smb.draw.anim[smb.draw.lights[j].bndob].state=0);
   end;
   
   if tovis then visop(0,ob,pointer(c+1));
  end;
 end;
 
 i:=-1;
 except stderr('Graph','Error in proc_smob (i='+stri(i)+')'); end;   
end;    
//############################################################################// 
//Update planet state vectors
procedure procplanets(scn:poglascene);
var i:integer;
m:mat;
begin
 for i:=0 to length(scn.plnt)-1 do begin
  //Pos, rot, air
  oapiGetGlobalPos(scn.plnt[i].obj,@scn.plnt[i].pos);
  oapiGetRotationMatrix(scn.plnt[i].obj,@m); 
  scn.plnt[i].rot:=tamat(m); 
  setatmparam(scn,scn.plnt[i]);  
 end;
end;   
//############################################################################// 
//############################################################################// 
//############################################################################//
// Parstream
procedure addpstrm(scn:poglascene;tp:integer;es:dword;pss:pPARTICLESTREAMSPEC;hVessel:ohnd;lvl:pdouble;ref,dir:pvec);
var i,c:integer;
begin
 c:=-1;
 for i:=0 to length(scn.pss)-1 do if scn.pss[i]=nil then begin c:=i; break; end;
 if c=-1 then begin
  c:=length(scn.pss);
  setlength(scn.pss,c+1);
 end; 
 new(scn.pss[c]);  
 scn.pss[c].pos:=ref;
 scn.pss[c].dir:=dir; 
 scn.pss[c].lv:=lvl;
 scn.pss[c].obj:=hVessel;  
 scn.pss[c].es:=es;                        //w l
 scn.pss[c].ps:=mkparstr(10,10,pss^.tex,tvec(2,8,1));                                                                     
end;   
//############################################################################// 
//Load planet parameters from Orbiter
procedure initplanets(scn:poglascene);
var i,c,n:integer;
d:ohnd;  
p:array[0..255]of char;
tvn:vec;      
begin for i:=0 to 255 do p[i]:=#0; i:=0;c:=0; try
 c:=0;
 for i:=0 to oapiGetObjectCount-1 do if oapiGetObjectType(oapiGetObjectByIndex(i))=OBJTP_PLANET then c:=c+1;

 setlength(scn.plnt,c); 
 n:=0;
 for i:=0 to oapiGetObjectCount-1 do begin
  d:=oapiGetObjectByIndex(i);
  if oapiGetObjectType(d)<>OBJTP_PLANET then continue;  
  new(scn.plnt[n]);        
  fillchar(scn.plnt[n]^,sizeof(scn.plnt[n]^),0);
  new(scn.plnt[n].draw);
  fillchar(scn.plnt[n].draw^,sizeof(scn.plnt[n].draw^),0);

  oapiGetObjectName(d,p,255);
  oapiGetGlobalPos(d,@tvn);                                               
  Rndspl('Loading Planets ('+p+')',1,1,i/(oapiGetObjectCount-1)); 
  
  //Basics
  oglaset_plntbase(scn,scn.plnt[n],string(p),d,tvn,tvec(0,0,0),oapigetsize(d),oapiPlanetHasAtmosphere(d));
  //Haze
  if scn.plnt[n].draw.atm then gethaze(scn.plnt[n].draw.haze,d,scn.plnt[n].name); 
  //Rings
  if pbytebool(oapiGetObjectParam(d,OBJPRM_PLANET_HASRINGS))^ then oglaset_plntring(scn.plnt[n],pdouble(oapiGetObjectParam(d,OBJPRM_PLANET_RINGMINRAD))^,pdouble(oapiGetObjectParam(d,OBJPRM_PLANET_RINGMAXRAD))^);
  //Init state
  updoplanet_grnd(scn,scn.plnt[n]);      
  updoplanet_clds(scn,scn.plnt[n]);
  updoplanet_lgts(scn,scn.plnt[n]);
  
  n:=n+1;
 end;    
 setlength(scn.plnt,n); 
 i:=-1;  
 except stderr('INIT','Error in initplanets (i='+stri(i)+', c='+stri(c)+')'); end;
end;   
//############################################################################//
{$endif}
//############################################################################//
begin             
 texcnt:=0; 
 dhtx:=0;
 orb_texdir:='Textures';
 orb_mshdir:='Meshes';
end.   
//############################################################################// 
