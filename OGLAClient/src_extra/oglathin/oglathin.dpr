//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA linux standalone
// Released under GNU General Public License
// Made in 2005-2010 by Artyom Litvinovich
//############################################################################// 
program oglathin;
uses sysutils,asys,tim,maths,strval,grph,glgr,dogl,log,grpcam,
oglctypes,oglc_common,glras_surface,otvar,otutil,otnet,{$ifdef orulex}dynplntutil,{$endif}
ogladata,oglacalc,oglautil,ogladraw,opengl1x,orbitscr,mfd_api;
{$ifdef win32}{$R ../../rsrc/std.res}{$APPTYPE CONSOLE}{$endif}
//############################################################################// 
var xdt,mdt:integer;
//############################################################################// 
//Render 2D panels  
procedure render_panel(t:pmat;transparent:boolean);
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
 //FIXME: Mamory leak ~4Kb/s
 msh:=@pan_msh;
 if msh=nil then exit;
 if not msh.used then exit;
 
 scalex:=T[0].x; dx:=T[0].z;
 scaley:=T[1].y; dy:=T[1].z;

 for i:=0 to msh.grc-1 do begin
  msh.grp[i].static:=false;
  //if msh.grp[i].orbTexIdx>=TEXIDX_MFD0 then begin
  if msh.grp[i].orbTexIdx>notx-100 then begin
   //mfdidx:=msh.grp[i].orbTexIdx-TEXIDX_MFD0;
   //newsurf:=getmsurf(orb_gc,0,mfdidx);
   //if newsurf=nil then continue;
   continue;
  end else begin
   newsurf:=@pan_idx[msh.grp[i].orbTexIdx];
  end;

  nvtx:=length(msh.grp[i].pnts);
  ns:=txget(newsurf);
  if ns<>nil then begin
   msh.grp[i].dif.tx:=ns.tex;

   if ns.tex<>0 then for j:=0 to nvtx-1 do begin
    msh.grp[i].pnts[j].pos.x:=msh.grp[i].pnts[j].pos.x*scalex+dx;
    msh.grp[i].pnts[j].pos.y:=msh.grp[i].pnts[j].pos.y*scaley+dy;
   end;   
  end;
  putmshgrp(@msh.grp[i],zvec,zvec,evec,false,false,notx-1,false,$FFFFFFFF,64*ord(transparent));

 end;
 glBindTexture(GL_TEXTURE_2D,0); 

 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
 except stderr('Graph','Error in render_panel'); end; 
end;  
//############################################################################// 
//Render front screen (info, HUD, etc)
procedure Rendertx(scn:poglascene);
var c:cardinal;
s:string;
gx,gy,i:integer;
begin c:=0; try     
 glgr_set2d(@gwin);  
 glEnable(GL_TEXTURE_2D);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
 gldisable(GL_LIGHTING);gldisable(GL_DEPTH_TEST);  
 
 common_render_own_info(scn);
 
 render_panel(@pan_mat,pan_trans);

 if shinf then begin
  wrtxt2d('FOV '+stri(round(2*180*scn.camapr/pi))+'o',1,gwin.wid-100,36,gclred);
  wrtxt2d('FPS '+stri(gwin.cfps),1,gwin.wid-100,53,gclred);
 
  s:='External Global';
  wrtxt2d('Mode '+s,1,7,19,gclred);
  wrtxt2d('Dist '+strcv(modv(subv(scn.cam.pos,scn.cam.tgt))),1,7,36,gclred);
 
  if tgt=0 then s:='Origin';
  if tgt>0 then s:=scn.plnt[tgt-1].name;
  wrtxt2d('View '+s,1,7,2,gclred);
 end;
      
 //wrtxtcnt2d('Right button to turn, wheel to zoom/move',1,gwin.wid div 2,20,gclred);
 //wrtxtcnt2d('1 selects original target, 2-9 - planets',1,gwin.wid div 2,35,gclred);
 if scene.cam.mode=1 then wrtxtcnt2d('Free flight (0 toggle)',1,gwin.wid div 2,90,gclred);
 if scene.cam.mode=3 then wrtxtcnt2d('Target mode (0 toggle)',1,gwin.wid div 2,90,gclred);
 
 //Options menu
 gx:=gwin.wid-210;gy:=gwin.hei div 2-200;
 if scn.cmdmod then begin
  //wrtxt2d('F7-4 Info',1,gx+5,gy+90,gclred);
  //if shinf then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+90,gclred);
 end else wrtxtcnt2d(scn.cmdmpref+' for options',1,gx+100,gy+10,gclred);
 
 if not is_link then wrtxtcnt2d('No link',2,gwin.wid div 2,gwin.hei div 2,gclred); 

 for i:=0 to length(scene.smobs)-1 do wrtxt2d(stri(i)+'. '+scene.smobs[i].name,1,10,300+i*20,bchcrgba(i=cur_ves,gclgreen,gclred));
 
 maindr.tx:=0;
 maindr.xp:=0;
 maindr.yp:=0;
 maindr.xs:=gwin.wid;
 maindr.ys:=gwin.hei;
 
 mfd_dr.tx:=0;
 mfd_dr.xp:=10;
 mfd_dr.yp:=10;
 mfd_dr.xs:=256;
 mfd_dr.ys:=256;
 
 swmg_sqr(@maindr,10,10,10+256,10+256,gclaz,gclgreen);
 orbit_info.prdraw(@mfd_dr,orbit_info.p);   
   
 glBindTexture(GL_TEXTURE_2D,0);  
 except stderr('Graph','Error in Rendertx (camera='+stri(c)+')'); end; 
