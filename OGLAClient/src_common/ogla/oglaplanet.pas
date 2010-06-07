//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA graphics one
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglaplanet;
interface
uses math,asys,grph,maths,strval,opengl1x,glgr,log,raleygpu,raleydata,vecmat,dpringdraw{$ifdef orulex},dynplntutil{$endif},oglashaders,ogladata; 
//############################################################################// 
procedure draw_planet(scn:poglascene;pln:poglas_planet;isz:boolean=false;ishz:boolean=false);
//############################################################################// 
implementation    
//############################################################################//
procedure raytraced_haze_render(scn:poglascene;camrpos,pgp:vec;rad:double); 
var h:double;
position,c:vec;
view,proj,iview:matq;
iviewf,iproj:mmatq;
begin
 position:=nmulv(camrpos,-rg/rad); 

 view[0]:=tquat(scn.cam.rtmat[0].x,scn.cam.rtmat[0].y,-scn.cam.rtmat[0].z,0);
 view[1]:=tquat(scn.cam.rtmat[1].x,scn.cam.rtmat[1].y,-scn.cam.rtmat[1].z,0);
 view[2]:=tquat(scn.cam.rtmat[2].x,scn.cam.rtmat[2].y,-scn.cam.rtmat[2].z,0);
 view[3]:=tquat(0,0,0,1);
         
 view:=mulm(inv_matq(view),translate3d(nmulv(position,-1)));


 h:=modv(position)-Rg;
 proj:=proj_matrix_transp(0.1*h,1e5*h,scn.camapr*(ord(scn.feat.projection=1)+1)*2*180/pi,scrx/scry);
              
 iproj:=matq2mmatq(inv_matq(proj));
 iview:=inv_matq(view);
 c:=lvmat(iview,tvec(0,0,0));

 iviewf[0]:=tmquat(iview[0].x,iview[0].y,iview[0].z,iview[0].w);
 iviewf[1]:=tmquat(iview[1].x,iview[1].y,iview[1].z,iview[1].w);
 iviewf[2]:=tmquat(iview[2].x,iview[2].y,iview[2].z,iview[2].w);
 iviewf[3]:=tmquat(iview[3].x,iview[3].y,iview[3].z,iview[3].w);

 pgp:=nrvec(nmulv(pgp,-1));    
 camrpos:=nmulv(camrpos,rg/rad);     
 
 glUseProgram(scatter_sh.prg); 
 glUniform3f(scatter_sh.unis[4],camrpos.x,camrpos.y,camrpos.z);
 glUniform3f(scatter_sh.unis[5],pgp.x,pgp.y,pgp.z);
 glUniformMatrix4fv(scatter_sh.unis[6],1,true,@iproj);
 glUniformMatrix4fv(scatter_sh.unis[7],1,true,@iviewf);        
 glUniform1f(scatter_sh.unis[8],0.4);
 glActiveTexturearb(GL_TEXTURE0_ARB+transmittanceUnit);glBindTexture(GL_TEXTURE_2D,transmittanceTexture);
 glActiveTexturearb(GL_TEXTURE0_ARB+irradianceUnit);glBindTexture(GL_TEXTURE_2D,irradianceTexture);
 glActiveTexturearb(GL_TEXTURE0_ARB+inscatterUnit);glBindTexture(GL_TEXTURE_3D,inscatterTexture);   
 glActiveTexturearb(GL_TEXTURE0_ARB+4);glBindTexture(GL_TEXTURE_2D,haztxz);   

 glUniform1i(scatter_sh.unis[0],reflectanceUnit);
 glUniform1i(scatter_sh.unis[1],transmittanceUnit);
 glUniform1i(scatter_sh.unis[2],irradianceUnit);
 glUniform1i(scatter_sh.unis[3],inscatterUnit);  
 glUniform1i(glGetUniformLocation(scatter_sh.prg,'depth'),4);  
                
 gldisable(GL_DEPTH_TEST);  
 glDepthMask(false);
 glMatrixMode(GL_PROJECTION);glPushMatrix;glLoadIdentity;
 gluPerspective((scn.camapr*2*180/pi)*(ord(scn.feat.projection=1)+1),scrx/scry,npp,fpp);
 glMatrixMode(GL_MODELVIEW);glPushMatrix;glLoadIdentity;  
 glBegin(GL_TRIANGLE_STRIP);
  glVertex2f(-1,-1);
  glVertex2f(-1, 1);
  glVertex2f( 1,-1);
  glVertex2f( 1, 1);
 glEnd;          
 glPopMatrix;glMatrixMode(GL_PROJECTION);
 glPopMatrix;glMatrixMode(GL_MODELVIEW);    
 glDepthMask(true);    
 glenable(GL_DEPTH_TEST);   
 glUseProgram(0);
 glActiveTexturearb(GL_TEXTURE0_ARB);
