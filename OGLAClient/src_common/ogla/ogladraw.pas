//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA core rendering system
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit ogladraw;
interface
uses tim,asys,maths,math,strval,grph,glgr,dogl,bmp,opengl1x,log,
ogladata,oglashaders,oglacalc,oglaplanet,oglasky,oglaengine,oglasmobs,glpars;
//############################################################################// 
//############################################################################// 
procedure ogla_render_scene(scn:poglascene);   
function  ogla_getpick(scn:poglascene;x,y:integer;ax:boolean=false;md:integer=0;pv:boolean=false):integer; 
//############################################################################// 
implementation           
//############################################################################//  
var o_dt:integer;
//############################################################################// 
//Render planets
procedure planets_render(scn:poglascene;cmvw:boolean;isz:boolean=false;shd:boolean=false);
var i,c,mi:integer;
dp,cdst,fpl,npl,mn:double;
pln:poglas_planet;  
ltp:mquat;
begin i:=0; try 
 if length(scn.plnt)=0 then exit;
 
 mn:=1e100;mi:=0;  
 for i:=0 to length(scn.plnt)-1 do begin
  if modvs(scn.plnt[i].cpos)<mn then begin mi:=i;mn:=modvs(scn.plnt[i].cpos);end;
  scn.plnt[i].draw.nrst:=false;
 end;
 scn.plnt[mi].draw.nrst:=true;

 if isz then begin
  glPushMatrix;

   glGetFloatv(GL_MODELVIEW_MATRIX,@gl_cmmat); 
   
   if(not shd)and((not scn.feat.shadows)or(scn.feat.shres<>5))then begin
    glenable(GL_DEPTH_TEST);
    gldisable(GL_TEXTURE_2D);
    gldisable(GL_BLEND);
    gldisable(GL_LIGHTING); 
    glColorMask(FALSE,FALSE,FALSE,FALSE);  
   end;
   pln:=scn.plnt[mi];
   fpp:=10000000;
   npp:=0.1;
   draw_planet(scn,pln,true,scn.feat.shadows and(scn.feat.shres=5));

   if(not shd)and((not scn.feat.shadows)or(scn.feat.shres<>5))then begin
    glColorMask(TRUE,TRUE,TRUE,TRUE); 
    glenable(GL_TEXTURE_2D);
    glenable(GL_BLEND);
    glenable(GL_LIGHTING); 
    if gl_2_sup then glUseProgram(0);
   end;

  glPopMatrix;
  exit;
 end;

 c:=0; 
 for i:=0 to length(scn.plnt)-1 do begin
  scn.plnt[i].draw.grnd.res:=updoplanet_grnd(scn,scn.plnt[i]);
  scn.plnt[i].draw.clds.res:=updoplanet_clds(scn,scn.plnt[i]);
  scn.plnt[i].draw.lgts.res:=updoplanet_lgts(scn,scn.plnt[i]);
  scn.plnt[i].draw.apr:=getob_apr(scn,scn.plnt[i].pos,scn.plnt[i].rrad); 
  if scn.plnt[i].draw.apr>0.01 then begin 
   oplbuf[c]:=scn.plnt[i];
   opldsbuf[c]:=modvs(scn.plnt[i].cpos);

   c:=c+1;
  end else putpnt(scn.plnt[i].cpos,scn.plnt[i].rot,scn.plnt[i].draw.apr+0.5); 
 end;

 qsort_ptr_dbl(apointer(oplbuf),opldsbuf,0,c-1);

 //glEnable(GL_LIGHTING);
 glMatrixMode(GL_PROJECTION);glPushMatrix;
 glMatrixMode(GL_MODELVIEW); glPushMatrix;
 for i:=c-1 downto 0 do begin  
  glClear(GL_DEPTH_BUFFER_BIT);
  if i<>0 then begin
   if scn.sky<>0 then begin
    //ltp:=tmquat(scn.skycolor[0]/255,scn.skycolor[1]/255,scn.skycolor[2]/255,1);glLightfv(GL_LIGHT0,GL_DIFFUSE,@ltp);
   end;
  end else begin
   ltp:=tmquat(gl_amb.x,gl_amb.y,gl_amb.z,1);glLightfv(GL_LIGHT0,GL_AMBIENT,@ltp);glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@ltp); 
  end;

  pln:=oplbuf[i];
     
  if scn.sky<>0 then if c=1 then begin 
   glMatrixMode(GL_PROJECTION);glPushMatrix;
   glMatrixMode(GL_MODELVIEW); glPushMatrix;
   glMatrixMode(GL_PROJECTION);glLoadIdentity; 
   glOrtho(0,1,1,0,1,-1);
   glMatrixMode(GL_MODELVIEW);glLoadIdentity; 
  
   glBlendFunc(GL_SRC_ALPHA,GL_DST_COLOR); 
   putsqr2D(0,0,1,1,scn.skycolor,gclaz);    
   glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
   
   glPopMatrix;glMatrixMode(GL_PROJECTION); 
   glPopMatrix;glMatrixMode(GL_MODELVIEW);  
  end;
      
  if((pln.draw.apr>PIX_LIM)and(pln.draw.grnd.res>0))or((pln.draw.apr>PIX_LIM)and(pln.draw.grnd.umsh))then begin    
   dp:=abs(smulv(scn.cam.dir,subv(pln.pos,scn.cam.pos)));
   cdst:=modv(subv(pln.pos,scn.cam.pos));
   fpl:=max2(1e3,dp+pln.rrad*1.2);     
   //if pln.draw.atm then npl:=max2(1e0,dp-pln.rrad*1.2)/100
   //else 
   npl:=max2(1e0,(dp/cdst*(cdst-pln.rrad))*0.9/1000);

   if pln.draw.ringex then if (npl<100)and(abs(dp-pln.rrad*1.2)>100)then npl:=100;
   if pln.draw.grnd.umsh then begin npl:=npl/1.1;fpl:=1.1*fpl;end;

   glMatrixMode(GL_PROJECTION);glLoadIdentity;
    if not cmvw then gluPerspective((scn.camapr*2*180/pi)*(ord(scn.feat.projection=1)+1),scn.wid/scn.hei,npl,fpl*1.1)
                else gluPerspective((scn.camapr*2*180/pi)*(ord(scn.feat.projection=1)+1),              1,npl,fpl*1.5);
   glMatrixMode(GL_MODELVIEW); 
   fpp:=fpl*1.1;
   npp:=npl;

   draw_planet(scn,pln);

  end else putpnt(pln.cpos,pln.rot,pln.draw.apr+0.5);
  
  if scn.sky>0.6 then if i=1 then begin
   glMatrixMode(GL_PROJECTION);glPushMatrix;
   glMatrixMode(GL_MODELVIEW); glPushMatrix;
   glMatrixMode(GL_PROJECTION);glLoadIdentity; 
   glOrtho(0,1,1,0,1,-1);
   glMatrixMode(GL_MODELVIEW);glLoadIdentity; 
  
   glBlendFunc(GL_SRC_ALPHA,GL_DST_COLOR); 
   putsqr2D(0,0,1,1,scn.skycolor,gclaz);    
   glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
   
   glPopMatrix;glMatrixMode(GL_PROJECTION); 
   glPopMatrix;glMatrixMode(GL_MODELVIEW);  
  end; 
  
 end;  
 i:=-1;
 glenable(GL_DEPTH_TEST);
 if gl_2_sup then glUseProgram(0);
 glPopMatrix;glMatrixMode(GL_PROJECTION); 
 glPopMatrix;glMatrixMode(GL_MODELVIEW);  
  
 except stderr('Graph','Error in Renderplanets (i='+stri(i)+')'); end;    
