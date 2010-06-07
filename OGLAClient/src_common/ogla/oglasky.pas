//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA core rendering system
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglasky;
interface
uses math,asys,grph,maths,strval,glgr,opengl1x,log,ogladata,oglaengine,oglacalc;
//############################################################################//    
procedure do_sky_render(scn:poglascene;pick:boolean=false);
procedure sky_render(scn:poglascene;chn:integer);  
//############################################################################// 
implementation   
//############################################################################// 
//Render the star(s)
procedure star_render(scn:poglascene);
var vr,vc,gp:vec; 
i,j:integer;
s,apr:double;
star:poglas_star;   
ltp:mquat;
begin try    
 //if gl_2_sup and scn.feat.advanced then if starsh<>0 then begin glUseProgram(starsh);glUniform1i(starsh_drwm,scn.feat.drwm);end;  
 if gl_2_sup then glUseProgram(0); 
 for i:=0 to length(scn.star)-1 do begin
  star:=scn.star[i];
  gp:=star.pos;
  s:=star.rad;  
  star.msh.grp[0].col:=star.col;
  
  vc:=subv(gp,scn.cam.pos);
  vr:=nmulv(tamat(v2vrotmat(nrvec(vc),tvec(0,0,1))),-1); 
  apr:=getob_apr(scn,gp,s);

  if apr>=0.01 then begin  
   gldisable(GL_LIGHTING);
   gldisable(GL_DEPTH_TEST); 
   glPushMatrix;
    glTranslatef(vc.x,vc.y,vc.z);  

    glrotatef(-vr.x*180/pi,1,0,0);   
    glrotatef(-vr.y*180/pi,0,1,0);  

    putmshgrp(@star.msh.grp[0],zvec,zvec,tvec(s,s,s),false);
    s:=s*(modv(vc)/star.rad)/80;
    star.msh.grp[1].col:=star.col;
    if apr<0.1 then star.msh.grp[1].col[3]:=round(255*(apr/0.1)) else star.msh.grp[1].col[3]:=255;
    putmshgrp(@star.msh.grp[1],zvec,zvec,tvec(s,s,s),false);
   glPopMatrix;     
   glenable(GL_LIGHTING);    
   glenable(GL_DEPTH_TEST); 
  end else putpnt(vc,vr,apr); 
 end;
 if gl_2_sup then glUseProgram(0); 

 
 //Sunlight from nearest star
 if length(scn.star)<>0 then begin
  s:=1e100;j:=0;
  for i:=0 to length(scn.star)-1 do if modv(subv(scn.star[i].pos,scn.cam.pos))<s then begin
   s:=modv(subv(scn.star[i].pos,scn.cam.pos));
   j:=i;
  end; 
  //putlt(-scn.cam.pos.x,-scn.cam.pos.y,-scn.cam.pos.z,1,1); 
  put_light(subv(scn.star[j].pos,scn.cam.pos),1,0,0);  
  if scn.feat.starlight_colored then begin
   ltp:=tmquat(scn.star[j].col[0]/255,scn.star[j].col[1]/255,scn.star[j].col[2]/255,1);glLightfv(GL_LIGHT0,GL_DIFFUSE,@ltp);
  end;
 end; 
      
 except stderr('Graph','Error in Renderstar'); end;  
end; 
//############################################################################// 
//Render nebulas 
procedure do_sky_render(scn:poglascene;pick:boolean=false);
var vr,gp,a,b,c,d:vec; 
i,k:integer;
s:double;
neb:poglas_nebula;
ctx:dword;  
cox,six,coy,siy:extended;

function rv(tx,ty:double):vec;
begin
 result.x:=tx*coy+gp.x;
 result.y:=ty*cox+tx*siy*six+gp.y;
 result.z:=ty*six-tx*siy*cox+gp.z;
end;