end; 
//############################################################################// 
// Haze drawing
procedure simple_haze_render(scn:poglascene;hazmsh:ptypmsh;h:poplhazetyp;dual:boolean;camrpos,pgp,cgp:vec);
var i,j,k,n:integer; 
cpos,pos:vec;
csun,alpha,colofs,h1,h2,r1,r2,intr,intg,intb,cdist,id,visrad,sinv,dr,dh,dens,colsh:double;
maxred,maxgreen,maxblue,minred,mingreen,minblue:double;
col:crgbad;

a,b,c,xh,yh,zh:vec;
tmat:mat;         
begin try   
 pos:=camrpos;
 camrpos:=nmulv(camrpos,-1);
 cdist:=modv(camrpos)/h.rad;    
  
 if scn.can_rayleigh then begin
  if dual then raytraced_haze_render(scn,camrpos,pgp,h.rad);
  exit;
 end;

 alpha:=h.dens0*min2(1,(cdist-1)*200);
 if (not dual)then alpha:=1-alpha;
 if (alpha<=0)then exit;   //nothing to do

 cpos:=tvec(0,cdist,0);
 id:=1/max2(cdist,1.001);  //inverse camera distance; 1.001: hack to avoid horizon to creep too close
 visrad:=arccos(id);       //aperture of visibility sector
 sinv:=sin(visrad);
 h1:=id; 
 h2:=h1+(h.hralt*id);
 r1:=sinv; 
 r2:=(1+h.hralt)*r1;

 if(h.hshift<>0)then if((cdist-1)>(h.cloudalt/h.rad))then begin
  dr:=h.hshift*sinv;
  dh:=h.hshift*id;
  h1:=h1+dh; h2:=h2+dh;
  r1:=r1+dr; r2:=r2+dr;
 end;

 dens:=max2(1,1.4-0.3/h.hralt*(cdist-1)); //saturate haze colour at low altitudes
 if dual then dens:=dens*(0.5+0.5/cdist); //scale down intensity at large distances

 if dual then colofs:=0.4 else colofs:=0.3;
  
 a:=pgp;b:=subv(cgp,a);
 yh:=nrvec(b);c:=perpv(a,b);
 xh:=nrvec(perpv(yh,c));
 if smulv(xh,a)>0 then xh:=nmulv(xh,-1);
 zh:=nrvec(vmulv(xh,yh));

 tmat[0].x:=xh.x;tmat[1].x:=xh.y;tmat[2].x:=xh.z;
 tmat[0].y:=yh.x;tmat[1].y:=yh.y;tmat[2].y:=yh.z;
 tmat[0].z:=zh.x;tmat[1].z:=zh.y;tmat[2].z:=zh.z;
  
  
 j:=0;i:=0;n:=ord(dual);   
 for k:=0 to HORIZON_HAZE_NSEG-1 do begin 
  hazmsh.grp[n].pnts[j].pos:=v2m(lvmat(tmat,tvec(r1*hCosP[i],h1,r1*hSinP[i])));

  csun:=smulv(m2v(hazmsh.grp[n].pnts[j].pos),nrvec(nmulv(a,-1)));
  colsh:=0.5*(smulv(nrvec(a),nrvec(b))+1);
       
  //compose a colourful sunset
  maxred  :=colofs-0.18*colsh; minred  :=maxred  -0.4;
  maxgreen:=colofs-0.1*colsh;  mingreen:=maxgreen-0.4;
  maxblue :=colofs;            minblue :=maxblue -0.4;
  if(csun>maxred  )then intr:=1 else if(csun<minred  )then intr:=0 else intr:=(csun-minred  )*2.5;
  if(csun>maxgreen)then intg:=1 else if(csun<mingreen)then intg:=0 else intg:=(csun-mingreen)*2.5;
  if(csun>maxblue )then intb:=1 else if(csun<minblue )then intb:=0 else intb:=(csun-minblue )*2.5;
  col:=tcrgbad(intr*min(1,dens*h.basecol[0]),intg*min(1,dens*h.basecol[1]),intb*min(1,dens*h.basecol[2]),alpha);
  
  hazmsh.grp[n].pnts[j].cold:=col;
  j:=j+1;           
  hazmsh.grp[n].pnts[j].pos:=v2m(lvmat(tmat,tvec(r2*hCosP[i],h2,r2*hSinP[i])));
  hazmsh.grp[n].pnts[j].cold:=col;    
  j:=j+1;
  i:=i+1;      
 end;    
  
 if dual then begin
  h2:=h1;
  r2:=h.hscale*r1*r1; 
                  
  for i:=0 to HORIZON_HAZE_NSEG*2-1 do hazmsh.grp[2].pnts[i]:=hazmsh.grp[n].pnts[i];
  j:=1; k:=0;   
  for i:=0 to HORIZON_HAZE_NSEG-1 do begin
   hazmsh.grp[2].pnts[j].pos:=v2m(lvmat(tmat,tvec(r2*hCosP[k],h2,r2*hSinP[k])));   
   
   k:=k+1;
   j:=j+2;   
  end; 
 end;
 
 glPushMatrix; 
  gldisable(gl_lighting);
  gldisable(GL_DEPTH_TEST);     
  glTranslatef(pos.x,pos.y,pos.z);  
  glscalef(h.rad,h.rad,h.rad); 

  glBindTexture(GL_TEXTURE_2D,h.tx);

  glEnableclientstate(GL_VERTEX_ARRAY);
  glEnableclientstate(GL_COLOR_ARRAY);
  glEnableclientstate(GL_TEXTURE_COORD_ARRAY);            
  glcolor4f(hazmsh.grp[n].col[0]/255,hazmsh.grp[n].col[1]/255,hazmsh.grp[n].col[2]/255,hazmsh.grp[n].col[3]/255);
                         
  gldisable(GL_CULL_FACE);
  glColorPointer(4,GL_FLOAT,SizeOf(pntyp),@hazmsh.grp[n].pnts[0].cold[0]);
  glVertexPointer(3,GL_FLOAT,SizeOf(pntyp),@hazmsh.grp[n].pnts[0].pos.x);
  glTexCoordPointer(2,GL_FLOAT,SizeOf(pntyp),@hazmsh.grp[n].pnts[0].tx.x);
  glDrawElements(GL_triangle_strip,2*HORIZON_HAZE_NSEG+2,GL_UNSIGNED_INT,@hazmsh.grp[n].trng[0]);
  udc:=udc+2*HORIZON_HAZE_NSEG+2;  
 
               
  if dual then begin            
   glColorPointer(4,GL_FLOAT,SizeOf(pntyp),@hazmsh.grp[2].pnts[0].cold[0]);
   glVertexPointer(3,GL_FLOAT,SizeOf(pntyp),@hazmsh.grp[2].pnts[0].pos.x);
   glTexCoordPointer(2,GL_FLOAT,SizeOf(pntyp),@hazmsh.grp[2].pnts[0].tx.x);
   glDrawElements(GL_triangle_strip,2*HORIZON_HAZE_NSEG+2,GL_UNSIGNED_INT,@hazmsh.grp[2].trng[0]);    
   udc:=udc+2*HORIZON_HAZE_NSEG+2;
  end;              
  glEnable(GL_CULL_FACE); 
                         
  gldisableclientstate(GL_VERTEX_ARRAY);
  gldisableclientstate(GL_COLOR_ARRAY);
  gldisableclientstate(GL_TEXTURE_COORD_ARRAY); 
         
  glenable(gl_lighting);    
  glenable(GL_DEPTH_TEST); 
 glPopMatrix;  
 
 except stderr('ORBGL','Error in hazerender'); end; 
