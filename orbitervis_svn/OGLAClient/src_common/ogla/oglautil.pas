//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA Utilities
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglautil;
interface
uses asys,maths,math,log,tim,noise,noir,oglacalc,ogladata,oglashaders,
grpcam,grph,grplib,procgenlib,dogl,glgr,glpars,{$ifdef orulex}dynplnt,dynplntutil,{$endif}sysutils,opengl1x;   
//############################################################################//
                                
procedure oglaclr_star(var star:poglas_star); 
procedure oglaclr_plnt(var plnt:poglas_planet);
procedure oglaclr_smob(var smob:poglas_smob);   
                
procedure oglaset_star(star:poglas_star;name:string;ob:intptr;pos:vec;r:double;col:crgba);stdcall;
procedure oglaset_plntbase(scn:poglascene;plnt:poglas_planet;name:string;ob:intptr;pos,rot:vec;r:double;atm:boolean);stdcall;
procedure oglaset_plntatm(plnt:poglas_planet;atmrho,atmrho0,atmradlimit:double;atmcolor0:crgbad);stdcall;  
procedure oglaset_plntring(plnt:poglas_planet;ringmin,ringmax:double);stdcall;

function get_free_smob(scn:poglascene):integer;
function get_smob_by_ob(scn:poglascene;ob:pointer):integer;      
function get_smob_by_id(scn:poglascene;id:dword):integer;
                    
procedure oglamk_haze(scn:poglascene;h:poplhazetyp;s:double;n:string);stdcall;
                
procedure oglainit_graph(scn:poglascene);
procedure ogla_loadscene(scn:poglascene;fn:string);
procedure ogla_savescene(scn:poglascene;fn:string);   
  
function ogla_cmdinput(scn:poglascene;op:integer;key:word;shift:byte):boolean;    
procedure ogla_render_own_info(scn:poglascene;auxinfo:boolean);      
procedure ogla_thr_term;      
procedure ogla_clrinit_scene(scn:poglascene);       
//############################################################################//     
var msg_tim:integer=-1;
//############################################################################//
implementation 
//############################################################################// 
procedure zero_op(op:popmeshrec);
var n:integer;
begin
 op.curld:=0;op.cnt:=0;op.avl:=MAXPATCHRES;
 op.res:=0; op.lv0msh.used:=false;op.umsh:=false;
 op.umshld:=false;op.umshck:=false;op.umshav:=false;op.rot:=0; 
 op.nmask:=0;op.npatch:=0;op.bin_loaded:=false;
 setlength(op.tiles,0);
 setlength(op.ptx,0);  
 for n:=1 to MAXPATCHRES do op.sml_tiles[n].done:=false;
end;     
//############################################################################// 
procedure free_op(op:popmeshrec);
var i,j:integer;
begin
 if(op.curld>0)then begin    
  if op.tx[0]<>4294967295 then glDeleteTextures(op.cnt,@op.tx[0]); 
  for i:=0 to length(op.tx)-1 do op.tx[i]:=0;
  for i:=0 to length(op.ptx)-1 do freemem(op.ptx[i]);
  for i:=1 to MAXPATCHRES do begin
   for j:=0 to length(op.sml_tiles[i].til)-1 do op.sml_tiles[i].til[j].msh:=nil;
   setlength(op.sml_tiles[i].til,0);
   op.sml_tiles[i].cnt:=0;
   op.sml_tiles[i].done:=false;
  end;
  op.nmask:=0;op.npatch:=0;op.bin_loaded:=false;
  setlength(op.tiles,0);
  setlength(op.tx,0);
  setlength(op.ptx,0);
  op.curld:=0;
 end;
end;            
//############################################################################//
procedure oglaclr_star(var star:poglas_star); 
begin    
 if star=nil then exit;
 dispose(star);
end;              
//############################################################################//
procedure oglaclr_plnt(var plnt:poglas_planet);
begin   
 if plnt=nil then exit;
 {$ifdef orulex}ogla_saferegraph;{$endif}

 plnt.draw.nrst:=false;
 plnt.draw.atm:=false;
 plnt.draw.ringex:=false;
 
 if plnt.draw.rng<>nil then dispose(plnt.draw.rng);
 plnt.draw.hazmsh.grc:=0;

 free_op(@plnt.draw.clds);
 free_op(@plnt.draw.grnd);
 free_op(@plnt.draw.lgts);

 {$ifdef orulex}
 if plnt.draw.dynpl<>nil then begin
  clrpls(plnt.draw.dynpl);
  dispose(plnt.draw.dynpl);
 end;
 plnt.draw.dynpl:=nil;
 {$endif}
                            
 if plnt.draw.atm then dispose(plnt.draw.haze);
 dispose(plnt.draw);
 dispose(plnt);
end;              
//############################################################################//
procedure oglaclr_smob(var smob:poglas_smob); 
begin
 //More...
 if smob=nil then exit;
 dispose(smob.draw);
 dispose(smob);
end;    
//############################################################################//
//############################################################################//
procedure oglaset_star(star:poglas_star;name:string;ob:intptr;pos:vec;r:double;col:crgba);stdcall;
begin        
 if star=nil then exit;
 star.name:=name;
 star.obj:=ob;
 star.pos:=pos;
 star.rad:=r;
 star.msh:=@starmsh;
 star.col:=col;