end;
//############################################################################//
procedure render_smob_exhaust(ves:poglas_smob;cp:vec);    
var i:integer;
tex:dword;
begin        
 if ves=nil then exit;
 if length(ves.draw.exh)=0 then exit;
 
 for i:=0 to length(ves.draw.exh)-1 do begin   
	 if ves.draw.exh[i].lvl=0 then continue;
  tex:=ves.draw.exh[i].tex;
  if tex=0 then tex:=defexhausttex;
  renderexhaust(ves.draw.exh[i].pos,ves.draw.exh[i].dir,cp,ves.draw.exh[i].lvl,ves.draw.exh[i].lscale,ves.draw.exh[i].wscale,tex);
 end;
end;     
//############################################################################//
//############################################################################//  
procedure set_smobs_lights(scn:poglascene);
var i,k:integer;
l:double; 
lt:pdraw_light_rec;
v,d:vec;      
modmap:tmatrix4f;   
begin
 //Multilight...
 lights_count:=1;
 setlength(lt_pos,lights_limit);
 setlength(lt_diff,lights_limit);
 setlength(lt_dir,lights_limit);
 setlength(lt_sco,lights_limit);
 setlength(lt_quad,lights_limit);
 if scn.feat.multilight then for i:=0 to length(scn.smobs)-1 do if scn.smobs[i]<>nil then if scn.smobs[i].draw<>nil then begin  
  l:=modv(scn.smobs[i].cpos);
  for k:=0 to scn.smobs[i].draw.lights_cnt-1 do if scn.smobs[i].draw.lights[k]<>nil then if(scn.smobs[i].draw.lights[k].ison)and(scn.smobs[i].draw.lights[k].setpwr>eps)and(l<scn.smobs[i].draw.lights[k].rad)then begin
   glPushMatrix;                  
    glTranslatef(scn.smobs[i].cpos.x,scn.smobs[i].cpos.y,scn.smobs[i].cpos.z);  
    x_glrotatef(scn.smobs[i].rot,-1);
    lt:=scn.smobs[i].draw.lights[k];

    if lights_count<8 then begin
     if lt.tp=OGLA_LIGHT_SPOT then put_light_spot(lights_count ,lt.pos,lt.dir,lt.spot,1/lt.setpwr/lt.pwr,0,tdcrgba(0.01,0.01,0.01,0),lt.col,tdcrgba(0,0,0,0));  
     if lt.tp=OGLA_LIGHT_OMNI then put_light_omni(lights_count ,lt.pos,1/lt.setpwr/lt.pwr,0,tdcrgba(0.01,0.01,0.01,0),lt.col,tdcrgba(0,0,0,0));  
    end;
         
    glGetFloatv(GL_MODELVIEW_MATRIX,@modmap);
    v.x:=lt.pos.x*modmap[0][0]+lt.pos.y*modmap[1][0]+lt.pos.z*modmap[2][0]+modmap[3][0];
    v.y:=lt.pos.x*modmap[0][1]+lt.pos.y*modmap[1][1]+lt.pos.z*modmap[2][1]+modmap[3][1];
    v.z:=lt.pos.x*modmap[0][2]+lt.pos.y*modmap[1][2]+lt.pos.z*modmap[2][2]+modmap[3][2];
    
    d.x:=lt.dir.x*modmap[0][0]+lt.dir.y*modmap[1][0]+lt.dir.z*modmap[2][0];
    d.y:=lt.dir.x*modmap[0][1]+lt.dir.y*modmap[1][1]+lt.dir.z*modmap[2][1];
    d.z:=lt.dir.x*modmap[0][2]+lt.dir.y*modmap[1][2]+lt.dir.z*modmap[2][2];
    
    lt_pos[lights_count-1]:=v2m(v);
    lt_diff[lights_count-1]:=tmvec(lt.col[0]/255,lt.col[1]/255,lt.col[2]/255);
    lt_quad[lights_count-1]:=1/lt.setpwr/lt.pwr;
    if lt.tp=OGLA_LIGHT_SPOT then lt_sco[lights_count-1]:=cos(lt.spot/180*pi) else lt_sco[lights_count-1]:=-1;
    lt_dir[lights_count-1]:=v2m(d);
    lights_count:=lights_count +1;
   glPopMatrix;         
   if lights_count-1>=lights_limit then exit;   
   if not gl_shm4 then if lights_count>=8 then exit;   
  end;
 end;