end;        
//############################################################################// 
//############################################################################// 
// Planet drawing    
procedure draw_rings(scn:poglascene;pln:poglas_planet;tp:integer);
var i:integer;
rot,camrpos:vec;
cpt:vec;
begin i:=0; try  
 if not pln.draw.ringmsh.used then exit;
 rot:=nmulv(pln.rot,-180/pi);
   
 cpt:=subv(scn.cam.pos,pln.pos);   
 vrotx(cpt,-rot.x/180*pi);   
 vroty(cpt,-rot.y/180*pi); 
 vrotz(cpt,-rot.z/180*pi);   
 camrpos:=pln.cpos;
 vrotx(camrpos,-rot.x/180*pi);   
 vroty(camrpos,-rot.y/180*pi); 
 vrotz(camrpos,-rot.z/180*pi); 
     
 if scn.feat.realrings then begin
  if gl_2_sup and scn.feat.advanced then if ring_sh.prg<>0 then begin         
   glUseProgram(ring_sh.prg); 
   
   glActiveTextureARB(GL_TEXTURE0_ARB);glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D,noitx);
   glActiveTextureARB(GL_TEXTURE1_ARB);glEnable(GL_TEXTURE_2D);
               
   glUniform1i(ring_sh.unis[0],0);//tex
   glUniform1i(ring_sh.unis[1],1);//tex1
   glUniform1f(ring_sh.unis[2],1e6);//sdist
   glUniform1f(ring_sh.unis[3],5e5);//fdist
   glUniform3f(ring_sh.unis[4],camrpos.x,camrpos.y,camrpos.z);//pov
  end;
 end;
    
 camrpos:=nmulv(camrpos,-1/pln.rad);  
 if scn.feat.realrings then begin
  if abs(cpt.y)<5e5 then pln.draw.ringmsh.grp[0].col[3]:=round(255*((abs(cpt.y)-1e5)/4e5)) else pln.draw.ringmsh.grp[0].col[3]:=255;
  if abs(cpt.y)<1e5 then pln.draw.ringmsh.grp[0].col[3]:=0;
 end else pln.draw.ringmsh.grp[0].col[3]:=255;
       
 gldisable(GL_CULL_FACE);
 glPushMatrix; 
  glTranslatef(pln.cpos.x,pln.cpos.y,pln.cpos.z);    
  glrotatef(rot.x,1,0,0);   
  glrotatef(rot.y,0,1,0);   
  glrotatef(rot.z,0,0,1);  
  putmsh(@pln.draw.ringmsh,zvec,zvec,tvec(pln.rad,1-ord(camrpos.y<0)*pln.rad,pln.rad)); 
 glPopMatrix;  
 glenable(GL_CULL_FACE);

 if gl_2_sup and scn.feat.advanced then begin 
  glUseProgram(0);
  glActiveTextureARB(GL_TEXTURE1_ARB);glDisable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D,0);
  glActiveTextureARB(GL_TEXTURE0_ARB);glEnable(GL_TEXTURE_2D);
 end;    

 if scn.feat.realrings then begin
  glDisable(GL_TEXTURE_2D);
  glPushMatrix; 
   glTranslatef(pln.cpos.x,pln.cpos.y,pln.cpos.z);    
   glrotatef(rot.x,1,0,0);   
   glrotatef(rot.y,0,1,0);   
   glrotatef(rot.z,0,0,1);  
   if abs(cpt.y)<2e6 then drdpring(pln.draw.rng,cpt,2,0);
   if abs(cpt.y)<5e5 then drdpring(pln.draw.rng,cpt,1,1-(abs(cpt.y)-2e5)/3e5);                                               
  glPopMatrix; 
  glEnable(GL_TEXTURE_2D); 
 end;
       
 i:=-1;
 except stderr('ORBGL','Error in pldrawrings (i='+stri(i)+')'); end; 