end;   
//############################################################################//
procedure oglaset_plntbase(scn:poglascene;plnt:poglas_planet;name:string;ob:intptr;pos,rot:vec;r:double;atm:boolean);stdcall;
const clnam='                                                                ';
begin   
 if plnt=nil then exit;  
 plnt.name:=clnam;      
 plnt.name:=name;     
 plnt.obj:=ob;
 plnt.pos:=pos;
 plnt.rot:=rot;
 plnt.rad:=r;
 plnt.rrad:=r;  
              
 if plnt.draw=nil then exit;  
 zero_op(@plnt.draw.grnd);
 zero_op(@plnt.draw.clds);
 zero_op(@plnt.draw.lgts);        
       
 plnt.draw.maxdist:=max2(max_surf_dist+plnt.rad,max_centre_dist);
 plnt.draw.dist_scale:=1;  
 plnt.draw.nrst:=false;
 plnt.draw.ringex:=false;
 plnt.draw.rng:=nil; 
 plnt.draw.dtn:=0;    
 plnt.draw.haze:=nil;
 plnt.draw.hazmsh.grc:=0; 
 plnt.draw.atm:=atm;
 plnt.draw.cloudrot:=0;
 
 {$ifdef orulex}
 if plnt.draw.dynpl<>nil then begin
  clrpls(plnt.draw.dynpl);
  dispose(plnt.draw.dynpl);
 end;
 plnt.draw.dynpl:=nil;
 {$endif}
 
 plnt.draw.gen:=false;
 plnt.draw.genused:=false;

 if plnt.draw.atm then begin
  new(plnt.draw.haze);
  oglamk_haze(scn,plnt.draw.haze,plnt.rad,plnt.name);  
 end;
end;
//############################################################################//
procedure oglaset_plntatm(plnt:poglas_planet;atmrho,atmrho0,atmradlimit:double;atmcolor0:crgbad);stdcall;
begin   
 if plnt=nil then exit;
 plnt.draw.atm:=true;
 plnt.draw.atmrho:=atmrho;
 plnt.draw.atmrho0:=atmrho0;
 plnt.draw.atmradlimit:=atmradlimit;
 plnt.draw.atmcolor0:=atmcolor0; 
end;  
//############################################################################//
procedure oglaset_plntring(plnt:poglas_planet;ringmin,ringmax:double);stdcall;
begin    
 if plnt=nil then exit;
 plnt.draw.ringex:=true;
 
 plnt.draw.ringmin:=ringmin;
 plnt.draw.ringmax:=ringmax;
 
 plnt.draw.ringtx[0]:=notx; 
 plnt.draw.ringtx[1]:=notx; 
 plnt.draw.ringtx[2]:=notx; 
   
 plnt.rrad:=plnt.rad*ringmax;
end;       
//############################################################################//
//############################################################################// 
function get_free_smob(scn:poglascene):integer;
var i:integer;
begin
 result:=-1;
 for i:=0 to length(scn.smobs)-1 do if scn.smobs[i]=nil then begin result:=i;exit;end;
 if result=-1 then begin   
  result:=length(scn.smobs);
  setlength(scn.smobs,result*2+1);
  for i:=result to result*2+1-1 do scn.smobs[i]:=nil;
 end;
end;
//############################################################################// 
function get_smob_by_ob(scn:poglascene;ob:pointer):integer;
var i:integer;
begin
 result:=-1;
 for i:=0 to length(scn.smobs)-1 do if scn.smobs[i]<>nil then if scn.smobs[i].ob=ob then begin result:=i;exit;end;
end;
//############################################################################// 
function get_smob_by_id(scn:poglascene;id:dword):integer;
var i:integer;
begin
 result:=-1;
 for i:=0 to length(scn.smobs)-1 do if scn.smobs[i]<>nil then if scn.smobs[i].id=id then begin result:=i;exit;end;
end;
//############################################################################// 
procedure oglamk_haze(scn:poglascene;h:poplhazetyp;s:double;n:string);stdcall;
var p:pointer;
x,y:integer;
begin try
 h.rad:=s; 
 h.tx:=dhtx;
 if fileexists(scn.sys.texdir+'/'+n+'_Horizon.dds') then begin
  LoadBitmap(scn.sys.texdir+'/'+n+'_Horizon.dds',x,y,p);
  glgr_make_tex(h.tx,x,y,p,scn.feat.tx_compress,scn.feat.tx_smooth,false,false);
 end; 
 except stderr('ORBGL','Error in mkhaze'); end; 
end;
//############################################################################// 
//############################################################################//
procedure mk_star_texture(var tx:cardinal;sz:integer); 
var d,r,f,q,qr,pr:double;  
p:pointer;
x,y,xp,yp,sz2:integer;
begin  
 q:=1-pow(0.6,0.23);
 sz2:=sz div 2;
 getmem(p,sz*sz*4); 
 for y:=0 to sz-1 do begin
  for x:=0 to sz-1 do begin
   xp:=sz2-x;
   yp:=sz2-y;  
   r:=sqrt(sqr(xp)+sqr(yp))/sz2;
   if r=0 then r:=0.001;
   d:=1-pow(r,0.23);  
   if r<=0.6 then d:=(d-q)*2+q;
   if r=0 then d:=1;
   if d>1 then d:=1;
   if d<0 then d:=0;
           
   f:=arctan2(xp,yp);      
   qr:=0.2+(sqr(sin(f*pi*2.2))/2+0.5)*0.1;
   if r<qr then d:=d*((qr/r-1)*0.5+1); 
   if d>1 then d:=1;if d<0 then d:=0;   
                  
   pr:=perlintf(@defnoi,tvec(f,1000,1000),0.1,4,evec)/2+0.5;
   qr:=0.2+(sqr(sin(f*pi*5))/2+0.5)*0.8*ord(pr<0.45);
   if r<qr then d:=d*((qr/r-1)*0.1+1); 
   if d>1 then d:=1;if d<0 then d:=0;   
   pcrgba(intptr(p)+intptr((x+y*sz)*4))^:=tcrgba(255,255,255,round(d*255));
  end;
 end;
 smootfilter(p,sz,sz);
 glgr_make_tex(tx,sz,sz,p,true,true,true,false);    
 freemem(p); 