end;
//############################################################################//
procedure smob_pick_drsetup(scn:poglascene;shd,pick:boolean;i,j,k:integer;v:vec); 
var l:double; 
a,b:integer;  
pt:dword;    
modmap,prjmap:tmatrix4f;  
viewport:tvector4i; 
begin
 if(not shd)or pick then if scn.axes_cnt>0 then if(scn.axes[0][0]=i)and(scn.axes[0][1]=j)and(scn.axes[0][2]=k)then begin
  l:=modv(scn.smobs[i].cpos)/2;
       
  putaxis(v,1,l,pick,scn.axes[0][3]);
       
  glGetFloatv(GL_MODELVIEW_MATRIX,@modmap);
  glGetFloatv(GL_PROJECTION_MATRIX,@prjmap);
  glGetIntegerv(GL_VIEWPORT,@viewport);
  scn.axes_pos[0][0]:=glhprojectf(v.x+l,v.y,v.z,@modmap,@prjmap,@viewport); //WTF? stabilises the output.
       
  scn.axes_pos[0][0]:=glhprojectf(v.x+l,v.y  ,v.z  ,@modmap,@prjmap,@viewport);
  scn.axes_pos[0][1]:=glhprojectf(v.x  ,v.y  ,v.z  ,@modmap,@prjmap,@viewport);
  scn.axes_pos[0][2]:=glhprojectf(v.x-l,v.y  ,v.z  ,@modmap,@prjmap,@viewport);
  scn.axes_pos[1][0]:=glhprojectf(v.x  ,v.y+l,v.z  ,@modmap,@prjmap,@viewport);
  scn.axes_pos[1][1]:=glhprojectf(v.x  ,v.y  ,v.z  ,@modmap,@prjmap,@viewport);
  scn.axes_pos[1][2]:=glhprojectf(v.x  ,v.y-l,v.z  ,@modmap,@prjmap,@viewport);
  scn.axes_pos[2][0]:=glhprojectf(v.x  ,v.y  ,v.z+l,@modmap,@prjmap,@viewport);
  scn.axes_pos[2][1]:=glhprojectf(v.x  ,v.y  ,v.z  ,@modmap,@prjmap,@viewport);
  scn.axes_pos[2][2]:=glhprojectf(v.x  ,v.y  ,v.z-l,@modmap,@prjmap,@viewport);
       
  for a:=0 to 2 do for b:=0 to 2 do scn.axes_pos[a][b].y:=scn.hei-scn.axes_pos[a][b].y
 end;
 if pick then begin
  pt:=(i+1)+(j+1)shl 4+(k+1)shl 8;
  if pt=11280  then halt;
  glcolor4f((pt and $FF)/255,((pt and $FF00)shr 8)/255,((pt and $FF0000)shr 16)/255,1);
 end;
end;         
//############################################################################//
function blink_group_render(scn:poglascene;g:ptypmshgrp;i,j,k:integer;for_shadow:boolean):boolean;
var x:integer;    
cl:crgba;
begin
 result:=false;
 if not for_shadow then for x:=0 to scn.axes_cnt-1 do if(scn.axes[x][0]=i)and(scn.axes[x][1]=j)and(scn.axes[x][2]=k)then begin
  cl:=g.col;
  g.col[0]:=round(255*abs(sin(rtdt(o_dt)/100000)));
  g.col[1]:=round(255*abs(sin(pi/2-rtdt(o_dt)/100000)));
  g.col[2]:=0;
  g.col[3]:=255;
  gldisable(GL_LIGHTING);
  putmshgrp(g,zvec,zvec,evec,false,for_shadow);
  glenable(GL_LIGHTING);
  g.col:=cl;
  result:=true;
 end;
end;     
//############################################################################//
procedure smob_shaderpars(scn:poglascene;g:ptypmshgrp;for_shadow:boolean;sh:integer;tan_att:dword;var tan_attp,shmtexp:dword);   
var t:dword;
begin
 if not for_shadow then if gl_2_sup and scn.feat.advanced then if ves_sh[sh].prg<>0 then begin
  if scn.feat.shadows and(scn.feat.shres=5) then shmtexp:=shmtex else shmtexp:=$FFFFFFFF;
  t:=g.dif.tx;if(t=notx)or(t=0)then t:=0 else t:=1;glUniform1f(ves_sh[sh].unis[2],t);
  t:=g.lth.tx;if(t=notx)or(t=0)then t:=0 else t:=1;
       if t=0 then begin glUniform1f(ves_sh[sh].unis[3],0);glUniform1f(ves_sh[sh].unis[16],0);end 
  else if g.lth.uv=0 then begin glUniform1f(ves_sh[sh].unis[3],1);glUniform1f(ves_sh[sh].unis[16],0); end 
  else begin glUniform1f(ves_sh[sh].unis[3],0);glUniform1f(ves_sh[sh].unis[16],1);end;
  t:=g.nml.tx;if(t=notx)or(t=0)then t:=0 else t:=1;glUniform1f(ves_sh[sh].unis[4],t);
  if t<>0 then tan_attp:=tan_att else tan_attp:=$FFFFFFFF;
 end;