end; 
//############################################################################//
//Main loop
procedure maintim(ct,dt:double);
var dp:vec;
i:integer;
begin
 stdt(xdt);
 mutex_lock(net_mx);

 scene.fps:=gwin.cfps;
 scene.wid:=gwin.wid;scene.hei:=gwin.hei;
 camprc_ogla(@scene);
         
 dp:=nmulv(scene.cam.tgtvel,dt);
 scene.cam.pos:=addv(scene.cam.pos,dp);
 scene.cam.tgt:=addv(scene.cam.tgt,dp);
 scene.cam1:=scene.cam;    
 scene.cam2:=scene.cam;     
 scene.cam2.pos:=addv(nmulv(subv(scene.cam2.pos,scene.cam2.tgt),10),scene.cam2.tgt);
          
 prop_obs(@scene,dt);
 if need_textures_load then begin
  for i:=0 to texcnt-1 do txget(@i);
  
  need_textures_load:=false;
 end;

  //Camera  
 if scene.feat.camera2 then begin
  //scene.restate:=true;
  scene.tx:=cmtx;
  scene.cam:=scene.cam2;   
  ogla_reupdatevals(@scene);
  ogla_render_scene(@scene);  
  //scene.restate:=true;
 end;        
 //Main view  
 scene.tx:=0;   
 scene.cam:=scene.cam1; 
 ogla_reupdatevals(@scene);
 ogla_render_scene(@scene);  

 
 //Main view
 //ogla_render_scene(@scene);

 rendertx(@scene);  
 mutex_release(net_mx);

 glFlush;doglswap(@gwin);
end;
//############################################################################//
//############################################################################//
procedure ldmsg(s,c:string;ld:boolean);
begin    
 glgr_set2d(@gwin);     
 glClearColor(0,0,0,1);
 glClear(GL_COLOR_BUFFER_BIT); 
 
 wrtxtcnt2d('Loading: '+s,1,gwin.wid div 2,gwin.hei div 2,gclred);  
 glColor4f(1,1,1,1);  
 glFlush;doglswap(@gwin); 
end;
//############################################################################//
//############################################################################//
procedure main;
var c:integer;
ns:boolean;
var cd:string;
begin  
 set_log('ogla.log');
 stdt(mdt); 
 
 if paramcount>=1 then begin
  c:=1;
  ns:=false;
  while c<=paramcount do begin
   if paramstr(c)='--udp' then use_udp:=true 
   else if not ns then begin net_srv:=paramstr(c);ns:=true;end else begin
    writeln('Usage: ',paramstr(0),' [OPTIONS] [server]');
    writeln(' Options:');
    writeln(' --udp      Use UDP for state vectors');
    writeln(' --comp     Compress data stream (broken)');
    writeln;
    writeln('"',paramstr(c),'" does not match any of them, and the server was already named (',net_srv,'), so check the input.');
    halt;
   end;
   c:=c+1;
  end;
 end;

 getdir(0,cd);
 if(cd[length(cd)]<>'/')and(cd[length(cd)]<>'\')then cd:=cd+'/';;
 if not directoryexists('textures') then forcedirectories(cd+'textures');
 
 //if paramcount>=1 then net_srv:=paramstr(1);
 //'91.206.14.91'

 common_main_init_sys(@scene);
 lrndseed:=65774;   
 
 if not createoglwin(@gwin,800,600,false,@glgr_frmevent,@maintim,'OGLA 090414 Win32 Thinclient') then halt(1); 
 //SetWindowText(hwnd,'Loading...');  
 glgr_init;
 if(@glCompressedTexImage2DARB=nil)or(@glGetCompressedTexImageARB=nil) then stderr('RNDR','Texture compression unsupported.');   
 glClearColor(0.8,0.8,0.8,1);
 ldmsg('All','bb',false);  
 
 //Constants
 orb_texdir:='Textures';
 orb_mshdir:='Meshes';
 sysogla.texdir:='Textures';
 sysogla.mshdir:='Meshes';
 sysogla.gwin:=@gwin;             
 scene.hei:=gwin.hei;        
 scene.wid:=gwin.wid;    
 scene.sys:=@sysogla;

 feats.camy:=400;
 scene.feat.camera2:=true;
                      
 scene.tx:=0; 
 scene.cam.rtmat:=emat;
 brtmat[0]:=emat;
 scene.cam.brtmat:=@brtmat[0];
 scene.cam.mode:=0;
 
 scene.cam.pos:=tvec(1,0,0);
 scene.cam.dir:=tvec(0,0,1);
 scene.cam.tgt:=tvec(0,0,1);    
 scene.camapr:=45;
 scene.invc:=false;
 scene.cam.tgtvel:=tvec(0,1,0);
 
 oglainit_graph(@scene); 
 initogla;
 {$ifdef orulex}dp_init(true,'textures\');{$endif}  
 net_init;  
 
 orbit_info.prinit(orbit_info.p,256,256,@csw_ob);

 doglmain;
end;                                                                             
//############################################################################// 
begin  
 xdt:=getdt;
 mdt:=getdt;
 ildmsg:=ldmsg;
 main;
end.
//############################################################################// 

