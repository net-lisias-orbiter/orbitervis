//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLAClient Main
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglcbase;
interface
uses math,windows,asys,maths,strval,grph,glgr,dogl,opengl1x,jpg,png,startuppng,grpcam,log,
oglcvar,oglc_common,oglctypes,glras_surface,orbitergl,ogladata,oglacalc,oglautil,ogladraw,oapi;
//############################################################################//    
procedure render_splash(str:string;a:double=0;b:double=0;c:double=0);
procedure render_loaddlg(str,cap:string;ld:boolean);
 
procedure render_own_info(scn:poglascene);
procedure render_panel(hSurf:papinteger;hMesh:pointer;t:pmat;transparent:boolean);      
procedure update_all;
function  render_all:integer; stdcall;  

procedure initogla;   
procedure init_splash;
procedure initgraph;    
//############################################################################// 
implementation
//############################################################################// 
procedure render_splash(str:string;a:double=0;b:double=0;c:double=0);
var xo,yo:integer;
begin try              
 if gl_2_sup then glUseProgram(0); 
 glClear(GL_COLOR_BUFFER_BIT);
 glEnable(GL_TEXTURE_2D);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);    
 gldisable(GL_LIGHTING);gldisable(GL_DEPTH_TEST);  
 
 glgr_set2d(@gwin);      
 puttx2dsh(logotx,0,0,gwin.wid,gwin.hei,0,0,1,768/1024,false,gclwhite); 
 
 putcsqr2D(gwin.wid-197,-3,200,40,4,tcrgba(0,0,0,64),tcrgba(200,200,200,255));  
 wrtxtcnt2d('Orbiter 2010',1,gwin.wid-100,3,tcrgba(200,200,200,255));  
 wrtxtcnt2d('OpenGL client '+oglaver,1,gwin.wid-100,20,tcrgba(200,200,200,255)); 
 
 xo:=gwin.wid div 2-200;yo:=gwin.hei-80;
 putcsqr2D(xo,yo,400,85,4,tcrgba(0,0,0,64),tcrgba(64,128,64,255)); 
 if a<>0 then putcsqr2D(xo+1,yo+20,398*a,20,4,tcrgba(64,0,0,64),tcrgba(64,128,64,255)); 
 if b<>0 then putcsqr2D(xo+1,yo+40,398*b,20,4,tcrgba(0,64,0,64),tcrgba(64,128,64,255)); 
 if c<>0 then putcsqr2D(xo+1,yo+60,398*c,20,4,tcrgba(0,0,64,64),tcrgba(64,128,64,255)); 
 wrtxtcnt2d('Загрузка, понятное дело | Loading, please wait',1,xo+200,yo+5,tcrgba(128,200,64,255));   
 wrtxtcnt2d(str,1,xo+200,yo+42,tcrgba(64,200,128,255)); 

 glBindTexture(GL_TEXTURE_2D,0);   
 glFlush;doglswap(@gwin);          
 except stderr('Graph','Error in render_splash (str='+str+')'); glFlush;doglswap(@gwin); end;
end;  
//############################################################################// 
//Render loading string
procedure render_loaddlg(str,cap:string;ld:boolean);   
var xo,yo:integer;
begin try                    
 if gl_2_sup then glUseProgram(0);  
 if firstrun then begin render_splash(str); exit; end;      
 glEnable(GL_TEXTURE_2D);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
 gldisable(GL_LIGHTING);gldisable(GL_DEPTH_TEST);   
 
 glgr_set2d(@gwin); 
 xo:=gwin.wid div 2-200;yo:=gwin.hei-40;
 putcsqr2D(xo,yo,400,45,4,tcrgba(0,0,0,64),tcrgba(64,128,64,255)); 
 wrtxtcnt2d('Грузим | Loading additional data',1,xo+200,yo+5,tcrgba(128,200,64,255));
 wrtxtcnt2d(str,1,xo+200,yo+22,tcrgba(64,200,128,255));

 glBindTexture(GL_TEXTURE_2D,0); 
 glFlush;doglswap(@gwin);            
 except stderr('Graph','Error in render_loaddlg (str='+str+')'); glFlush;doglswap(@gwin); end;