begin i:=0;k:=0;try   
 if not pick then begin 
  gldisable(GL_LIGHTING);
  gldisable(GL_DEPTH_TEST);  
  glEnable(GL_TEXTURE_2D);
  k:=2;  
  ctx:=0;
  if scn.sky<0.6 then for i:=0 to scn.nebcnt-1 do if scn.nebs[i]<>nil then begin
   neb:=scn.nebs[i]; 
   gp:=neb.gps;
   s:=neb.rad/2;  
   vr:=nmulv(tamat(v2vrotmat(nrvec(gp),tvec(0,0,1))),-1); 

   glColor4f(neb.col[0]/255,neb.col[1]/255,neb.col[2]/255,neb.col[3]/255); 
               
   sincos(-vr.x,six,cox);
   sincos(-vr.y,siy,coy);
   a:=rv(-s,+s);
   b:=rv(+s,+s);
   c:=rv(+s,-s);
   d:=rv(-s,-s);
   
   if ctx<>neb.tx then glBindTexture(GL_TEXTURE_2D,neb.tx); 
   ctx:=neb.tx;       
   glBegin(GL_QUADS);  
    glTexCoord2f(0,1);glVertex3f(a.x,a.y,a.z); 
    glTexCoord2f(1,1);glVertex3f(b.x,b.y,b.z);   
    glTexCoord2f(1,0);glVertex3f(c.x,c.y,c.z);  
    glTexCoord2f(0,0);glVertex3f(d.x,d.y,d.z);  
   glEnd;   
  end; 
 end;
 k:=3;i:=999;   
   
 if not pick then glenable(GL_LIGHTING);    
 if not pick then glenable(GL_DEPTH_TEST);  
 
 //Sky and stars    
 if scn.sky<0.6 then if scn.stars<>nil then begin
  if pick then glpointsize(8) else glpointsize(1);           
  gldisable(GL_LIGHTING);
  gldisable(GL_DEPTH_TEST); 
  gldisable(GL_TEXTURE_2D);   
  glEnableclientstate(GL_VERTEX_ARRAY); 
  glEnableclientstate(GL_COLOR_ARRAY);     
  gldisableclientstate(GL_TEXTURE_COORD_ARRAY);  
  gldisableclientstate(GL_NORMAL_ARRAY);  
         
  k:=0;      
  for i:=0 to length(scn.stars^)-1 do if scn.stars^[i]<>nil then if scn.stars^[i].cnt>12 then begin
   assert(scn.stars^[i].mag=$AAEE6699);
   if pick and (not scn.stars^[i].pick)then continue;
   if scn.stars^[i].rad<>0 then if not SphereInFrustum(scn.stars^[i].cgps.x,scn.stars^[i].cgps.y,scn.stars^[i].cgps.z,scn.stars^[i].rad) then continue;
   if pick then glColorPointer(4,GL_FLOAT,SizeOf(crgbad),@scn.stars^[i].pcol[0]) 
           else glColorPointer(4,GL_FLOAT,SizeOf(crgbad),@scn.stars^[i].col[0]);
   glVertexPointer(3,GL_FLOAT,SizeOf(mvec),@scn.stars^[i].gps[0]);
   glDrawElements(GL_points,scn.stars^[i].cnt,GL_UNSIGNED_SHORT,@scn.stars^[i].idx[0]);   
  end;  
  k:=1;i:=999;      
                          
  gldisableclientstate(GL_VERTEX_ARRAY);
  gldisableclientstate(GL_COLOR_ARRAY); 
  glEnable(GL_TEXTURE_2D); 
  glenable(GL_DEPTH_TEST); 
  glEnable(GL_LIGHTING);
 end;
  
 except stderr('Graph','Error in do_sky_render, i='+stri(i)+', k='+stri(k)+', length(scn.stars^)='+stri(length(scn.stars^))); end;     
