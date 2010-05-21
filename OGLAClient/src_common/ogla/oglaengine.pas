//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA core rendering system
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglaengine;
interface
uses asys,grph,maths,glgr,dogl,opengl1x,ogladata,oglacalc;
//############################################################################//  
procedure render_setfirst(scn:poglascene);          
procedure render_setre(scn:poglascene;chn:integer);     
procedure putpnt(v,vr:vec;apr:double;shd:boolean=false); 
function glhProjectf(objx,objy,objz:single;modelview,projection:psinglea;viewport:pinta):vec;
//############################################################################//  
implementation  
//############################################################################//
procedure render_setfirst(scn:poglascene); 
var v:mquat;
begin
 if not scn.firstrun then exit;
 scn.firstrun:=false;

 glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
 glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
 glHint(GL_POINT_SMOOTH_HINT,GL_NICEST);
 
 glenable(GL_LINE_SMOOTH);
 
 glColorMaterial(GL_FRONT_AND_BACK,GL_DIFFUSE);
 glenable(GL_COLOR_MATERIAL);
 
 glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
 v:=tmquat(gl_amb.x,gl_amb.y,gl_amb.z,1);glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@v.x); 
 v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);  
 v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);

 glLightModelf(GL_LIGHT_MODEL_LOCAL_VIEWER,1);
 glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL,GL_SEPARATE_SPECULAR_COLOR);
 
 glShadeModel(GL_SMOOTH);
 glLineWidth(1);
 glEnable(GL_NORMALIZE);
 glenable(GL_POINT_SMOOTH);
               
 if gl_2_sup then glUseProgram(0);
end;    
//############################################################################// 
procedure render_setre(scn:poglascene;chn:integer);
var i,mi:integer;
mx:double;  
begin      
 render_setfirst(scn);  
 glColorMask(true,true,true,true);
 
 //Sky color
 mi:=-1;
 mx:=1e100;
 for i:=0 to length(scn.plnt)-1 do if modv(scn.plnt[i].cpos)<mx then begin mx:=modv(scn.plnt[i].cpos); mi:=i; end;
 if mi=-1 then scn.skycolor:=gclaz else begin
  scn.skycolor:=getskycol(scn,scn.plnt[mi]);
  scn.skycolor_grnd:=getskycol(scn,scn.plnt[mi],true);
 end;
 
 if gl_2_sup and scn.feat.rayleigh and scn.feat.advanced then begin
  scn.sky:=0;
  glClearColor(0,0,0,1); 
 end else begin
  scn.sky:=scn.skycolor[3]/255;  
  glClearColor(scn.skycolor[0]/255,scn.skycolor[1]/255,scn.skycolor[2]/255,1); 
 end;  

 if gl_14_fbo_sup then begin
  //Post plane    
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,0,0);        
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);
  if gl_14_fbo_sup then if scn.feat.postplane then begin
   glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,scn.screen_fbo);
   if glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)<>GL_FRAMEBUFFER_COMPLETE_EXT then glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);  
  end;
 end;

 //Viewport
 if scn.cur_sv=0 then if not(scn.feat.stereo and(chn=1)) then glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
 if scn.tx<>0 then begin          
  //Scene set for camera
  glMatrixMode(GL_PROJECTION); glLoadIdentity;
  gluPerspective((scn.camapr*2*180/pi)*(ord(scn.feat.projection=1)+1),1,0.1,10000000);
  glMatrixMode(GL_MODELVIEW); glLoadIdentity;   
  glViewport(0,0,scn.feat.cmtres,scn.feat.cmtres);
 end else begin                  
  //Scene set for main     
  glgr_set3d(scn.sys.gwin,(scn.camapr*2*180/pi)*(ord(scn.feat.projection=1)+1),0.1,10000000); 
  if scn.feat.projection=4 then case scn.cur_sv of 
   2:glViewport(0,0,scn.wid div 3+1,scn.hei);
   0:glViewport(scn.wid div 3,0,scn.wid div 3,scn.hei);
   1:glViewport(2*scn.wid div 3-2,0,scn.wid div 3+3,scn.hei);
  end else if scn.feat.projection=2 then case scn.cur_sv of 
   0:glViewport(0,0,scn.wid div 2,scn.hei);
   1:glViewport(scn.wid div 2,0,scn.wid div 2,scn.hei);
  end else if scn.feat.projection=3 then case scn.cur_sv of 
   0:glViewport(0,0,scn.wid div 3+1,scn.hei);
   1:glViewport(scn.wid div 3,0,scn.wid div 3,scn.hei);
   2:glViewport(2*scn.wid div 3-2,0,scn.wid div 3+3,scn.hei);
  end else glViewport(0,0,scn.wid,scn.hei);
 end;   

 
 if scn.feat.stereo then begin
  if chn=0 then glColorMask(true,false,false,true);  
  if chn=1 then glColorMask(false,true,true,true);  
  if chn=2 then glColorMask(true,true,true,true);
 end;  

 glenable(GL_DEPTH_TEST); 
 glEnable(GL_TEXTURE_2D);
 glEnable(GL_BLEND);
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
 
 glEnable(GL_LIGHTING);
 glPointSize(1);

 glEnable(GL_CULL_FACE);//orbitergl uses that.
 glCullFace(GL_BACK);
 glFrontFace(GL_CW); 
 //Left-handed coordinates
 glScalef(1,1,-1);
               
 if gl_2_sup then glUseProgram(0);

 if scn.feat.wireframe then begin
  glPolygonmode(GL_FRONT,GL_LINE);
  glPolygonmode(GL_BACK,GL_LINE);
 end else begin
  glPolygonmode(GL_FRONT,GL_FILL);
  glPolygonmode(GL_BACK,GL_FILL);
 end;