end;  
//############################################################################// 
//Render front screen (info, HUD, etc)    
procedure render_own_info(scn:poglascene);
begin try 
 common_render_own_info(scn); 
 if oapiGetPause then begin 
  putcsqr2D(scn.sys.gwin.wid div 2-8*5,scn.sys.gwin.hei-32,8*10,16,4,tcrgba(0,0,0,128),tcrgba(200,200,200,255));
  wrtxtcnt2d('Paused',1,scn.sys.gwin.wid div 2,scn.sys.gwin.hei-32,gclred);
 end;      
 if feats.server_on then wrtxtcnt2d('Clients connected: '+stri(net_cls),1,scn.sys.gwin.wid div 2,32,gclred);
 
 //if xp<0 then xp:=gwin.wid-xp;
 //if yp<0 then xp:=gwin.hei-yp;
 //const char *msg=oapiDebugString();
 //if(msg[0]){ogla_wrgltxt2D(msg,8,-16,0);} 
 //wrtxt2d(st,siz,xp,yp,gclwhite); 
 
 except stderr('Graph','Error in render_own_info'); end; 
end; 
//############################################################################// 
//Render 2D panels
procedure render_panel(hSurf:papinteger;hMesh:pointer;t:pmat;transparent:boolean);
var msh:ptypmsh;
i,j,nvtx,mfdidx:integer;
scalex,scaley,dx,dy:single;
newsurf:pinteger;
ns:psurfinfo;
begin try  
 if gl_2_sup then glUseProgram(0);  
 glgr_set2d(@gwin);  
 glEnable(GL_TEXTURE_2D);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
 gldisable(GL_LIGHTING);gldisable(GL_DEPTH_TEST);  
 if transparent then glBlendFunc(GL_SRC_ALPHA,GL_ONE); 
 //FIXME: Memory leak ~4Kb/s
 msh:=ldmsh(hMesh,false); 
 if msh=nil then exit;     
 
 scalex:=T[0].x; dx:=T[0].z;
 scaley:=T[1].y; dy:=T[1].z;
 for i:=0 to msh.grc-1 do begin
  if msh.grp[i].orbTexIdx>=TEXIDX_MFD0 then begin
   mfdidx:=msh.grp[i].orbTexIdx-TEXIDX_MFD0;
   newsurf:=getmsurf(0,mfdidx);
   if newsurf=nil then continue;
  end else newsurf:=hSurf[msh.grp[i].orbTexIdx];  
                        
  nvtx:=length(msh.grp[i].pnts);
  ns:=txget(newsurf);
  msh.grp[i].dif.tx:=0;
  if ns<>nil then msh.grp[i].dif.tx:=ns.tex; 
  if ns<>nil then assert(ns.mag=SURFH_MAG);
  
  for j:=0 to nvtx-1 do begin
   msh.grp[i].pnts[j].pos.x:=msh.grp[i].pnts[j].pos.x*scalex+dx;
   msh.grp[i].pnts[j].pos.y:=msh.grp[i].pnts[j].pos.y*scaley+dy;
   msh.grp[i].pnts[j].pos.z:=0;
   msh.grp[i].pnts[j].tx.x:=msh.grp[i].pnts[j].tx.x;
   msh.grp[i].pnts[j].tx.y:=msh.grp[i].pnts[j].tx.y;
  end;   
  putmshgrp(@msh.grp[i],zvec,zvec,evec,false,false,notx-1,false,$FFFFFFFF,64*ord(transparent));

 end;
 glBindTexture(GL_TEXTURE_2D,0); 

 //FIXME: Mamory leak ~4Kb/s
 freemsh(msh);
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
 except stderr('Graph','Error in render_panel'); end; 
end;  
//############################################################################// 
//Main render call
//Update scene state, call OGLA scene render 
procedure update_all;
var cd,bd:vec;
cm,bm:mat;    
focallength:double;
begin try  
 //Sync configs
 ogli.shfps:=ord(feats.auxinfo);
 
 //Update scene
 //Camera position and direction, target position, view mode
 oapiCameraGlobalPos(              @scene.cam.pos);
 oapiGetGlobalPos(oapiCameraTarget,@scene.cam.tgt);
 oapiCameraGlobalDir(              @scene.cam.dir);
 oapiCameraRotationMatrix(@cm);
 
 scene.cam.rtmat:=cm;
 scene.cam.brtmat:=@scene.cam.rtmat;
 bm:=cm;                          
 cd:=scene.cam.dir;bd:=cd;
 if feats.camdir=0 then begin rtmaty(bm,pi);   vroty(bd,pi);   end;
 if feats.camdir=1 then begin rtmatx(bm,-pi/2);vrotx(bd,-pi/2);end;
                    
 scene.cam2:=scene.cam;scene.cam1:=scene.cam;            
 scene.cam1.rot:=tamat(cm);scene.cam1.dir:=cd;      
 scene.cam2.rot:=tamat(bm);scene.cam2.dir:=bd;    
 scene.cam:=scene.cam1;

