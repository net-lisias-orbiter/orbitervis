//############################################################################// 
// Orbiter Visualisation Project OpenGL client
// Particle systems
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit glpars;
interface
uses opengl1x,grph,grplib,glgr,asys,maths;
//############################################################################//
type
part=record
 used:boolean;
 pos:vec;
 cl:crgba;
 tx:cardinal;

 vel,scl:vec;
 lt,tt,siz:double; 
end;
ppart=^part;

pararr=record
 cnt:integer;
 stt:boolean;
 lv:double;
 tp:integer;

 pos,vel,acc,dir:vec;
 pts:array of part;
end;
ppararr=^pararr;

var cldtx:array[0..0]of cardinal;  
defextx:cardinal;
//############################################################################//        
function initps:boolean;   
procedure renderpars(pt:ppararr;cp:vec);  
procedure renderexhaust(ps,dir,cp:vec;lev,lscale,wscale:double;tx:dword);  
//############################################################################// 
function  mkparstr(s,ps:double;tx:cardinal;scl:vec):ppararr;
//############################################################################//
implementation
//############################################################################//
function initps:boolean;
var txx,tyy:integer;
tp:pointer;
begin
 if loadBitmap('textures\Exhaust.dds',txx,tyy,tp)<>nil then glgr_make_tex(defextx,txx,tyy,tp,false,true,true,false);
 if loadBitmap('textures\cloud1.dds',txx,tyy,tp)<>nil then glgr_make_tex(cldtx[0],txx,tyy,tp,false,true,true,false);
 result:=true;
end;  
//############################################################################//
procedure renderpars(pt:ppararr;cp:vec);
var i:integer;
p:ppart;
tx:cardinal;           
tmat:mat;
pos:array[0..3]of vec;

begin 
 glDepthMask(FALSE);
 gldisable(GL_LIGHTING);    
 gldisable(GL_CULL_FACE);
 tx:=0;
 for i:=0 to pt.cnt-1 do if pt.pts[i].used then begin
  p:=@pt.pts[i];
  if tx<>p.tx then begin
   tx:=p.tx;
   glBindTexture(GL_TEXTURE_2D,tx);
  end;
  
  glPushMatrix;
   glTranslatef(p.pos.x,p.pos.y,p.pos.z);  
             
   tmat:=bilbmat(cp);
   
   pos[1]:=lvmat(tmat,tvec( 5,0, 5));
   pos[0]:=lvmat(tmat,tvec(-5,0, 5));
   pos[3]:=lvmat(tmat,tvec( 5,0,-5));
   pos[2]:=lvmat(tmat,tvec(-5,0,-5)); 

   glColor4f(p.cl[0]/255,p.cl[1]/255,p.cl[2]/255,p.cl[3]*pt.lv/255);
   glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2d(1,0.5);  glVertex3f(pos[0].x,pos[0].y,pos[0].z);
    glTexCoord2d(0.5,0.5);glVertex3f(pos[1].x,pos[1].y,pos[1].z);
    glTexCoord2d(1,0);    glVertex3f(pos[2].x,pos[2].y,pos[2].z);
    glTexCoord2d(0.5,0);  glVertex3f(pos[3].x,pos[3].y,pos[3].z);
   glEnd;  
   
  glPopMatrix;
 end;                  
 glEnable(GL_CULL_FACE);
 glenable(GL_LIGHTING);     
 glDepthMask(TRUE);
end;
//############################################################################//
procedure renderexhaust(ps,dir,cp:vec;lev,lscale,wscale:double;tx:dword);
var vr:vec; 
s,slev:double;
v:vec;

tmat:mat;
pos:array[0..3]of vec;   