end;
//############################################################################// 
//############################################################################//
procedure mk_starhalo_texture(var tx:cardinal;sz:integer); 
var d,r,q:double;  
p:pointer;
x,y,xp,yp,sz2:integer;
begin  
 q:=1-pow(0.6,0.23);
 sz2:=sz div 2;
 getmem(p,sz*sz*4); 
 for y:=0 to sz-1 do begin
  for x:=0 to sz-1 do begin
   xp:=sz2-x;
   yp:=sz2-y;  
   r:=sqrt(sqr(xp)+sqr(yp))/sz2;
   if r=0 then r:=0.001;
   d:=1-pow(r,0.23);  
   if r<=0.6 then d:=(d-q)*2+q;
   if r=0 then d:=1;
   if d>1 then d:=1;
   if d<0 then d:=0;

   pcrgba(intptr(p)+intptr((x+y*sz)*4))^:=tcrgba(255,255,255,round(d*128));
  end;
 end;
 smootfilter(p,sz,sz);
 glgr_make_tex(tx,sz,sz,p,true,true,true,false);    
 freemem(p); 
end;
//############################################################################// 
//############################################################################//
procedure mk_nebula_texture(var tx:cardinal;sz:integer); 
var d,r,f,q,pr,l:double;  
p:pointer;
i,x,y,xp,yp,sz2:integer;
sts:array of vec2;
cl,cl1:crgba;
begin          
 sz2:=sz div 2;
 lrndseed:=1;
 setlength(sts,5);
 for i:=0 to length(sts)-1 do begin
  sts[i]:=tvec2(sz2 div 2+lrandom(sz2),sz2 div 2+lrandom(sz2));
  xp:=round(sz2-sts[i].x);
  yp:=round(sz2-sts[i].y);  
  q:=sqrt(sqr(1.5*xp)+sqr(yp))/sz2;
  if q>0.2 then sts[i]:=addv(nmulv(subv(sts[i],tvec2(sz2,sz2)),0.5),tvec2(sz2,sz2));
 end;
 getmem(p,sz*sz*4);
 for y:=0 to sz-1 do begin
  for x:=0 to sz-1 do begin
   pr:=perlintf(@defnoi,tvec(x,y,1000),70,9,evec)/4+0.75;
   d:= perlintf(@defnoi,tvec(x,y,2000),70,9,evec)/2+0.5;
   r:= perlintf(@defnoi,tvec(x,y,3000),70,9,evec)/2+0.5;
   f:= perlintf(@defnoi,tvec(x,y,4000),70,9,evec)/2+0.5;  
   
   xp:=sz2-x;
   yp:=sz2-y;  
   q:=sqrt(sqr(1.5*xp)+sqr(yp))/sz2;
   if q=0 then q:=0;
   if q>1 then q:=1;
   q:=1-q;
   cl:=tcrgba(round(d*255),round(r*255),round(f*255),round(q*pr*255));
   for i:=0 to length(sts)-1 do begin
    l:=(sqrt(abs(sts[i].x-x))+sqrt(abs(sts[i].y-y)))*2;
    if l<10 then begin
     if l<5 then begin
      cl1[0]:=round(255*(1-l/5));
      cl1[1]:=round(255*(1-l/5));
     end else begin       
      cl1[0]:=0;
      cl1[1]:=0;
     end;
     cl1[2]:=round(255*(1-l/10));
     cl1[3]:=round(255*(1-l/10));
     if cl1[0]+cl[0]>255 then cl[0]:=255 else cl[0]:=cl1[0]+cl[0];
     if cl1[1]+cl[1]>255 then cl[1]:=255 else cl[1]:=cl1[1]+cl[1];
     if cl1[2]+cl[2]>255 then cl[2]:=255 else cl[2]:=cl1[2]+cl[2];
     if cl1[3]+cl[3]>255 then cl[3]:=255 else cl[3]:=cl1[3]+cl[3];
    end;
   end;
   pcrgba(intptr(p)+intptr((x+y*sz)*4))^:=cl;
  end;
 end; 
 //smootfilter(p,sz,sz);
 glgr_make_tex(tx,sz,sz,p,true,true,true,false);    
 freemem(p); 
end;
//############################################################################// 
//############################################################################//
procedure mk_gal_texture(var tx:cardinal;sz:integer); 
var d,r,pr:double;  
p:pointer;
x,y,xp,yp,sz2,i:integer;
begin  
 sz2:=sz div 2;
 getmem(p,sz*sz*4); 
 for y:=0 to sz-1 do begin
  for x:=0 to sz-1 do begin
   xp:=sz2-x;
   yp:=sz2-y;  
   r:=sqrt(sqr(xp)+sqr(yp))/sz2;  
     
   pr:=perlintf(@defnoi,tvec(xp,yp,1000),15,4,evec);
   d:=0;
   for i:=0 to 8 do d:=d+(0.05+0.015*i)*ord(r<(0.9-i*0.09)*(pr*(0.2+i*0.1)+1));

   pcrgba(intptr(p)+intptr((x+y*sz)*4))^:=tcrgba(255,255,255,round(d*255));
  end;
 end;
 smootfilter(p,sz,sz);
 glgr_make_tex(tx,sz,sz,p,true,true,true,false);    
 freemem(p); 