end; 
//############################################################################// 
procedure ground_lowtill(scn:poglascene;pln:poglas_planet;tl:popmeshrec;rotoff,altoff:double;typ:integer;is_sh,isz,ishz:boolean);
const cldscol:crgba=(0,0,0,255);
var m:ptypmshgrp;
lv,i,flg:integer;
crp:vec;
ee,rad,r,scl1:double; 
d,srp:vec;    
v:mquat;
mixedspec,lights,spec:boolean;   
begin i:=0; try  
 lv:=tl.res;
 if lv>tl.curld then lv:=tl.curld;     
 if lv=0 then if typ<>0 then begin
  glEnable(GL_CULL_FACE);//orbitergl uses that.
  glCullFace(GL_BACK);
  glFrontFace(GL_CW);   
  glenable(GL_DEPTH_TEST);
  exit;
 end;
 mixedspec:=false;lights:=false;
 
 rad:=pln.rad+altoff;  
 r:=modv(pln.cpos)-rad;
 if typ=1 then begin
  {   
  if gl_2_sup and scn.feat.advanced then if cldsh<>0 then begin  
   glUseProgram(cldsh);
   glUniform1i(cldsh_drwm,scn.feat.drwm);
   glActiveTextureARB(GL_TEXTURE0_ARB);glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D,noitx);
   glActiveTextureARB(GL_TEXTURE1_ARB);glEnable(GL_TEXTURE_2D);
  
   glUniform1i(cldsh_tex,0);
   glUniform1i(cldsh_tex1,1);
   glUniform1f(cldsh_sdist,1e6);
   glUniform1f(cldsh_fdist,100e3);
   glUniform1f(cldsh_dst,r);
  end;                                  
  }       
  r:=r/20e3;
  if r<0 then r:=0;
  if r>1 then r:=1;

  if not scn.feat.advanced then begin
   if rad<modv(pln.cpos) then begin glFrontFace(GL_CW);gldisable(GL_DEPTH_TEST);end else begin glFrontFace(GL_CCW);glenable(GL_DEPTH_TEST);end;
  end;
 end;

 if tl.umsh then begin
  glPushMatrix; 
   glTranslatef(pln.cpos.x,pln.cpos.y,pln.cpos.z);  
   glrotatef(-pln.rot.x*180/pi,1,0,0);   
   glrotatef(-pln.rot.y*180/pi,0,1,0);   
   glrotatef(-pln.rot.z*180/pi,0,0,1);   
   putmsh(@tl.lv0msh,zvec,zvec,tvec(pln.rad,pln.rad,pln.rad));
  glPopMatrix; 
  exit;
 end; 
 if lv=0 then exit;

 if typ=0 then begin
  v:=tmquat(1,1,1,1);
  glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@v.x);
  v:=tmquat(0,0,0,0);
  glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);
  glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);
  glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
  glcolor4f(1,1,1,1);   
 end;
            
 for i:=0 to tl.sml_tiles[lv].cnt-1 do begin 
  scl1:=tl.sml_tiles[lv].til[i].scl1;
  crp:=pln.lcamrpos;        
  vroty(crp,-tl.sml_tiles[lv].til[i].yoff/180*pi);  
  vroty(crp,-(rotoff+tl.rot));  
  crp.y:=crp.y*scl1;
  crp.z:=crp.z*scl1;

  ee:=line2sph(crp,tl.sml_tiles[lv].til[i].med,tvec(0,0,0),1,d);
  if (ee>0)and((1-modv(d))>sqr(tl.sml_tiles[lv].til[i].rad))and(modv(subv(crp,d))<modv(subv(crp,tl.sml_tiles[lv].til[i].med))) then continue;

  m:=tl.sml_tiles[lv].til[i].msh;  
  if m=nil then continue;
  m.dif.tx:=tl.sml_tiles[lv].til[i].tx;   
  m.col:=gclwhite;   
  if m.dif.tx=notx then continue;
  
  if typ=2 then begin
   srp:=pln.lstarpos;     
   vroty(srp,-tl.sml_tiles[lv].til[i].yoff/180*pi);  
   vroty(srp,-tl.rot);

   flg:=tl.tiles[tl.sml_tiles[lv].til[i].id].flag;
   mixedspec:=((flg and 3)=3);
   r:=smulv(nrvec(srp),nrvec(tl.sml_tiles[lv].til[i].med));
   lights:=((flg and 4)<>0)and(r<0)and(lv>=6);
   if r<0 then begin
    r:=-10*r;
    if r>1 then r:=1;
   end else r:=0;
  end;
       
  glPushMatrix; 
   glTranslatef(pln.cpos.x,pln.cpos.y,pln.cpos.z);    
   glrotatef(-pln.rot.x*180/pi,1,0,0);   
   glrotatef(-pln.rot.y*180/pi,0,1,0);   
   glrotatef(-pln.rot.z*180/pi,0,0,1);  
   glrotatef(tl.sml_tiles[lv].til[i].yoff,0,1,0);     
   glrotatef((rotoff+tl.rot)*180/pi,0,1,0);  

   if typ=0 then begin
    spec:=false;
    if i<length(pln.draw.lgts.tiles) then begin
     flg:=pln.draw.lgts.tiles[tl.sml_tiles[lv].til[i].id].flag;
     if((flg and 3)=2)then spec:=true;
    end;

    if spec then begin
     glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,20);
     v:=tmquat(1,1,1,1);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);  
    end;
    
    putmshgrp(m,tvec(pln.rad,pln.rad*scl1,pln.rad*scl1),notx-1,true); 
           
    if spec then begin
     glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
     v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);  
    end;
   end;
   if typ=1 then begin             
    if is_sh then begin
     glFrontFace(GL_CW);gldisable(GL_DEPTH_TEST);
     m.col:=cldscol;
     m.col[3]:=round(255*r);
     putmshgrp(m ,zvec,zvec,tvec(pln.rad,pln.rad*scl1,pln.rad*scl1),false);
    end else begin
     if scn.feat.advanced then begin if rad<modv(pln.cpos) then begin glFrontFace(GL_CW);gldisable(GL_DEPTH_TEST);end else begin glFrontFace(GL_CCW);glenable(GL_DEPTH_TEST);end;end;    
     //FIXME: WTF? Z buffer prob.
     //glenable(GL_DEPTH_TEST);    
     putmshgrp(m,zvec,zvec,tvec(rad,rad*tl.sml_tiles[lv].til[i].scl1,rad*tl.sml_tiles[lv].til[i].scl1),false);
    end; 
   end;
   if typ=2 then begin
    if mixedspec then begin          
     glBlendFunc(GL_ONE_MINUS_SRC_ALPHA,GL_ONE); 
     v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@v.x);
     v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);
     glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,20);
     v:=tmquat(1,1,1,1);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);
     putmshgrp(m,zvec,zvec,tvec(rad,rad*tl.sml_tiles[lv].til[i].scl1,rad*tl.sml_tiles[lv].til[i].scl1),false,false,notx-1,true);
    end;
    if lights then begin        
     glBlendFunc(GL_SRC_ALPHA,GL_ONE); 
     v:=tmquat(r,r,r,r);glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@v.x);
     v:=tmquat(r,r,r,r);glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);
     glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
     v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);
     putmshgrp(m,zvec,zvec,tvec(rad,rad*tl.sml_tiles[lv].til[i].scl1,rad*tl.sml_tiles[lv].til[i].scl1),false,false,notx-1,true);
    end;
   end;
  glPopMatrix; 
 end;  
 
 if gl_2_sup and scn.feat.advanced then begin
  glUseProgram(0); 
  glActiveTextureARB(GL_TEXTURE1_ARB);glDisable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D,0);
  glActiveTextureARB(GL_TEXTURE0_ARB);glEnable(GL_TEXTURE_2D);
 end;

 v:=tmquat(1,1,1,1);glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@v.x);
 v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);
 glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
 v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);  
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
 
 glFrontFace(GL_CW); 
 glenable(GL_DEPTH_TEST); 
 
 i:=-1;
 except stderr('ORBGL','Error in pldraw_lowtill (i='+stri(i)+')'); end; 
