//############################################################################//
// GLGR OpenGL graphics library
// Released under GNU General Public License
// Made in 2007-2010 by Artyom Litvinovich
//############################################################################//
unit glgr;
interface
uses sysutils,asys,
{$ifdef use_zgl}zgl,{$else}opengl1x,{$endif}
grph,grplib,maths,math{$ifdef VFS},vfs{$endif};
//############################################################################//
const biosfnt:array[0..4095]of byte=({$ifdef prefont}{$I ..\biosfnt.inc}{$else}{$I biosfnt.inc}{$endif});
//############################################################################//
const use_zgl:boolean={$ifdef use_zgl}true;{$else}false;{$endif}         
//############################################################################//
type  
bin_fnt=record
 xb,yb,yo:integer;
 d:double;
 cp:array[0..255]of cardinal;
 cpl,cpr,cpd:array[0..255]of double;
end;    

{
glfntrec=record
 weight,height,orientation:integer;
 italic,underline:dword;
 face:pchar;
end;
pglfntrec=^glfntrec; 

}

//############################################################################//

ogl_shader=record
 fs,vs,gs,prg:cardinal;
 unis:array of integer;
end; 

//############################################################################//

var 

gl_cmmat:tmatrix4f;    

frustum:array[0..5]of array[0..3]of glfloat;

bin_fnts:array[0..9]of bin_fnt;
udc:dword;
gl_amb:vec;    
        
glgruva:boolean=true; 
glgr_stensh_aupd:boolean=false;  
gl_shm4:boolean=true;

vboav,gl_2_sup,gl_12_sup,gl_14_fbo_sup,gl_comp_sup:boolean;
usevbo:boolean=true;
rndfbo:cardinal=0;
rndfbod:cardinal=0;

shaderlog_name:string='shader.log';
//############################################################################//
procedure glgr_init; 

procedure loadfnt_bin(ft:integer;fn:string);
procedure loadfnt_grp(ft:integer;fn:string);
                        
function  glgr_free_tex(var tex:GLuint):boolean;   
function  glgr_copy_tex(var textgt,texsrc:GLuint;wid,hei:integer;comp:boolean):boolean;
function  glgr_makeblank_tex(var tex:GLuint;wid,hei:integer;comp,smt,wrp:boolean):Boolean;
function  glgr_make_tex(var tex:GLuint;wid,hei:integer;pdata:pointer;comp,smt,wrp,mip:boolean):Boolean;
function  glgr_make_texfcomp(var tex:GLuint;wid,hei:integer;pdata:pointer;ct,len:cardinal;comp,smt,wrp:boolean):Boolean;
function  glgr_remake_tex(var tex:GLuint;wid,hei:integer;pdata:pointer;comp,smt,wrp:boolean):Boolean;  
function  glgr_remake_texbgr(var tex:GLuint;wid,hei:integer;pdata:pointer;comp,smt,wrp:boolean):Boolean;  
procedure glgr_gettxsiz(var tex:GLuint;var wid,hei:cardinal);      
function  glgr_setshmap(var tex:GLuint;res:cardinal;resy:cardinal=0):boolean;
procedure glgr_fintex(msh:ptypmsh;mip:boolean);
  
procedure put_light(pos:vec;r:double;bn:integer;ltn:integer);  
procedure put_light_omni(n:integer;pos:vec;qa,la:double;amb,dif,spc:crgba);
procedure put_light_spot(n:integer;pos,dir:vec;sp,qa,la:double;amb,dif,spc:crgba);
procedure glgr_ltoff;  

function  invert_matrix4f(im:tmatrix4f):tmatrix4f;   
procedure extract_frustum;
function  SphereInFrustum(x,y,z,radius:real):boolean;  
procedure x_glrotatef(v:vec;d:integer);

procedure wrtxt2D(st:string;siz,xp,yp:double;cl:crgba;fnt:byte=0);
procedure wrtxt(st:string;siz,xp,yp,z:double;cl:crgba;fnt:byte=0);   
procedure wrtxtcnt2D(st:string;siz,xp,yp:double;cl:crgba;fnt:byte=0);
procedure wrtxtbox2D(st:string;siz,xp,yp,xs:double;cl:crgba;fnt:byte=0);
procedure wrtxtcnt(st:string;siz,xp,yp,z:double;cl:crgba;fnt:byte=0);  
                                                        
procedure putpoly2D(x1,y1,x2,y2,x3,y3:double;cl:crgba);
procedure putsqr2D(xp,yp,xs,ys:double;cl,clb:crgba);    
procedure putcsqr2D(xp,yp,xs,ys:double;cf:integer;clin,clbr:crgba);
procedure puttx2D(tx:cardinal;xp,yp,xs,ys:double;flip:boolean;cl:crgba); 
procedure puttx2Dsh(tx:cardinal;xp,yp,xs,ys,txp,typ,txs,tys:double;flip:boolean;cl:crgba);    
procedure puttx3D(tx:cardinal;x,y,z,rx,ry,rz,sx,sy,sz,su,sv:double;cl:crgba);  
 
procedure wrline2D(xh,yh,xl,yl:integer;cl:crgba);    
procedure wrline3D(a,b:vec;cl:crgba);
procedure wrpix2D(x,y:integer;cl:crgba);  
procedure wrellipse2D(xh,yh,xl,yl:double;cl:crgba);    
procedure wrcircle2D(x,y,r:double;cl:crgba);
procedure wrellipse3Dz(xh,yh,xl,yl,z:double;cl:crgba);    
procedure wrcircle3Dz(x,y,z,r:double;cl:crgba);
                                   
//procedure drawvbo(c:integer);     
//procedure drawvbo_place(c:integer);
//procedure genvbo(grp:ptypmshgrp;c:integer;re:boolean);
//procedure genvbont(nt:pantvertex;vt:psmallinta;cvt,ctr,c:integer;re:boolean;tx:cardinal);   
//function  getfreevbo:integer;
//procedure clrvbo(c:integer);
                                                                     
{$ifndef use_zgl}procedure putfullmshgrp(grp:ptypmshgrp;shd:boolean;semit:byte;cmmat,shmat:tmatrix4f;shmtex,tan_att:dword;light:boolean=true);{$endif}                                
procedure putmshgrp(grp:ptypmshgrp;pos,rot,scl:vec;sh:boolean;shd:boolean=false;tx:cardinal=notx-1;noacol:boolean=false;crgba_sh:dword=$FFFFFFFF;semit:byte=0;tan_att:dword=$FFFFFFFF);overload;
procedure putmshgrp(grp:ptypmshgrp;scl:vec;tx:cardinal;noacol:boolean=false);overload;

procedure putmsh(msh:ptypmsh;pos,rot,scl:vec);     
procedure putmshsh(msh:ptypmsh;pos,rot,scl:vec);   
procedure putmshvshset(ps:integer); 
procedure putmshvsh(msh:ptypmsh;pos,rot,scl:vec;lt:vec;pass:integer);  
                                                     
procedure putmshgrpsrt(grp:ptypmshgrp;pos,rot,scl:vec);
procedure putmshsrt(msh:ptypmsh;pos,rot,scl:vec);

procedure putaxis(p:vec;r,s:double;ps:boolean;la:integer);overload;  
//############################################################################//
procedure printInfoLog(obj:cardinal);
function mkshader(verts,frags,geom:pchar;var sh:ogl_shader;logname:string):boolean;
//############################################################################//
implementation
//############################################################################//
type
chr8x16=array[0..15]of array[0..7]of crgba;

vbostktyp=packed record
 tag:integer;
 nml,tex,tex2,elem,vrt:gluint;
 count:integer;
 tx:cardinal;
 esiz:integer;
end;
//############################################################################//
var ctg:integer=23567;
vbostk:array of vbostktyp; 
inda:array of integer;                       
//############################################################################//  
//############################################################################//
procedure calcplanes(grp:ptypmshgrp); 
var v:array [0..3] of vec;  
i,j:integer;  
v1,v2,v3:vec;
begin
 setlength(grp.trngpl,length(grp.trng)div 3);
 setlength(grp.trngplv,length(grp.trng)div 3);
 setlength(grp.trngpln,length(grp.trng));
 setlength(grp.trngpls,length(grp.trng)div 3);
 for j:=0 to length(grp.trng)div 3-1 do begin
  for i:=0 to 2 do begin
   v[i+1].x:=grp.pnts[grp.trng[j*3+i]].pos.x;
   v[i+1].y:=grp.pnts[grp.trng[j*3+i]].pos.y;
   v[i+1].z:=grp.pnts[grp.trng[j*3+i]].pos.z;
  end;
  grp.trngpl[j].x:=v[1].y*(v[2].z-v[3].z)+v[2].y*(v[3].z-v[1].z)+v[3].y*(v[1].z-v[2].z);
  grp.trngpl[j].y:=v[1].z*(v[2].x-v[3].x)+v[2].z*(v[3].x-v[1].x)+v[3].z*(v[1].x-v[2].x);
  grp.trngpl[j].z:=v[1].x*(v[2].y-v[3].y)+v[2].x*(v[3].y-v[1].y)+v[3].x*(v[1].y-v[2].y);
  grp.trngpl[j].w:=-(v[1].x*(v[2].y*v[3].z-v[3].y*v[2].z)+v[2].x*(v[3].y*v[1].z-v[1].y*v[3].z)+v[3].x*(v[1].y*v[2].z-v[2].y*v[1].z));
  
  v1:=v[1];
  v2:=v[2];
  v3:=v[3];
  //grp.trngpls[j]:=max3(vdst(v1,v2),vdst(v1,v3),vdst(v3,v2));
  grp.trngpls[j]:=0.5*sqrt(sqr(vdst(v1,v2)*vdst(v1,v3))-sqr(smulv(subv(v1,v2),subv(v1,v3))));
 end;
 grp.plcl:=true;
end;
//############################################################################//
procedure calcjoints(grp:ptypmshgrp);
var p1i,p2i,p1j,p2j,q1i,q2i,q1j,q2j,i,j,ki,kj:integer;  
begin
 for i:=0 to length(grp.trngpl)-2 do
  for j:=i+1 to length(grp.trngpl)-1 do 
   for ki:=0 to 2 do if grp.trngpln[i*3+ki]<>0 then for kj:=0 to 2 do begin

  p1i:=ki;                                   
  p1j:=kj;
  p2i:=(ki+1) mod 3;
  p2j:=(kj+1) mod 3;
  p1i:=grp.trng[i*3+p1i];
  p2i:=grp.trng[i*3+p2i];
  p1j:=grp.trng[j*3+p1j];
  p2j:=grp.trng[j*3+p2j];
  q1i:=((p1i+p2i)-abs(p1i-p2i)) div 2;
  q2i:=((p1i+p2i)+abs(p1i-p2i)) div 2;
  q1j:=((p1j+p2j)-abs(p1j-p2j)) div 2;
  q2j:=((p1j+p2j)+abs(p1j-p2j)) div 2;
  if (q1i=q2i)and(q1j=q2j)then begin
   grp.trngpln[i*3+ki]:=j+1;
   grp.trngpln[j*3+kj]:=i+1;
  end;
 end;