end;
//############################################################################// 
//############################################################################//
procedure mk_ring_texture(var tx:cardinal;sz,n:integer); 
var p:pointer;
x,y,i,k:integer;   
r:double;    
cl:crgba;  
ccc:array of noirgradpoint; 
begin
 getmem(p,256*256*4); 

 if n=0 then begin
  setlength(ccc,21);  
  ccc[ 0].cl:=tdcrgba(107/255,105/255, 99/255,0.0);ccc[ 0].pos:=0;
  ccc[ 1].cl:=tdcrgba(198/255,186/255,156/255,0.7);ccc[ 1].pos:=0.05;
  ccc[ 2].cl:=tdcrgba(107/255,105/255, 99/255,0.9);ccc[ 2].pos:=0.1;
  ccc[ 3].cl:=tdcrgba(225/255,211/255,162/255,0.9);ccc[ 3].pos:=0.15;
  ccc[ 4].cl:=tdcrgba(222/255,205/255,140/255,0.7);ccc[ 4].pos:=0.2;
  ccc[ 5].cl:=tdcrgba(198/255,186/255,156/255,0.7);ccc[ 5].pos:=0.25;
  ccc[ 6].cl:=tdcrgba(211/255,196/255,153/255,0.3);ccc[ 6].pos:=0.3;
  ccc[ 7].cl:=tdcrgba(206/255,207/255,181/255,0.8);ccc[ 7].pos:=0.35;
  ccc[ 8].cl:=tdcrgba(132/255,132/255,132/255,0.6);ccc[ 8].pos:=0.4;
  ccc[ 9].cl:=tdcrgba(140/255,134/255,115/255,0.4);ccc[ 9].pos:=0.45;
  ccc[10].cl:=tdcrgba(198/255,186/255,156/255,0.7);ccc[10].pos:=0.5;
  ccc[11].cl:=tdcrgba(211/255,196/255,153/255,0.3);ccc[11].pos:=0.55;
  ccc[12].cl:=tdcrgba(231/255,222/255,214/255,0.8);ccc[12].pos:=0.6;
  ccc[13].cl:=tdcrgba(225/255,211/255,162/255,0.9);ccc[13].pos:=0.65;
  ccc[14].cl:=tdcrgba(222/255,205/255,140/255,0.7);ccc[14].pos:=0.7;
  ccc[15].cl:=tdcrgba(231/255,222/255,214/255,0.8);ccc[15].pos:=0.75;
  ccc[16].cl:=tdcrgba(206/255,207/255,181/255,0.8);ccc[16].pos:=0.8;
  ccc[17].cl:=tdcrgba(107/255,105/255, 99/255,0.9);ccc[17].pos:=0.85;
  ccc[18].cl:=tdcrgba(132/255,132/255,132/255,0.6);ccc[18].pos:=0.9;
  ccc[19].cl:=tdcrgba(140/255,134/255,115/255,0.4);ccc[19].pos:=0.95;
  ccc[20].cl:=tdcrgba(107/255,105/255, 99/255,0.0);ccc[20].pos:=1;
 end else begin
  setlength(ccc,11);  
  ccc[ 0].cl:=tdcrgba(107/255,105/255, 99/255,0.0);ccc[ 0].pos:=0;
  ccc[ 6].cl:=tdcrgba(198/255,186/255,156/255,0.7);ccc[ 6].pos:=0.6;
  ccc[ 4].cl:=tdcrgba(231/255,222/255,214/255,0.8);ccc[ 4].pos:=0.4;
  ccc[ 5].cl:=tdcrgba(225/255,211/255,162/255,0.9);ccc[ 5].pos:=0.5;
  ccc[ 7].cl:=tdcrgba(222/255,205/255,140/255,0.7);ccc[ 7].pos:=0.7;
  ccc[ 2].cl:=tdcrgba(206/255,207/255,181/255,0.8);ccc[ 2].pos:=0.2;
  ccc[ 1].cl:=tdcrgba(211/255,196/255,153/255,0.3);ccc[ 1].pos:=0.1;
  ccc[ 3].cl:=tdcrgba(107/255,105/255, 99/255,0.9);ccc[ 3].pos:=0.3;
  ccc[ 8].cl:=tdcrgba(132/255,132/255,132/255,0.6);ccc[ 8].pos:=0.8;
  ccc[ 9].cl:=tdcrgba(140/255,134/255,115/255,0.4);ccc[ 9].pos:=0.9;
  ccc[10].cl:=tdcrgba(107/255,105/255, 99/255,0.0);ccc[10].pos:=1;
 end;
 
 i:=600;k:=230;
 for y:=0 to 255 do for x:=0 to 255 do begin     
  r:=sqrt(sqr(x-128)+sqr(y-i)); 
  r:=(r-i+k)/k;
  if r>1 then r:=-1; 
  if r>0 then begin
   cl:=gradientcf(0,r,ccc); 
  end else cl:=gclaz;
  
  pcrgba(intptr(p)+intptr((x+y*256)*4))^:=cl;
 end;
 glgr_make_tex(tx,256,256,p,true,true,true,true);    
 getmem(defrng[n],256*256*4);
 move(p^,defrng[n]^,256*256*4);
 freemem(p);