end;   
//############################################################################// 
procedure ground_oru(scn:poglascene;pln:poglas_planet;isz,ishz:boolean); 
var k:integer;
plnsh_istx2,plnsh_subtex,plnsh_smap,pr:integer;
hfo,alt,cufo:single;
haz:boolean;   
begin try  
 plnsh_istx2:=-1;   
 plnsh_subtex:=-1; 
 plnsh_smap:=-1;   
 pr:=0;  
         
 hfo:=1/(20000/10);
 alt:=modv(pln.cpos)-pln.rad;
 cufo:=exp((-hfo*alt)*ln(2));
 haz:=scn.feat.advatm and(not scn.can_rayleigh) and pln.draw.atm and(cufo>0.000001);
 if gl_shm4 then k:=((lights_count-1) div 10+ord(((lights_count-1) mod 10)<>0))+5*ord(haz) 
            else k:=lights_count-1+8*ord(haz);   
             
 if (not isz)or ishz then if gl_2_sup and scn.feat.advanced then if pln_sh[0].prg<>0 then begin 
  if gl_2_sup then begin
   glUseProgram(pln_sh[k].prg);  
   pr:=pln_sh[k].prg;
   glUniform1i(pln_sh[k].unis[2],ord(ishz));
   glUniform1i(pln_sh[k].unis[3],0);
   plnsh_istx2:=pln_sh[k].unis[3];
   plnsh_subtex:=pln_sh[k].unis[0];
   plnsh_smap:=pln_sh[k].unis[1];    
  end;
         
  if gl_shm4 then begin
   glUniform3fv(pln_sh[k].unis[10],lights_count-1,@lt_pos[0]);
   glUniform3fv(pln_sh[k].unis[13],lights_count-1,@lt_dir[0]);
   glUniform3fv(pln_sh[k].unis[11],lights_count-1,@lt_diff[0]); 
   glUniform1fv(pln_sh[k].unis[12],lights_count-1,@lt_sco[0]);
   glUniform1fv(pln_sh[k].unis[14],lights_count-1,@lt_quad[0]); 
   glUniform1i(pln_sh[k].unis[15],lights_count-1);
  end;
       
  if haz then begin  
   glUniform1f(pln_sh[k].unis[4],pln.rad);
   glUniform1f(pln_sh[k].unis[5],alt);
   glUniform1f(pln_sh[k].unis[6],hfo);            
   glUniform4f(pln_sh[k].unis[7],scn.skycolor_grnd[0]/255,scn.skycolor_grnd[1]/255,scn.skycolor_grnd[2]/255,255);
   glUniform1f(pln_sh[k].unis[8],1.0/10000.0);
   glUniform1f(pln_sh[k].unis[9],cufo);
  end;  
 end;   
 
 if gl_2_sup and scn.feat.advanced then if haz then if haz_sh.prg<>0 then begin
 {  
  glUseProgram(haz_sh.prg);  
  glUniform1f(haz_sh.unis[1],pln.rad);
  glUniform1f(haz_sh.unis[2],alt);
  glUniform1f(haz_sh.unis[3],hfo);            
  glUniform4f(haz_sh.unis[4],scn.skycolor_grnd[0]/255,scn.skycolor_grnd[1]/255,scn.skycolor_grnd[2]/255,255);
  glUniform1f(haz_sh.unis[5],1.0/10000.0);
  glUniform1f(haz_sh.unis[6],cufo);
  }           
  glUseProgram(0);  
  simple_haze_render(scn,@pln.draw.hazmsh,pln.draw.haze,true,pln.cpos,subv(pln.pos,pln.starlightpos),subv(scn.cam.pos,pln.starlightpos));  
  glUseProgram(pr);  
  pln.draw.was_haze:=true;
 end;
          
 glPushMatrix; 
  glcolor4f(1,1,1,1); 
  glrotatef(-pln.rot.x*180/pi,1,0,0);
  glrotatef(-pln.rot.y*180/pi,0,1,0);
  glrotatef(-pln.rot.z*180/pi,0,0,1);
  {$ifdef orulex}   
  drdynplnt(pln.draw.dynpl,pln.lcampos,pln.lcamdir,tvec(0,0,0),0,plnsh_istx2*ord(scn.feat.advanced)-ord(not scn.feat.advanced),plnsh_subtex,isz,ishz,plnsh_smap,shmtex,@shmapmat);
  udc:=udc+dword(pln.draw.dynpl.drpolycount);       
  {$endif} 
 glPopMatrix;   
 
 except stderr('ORBGL','Error in pldraw_oru'); end; 