end;
//############################################################################//
procedure recalcgroup(grp:ptypmshgrp;lt:vec);
var i,j,k,jj:GLuint;
p1,p2:GLuint;
v1,v2:vec;
b:boolean;
lm:single;
begin
 lm:=modv(lt);
 grp.shacnt:=0;
 setlength(grp.shava,length(grp.trngpl)*3*6);
 for i:=0 to length(grp.trngpl)-1 do if grp.trngplv[i] then for j:=0 to 2 do begin
  k:=grp.trngpln[i*3+j];
  if k<>0 then b:=not grp.trngplv[k-1] else b:=false;
        
  //if grp.trngpls[i]<0.05 then begin k:=1;b:=false; end;
  
  if(k=0)or b then begin
   p1:=grp.trng[i*3+j];
   jj:=(j+1) mod 3;
   p2:=grp.trng[i*3+jj];
   //FIXME: Limit shadows to lower fillrate...?
   v1.x:=(grp.pnts[p1].pos.x-lt.x)*(1/lm)*1000000;
   v1.y:=(grp.pnts[p1].pos.y-lt.y)*(1/lm)*1000000;
   v1.z:=(grp.pnts[p1].pos.z-lt.z)*(1/lm)*1000000;
   v2.x:=(grp.pnts[p2].pos.x-lt.x)*(1/lm)*1000000;
   v2.y:=(grp.pnts[p2].pos.y-lt.y)*(1/lm)*1000000;
   v2.z:=(grp.pnts[p2].pos.z-lt.z)*(1/lm)*1000000; 
   grp.shava[grp.shacnt+0]:=tmvec(grp.pnts[p1].pos.x,grp.pnts[p1].pos.y,grp.pnts[p1].pos.z);
   grp.shava[grp.shacnt+1]:=tmvec(grp.pnts[p1].pos.x+v1.x,grp.pnts[p1].pos.y+v1.y,grp.pnts[p1].pos.z+v1.z);
   grp.shava[grp.shacnt+2]:=tmvec(grp.pnts[p2].pos.x,grp.pnts[p2].pos.y,grp.pnts[p2].pos.z);
   grp.shava[grp.shacnt+3]:=tmvec(grp.pnts[p2].pos.x,grp.pnts[p2].pos.y,grp.pnts[p2].pos.z);     
   grp.shava[grp.shacnt+4]:=tmvec(grp.pnts[p1].pos.x+v1.x,grp.pnts[p1].pos.y+v1.y,grp.pnts[p1].pos.z+v1.z);
   grp.shava[grp.shacnt+5]:=tmvec(grp.pnts[p2].pos.x+v2.x,grp.pnts[p2].pos.y+v2.y,grp.pnts[p2].pos.z+v2.z);
   grp.shacnt:=grp.shacnt+6;
  end;
 end;
 if length(inda)<grp.shacnt then begin
  setlength(inda,grp.shacnt+100);
  for i:=0 to grp.shacnt do inda[i]:=i;
 end;
end;  
//############################################################################//
procedure pscc(var s,c:array of extended;sa,ea:extended);
var i:integer;
d,a,b:extended;
begin
 ea:=ea+1e-5;
 d:=0.017453292*(ea-sa)/length(s);

 if length(s)<1000 then begin
  a:=2*Sqr(Sin(d*0.5));
  b:=Sin(d);
  SinCos(sa*0.017453292,s[0], c[0]);
  for i:=0 to length(s)-2 do begin
   c[i+1]:=c[i]-a*c[i]-b*s[i];
   s[i+1]:=s[i]-a*s[i]+b*c[i];
  end;
 end else begin
  sa:=sa*0.017453292;
  for i:=0 to length(s)-1 do SinCos(i*d+sa,s[i],c[i]);
 end;
end;
//############################################################################//
procedure ev(x,y,xr,yr,z:double);
var
i,n:integer;
s,c:array of extended;
begin
 n:=round(max(xr,yr)*0.1)+5;
 if n mod 2=1 then n:=n+1;
 setlength(s,n);
 setlength(c,n);
 n:=n-1;
 pscc(s,c,0,90);
 for i:=0 to n do s[i]:=s[i]*yr;
 for i:=0 to n do c[i]:=c[i]*xr;

 for i:=0 to n-1 do begin glVertex3f(x+c[i],y+s[i],z);glVertex3f(x+c[i+1],y+s[i+1],z); end;
 glVertex3f(x+c[n],y+s[n],z);glVertex3f(x-c[n],y+s[n],z); 
 for i:=n downto 1 do begin glVertex3f(x-c[i],y+s[i],z);glVertex3f(x-c[i-1],y+s[i-1],z); end;
 for i:=0 to n-1 do begin glVertex3f(x-c[i],y-s[i],z);glVertex3f(x-c[i+1],y-s[i+1],z); end;
 glVertex3f(x-c[n],y-s[n],z);glVertex3f(x+c[n],y-s[n],z); 
 for i:=n downto 1 do begin glVertex3f(x+c[i],y-s[i],z);glVertex3f(x+c[i-1],y-s[i-1],z); end;
end;
//############################################################################//
//############################################################################//
//############################################################################//
procedure loadfnt;
var d:array[0..15]of byte;
i,x,y,j:integer;
k:cardinal;
p:pointer;
fnt:array[0..255]of chr8x16;
begin
 bin_fnts[0].xb:=8;bin_fnts[0].yb:=16;bin_fnts[0].d:=2;bin_fnts[0].yo:=0;
 for i:=0 to 255 do begin
  for j:=0 to 15 do d[j]:=biosfnt[i*16+j];

  for y:=0 to 15 do for x:=0 to 7 do if d[y] and ($80 shr x)>0 then 
  fnt[i][y][x]:=tcrgba(255,255,255,255) else
  fnt[i][y][x]:=tcrgba(0,0,0,0);

  p:=@fnt[i][0][0];
  glgr_make_tex(k,8,16,p,false,false,false,false);
  bin_fnts[0].cp[i]:=k;
  bin_fnts[0].cpl[i]:=0;bin_fnts[0].cpr[i]:=1;bin_fnts[0].cpd[i]:=8;
 end;
end; 
//############################################################################//
procedure loadfnt_bin(ft:integer;fn:string);
var f:file;
d:array[0..15]of byte;
i,x,y:integer;
j:cardinal;
p:pointer;    
fnt:array[0..255]of chr8x16;
begin
 bin_fnts[ft].xb:=8;bin_fnts[ft].yb:=16;bin_fnts[ft].d:=2;bin_fnts[ft].yo:=0;
 assignfile(f,fn);
 reset(f,1);
 for i:=0 to 255 do begin
  blockread(f,d,16);

  for y:=0 to 15 do for x:=0 to 7 do if d[y] and ($80 shr x)>0 then 
  fnt[i][y][x]:=tcrgba(255,255,255,255) else
  fnt[i][y][x]:=tcrgba(0,0,0,0);

  p:=@fnt[i][0][0];
  glgr_make_tex(j,8,16,p,false,true,false,false);
  bin_fnts[ft].cp[i]:=j;   
  bin_fnts[ft].cpl[i]:=0;bin_fnts[ft].cpr[i]:=1;bin_fnts[ft].cpd[i]:=8;
 end;
 closefile(f);
end;  
//############################################################################//
procedure loadfnt_grp(ft:integer;fn:string);
var i,x,y,w,h,xw,yw:integer;
p,pn:pbcrgba; 
lw:boolean;
begin
 if loadBitmap(fn,w,h,tcrgb(0,0,0),pointer(pn))=nil then exit;
 xw:=w div 16;yw:=h div 16;bin_fnts[ft].xb:=xw;bin_fnts[ft].yb:=yw;bin_fnts[ft].d:=yw/xw;bin_fnts[ft].yo:=0;
 getmem(p,xw*yw*4);
 for i:=0 to 255 do begin
  bin_fnts[ft].cpl[i]:=xw;bin_fnts[ft].cpr[i]:=0;
  for y:=0 to yw-1 do begin
   lw:=false;
   for x:=0 to xw-1 do begin
    p^[x+y*xw]:=pn^[(i mod 16)*xw+x+((i div 16)*yw+y)*w];
    
    if (p^[x+y*xw][0]<>0)or(p^[x+y*xw][1]<>0)or(p^[x+y*xw][2]<>0)then begin
     if (not lw)and(x<bin_fnts[ft].cpl[i]) then begin bin_fnts[ft].cpl[i]:=x;lw:=true;end;
     if x>bin_fnts[ft].cpr[i] then bin_fnts[ft].cpr[i]:=x;
    end;
    
   end;
  end;
  glgr_make_tex(bin_fnts[ft].cp[i],xw,yw,p,false,true,false,false);
  if bin_fnts[ft].cpl[i]>=bin_fnts[ft].cpr[i] then begin bin_fnts[ft].cpr[i]:=xw/2;bin_fnts[ft].cpl[i]:=0;end;
  if i=32 then begin bin_fnts[ft].cpr[i]:=xw/4;bin_fnts[ft].cpl[i]:=0;end;
  bin_fnts[ft].cpl[i]:=bin_fnts[ft].cpl[i]-1;bin_fnts[ft].cpr[i]:=bin_fnts[ft].cpr[i]+1;
  bin_fnts[ft].cpd[i]:=bin_fnts[ft].cpr[i]-bin_fnts[ft].cpl[i];
  bin_fnts[ft].cpl[i]:=bin_fnts[ft].cpl[i]/xw;bin_fnts[ft].cpr[i]:=bin_fnts[ft].cpr[i]/xw;
 end;
 freemem(p);
end;      
//############################################################################//
function invert_matrix4f(im:tmatrix4f):tmatrix4f;
begin
 result[0][0]:=im[0][0];result[0][1]:=im[1][0];result[0][2]:=im[2][0];result[1][0]:=im[0][1];
 result[1][1]:=im[1][1];result[1][2]:=im[2][1];result[2][0]:=im[0][2];result[2][1]:=im[1][2];
  
 result[2][2]:=im[2][2];  
   
 result[3][0]:=-im[0][0]*im[3][0]-im[0][1]*im[3][1]-im[0][2]*im[3][2];
 result[3][1]:=-im[1][0]*im[3][0]-im[1][1]*im[3][1]-im[1][2]*im[3][2];
 result[3][2]:=-im[2][0]*im[3][0]-im[2][1]*im[3][1]-im[2][2]*im[3][2]; 
      
 result[0][3]:=0;result[1][3]:=0;result[2][3]:=0;result[3][3]:=1;   
end;   
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
function glgr_free_tex(var tex:GLuint):Boolean;
//var p:pointer;
begin
 result:=true;
 //glBindTexture(GL_TEXTURE_2D,tex);
 glDeleteTextures(1,@tex);
 glBindTexture(GL_TEXTURE_2D,0);
end;
//############################################################################//
//############################################################################//
function glgr_makeblank_tex(var tex:GLuint;wid,hei:integer;comp,smt,wrp:boolean):Boolean;
var p:pointer;
begin
 if use_zgl then begin comp:=false;wrp:=true;smt:=false;end;  
 if not gl_12_sup then comp:=false;
 result:=true;
 getmem(p,wid*hei*4);
 glGenTextures(1,@tex);
 glBindTexture(GL_TEXTURE_2D,tex);
 
 if not use_zgl then glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
 if smt then begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
 end else begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
 end;
 if wrp then begin                                            
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
 end else begin 
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP);  
 end;
  
 if comp then glTexImage2D     (GL_TEXTURE_2D,0,GL_COMPRESSED_RGBA_ARB,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,p); 
 if not comp then glTexImage2D (GL_TEXTURE_2D,0,GL_RGBA8                  ,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,p);     
 freemem(p);
 glBindTexture(GL_TEXTURE_2D,0);
end;    
//############################################################################//  
function glgr_copy_tex(var textgt,texsrc:GLuint;wid,hei:integer;comp:boolean):boolean;
var p:pointer;
begin
 {$ifndef use_zgl}
 //bind the source texture and get the texels   
 getmem(p,wid*hei*4);
 glBindTexture(GL_TEXTURE_2D,texsrc);  
 glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE,p);  
  
 //bind the output texture and copy the image  
 glBindTexture(GL_TEXTURE_2D,textgt);  
 
 if comp then glTexImage2D     (GL_TEXTURE_2D,0,GL_COMPRESSED_RGBA_ARB,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,p); 
 if not comp then glTexImage2D (GL_TEXTURE_2D,0,GL_RGBA8              ,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,p);     
 glBindTexture(GL_TEXTURE_2D,0);  
 freemem(p);
 result:=true;
 {$else}result:=false;{$endif}
