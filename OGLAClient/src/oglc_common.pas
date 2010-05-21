//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLAClient Main
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglc_common;
interface
uses sysutils,asys,tim,maths,grph,log,strval,parser,oglctypes,ogladata,oglautil,oglashaders,oapi,{$ifdef orulex}dynplntutil,{$endif}dogl,glgr,opengl1x;
//############################################################################//  
function  common_input(scn:poglascene;op:integer;key:word;shift:byte):boolean;
procedure common_render_own_info(scn:poglascene);  
procedure common_main_init_sys(scn:poglascene); 
//############################################################################// 
implementation                  
//############################################################################// 
function common_input(scn:poglascene;op:integer;key:word;shift:byte):boolean;
begin   
 result:=false;  
 if not scn.cmdmod then ogla_cmdinput(scn,0,key,shift) else begin
  ogla_cmdinput(scn,0,key,shift);
  case key of 
   27:scn.cmdmod:=false;     //Esc
   73:feats.auxinfo:=not feats.auxinfo;  //I
   48:feats.camdir:=1-feats.camdir;         //0
  end;
  scn.cmdmod:=false;
  result:=true;
  exit;
 end;
end;
//############################################################################// 
//Render front screen (info, HUD, etc)
procedure common_render_own_info(scn:poglascene);
var s:string;
gx,gy:integer;
cl_tx:crgba;
begin    
 cl_tx:=tcrgba(200,200,200,255);
 if gl_2_sup then glUseProgram(0);  
 glgr_set2d(scn.sys.gwin);  
 glEnable(GL_TEXTURE_2D);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
 gldisable(GL_LIGHTING);gldisable(GL_DEPTH_TEST);  
        
 ogla_render_own_info(scn,feats.auxinfo);
 //Camera
 if scn.feat.camera2 then begin  
  if feats.auxinfo then wrtxtcnt2d('Camera view (F7-1 toggle):',1,dword(feats.camx)+scn.feat.cmtres div 2,feats.camy-20,gclred);
  putcsqr2D(feats.camx,feats.camy,scn.feat.cmtres+8,scn.feat.cmtres+8,4,gclblack,gclgreen);
  puttx2d(cmtx,feats.camx+4,feats.camy+4,scn.feat.cmtres,scn.feat.cmtres,true,gclwhite);
 end;
      
 if rtdt(msg_tim)<5000000 then if(not gl_14_fbo_sup)and(feats.gdiemu)then wrtxtcnt2d('GDI emulation impossible. Legacy MFDs & panels will not work.',1,scn.sys.gwin.wid div 2,90,cl_tx);  
  
 //Options menu
 gx:=scn.sys.gwin.wid-210;gy:=scn.sys.gwin.hei div 2-200;
 if scn.cmdmod then begin
  wrtxt2d('F7-I Aux info'       ,1,gx+5,gy+30+20*15,cl_tx);if feats.auxinfo then s:='On ' else s:='Off'; wrtxt2d(s,1,gx+175,gy+30+20*15,cl_tx);
  wrtxt2d('F7-0 Camera-2 toggle',1,gx+5,gy+30+20*16,cl_tx);if feats.camdir=0 then s:='R ' else s:='L';   wrtxt2d(s,1,gx+175,gy+30+20*16,cl_tx);
 end else if feats.auxinfo then wrtxtcnt2d('F7 for options',1,gx+100,gy+10,cl_tx);  
 
 glBindTexture(GL_TEXTURE_2D,0);  
end; 
//############################################################################//
//System init
procedure save_ogla_feats(scn:poglascene);
var f:text;
begin 
 assignfile(f,'OGLAClient.cfg');
 rewrite(f);
 writeln(f,'//OGLAClient Feature Config');   
 writeln(f,'');
 writeln(f,'//Render');
 if feats.camdir=1 then write(f,'Camera-2_Mode=Landing');
 if feats.camdir=0 then write(f,'Camera-2_Mode=Retro');
 writeln(f,'      //Landing, Retro');
 writeln(f,'Aux_Info=',ord(feats.auxinfo));
 writeln(f,'GDI_Emulation=',ord(feats.gdiemu));  
 writeln(f,'Server_mode=',ord(feats.server_on));      
 writeln(f,'Use_UDP=',ord(use_udp));      
 writeln(f,' ');     
 writeln(f,'//Scene');
 writeln(f,'Shadows_General_Switch=',ord(scn.feat.shadows));   
 if scn.feat.shres=0 then write(f,'Shadows_Mode=Off');
 if scn.feat.shres=1 then write(f,'Shadows_Mode=Projective');
 if scn.feat.shres=2 then write(f,'Shadows_Mode=Low_Stencil');
 if scn.feat.shres=3 then write(f,'Shadows_Mode=Med_Stencil');
 if scn.feat.shres=4 then write(f,'Shadows_Mode=High_Stencil');
 if scn.feat.shres=5 then write(f,'Shadows_Mode=Mapped');  
 writeln(f,'      //Off, Projective, Low_Stencil, Med_Stencil, High_Stencil, Mapped');      
 writeln(f,'Auto_Resolution=',ord(scn.feat.autores));
 writeln(f,'Projection=',scn.feat.projection);
 writeln(f,'Multilight_Terrain=',ord(scn.feat.mlight_terrain));
 writeln(f,'Terrain=',ord(scn.feat.orulex));
 writeln(f,'Terrain_Mode=',stri(scn.feat.orures));
 writeln(f,'Advanced_atmosphere=',ord(scn.feat.advatm));
 writeln(f,'Raytraced_atmosphere=',ord(scn.feat.rayleigh));
 writeln(f,'Camera-2=',ord(scn.feat.camera2));
 writeln(f,'Multilight=',ord(scn.feat.multilight));
 writeln(f,'Advanced_Graphics=',ord(scn.feat.advanced));
 writeln(f,'Draw_Mode_Override=',scn.feat.drwm);   
 writeln(f,'Shadow_Maps_Resolution=',scn.feat.shmres);
 writeln(f,'Second_Camera_Resolution=',scn.feat.cmtres); 
 writeln(f,'Wireframe=',ord(scn.feat.wireframe));
 writeln(f,'Stereo=',ord(scn.feat.stereo));
 writeln(f,'Stereo_distance=',stre(scn.feat.angl_dist));
 closefile(f);