end;
//############################################################################//
function smob_sunlight(scn:poglascene;dr:pdraw_rec;i,sh:integer):double;
var ltp:mquat; 
amc:vec;     
l:double;
begin
 //Sunlight in planet shadow
 ltp:=tmquat(dr.lt0.x,dr.lt0.y,dr.lt0.z,dr.lt0.w);
 result:=max3(dr.lt0.x,dr.lt0.y,dr.lt0.z);
 glLightfv(GL_LIGHT0,GL_DIFFUSE,@ltp);
 glLightfv(GL_LIGHT0,GL_SPECULAR,@ltp);  
 ltp:=tmquat(gl_amb.x,gl_amb.y,gl_amb.z,1);glLightfv(GL_LIGHT0,GL_AMBIENT,@ltp);glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@ltp); 
 if scn.smobs[i].near_plnt<>-1 then if gl_2_sup and scn.feat.advanced and(ves_sh[sh].prg<>0)then begin 
  if scn.plnt[scn.smobs[i].near_plnt].draw<>nil then begin
   if scn.plnt[scn.smobs[i].near_plnt].draw.atm then begin
    amc.x:=scn.plnt[scn.smobs[i].near_plnt].draw.atmcolor0[0];
    amc.y:=scn.plnt[scn.smobs[i].near_plnt].draw.atmcolor0[1];
    amc.z:=scn.plnt[scn.smobs[i].near_plnt].draw.atmcolor0[2];
   end else begin
    //Albedo?
    amc:=evec;
   end;
   l:=sqr(scn.smobs[i].pgsiz/modv(subv(scn.smobs[i].pgpos,scn.smobs[i].pos)));
   if l>1 then l:=1;
   amc:=nmulv(subv(evec,nmulv(subv(evec,amc),0.2)),0.5*l); 
   if not scn.feat.planet_light then amc:=zvec;
   ltp:=tmquat(amc.x*dr.lt0.x,amc.y*dr.lt0.y,amc.z*dr.lt0.z,1);glLightfv(GL_LIGHT0,GL_AMBIENT,@ltp);glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@ltp);
  end;
 end;
end;
//############################################################################//
procedure smob_shaderlight_init(scn:poglascene;var sh:integer;var tan_att:dword;var cmmat:tmatrix4f);
var ltp:mquat;  
begin
 if gl_2_sup and scn.feat.advanced and(ves_sh[0].prg<>0)then begin       
  if gl_shm4 then sh:=(lights_count-1) div 10+ord(((lights_count-1) mod 10)<>0);
  if not gl_shm4 then sh:=lights_count-1;
  tan_att:=ves_sh[sh].unis[15];
  glUseProgram(ves_sh[sh].prg);
  glUniform1i(ves_sh[sh].unis[5],3);
  glUniform1i(ves_sh[sh].unis[6],1);
  glUniform1i(ves_sh[sh].unis[7],0);
  glUniform1i(ves_sh[sh].unis[8],2);
   
  if gl_shm4 then begin                
   glUniform3fv(ves_sh[sh].unis[9],lights_count-1,@lt_pos[0]);
   glUniform3fv(ves_sh[sh].unis[12],lights_count-1,@lt_dir[0]);
   glUniform3fv(ves_sh[sh].unis[10],lights_count-1,@lt_diff[0]); 
   glUniform1fv(ves_sh[sh].unis[11],lights_count-1,@lt_sco[0]);
   glUniform1fv(ves_sh[sh].unis[13],lights_count-1,@lt_quad[0]); 
   glUniform1i(ves_sh[sh].unis[14],lights_count-1);
  end;

  if scn.feat.shadows and(scn.feat.shres=5) then glGetFloatv(GL_MODELVIEW_MATRIX,@cmmat); 
 end;
 glEnable(GL_LIGHTING);
 ltp:=tmquat(1,1,1,1);
 glLightfv(GL_LIGHT0,GL_DIFFUSE,@ltp);
 ltp:=tmquat(gl_amb.x,gl_amb.y,gl_amb.z,1);
 glLightfv(GL_LIGHT0,GL_AMBIENT,@ltp);
 glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@ltp);
end;            
//############################################################################//
procedure reset_light; 
var ltp:mquat;  
begin
 glEnable(GL_LIGHTING);
 ltp:=tmquat(1,1,1,1);
 glLightfv(GL_LIGHT0,GL_DIFFUSE,@ltp);
 glLightfv(GL_LIGHT0,GL_SPECULAR,@ltp);