//focallength:=(gwin.wid/2)/tan(FovH/2)=(gwin.hei/2)/tan(FovV/2);
//FovV:=2*(atan((gwin.hei/2)/focallength))
//FovH:=2*(atan((gwin.wid/2)/focallength)) 
 
 scene.camapr:=oapiCameraAperture;
 if scene.feat.projection=4 then begin
  focallength:=(gwin.wid/2)/tan((2*pi/3)/2);
  scene.camapr:=(arctan((gwin.hei/2)/focallength));
 end;
 if scene.feat.projection=2 then begin 
  focallength:=(gwin.wid/2)/tan((pi/2)/2);
  scene.camapr:=(arctan((gwin.hei/2)/focallength));
 end;
 if scene.feat.projection=3 then begin 
  focallength:=(gwin.wid/2)/tan((pi/3)/2);
  scene.camapr:=(arctan((gwin.hei/2)/focallength));
 end;
 scene.invc:=oapiCockpitMode=COCKPIT_VIRTUAL;  


 //Update state vectors, load if not loaded
 //Vessel and base meshes are obtained from Orbiter, textures loaded by orbitergl
 //Planet textures and meshes are handled by OGLA entirely
 procplanets(@scene);  
 proc_smob(@scene);  
 
 //OGLA engine render process
 //Update internal values
 ogla_reupdatevals(@scene); 
                              
 except stderr('RNDR','Error in OGLARender'); end;
end;     
//############################################################################// 
//Main render call
//Update scene state, call OGLA scene render 
function render_all:integer; stdcall;  
var co:camrec; 
begin result:=0; try  
 udc:=0; 
 //Camera  
 if scene.feat.camera2 then begin
  scene.tx:=cmtx;
  scene.cam:=scene.cam2;
  ogla_render_scene(@scene);  
 end;    
 //Main view  
 scene.tx:=0;   
 scene.cam:=scene.cam1;

 if scene.feat.projection=4 then begin
  co:=scene.cam;
  scene.cur_sv:=0;ogla_render_scene(@scene);  
  rtmaty(scene.cam.rtmat,120/180*pi);
  scene.cam.rot:=tamat(scene.cam.rtmat);
  vroty(scene.cam.dir,120/180*pi);      
  scene.cur_sv:=1;ogla_render_scene(@scene);         
  rtmaty(scene.cam.rtmat,120/180*pi);
  scene.cam.rot:=tamat(scene.cam.rtmat);
  vroty(scene.cam.dir,120/180*pi);   
  scene.cur_sv:=2;ogla_render_scene(@scene);   
  scene.cam:=co;
 end else if scene.feat.projection=2 then begin
  co:=scene.cam;
  
  rtmaty(scene.cam.rtmat,-45/180*pi);
  scene.cam.rot:=tamat(scene.cam.rtmat);
  vroty(scene.cam.dir,-45/180*pi);      
  scene.cur_sv:=0;ogla_render_scene(@scene);    
       
  rtmaty(scene.cam.rtmat,90/180*pi);
  scene.cam.rot:=tamat(scene.cam.rtmat);
  vroty(scene.cam.dir,90/180*pi);   
  scene.cur_sv:=1;ogla_render_scene(@scene);   
  
  scene.cam:=co;
 end else if scene.feat.projection=3 then begin
  co:=scene.cam;
  
  rtmaty(scene.cam.rtmat,-60/180*pi);
  scene.cam.rot:=tamat(scene.cam.rtmat);
  vroty(scene.cam.dir,-45/180*pi);      
  scene.cur_sv:=0;ogla_render_scene(@scene);    
       
  rtmaty(scene.cam.rtmat,60/180*pi);
  scene.cam.rot:=tamat(scene.cam.rtmat);
  vroty(scene.cam.dir,90/180*pi);   
  scene.cur_sv:=1;ogla_render_scene(@scene);    
       
  rtmaty(scene.cam.rtmat,60/180*pi);
  scene.cam.rot:=tamat(scene.cam.rtmat);
  vroty(scene.cam.dir,90/180*pi);   
  scene.cur_sv:=2;ogla_render_scene(@scene);   
  
  scene.cam:=co;
 end else ogla_render_scene(@scene);
          
 //Return polygon count
 result:=udc; 
 except stderr('RNDR','Error in OGLARender'); end;