end;
//############################################################################// 
procedure draw_planet(scn:poglascene;pln:poglas_planet;isz:boolean=false;ishz:boolean=false);
var oru_unavl,oru_predone:boolean; 
begin try
 if not isz then if pln.draw.atm then simple_haze_render(scn,@pln.draw.hazmsh,pln.draw.haze,false,pln.cpos,subv(pln.pos,pln.starlightpos),subv(scn.cam.pos,pln.starlightpos));   
      
 pln.draw.was_haze:=false;
 oru_unavl:=true;
 oru_predone:=false; 
 {$ifdef orulex} 
 if pln.draw.dynpl<>nil then begin
  oru_unavl:=(modv(pln.lcampos)-pln.rad>pln.draw.dynpl.altitude_limit)or(not pln.draw.dynpl.used)or(not pln.draw.dynpl.lded)or(not scn.feat.orulex)or(not pln.draw.nrst);
  oru_predone:=pln.draw.dynpl.predone;
 end;  
 if(not oru_unavl)and(not oru_predone)then drdynplnt_tes(pln.draw.dynpl,pln.lcampos,pln.lcamdir,tvec(0,0,0),0);
 {$endif}
        
 //FIXME: sequencing for haze broken.
 //Draw ground tiles or draw Orulex                                
 if(not isz)or ishz then if gl_2_sup and scn.feat.advanced then glUseProgram(0);     
 if oru_unavl or(not oru_predone)then ground_lowtill(scn,pln,@pln.draw.grnd,0,0,0,false,isz,ishz)     
                                 else ground_oru(scn,pln,isz,ishz);       
 if(not isz)or ishz then if gl_2_sup and scn.feat.advanced then glUseProgram(0);      
         
 if (not isz) or ishz then begin
  if oru_unavl or(not oru_predone)then ground_lowtill(scn,pln,@pln.draw.lgts,0,0,2,false,isz,ishz);
         
  if pln.draw.atm and scn.can_rayleigh then begin
   glBindTexture(GL_TEXTURE_2D,haztxz);
   glCopyTexSubImage2D(GL_TEXTURE_2D,0,0,0,0,0,scrx,scry);
   glBindTexture(GL_TEXTURE_2D,0);  
  end;
 
  if scn.feat.clouds then if pln.draw.atm then begin
   if scn.feat.cloudshadows then ground_lowtill(scn,pln,@pln.draw.clds,pln.draw.cloudrot,0,1,true,isz,ishz);
                                 ground_lowtill(scn,pln,@pln.draw.clds,pln.draw.cloudrot,pln.draw.haze.cloudalt,1,false,isz,ishz);
  end; 
  if not pln.draw.was_haze then if pln.draw.atm then simple_haze_render(scn,@pln.draw.hazmsh,pln.draw.haze,true,pln.cpos,subv(pln.pos,pln.starlightpos),subv(scn.cam.pos,pln.starlightpos));
  if pln.draw.ringex then draw_rings(scn,pln,0);
 end; 
 
 except stderr('ORBGL','Error in draw_planet'); end; 
end;
//############################################################################// 
//############################################################################// 
begin
end.
//############################################################################//

    