end;
//############################################################################// 
//############################################################################//
procedure oglainit_graph(scn:poglascene);
var p:pointer;
x,y:integer;
i:integer;
b:byte;      
cl:crgba; 
begin        
 scn.axes_cnt:=0;
 setlength(scn.axes,0);
 //scn.axes[0]:=-1;scn.axes[1]:=-1;scn.axes[2]:=-1;
  
 {$ifdef OGLADBG}AllocConsole;writeln('OGLA '+oglaver+' Debug.');{$else}wr_log('OGLADBG','OGLA '+oglaver+' Debug.');{$endif}
 oglaset_shaders(scn);    
 initps;

 //Sky
 scn.drsky:=true;
 scn.fixedsky:=false;
 scn.fixedsky_done:=false;
 if not gl_14_fbo_sup then begin
  i:=min2i(scn.sys.gwin.wid,scn.sys.gwin.hei);
  if i<128 then i:=64 else
  if i<256 then i:=128 else
  if i<512 then i:=256 else
  if i<1024 then i:=512 else
  if i<2048 then i:=1024 else
  if i<4096 then i:=2048 else
  if i<8192 then i:=4096;
  if scn.feat.fxsky_res>dword(i) then scn.feat.fxsky_res:=i;
 end;
 if scn.feat.fxsky then for i:=0 to 6 do glgr_makeblank_tex(scn.fxsky_tx[i],scn.feat.fxsky_res,scn.feat.fxsky_res,false,true,false);
 if gl_14_fbo_sup then glGenFramebuffersext(1,@scn.fxsky_fbo);  
 
 if gl_14_fbo_sup then begin
  glGenFramebuffersext(1,@scn.screen_fbo);  
  glgr_makeblank_tex(scn.screen_tx,scn.wid,scn.hei,false,true,false);
  glGenRenderbuffersEXT(1,@scn.screen_depth_fbo);
  glBindRenderbufferEXT(GL_RENDERBUFFER_EXT,scn.screen_depth_fbo);
  glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT,GL_DEPTH_COMPONENT24_ARB,scn.wid,scn.hei);  
    
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,scn.screen_fbo);
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,scn.screen_tx,0);
  glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,GL_DEPTH_ATTACHMENT_EXT,GL_RENDERBUFFER_EXT,scn.screen_depth_fbo);     
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);
 end else scn.screen_fbo:=0;

 //Shadow texture
 glgr_makeblank_tex(shscr,scn.sys.gwin.wid div 4,scn.sys.gwin.hei div 4,false,true,false);    
 glgr_makeblank_tex(nebscr,256,256,false,true,false);    
 glgr_setshmap(shmtex,scn.feat.shmres);  
 
 glgr_makeblank_tex(haztxz,scn.sys.gwin.wid,scn.sys.gwin.hei,false,true,false);    
 glgr_setshmap(haztxz,scn.sys.gwin.wid,scn.sys.gwin.hei);   

 //Noise texture
 getmem(p,256*256*4);   
 for y:=0 to 255 do for x:=0 to 255 do begin
  b:=192+random(255) div 4;
  pcrgba(intptr(p)+intptr(x+y*256)*4)^:=tcrgba(b,b,b,b);
 end;
 glgr_make_tex(noitx,256,256,p,true,true,true,false);    
 freemem(p); 
 
 //Horizon texture
 getmem(p,128*128*4);    
 for y:=0 to 127 do begin
  cl:=tcrgba(255,255,255,255*ord(y>123)+ord(y<=123)*round(245*sqr(y/123)));
  //if cl[3]=5 then cl[3]:=y;
  for x:=0 to 127 do pcrgba(intptr(p)+intptr((x+y*128)*4))^:=cl;
 end;
 glgr_make_tex(dhtx,128,128,p,true,true,false,false);    
 freemem(p); 
 
 //Rings
 mk_ring_texture(defrngtx1,256,0);
 mk_ring_texture(defrngtx2,256,1);
   
 //Star texture & mesh
 setlength(starmsh.grp,2);starmsh.grc:=2;starmsh.used:=true;
 starmsh.grp[0].col:=tcrgba(255,255,255,255);
 starmsh.grp[1].col:=tcrgba(255,255,255,255);
 mk_star_texture(starmsh.grp[0].dif.tx,256);
 mk_starhalo_texture(starmsh.grp[1].dif.tx,256);
 //mk_nebula_texture(starmsh.grp[0].dif.tx,512);
 mk_pln(@starmsh.grp[0],16,16);
 mk_pln(@starmsh.grp[1],16,16);
 starmsh.grp[0].static:=true;
 starmsh.grp[1].static:=true;
               
 //Galaxy texture & mesh
 mk_gal_texture(gals_tx,256);  
 
 //Exhaust texture
 getmem(p,256*256*4);
 LoadBitmap(scn.sys.texdir+'/Exhaust.dds',x,y,p);
 glgr_make_tex(defexhausttex,x,y,p,scn.feat.tx_compress,scn.feat.tx_smooth,true,false);
 freemem(p);
 
  //Camera resolution, texture
 glgr_makeblank_tex(cmtx,scn.feat.cmtres,scn.feat.cmtres,false,true,false);  

 glgr_makeblank_tex(shscr,scn.sys.gwin.wid div 4,scn.sys.gwin.hei div 4,false,true,false);  
 glgr_setshmap(shmtex,scn.feat.shmres);     

 //Deres texture 
 glgr_makeblank_tex(scn.itx,2048,2048,false,true,false); 
end;  

//############################################################################//

//############################################################################//
procedure ogla_loadscene(scn:poglascene;fn:string);
type str64=string[64];
var f:file;
x:dword;
i:integer;
iss_m:ptypmsh;

function readvec:vec;begin blockread(f,result,sizeof(vec));end;
function readdbl:double;begin blockread(f,result,8);end;        
function readdword:dword;begin blockread(f,result,4);end;        
function readmat:mat;begin blockread(f,result,sizeof(mat));end;  
function readbool:boolean;begin blockread(f,result,sizeof(boolean));end;
function readstr64:str64;begin blockread(f,result,sizeof(str64));end;
function readcrgbad:crgbad;begin blockread(f,result,sizeof(crgbad));end;
function readcrgba:crgba;begin blockread(f,result,sizeof(crgba));end;