end;
//############################################################################// 
procedure sky_render_qset(scn:poglascene;n:integer);
begin
 glFlush;
 if gl_14_fbo_sup then begin
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,scn.fxsky_fbo);
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,scn.fxsky_tx[n],0);
      
  if glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)<>GL_FRAMEBUFFER_COMPLETE_EXT then begin 
   glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,scn.screen_fbo);  
   exit;
  end;
 end;
        
 glClearColor(0,0,0,1);  
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
 if n<>6 then begin                                               
  glViewport(0,0,scn.feat.fxsky_res,scn.feat.fxsky_res);
  glMatrixMode(GL_PROJECTION);glLoadIdentity;  
  gluPerspective(45*2,1,0.01,10000000);  
  glMatrixMode(GL_MODELVIEW);glLoadIdentity;   
   
  //Left-handed coordinates
  glScalef(1,1,-1);
 end;
end;
//############################################################################// 
procedure sky_render_qfin(scn:poglascene;n:integer);
begin
 if not gl_14_fbo_sup then begin
  glBindTexture(GL_TEXTURE_2D,scn.fxsky_tx[n]);
  glCopyTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,0,0,scn.feat.fxsky_res,scn.feat.fxsky_res,0); 
 end;
end;
//############################################################################// 
procedure sky_render(scn:poglascene;chn:integer);
var s,sk:double;
begin try                                                                 
 if not gl_14_fbo_sup then scn.fixedsky:=false;   
 
 if (not scn.fixedsky)and scn.fixedsky_done then scn.fixedsky_done:=false;
 if scn.fixedsky then begin
  if not scn.fixedsky_done then begin  
   glpopmatrix;            
   glColorMask(true,true,true,true);
   sky_render_qset(scn,0);glrotatef(  90,1,0,0);do_sky_render(scn);sky_render_qfin(scn,0);
   sky_render_qset(scn,1);glrotatef( -90,1,0,0);do_sky_render(scn);sky_render_qfin(scn,1);
   sky_render_qset(scn,2);                      do_sky_render(scn);sky_render_qfin(scn,2);
   sky_render_qset(scn,3);glrotatef(-180,1,0,0);do_sky_render(scn);sky_render_qfin(scn,3);
   sky_render_qset(scn,4);glrotatef( -90,0,1,0);do_sky_render(scn);sky_render_qfin(scn,4);
   sky_render_qset(scn,5);glrotatef(  90,0,1,0);do_sky_render(scn);sky_render_qfin(scn,5);
   if gl_14_fbo_sup then begin
    glFlush;
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,scn.screen_fbo);
   end;
   
   scn.fixedsky_done:=true; 
   render_setre(scn,chn);  
   
   glPushMatrix;     
    x_glrotatef(scn.cam.rot,1);
    if length(scn.star)<>0 then put_light(nmulv(scn.cam.pos,-1),1,1,0); 
  end;   
  s:=100;sk:=s*1.002;      
  glEnable(GL_TEXTURE_2D);  
  glcolor4f(1,1,1,1);  
       
  gldisable(GL_LIGHTING);     
  gldisable(GL_BLEND); 
       
  //Z+
  glBindTexture(GL_TEXTURE_2D,scn.fxsky_tx[2]);
  glBegin(GL_TRIANGLE_STRIP);               
   glTexCoord2f(1,1);glVertex3f( sk, sk,s);glTexCoord2f(1,0);glVertex3f( sk,-sk,s);      
   glTexCoord2f(0,1);glVertex3f(-sk, sk,s);glTexCoord2f(0,0);glVertex3f(-sk,-sk,s);
  glEnd;  
  //Z-
  glBindTexture(GL_TEXTURE_2D,scn.fxsky_tx[3]);
  glBegin(GL_TRIANGLE_STRIP);
   glTexCoord2f(0,0);glVertex3f(-sk, sk,-s);glTexCoord2f(0,1);glVertex3f(-sk,-sk,-s);
   glTexCoord2f(1,0);glVertex3f( sk, sk,-s);glTexCoord2f(1,1);glVertex3f( sk,-sk,-s);
  glEnd; 
        
  //Y+
  glBindTexture(GL_TEXTURE_2D,scn.fxsky_tx[0]);
  glBegin(GL_TRIANGLE_STRIP);
   glTexCoord2f(0,0);glVertex3f(-sk, s, sk);glTexCoord2f(0,1);glVertex3f(-sk, s,-sk);      
   glTexCoord2f(1,0);glVertex3f( sk, s, sk);glTexCoord2f(1,1);glVertex3f( sk, s,-sk);
  glEnd;  
  //Y-
  glBindTexture(GL_TEXTURE_2D,scn.fxsky_tx[1]);
  glBegin(GL_TRIANGLE_STRIP);
   glTexCoord2f(1,1);glVertex3f( sk,-s, sk);glTexCoord2f(1,0);glVertex3f( sk,-s,-sk);      
   glTexCoord2f(0,1);glVertex3f(-sk,-s, sk);glTexCoord2f(0,0);glVertex3f(-sk,-s,-sk);
  glEnd;  
             
  //X+
  glBindTexture(GL_TEXTURE_2D,scn.fxsky_tx[4]);
  glBegin(GL_TRIANGLE_STRIP);
   glTexCoord2f(1,1);glVertex3f( s, sk,-sk);glTexCoord2f(1,0);glVertex3f( s,-sk,-sk);      
   glTexCoord2f(0,1);glVertex3f( s, sk, sk);glTexCoord2f(0,0);glVertex3f( s,-sk, sk);
  glEnd;  
  //X-
  glBindTexture(GL_TEXTURE_2D,scn.fxsky_tx[5]);
  glBegin(GL_TRIANGLE_STRIP);
   glTexCoord2f(1,1);glVertex3f(-s, sk, sk);glTexCoord2f(1,0);glVertex3f(-s,-sk, sk);      
   glTexCoord2f(0,1);glVertex3f(-s, sk,-sk);glTexCoord2f(0,0);glVertex3f(-s,-sk,-sk);
  glEnd;   
   
  glenable(GL_BLEND); 
                
  //background    
  s:=99;sk:=s;    
  glBindTexture(GL_TEXTURE_2D,0);
  glBegin(GL_TRIANGLE_STRIP);               
   glcolor4f(scn.skycolor[0]/255,scn.skycolor[1]/255,scn.skycolor[2]/255,scn.skycolor[3]/255);  
   glVertex3f( sk, sk,s);glVertex3f( sk,-sk,s);glVertex3f(-sk, sk,s);glVertex3f(-sk,-sk,s);
  glEnd;  
  glBegin(GL_TRIANGLE_STRIP);glVertex3f(-sk, sk,-s);glVertex3f(-sk,-sk,-s);glVertex3f( sk, sk,-s);glVertex3f( sk,-sk,-s);glEnd; 
  glBegin(GL_TRIANGLE_STRIP);glVertex3f(-sk, s, sk);glVertex3f(-sk, s,-sk);glVertex3f( sk, s, sk);glVertex3f( sk, s,-sk);glEnd;  
  glBegin(GL_TRIANGLE_STRIP);glVertex3f( sk,-s, sk);glVertex3f( sk,-s,-sk);glVertex3f(-sk,-s, sk);glVertex3f(-sk,-s,-sk);glEnd;  
  glBegin(GL_TRIANGLE_STRIP);glVertex3f( s, sk,-sk);glVertex3f( s,-sk,-sk);glVertex3f( s, sk, sk);glVertex3f( s,-sk, sk);glEnd;  
  glBegin(GL_TRIANGLE_STRIP);glVertex3f(-s, sk, sk);glVertex3f(-s,-sk, sk);glVertex3f(-s, sk,-sk);glVertex3f(-s,-sk,-sk);glEnd;             
             
  glenable(GL_LIGHTING);    
 end else do_sky_render(scn);

 star_render(scn);
 
 except stderr('Graph','Error in sky_render'); end;  
end;     
//############################################################################//
begin
end.
//############################################################################//