end;
//############################################################################//
//############################################################################//
function glgr_make_tex(var tex:GLuint;wid,hei:integer;pdata:pointer;comp,smt,wrp,mip:boolean):Boolean;
begin
 result:=false;
 if pdata=nil then exit;
 if use_zgl then begin comp:=false;wrp:=true;smt:=false;mip:=false;end;
 if not gl_12_sup then comp:=false;
 result:=true;
 glGenTextures(1,@tex);
 glBindTexture(GL_TEXTURE_2D,tex);
 
 if not use_zgl then glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);      
 if smt then begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
 end else begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
 end;
 if wrp then begin                                            
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
 end else begin 
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);  
 end;
 if mip then begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR_MIPMAP_LINEAR);
  {$ifndef use_zgl}gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGBA,wid,hei,GL_RGBA,GL_UNSIGNED_BYTE,pdata);{$endif}
 end else begin
  if comp then glTexImage2D     (GL_TEXTURE_2D,0,GL_COMPRESSED_RGBA_ARB,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,pdata); 
  if not comp then glTexImage2D (GL_TEXTURE_2D,0,GL_RGBA8              ,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,pdata); 
 end;
 glBindTexture(GL_TEXTURE_2D,0); 
end;
//############################################################################//
//############################################################################//
function glgr_make_texfcomp(var tex:GLuint;wid,hei:integer;pdata:pointer;ct,len:cardinal;comp,smt,wrp:boolean):Boolean;
begin
 result:=false;
 if pdata=nil then exit;
 if use_zgl then exit;
 //if not gl_12_sup then comp:=false;
 result:=true;
 {$ifndef use_zgl}
 glGenTextures(1,@tex);
 glBindTexture(GL_TEXTURE_2D,tex);
 if not use_zgl then glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
 if smt then begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
 end else begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
 end;
 if wrp then begin                                            
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
 end else begin 
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP);  
 end;  
 case ct of
  1:ct:=GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
  3:ct:=GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
  5:ct:=GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
 end;
 
 if assigned(glCompressedTexImage2DARB) then glCompressedTexImage2DARB(GL_TEXTURE_2D,0,ct,wid,hei,0,len,pdata);
                                                      
 //if comp then glTexImage2D     (GL_TEXTURE_2D,0,GL_COMPRESSED_RGBA_ARB,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,pdata); 
 //if not comp then glTexImage2D (GL_TEXTURE_2D,0,GL_RGBA8              ,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,pdata); 
 glBindTexture(GL_TEXTURE_2D,0);
 {$endif}
end;
//############################################################################//
//############################################################################//
function glgr_remake_tex(var tex:GLuint;wid,hei:integer;pdata:pointer;comp,smt,wrp:boolean):Boolean;
begin
 result:=false;
 if pdata=nil then exit;
 if use_zgl then begin comp:=false;wrp:=true;smt:=false;end;  
 if not gl_12_sup then comp:=false;
 result:=true;
 glBindTexture(GL_TEXTURE_2D,tex); 
 if not use_zgl then glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
 if smt then begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
 end else begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
 end;
 if wrp then begin                                            
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
 end else begin 
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP);  
 end; 
 if comp then glTexImage2D     (GL_TEXTURE_2D,0,GL_COMPRESSED_RGBA_ARB,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,pdata); 
 if not comp then glTexImage2D (GL_TEXTURE_2D,0,GL_RGBA8              ,wid,hei,0,GL_RGBA,GL_UNSIGNED_BYTE,pdata);
 glBindTexture(GL_TEXTURE_2D,0);
end;     
//############################################################################//
function glgr_remake_texbgr(var tex:GLuint;wid,hei:integer;pdata:pointer;comp,smt,wrp:boolean):Boolean;
begin
 result:=false;
 if pdata=nil then exit;
 if use_zgl then begin comp:=false;wrp:=true;smt:=false;end;  
 if not gl_12_sup then comp:=false;
 result:=true;
 glBindTexture(GL_TEXTURE_2D,tex); 
 if not use_zgl then glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
 if smt then begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
 end else begin
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
 end;
 if wrp then begin                                            
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
 end else begin 
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP);  
 end; 
 if comp then glTexImage2D     (GL_TEXTURE_2D,0,GL_COMPRESSED_RGB_ARB,wid,hei,0,GL_BGRA,GL_UNSIGNED_BYTE,pdata); 
 if not comp then glTexImage2D (GL_TEXTURE_2D,0,GL_RGB8              ,wid,hei,0,GL_BGRA,GL_UNSIGNED_BYTE,pdata);  
 glBindTexture(GL_TEXTURE_2D,0);
end;  
//############################################################################//
procedure glgr_gettxsiz(var tex:GLuint;var wid,hei:cardinal);
begin  
 {$ifndef use_zgl}
 glBindTexture(GL_TEXTURE_2D,tex);
 glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_WIDTH,@wid);
 glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_WIDTH,@hei);
 glBindTexture(GL_TEXTURE_2D,0);
 {$else}wid:=256;hei:=256;{$endif}
end;
//############################################################################//
function glgr_setshmap(var tex:GLuint;res:cardinal;resy:cardinal=0):boolean;
const BorderColor:array[0..3]of single=(1,1,1,1);
begin
 result:=false;
 if not gl_2_sup then exit;

 if resy=0 then resy:=res;

 glGenTextures(1,@tex);
 glBindTexture(GL_TEXTURE_2D,tex);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);         
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER_ARB);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER_ARB);
 {$ifndef use_zgl}glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_BORDER_COLOR,@BorderColor);{$endif}
      
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_COMPARE_MODE_ARB,GL_COMPARE_R_TO_TEXTURE_ARB);
 glTexImage2D(GL_TEXTURE_2D,0,GL_DEPTH_COMPONENT24_ARB,res,resy,0,GL_DEPTH_COMPONENT,GL_UNSIGNED_BYTE,nil);
end;     
//############################################################################//
procedure glgr_fintex(msh:ptypmsh;mip:boolean);
var i:integer;
txp:array of pointer;
txi:array of cardinal;
begin
 if msh=nil then exit;
 if not msh.need_fin then exit;
 msh.need_fin:=false;
 setlength(txp,msh.txc);
 setlength(txi,msh.txc);
 for i:=0 to msh.txc-1 do txi[i]:=notx;
 
 for i:=0 to msh.grc-1 do if msh.grp[i].dif.tx<>notx then if txi[msh.grp[i].dif.tx-1]=notx then begin
  txp[msh.grp[i].dif.tx-1]:=msh.grp[i].dif.p;
  txi[msh.grp[i].dif.tx-1]:=0;
  glgr_make_tex(txi[msh.grp[i].dif.tx-1],msh.grp[i].dif.xs,msh.grp[i].dif.ys,msh.grp[i].dif.p,true,true,true,mip);
  freemem(msh.grp[i].dif.p);
 end;
 for i:=0 to msh.grc-1 do if msh.grp[i].nml.tx<>notx then if txi[msh.grp[i].nml.tx-1]=notx then begin
  txp[msh.grp[i].nml.tx-1]:=msh.grp[i].nml.p;
  txi[msh.grp[i].nml.tx-1]:=0;
  glgr_make_tex(txi[msh.grp[i].nml.tx-1],msh.grp[i].nml.xs,msh.grp[i].nml.ys,msh.grp[i].nml.p,true,true,true,mip);
  freemem(msh.grp[i].nml.p);
 end;
 for i:=0 to msh.grc-1 do if msh.grp[i].lth.tx<>notx then if txi[msh.grp[i].lth.tx-1]=notx then begin
  txp[msh.grp[i].lth.tx-1]:=msh.grp[i].lth.p;
  txi[msh.grp[i].lth.tx-1]:=0;
  glgr_make_tex(txi[msh.grp[i].lth.tx-1],msh.grp[i].lth.xs,msh.grp[i].lth.ys,msh.grp[i].lth.p,true,true,true,mip);
  freemem(msh.grp[i].lth.p);
 end;
 
 for i:=0 to msh.grc-1 do begin
  if msh.grp[i].dif.tx<>notx then msh.grp[i].dif.tx:=txi[msh.grp[i].dif.tx-1];
  if msh.grp[i].nml.tx<>notx then msh.grp[i].nml.tx:=txi[msh.grp[i].nml.tx-1];
  if msh.grp[i].lth.tx<>notx then msh.grp[i].lth.tx:=txi[msh.grp[i].lth.tx-1];
 end;
end;                                                              
//############################################################################//
//############################################################################// 
//############################################################################//
procedure printInfoLog(obj:cardinal);
var infologLength:integer;
charsWritten:integer;
infoLog:pchar;           
var f:text;
begin
 infologLength:=0;
 charsWritten:=0;
	
 glGetObjectParameterivARB(obj,GL_OBJECT_INFO_LOG_LENGTH_ARB,@infologLength);
	
 if infologLength>1 then begin
  getmem(infoLog,infologLength+1);
  glGetInfoLogARB(obj,infologLength,@charsWritten,infoLog);
  assignfile(f,shaderlog_name);
  if fileexists(shaderlog_name)then append(f) else rewrite(f);
  writeln(f,infoLog);
  closefile(f);
  
  freemem(infoLog);
 end;
end;     
//############################################################################//
function mkshader(verts,frags,geom:pchar;var sh:ogl_shader;logname:string):boolean;             
var f:text;
begin
 result:=false; 
 sh.prg:=0;     
 if(verts=nil)or(frags=nil)then exit;
 sh.prg:=glCreateProgram;                   
 sh.vs:=glCreateShader(GL_VERTEX_SHADER);
 sh.fs:=glCreateShader(GL_FRAGMENT_SHADER); 
 if geom<>nil then sh.gs:=glCreateShader(GL_GEOMETRY_SHADER_EXT); 
 glAttachShader(sh.prg,sh.fs);
 glAttachShader(sh.prg,sh.vs);   
 if geom<>nil then glAttachShader(sh.prg,sh.gs);  
 assignfile(f,shaderlog_name);
 if fileexists(shaderlog_name)then append(f) else rewrite(f);
 writeln(f,logname);
 closefile(f);
 
 glShaderSource(sh.vs,1,@verts,nil);  
 glCompileShader(sh.vs);
 printInfoLog(sh.vs);
 
 glShaderSource(sh.fs,1,@frags,nil);
 glCompileShader(sh.fs); 
 printInfoLog(sh.fs); 
 if geom<>nil then begin 
  glShaderSource(sh.gs,1,@geom,nil);
  glCompileShader(sh.gs); 
  printInfoLog(sh.gs);  
 end;
 
 glLinkProgram(sh.prg); 
 printInfoLog(sh.prg);   

 result:=true;
