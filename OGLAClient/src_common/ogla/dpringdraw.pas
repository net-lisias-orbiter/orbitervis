//############################################################################// 
// Orbiter Visualisation Project OpenGL client
// Dynamic ring drawing        
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit dpringdraw;
interface
uses asys,grph,maths,opengl1x,dpringbs;
//############################################################################//

procedure drdpring(rng:pdpring;cpos:vec;tp:integer;trc:single);  

implementation
//############################################################################//
//############################################################################//
procedure drdpring(rng:pdpring;cpos:vec;tp:integer;trc:single);
var i:integer;
d:prdrlstyp;
begin 
 if tp=-1 then exit;
 if trc>1 then trc:=1;
 if rng=nil then exit; 
 if not rng.used then exit;  
  
 rng^.ccampos:=nmulv(cpos,1);
   
 dprtessel(@rng^,0,0); 
               
 if tp=0 then begin    
  d:=rng^.drst; 
  if d=nil then exit;  
  
  glpointsize(1);           
  gldisable(GL_LIGHTING);
  gldisable(GL_TEXTURE_2D); 
  glEnableclientstate(GL_COLOR_ARRAY);    
  glEnableclientstate(GL_VERTEX_ARRAY);

  repeat                                                 
   glVertexPointer(3,GL_FLOAT,sizeof(mvec),@d.tr.pnts[0].x);
   glColorPointer(4,GL_FLOAT,sizeof(crgbad),@d.tr.pntc[0][0]);
   glDrawElements(GL_points,100,GL_UNSIGNED_INT,@rngpoints[0]);   
   break; 
   d:=d.nx;
  until d=nil;
                                       
  gldisableclientstate(GL_VERTEX_ARRAY);
  gldisableclientstate(GL_COLOR_ARRAY); 
  glEnable(GL_TEXTURE_2D); 
  glEnable(GL_LIGHTING);
 end;
    
 if tp=1 then begin
  d:=rng^.drst;    
  if d=nil then exit;   
  
  glpointsize(3); 
  gldisable(GL_LIGHTING); 
  gldisable(GL_TEXTURE_2D);
  gldisable(GL_DEPTH_TEST);
  repeat      
   glBegin(GL_POINTS); 
   for i:=0 to RBLK_RES div 3-1 do begin   
    glColor4f (d.tr.pntc[i][0],d.tr.pntc[i][1],d.tr.pntc[i][2],d.tr.pntc[i][3]*trc);
    glnormal3f(0,-1,0);
    glVertex3f(d.tr.pnts[i].x,d.tr.pnts[i].y,d.tr.pnts[i].z);
   end;                                                                            
   glEnd;    
   d:=d.nx;
  until d=nil;            
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D); 
  glEnable(GL_LIGHTING);
 end;
 {
 if tp=2 then begin  
  gldisable(GL_COLOR_MATERIAL);
  gldisable(GL_LIGHTING);     
  gldisable(GL_TEXTURE_2D);
  d:=pln^.drst;     
  if d=nil then exit;
  repeat
   //if d.tr.tex.htex<>-1 then glBindTexture(GL_TEXTURE_2D,txs[d.tr.tex.htex].tx);
   for i:=0 to rplspcount div 3-1 do begin                                            
    if d.tr.qrt=0 then glcolor4f(1,0,0,1);
    if d.tr.qrt=1 then glcolor4f(0,1,0,1);
    if d.tr.qrt=2 then glcolor4f(0,0,1,1);
    if d.tr.qrt=3 then glcolor4f(0,1,1,1);
    if d.tr.qrt=4 then glcolor4f(1,0,1,1);    
    if d.tr.qrt=5 then glcolor4f(1,1,0,1);   
    glBegin(GL_lines);
     glVertex3f(psingle(dword(@d.tr.mshd[0].x)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+0]))^,psingle(dword(@d.tr.mshd[0].y)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+0]))^,psingle(dword(@d.tr.mshd[0].z)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+0]))^);
     glVertex3f(psingle(dword(@d.tr.mshd[0].x)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+1]))^,psingle(dword(@d.tr.mshd[0].y)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+1]))^,psingle(dword(@d.tr.mshd[0].z)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+1]))^);
     glVertex3f(psingle(dword(@d.tr.mshd[0].x)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+2]))^,psingle(dword(@d.tr.mshd[0].y)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+2]))^,psingle(dword(@d.tr.mshd[0].z)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+2]))^);
     glVertex3f(psingle(dword(@d.tr.mshd[0].x)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+0]))^,psingle(dword(@d.tr.mshd[0].y)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+0]))^,psingle(dword(@d.tr.mshd[0].z)+SizeOf(NTVERTEX)*dword(rplspoints[i*3+0]))^);
    glend;     
   end;     
   d:=d.nx;
  until d=nil;
 end;  
 }   
end;
//############################################################################//
begin
end. 
//############################################################################//