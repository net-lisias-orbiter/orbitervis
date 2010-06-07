//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLAClient Interface
//
// Delphi7:
// Path: ..\rsrc;..\src_common\alib\synapse;..\src_common\alib;..\src_common\alibc;..\src_common\alib\glgr;..\src_common\alib\pck;..\src_common\dynplnt;..\src_common\ogla
// Units output: ..\rsrc\units
// Output: ..\..\..\modules
//
// Possible defines: 
// OGLADBG
// no_render
// orulex
//
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
library ogla;
uses sysutils,windows,asys,grph,maths,strval,tim,log,orbitergl,oapi,parser,
oglctypes,glras_draw,glras_surface,oglcvar,oglcnet
{$ifndef no_render},dynplntbase,ogladata,oglcsdk,oglc_common,oglcbase,glras_gdi,opengl1x,grplib,glgr,dogl,oglautil,oglashaders,ogladraw,dynplntutil{$endif};
//############################################################################// 
//Create Surface     
function ogla_maksrf(w,h:dword;tmp:pinteger;tp:integer):pinteger;stdcall;
var srf:psurfinfo;
begin result:=nil; try
 case tp of
  0,1:begin new(result);result^:=create_surface('',w,h,false,false,true,false);{$ifndef no_render}if tp=1 then clrsrf(result,0,0,0,0,0);{$endif} end;
  2:begin srf:=txget(tmp);if srf<>nil then inc(srf.uc);assert(srf.mag=SURFH_MAG);end;
 end;
 except on ex:exception do stderr('OGLTEX','(ogla_maksrf) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;  
//############################################################################// 
//Load texture
function ogla_loadtex(fnam:pchar;flg:dword):pinteger; stdcall;   
var i:integer;   
begin result:=nil; try 
 if get_texture_file_by_name(fnam)='' then exit; 
 new(result);
 {$ifndef no_render}
 if fnam='Fcd01.dds' then render_splash('Basic textures',0);
 if fnam='Fcd08_n.dds' then render_splash('Basic textures',0.25);
 if fnam='Door01_n.dds' then render_splash('Basic textures',0.5);
 if fnam='Runway2_n.dds' then render_splash('Basic textures',0.75);
 if fnam='Cape23_n.dds' then render_splash('Other core stuff',1);
 {$endif}
 
 i:=txfind(fnam);                             
 if(i<>-1)and(texres[i].global)then begin    
  assert(texres[i].mag=SURFH_MAG);
  result^:=i;
 end else begin
  result^:=create_surface(fnam,2,2,(flg and 8)<>0,((flg and 2)=0)and scene.feat.tx_compress and gl_12_sup,scene.feat.tx_smooth,scene.feat.tx_mipmap); 
 end;       
 //if result<>nil then wr_dbg('ogla_loadtex','result^='+stri(result^)+' fnam='+fnam+' flg='+stri(flg));  
 
 except on ex:exception do stderr('OGLTEX','(ogla_loadtex) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;   
//############################################################################// 
//Release texture (is it used?)
function ogla_reltex(tex:pinteger):boolean; stdcall;
var tx:psurfinfo;
begin result:=false; try   
 tx:=txget(tex);
 if tx=nil then exit;      
 assert(tx.mag=SURFH_MAG);
 dec(tx.uc); 
 if tx.uc<=0 then begin
  {$ifndef no_render}if tx.tex<>0 then glDeleteTextures(1,@tx.tex);{$endif}
  //dispose(tx);
  tx.used:=false;
  tx.mag:=0;
 end;            
 result:=true;  
 except on ex:exception do stderr('OGLTEX','(ogla_reltex) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;    
//############################################################################// 
//Fill Surface
function ogla_fillsr(s:pinteger;x,y,w,h,col:dword):boolean;stdcall;     
begin result:=false; try 
 {$ifndef no_render}clrsrf(s,x,y,w,h,col);{$endif}
 result:=true;
 except on ex:exception do stderr('OGLAUX','(ogla_fillsr) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;               
//############################################################################// 
//Get Surface Size
function ogla_gsrfsiz(s:pinteger;w,h:pdword):boolean; stdcall;         
var tx:psurfinfo;
begin result:=false; try  
 if s=nil then begin 
  w^:=scrsrf.w;
  h^:=scrsrf.h;
  result:=true;
  exit;
 end;    
 tx:=txget(s);             
 if tx=nil then exit;      
 assert(tx.mag=SURFH_MAG);
 if tx.tex=0 then exit;
 w^:=tx.w;
 h^:=tx.h;  
 result:=true;
 except on ex:exception do stderr('OGLTEX','(ogla_gsrfsiz) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;         
//############################################################################// 
//Get Surface HDC
//Create context and copy texture to it
//Context remains created for every textuer requested atlease once
function ogla_getsdc(s:pinteger):HDC; stdcall;       
var tx:psurfinfo;
begin result:=0; try 
 {$ifdef no_render}exit;{$else}
 if feats.gdiemu then begin
  if s=nil then begin   
   exit;
   //settodc(@scrsrf);
   //textohdcclr(@scrsrf);  
   //result:=psurfgdi(scrsrf.gdi).dc;
  end else begin   
   tx:=txget(s);  
   if tx=nil then exit;
   assert(tx.mag=SURFH_MAG);
   settodc(tx);
   textohdc(tx);
   result:=psurfgdi(tx.gdi).dc;     
  end;       
 end;            
 {$endif}
 except on ex:exception do stderr('OGLGDI','(ogla_getsdc) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;  
//############################################################################// 
//Release GDI Surface
//Copy GDI buffer over to texture
procedure ogla_relsdc(s:pinteger;dc:hdc); stdcall;
begin try     
 {$ifdef no_render}exit;{$else}
 if feats.gdiemu then begin
  if s=nil then begin
   //hdctotex(@scrsrf); 
   exit;
  end else begin
   hdctotex(txget(s));     
  end;     
 end;                 
 {$endif}
 except on ex:exception do stderr('OGLGDI','(ogla_relsdc) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;      
end;
//############################################################################// 
//Blit Surface
function ogla_blit(tp:integer;tgt:pinteger;tgtx,tgty,tgtw,tgth:dword;src:pinteger;srcx,srcy,srcw,srch,flag:dword):boolean;stdcall;
var tsrc,tdst:psurfinfo;
begin result:=false; try  
 {$ifdef no_render}exit;{$else}  
 tsrc:=txget(src); 
 tdst:=txget(tgt);  
 if tsrc<>nil then assert(tsrc.mag=SURFH_MAG);
 if tdst<>nil then assert(tdst.mag=SURFH_MAG);
 result:=oglc_blit(tp,tdst,tgtx,tgty,tgtw,tgth,tsrc,srcx,srcy,srcw,srch,flag);                        
 {$endif}
 except on ex:exception do stderr('OGLTEX','(ogla_blit) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;       
//############################################################################// 
//Render 2D elements     
procedure ogla_render2D(hSurf:papinteger;hMesh:pointer;t:pmat;transparent:integer);stdcall;
begin try   
 if feats.server_on then xmit_panel(hSurf,hMesh,t,transparent<>0);    
 {$ifndef no_render}render_panel(hSurf,hMesh,t,transparent<>0);{$endif}  
 except on ex:exception do stderr('OGLAUX','(ogla_render2D) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;    
//############################################################################// 
//Mesh operations   
procedure ogla_meshop(tp:integer;var hMesh:ptypmsh;vis:integer;tex:pinteger;idx:dword;ges:pGROUPEDITSPEC);stdcall; 
var i,vi:integer;
g:ptypmshgrp;
ofs:vec;
mat:pmaterial;
ctx:dword;
tx:psurfinfo;   
se:pdraw_rec;
function iii:integer;begin if ges.vIdx=nil then result:=i else result:=ges.vIdx[i];end;
begin try   
 {$ifdef no_render}exit;{$else}
 case tp of  
  0:hmesh:=scene.smobs[vis-1].draw.mshs[idx];    
  1:begin
   if idx>=dword(hmesh.grc) then exit;
   g:=@hmesh.grp[idx]; 
   if(ges.flags and GRPEDIT_SETUSERFLAG)<>0 then g.flags:=ges.UsrFlag else
   if(ges.flags and GRPEDIT_ADDUSERFLAG)<>0 then g.flags:=g.flags or ges.UsrFlag else
   if(ges.flags and GRPEDIT_DELUSERFLAG)<>0 then g.flags:=g.flags and(not ges.UsrFlag) else
   if(ges.flags and GRPEDIT_VTX)<>0 then begin
    for i:=0 to ges.nVtx-1 do begin
     vi:=iii;
     if vi<length(g.pnts)then begin
      if(ges.flags and GRPEDIT_VTXCRDX)<>0 then g.pnts[vi].pos.x:=ges.vtx[i].x;
      if(ges.flags and GRPEDIT_VTXCRDY)<>0 then g.pnts[vi].pos.y:=ges.vtx[i].y;
      if(ges.flags and GRPEDIT_VTXCRDZ)<>0 then g.pnts[vi].pos.z:=ges.vtx[i].z;
      if(ges.flags and GRPEDIT_VTXNMLX)<>0 then g.pnts[vi].nml.x:=ges.vtx[i].nx;
      if(ges.flags and GRPEDIT_VTXNMLY)<>0 then g.pnts[vi].nml.y:=ges.vtx[i].ny;
      if(ges.flags and GRPEDIT_VTXNMLZ)<>0 then g.pnts[vi].nml.z:=ges.vtx[i].nz;
      if(ges.flags and GRPEDIT_VTXTEXU)<>0 then g.pnts[vi].tx.x:=ges.vtx[i].tu;
      if(ges.flags and GRPEDIT_VTXTEXV)<>0 then g.pnts[vi].tx.y:=ges.vtx[i].tv;
     end;
    end;
    hmesh.grp[idx].vboreset:=true;
   end;  
  end;
  2:begin
   tx:=txget(tex);
   if tx<>nil then for i:=0 to hmesh.grc-1 do if hMesh.grp[i].orbTexIdx=idx-1 then begin 
    assert(tx.mag=SURFH_MAG);
    hMesh.grp[i].dif.tx:=tx.tex;  
    hMesh.grp[i].orbTexIdx:=idx-1;
   end;
  end;
  3:begin
   ctx:=dword(tex);
   case idx of
    EVENT_VESSEL_INSMESH:begin
     se:=scene.smobs[vis-1].draw;
     if integer(ctx)>=se.nmesh then begin
      setlength(se.mshv,se.nmesh);
      setlength(se.mshs,se.nmesh);
     end else if se.mshs[ctx]<>nil then se.mshs[ctx].used:=false;
     add_one_vessel_mesh(se,ctx,false);  
    end;
    EVENT_VESSEL_DELMESH:if scene.smobs[vis-1].draw.mshs[ctx]<>nil then scene.smobs[vis-1].draw.mshs[ctx].used:=false;
    EVENT_VESSEL_MESHOFS:if scene.smobs[vis-1].draw.mshs[ctx]<>nil then begin
     vesGetMeshOffset(scene.smobs[vis-1].draw.obj,ctx,@ofs); 
     scene.smobs[vis-1].draw.mshs[ctx].off:=ofs;
    end;
    EVENT_VESSEL_MESHVISMODE:if scene.smobs[vis-1].draw.mshs[ctx]<>nil then scene.smobs[vis-1].draw.mshv[ctx]:=vesGetMeshVisibilityMode(scene.smobs[vis-1].draw.obj,ctx);
   end;
  end;
  4:begin
   mat:=pmaterial(tex);
   if mat=nil then exit;
   for i:=0 to hmesh.grc-1 do if hMesh.grp[i].orbMtrlIdx=idx then begin
    hMesh.grp[i].col :=tdcrgba(mat.diffuse.r ,mat.diffuse.g ,mat.diffuse.b ,mat.diffuse.a);
    hMesh.grp[i].cole:=tdcrgba(mat.emissive.r,mat.emissive.g,mat.emissive.b,mat.emissive.a);
    hMesh.grp[i].cols:=tdcrgba(mat.specular.r,mat.specular.g,mat.specular.b,mat.specular.a);
    hMesh.grp[i].spow:=mat.power;
   end;
  end;
 end;
 {$endif}
 except on ex:exception do stderr('OGLAUX','(ogla_render2D) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;    
//############################################################################//
//Particle stream def
procedure ogla_addps(tp:integer;es:dword;pss:pPARTICLESTREAMSPEC;hVessel:ohnd;lvl:pdouble;ref,dir:pvec);stdcall;
begin try                    
 {$ifdef no_render}exit;{$else}  
 addpstrm(@scene,tp,es,pss,hVessel,lvl,ref,dir);                                       
 {$endif}
 except on ex:exception do stderr('OGLAUX','(ogla_addps) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;
//############################################################################//
//Keyboard  
//############################################################################//
//############################################################################//
procedure ogla_mouse(t:integer;x,y:integer;Shift:byte);stdcall;begin end;
procedure ogla_keyup(Key:Word;Shift:byte);stdcall;begin end;
procedure ogla_keydown(Key:Word;Shift:byte);stdcall;
begin try     
 //if key=27 then halt;                 
 {$ifdef no_render}
 case key of 
  48:net_stvec_dt:=1000000;        //0
  49:net_stvec_dt:=500000;         //1
  50:net_stvec_dt:=200000;         //2
  51:net_stvec_dt:=100000;         //3
  52:net_stvec_dt:=80000;         //4
  53:net_stvec_dt:=50000;         //5
  54:net_stvec_dt:=30000;         //6
  55:net_stvec_dt:=25000;         //7
  56:net_stvec_dt:=18000;         //8
  57:net_stvec_dt:=10000;         //9
 end;
 exit;
 {$else}if common_input(@scene,0,key,shift)then exit;{$endif}
 except on ex:exception do stderr('OGLINP','(ogla_keydown) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;   
//############################################################################// 
//Main render call
//Update scene state, call OGLA scene render 
function ogla_render(fps:integer):integer; stdcall;
begin                
 if feats.server_on then begin
  if rtdt(dt66)>2000000 then begin
   net_traf_avg:=(net_traf-net_traf_prv)/2/1024;
   net_traf_prv:=net_traf;
   stdt(dt66);
  end; 
  if rtdt(dt65)>10000 then begin
   //result:=
   render_net(fps);   
   stdt(dt65);
  end;    
 end;   
 if feats.server_on then begin
  mutex_release(net_mx); 
  sleep(1000 div 64);
  mutex_lock(net_mx);
 end;      
 {$ifndef no_render}
 cfps:=fps;     
 update_all;            
 result:=render_all;       
 {$endif}
end;  
//############################################################################// 
//Finish output
procedure ogla_out2D;stdcall;
begin try                   
 {$ifndef no_render}        
 render_own_info(@scene);    
 glFlush;          
 doglswap(@gwin);   
 {$else}
 d2o_cur:=0;                          
 {$endif}
 except on ex:exception do stderr('OGLAUX','(ogla_out2D) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;    
//############################################################################// 
//First run - init ogla
procedure ogla_firstrun; stdcall;
begin    
 {$ifndef no_render}
 initogla;
 {$ifdef orulex}dp_init(true,'textures\');{$endif}
 render_splash('Loading Bases and vessels');
 {$endif}
 if feats.server_on then net_init;
 firstrun:=false;
end;          
//############################################################################// 
//############################################################################//                     
procedure ogla_initgl(hwnd:dword;w,h:pdword;vd:pVIDEODATA); stdcall;
var rc:trect;
ambcol:crgba;
begin try   
 winh:=hwnd;  
 SetWindowText(hwnd,'OGLAClient Server loading');    
 dt62:=getdt;
 dt63:=getdt;
 dt65:=getdt;
 stdt(dt63); 
 stdt(dt62); 
 stdt(dt65);   
 mutex_lock(net_mx);
             
 {$ifndef no_render}   
 ambcol:=pcrgba(getconfigparam(CFGPRM_AMBIENTLEVEL))^;
 gl_amb.x:=ambcol[0]/255;
 gl_amb.y:=ambcol[0]/255;
 gl_amb.z:=ambcol[0]/255;  
 scene.feat.clouds:=pbyte(getconfigparam(CFGPRM_CLOUDS))^<>0;
 scene.feat.cloudshadows:=pbyte(getconfigparam(CFGPRM_CLOUDSHADOWS))^<>0;
 scene.feat.max_plnt_lv:=pdword(getconfigparam(CFGPRM_SURFACEMAXLEVEL))^;
      
 if not vd.fullscreen then GetClientRect(hwnd,rc) else SetRect(rc,0,0,vd.winw,vd.winh);            
 w^:=rc.Right;h^:=rc.bottom; 
 
 gwin.fs:=vd.fullscreen;   
 gwin.pd:=32;
 gwin.wnd:=hwnd; 
 gwin.wid:=rc.Right;
 gwin.hei:=rc.bottom;
 if not setoglwin(@gwin) then bigerror(0,'');            
 scrx:=gwin.wid;  
 scry:=gwin.hei;  
   
 SetWindowText(hwnd,'Loading...');  
 glgr_init;     
 shaderlog_name:='ogla.log'; 
 orulexlog_name:='ogla.log'; 
 if gl_12_sup then wr_log('INIT','GPU supports OpenGL 1.2') else wr_log('INIT','GPU does not support OpenGL 1.2 (Problem)');
 if gl_14_fbo_sup then wr_log('INIT','GPU supports OpenGL 1.4') else wr_log('INIT','GPU does not support OpenGL 1.4 (No MFDs and panels)');
 if gl_2_sup then wr_log('INIT','GPU supports OpenGL 2.0') else wr_log('INIT','GPU does not support OpenGL 2.0 (No advanced graphics)');
 wr_log('INIT','glgruva='+stri(ord(glgruva))+', usevbo='+stri(ord(usevbo))+', vboav='+stri(ord(vboav))+', glgr_stensh_aupd='+stri(ord(glgr_stensh_aupd))+', gvsync='+stri(ord(gvsync))+', gl_comp_sup='+stri(ord(gl_comp_sup))+', gl_shm4='+stri(ord(gl_shm4)));
 if not gl_comp_sup then wr_log('RNDR','Warning: Texture compression unsupported.'); 
                     
 sysogla.texdir:=orb_texdir;
 sysogla.mshdir:=orb_mshdir;
 sysogla.gwin:=@gwin;
 scene.hei:=gwin.hei;        
 scene.wid:=gwin.wid;    
 scene.sys:=@sysogla;

 common_main_init_sys(@scene);
 ogli.font_mode^:=3;//feats.font_mode;

 if scene.feat.rayleigh then if not fileexists('textures\inscatter.bin')then begin
  scene.feat.rayleigh:=false;
  wr_log('RNDR','Warning: Raytraced haze requested, but no tables found. Run scatter_gen.exe.'); 
 end;

 init_splash; 
 glClearColor(0.8,0.8,0.8,1);
 render_splash('Loading Orbiter core'); 
 initgraph;  
 
 oglaset_shaders(@scene);
 
 feats.camx:=10;
 feats.camy:=gwin.hei-275;
 ogli.shfps:=1;          
 {$endif} 
  
 except on ex:exception do stderr('OGLAINIT','(ogla_initgl) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;   
//############################################################################// 
//oapi init, local interface init 
procedure initint(a:ilp); stdcall;
begin //try
 initoapi(a);
 initstr:=initstrs;
 {$ifndef no_render}
 set_log('ogla.log');
 if use_zgl then wr_log('INIT','OGLA v'+oglaver+' (ZGL)')
            else wr_log('INIT','OGLA v'+oglaver+' (GLGR)');
 {$endif}  
 //except on ex:exception do stderr('INIT','(initint) '+ex.message+' (hc='+stri(ex.helpcontext)+') (log='+stri(ord(logable))+', initstr='+initstr+')'); end;
end;
//############################################################################// 
//oapi init, local interface init 
procedure ogla_interface_get(ogl:pogla_interface);stdcall;
begin  
 ogl.initgl  :=ogla_initgl;
 ogl.render  :=ogla_render;
 ogl.loadtex :=ogla_loadtex;
 ogl.reltex  :=ogla_reltex;
 ogl.getsdc  :=ogla_getsdc;
 ogl.relsdc  :=ogla_relsdc;
 ogl.gsrfsiz :=ogla_gsrfsiz;
 ogl.maksrf  :=ogla_maksrf;
 ogl.fillsr  :=ogla_fillsr;
 ogl.out2D   :=ogla_out2D;
 ogl.firstrun:=ogla_firstrun;
 ogl.meshop  :=ogla_meshop;
 ogl.render2D:=ogla_render2D;
 ogl.addps   :=ogla_addps;
 ogl.blit    :=ogla_blit;
 ogl.keydown :=ogla_keydown;
 ogl.keyup   :=ogla_keyup;
 ogl.mouse   :=ogla_mouse;   
 ogl.o2_op   :=o2_op;

 render_font:=ogl.render_font;
 text_width:=ogl.text_width;
 
 getbase:=ogl.getbase;
 visop:=ogl.visop;
 vcsurf:=ogl.vcsurf;
 getconfigparam:=ogl.getconfigparam;
 getmsurf:=ogl.getmsurf;

 ogli:=ogl;
end;
//############################################################################//
//DLL Exports
exports
initint,
ogla_interface_get
{$ifndef no_render}
,
oglcSetFlags,
oglcAddLight,
oglcBindLightThruster,
oglcBindLightAnim,
oglcLightRemove,
oglcBindTexture,
oglcBindExtMesh
{$endif}
;    
//############################################################################// 
procedure load_ogla_feats_net;
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
 end;
end;
//############################################################################//
//############################################################################//
begin
 firstrun:=true;
 initstr :=''; 

 {$ifndef no_render}
 common_main_init_sys(@scene);     
 ildmsg:=render_loaddlg;
 Rndspl:=render_splash;  //For orbitergl
 Rndprg:=render_loaddlg; //For orbitergl    
 {$else}
 load_ogla_feats_net;
 feats.server_on:=true;
 {$endif}   
 if do_check_ng then if lowercase(copy(paramstr(0),length(paramstr(0))-25,26))<>lowercase('Modules\Server\orbiter.exe') then begin
  messagebox(0,'Hi, it''s OGLAClient.'#13#10'You appear to have enabled me from orbiter.exe instead of orbiter_ng.exe.'#13#10'If i''m mistaken or so is your plan, disable this check in video tab.','Message',MB_OK);
 end;

 lrndseed:=65774;  
end. 
//############################################################################//