end;
//############################################################################//
//############################################################################//
//Render vessels and bases
procedure smobs_render(scn:poglascene;for_shadow,pick,ax:boolean);
var i,j,p,k,sh:integer;
tan_att,tan_attp,shmtexp:dword;
cmmat:tmatrix4f;
light:double;
g:ptypmshgrp;
dr:pdraw_rec;
begin i:=0; try   
 tan_att:=$FFFFFFFF;
 sh:=0;
 light:=1; 
 
 if not for_shadow then smob_shaderlight_init(scn,sh,tan_att,cmmat);  
 
 for p:=-1 to 1 do for i:={$ifdef reverse_smobs}length(scn.smobs)-1 downto 0{$else}0 to length(scn.smobs)-1{$endif} do if scn.smobs[i]<>nil then if scn.smobs[i].draw<>nil then begin
  if(p=-1)and(scn.smobs[i].tp=SMOB_VESSEL)then continue;
  if(p>-1)and(scn.smobs[i].tp<>SMOB_VESSEL)then continue;
  dr:=scn.smobs[i].draw;
        
  //Sunlight in planet shadow
  if not pick then light:=smob_sunlight(scn,dr,i,sh);
        
  //Draw mesh
  if dr.drmsh then begin
   if not SphereInFrustum(scn.smobs[i].cpos.x,scn.smobs[i].cpos.y,scn.smobs[i].cpos.z,scn.smobs[i].rad) then continue;
   glPushMatrix;
   glTranslatef(scn.smobs[i].cpos.x,scn.smobs[i].cpos.y,scn.smobs[i].cpos.z);
   x_glrotatef(scn.smobs[i].rot,-1);
    
   if dr.nmesh>0 then for j:=0 to dr.nmesh-1 do if dr.mshs[j]<>nil then if dr.mshs[j].used then begin       
    if scn.smobs[i].tp=SMOB_VESSEL then if not ves_thatisvis(scn,i,j,p) then continue;
    //if dr.mshs[j].need_fin then grglfintex(dr.mshs[j]);  ///WTF? Texture loading on demand
       
    glPushMatrix;
    glTranslatef(dr.mshs[j].off.x,dr.mshs[j].off.y,dr.mshs[j].off.z);
     
    if not for_shadow then glenable(GL_TEXTURE_2D);   
    for k:=0 to dr.mshs[j].grc-1 do begin
     g:=@dr.mshs[j].grp[k];                
     if(g.flags and 2)<>0 then continue;
     
     smob_pick_drsetup(scn,for_shadow,pick,i,j,k,g.center);
     smob_shaderpars(scn,g,for_shadow,sh,tan_att,tan_attp,shmtexp);
     
     if(not ax)and(not blink_group_render(scn,g,i,j,k,for_shadow))then begin       
      if gl_2_sup and scn.feat.advanced then begin
       glUniform4f(ves_sh[sh].unis[1],g.col[0]/255,g.col[1]/255,g.col[2]/255,(g.col[3]-dr.semit)/255); 
       glUniform1f(ves_sh[sh].unis[17],light); 
       if(dr.semit=0)or(not pick)then if(dr.lt0.w<>0)or(not for_shadow)then putfullmshgrp(g,for_shadow,dr.semit,cmmat,shmapmat,shmtexp,tan_attp,light>0.1);
      end else putmshgrp(g,zvec,zvec,evec,false,for_shadow,notx-1,false,$FFFFFFFF,dr.semit);
     end;
     
    end;    
    glPopMatrix;
    
   end;    
   glPopMatrix;
  end else if((scn.smobs[i].tp=SMOB_VESSEL)and(dr.apr>0.05))or((scn.smobs[i].tp=SMOB_BASE)and(dr.apr>1))then putpnt(scn.smobs[i].cpos,scn.smobs[i].rot,dr.apr,for_shadow);
  if not for_shadow then reset_light;
 end else if getob_apr(scn,scn.smobs[i].pos,scn.smobs[i].rad)>0.5 then putpnt(scn.smobs[i].cpos,scn.smobs[i].rot,getob_apr(scn,scn.smobs[i].pos,scn.smobs[i].rad),for_shadow);
          
 glgr_ltoff;
 i:=-1;
 if gl_2_sup then glUseProgram(0);
 
 except stderr('Graph','Error in smobs_render (i='+stri(i)+')'); end;  
end;
//############################################################################//
//Render parstreams
procedure pars_render(scn:poglascene);
var i,j:integer;
cp:vec; 
begin i:=0; try 
 {
 for i:=0 to length(scn.pss)-1 do if scn.pss[i]<>nil then begin  
  for j:=0 to length(scn.smobs)-1 do if scn.smobs[j]<>nil then if scn.smobs[j].draw<>nil then if scn.smobs[j].id=scn.pss[i].obj then begin
   glPushMatrix;                  
    glTranslatef(scn.smobs[j].cpos.x,scn.smobs[j].cpos.y,scn.smobs[j].cpos.z); 
    x_glrotatef(scn.smobs[j].rot,-1);

    cp:=scn.smobs[j].cpos;
    vrotx(cp,scn.smobs[j].rot.x);   
    vroty(cp,scn.smobs[j].rot.y); 
    vrotz(cp,scn.smobs[j].rot.z);     
    //cp:=addv(cp,scn.pss[i].pos^);
    
    scn.pss[i].ps.lv:=scn.pss[i].lv^;
    renderpars(scn.pss[i].ps,cp);  
   glPopMatrix; 
  end;
 end;
 i:=0;
 }
 for j:=0 to length(scn.smobs)-1 do if scn.smobs[j]<>nil then if scn.smobs[j].draw<>nil then begin
  glPushMatrix;                  
   glTranslatef(scn.smobs[j].cpos.x,scn.smobs[j].cpos.y,scn.smobs[j].cpos.z);  
   x_glrotatef(scn.smobs[j].rot,-1);

   cp:=scn.smobs[j].cpos;
   vrotx(cp,scn.smobs[j].rot.x);   
   vroty(cp,scn.smobs[j].rot.y); 
   vrotz(cp,scn.smobs[j].rot.z);  
      
   render_smob_exhaust(scn.smobs[j],cp);

  glPopMatrix; 
 end;
 
 except stderr('Graph','Error in renderpars (i='+stri(i)+')'); end;  
