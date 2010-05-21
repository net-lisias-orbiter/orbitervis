//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA SDK
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglcsdk;
interface
uses sysutils,asys,maths,grph,grplib,ogladata,oglcvar,glras_surface,glgr;      
//############################################################################//  
const
OGLC_VCSHADOWS=1;
OGLC_READ_FLAGS=$FFFFFFFF;

OGLA_TX_NORMAL_SPECULAR=1;
OGLA_TX_EMISSION=2;
//############################################################################//  
function oglcSetFlags(s:integer;flags:dword):dword; stdcall;    
function oglcAddLight(s:integer;typ:integer;pos,dir,col:vec;spot,rad,pwr:double):pdraw_light_rec; stdcall;
procedure oglcBindLightThruster(s:integer;lt:pdraw_light_rec;th:dword); stdcall;
procedure oglcBindLightAnim(s:integer;lt:pdraw_light_rec;dir:integer;an:dword); stdcall;
procedure oglcLightRemove(s:integer;lt:pdraw_light_rec); stdcall;  
procedure oglcBindTexture(s:integer;typ,mesh,group:integer;tex:pinteger); stdcall;     
procedure oglcBindExtMesh(s:integer;mesh:integer;nm:pchar); stdcall;  
//############################################################################// 
implementation
//############################################################################// 
function oglcSetFlags(s:integer;flags:dword):dword; stdcall;
var ves:poglas_smob;   
begin  
 s:=s-1;
 result:=0;
 if initstr<>initstrs then exit;  
 if(s<0)or(s>length(scene.smobs))then exit;
 ves:=scene.smobs[s];
 if ves.draw=nil then exit;
    
 result:=OGLC_VCSHADOWS*ord(ves.draw.vc_shadows);
 if flags=OGLC_READ_FLAGS then exit;
 ves.draw.vc_shadows:=(flags and OGLC_VCSHADOWS)<>0;
end;
//############################################################################// 
function oglcAddLight(s:integer;typ:integer;pos,dir,col:vec;spot,rad,pwr:double):pdraw_light_rec; stdcall;
var ves:poglas_smob;  
c:integer; 
begin      
 s:=s-1;
 result:=nil;
 if initstr<>initstrs then exit;  
 if(s<0)or(s>length(scene.smobs))then exit;
 ves:=scene.smobs[s];
 if ves.draw=nil then exit;

 c:=ves.draw.lights_cnt;
 setlength(ves.draw.lights,c+1);
 new(ves.draw.lights[c]);
 result:=ves.draw.lights[c];
 ves.draw.lights_cnt:=ves.draw.lights_cnt+1;
 
 result.ison:=true;
 result.tp:=typ;
 result.col[0]:=round(col.x*255);
 result.col[1]:=round(col.y*255);
 result.col[2]:=round(col.z*255);
 result.col[3]:=255;
 result.spot:=spot;
 result.rad:=rad;
 result.pwr:=pwr;
 result.setpwr:=1;
 result.pos:=pos;
 result.dir:=dir; 
 result.bndtp:=0; 
end;
//############################################################################// 
procedure oglcBindLightThruster(s:integer;lt:pdraw_light_rec;th:dword); stdcall;
var ves:poglas_smob;   
begin     
 s:=s-1;
 if initstr<>initstrs then exit;  
 if(s<0)or(s>length(scene.smobs))then exit;
 ves:=scene.smobs[s];
 if ves.draw=nil then exit;  
 if lt=nil then exit;
                     
 lt.setpwr:=0; 
 lt.bndtp:=1; 
 lt.bndob:=th; 
end;
//############################################################################// 
procedure oglcBindLightAnim(s:integer;lt:pdraw_light_rec;dir:integer;an:dword); stdcall;
var ves:poglas_smob;   
begin     
 s:=s-1;
 if initstr<>initstrs then exit;  
 if(s<0)or(s>length(scene.smobs))then exit;
 ves:=scene.smobs[s];
 if ves.draw=nil then exit;  
 if lt=nil then exit;
                       
 lt.setpwr:=0; 
 lt.bndtp:=2+dir; 
 lt.bndob:=an; 
end;
//############################################################################// 
procedure oglcLightRemove(s:integer;lt:pdraw_light_rec); stdcall;
var ves:poglas_smob;  
i,j:integer; 
begin   
 s:=s-1;
 if initstr<>initstrs then exit;  
 if(s<0)or(s>length(scene.smobs))then exit;
 ves:=scene.smobs[s];
 if ves.draw=nil then exit;
 if lt=nil then exit;

 for i:=0 to ves.draw.lights_cnt-1 do if ves.draw.lights[i]=lt then begin
  for j:=i to ves.draw.lights_cnt-2 do ves.draw.lights[j]:=ves.draw.lights[j+1];
  setlength(ves.draw.lights,ves.draw.lights_cnt-1);
  ves.draw.lights_cnt:=ves.draw.lights_cnt-1;
  break;
 end;
 dispose(lt);
end;  
//############################################################################// 
procedure oglcBindTexture(s:integer;typ,mesh,group:integer;tex:pinteger); stdcall;  
var ves:poglas_smob; 
tx:psurfinfo;
begin     
 s:=s-1;
 if initstr<>initstrs then exit;  
 if(s<0)or(s>length(scene.smobs))then exit;
 ves:=scene.smobs[s];
 if ves.draw=nil then exit;  
            
 tx:=txget(tex);
 if tx<>nil then assert(tx.mag=SURFH_MAG); 

 if typ=OGLA_TX_NORMAL_SPECULAR then if tx<>nil then ves.draw.mshs[mesh].grp[group].nml.tx:=tx.tex;
 if typ=OGLA_TX_EMISSION then if tx<>nil then ves.draw.mshs[mesh].grp[group].lth.tx:=tx.tex;
end;
//############################################################################// 
procedure oglcBindExtMesh(s:integer;mesh:integer;nm:pchar); stdcall;  
var ves:poglas_smob; 
emsh:typmsh;
fn:string;
i,j:integer;
begin     
 s:=s-1;
 if initstr<>initstrs then exit;  
 if(s<0)or(s>length(scene.smobs))then exit;
 ves:=scene.smobs[s];
 if ves.draw=nil then exit;  

 fn:='meshes\'+nm+'.msh';
 if not fileexists(fn)then exit;

 if loadmsh(@emsh,fn,'textures/')=1 then begin
  glgr_fintex(@emsh,false);
  for i:=0 to ves.draw.mshs[mesh].grc-1 do begin
   ves.draw.mshs[mesh].grp[i].nml:=emsh.grp[i].nml;
   ves.draw.mshs[mesh].grp[i].lth:=emsh.grp[i].lth;
   for j:=0 to length(ves.draw.mshs[mesh].grp[i].pnts)-1 do ves.draw.mshs[mesh].grp[i].pnts[j].tx2:=emsh.grp[i].pnts[j].tx2;
  end;
 end; 
end;
//############################################################################//
begin
end. 
//############################################################################//