end;  
//############################################################################// 
procedure putpnt(v,vr:vec;apr:double;shd:boolean=false);
begin
 //gldisable(GL_DEPTH_TEST);  
 if not shd then begin
  gldisable(GL_LIGHTING); 
  gldisable(GL_TEXTURE_2D);
 end;
 glPushMatrix;        
  glTranslatef(v.x,v.y,v.z);   
  x_glrotatef(vr,-1);
  glpointsize(apr);
  glBegin(GL_POINTS); 
   glcolor4f(1,1,1,1);
   glVertex3f(0,0,0);
  glend;
 glPopMatrix; 
 if not shd then begin
  glenable(GL_TEXTURE_2D);  
  glenable(GL_LIGHTING); 
 end;
 //glenable(GL_DEPTH_TEST);   
end;   
//############################################################################//
function glhProjectf(objx,objy,objz:single;modelview,projection:psinglea;viewport:pinta):vec;
var fTempo:array[0..7]of single;//Transformation vectors
begin
 result:=zvec;
 //Modelview transform
 ftempo[0]:=modelview[0]*objx+modelview[4]*objy+modelview[8]*objz+modelview[12];  //w is always 1
 ftempo[1]:=modelview[1]*objx+modelview[5]*objy+modelview[9]*objz+modelview[13];
 ftempo[2]:=modelview[2]*objx+modelview[6]*objy+modelview[10]*objz+modelview[14];
 ftempo[3]:=modelview[3]*objx+modelview[7]*objy+modelview[11]*objz+modelview[15];
 
 //Projection transform, the final row of projection matrix is always [0 0 -1 0] so we optimize for that.
 ftempo[4]:=projection[0]*fTempo[0]+projection[4]*fTempo[1]+projection[8]*fTempo[2]+projection[12]*fTempo[3];
 ftempo[5]:=projection[1]*fTempo[0]+projection[5]*fTempo[1]+projection[9]*fTempo[2]+projection[13]*fTempo[3];
 ftempo[6]:=projection[2]*fTempo[0]+projection[6]*fTempo[1]+projection[10]*fTempo[2]+projection[14]*fTempo[3];
 ftempo[7]:=ftempo[7]-fTempo[2];
 
 //The result normalizes between -1 and 1
 if fTempo[7]=0 then exit;//The w value
 ftempo[7]:=1.0/fTempo[7];

 //Perspective division
 ftempo[4]:=ftempo[4]*fTempo[7];
 ftempo[5]:=ftempo[5]*fTempo[7];
 ftempo[6]:=ftempo[6]*fTempo[7];
 
 //Window coordinates
 //Map x, y to range 0-1
 result.x:=(fTempo[4]*0.5+0.5)*viewport[2]+viewport[0];
 result.y:=(fTempo[5]*0.5+0.5)*viewport[3]+viewport[1];
 //This is only correct when glDepthRange(0.0, 1.0)
 result.z:=(1.0+fTempo[6])*0.5; //Between 0 and 1
end;          
//############################################################################//
begin
end.
//############################################################################//