end;
//############################################################################//
//Render vessel shadows 5    
procedure shadows_mapped(scn:poglascene;step:integer);
var av:vec;
i,mi:integer;
mx,d,l,f,r:double;
begin
 if scn.feat.shres<>5 then exit;   
 if not gl_14_fbo_sup then exit;
 if length(scn.smobs)=0 then exit;

 mi:=0;
 mx:=1e100; 
 for i:=0 to length(scn.smobs)-1 do if scn.smobs[i]<>nil then if scn.smobs[i].ob<>nil then begin
  d:=modv(scn.smobs[i].cpos);
  if d<mx then begin mx:=d;mi:=i;end;
 end;
 l:=modv(scn.cam.pos)/1e8;
 f:=2*arctan(2*scn.smobs[mi].rad/l)*1.1;
 r:=10*scn.smobs[mi].rad*1.1;
   
 glMatrixMode(GL_PROJECTION);glLoadIdentity;
  gluPerspective(f*180/pi,1,l-r,l+r);
 glMatrixMode(GL_MODELVIEW);glLoadIdentity;           
 glViewport(0,0,scn.feat.shmres-1,scn.feat.shmres-1);
        
 glClearColor(0,0,0,1);
        
 //Scene set for camera   
 glClear(GL_DEPTH_BUFFER_BIT);
    
 glenable(GL_DEPTH_TEST); 
 
 gldisable(GL_TEXTURE_2D);
 gldisable(GL_BLEND);
 gldisable(GL_LIGHTING); 
  
 glShadeModel(GL_FLAT);
 glColorMask(FALSE,FALSE,FALSE,FALSE);  
 
 glPolygonOffset(2,2);
 glEnable(GL_POLYGON_OFFSET_FILL);
 
 glEnable(GL_CULL_FACE);//orbitergl uses that.
 glCullFace(GL_BACK);
 glFrontFace(GL_CW); 
  
 //Left-handed coordinates
 glScalef(1,1,-1);
 glColor4f(0.5,0,0,1);    
     
 glPushMatrix;  
  av:=tamat(getrtmat1(nmulv(scn.cam.pos,-1)));             
  av:=tvec(-av.y,av.z,0);
      
  glRotatef(av.x*180/pi,1,0,0);
  glRotatef(av.y*180/pi,0,1,0);

  glTranslatef(-scn.smobs[mi].cpos.x,-scn.smobs[mi].cpos.y,-scn.smobs[mi].cpos.z);  
  gltranslatef(scn.cam.pos.x/1e8,scn.cam.pos.y/1e8,scn.cam.pos.z/1e8);  

  //Matrix aquisition
  glBindTexture(GL_TEXTURE_2D,shmtex);
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity; 
  glTranslatef(0.5,0.5,0.5);
  glScalef(0.5,0.5,0.5);
  glGetFloatv(GL_PROJECTION_MATRIX,@shmapmat);glMultMatrixf(@shmapmat);       
  glGetFloatv(GL_MODELVIEW_MATRIX ,@shmapmat);glMultMatrixf(@shmapmat);    
  glGetFloatv(GL_TEXTURE_MATRIX,@shmapmat); 
  glLoadIdentity;  
  glMatrixMode(GL_MODELVIEW); 
  glBindTexture(GL_TEXTURE_2D,0); 
  
  extract_frustum;
  //Planet Z layer
  planets_render(scn,scn.tx<>0,true,true);
  smobs_render(scn,true,false,false); 

 glPopMatrix; 
                              
 glShadeModel(GL_SMOOTH);
 glColorMask(TRUE,TRUE,TRUE,TRUE); 
 glDisable(GL_POLYGON_OFFSET_FILL);   
 glColor4f(0,0,0,1);  
     
 glFlush;
 
 glBindTexture(GL_TEXTURE_2D,shmtex);
 glCopyTexSubImage2D(GL_TEXTURE_2D,0,0,0,0,0,scn.feat.shmres,scn.feat.shmres);
 glBindTexture(GL_TEXTURE_2D,0);  