begin
 new(iss_m);
 //iss_m:=nil;
 {$ifndef fpc}loadmsh(iss_m,'meshes/ProjectAlpha_ISS.msh','textures\');{$endif} 
 glgr_fintex(iss_m,scn.feat.tx_mipmap);
 //iss_m:=nil;

 assignfile(f,fn);
 reset(f,1);

 //Main
 if readdword<>$04030201 then exit;

 {$ifdef orulex}ogla_saferegraph;{$endif}
  
 blockread(f,scn.cam.pos,sizeof(vec));
 blockread(f,scn.cam.dir,sizeof(vec));
 blockread(f,scn.cam.rot,sizeof(vec));
 blockread(f,scn.cam.tgt,sizeof(vec));  
 blockread(f,scn.cam.rtmat,sizeof(mat));
 brtmat[1]:=scn.cam.rtmat;
 rtcur:=1;
 scn.cam.mode:=1;
 scn.cam.rtmat:=emat;
 scn.cam.brtmat:=@brtmat[rtcur];
 rotcam(scn.cam,0,0);

 
 //Stars             
 setlength(scn.star,readdword);  
 for i:=0 to length(scn.star)-1 do begin new(scn.star[i]);oglaset_star(scn.star[i],readstr64,readdword,readvec,readdbl,readcrgba);end;    

 
 //Galaxys 
 setlength(scn.nebs,0);
 scn.nebcnt:=0;
      

 //Planets     
 setlength(scn.plnt,readdword); 
 setlength(oplbuf,length(scn.plnt));
 setlength(opldsbuf,length(scn.plnt));   
 for i:=0 to length(scn.plnt)-1 do begin
  new(scn.plnt[i]);   
  new(scn.plnt[i].draw);
  
  oglaset_plntbase(scn,scn.plnt[i],readstr64,readdword,readvec,readvec,readdbl,readbool);
  if scn.plnt[i].draw.atm then oglaset_plntatm(scn.plnt[i],readdbl,readdbl,readdbl,readcrgbad);
  
  scn.plnt[i].draw.ringex:=readbool;
  if scn.plnt[i].draw.ringex then oglaset_plntring(scn.plnt[i],readdbl,readdbl);
  
  if readdword=1 then begin 
   blockread(f,scn.plnt[i].draw.haze.basecol,sizeof(crgbad));
   blockread(f,scn.plnt[i].draw.haze.hralt,8);
   blockread(f,scn.plnt[i].draw.haze.dens0,8);
  
   blockread(f,scn.plnt[i].draw.haze.hshift,8);
   blockread(f,scn.plnt[i].draw.haze.cloudalt,8);
   blockread(f,scn.plnt[i].draw.haze.hscale,8);
   blockread(f,scn.plnt[i].draw.haze.hasclouds,sizeof(scn.plnt[i].draw.haze.hasclouds));
  end;
  //updoplanet(scn,scn.plnt[i]);      
  //updoplanetcl(scn,scn.plnt[i]);
 end;


 //Vessels & bases
 setlength(scn.smobs,readdword);    
 for i:=0 to length(scn.smobs)-1 do begin           
  blockread(f,x,4);   
  if x<>1221 then begin scn.smobs[i]:=nil;continue;end;
  new(scn.smobs[i]);
  blockread(f,scn.smobs[i].tp,4);
  blockread(f,scn.smobs[i].pos,sizeof(vec));
  blockread(f,scn.smobs[i].rot,sizeof(vec));
  blockread(f,scn.smobs[i].rad,8);
  blockread(f,scn.smobs[i].ob,4);
  
  blockread(f,scn.smobs[i].name,sizeof(scn.smobs[i].name));  
  new(scn.smobs[i].draw);
  scn.smobs[i].draw.nmesh:=1;
  setlength(scn.smobs[i].draw.mshs,1);
  setlength(scn.smobs[i].draw.mshv,1);
  scn.smobs[i].draw.mshv[0]:=MESHVIS_EXTERNAL;
  scn.smobs[i].draw.mshs[0]:=iss_m;
  
  scn.smobs[i].draw.drmsh:=true;
  scn.smobs[i].draw.apr:=10;    

  scn.smobs[i].draw.anim:=nil;
  scn.smobs[i].draw.nanim:=0;  
   
  scn.smobs[i].draw.cp:=false;
   
  scn.smobs[i].draw.lt0:=tquat(1,1,1,1);
 end;
 
 closefile(f);
end;
//############################################################################//
procedure ogla_savescene(scn:poglascene;fn:string);
var f:file;
var d,x:dword;
i:integer;
begin
 assignfile(f,fn);
 rewrite(f,1);


 //Basics
 d:=$04030201;
 blockwrite(f,d,4);

 blockwrite(f,scn.cam.pos,sizeof(vec));
 blockwrite(f,scn.cam.dir,sizeof(vec));
 blockwrite(f,scn.cam.rot,sizeof(vec));
 blockwrite(f,scn.cam.tgt,sizeof(vec));
 blockwrite(f,scn.cam.rtmat,sizeof(mat));
 scn.cam.brtmat:=@scn.cam.rtmat;
   

   
 //Stars
 d:=length(scn.star);  
 blockwrite(f,d,4);
 for i:=0 to d-1 do begin
  blockwrite(f,scn.star[i].col,sizeof(crgba));
  blockwrite(f,scn.star[i].rad,8);
  blockwrite(f,scn.star[i].pos,sizeof(vec));
  blockwrite(f,scn.star[i].obj,4);
  blockwrite(f,scn.star[i].name,sizeof(scn.star[i].name));
 end;

 
 //Planets          
 d:=length(scn.plnt);  
 blockwrite(f,d,4);
 for i:=0 to d-1 do begin       
  blockwrite(f,scn.plnt[i].draw.atm,sizeof(boolean)); 
  blockwrite(f,scn.plnt[i].rad,8);                   
  blockwrite(f,scn.plnt[i].rot,sizeof(vec));   
  blockwrite(f,scn.plnt[i].pos,sizeof(vec));         
  blockwrite(f,scn.plnt[i].obj,4);
  blockwrite(f,scn.plnt[i].name,sizeof(scn.plnt[i].name)); 

  if scn.plnt[i].draw.atm then begin 
   blockwrite(f,scn.plnt[i].draw.atmrho,8);        
   blockwrite(f,scn.plnt[i].draw.atmrho0,8);  
   blockwrite(f,scn.plnt[i].draw.atmradlimit,8); 
   blockwrite(f,scn.plnt[i].draw.atmcolor0,sizeof(crgbad));  
  end;

  blockwrite(f,scn.plnt[i].draw.ringex,sizeof(boolean));
  if scn.plnt[i].draw.ringex then begin    
   blockwrite(f,scn.plnt[i].draw.ringmax,8);
   blockwrite(f,scn.plnt[i].draw.ringmin,8);
  end;

  if scn.plnt[i].draw.atm then begin  
   d:=1;  
   blockwrite(f,d,4);
   blockwrite(f,scn.plnt[i].draw.haze.basecol,sizeof(crgbad));
   blockwrite(f,scn.plnt[i].draw.haze.hralt,8);
   blockwrite(f,scn.plnt[i].draw.haze.dens0,8);
  
   blockwrite(f,scn.plnt[i].draw.haze.hshift,8);
   blockwrite(f,scn.plnt[i].draw.haze.cloudalt,8);
   blockwrite(f,scn.plnt[i].draw.haze.hscale,8);
   blockwrite(f,scn.plnt[i].draw.haze.hasclouds,sizeof(scn.plnt[i].draw.haze.hasclouds));
  end else begin
   d:=0;  
   blockwrite(f,d,4);
  end;
 end;
 

 //Vessels & bases
 d:=length(scn.smobs);  
 blockwrite(f,d,4);
 for i:=0 to d-1 do if scn.smobs[i]<>nil then begin
  x:=1221;      
  blockwrite(f,x,4);    
  blockwrite(f,scn.smobs[i].tp,4);
  blockwrite(f,scn.smobs[i].pos,sizeof(vec));
  blockwrite(f,scn.smobs[i].rot,sizeof(vec));
  blockwrite(f,scn.smobs[i].rad,8);
  blockwrite(f,scn.smobs[i].ob,4);
  
  blockwrite(f,scn.smobs[i].name,sizeof(scn.smobs[i].name));
 end else begin x:=0; blockwrite(f,x,4);end;
 
 closefile(f);
end;                
//############################################################################// 
function ogla_cmdinput(scn:poglascene;op:integer;key:word;shift:byte):boolean;
begin   
 result:=false;
 if scn.cmdmod then begin
  case key of 
   27:scn.cmdmod:=false;     //Esc
   49:scn.feat.camera2:=not scn.feat.camera2;  //1
   50:begin scn.feat.multilight:=not scn.feat.multilight;oglaset_shaders(scn);end;  //2  
   51:usevbo:=not usevbo;  //3 
   52:scn.drsky:=not scn.drsky;//4  
   53:scn.feat.orulex:=not scn.feat.orulex; //5                   
   54:begin scn.feat.advatm:=not scn.feat.advatm;if scn.feat.rayleigh then scn.feat.rayleigh:=false; oglaset_shaders(scn);end; //6 
   55:begin scn.feat.shres:=scn.feat.shres+1;if(scn.feat.shres>4)and(scn.feat.shadows)then oglaset_shaders(scn);end;  //7
   56:begin scn.feat.mlight_terrain:=not scn.feat.mlight_terrain;oglaset_shaders(scn);end;  //8   
   57:begin scn.feat.rayleigh:=not scn.feat.rayleigh;if scn.feat.advatm then scn.feat.advatm:=false; oglaset_shaders(scn);end; //9
   192:begin gvsync:=not gvsync; glgr_vsync(gvsync); end;  //~
   //{$ifdef orulex}80:orutes:=not orutes;{$endif}  //P
   85:begin scn.feat.advanced:=not scn.feat.advanced;oglaset_shaders(scn);end;  //U
   77:scn.feat.wireframe:=not scn.feat.wireframe;  //M
   80:scn.feat.postplane:=not scn.feat.postplane;  //P
   76:scn.feat.camera_light:=not scn.feat.camera_light;  //L
   
   83:ogla_savescene(@scn,'scn.oglascn');    //S
  end;
  if scn.feat.rayleigh then if not fileexists('textures\inscatter.bin')then begin
   scn.feat.rayleigh:=false;
   wr_log('RNDR','Warning: Raytraced haze requested, but no tables found. Run scatter_gen.exe.'); 
  end;
 
  if scn.feat.shres>5 then scn.feat.shres:=0;
  scn.cmdmod:=false;
  result:=true;
  exit;
 end;
 if key=scn.cmdmkey then if shift=0 then scn.cmdmod:=not scn.cmdmod; //F-X
 if key=scn.scrskey then if shift=2 then glgr_screenshot(scn.sys.gwin);   //Ctrl+V 
end;  
//############################################################################//
procedure ogla_render_own_info(scn:poglascene;auxinfo:boolean);
var s:string;
gx,gy,i:integer;
cl_tx:crgba;
begin    
 cl_tx:=tcrgba(200,200,200,255);

 //putcsqr2D(gwin.wid-197,-3,200,40,4,tcrgba(0,0,0,64),tcrgba(200,200,200,255));  
 
 if auxinfo then begin    
  if msg_tim=-1 then begin
   msg_tim:=getdt;
   stdt(msg_tim);
  end;
  if rtdt(msg_tim)<5000000 then begin
   //if scn.feat.multilight then wrtxtcnt2d('Multilight on ('+scn.cmdmpref+'-2 toggle)',1,scn.sys.gwin.wid div 2,50,cl_tx);
   if not vboav then wrtxtcnt2d('VBO not available. Running unaccelerated.',1,scn.sys.gwin.wid div 2,70,cl_tx);  
   if (not usevbo)and vboav then wrtxtcnt2d('VBO off. Running unaccelerated. ('+scn.cmdmpref+'-3 toggle)',1,scn.sys.gwin.wid div 2,70,cl_tx);
  end;
 end;

 //Options menu
 gx:=scn.sys.gwin.wid-210;gy:=scn.sys.gwin.hei div 2-200;
 if scn.cmdmod then begin
  //putcsqr2D(gx,gy,200,400,4,gclblack,gclgreen);    
  putcsqr2D(gx,gy,200,400,4,tcrgba(0,0,0,128),tcrgba(200,200,200,255));
  
  wrtxtcnt2d('Features:',1,gx+100,gy+10,cl_tx);
  
  i:=0;      
  wrtxt2d(scn.cmdmpref+'-1 Second camera',1,gx+5,gy+30+i*20,cl_tx);if scn.feat.camera2    then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-2 Multilight'   ,1,gx+5,gy+30+i*20,cl_tx);if scn.feat.multilight then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;  
  wrtxt2d(scn.cmdmpref+'-3 VBO accel'    ,1,gx+5,gy+30+i*20,cl_tx);if usevbo              then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;  
  wrtxt2d(scn.cmdmpref+'-4 Draw sky'     ,1,gx+5,gy+30+i*20,cl_tx);if scn.drsky           then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-5 Terrain'      ,1,gx+5,gy+30+i*20,cl_tx);if scn.feat.orulex     then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-6 Air shade'    ,1,gx+5,gy+30+i*20,cl_tx);if scn.feat.advatm     then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  
  if not scn.feat.shadows then s:='Off' else case scn.feat.shres of
   0:s:='Off';
   1:s:='VLow';
   2:s:='Low';
   3:s:='Medium';
   4:s:='High';
   5:s:='Mapped';
   else s:='ERR';
  end;
  wrtxt2d(scn.cmdmpref+'-7 Shadows'                ,1,gx+5,gy+30+i*20,cl_tx);wrtxt2d(s,1,gx+198-length(s)*8,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-8 Multilight terrain'     ,1,gx+5,gy+30+i*20,cl_tx);if scn.feat.mlight_terrain then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-9 Raytraced air'          ,1,gx+5,gy+30+i*20,cl_tx);if scn.feat.rayleigh       then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-~ Vsync'                  ,1,gx+5,gy+30+i*20,cl_tx);if gvsync                  then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-U Advanced grp'           ,1,gx+5,gy+30+i*20,cl_tx);if scn.feat.advanced       then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-M Wireframe'              ,1,gx+5,gy+30+i*20,cl_tx);if scn.feat.wireframe      then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-L Camera light'           ,1,gx+5,gy+30+i*20,cl_tx);if scn.feat.camera_light   then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d(scn.cmdmpref+'-S Save scene to file'     ,1,gx+5,gy+30+i*20,cl_tx);i:=i+1;
  wrtxt2d('Ctrl+'+scn.scrskeynam+' Take screenshot',1,gx+5,gy+30+i*20,cl_tx);
 end;