end;   
//############################################################################//
//############################################################################//       
//############################################################################//  
//############################################################################//
procedure put_light(pos:vec;r:double;bn:integer;ltn:integer);
var ltp,ltpa:mquat;
begin
 ltp:=tmquat(pos.x,pos.y,pos.z,1);glLightfv(GL_LIGHT0+ltn,GL_POSITION,@ltp);
 ltpa:=tmquat(0.01,0.01,0.01,0);glLightfv(GL_LIGHT0+ltn,GL_AMBIENT,@ltpa);
 ltp:=tmquat(1,1,1,1);glLightfv(GL_LIGHT0+ltn,GL_DIFFUSE,@ltp);
 ltp:=tmquat(1,1,1,1);glLightfv(GL_LIGHT0+ltn,GL_SPECULAR,@ltp);
 glEnable(GL_LIGHT0+ltn);
      
 if bn=1 then begin
  glColor4f(1,1,0,1);
  glBegin(GL_LINES);
   glVertex3f(pos.x,pos.y,pos.z-r);
   glVertex3f(pos.x-r,pos.y,pos.z);

   glVertex3f(pos.x,pos.y,pos.z-r);
   glVertex3f(pos.x,pos.y-r,pos.z);

   glVertex3f(pos.x,pos.y,pos.z-r);
   glVertex3f(pos.x+r,pos.y,pos.z);

   glVertex3f(pos.x,pos.y,pos.z-r);
   glVertex3f(pos.x,pos.y+r,pos.z);

   glVertex3f(pos.x,pos.y,pos.z+r);
   glVertex3f(pos.x-r,pos.y,pos.z);

   glVertex3f(pos.x,pos.y,pos.z+r);
   glVertex3f(pos.x,pos.y-r,pos.z);

   glVertex3f(pos.x,pos.y,pos.z+r);
   glVertex3f(pos.x+r,pos.y,pos.z);

   glVertex3f(pos.x,pos.y,pos.z+r);
   glVertex3f(pos.x,pos.y+r,pos.z);

   glVertex3f(pos.x+r,pos.y,pos.z);
   glVertex3f(pos.x,pos.y+r,pos.z);

   glVertex3f(pos.x+r,pos.y,pos.z);
   glVertex3f(pos.x,pos.y-r,pos.z);

   glVertex3f(pos.x-r,pos.y,pos.z);
   glVertex3f(pos.x,pos.y-r,pos.z);

   glVertex3f(pos.x-r,pos.y,pos.z);
   glVertex3f(pos.x,pos.y+r,pos.z);
  glEnd;
 end;  
end;  
//############################################################################//
procedure put_light_omni(n:integer;pos:vec;qa,la:double;amb,dif,spc:crgba);
var ltp:mquat;
begin
 ltp:=tmquat(pos.x,pos.y,pos.z,1);glLightfv(GL_LIGHT0+n,GL_POSITION,@ltp);
 ltp:=crgba2mquat(amb);glLightfv(GL_LIGHT0+n,GL_AMBIENT ,@ltp);
 ltp:=crgba2mquat(dif);glLightfv(GL_LIGHT0+n,GL_DIFFUSE ,@ltp);
 ltp:=crgba2mquat(spc);glLightfv(GL_LIGHT0+n,GL_SPECULAR,@ltp);
                                      
 glLightf(GL_LIGHT0+n,GL_SPOT_CUTOFF,180); 
 glLightf(GL_LIGHT0+n,GL_LINEAR_ATTENUATION,la);
 glLightf(GL_LIGHT0+n,GL_QUADRATIC_ATTENUATION,qa);
           
 glEnable(GL_LIGHT0+n);
end;
//############################################################################//
procedure put_light_spot(n:integer;pos,dir:vec;sp,qa,la:double;amb,dif,spc:crgba);
var ltp:mquat;
begin
 ltp:=tmquat(pos.x,pos.y,pos.z,1);glLightfv(GL_LIGHT0+n,GL_POSITION,@ltp);
 ltp:=crgba2mquat(amb);glLightfv(GL_LIGHT0+n,GL_AMBIENT ,@ltp);
 ltp:=crgba2mquat(dif);glLightfv(GL_LIGHT0+n,GL_DIFFUSE ,@ltp);
 ltp:=crgba2mquat(spc);glLightfv(GL_LIGHT0+n,GL_SPECULAR,@ltp);
    
 ltp:=tmquat(dir.x,dir.y,dir.z,1);glLightfv(GL_LIGHT0+n,GL_SPOT_DIRECTION,@ltp);
 glLightf(GL_LIGHT0+n,GL_SPOT_CUTOFF,sp);
 glLightf(GL_LIGHT0+n,GL_SPOT_EXPONENT,15);
 
 glLightf(GL_LIGHT0+n,GL_CONSTANT_ATTENUATION,1);
 glLightf(GL_LIGHT0+n,GL_LINEAR_ATTENUATION,la);
 glLightf(GL_LIGHT0+n,GL_QUADRATIC_ATTENUATION,qa);
    
 glEnable(GL_LIGHT0+n);
end;       
//############################################################################//
procedure glgr_ltoff;
var i:integer;
begin
 for i:=GL_LIGHT1 to GL_LIGHT7 do gldisable(i); 
end;   
//############################################################################//
//############################################################################//
//############################################################################//    
procedure extract_frustum;
var proj,modl,clip:array[0..15]of glfloat;
t:glfloat;
i,j:integer;
begin
 glGetFloatv(GL_PROJECTION_MATRIX,@proj[0]);
 glGetFloatv(GL_MODELVIEW_MATRIX ,@modl[0]);

 for i:=0 to 3 do for j:=0 to 3 do clip[i+j*4]:=modl[j*4]*proj[i]+modl[1+j*4]*proj[i+4]+modl[2+j*4]*proj[i+8]+modl[3+j*4]*proj[i+12]; 
 for j:=0 to 5 do begin
  for i:=0 to 3 do frustum[j][i]:=clip[3+i*4]-clip[i*4+j div 2];
  t:=sqrt(frustum[j][0]*frustum[j][0]+frustum[j][1]*frustum[j][1]+frustum[j][2]*frustum[j][2]);
  if t=0 then t:=1/1e10;
  for i:=0 to 3 do frustum[j][i]:=frustum[j][i]/t;
 end;
end;    
//############################################################################// 
function SphereInFrustum(x,y,z,radius:real):boolean;
var p:integer;
begin
 result:=true;
 for p:=0 to 6-1 do if(frustum[p][0]*x+frustum[p][1]*y+frustum[p][2]*z+frustum[p][3]<=-radius)then begin result:=false; break; end;
end; 
//############################################################################//
procedure x_glrotatef(v:vec;d:integer);
begin
 if d=1 then begin
  glRotatef(v.z*180/pi,0,0,1);
  glRotatef(v.y*180/pi,0,1,0);
  glRotatef(v.x*180/pi,1,0,0);   
 end else if d=-1 then begin      
  glrotatef(-v.x*180/pi,1,0,0); 
  glrotatef(-v.y*180/pi,0,1,0);     
  glrotatef(-v.z*180/pi,0,0,1);  
 end;
end;   
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
procedure wrtxt2D(st:string;siz,xp,yp:double;cl:crgba;fnt:byte=0);
var i:integer;
x1,y1:double;
ch:byte;
begin   
 x1:=xp;y1:=yp-bin_fnts[fnt].yo;
 glPushMatrix;   
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);    
 glEnable(GL_TEXTURE_2D);  
 for i:=1 to length(st) do begin
  ch:=ord(st[i]);   
  glBindTexture(GL_TEXTURE_2D,0);    
  glBindTexture(GL_TEXTURE_2D,bin_fnts[fnt].cp[ch]);     
  glBegin(GL_QUADS);
   glColor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255);   
                                        
   glTexCoord2f(bin_fnts[fnt].cpl[ch],0); glVertex2f(x1,y1);  
   glTexCoord2f(bin_fnts[fnt].cpr[ch],0); glVertex2f(x1+bin_fnts[fnt].cpd[ch]*siz,y1);  
   glTexCoord2f(bin_fnts[fnt].cpr[ch],1); glVertex2f(x1+bin_fnts[fnt].cpd[ch]*siz,y1+siz*bin_fnts[fnt].yb); 
   glTexCoord2f(bin_fnts[fnt].cpl[ch],1); glVertex2f(x1,y1+siz*bin_fnts[fnt].yb);
 
  glEnd;       
  x1:=x1+bin_fnts[fnt].cpd[ch]*siz;
  udc:=udc+1;
 end;          
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST); 
 glPopMatrix; 
 glBindTexture(GL_TEXTURE_2D,0);
end;
//############################################################################//
procedure wrtxt(st:string;siz,xp,yp,z:double;cl:crgba;fnt:byte=0);
var i:integer;
x1,y1,mjx,mjy:double;
ch:byte;
begin
 mjx:=scrx;
 mjy:=scry;
 x1:=xp; y1:=yp;
 glPushMatrix;
 glscalef(siz,siz,1);
 for i:=1 to length(st) do begin
  ch:=ord(st[i]);
  glBindTexture(GL_TEXTURE_2D,bin_fnts[fnt].cp[ch]);
  glBegin(GL_QUADS);
   glColor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255);  
   glnormal3f(0,0,1);

   glTexCoord2f(0,0); glVertex3f(x1,y1+16/mjy,z);
   glTexCoord2f(1,0); glVertex3f(x1+8/mjx,y1+16/mjy,z);
   glTexCoord2f(1,1); glVertex3f(x1+8/mjx,y1,z);
   glTexCoord2f(0,1); glVertex3f(x1,y1,z);
  glEnd;
  x1:=x1+8/mjx;    
  udc:=udc+1;
 end;
 glPopMatrix;
end;
//############################################################################//
procedure wrtxtcnt2D(st:string;siz,xp,yp:double;cl:crgba;fnt:byte=0);
var i:integer;l:double;
begin    
 l:=0;for i:=0 to length(st)-1 do begin l:=l+bin_fnts[fnt].cpd[ord(st[i+1])]*siz;end;
 wrtxt2d(st,siz,xp-l/2,yp,cl,fnt);
end;
//############################################################################//
procedure wrtxtbox2D(st:string;siz,xp,yp,xs:double;cl:crgba;fnt:byte=0);
var c,l,lr,i:integer;
begin    
 c:=round(xs/(siz*8));
 l:=length(st);
 lr:=l div c;
 for i:=0 to lr do wrtxt2d(copy(st,i*c,c-1),siz,xp,yp+i*siz*8*1.5,cl,fnt);
end;
//############################################################################//
procedure wrtxtcnt(st:string;siz,xp,yp,z:double;cl:crgba;fnt:byte=0);
var mjx,l:double; 
i:integer;
begin    
 l:=0;for i:=0 to length(st)-1 do begin l:=l+bin_fnts[fnt].cpd[ord(st[i+1])]*siz;end;
 mjx:=scry;
 wrtxt(st,siz,xp-(siz/mjx)*(l/2),yp,z,cl,fnt);
end;
//############################################################################//
procedure puttx2D(tx:dword;xp,yp,xs,ys:double;flip:boolean;cl:crgba);
begin        
 glEnable(GL_TEXTURE_2D);  
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);      
 glBindTexture(GL_TEXTURE_2D,tx); 
 glBegin(GL_QUADS);
  glColor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 

  if not flip then begin
   glTexCoord2f(0,0); glVertex2f(xp,yp);     
   glTexCoord2f(1,0); glVertex2f(xp+xs,yp);   
   glTexCoord2f(1,1); glVertex2f(xp+xs,yp+ys);   
   glTexCoord2f(0,1); glVertex2f(xp,yp+ys);
  end else begin                           
   glTexCoord2f(0,1); glVertex2f(xp,yp);     
   glTexCoord2f(1,1); glVertex2f(xp+xs,yp);   
   glTexCoord2f(1,0); glVertex2f(xp+xs,yp+ys);   
   glTexCoord2f(0,0); glVertex2f(xp,yp+ys);
  end;
 glEnd;      
 udc:=udc+1;
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST); 
 glBindTexture(GL_TEXTURE_2D,0);    
