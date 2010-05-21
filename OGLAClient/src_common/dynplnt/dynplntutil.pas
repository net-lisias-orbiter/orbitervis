//############################################################################//
// Orulex: Dynamic planet utils
// Released under GNU General Public License
// Made in 2006-2010 by Artyom Litvinovich
//############################################################################//
unit dynplntutil;
{$ifdef fpc}{$mode delphi}{$endif}
interface
uses dynplnt,dynplntbase,dynplntfiles,dynplnttools,noir,sysutils,log,
asys,grph,filef,maths,math,strval,parser,polis{$ifndef no_render},grplib,glgr,opengl1x{$endif};
//############################################################################//
{$ifndef no_render}
procedure drdynplnt(pln:proampl;cpos,cdr,off:vec;tp:integer;tx2sh:integer=-1;subtex:integer=-1;isz:boolean=false;iszh:boolean=false;smap:integer=-1;shmtex:dword=notx;shmapmat:pmatrix4f=nil);
procedure drdynplnt_tes(pln:proampl;cpos,cdr,off:vec;tp:integer);
{$endif}
procedure dp_init(mt:boolean;txd:string);      
procedure def_planet(cp:proampl;nam:string;rad:double);
procedure chplanet(cp:proampl;nam:string;rad:double);
procedure loadpl(cp:proampl);  
function plpos_latlonoff(pl:proampl;rpos:vec;r:double;rotm:mat;lat,lon,x,y,z:double):vec;
//############################################################################//
implementation      
//############################################################################// 
{$ifndef no_render}
procedure drdynplnt(pln:proampl;cpos,cdr,off:vec;tp:integer;tx2sh:integer=-1;subtex:integer=-1;isz:boolean=false;iszh:boolean=false;smap:integer=-1;shmtex:dword=notx;shmapmat:pmatrix4f=nil);
var i:integer;
d:pdrlstyp;                        
v:mquat;
cv,ta:vec;
alt,xa,ya:double;
r:mat;
mat:tmatrix4f;
begin
 if pln=nil then exit; 
 if tp=-1 then exit;
 if not pln.used then exit;  
 if apln<>pln then begin
  dp_thr_term;
  apln:=pln;
 end;

 if ocfg.multithreaded then mutex_lock(tthmx);

 cv:=trr2l(cpos);
 vrec2sph(cv,pln^.radius);
 xa:=(pi/2-cv.x);ya:=pi/2+cv.y; 
 if(abs(xa-pln^.xa)>0.01)or(abs(ya-pln^.ya)>0.01)then begin 
  pln^.xa:=xa;pln^.ya:=ya;    
  rmtrn(@pln^,cos(pln^.xa),sin(pln^.xa),cos(pln^.ya),sin(pln^.ya));
 end;

 cv:=subv(vsph2rec(pln^.radius,pi/2-pln^.xa,pln^.ya-pi/2),cpos);  
 glTranslatef(cv.x,cv.y,cv.z);

 getloclatlonhdg(pi/2-pln^.xa,pln^.ya-pi/2,0,pln^.radius,cv,r);
 ta:=tamat(r);
 
 glrotatef(-ta.x*180/pi,1,0,0);
 glrotatef(-ta.y*180/pi,0,1,0);
 glrotatef(-ta.z*180/pi,0,0,1);
 
 alt:=0;
 pln^.fgeth(@pln^,cpos,alt);
 alt:=modv(cpos)-pln^.radius-alt;
 if alt<0 then alt:=0;
 cpos:=addv(off,addv(cpos,nmulv(cdr,alt/1.1)));

 pln^.ccampos:=nmulv(cpos,1);
 pln^.ccampos.y:=pln^.ccampos.y;

 if not isz then if not ocfg.multithreaded then if orutes then rmtessel(pln); 



 //tp:=2;
           
 if tp=0 then begin 
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  
  if gl_12_sup and((not isz)or iszh) then begin
   glActiveTextureARB(GL_TEXTURE0_ARB);glEnable(GL_TEXTURE_2D);glBindTexture(GL_TEXTURE_2D,0);
   glActiveTextureARB(GL_TEXTURE1_ARB);glEnable(GL_TEXTURE_2D);glBindTexture(GL_TEXTURE_2D,0);
   if iszh then begin glActiveTextureARB(GL_TEXTURE2_ARB);glEnable(GL_TEXTURE_2D);glBindTexture(GL_TEXTURE_2D,0);end;              
   if iszh then begin                                                         
    glMatrixMode(GL_TEXTURE);  
    glLoadMatrixf(pointer(shmapmat));
    mat:=invert_matrix4f(gl_cmmat);
    glMultMatrixf(@mat);   
    glMatrixMode(GL_MODELVIEW); 
   end;                                       
   if tx2sh<>-1 then if gl_2_sup then begin
    glUniform1f(subtex,1);
    if iszh then glUniform1i(smap,2);
   end;
  end else glBindTexture(GL_TEXTURE_2D,0); 
  glcolor4f(1,1,1,1);    
                    
  d:=pln^.drst; 
  if d=nil then begin if ocfg.multithreaded then mutex_release(tthmx); exit; end; 
  repeat   
   if d.tr.draw_tex<>nil then if d.tr.draw_tex.fin and(not d.tr.draw_tex.ld)then makhtex(pln,d.tr.draw_tex);
    
   if gl_12_sup and( (not isz)or iszh) then begin
    glActiveTextureARB(GL_TEXTURE0_ARB);glBindTexture(GL_TEXTURE_2D,d.tr.draw_tex.gltx);
    glActiveTextureARB(GL_TEXTURE1_ARB);glBindTexture(GL_TEXTURE_2D,d.tr.draw_tex.gletx*dword(ord(tx2sh>=0)));          
    if iszh then begin glActiveTextureARB(GL_TEXTURE2_ARB);glBindTexture(GL_TEXTURE_2D,shmtex);end;                                                
    if tx2sh<>-1 then glUniform1i(tx2sh,ord(d.tr.lv>pln.levlimit-2));
   end else glBindTexture(GL_TEXTURE_2D,d.tr.draw_tex.gltx);
    
   glNormalPointer(GL_FLOAT,SizeOf(NTVERTEX),@d.tr.mshd[0].nx);
   glTexCoordPointer(2,GL_FLOAT,SizeOf(NTVERTEX),@d.tr.mshd[0].tu);
   glVertexPointer(3,GL_FLOAT,SizeOf(NTVERTEX),@d.tr.mshd[0].x);
   
   if d.tr.crd and (not d.tr.crdf) then begin
    if(not isz)or iszh then begin
     glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,pln.ospecpow);
     v:=tmquat(pln.ospeccol.x,pln.ospeccol.y,pln.ospeccol.z,1);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x); 
    end;
    glDrawElements(GL_triangles,rplspcount,GL_UNSIGNED_SHORT,@d.tr.refpts[0]);  
    if(not isz)or iszh then begin
     glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,pln.specpow);
     v:=tmquat(pln.speccol.x,pln.speccol.y,pln.speccol.z,1);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x); 
    end;    
    glDrawElements(GL_triangles,rplspcount,GL_UNSIGNED_SHORT,@d.tr.nrefpts[0]);
   end else begin
    if(not isz)or iszh then begin
     if d.tr.crdf then begin         
      glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,pln.ospecpow);
      v:=tmquat(pln.ospeccol.x,pln.ospeccol.y,pln.ospeccol.z,1);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x); 
     end else begin       
      glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,pln.specpow);
      v:=tmquat(pln.speccol.x,pln.speccol.y,pln.speccol.z,1);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);   
     end;  
    end;
    glDrawElements(GL_triangles,rplspcount,GL_UNSIGNED_SHORT,@rplspoints[0]); 
   end;
   
   d:=d.nx;
  until d=nil;  
  if gl_12_sup and((not isz)or iszh) then begin
   if iszh then begin glActiveTextureARB(GL_TEXTURE2_ARB);glDisable(GL_TEXTURE_2D);glBindTexture(GL_TEXTURE_2D,0);end;
   glActiveTextureARB(GL_TEXTURE1_ARB);glDisable(GL_TEXTURE_2D);glBindTexture(GL_TEXTURE_2D,0);
   glActiveTextureARB(GL_TEXTURE0_ARB);glEnable(GL_TEXTURE_2D); glBindTexture(GL_TEXTURE_2D,0);
  end else glBindTexture(GL_TEXTURE_2D,0);
  
  glDisableClientState(GL_VERTEX_ARRAY); 
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);  
  glDisableClientState(GL_NORMAL_ARRAY); 
 end;



 
 
 if tp=1 then begin
  d:=pln^.drst;    
  if d=nil then begin if ocfg.multithreaded then mutex_release(tthmx); exit; end; 
  repeat     
   if d.tr.draw_tex<>nil then if d.tr.draw_tex.fin and(not d.tr.draw_tex.ld)then makhtex(pln,d.tr.draw_tex);
   if d.tr.draw_tex.gltx<>0 then glBindTexture(GL_TEXTURE_2D,d.tr.draw_tex.gltx);
   
   if d.tr.crd then begin         
    glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,90);
    v:=tmquat(1,1,1,1);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x); 
   end else begin         
    glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
    v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x); 
   end;  
   
   glBegin(GL_TRIANGLES); 
   for i:=0 to rplspcount div 3-1 do begin   
    glnormal3f  (psingle(intptr(@d.tr.mshd[0].nx)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0].ny)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0].nz)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^);
    glTexCoord2f(psingle(intptr(@d.tr.mshd[0].tu)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0].tv)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^);
    glVertex3f  (psingle(intptr(@d.tr.mshd[0]. x)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0]. y)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0]. z)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^);

    glnormal3f  (psingle(intptr(@d.tr.mshd[0].nx)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^,psingle(intptr(@d.tr.mshd[0].ny)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^,psingle(intptr(@d.tr.mshd[0].nz)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^);
    glTexCoord2f(psingle(intptr(@d.tr.mshd[0].tu)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^,psingle(intptr(@d.tr.mshd[0].tv)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^);
    glVertex3f  (psingle(intptr(@d.tr.mshd[0]. x)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^,psingle(intptr(@d.tr.mshd[0]. y)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^,psingle(intptr(@d.tr.mshd[0]. z)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^);
 
    glnormal3f  (psingle(intptr(@d.tr.mshd[0].nx)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^,psingle(intptr(@d.tr.mshd[0].ny)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^,psingle(intptr(@d.tr.mshd[0].nz)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^);
    glTexCoord2f(psingle(intptr(@d.tr.mshd[0].tu)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^,psingle(intptr(@d.tr.mshd[0].tv)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^);
    glVertex3f  (psingle(intptr(@d.tr.mshd[0]. x)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^,psingle(intptr(@d.tr.mshd[0]. y)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^,psingle(intptr(@d.tr.mshd[0]. z)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^); 
   end;                                                                            
   glEnd;    
   d:=d.nx;
  until d=nil;
 end;

 if tp=2 then begin  
  gldisable(GL_COLOR_MATERIAL);
  gldisable(GL_LIGHTING);     
  gldisable(GL_TEXTURE_2D);
  d:=pln^.drst;     
  if d=nil then begin if ocfg.multithreaded then mutex_release(tthmx); exit; end; 
  repeat
   for i:=0 to rplspcount div 3-1 do begin                                            
    if d.tr.qrt=0 then glcolor4f(1,0,0,1);
    if d.tr.qrt=1 then glcolor4f(0,1,0,1);
    if d.tr.qrt=2 then glcolor4f(0,0,1,1);
    if d.tr.qrt=3 then glcolor4f(0,1,1,1);
    if d.tr.qrt=4 then glcolor4f(1,0,1,1);    
    if d.tr.qrt=5 then glcolor4f(1,1,0,1);   
    glBegin(GL_lines);
     glVertex3f(psingle(intptr(@d.tr.mshd[0].x)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0].y)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0].z)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^);
     glVertex3f(psingle(intptr(@d.tr.mshd[0].x)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^,psingle(intptr(@d.tr.mshd[0].y)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^,psingle(intptr(@d.tr.mshd[0].z)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+1]))^);
     glVertex3f(psingle(intptr(@d.tr.mshd[0].x)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^,psingle(intptr(@d.tr.mshd[0].y)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^,psingle(intptr(@d.tr.mshd[0].z)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+2]))^);
     glVertex3f(psingle(intptr(@d.tr.mshd[0].x)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0].y)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^,psingle(intptr(@d.tr.mshd[0].z)+SizeOf(NTVERTEX)*intptr(rplspoints[i*3+0]))^);
    glend;     
   end;     
   d:=d.nx;
  until d=nil;
 end; 
           
 if ocfg.multithreaded then mutex_release(tthmx);
end;  
//############################################################################//
//############################################################################// 
procedure drdynplnt_tes(pln:proampl;cpos,cdr,off:vec;tp:integer);
var cv:vec;
alt,xa,ya:double;
r:mat;
begin     
 if pln=nil then exit; 
 if tp=-1 then exit;
 if not pln.used then exit;  
 if apln<>pln then begin
  dp_thr_term;
  apln:=pln;
 end;

 if ocfg.multithreaded then mutex_lock(tthmx);

 cv:=trr2l(cpos);
 vrec2sph(cv,pln^.radius);
 xa:=(pi/2-cv.x);ya:=pi/2+cv.y; 
 if(abs(xa-pln^.xa)>0.01)or(abs(ya-pln^.ya)>0.01)then begin 
  pln^.xa:=xa;pln^.ya:=ya;    
  rmtrn(@pln^,cos(pln^.xa),sin(pln^.xa),cos(pln^.ya),sin(pln^.ya));
 end;

 cv:=subv(vsph2rec(pln^.radius,pi/2-pln^.xa,pln^.ya-pi/2),cpos);  
 getloclatlonhdg(pi/2-pln^.xa,pln^.ya-pi/2,0,pln^.radius,cv,r);
 
 alt:=0;
 pln^.fgeth(@pln^,cpos,alt);
 alt:=modv(cpos)-pln^.radius-alt;
 if alt<0 then alt:=0;
 cpos:=addv(off,addv(cpos,nmulv(cdr,alt/1.1)));

 pln^.ccampos:=nmulv(cpos,1);

 if not ocfg.multithreaded then if orutes then rmtessel(pln); 
           
 if ocfg.multithreaded then mutex_release(tthmx);
end;     
{$endif}      
//############################################################################//
//############################################################################// 
function drdynplntthr(par:pointer):integer;
begin result:=0; try
 repeat
  if apln<>nil then if orutes then rmtessel(apln); 
  if oruclr then begin
   orutes:=false;
   oruclr:=false;
  end;
 until false; 
   
 except wr_log('MainCall','Undefined error, thr-1');end;
end;
//############################################################################//
//############################################################################// 
procedure readorucfg;
var psr:preca;
i:integer;
begin psr:=nil;
 if fileexists('orulex.cfg') then begin
  psr:=parsecfg('orulex.cfg',true,'=');
  for i:=0 to length(psr)-1 do with psr[i] do begin
   if trim(lowercase(par))='maxpolycount' then ocfg.maxpolycount:=propn;
   if trim(lowercase(par))='balance_t' then ocfg.balancing_time_slice:=propn;
   if trim(lowercase(par))='textures_t' then ocfg.textures_time_slice:=propn;
   if trim(lowercase(par))='main_t' then ocfg.main_queue_time_slice:=propn;
   if trim(lowercase(par))='pri_calt_t' then ocfg.priorities_time_slice:=propn;
   if trim(lowercase(par))='reflection' then begin
    if trim(lowercase(props))='c' then ocfg.refidx:=0;
    if trim(lowercase(props))='b' then ocfg.refidx:=1;
    if trim(lowercase(props))='a' then ocfg.refidx:=2;
    if trim(lowercase(props))='off' then ocfg.refidx:=3;
   end; 
   if trim(lowercase(par))='texgen' then ocfg.texture_gen_order:=propn;      
   if trim(lowercase(par))='rangefactor' then ocfg.texture_range_factor:=propd;   
   if trim(lowercase(par))='texture_resolution' then begin
    if propn<3 then propn:=3;
    if propn>7 then propn:=7;
    ocfg.texture_res:=round(pow(2,propn))+1;
   end;
   if trim(lowercase(par))='multithread' then ocfg.multithreaded:=propb;
   if trim(lowercase(par))='levlimit' then ocfg.levlimit:=propn;
   if trim(lowercase(par))='globalhmaplimit' then ocfg.global_heightmap_limit:=propn;
   if trim(lowercase(par))='configs' then ocfg.cfgdir:=props;
   if trim(lowercase(par))='textures' then ocfg.texdir:=props;
   if trim(lowercase(par))='heightmaps' then ocfg.hmapdir:=props;
  end;
 end;  
end;  
//############################################################################//                   
procedure dp_init(mt:boolean;txd:string);
//{$ifdef win32}var sysinfo:system_info;{$endif}
var i,x,y:integer;
p:pointer;
id:cardinal;
begin
 //Default config
 {$I dynplnt_defcfg.inc}
 readorucfg;
 ocfg.multithreaded:=true;
 //{$ifndef win32}ocfg.multithreaded:=false;{$endif}
 //ocfg.multithreaded:=ocfg.multithreaded and mt;
 
 //{$ifdef win32}
 // GetSystemInfo(sysinfo);
 // ocfg.multithreaded:=ocfg.multithreaded and (sysinfo.dwNumberOfProcessors>1);
 //{$endif}
 if ocfg.multithreaded then begin
  tthmx:=mutex_create;
  {$ifdef win32}tthhd:=BeginThread(nil,0,drdynplntthr,nil,0,id);{$else}tthhd:=BeginThread(drdynplntthr);{$endif}
  if tthhd=0 then ocfg.multithreaded:=false;
  //SetThreadPriority(tthhd,THREAD_PRIORITY_IDLE);
  mutex_release(tthmx);
 end;
         
 addifc('perlin',5,@ifcperlin);
 addifc('ridge',5,@ifcridge);
 addifc('sealevel',2,@ifcsealevel);
 addifc('sintf',4,@ifcsintf);
 addifc('costf',4,@ifccostf);
 addifc('ax',0,@ifcax);
 addifc('ay',0,@ifcay);
 addifc('az',0,@ifcaz);
 addifc('az',0,@ifcaz);

 orutes:=true;
 oruclr:=false;

 i:=0;
 for y:=0 to PLT_RES-2 do for x:=0 to PLT_RES-2 do begin
  rplspoints[i+0]:=x+0+(y+0)*PLT_RES;
  rplspoints[i+1]:=x+1+(y+0)*PLT_RES;
  rplspoints[i+2]:=x+1+(y+1)*PLT_RES;
  rplspoints[i+3]:=x+0+(y+0)*PLT_RES;
  rplspoints[i+4]:=x+1+(y+1)*PLT_RES;
  rplspoints[i+5]:=x+0+(y+1)*PLT_RES;
  i:=i+6;
 end;  
 {$ifndef no_render}
 for i:=0 to 1 do begin
  getmem(p,1024*1024*4);
  LoadBitmap(txd+'detail0'+stri(i+1)+'.dds',x,y,p);
  glgr_make_tex(etx[i],x,y,p,true,true,true,true);
  freemem(p);
 end;
 {$endif}
end;
//############################################################################//
procedure chplbas(cp:proampl);
//label 1;
var j,i,n,m,k:integer;
p:vec;
bcnt:integer;
l:astr;
psr:preca;

exl:array of string;
exlh,exlr:array of double;
exlt:array of integer;
t:text;
s,nm:string;

bl:vec2;
bs:double;
begin psr:=nil;   
 //Surfbases
 bcnt:=0;
 setlength(exl,0);setlength(exlh,0);setlength(exlt,0);setlength(exlr,0);
 if fileexists(ocfg.cfgdir+ch_slash+cp^.name+'.crater') then begin
  assignfile(t,ocfg.cfgdir+ch_slash+cp^.name+'.crater');
  reset(t);
  repeat      
   readln(t,s);
   if copy(s,1,2)='//' then continue;
   m:=length(exl);
   setlength(exl,m+1);
   setlength(exlh,m+1);
   setlength(exlt,m+1);
   setlength(exlr,m+1);
    
   j:=getfsymp(s,',');
   exl[m]:=lowercase(trim(copy(s,1,j-1))); 
   s:=copy(s,j+1,length(s));  
   j:=getfsymp(s,',');     
   exlh[m]:=vale(copy(s,1,j-1));
   s:=copy(s,j+1,length(s));  
   j:=getfsymp(s,',');    
   exlt[m]:=vali(copy(s,1,j-1));
   exlr[m]:=vale(copy(s,j+1,length(s)));
  until eof(t);
  closefile(t);
 end;
  
 n:=0;
 l:=filelist(ocfg.bcfgdir+ch_slash+cp^.name+ch_slash+'base'+ch_slash+'*.*',faanyfile);
 for j:=0 to length(l)-1 do if copy(l[j],length(l[j])-3,4)='.cfg' then begin
  psr:=parsecfg(ocfg.bcfgdir+ch_slash+cp^.name+ch_slash+'base'+ch_slash+l[j],true,'=');
  bs:=4000;bl:=tvec2(0,0);
  for i:=0 to length(psr)-1 do with psr[i] do begin   
   if trim(lowercase(par))='location' then bl:=propv2; 
   if trim(lowercase(par))='size' then bs:=propd;
   if trim(lowercase(par))='name' then nm:=props;
  end; 
  
  setlength(cp^.srbs,bcnt+1);

  if bs<4000 then bs:=4000; 
  p:=vsph2rec(cp^.radius,bl.y*pi/180,bl.x*pi/180);
  cp^.srbs[n].used:=true;
  cp^.srbs[n].pos :=p;
  cp^.srbs[n].posl:=tvec2(bl.y,bl.x);
  cp^.srbs[n].r   :=bs;     
  cp^.srbs[n].ro  :=cp^.srbs[n].r;           
  cp^.srbs[n].r2  :=sqr(cp^.srbs[n].r); 
  cp^.srbs[n].h   :=cp^.sbcrlev;   
  cp^.srbs[n].t   :=3;
  cp^.srbs[n].name:=nm;    
  cp^.srbs[n].ch  :=false;
  for k:=0 to length(exl)-1 do if trim(lowercase(nm))=exl[k] then begin
   if exlt[k] and 7=0 then cp^.srbs[n].used:=false;
   if exlh[k]<>0 then cp^.srbs[n].h:=exlh[k];
   cp^.srbs[n].t:=exlt[k];
   if exlr[k]<>0 then cp^.srbs[n].r:=exlr[k]; 
   cp^.srbs[n].r2:=sqr(cp^.srbs[n].r);  
   cp^.srbs[n].ch:=true;
  end;
  n:=n+1;
  
  bcnt:=bcnt+1;
 end;
end;
//############################################################################//
{$i dynplnt_defplnt.inc}
//############################################################################//
procedure chplanet(cp:proampl;nam:string;rad:double);
var psr:preca;
i:integer;
p,pp:vec;
tlm:boolean;
//inosp:boolean;
begin psr:=nil; 
 if fileexists(ocfg.cfgdir+ch_slash+nam+'.cfg') then begin  

  def_planet(cp,nam,rad);

  tlm:=false;
  psr:=parsecfg(ocfg.cfgdir+ch_slash+nam+'.cfg',true,'=');
  for i:=0 to length(psr)-1 do with psr[i] do begin 
   if tlm then begin
    if trim(lowercase(par))='end_surftilelist' then begin tlm:=false; continue; end;
    //getctile(@cp^,valvec4(trim(lowercase(par))),trim(lowercase(par))); 
   end;
   if not tlm then begin
    if trim(lowercase(par))='seed' then cp^.seed:=propn;
    if trim(lowercase(par))='radius' then cp^.radius:=propd;
    //if trim(lowercase(par))='cratercnt' then cp^.cratercnt:=propn;
    if trim(lowercase(par))='function' then cp^.tfuncs:=props;
    if trim(lowercase(par))='belowsphere' then cp^.bels:=propb;   
    if trim(lowercase(par))='levlimit' then cp^.levlimit:=propn;  
    if trim(lowercase(par))='sbcrater' then cp^.sbcrlev:=propd;
    if trim(lowercase(par))='speccol' then cp^.speccol:=propv;
    if trim(lowercase(par))='specpow' then cp^.specpow:=propd;
    if trim(lowercase(par))='ospeccol' then cp^.ospeccol:=propv;
    if trim(lowercase(par))='ospecpow' then cp^.ospecpow:=propd;
   
    if trim(lowercase(par))='microtexture' then cp^.mtex:=propb;
    if trim(lowercase(par))='microtex_lev' then cp^.noilv:=propd;
    if trim(lowercase(par))='maxpolycount' then cp^.maxpolycount:=propn;
    if trim(lowercase(par))='altlimit'   then cp^.altitude_limit:=propd;
    if trim(lowercase(par))='blendlimit' then cp^.blend_limit:=propd;
    if trim(lowercase(par))='glhmaplevel' then cp^.level_of_global_heightmap:=propn;
    if trim(lowercase(par))='glhmapop' then cp^.glhmop:=propn;
    if trim(lowercase(par))='glhmapflag' then cp^.glhmtr:=propn;

    if trim(lowercase(par))='flat'         then getflat   (@cp^,propv4,trim(lowercase(props)));
   
    //if trim(lowercase(par))='heightmap'    then gethmap   (@cp^,trim(lowercase(props)),trim(copy(props,1,40)),vale(copy(props,42,10)),vale(copy(props,53,10)),vale(copy(props,64,10)),vale(copy(props,75,10)),vale(copy(props,86,8)),vali(copy(props,95,1)),vali(copy(props,97,1)),vali(copy(props,99,1)));
    //if trim(lowercase(par))='heightmap8'   then geth8map  (@cp^,trim(lowercase(props)),trim(copy(props,1,40)),vale(copy(props,42,10)),vale(copy(props,53,10)),vale(copy(props,64,10)),vale(copy(props,75,10)),vale(copy(props,86,8)),vali(copy(props,95,1)),vali(copy(props,97,1)),vali(copy(props,99,1)));
    //if trim(lowercase(par))='heightmaphei' then getheihmap(@cp^,trim(lowercase(props)),trim(copy(props,1,40)),vale(copy(props,42,10)),vale(copy(props,53,10)),vale(copy(props,64,10)),vale(copy(props,75,10)),vale(copy(props,86,8)),vali(copy(props,95,1)),vali(copy(props,97,1)),vali(copy(props,99,1)),false);
    //if trim(lowercase(par))='colormap'     then getcmap   (@cp^,trim(lowercase(props)),trim(copy(props,1,40)),vale(copy(props,42,10)),vale(copy(props,53,10)),vale(copy(props,64,10)),vale(copy(props,75,10)),vali(copy(props,86,1)),vali(copy(props,88,1)));
    if trim(lowercase(par))='begin_surftilelist' then tlm:=true;
   end;
  end; 
  if cp^.level_of_global_heightmap>ocfg.global_heightmap_limit then cp^.level_of_global_heightmap:=ocfg.global_heightmap_limit;

  //Craters
  lrndseed:=177;
  setlength(cp^.craters,cp^.cratercnt);
  for i:=0 to cp^.cratercnt-1 do begin               
   p:=nrvec(tvec(random(65535)-32768,random(65535)-32768,random(65535)-32768));
   cp^.craters[i].pos:=nmulv(p,cp^.radius); 
   pp:=vrec2sphv(p);
   cp^.craters[i].lat:=pi/2-pp.x;
   cp^.craters[i].lon:=pi/2+pp.y;
   cp^.craters[i].siz:=random(2500)+500;
   cp^.craters[i].siz2:=sqr(cp^.craters[i].siz);
   cp^.craters[i].h:=random(350)+50;
   if cp^.craters[i].h>cp^.craters[i].siz*0.1 then cp^.craters[i].h:=cp^.craters[i].siz*0.1;
   cp^.craters[i].a:=cp^.craters[i].siz*0.2;
   cp^.craters[i].b:=cp^.craters[i].siz*0.3;
   cp^.craters[i].c:=cp^.craters[i].siz*0.4;
   cp^.craters[i].d:=cp^.craters[i].siz*0.1*ord(random(2)=1);
  end;
             
  cp^.tfuncc:=compexpr(cp^.tfuncs);  
  //rmplinit(@cp^);  
  chplbas(cp); 
 end else begin     
  if assigned(imakepln) then imakepln(cp,nam,rad);   
  chplbas(cp); 
 end;
end;
//############################################################################//
procedure loadpl(cp:proampl);
var psr:preca;
i:integer;
tlm:boolean;
begin psr:=nil;
 if not cp.used then exit;
 tlm:=false;
 if fileexists(ocfg.cfgdir+ch_slash+cp^.name+'.cfg') then begin
  psr:=parsecfg(ocfg.cfgdir+ch_slash+cp^.name+'.cfg',true,'=');
  for i:=0 to length(psr)-1 do with psr[i] do begin 
   if tlm then begin
    if trim(lowercase(par))='end_surftilelist' then begin tlm:=false; continue; end;
    getctile(cp,valquat(trim(lowercase(par))),trim(lowercase(par))); 
   end;
   if not tlm then begin
    if trim(lowercase(par))='heightmap'    then gethmap   (cp,trim(lowercase(props)),trim(copy(props,1,40)),vale(copy(props,42,10)),vale(copy(props,53,10)),vale(copy(props,64,10)),vale(copy(props,75,10)),vale(copy(props,86,8)),vali(copy(props,95,1)),vali(copy(props,97,1)),vali(copy(props,99,1)));
    if trim(lowercase(par))='heightmap8'   then geth8map  (cp,trim(lowercase(props)),trim(copy(props,1,40)),vale(copy(props,42,10)),vale(copy(props,53,10)),vale(copy(props,64,10)),vale(copy(props,75,10)),vale(copy(props,86,8)),vali(copy(props,95,1)),vali(copy(props,97,1)),vali(copy(props,99,1)));
    if trim(lowercase(par))='heightmaphei' then getheihmap(cp,trim(lowercase(props)),trim(copy(props,1,40)),vale(copy(props,42,10)),vale(copy(props,53,10)),vale(copy(props,64,10)),vale(copy(props,75,10)),vale(copy(props,86,8)),vali(copy(props,95,1)),vali(copy(props,97,1)),vali(copy(props,99,1)),false);
    if trim(lowercase(par))='colormap'     then getcmap   (cp,trim(lowercase(props)),trim(copy(props,1,40)),vale(copy(props,42,10)),vale(copy(props,53,10)),vale(copy(props,64,10)),vale(copy(props,75,10)),vali(copy(props,86,1)),vali(copy(props,88,1)));
    if trim(lowercase(par))='begin_surftilelist' then tlm:=true;
   end;
  end; 
 end;

 rmplinit(cp);
 cp^.lded:=true;
end;        
//############################################################################//   
function plpos_latlonoff(pl:proampl;rpos:vec;r:double;rotm:mat;lat,lon,x,y,z:double):vec;
var alt:double;
pos0:vec;
begin
 result:=zvec;
 if pl=nil then exit;
 if @pl.fgeth=nil then exit;
 lat:=lat+z*(360/(2*pi*r));
 if pl.used then pos0:=pl.fgeth(pl,vsph2rec(r,lat/180*pi,lon/180*pi),alt);
 result:=addv(lvmat(rotm,nmulv(nrvec(pos0),r+alt+y)),rpos);
end;
//############################################################################//  
begin 
 imakepln:=def_planet;
end.
//############################################################################//  