end;
//############################################################################// 
procedure load_ogla_feats(scn:poglascene=nil);
var p:preca;
i:integer;
begin p:=nil;
 if not fileexists('OGLAClient.cfg')then exit;
 p:=parsecfg('OGLAClient.cfg',false);
 for i:=0 to length(p)-1 do with p[i] do begin
  if par='Camera-2_Mode' then begin
   if props='Landing' then begin feats.camdir:=1;continue;end;
   if props='Retro' then begin feats.camdir:=0;continue;end;
  end;
  if par='Aux_Info' then begin feats.auxinfo:=propb;continue;end;
  if par='GDI_Emulation' then begin feats.gdiemu:=propb;continue;end;   
  if par='Server_mode' then begin feats.server_on:=propb;continue;end;        
  if par='Use_UDP' then begin use_udp:=propb;continue;end;
  if par='Smooth_textures' then begin scn.feat.tx_smooth:=propb;continue;end;
  if par='Compress_textures' then begin scn.feat.tx_compress:=propb;continue;end;
  if par='MipMaps' then begin scn.feat.tx_mipmap:=propb;continue;end;
  if par='Shadows_General_Switch' then begin scn.feat.shadows:=propb;continue;end;
  if par='Shadows_Mode' then begin
   if props='Off' then begin scn.feat.shres:=0;continue;end;
   if props='Projective' then begin scn.feat.shres:=1;continue;end;
   if props='Low_Stencil' then begin scn.feat.shres:=2;continue;end;
   if props='Med_Stencil' then begin scn.feat.shres:=3;continue;end;
   if props='High_Stencil' then begin scn.feat.shres:=4;continue;end;
   if props='Mapped' then begin scn.feat.shres:=5;continue;end;
  end;                           
  if par='Auto_Resolution' then begin scn.feat.autores:=propb;continue;end;
  if par='Projection' then begin scn.feat.projection:=propn;continue;end;
  if par='Multilight_Terrain' then begin scn.feat.mlight_terrain:=propb;continue;end;
  if par='Terrain' then begin scn.feat.orulex:=propb;continue;end;
  if par='Terrain_Mode' then begin scn.feat.orures:=propn;continue;end; 
  if par='Advanced_atmosphere' then begin scn.feat.advatm:=propb;continue;end;
  if par='Raytraced_atmosphere' then begin scn.feat.rayleigh:=propb;continue;end;
  if par='Camera-2' then begin scn.feat.camera2:=propb;continue;end;
  if par='Multilight' then begin scn.feat.multilight:=propb;continue;end;
  if par='Fast_Multilight' then begin gl_shm4:=not propb;continue;end;
  if par='Advanced_Graphics' then begin scn.feat.advanced:=propb;continue;end;
  if par='Draw_Mode_Override' then begin scn.feat.drwm:=propn;continue;end;
  if par='Shadow_Maps_Resolution' then begin scn.feat.shmres:=propn;continue;end;
  if par='Second_Camera_Resolution' then begin scn.feat.cmtres:=propn;continue;end;  
  if par='Wireframe' then begin scn.feat.wireframe:=propb;continue;end;
  if par='Stereo' then begin scn.feat.stereo:=propb;continue;end;
  if par='Stereo_distance' then begin scn.feat.angl_dist:=propd;continue;end;
 end;
end;
//############################################################################//
procedure common_main_init_sys(scn:poglascene);
begin
 scn.feat.tx_smooth:=true;
 scn.feat.tx_compress:=true;
 scn.feat.tx_mipmap:=true;
 
 feats.camdir:=0;
 feats.auxinfo:=true;
 feats.gdiemu:=false;
 
 ogla_clrinit_scene(scn);
    
 scn.fixedsky:=false;
 scn.feat.orulex:=false;
 scn.feat.advatm:=false; 
 scn.feat.fxsky:=false; 
 scn.feat.shres:=0; //0=off, 1=projective, 2=low-res, 3=med-res, 4=hi-res, 5=mapped
 scn.feat.rayleigh:=false;   
 
 scn.cmdmkey:=118;
 scn.cmdmpref:='F7';
 scn.scrskey:=86;
 scn.scrskeynam:='V';
  
 load_ogla_feats(scn);    
 scn.cmdmod:=false;  
end;
//############################################################################//
initialization
finalization
if crash then oapiSaveScenario('crash_scenario','Game state, as intercepted during OGLA crash.');  
//############################################################################//
end. 
//############################################################################//