end; 
//############################################################################//  
procedure puttx2Dsh(tx:dword;xp,yp,xs,ys,txp,typ,txs,tys:double;flip:boolean;cl:crgba);   
begin        
 glEnable(GL_TEXTURE_2D);  
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);      
 glBindTexture(GL_TEXTURE_2D,tx); 
 glBegin(GL_QUADS);
  glColor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 

  if not flip then begin
   glTexCoord2f(txp,typ); glVertex2f(xp,yp);     
   glTexCoord2f(txs,typ); glVertex2f(xp+xs,yp);   
   glTexCoord2f(txs,tys); glVertex2f(xp+xs,yp+ys);   
   glTexCoord2f(txp,tys); glVertex2f(xp,yp+ys);
  end else begin                           
   glTexCoord2f(txp,tys); glVertex2f(xp,yp);     
   glTexCoord2f(txs,tys); glVertex2f(xp+xs,yp);   
   glTexCoord2f(txs,typ); glVertex2f(xp+xs,yp+ys);   
   glTexCoord2f(txp,typ); glVertex2f(xp,yp+ys);
  end;
 glEnd;      
 udc:=udc+1;
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST); 
 glBindTexture(GL_TEXTURE_2D,0);     
end;   
//############################################################################//
procedure putsqr2D(xp,yp,xs,ys:double;cl,clb:crgba);
begin   
 if xs>1 then xs:=xs-1;
 if ys>1 then ys:=ys-1;
 glPushMatrix;   
  glDisable(GL_LIGHTING);  
  gldisable(GL_DEPTH_TEST);  
  glBindTexture(GL_TEXTURE_2D,0);     
  glBegin(GL_QUADS);
   glColor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 

   glTexCoord2f(0,0); glVertex2f(xp,yp);     
   glTexCoord2f(1,0); glVertex2f(xp+xs,yp);   
   glTexCoord2f(1,1); glVertex2f(xp+xs,yp+ys);   
   glTexCoord2f(0,1); glVertex2f(xp,yp+ys);
  glEnd;       
  glBegin(GL_LINE_LOOP);
   glColor4f(clb[0]/255,clb[1]/255,clb[2]/255,clb[3]/255); 

   glTexCoord2f(0,0); glVertex2f(xp,yp);     
   glTexCoord2f(1,0); glVertex2f(xp+xs,yp);   
   glTexCoord2f(1,1); glVertex2f(xp+xs,yp+ys);   
   glTexCoord2f(0,1); glVertex2f(xp,yp+ys);
  glEnd;      
  udc:=udc+1;
  glEnable(GL_LIGHTING);   
  glEnable(GL_DEPTH_TEST);  
 glPopMatrix;  
 glBindTexture(GL_TEXTURE_2D,0);
end;
//############################################################################//
procedure putpoly2D(x1,y1,x2,y2,x3,y3:double;cl:crgba);
begin   
 glPushMatrix;   
  glDisable(GL_LIGHTING);  
  gldisable(GL_DEPTH_TEST);  
  glBindTexture(GL_TEXTURE_2D,0);     
  glBegin(GL_TRIANGLES);
   glColor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 

   glVertex2f(x1,y1);   
   glVertex2f(x2,y2);
   glVertex2f(x3,y3);
  glEnd;       
  udc:=udc+1;
  glEnable(GL_LIGHTING);   
  glEnable(GL_DEPTH_TEST);  
 glPopMatrix;  
 glBindTexture(GL_TEXTURE_2D,0);
end;
//############################################################################//
procedure putcsqr2D(xp,yp,xs,ys:double;cf:integer;clin,clbr:crgba);
begin   
 if xs>1 then xs:=xs-0.1;
 if ys>1 then ys:=ys-0.1;
 glPushMatrix;   
  glDisable(GL_LIGHTING); 
  gldisable(GL_DEPTH_TEST);  
  glBindTexture(GL_TEXTURE_2D,0);  

  if cf<ys/2 then begin 
   glBegin(GL_TRIANGLES);
    glColor4f(clin[0]/255,clin[1]/255,clin[2]/255,clin[3]/255); 
 
    glVertex2f(xp,yp+cf);   
    glVertex2f(xp+xs-cf,yp);
    glVertex2f(xp+xs,yp+cf);    
    glVertex2f(xp,yp+cf);    
    glVertex2f(xp+cf,yp);  
    glVertex2f(xp+xs-cf,yp); 
                          
    glVertex2f(xp+cf,yp+ys);    
    glVertex2f(xp+xs,yp+ys-cf);  
    glVertex2f(xp+xs-cf,yp+ys);                             
    glVertex2f(xp+cf,yp+ys);     
    glVertex2f(xp,yp+ys-cf); 
    glVertex2f(xp+xs,yp+ys-cf);
                     
    glVertex2f(xp,yp+ys-cf);
    glVertex2f(xp+xs,yp+cf);
    glVertex2f(xp+xs,yp+ys-cf);    
    glVertex2f(xp,yp+ys-cf);   
    glVertex2f(xp,yp+cf);      
    glVertex2f(xp+xs,yp+cf);  
    
   glEnd; 
  end;
  glBegin(GL_LINE_LOOP);
   glColor4f(clbr[0]/255,clbr[1]/255,clbr[2]/255,clbr[3]/255); 

   glTexCoord2f(0,0); glVertex2f(xp+cf,yp);     
   glTexCoord2f(1,0); glVertex2f(xp+xs-cf,yp);  
   glTexCoord2f(1,0); glVertex2f(xp+xs,yp+cf);   
   glTexCoord2f(1,1); glVertex2f(xp+xs,yp+ys-cf);  
   glTexCoord2f(1,1); glVertex2f(xp+xs-cf,yp+ys);   
   glTexCoord2f(0,1); glVertex2f(xp+cf,yp+ys);  
   glTexCoord2f(0,1); glVertex2f(xp,yp+ys-cf);
   glTexCoord2f(0,1); glVertex2f(xp,yp+cf); 
  glEnd;      
  udc:=udc+1;
  glEnable(GL_LIGHTING);   
  glEnable(GL_DEPTH_TEST); 
 glPopMatrix;             
 glBindTexture(GL_TEXTURE_2D,0);
end;
//############################################################################//
procedure puttx3D(tx:dword;x,y,z,rx,ry,rz,sx,sy,sz,su,sv:double;cl:crgba);
begin   
 glPushMatrix;  
  glTranslatef(x,y,z);  
  glrotatef(rx,1,0,0); 
  glrotatef(ry,0,1,0);     
  glrotatef(rz,0,0,1);   
  glscalef(sx,sy,sz);  
  if tx<>notx then glEnable(GL_TEXTURE_2D) else gldisable(GL_TEXTURE_2D);  
  glDisable(GL_LIGHTING);      
  if tx<>notx then glBindTexture(GL_TEXTURE_2D,tx); 
  glBegin(GL_QUADS);
   glColor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 

   glTexCoord2f( 0, 0); glVertex3f(-0.5,-0.5,0);     
   glTexCoord2f(su, 0); glVertex3f( 0.5,-0.5,0);   
   glTexCoord2f(su,sv); glVertex3f( 0.5, 0.5,0);   
   glTexCoord2f( 0,sv); glVertex3f(-0.5, 0.5,0);
  glEnd;      
  udc:=udc+1;   
  glEnable(GL_LIGHTING);   
 glPopMatrix;  
 glEnable(GL_TEXTURE_2D); 
 glBindTexture(GL_TEXTURE_2D,0);
end;
//############################################################################//
procedure wrline2D(xh,yh,xl,yl:integer;cl:crgba);
begin                  
 gldisable(GL_TEXTURE_2D);  
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);  
 glBegin(GL_LINES);
  glcolor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 

  glVertex2f(xh,yh);     
  glVertex2f(xl,yl);
 glEnd;       
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST); 
 glEnable(GL_TEXTURE_2D);  
end;
//############################################################################//
procedure wrline3D(a,b:vec;cl:crgba);
begin                  
 gldisable(GL_TEXTURE_2D);  
 glDisable(GL_LIGHTING); 
 //gldisable(GL_DEPTH_TEST);  
 glBegin(GL_LINES);
  glcolor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 

  glVertex3f(a.x,a.y,a.z);     
  glVertex3f(b.x,b.y,b.z);
 glEnd;       
 glEnable(GL_LIGHTING);   
 //glEnable(GL_DEPTH_TEST); 
 glEnable(GL_TEXTURE_2D);  
end;
//############################################################################//
procedure wrpix2D(x,y:integer;cl:crgba);
begin
 {$ifndef use_zgl}glPointSize(1);{$endif}
 gldisable(GL_POINT_SMOOTH);
 gldisable(GL_TEXTURE_2D);    
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);  
 glBegin(GL_POINTS);
  glcolor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 

  glVertex2f(x,y);  
 glEnd;       
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST);  
 glEnable(GL_TEXTURE_2D);  
end;
//############################################################################//
procedure wrcircle2D(x,y,r:double;cl:crgba);
begin 
 glBindTexture(GL_TEXTURE_2D,0);    
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);  
 glBegin(GL_LINES);
  glcolor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 
  EV(x,y,r,r,0); 
 glEnd;       
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST);
end;  
//############################################################################//
procedure wrellipse2D(xh,yh,xl,yl:double;cl:crgba);
begin   
 glBindTexture(GL_TEXTURE_2D,0);    
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);  
 glBegin(GL_LINES);
  glcolor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 
  EV((xh+xl)/2,(yh+yl)/2,abs(xh-xl)/2,Abs(yh-yl)/2,0);  
 glEnd;       
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST);
end;  
//############################################################################//
procedure wrcircle3Dz(x,y,z,r:double;cl:crgba);
begin 
 glBindTexture(GL_TEXTURE_2D,0);    
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);  
 glBegin(GL_LINES);
  glcolor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 
  EV(x,y,r,r,z); 
 glEnd;       
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST);
end;  
//############################################################################//
procedure wrellipse3Dz(xh,yh,xl,yl,z:double;cl:crgba);
begin   
 glBindTexture(GL_TEXTURE_2D,0);    
 glDisable(GL_LIGHTING); 
 gldisable(GL_DEPTH_TEST);  
 glBegin(GL_LINES);
  glcolor4f(cl[0]/255,cl[1]/255,cl[2]/255,cl[3]/255); 
  EV((xh+xl)/2,(yh+yl)/2,abs(xh-xl)/2,Abs(yh-yl)/2,z);  
 glEnd;       
 glEnable(GL_LIGHTING);   
 glEnable(GL_DEPTH_TEST);
end;
//############################################################################//
{$ifndef use_zgl}
procedure genvbo(grp:ptypmshgrp;c:integer;re:boolean);
var i:integer;
vtx,nml:array of mvec;
txc,tx2c:array of mvec2;
trng:array of word;
begin      
 ctg:=ctg+1;
 grp.tag:=ctg;
 vbostk[c].tag:=ctg;
 vbostk[c].tx:=grp^.dif.tx;

 setlength(vtx,length(grp.pnts));for i:=0 to length(grp.pnts)-1 do vtx[i]:=grp.pnts[i].pos;
 setlength(nml,length(grp.pnts));for i:=0 to length(grp.pnts)-1 do nml[i]:=grp.pnts[i].nml;
 setlength(txc,length(grp.pnts));for i:=0 to length(grp.pnts)-1 do txc[i]:=grp.pnts[i].tx;
 setlength(tx2c,length(grp.pnts));for i:=0 to length(grp.pnts)-1 do tx2c[i]:=grp.pnts[i].tx2;

 vbostk[c].count:=length(grp.trng); 
 if length(grp.pnts)<65000 then begin
  vbostk[c].esiz:=1;         
  setlength(trng,length(grp.trng));
  for i:=0 to length(grp.trng)-1 do trng[i]:=grp.trng[i];
 end else vbostk[c].esiz:=2;

 if re then glDeleteBuffersARB(5,@vbostk[c].nml);
 glGenBuffersARB(5,@vbostk[c].nml);
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].vrt);
 glBufferDataARB(GL_ARRAY_BUFFER_ARB,length(grp.pnts)*3*sizeof(single),@vtx[0],GL_STATIC_DRAW_ARB); 
                        
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].nml);
 glBufferDataARB(GL_ARRAY_BUFFER_ARB,length(grp.pnts)*3*sizeof(single),@nml[0],GL_STATIC_DRAW_ARB);

 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].tex);
 glBufferDataARB(GL_ARRAY_BUFFER_ARB,length(grp.pnts)*2*sizeof(single),@txc[0],GL_STATIC_DRAW_ARB);
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].tex2);
 glBufferDataARB(GL_ARRAY_BUFFER_ARB,length(grp.pnts)*2*sizeof(single),@tx2c[0],GL_STATIC_DRAW_ARB);

 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[c].elem);
 if vbostk[c].esiz=1 then glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[c].count*2,@trng[0],GL_STATIC_DRAW_ARB); 
 if vbostk[c].esiz=2 then glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[c].count*4,@grp.trng[0],GL_STATIC_DRAW_ARB); 
              
 setlength(vtx,0);
 setlength(nml,0);
 setlength(txc,0); 
 setlength(tx2c,0); 
 setlength(trng,0); 
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);  
 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,0);