begin 
 glDepthMask(FALSE);
 gldisable(GL_LIGHTING);
 gldisable(GL_CULL_FACE);
 
 glBindTexture(GL_TEXTURE_2D,tx);
  
 glPushMatrix;
  glTranslatef(ps.x,ps.y,ps.z); 
  glPushMatrix; 
                                       
   vr:=tamat(v2vrotmat(dir,tvec(0,-1,0)));               
   if vdsts(dir,tvec(0,-1,0))<eps then vr:=zvec;              
   if vdsts(dir,tvec(0,1,0))<eps then vr:=tvec(0,0,pi); 
   glrotatef(vr.x*180/pi,1,0,0); 
   glrotatef(vr.y*180/pi,0,1,0); 
   glrotatef(vr.z*180/pi,0,0,1); 
           
   slev:=sqrt(lev);          
   v:=cp;
   vrotx(v,vr.x);
   vroty(v,vr.y);
   vrotz(v,vr.z);
 
   s:=getrtang(0,0,v.x,v.z);   
   
   glrotatef(s,0,1,0); 

   glColor4f(1,1,1,slev);
   glBegin(GL_TRIANGLE_STRIP);
    glTexCoord2d(0.24,1); glVertex3f(+slev*1*wscale,+slev*1*lscale,0);
    glTexCoord2d(0.01,1); glVertex3f(-slev*1*wscale,+slev*1*lscale,0);
    glTexCoord2d(0.24,0); glVertex3f(+slev*1*wscale,-slev*0*lscale,0);
    glTexCoord2d(0.01,0); glVertex3f(-slev*1*wscale,-slev*0*lscale,0);
   glEnd;  
  glPopMatrix;

  tmat:=bilbmat(cp);
          
  pos[1]:=lvmat(tmat,tvec( slev*7*wscale,0, slev*7*wscale));
  pos[0]:=lvmat(tmat,tvec(-slev*7*wscale,0, slev*7*wscale));
  pos[3]:=lvmat(tmat,tvec( slev*7*wscale,0,-slev*7*wscale));
  pos[2]:=lvmat(tmat,tvec(-slev*7*wscale,0,-slev*7*wscale)); 
                  
  glColor4f(1,1,1,slev);
  glBegin(GL_TRIANGLE_STRIP);
   glTexCoord2d(0.99609375,0.49609375);glVertex3f(pos[0].x,pos[0].y,pos[0].z);
   glTexCoord2d(0.50390625,0.49609375);glVertex3f(pos[1].x,pos[1].y,pos[1].z);
   glTexCoord2d(0.99609375,0.00390625);glVertex3f(pos[2].x,pos[2].y,pos[2].z);
   glTexCoord2d(0.50390625,0.00390625);glVertex3f(pos[3].x,pos[3].y,pos[3].z);
  glEnd;       
   
 glPopMatrix;
       
 glBindTexture(GL_TEXTURE_2D,0);
 glEnable(GL_CULL_FACE);
 glenable(GL_LIGHTING);     
 glDepthMask(TRUE);
end;  
//############################################################################//
//############################################################################// 
function mkparstr(s,ps:double;tx:cardinal;scl:vec):ppararr;
var i:integer;
r,f:double;
txa:cardinal;
begin
 txa:=tx;
 if txa=0 then txa:=defextx;
 if txa=notx then txa:=defextx;
 new(result);
 result.cnt:=10;
 result.stt:=true;
 result.pos:=tvec(0,0,0);result.vel:=tvec(0,0,0);result.acc:=tvec(0,0,0);result.dir:=tvec(0,0,0);
                
 setlength(result.pts,result.cnt);  
 for i:=0 to result.cnt-1 do begin
  f:=(random(1000)-500)/500*pi;
  r:=(random(1000)-500)/500*2*pi;
  result.pts[i].used:=true;
  result.pts[i].pos:=tvec(s*cos(f)*sin(r),sin(f)*s/3,s*cos(f)*cos(r));
  result.pts[i].cl:=gclwhite;
  result.pts[i].tx:=txa;
  result.pts[i].siz:=random(round(ps))+ps/2;

  result.pts[i].vel:=tvec(0,0,0);
  result.pts[i].lt:=1;
  result.pts[i].tt:=0;
 end;   
end;   
//############################################################################//
begin
end. 
//############################################################################//