end;
//############################################################################//
//Render vessel shadows 2-4
procedure shadows_stencil(scn:poglascene;x,y:integer;var shi,shj:aointeger);
var i:integer;
lp:vec;   
begin  
 if(scn.feat.shres=2)or(scn.feat.shres=3)then begin
  glClearColor(1,1,1,1);
 
  //Scene set for camera   
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
     
  glMatrixMode(GL_PROJECTION); glLoadIdentity;
  gluPerspective((scn.camapr*2*180/pi)*(ord(scn.feat.projection=1)+1),scn.sys.gwin.wid/scn.sys.gwin.hei,0.01,10000000);
  glMatrixMode(GL_MODELVIEW);           
  glViewport(0,0,x,y);
 
  glenable(GL_DEPTH_TEST); 
  gldisable(GL_TEXTURE_2D);
  gldisable(GL_BLEND);
  gldisable(GL_LIGHTING);    
  
  glEnable(GL_CULL_FACE);//orbitergl uses that.
  glCullFace(GL_BACK);
  glFrontFace(GL_CW); 
  //Left-handed coordinates
  glScalef(1,1,-1);
               
  glColorMask(FALSE,FALSE,FALSE,FALSE);

  glPushMatrix;  
   x_glrotatef(scn.cam.rot,1);

   extract_frustum;
   //Planet Z layer
   planets_render(scn,scn.tx<>0,true,true);
   smobs_render(scn,true,false,false);
 end;
           
  putmshvshset(0);
  for i:=0 to length(shi)-1 do if scn.smobs[shi[i]]<>nil then begin
  glPushMatrix;                       
   glTranslatef(scn.smobs[shi[i]].cpos.x,scn.smobs[shi[i]].cpos.y,scn.smobs[shi[i]].cpos.z);       
   x_glrotatef(scn.smobs[shi[i]].rot,-1); 
   glTranslatef(scn.smobs[shi[i]].draw.mshs[shj[i]].off.x,scn.smobs[shi[i]].draw.mshs[shj[i]].off.y,scn.smobs[shi[i]].draw.mshs[shj[i]].off.z);   
    
   if (modv(scn.smobs[shi[i]].draw.lt0)<>0) then begin
    lp:=nmulv(scn.smobs[shi[i]].pos,-1);
    vrotx(lp,scn.smobs[shi[i]].rot.x); 
    vroty(lp,scn.smobs[shi[i]].rot.y);     
    vrotz(lp,scn.smobs[shi[i]].rot.z);
    
     
    if scn.smobs[shi[i]].draw.mshs[shj[i]]<>nil then putmshvsh(scn.smobs[shi[i]].draw.mshs[shj[i]],zvec,zvec,evec,lp,0);
   end;  
   
  glPopMatrix;
  end;
  for i:=0 to length(shi)-1 do if scn.smobs[shi[i]]<>nil then begin
  glPushMatrix;                       
   glTranslatef(scn.smobs[shi[i]].cpos.x,scn.smobs[shi[i]].cpos.y,scn.smobs[shi[i]].cpos.z); 
   x_glrotatef(scn.smobs[shi[i]].rot,-1);  
   glTranslatef(scn.smobs[shi[i]].draw.mshs[shj[i]].off.x,scn.smobs[shi[i]].draw.mshs[shj[i]].off.y,scn.smobs[shi[i]].draw.mshs[shj[i]].off.z); 
    
   if (modv(scn.smobs[shi[i]].draw.lt0)<>0) then begin
    lp:=nmulv(scn.smobs[shi[i]].pos,-1);
    vrotx(lp,scn.smobs[shi[i]].rot.x); 
    vroty(lp,scn.smobs[shi[i]].rot.y);     
    vrotz(lp,scn.smobs[shi[i]].rot.z);  
     
    if scn.smobs[shi[i]].draw.mshs[shj[i]]<>nil then putmshvsh(scn.smobs[shi[i]].draw.mshs[shj[i]],zvec,zvec,evec,lp,1);
   end;  
  glPopMatrix;
  end;
  
  if length(shi)<>0 then putmshvshset(1); 
  if length(shi)=0 then putmshvshset(2);    
 glPopMatrix;  
    
 if(scn.feat.shres=2)or(scn.feat.shres=3)then begin      
  glFlush;
       
  glBindTexture(GL_TEXTURE_2D,shscr);
  glCopyTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,0,0,1024,1024,0);    
 end;      
end;   
//############################################################################// 
procedure render_shadows(scn:poglascene;pnt:integer);
var i:integer;
begin      
 case pnt of
  1:begin
   scn.feat.drwm:=scn.feat.drwm and $FE;
   if scn.feat.shadows then case scn.feat.shres of
    2,3:begin
     calcveshi(scn,scn.shi,scn.shj);
     if scn.feat.shres=2 then i:=4 else i:=2;
     shadows_stencil(scn,scn.wid div i,scn.hei div i,scn.shi,scn.shj);
    end;   
    5:begin scn.feat.drwm:=scn.feat.drwm or 1;shadows_mapped(scn,0);end;
   end;
  end;
  2:if scn.feat.shadows then if(scn.feat.shres=4)then begin
   calcveshi(scn,scn.shi,scn.shj);
   shadows_stencil(scn,scn.wid div 4,scn.hei div 4,scn.shi,scn.shj);
  end; 
  3:if scn.feat.shadows then if(scn.feat.shres>=2)and(scn.feat.shres<=3)then begin
   glgr_set2d(scn.sys.gwin);     
   i:=0;            
   if scn.feat.shres=2 then i:=4;if scn.feat.shres=3 then i:=2;    
   glBlendFunc(GL_ZERO,GL_SRC_COLOR);          
   puttx2Dsh(shscr,0,0,scn.sys.gwin.wid,scn.sys.gwin.hei,0,0,scn.sys.gwin.wid div i/1024,scn.sys.gwin.hei div i/1024,true,tcrgba(255,255,255,round(255))); 
   glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
  end;
 end;