end;       
//############################################################################//
procedure ogla_thr_term;
begin
{$ifdef orulex}
 gentexthr_term:=true;        
 while(gentexthr_running and gentexthr_term)do;
 gentexthr_term:=false;
{$endif}
end;       
//############################################################################//
procedure ogla_clrinit_scene(scn:poglascene);
begin
 scn.feat.tx_smooth:=true;
 scn.feat.tx_compress:=true;
 scn.feat.tx_mipmap:=true;
 scn.feat.shadows:=true;
 scn.feat.mlight_terrain:=false;
 scn.feat.orulex:=false;
 scn.feat.camera2:=false;
 scn.feat.multilight:=false;
 scn.feat.advanced:=false;
 scn.feat.advatm:=true;
 scn.feat.shres:=4; //0=off, 1=projective, 2=low-res, 3=med-res, 4=hi-res, 5=mapped
 scn.feat.orures:=0; 
 scn.feat.drwm:=0;  
 scn.feat.shmres:=512;  
 scn.feat.cmtres:=256;       
 scn.feat.autores:=false;
 scn.feat.fxsky:=true;
 scn.feat.fxsky_res:=1024;   
 scn.feat.wireframe:=false;
 scn.feat.clouds:=true;
 scn.feat.cloudshadows:=true;
 scn.feat.max_plnt_lv:=14;    
 scn.feat.camera_light:=false;
 scn.feat.postplane:=false;
 scn.feat.projection:=0;
 scn.feat.starlight_colored:=true;
 scn.feat.stereo:=false;
 scn.feat.rayleigh:=false;
 scn.feat.angl_dist:=0.5;

 scn.cmdmod:=false;
 scn.cmdmkey:=122;
 {$ifdef linux}scn.cmdmkey:=139;{$endif}
 scn.cmdmpref:='F11';
 scn.scrskey:=86;
 scn.scrskeynam:='V';  
 scn.skip_step:=nil;    
 scn.cur_sv:=0;
 
 scn.axes_cnt:=0;  
 setlength(scn.axes,0);
 scn.firstrun:=true; 
 scn.fixedsky:=true;
end;
//############################################################################//
begin
end.  
//############################################################################//