end;  
//############################################################################//
procedure genvbont(nt:pantvertex;vt:psmallinta;cvt,ctr,c:integer;re:boolean;tx:cardinal);
var i:integer;
vtx,nml:array of mvec;
txc:array of mvec2;
begin      
 ctg:=ctg+1;
 vbostk[c].tag:=ctg;
 vbostk[c].tx:=tx;

 setlength(vtx,cvt);for i:=0 to cvt-1 do vtx[i]:=tmvec(nt[i].x,nt[i].y,nt[i].z);
 setlength(nml,cvt);for i:=0 to cvt-1 do nml[i]:=tmvec(nt[i].nx,nt[i].ny,nt[i].nz);
 setlength(txc,cvt);for i:=0 to cvt-1 do txc[i]:=tmvec2(nt[i].tu,nt[i].tv);
   
 vbostk[c].count:=ctr; 
 vbostk[c].esiz:=1;         

 if re then glDeleteBuffersARB(5,@vbostk[c].nml);
 glGenBuffersARB(5,@vbostk[c].nml);
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].vrt);
 glBufferDataARB(GL_ARRAY_BUFFER_ARB,cvt*3*sizeof(single),@vtx[0],GL_STATIC_DRAW_ARB); 
                        
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].nml);
 glBufferDataARB(GL_ARRAY_BUFFER_ARB,cvt*3*sizeof(single),@nml[0],GL_STATIC_DRAW_ARB);

 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].tex);
 glBufferDataARB(GL_ARRAY_BUFFER_ARB,cvt*2*sizeof(single),@txc[0],GL_STATIC_DRAW_ARB);

 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[c].elem);
 if vbostk[c].esiz=1 then glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[c].count*2,vt,GL_STATIC_DRAW_ARB); 
 //if vbostk[c].esiz=2 then glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[c].count*4,@grp.trng[0],GL_STATIC_DRAW_ARB); 
              
 setlength(vtx,0);
 setlength(nml,0);
 setlength(txc,0); 
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);  
 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,0)
end;
//############################################################################//
procedure clrvbo(c:integer);
begin      
 vbostk[c].tag:=-1;
 vbostk[c].tx:=notx;

 glDeleteBuffersARB(5,@vbostk[c].nml);
 vbostk[c].nml:=0;
 
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);  
 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,0)
end;  
//############################################################################//
procedure drawvbo(c:integer);
begin  
 glEnableclientstate(GL_VERTEX_ARRAY);
 glEnableclientstate(GL_NORMAL_ARRAY);
 glEnableclientstate(GL_TEXTURE_COORD_ARRAY);   
        
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].nml);   //1
 glNormalPointer(GL_FLOAT,0,nil);
 
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].tex);   //2
 glTexCoordPointer(2,GL_FLOAT,0,nil);

 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[c].elem);    //3

 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].vrt);       //0
 glVertexPointer(3,GL_FLOAT,0,nil);

 if vbostk[c].esiz=1 then glDrawElements(GL_TRIANGLES,vbostk[c].count,GL_UNSIGNED_SHORT,nil);
 if vbostk[c].esiz=2 then glDrawElements(GL_TRIANGLES,vbostk[c].count,GL_UNSIGNED_INT,nil);
                     
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);  
 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,0); 
                                        
 gldisableclientstate(GL_NORMAL_ARRAY);  
 gldisableclientstate(GL_TEXTURE_COORD_ARRAY);  
 gldisableclientstate(GL_VERTEX_ARRAY); 
end;  
//############################################################################//
procedure drawvbo_place(c:integer);
begin   
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].nml);   //1
 glNormalPointer(GL_FLOAT,0,nil); 
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].tex);   //2
 glTexCoordPointer(2,GL_FLOAT,0,nil);
 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[c].elem);    //3
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[c].vrt);       //0
 glVertexPointer(3,GL_FLOAT,0,nil);

 if vbostk[c].esiz=1 then glDrawElements(GL_TRIANGLES,vbostk[c].count,GL_UNSIGNED_SHORT,nil);
 if vbostk[c].esiz=2 then glDrawElements(GL_TRIANGLES,vbostk[c].count,GL_UNSIGNED_INT,nil);
                     
 glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);  
 glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,0);
end;            
//############################################################################//
function getfreevbo:integer;
begin
 result:=length(vbostk);
 setlength(vbostk,result+1);
end;  
//############################################################################//
procedure putfullmshgrp(grp:ptypmshgrp;shd:boolean;semit:byte;cmmat,shmat:tmatrix4f;shmtex,tan_att:dword;light:boolean=true);
var i,j,vbon:integer;
tc:dword;
pn:paopntyp;
tr:paointeger;
v:mquat;       
mat:tmatrix4f;  
begin 
 if grp=nil then exit;
 
 if not shd then begin
                             v:=tmquat(grp^.col [0]/255,grp^.col [1]/255,grp^.col [2]/255,(grp^.col [3]-semit)/255);glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE, @v.x);
                             v:=tmquat(grp^.cole[0]/255,grp^.cole[1]/255,grp^.cole[2]/255, grp^.cole[3]/255);       glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);
                             glcolor4f(grp^.col [0]/255,grp^.col [1]/255,grp^.col [2]/255,(grp^.col [3]-semit)/255);                                                 
  if light then begin
   if grp^.spow<>0 then begin v:=tmquat(grp^.cols[0]/255,grp^.cols[1]/255,grp^.cols[2]/255, grp^.cols[3]/255);       glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);end;
   glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,grp^.spow/2);
  end;
 end;  

 vbon:=-1;
 if usevbo then if grp.static then if length(grp.pnts)>10 then begin
  j:=-1;
  for i:=0 to length(vbostk)-1 do if vbostk[i].tag=grp.tag then begin j:=i; break; end;
  if j=-1 then begin
   j:=getfreevbo;                                                                                       
   genvbo(grp,j,false);
  end;
  if grp.vboreset then begin genvbo(grp,j,true); grp.vboreset:=false;end;    
  vbon:=j;            
 end;  
 
 tc:=length(grp^.trng) div 3;
 pn:=@grp^.pnts;
 tr:=@grp^.trng; 
              
 //glClientActiveTextureARB(GL_TEXTURE0_ARB);
 glActiveTextureARB(GL_TEXTURE0_ARB);glEnable(GL_TEXTURE_2D);if grp.nml.tx<>notx then glBindTexture(GL_TEXTURE_2D,grp.nml.tx) else glBindTexture(GL_TEXTURE_2D,0); 
 if grp.nml.uv<>0 then begin
  glEnableclientstate(GL_TEXTURE_COORD_ARRAY); 
  if vbon<>-1 then begin
   glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[vbon].tex2);   //2
   glTexCoordPointer(2,GL_FLOAT,0,nil);
  end else glTexCoordPointer(2,GL_FLOAT,SizeOf(pntyp),@pn^[0].tx2.x);
 end;
                 
 glClientActiveTextureARB(GL_TEXTURE1_ARB);
 glActiveTextureARB(GL_TEXTURE1_ARB);glEnable(GL_TEXTURE_2D);if grp.lth.tx<>notx then glBindTexture(GL_TEXTURE_2D,grp.lth.tx) else glBindTexture(GL_TEXTURE_2D,0); 
 if grp.lth.uv<>0 then begin       
  glEnableclientstate(GL_TEXTURE_COORD_ARRAY); 
  if vbon<>-1 then begin
   glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[vbon].tex2);   //2
   glTexCoordPointer(2,GL_FLOAT,0,nil);
  end else glTexCoordPointer(2,GL_FLOAT,SizeOf(pntyp),@pn^[0].tx2.x);
 end;
 if shmtex<>$FFFFFFFF then begin     
  //glClientActiveTextureARB(GL_TEXTURE2_ARB);
  glActiveTextureARB(GL_TEXTURE2_ARB);glEnable(GL_TEXTURE_2D);glBindTexture(GL_TEXTURE_2D,shmtex);
  glMatrixMode(GL_TEXTURE);
  glLoadMatrixf(@shmat);
  mat:=invert_matrix4f(cmmat);
  glMultMatrixf(@mat);
  glMatrixMode(GL_MODELVIEW);
 end;                       
 //glClientActiveTextureARB(GL_TEXTURE3_ARB);
 glActiveTextureARB(GL_TEXTURE3_ARB);glEnable(GL_TEXTURE_2D);if grp.dif.tx<>notx then glBindTexture(GL_TEXTURE_2D,grp.dif.tx) else glBindTexture(GL_TEXTURE_2D,0);
                      
 glClientActiveTextureARB(GL_TEXTURE0_ARB);
 
 glEnableclientstate(GL_VERTEX_ARRAY);
 glEnableclientstate(GL_NORMAL_ARRAY);
 glEnableclientstate(GL_TEXTURE_COORD_ARRAY); 
 if tan_att<>$FFFFFFFF then glEnableVertexAttribArrayARB(tan_att);

 if vbon<>-1 then begin
  glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[vbon].nml);   //1
  glNormalPointer(GL_FLOAT,0,nil); 
  glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[vbon].tex);   //2
  glTexCoordPointer(2,GL_FLOAT,0,nil);
  glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,vbostk[vbon].elem);    //3
  glBindBufferARB(GL_ARRAY_BUFFER_ARB,vbostk[vbon].vrt);       //0
  glVertexPointer(3,GL_FLOAT,0,nil);   
  glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);       //0
  if tan_att<>$FFFFFFFF then glVertexAttribPointerARB(tan_att,3,GL_FLOAT,false,SizeOf(pntyp),@pn^[0].tng.x); 

  if vbostk[vbon].esiz=1 then glDrawElements(GL_TRIANGLES,vbostk[vbon].count,GL_UNSIGNED_SHORT,nil);
  if vbostk[vbon].esiz=2 then glDrawElements(GL_TRIANGLES,vbostk[vbon].count,GL_UNSIGNED_INT,nil);
                     
  glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);  
  glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,0);
 end else begin
  glNormalPointer(GL_FLOAT,SizeOf(pntyp),@pn^[0].nml.x);
  glVertexPointer(3,GL_FLOAT,SizeOf(pntyp),@pn^[0].pos.x);
  glTexCoordPointer(2,GL_FLOAT,SizeOf(pntyp),@pn^[0].tx.x);
  if tan_att<>$FFFFFFFF then glVertexAttribPointerARB(tan_att,3,GL_FLOAT,false,SizeOf(pntyp),@pn^[0].tng.x); 
                       
  if dword(length(tr^))=tc*3 then glDrawElements(GL_triangles,tc*3,GL_UNSIGNED_INT,@tr^[0]);   
 end;
 udc:=udc+tc*3;
                           
 if tan_att<>$FFFFFFFF then glDisableVertexAttribArrayARB(tan_att);
 gldisableclientstate(GL_VERTEX_ARRAY); 
 gldisableclientstate(GL_NORMAL_ARRAY); 
 gldisableclientstate(GL_TEXTURE_COORD_ARRAY); 
      
 for i:=GL_TEXTURE3_ARB downto GL_TEXTURE0_ARB do begin glClientActiveTextureARB(i);glActiveTextureARB(i);glDisable(GL_TEXTURE_2D);glBindTexture(GL_TEXTURE_2D,0);gldisableclientstate(GL_TEXTURE_COORD_ARRAY);end;
      
 if not shd then begin
  glenable(GL_TEXTURE_2D);
  glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
  v:=tmquat(0,0,0,0);
  glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);  
  glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);
 end; 