end;  
//############################################################################// 
//Load basic graphics
//Loading screen
procedure init_splash; 
var p:pointer;
x,y:integer;
begin
 //ldjpgbuf(@startup,length(startup),false,true,gclz,x,y,p); 
 ldpngbuf(@startup,length(startup),false,true,gclz,x,y,p); 
 glgr_make_tex(logotx,x,y,p,true,true,false,false);   
 freemem(p); 
end;          
//############################################################################// 
procedure initgraph;
var data:array of starrec;
f:file;
i,n,star_count,fs:integer;
v:vec;
xz,a,c,b,brt_min,mag_lo,mag_hi,sphere_r:double;
map_log:boolean;
spr:StarRenderPrm;
begin b:=1;try   
 oglainit_graph(@scene);
 
 //Screen plane and GDI screen plane    
 create_screen_surface(scrx,scry);

 spr:=pStarRenderPrm(GetConfigParam(CFGPRM_STARRENDERPRM))^;

 filemode:=0;
 assignfile(f,'Star.bin');
 reset(f,1);
 fs:=filesize(f); 
 setlength(data,fs div sizeof(StarRec)); 
 blockread(f,data[0],fs);
 closefile(f);

 
 star_count:=5000;
 brt_min:=spr.brt_min;
 mag_lo:=spr.mag_lo;
 mag_hi:=spr.mag_hi;
 sphere_r:=10;
 map_log:=spr.map_log;

 if map_log then begin
  a:=-ln(brt_min)/(mag_lo-mag_hi);
 end else begin
  a:=(1-brt_min)/(mag_hi-mag_lo);
  b:=brt_min-mag_lo*a;
 end;

 new(scene.stars);
 setlength(scene.stars^,1); 
 new(scene.stars^[0]);
 setlength(scene.stars^[0].gps,star_count); 
 setlength(scene.stars^[0].idx,star_count); 
 setlength(scene.stars^[0].col,star_count); 
 scene.stars^[0].cnt:=star_count;

 n:=0;
 for i:=0 to fs div sizeof(StarRec)-1 do if data[i].mag<mag_lo then begin
  if n>=star_count then break;
  xz:=10*cos(data[i].lat);
  v.x:=(xz*cos(data[i].lng));
  v.z:=(xz*sin(data[i].lng));
  v.y:=(sphere_r*sin(data[i].lat));
  scene.stars^[0].gps[n]:=v2m(v);
  scene.stars^[0].idx[n]:=n;
  scene.stars^[0].mag:=$AAEE6699;
  
   //map_log              //brt_min               //mag_hi
  if map_log then c:=min2(1,max2(brt_min,exp(-(data[i].mag-mag_hi)*a)))
             else c:=min2(1,max2(brt_min,a*data[i].mag+b));

  scene.stars^[0].col[n]:=tcrgbad(c,c,c,1);
  n:=n+1;
 end;  
 scene.stars^[0].cnt:=n;


 except stderr('INIT','Error in initgraph'); end;
end;
//############################################################################// 
//Load stars, planets and currently visible bases and vessels, set constants
procedure initogla;
var j,i:integer;
d:ohnd;
tvn:vec;
p:array[0..255]of char;
begin
 //Stars
 scene.firstrun:=true;

 //Suns
 j:=0;
 for i:=0 to oapiGetObjectCount-1 do begin
  d:=oapiGetObjectByIndex(i);             
  if oapiGetObjectType(d)<>OBJTP_star then continue;
  setlength(scene.star,j+1);
  new(scene.star[j]);
  oapiGetGlobalPos(d,@tvn); 
  oapiGetObjectName(d,p,255);
  oglaset_star(scene.star[j],string(p),d,tvn,oapigetsize(d),tcrgba(255,255,230,255));
  j:=j+1;
 end;  
 setlength(scene.nebs,0);
 scene.nebcnt:=0;
  
 //Planets
 render_splash('Loading Planets');
 initplanets(@scene);  
end;      
//############################################################################//
begin
end. 
//############################################################################//