end;
//############################################################################//
//############################################################################//
//Render whole scene      
procedure ogla_render_scene(scn:poglascene);
var v:mquat;
x:vec;
s:integer;
begin try 
 for s:=0 to ord(scn.feat.stereo) do begin  
  if scn.feat.stereo then begin              
   x:=nmulv(nrvec(perpv(scn.cam.dir,scn.cam.up)),scn.feat.angl_dist/2);//0.03);
   case s of
    0:scn.cam.pos:=addv(scn.cam.pos,x);
    1:scn.cam.pos:=addv(scn.cam.pos,nmulv(x,-2));
   end;
   ogla_reupdatevals(scn);
  end;
  //Render setup
  render_shadows(scn,1);
  render_setre(scn,s);  

  glgr_ltoff;
  glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
  v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);
   
  lights_count:=1;
  if scn.feat.camera_light then begin
   put_light(zvec,1,0,1);     
   gldisable(GL_LIGHT0+1);
  end;
  glPushMatrix;      
   x_glrotatef(scn.cam.rot,1); 
                  
   extract_frustum; 
   //Background layer
   if scn.drsky then if scn.sky<0.9 then sky_render(scn,s); //F2  

   set_smobs_lights(scn);  
   //Planet layer  
   planets_render(scn,scn.tx<>0); 
  
   //Foreground layer
   glClear(GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);  
  
   //Planet Z layer
   if scn.feat.shres>1 then planets_render(scn,scn.tx<>0,true,false);
                           
   if scn.feat.camera_light then glenable(GL_LIGHT0+1);
   smobs_render(scn,false,false,false);  
   if scn.feat.camera_light then gldisable(GL_LIGHT0+1);
 
   pars_render(scn);
   render_shadows(scn,2);
  glPopMatrix;
  render_shadows(scn,3);        
  glPolygonmode(GL_FRONT,GL_FILL);
  glPolygonmode(GL_BACK,GL_FILL);  
 
  //Postproduction        
  if gl_14_fbo_sup then begin
   glFlush;
   glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);
   glgr_set2d(scn.sys.gwin);
   if scn.feat.postplane then puttx2d(scn.screen_tx,0,0,scn.wid,scn.hei,true,gclwhite);
  end;
     
  //Into texture
  if scn.tx<>0 then begin
   glFlush;
   
   glBindTexture(GL_TEXTURE_2D,scn.tx);
   glCopyTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,0,0,scn.feat.cmtres,scn.feat.cmtres,0);
  end;   
  glBindTexture(GL_TEXTURE_2D,0);
 end;
         
 except stderr('Graph','Error in Renderscn'); end; 
end; 
//############################################################################//
//############################################################################//
//Render whole scene, picking mode      
function ogla_getpick(scn:poglascene;x,y:integer;ax:boolean=false;md:integer=0;pv:boolean=false):integer;
var v:array[0..2]of byte;
pt:dword;
n:integer;
begin n:=0;result:=0; try    
 glColorMask(true,true,true,true);
 glClearColor(0,0,0,1);  
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 
 //Scene set for main     
 glgr_set3d(scn.sys.gwin,(scn.camapr*2*180/pi)*(ord(scn.feat.projection=1)+1),0.1,100000); 
 glViewport(0,0,scn.wid,scn.hei);
       
 glenable(GL_DEPTH_TEST); 
 glBindTexture(GL_TEXTURE_2D,0);  
 gldisable(GL_TEXTURE_2D);
 gldisable(GL_BLEND);
 gldisable(GL_LIGHTING);       
 gldisable(GL_COLOR_MATERIAL);
 glPointSize(1);
 glEnable(GL_CULL_FACE);//orbitergl uses that.
 glCullFace(GL_BACK);
 glFrontFace(GL_CW); 
 if gl_2_sup then glUseProgram(0);
      
 glPushMatrix;  
  glScalef(1,1,-1);
  x_glrotatef(scn.cam.rot,1);
  //Foreground layer
  extract_frustum; 
  if md<3 then smobs_render(scn,true,true,ax)  
  else do_sky_render(scn,true);
 glPopMatrix; 

 glFlush;   
 glenable(GL_TEXTURE_2D);
 glenable(GL_BLEND);
 glenable(GL_LIGHTING);
 glenable(GL_COLOR_MATERIAL);                     
 glBindTexture(GL_TEXTURE_2D,0);
 
 glReadPixels(x,scn.hei-y,1,1,GL_RGB,GL_UNSIGNED_BYTE,@v[0]);   
 pt:=v[0]+v[1] shl 8+v[2] shl 16;

 if md<2 then begin
  if md=0 then begin
   n:=0;         
   if scn.axes_cnt=0 then scn.axes_cnt:=1;
  end;
  if md=1 then begin
   n:=scn.axes_cnt;    
   scn.axes_cnt:=scn.axes_cnt+1;
  end;
        
  if n>=length(scn.axes) then setlength(scn.axes,n*2+1);
 
  if ax then scn.axes[n][3]:=0;      
  if(not ax)and(pt<>0)then if(v[0]<254)and(v[1]<254)and(v[2]<254)then begin 
   scn.axes[n][0]:=pt and $0F-1;
   scn.axes[n][1]:=(pt and $F0)shr 4-1;
   scn.axes[n][2]:=(pt and $FFFF00)shr 8-1;
  end;
  if ax then begin
   if(v[0]=255)and(v[1]=0)and(v[2]=0)then scn.axes[n][3]:=1;
   if(v[0]=0)and(v[1]=255)and(v[2]=0)then scn.axes[n][3]:=2;
   if(v[0]=0)and(v[1]=0)and(v[2]=255)then scn.axes[n][3]:=3;
   if(v[0]=254)and(v[1]=0)and(v[2]=0)then scn.axes[n][3]:=4;
   if(v[0]=0)and(v[1]=254)and(v[2]=0)then scn.axes[n][3]:=5;
   if(v[0]=0)and(v[1]=0)and(v[2]=254)then scn.axes[n][3]:=6;
  end;  
  if md=0 then if not ax then if not pv then if scn.axes[n][3]=0 then scn.axes_cnt:=1;
 end else if md=2 then begin 
  for n:=0 to scn.axes_cnt-1 do if(pt<>0)then if(dword(scn.axes[n][0])=pt and $0F-1)and(dword(scn.axes[n][1])=(pt and $F0)shr 4-1)and(dword(scn.axes[n][2])=(pt and $FFFF00)shr 8-1)then begin 
   scn.axes[n][0]:=-1;
   scn.axes[n][1]:=-1;
   scn.axes[n][2]:=-1;
  end;
 end;
 result:=pt;
 
 
 except stderr('Graph','Error in getpick'); end; 
end; 
//############################################################################//
begin
 stdt(o_dt);
end.
//############################################################################//