end;     
{$endif}
//############################################################################//
procedure putmshgrp(grp:ptypmshgrp;pos,rot,scl:vec;sh:boolean;shd:boolean=false;tx:cardinal=notx-1;noacol:boolean=false;crgba_sh:dword=$FFFFFFFF;semit:byte=0;tan_att:dword=$FFFFFFFF);
label 1;
var i,j:integer;
tc:dword;
pn:paopntyp;
tr:paointeger;
v:mquat;
begin 
 if grp=nil then exit;
 if tx=notx-1 then tx:=grp^.dif.tx;
 
 if not shd then begin
  if tx=notx then gldisable(GL_TEXTURE_2D) else glBindTexture(GL_TEXTURE_2D,tx);
  if not noacol then begin
   v:=tmquat(grp^.col[0]/255,grp^.col[1]/255,grp^.col[2]/255,(grp^.col[3]-semit)/255);glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@v.x);
   {$ifndef use_zgl}if gl_2_sup and (crgba_sh<>$FFFFFFFF) then glUniform4f(crgba_sh,grp^.col[0]/255,grp^.col[1]/255,grp^.col[2]/255,(grp^.col[3]-semit)/255);{$endif}
   v:=tmquat(grp^.cole[0]/255,grp^.cole[1]/255,grp^.cole[2]/255,grp^.cole[3]/255);glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);
   glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,grp^.spow/2);
   if grp^.spow<>0 then begin v:=tmquat(grp^.cols[0]/255,grp^.cols[1]/255,grp^.cols[2]/255,grp^.cols[3]/255);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);end;
   glcolor4f(grp^.col[0]/255,grp^.col[1]/255,grp^.col[2]/255,(grp^.col[3]-semit)/255);   
  end;
 end;
      
 glPushMatrix;    
  glTranslatef(pos.x,pos.y,pos.z);   
  if sh then glscalef(scl.x,scl.y,scl.z);  
  glrotatef(rot.x,1,0,0); 
  glrotatef(rot.y,0,1,0);     
  glrotatef(rot.z,0,0,1);    
  if not sh then glscalef(scl.x,scl.y,scl.z);  

  {$ifndef use_zgl}  
  if usevbo then if grp.static then if length(grp.pnts)>10 then begin
   j:=-1;
   for i:=0 to length(vbostk)-1 do if vbostk[i].tag=grp.tag then begin j:=i; break; end;
   if j=-1 then begin
    j:=getfreevbo;                                                                                       
    genvbo(grp,j,false);
   end;
   if grp.vboreset then begin genvbo(grp,j,true); grp.vboreset:=false;end;                
    
   drawvbo(j);             
   udc:=udc+dword(vbostk[j].count); 
   goto 1;
  end;
  {$endif}
 
  tc:=length(grp^.trng) div 3;
  pn:=@grp^.pnts;
  tr:=@grp^.trng;
               
  case grp^.typ of
   0:begin 
    if not glgruva then begin
     glBegin(GL_TRIANGLES);          
     for i:=0 to tc-1 do for j:=0 to 2 do begin glnormal3f(pn^[tr^[i*3+j]].nml.x,pn^[tr^[i*3+j]].nml.y,pn^[tr^[i*3+j]].nml.z);glTexCoord2f(pn^[tr^[i*3+j]].tx.x,pn^[tr^[i*3+j]].tx.y);glVertex3f(pn^[tr^[i*3+j]].pos.x,pn^[tr^[i*3+j]].pos.y,pn^[tr^[i*3+j]].pos.z); end;
     glEnd;
     udc:=udc+tc*3;
    end else begin 
     glEnableclientstate(GL_VERTEX_ARRAY);
     glEnableclientstate(GL_NORMAL_ARRAY);
     glEnableclientstate(GL_TEXTURE_COORD_ARRAY); 
     {$ifndef use_zgl}if tan_att<>$FFFFFFFF then glEnableVertexAttribArrayARB(tan_att);{$endif}

     glNormalPointer(GL_FLOAT,SizeOf(pntyp),@pn^[0].nml.x);
     glVertexPointer(3,GL_FLOAT,SizeOf(pntyp),@pn^[0].pos.x);
     glTexCoordPointer(2,GL_FLOAT,SizeOf(pntyp),@pn^[0].tx.x);
     {$ifndef use_zgl}if tan_att<>$FFFFFFFF then glVertexAttribPointerARB(tan_att,3,GL_FLOAT,false,SizeOf(pntyp),@pn^[0].tng.x);{$endif} 

     {$ifdef use_zgl}
     glBegin(GL_TRIANGLES);
      for i:=0 to tc-1 do begin
       glarrayElement(tr^[i*3+0]);
       glarrayElement(tr^[i*3+1]);
       glarrayElement(tr^[i*3+2]);
      end;
     glEnd; 
     {$else}                  
     if dword(length(tr^))=tc*3 then glDrawElements(GL_triangles,tc*3,GL_UNSIGNED_INT,@tr^[0]);
     {$endif}   
     udc:=udc+tc*3;
                           
     {$ifndef use_zgl}if tan_att<>$FFFFFFFF then glDisableVertexAttribArrayARB(tan_att);{$endif}
     gldisableclientstate(GL_VERTEX_ARRAY); 
     gldisableclientstate(GL_TEXTURE_COORD_ARRAY);  
     gldisableclientstate(GL_NORMAL_ARRAY);  
    end;
   end;
   1:begin     
    if not shd then glDisable(GL_LIGHTING);
    {$ifndef use_zgl}glLineWidth(1);{$endif}   
    glBegin(GL_lines);
    for i:=0 to tc-1 do begin 
     glVertex3f(pn^[tr^[i*3+0]].pos.x,pn^[tr^[i*3+0]].pos.y,pn^[tr^[i*3+0]].pos.z);
     glVertex3f(pn^[tr^[i*3+1]].pos.x,pn^[tr^[i*3+1]].pos.y,pn^[tr^[i*3+1]].pos.z);
     glVertex3f(pn^[tr^[i*3+1]].pos.x,pn^[tr^[i*3+1]].pos.y,pn^[tr^[i*3+1]].pos.z);
     glVertex3f(pn^[tr^[i*3+2]].pos.x,pn^[tr^[i*3+2]].pos.y,pn^[tr^[i*3+2]].pos.z);
     glVertex3f(pn^[tr^[i*3+2]].pos.x,pn^[tr^[i*3+2]].pos.y,pn^[tr^[i*3+2]].pos.z);
     glVertex3f(pn^[tr^[i*3+0]].pos.x,pn^[tr^[i*3+0]].pos.y,pn^[tr^[i*3+0]].pos.z);    
    end;             
    glend;  
    if not shd then glEnable(GL_LIGHTING); 
   end;
  end;

  1:
  if not shd then begin
   glenable(GL_TEXTURE_2D);
   if not noacol then begin
    glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
    v:=tmquat(0,0,0,0);
    glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);  
    glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);
   end;
  end;
 glPopMatrix;  
end;         
//############################################################################//
procedure putmshgrp(grp:ptypmshgrp;scl:vec;tx:cardinal;noacol:boolean=false);overload;
begin   
 putmshgrp(grp,zvec,zvec,scl,false,false,tx,noacol);
end;
//############################################################################//
//############################################################################//
//############################################################################//
procedure placemshgrpsh(grp:ptypmshgrp;pos,rot,scl:vec);
{$ifdef use_zgl}var i:integer;{$endif}
begin
 glPushMatrix;    
  glTranslatef(pos.x,pos.y,pos.z);   
  glrotatef(rot.x,1,0,0); 
  glrotatef(rot.y,0,1,0);     
  glrotatef(rot.z,0,0,1);    
  glscalef(scl.x,scl.y,scl.z);  

  glEnableclientstate(GL_VERTEX_ARRAY);
  glVertexPointer(3,GL_FLOAT,SizeOf(mvec),@grp.shava[0].x); 
  {$ifdef use_zgl}
  glBegin(GL_TRIANGLES);
   for i:=0 to grp.shacnt-1 do begin
    glarrayElement(inda[i*3+0]);
    glarrayElement(inda[i*3+1]);
    glarrayElement(inda[i*3+2]);
   end;
  glEnd; 
  {$else}                  
  glDrawElements(GL_TRIANGLES,grp.shacnt,GL_UNSIGNED_INT,@inda[0]); 
  {$endif}     
  
  udc:=udc+dword(grp.shacnt);
  gldisableclientstate(GL_VERTEX_ARRAY);
     
 glPopMatrix;
end;
//############################################################################//
procedure putmsh(msh:ptypmsh;pos,rot,scl:vec);
var j:integer;
begin
 if not msh^.used then exit;
 for j:=0 to msh.grc-1 do putmshgrp(@msh.grp[j],pos,rot,scl,false);   
end;     
//############################################################################//
procedure putmshvshset(ps:integer);
begin
{$ifndef use_zgl}
 case ps of
  0:begin
   glClearStencil(0);
   gldisable(GL_TEXTURE_2D);  
   glDisable(GL_LIGHTING);
   glDepthMask(FALSE);
   glDepthFunc(GL_LEQUAL);
   glEnable(GL_STENCIL_TEST);
   glpushattrib(GL_COLOR_BUFFER_BIT);
   glColorMask(FALSE,FALSE,FALSE,FALSE);
   glStencilFunc(GL_ALWAYS,1,$FFFFFFFF);
  end;
  1:begin
   glFrontFace(GL_CCW);  
   glColorMask(TRUE,TRUE,TRUE,TRUE);
   glpopattrib;
   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);  
   glColor4f(0.0,0.0,0.0,0.5);   
   
   glStencilFunc(GL_NOTEQUAL,0,$FFFFFFFF); 
   glStencilOp(GL_KEEP,GL_KEEP,GL_KEEP);
   glPushMatrix;   
    glLoadIdentity;  
    glBegin(GL_TRIANGLE_STRIP);
     glVertex3f(-0.1, 0.1,-0.10);
     glVertex3f(-0.1,-0.1,-0.10);
     glVertex3f( 0.1, 0.1,-0.10);
     glVertex3f( 0.1,-0.1,-0.10);
    glEnd;
   glPopMatrix();         
   glDepthFunc(GL_LEQUAL);
   glDepthMask(true);
   glEnable(GL_LIGHTING);
   glDisable(GL_STENCIL_TEST);
   glShadeModel(GL_SMOOTH);
   glFrontFace(GL_CW);  
   glenable(GL_TEXTURE_2D);  
  end;
  2:begin
   glFrontFace(GL_CCW);     
   glColorMask(TRUE,TRUE,TRUE,TRUE);   
   glpopattrib;
   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);          
   glDepthFunc(GL_LEQUAL);
   glDepthMask(true);
   glEnable(GL_LIGHTING);
   glDisable(GL_STENCIL_TEST);
   glShadeModel(GL_SMOOTH);
   glFrontFace(GL_CW);  
   glenable(GL_TEXTURE_2D);  
  end;
 end;
{$endif}
end; 
//############################################################################//
procedure putmshvsh(msh:ptypmsh;pos,rot,scl:vec;lt:vec;pass:integer);
var j,i:integer;
grp:ptypmshgrp;  
side,slim:GLfloat;
rcg:boolean;
begin
{$ifndef use_zgl}
 if not msh^.used then exit;

 rcg:=(vdst(msh^.prlt,nrvec(lt))>0.003)or glgr_stensh_aupd;
 if rcg then msh^.prlt:=nrvec(lt);
 slim:=0;//modv(lt)/15;

 for j:=0 to msh.grc-1 do begin  
  grp:=@msh.grp[j]; 
  if not grp.plcl then begin   
   calcplanes(grp);
   calcjoints(grp);
  end;

  if rcg then for i:=0 to length(grp.trngpl)-1 do begin                                                                 
   side:=grp.trngpl[i].x*lt.x+grp.trngpl[i].y*lt.y+grp.trngpl[i].z*lt.z+grp.trngpl[i].w*1;
   grp.trngplv[i]:=side>slim;
  end;  
  if rcg then recalcgroup(grp,lt); 
 end;

 if pass=0 then begin
  glFrontFace(GL_CW);
  glStencilOp(GL_KEEP,GL_KEEP,GL_INCR_WRAP_EXT);
  for j:=0 to msh.grc-1 do placemshgrpsh(@msh.grp[j],pos,rot,scl);
 end;
 
 if pass=1 then begin
  glFrontFace(GL_CCW);
  glStencilOp(GL_KEEP,GL_KEEP,GL_DECR_WRAP_EXT);
  for j:=0 to msh.grc-1 do placemshgrpsh(@msh.grp[j],pos,rot,scl);
 end;
{$endif} 
end;   
//############################################################################//
procedure putmshsh(msh:ptypmsh;pos,rot,scl:vec);
var j:integer;
c:crgba;
begin
 if not msh^.used then exit;
 for j:=0 to msh.grc-1 do begin
  c:=msh.grp[j].col;
  msh.grp[j].col:=tcrgba(0,0,0,64);
  putmshgrp(@msh.grp[j],pos,rot,scl,true);     
  msh.grp[j].col:=c;
 end;
end;          
//############################################################################//
procedure putmshgrpsrt(grp:ptypmshgrp;pos,rot,scl:vec);
var i:integer;
tc:dword;
pn:paopntyp;
tr:aointeger;
tr1:paointeger;
ts:aointeger;
trd:adouble;
v:vec;
begin    
 v:=pos;     
 vrotz(v,-(rot.z/180)*pi);
 vroty(v,-(rot.y/180)*pi);
 vrotx(v,-(rot.x/180)*pi);
 
 tc:=length(grp^.trng) div 3;
 pn:=@grp^.pnts;
 tr1:=@grp^.trng;

 setlength(trd,length(tr1^) div 3);   
 setlength(ts,length(tr1^) div 3);    
 for i:=0 to length(trd)-1 do ts[i]:=i;   
 for i:=0 to length(trd)-1 do trd[i]:=vdst(v,vmid3(m2v(pn^[tr1^[i*3+0]].pos),m2v(pn^[tr1^[i*3+1]].pos),m2v(pn^[tr1^[i*3+2]].pos)));
 qsort_ptr_dbl(papointer(@ts)^,trd,0,length(trd)-1);    

 setlength(tr,length(tr1^));
 for i:=0 to length(trd)-1 do begin
  tr[i*3+0]:=tr1^[ts[i]*3+0];
  tr[i*3+1]:=tr1^[ts[i]*3+1];
  tr[i*3+2]:=tr1^[ts[i]*3+2];
 end;
 
 glPushMatrix;
  glTranslatef(pos.x,pos.y,pos.z);  
  glscalef(scl.x,scl.y,scl.z);
  glrotatef(rot.z,0,0,1); 
  glrotatef(rot.y,0,1,0); 
  glrotatef(rot.x,1,0,0);  
  if grp.dif.tx=notx then gldisable(GL_TEXTURE_2D) else glBindTexture(GL_TEXTURE_2D,grp.dif.tx);
  case grp^.typ of
   0:begin     
    glEnable(GL_VERTEX_ARRAY);
    glEnable(GL_NORMAL_ARRAY);
    glEnable(GL_TEXTURE_COORD_ARRAY); 
    glEnableclientstate(GL_VERTEX_ARRAY);
    glEnableclientstate(GL_NORMAL_ARRAY);
    glEnableclientstate(GL_TEXTURE_COORD_ARRAY);          
    glcolor4f(grp^.col[0]/255,grp^.col[1]/255,grp^.col[2]/255,grp^.col[3]/255);
     
     
    //glColorPointer(4,GL_FLOAT,SizeOf(pntyp),@pn^[0].cold[0]);
    glNormalPointer(GL_FLOAT,SizeOf(pntyp),@pn^[0].nml.x);
    glVertexPointer(3,GL_FLOAT,SizeOf(pntyp),@pn^[0].pos.x);
    glTexCoordPointer(2,GL_FLOAT,SizeOf(pntyp),@pn^[0].tx.x);
     
    {$ifdef use_zgl}
     glBegin(GL_TRIANGLES);
      for i:=0 to tc-1 do begin
       glarrayElement(tr[i*3+0]);
       glarrayElement(tr[i*3+1]);
       glarrayElement(tr[i*3+2]);
      end;
     glEnd; 
    {$else}                  
     if dword(length(tr))=tc*3 then glDrawElements(GL_triangles,tc*3,GL_UNSIGNED_INT,@tr[0]);
    {$endif}
    udc:=udc+tc*3;
                                  
    gldisableclientstate(GL_VERTEX_ARRAY); 
    gldisableclientstate(GL_TEXTURE_COORD_ARRAY);  
    gldisableclientstate(GL_NORMAL_ARRAY);    
    gldisable(GL_VERTEX_ARRAY); 
    gldisable(GL_TEXTURE_COORD_ARRAY);  
    gldisable(GL_NORMAL_ARRAY);    
   end;
  end;

  glenable(GL_TEXTURE_2D);
 glPopMatrix; 
end; 
//############################################################################//
procedure putmshsrt(msh:ptypmsh;pos,rot,scl:vec);
var i:integer;
begin     
 if not msh^.used then exit;
 for i:=0 to msh.grc-1 do putmshgrpsrt(@msh.grp[i],pos,rot,scl);
end;
//############################################################################//
procedure putaxis(p:vec;r,s:double;ps:boolean;la:integer);overload;
var c:single;
begin
{$ifndef use_zgl}
 if ps then c:=254/255 else c:=0.5;
 if ps then r:=r*10;
  //---------------------------------------------------------------------------//
  //
  //                                          Y
  //                                          |
  //                                          |
  //                                          O---X
  //                                         /
  //                                        Z
  //      
  glpushattrib(GL_LIGHTING_BIT or GL_TEXTURE_BIT);       
  gldisable(GL_LIGHTING);     
  gldisable(GL_TEXTURE_2D);
  if la=1 then glLineWidth(r+2) else glLineWidth(r);glBegin(GL_LINES);
   glColor4f(1,0,0,1);
   glVertex3f(p.x,p.y,p.z);glVertex3f(p.x+s,p.y  ,p.z  );
   glVertex3f(p.x+s,p.y  ,p.z  );glVertex3f(p.x+s*0.9,p.y+s*0.1,p.z  );
   glVertex3f(p.x+s,p.y  ,p.z  );glVertex3f(p.x+s*0.9,p.y-s*0.1,p.z  );
   glVertex3f(p.x+s,p.y  ,p.z  );glVertex3f(p.x+s*0.9,p.y,p.z+s*0.1);
   glVertex3f(p.x+s,p.y  ,p.z  );glVertex3f(p.x+s*0.9,p.y,p.z-s*0.1);
  glEnd;
  if la=2 then glLineWidth(r+2) else glLineWidth(r);glBegin(GL_LINES);
   glColor4f(0,1,0,1);
   glVertex3f(p.x,p.y,p.z);glVertex3f(p.x  ,p.y+s,p.z  );
   glVertex3f(p.x  ,p.y+s,p.z  );glVertex3f(p.x+s*0.1,p.y+s*0.9,p.z  );
   glVertex3f(p.x  ,p.y+s,p.z  );glVertex3f(p.x-s*0.1,p.y+s*0.9,p.z  );
   glVertex3f(p.x  ,p.y+s,p.z  );glVertex3f(p.x,p.y+s*0.9,p.z+s*0.1);
   glVertex3f(p.x  ,p.y+s,p.z  );glVertex3f(p.x,p.y+s*0.9,p.z-s*0.1);
  glEnd;
  if la=3 then glLineWidth(r+2) else glLineWidth(r);glBegin(GL_LINES);
   glColor4f(0,0,1,1);
   glVertex3f(p.x,p.y,p.z);glVertex3f(p.x  ,p.y  ,p.z+s);
   glVertex3f(p.x  ,p.y  ,p.z+s);glVertex3f(p.x+s*0.1,p.y  ,p.z+s*0.9);
   glVertex3f(p.x  ,p.y  ,p.z+s);glVertex3f(p.x-s*0.1,p.y  ,p.z+s*0.9);
   glVertex3f(p.x  ,p.y  ,p.z+s);glVertex3f(p.x,p.y+s*0.1,p.z+s*0.9);
   glVertex3f(p.x  ,p.y  ,p.z+s);glVertex3f(p.x,p.y-s*0.1,p.z+s*0.9);
  glEnd;
  if la=4 then glLineWidth(r+2) else glLineWidth(r);glBegin(GL_LINES);glColor4f(c,0,0,1);glVertex3f(p.x,p.y,p.z);glVertex3f(p.x-s,p.y  ,p.z  );glEnd;
  if la=5 then glLineWidth(r+2) else glLineWidth(r);glBegin(GL_LINES);glColor4f(0,c,0,1);glVertex3f(p.x,p.y,p.z);glVertex3f(p.x  ,p.y-s,p.z  );glEnd;
  if la=6 then glLineWidth(r+2) else glLineWidth(r);glBegin(GL_LINES);glColor4f(0,0,c,1);glVertex3f(p.x,p.y,p.z);glVertex3f(p.x  ,p.y  ,p.z-s);glEnd;
  glLineWidth(1);
  glpopattrib;  
  //---------------------------------------------------------------------------//
 {$endif}
end;  
//############################################################################//
procedure glgr_init; 
var glextstring:string; 
begin
 loadfnt;     
 {$ifdef use_zgl}
 usevbo:=false;   
 vboav:=usevbo;
 gl_shm4:=false;   
 gl_2_sup:=false;
 gl_14_fbo_sup:=false;
 gl_12_sup:=false;
 gl_comp_sup:=false;
 {$else}
 Load_GL_EXT_blend_minmax;
 Load_GL_ARB_vertex_buffer_object;
 usevbo:=assigned(glBindBufferARB);//Load_GL_ARB_vertex_buffer_object;
 vboav:=usevbo; 
 
 glextstring:=glGetString(GL_EXTENSIONS);
 gl_shm4:=gl_shm4 and (pos('GL_EXT_gpu_shader4',glextstring)<>0);

 gl_2_sup:=Load_GL_version_2_0;
 gl_14_fbo_sup:=Load_GL_EXT_framebuffer_object and (pos('framebuffer_object',glextstring)<>0);
 ReadExtensions;   
 gl_12_sup:=assigned(glActiveTextureARB);
                                     
 glDrawrangeElements:=GLGetProcAddress('glDrawRangeElements');
 glCompressedTexImage2DARB:=GLGetProcAddress('glCompressedTexImage2DARB');
 glGetCompressedTexImageARB:=GLGetProcAddress('glGetCompressedTexImageARB');
 EXT_fog_coord_Init; 
 
 gl_comp_sup:=assigned(glCompressedTexImage2DARB);
 {$endif}
end;
//############################################################################//
begin
 gl_amb:=tvec(0.01,0.01,0.01);
end.   
//############################################################################//
