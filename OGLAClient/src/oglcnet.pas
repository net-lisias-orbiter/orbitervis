//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLAClient network system
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglcnet;
interface
uses windows,messages,blcksock,synsock,synautil,sysutils,asys,grph,strval,tim,maths,
oglcvar,oapi,oglctypes,glras_surface,orbitergl,ogladata,lzw;   
//############################################################################//
var pan_msh:typmsh;
pan_idx:array of integer;
pan_mat:mat;
pan_idx_lng:integer;   
pan_trans:boolean;
pan_ex:boolean=false;

d2os:array of id2opck;
d2o_cnt:integer=0;
d2os_siz:integer=0;
d2o_cur:integer=0;
//############################################################################//
procedure net_init;  
function render_net(fps:integer):integer; stdcall;
procedure xmit_panel(hSurf:papinteger;hMesh:pointer;t:pmat;transparent:boolean);     
function o2_op_net(tp:integer;srf:pinteger;x0,y0,x1,y1:integer;fnam:pchar;len:dword):integer;stdcall;        
//############################################################################//
implementation     
//############################################################################//
var
terminated:boolean=false;
netthr_thr_id:integer=0;
netthr_tid:cardinal;
clithr_thr_id:integer=0;
clithr_tid:cardinal;  

dt49:integer; 
//############################################################################//
type 
xmittyp=record
 go_vecs:boolean;
 sock:TTCPBlockSocket;
 usock:TUDPBlockSocket;
end;   
//############################################################################//
procedure xmt_sendbuf(var xmt:xmittyp;buf:pointer;bs:integer;force_tcp:boolean);
begin
 if use_udp and(not force_tcp)then xmt.usock.SendBuffer(buf,bs) else xmt.sock.SendBuffer(buf,bs);  
end;   
//############################################################################//
procedure xmt_sendpacket(var xmt:xmittyp;force_tcp:boolean;tp:byte;buf:pointer;bs:integer);
var sbuf:pointer;
begin
 getmem(sbuf,bs+5);
 pbyte(sbuf)^:=tp;        
 pdword(dword(sbuf)+1)^:=bs;   
 move(buf^,pdword(dword(sbuf)+5)^,bs);
 xmt_sendbuf(xmt,sbuf,bs+5,force_tcp);  
 net_traf:=net_traf+bs+5;
end;
//############################################################################//
procedure sendplanets(var xmt:xmittyp);  
var buf:pointer;
bs,i,n:integer;   
d:ohnd;  
p:array[0..255]of char;
m:mat; 
s:string;
h:oplhazetyp;

iplnt:iplntpck;
begin    
 getmem(buf,net_sml_buffer_size);
 n:=0;  
 bs:=4;
 for i:=0 to 255 do p[i]:=#0; 
 
 mutex_lock(net_mx);
 for i:=0 to oapiGetObjectCount-1 do begin
  d:=oapiGetObjectByIndex(i);
  if oapiGetObjectType(d)<>OBJTP_PLANET then continue;  
   
  oapiGetObjectName(d,p,255);        
  iplnt.nam:=string(p);
  oapiGetGlobalPos(d,@iplnt.pos);
  oapiGetGlobalVel(d,@iplnt.vel);
  oapiGetRotationMatrix(d,@m); 
  iplnt.rot:=tamat(m);
  iplnt.ob:=d;
  iplnt.rad:=oapigetsize(d); 
  iplnt.mass:=oapigetmass(d); 
  iplnt.isatm:=ord(oapiPlanetHasAtmosphere(d)); 
  
  //Haze
  if oapiPlanetHasAtmosphere(d) then begin
   h.rad:=oapigetsize(d);
   gethaze(@h,d,s);  
   iplnt.h:=h;
  end;
  //Rings
  //if pbytebool(oapiGetObjectParam(d,OBJPRM_PLANET_HASRINGS))^ then oglasetplntring(scn.plnt[n],pdouble(oapiGetObjectParam(d,OBJPRM_PLANET_RINGMINRAD))^,pdouble(oapiGetObjectParam(d,OBJPRM_PLANET_RINGMAXRAD))^);
  //Init state
  //updoplanet(scn,scn.plnt[n]);      
  //updoplanetcl(scn,scn.plnt[n]); 
  move(iplnt,pdword(dword(buf)+dword(bs))^,sizeof(iplnt));  
  bs:=bs+sizeof(iplnt);
  n:=n+1;
 end;  
 mutex_release(net_mx); 
 pdword(dword(buf)+0)^:=n;
 xmt_sendpacket(xmt,true,ord('p'),buf,bs);
 freemem(buf);
end;  
//############################################################################//
procedure sendvess(var xmt:xmittyp);  
var buf:pointer;
bs:integer;   
var i,c:integer;
ob:ohnd;
//vs:pointer; 
p:array[0..255]of char;
ives:ivespck;
begin        
 getmem(buf,net_sml_buffer_size);
 bs:=4;
 for i:=0 to 255 do p[i]:=#0;  

 c:=0;  
 mutex_lock(net_mx);
 for i:=0 to oapiGetObjectCount-1 do begin
  ob:=oapiGetObjectByIndex(i);    
  if (oapiGetObjectType(ob)<>OBJTP_VESSEL) then continue;
  
  //vs:=oapiGetVesselInterface(ob);  
  
  oapiGetObjectName(ob,p,255);         
  ives.nam:=string(p);
  oapiGetGlobalPos(ob,@ives.pos);   
  oapiGetGlobalVel(ob,@ives.vel);     
  oapiGetRotationMatrix(ob,@ives.rotm);
  ives.id:=ob;
  ives.rad:=oapigetsize(ob);     
  ives.mass:=oapigetmass(ob); 
  
  move(ives,pdword(dword(buf)+dword(bs))^,sizeof(ives)); 
  bs:=bs+sizeof(ives);
        
  c:=c+1;
 end;    
 mutex_release(net_mx);  
 pdword(dword(buf)+0)^:=c;
 xmt_sendpacket(xmt,true,ord('i'),buf,bs);
 freemem(buf);  
end;
//############################################################################//
procedure sendmsh(var xmt:xmittyp;msh:ptypmsh;id,n:integer;vis:dword;lock:boolean);  
var buf,dst:pointer;
bs,ds:dword;   
i,j:integer;
imsh:imshpck;
igrp:imshgrppck;
begin 
 if msh=nil then exit;
 getmem(buf,net_buffer_size);
 getmem(dst,net_buffer_size);
 bs:=0;
 if lock then mutex_lock(net_mx);

 imsh.flg:=msh.flg;
 imsh.grc:=msh.grc;
 imsh.txc:=msh.txc;
 imsh.vis:=vis;
 imsh.id:=id;
 imsh.n:=n;
 move(imsh,pdword(dword(buf)+dword(bs))^,sizeof(imsh)); 
 bs:=bs+sizeof(imsh);

 for i:=0 to msh.grc-1 do begin
  igrp.pnts_cnt:=length(msh.grp[i].pnts);
  igrp.trng_cnt:=length(msh.grp[i].trng);
  igrp.tx:=msh.grp[i].dif.tx;
  igrp.center:=msh.grp[i].center;
  igrp.col:=msh.grp[i].col;
  igrp.cole:=msh.grp[i].cole;
  igrp.cols:=msh.grp[i].cols;
  igrp.spow:=msh.grp[i].spow;
  igrp.typ:=msh.grp[i].typ;
  igrp.tag:=msh.grp[i].tag;
  igrp.orbTexIdx:=msh.grp[i].orbTexIdx;  
  igrp.xmit_tx:=msh.grp[i].xmit_tx;  
  move(igrp,pdword(dword(buf)+dword(bs))^,sizeof(igrp)); 
  bs:=bs+sizeof(igrp);        
  for j:=0 to length(msh.grp[i].pnts)-1 do begin
   move(msh.grp[i].pnts[j],pdword(dword(buf)+dword(bs))^,sizeof(msh.grp[i].pnts[j])); 
   bs:=bs+sizeof(msh.grp[i].pnts[j]);   
  end;        
  for j:=0 to length(msh.grp[i].trng)-1 do begin
   move(msh.grp[i].trng[j],pdword(dword(buf)+dword(bs))^,sizeof(msh.grp[i].trng[j])); 
   bs:=bs+sizeof(msh.grp[i].trng[j]);   
  end;
 end;
 mutex_release(net_mx);   
 if use_comp then begin
  ds:=bs;
  encodeLZW(buf,dst,ds);  
  xmt_sendpacket(xmt,true,ord('m'),dst,ds);
 end else begin    
  xmt_sendpacket(xmt,true,ord('m'),buf,bs);
 end;
 freemem(buf); 
 freemem(dst); 
end;      
//############################################################################//
procedure sendvessmsh(var xmt:xmittyp);  
var i,j:integer;
ob:ohnd;
vs:pointer; 
hmesh:pointer;
nmesh:integer;  
msh:ptypmsh;  
vis:dword; 
ofs:vec;
begin     
 for i:=0 to oapiGetObjectCount-1 do begin
  ob:=oapiGetObjectByIndex(i);    
  if (oapiGetObjectType(ob)<>OBJTP_VESSEL) then continue;
  
  vs:=oapiGetVesselInterface(ob);  

  nmesh:=vesGetMeshCount(vs);
  for j:=0 to nmesh-1 do begin
   hMesh:=vesGetMeshTemplate(vs,j);
   msh:=getmsh(hMesh); 
  
   vis:=vesGetMeshVisibilityMode(vs,j);
   vesGetMeshOffset(vs,j,@ofs); 
  
   if(hmesh<>nil)and(msh<>nil)then begin
    //copy from preloaded template
    sendmsh(xmt,msh,ob,j,vis,true);
   end else begin
    //load on the fly and discard after copying        
    hMesh:=vesCopyMeshFromTemplate(vs,j);
    sendmsh(xmt,ldmsh(hMesh),ob,j,vis,true);
    //oapiDeleteMesh(hMesh);
   end;  
  end;  
 end;     
end;
//############################################################################//
procedure sendstars(var xmt:xmittyp);  
var buf:pointer;
bs,i,j:integer;   
d:ohnd;
tvn:vec;
p:array[0..255]of char;
s:string;
begin    
 getmem(buf,net_sml_buffer_size);
 //Suns  
 mutex_lock(net_mx);
 j:=0; 
 bs:=9;
 for i:=0 to oapiGetObjectCount-1 do begin
  d:=oapiGetObjectByIndex(i);             
  if oapiGetObjectType(d)<>OBJTP_star then continue;
     
  oapiGetGlobalPos(d,@tvn); 
  oapiGetObjectName(d,p,255);
  s:=p;
              
  pdword(dword(buf)+dword(bs))^:=length(s);
  move(s[1],pbyte(dword(buf)+dword(bs+4))^,length(s));
  bs:=bs+4+length(s);
     
  pdword(dword(buf)+dword(bs+0))^:=d;
  move(tvn,pbyte(dword(buf)+dword(bs+4))^,24);
  pdouble(dword(buf)+dword(bs+28))^:=oapigetsize(d); 
  pcrgba(dword(buf)+dword(bs+36))^:=tcrgba($ff,$f2,$a1,255);
  bs:=bs+40;
     
  j:=j+1;
 end;    
 mutex_release(net_mx); 
  
 pbyte(buf)^:=ord('s');
 pdword(dword(buf)+5)^:=j;  
 pdword(dword(buf)+1)^:=bs;
 xmt_sendbuf(xmt,buf,bs,true);    
 net_traf:=net_traf+bs;
 freemem(buf);
end; 
//############################################################################//
procedure sendnebs(var xmt:xmittyp);  
var buf:pointer;
bs:integer;  
begin    
 getmem(buf,net_sml_buffer_size);
 //Nebs               
 mutex_lock(net_mx);
 //setlength(scene.nebs,0);
 //scene.nebcnt:=0;
 pbyte(buf)^:=ord('n');
 pdword(dword(buf)+1)^:=9;
 pdword(dword(buf)+5)^:=0;  
 mutex_release(net_mx); 
 bs:=9;
 xmt_sendbuf(xmt,buf,bs,true);   
 net_traf:=net_traf+bs;
 freemem(buf);
end;   
//############################################################################//
procedure sendvecs(var xmt:xmittyp;first:boolean); 
var buf,dst:pointer;
bs,i,n,sc,pc:integer;   
ds:dword;
d:ohnd;
tvn:vec;
full:boolean;
dt:int64;

var atmp:pATMCONST;
cdist:double;
prm:ATMPARAM;

vpck:vecspck;
apck:atmpck;
mpck:mainpck;
begin
 full:=first;    
 dt:=rtdt(dt49);
 if dt>60e6 then begin
  stdt(dt49);
  full:=true;
 end;
 
 getmem(buf,net_sml_buffer_size);
 getmem(dst,net_sml_buffer_size);  
 bs:=4;
 n:=0;sc:=0;pc:=0;

 //State vectors 
 mutex_lock(net_mx); 

 vpck.tp:=1;  
 vpck.id:=0;
 vpck.v1:=net_cpos;
 vpck.v2:=net_cdir;
 vpck.v3:=net_ctgt;
 vpck.m1:=net_cm;   
 move(vpck,pbyte(dword(buf)+dword(bs))^,sizeof(vpck));
 bs:=bs+sizeof(vpck);

 mpck.apr:=net_capr;
 mpck.invc:=net_cinvc;
 mpck.tgtvel:=net_ctgtvel;
 move(mpck,pbyte(dword(buf)+dword(bs))^,sizeof(mpck));
 bs:=bs+sizeof(mpck);
 n:=n+1;
 
 for i:=0 to oapiGetObjectCount-1 do begin
  d:=oapiGetObjectByIndex(i);             
  if oapiGetObjectType(d)=OBJTP_star then if full then begin
   vpck.tp:=2;
   vpck.id:=sc;     
   oapiGetGlobalPos(d,@vpck.v1);  
   oapiGetGlobalVel(d,@vpck.v2);  
   oapiGetRotationMatrix(d,@vpck.m1); 
   sc:=sc+1; 
   
   move(vpck,pbyte(dword(buf)+dword(bs+0))^,sizeof(vpck));
   bs:=bs+sizeof(vpck);      
   n:=n+1;
  end;           
  if oapiGetObjectType(d)=OBJTP_PLANET then begin
   vpck.tp:=3;
   vpck.id:=pc;
   pc:=pc+1;  
   oapiGetGlobalPos(d,@vpck.v1);   
   if not full then if modv(subv(net_cpos,vpck.v1))>1e9 then continue;   
   
   oapiGetGlobalVel(d,@vpck.v2);  
   oapiGetRotationMatrix(d,@vpck.m1);  
   move(vpck,pbyte(dword(buf)+dword(bs+0))^,sizeof(vpck));
   bs:=bs+sizeof(vpck);

   if oapiPlanetHasAtmosphere(d) then begin
    atmp:=oapiGetPlanetAtmConstants(d);    
    oapiCameraGlobalPos(@tvn);  
    cdist:=modv(subv(vpck.v1,tvn));

    apck.radlimit:=atmp.radlimit;
    apck.cldrot:=pdouble(oapiGetObjectParam(d,OBJPRM_PLANET_CLOUDROTATION))^;
    //if cdist<(atmp^.radlimit) then begin  
     oapiGetPlanetAtmParams(d,cdist,@prm); 
     apck.rho:=prm.rho;
     apck.rho0:=atmp.rho0;
     apck.color0:=atmp.color0;
    //end;
    move(apck,pbyte(dword(buf)+dword(bs+0))^,sizeof(apck));   
    bs:=bs+sizeof(apck);
   end; 
   
   n:=n+1;
  end;     
  if oapiGetObjectType(d)=OBJTP_VESSEL then begin
   vpck.tp:=4;
   vpck.id:=d;     
   oapiGetGlobalPos(d,@vpck.v1);  
   if not full then if modv(subv(net_cpos,vpck.v1))>1e6 then continue;   
   
   oapiGetGlobalVel(d,@vpck.v2);   
   oapiGetRotationMatrix(d,@vpck.m1);  
   vpck.b1:=oapiCameraInternal and (d=oapiGetFocusObject);
   move(vpck,pbyte(dword(buf)+dword(bs+0))^,sizeof(vpck));
   bs:=bs+sizeof(vpck);  
   n:=n+1;
  end;
 end; 
 mutex_release(net_mx); 
                  
 pdword(dword(buf)+0)^:=n;  
 if use_comp then begin
  ds:=bs;
  encodeLZW(buf,dst,ds);  
  xmt_sendpacket(xmt,false,ord('v'),dst,ds);
 end else begin    
  xmt_sendpacket(xmt,false,ord('v'),buf,bs);
 end;
 
 freemem(buf);
 freemem(dst);
end;  
//############################################################################//
procedure sendtexs(var xmt:xmittyp); 
var buf,dst:pointer;
bs,i,n:integer;   
ds:dword;
itex:itexpck;
begin 
 getmem(buf,net_med_buffer_size);
 getmem(dst,net_med_buffer_size);  
 bs:=4;
 n:=0;

 //State vectors 
 mutex_lock(net_mx);                                                       /////FIXME/////////
 for i:=0 to length(texres)-1 do if texres[i]<>nil then if(texres[i].used){and(texres[i].xmit)}then begin
  texres[i].xmit:=false; 
  
  itex.id:=i;
  itex.w:=texres[i].w;
  itex.h:=texres[i].h;
  itex.ckey:=texres[i].ckey;
  itex.f_clr:=texres[i].f_clr;
  itex.srcn:=texres[i].srcn;
 
  move(itex,pbyte(dword(buf)+dword(bs+0))^,sizeof(itex));
  bs:=bs+sizeof(itex);
  
  n:=n+1;
 end; 
 mutex_release(net_mx); 
                  
 pdword(dword(buf)+0)^:=n;  
 if use_comp then begin
  ds:=bs;
  encodeLZW(buf,dst,ds);  
  xmt_sendpacket(xmt,true,ord('T'),dst,ds);
 end else begin    
  xmt_sendpacket(xmt,true,ord('T'),buf,bs);
 end;
 
 freemem(buf);
 freemem(dst);
end;  
//############################################################################//
procedure send_tx(var xmt:xmittyp;id:integer); 
var buf:pointer;
bs:integer;
n:string;  
itxg:itxgpck;
f:file;
begin       
 bs:=0;
 //Texture 
 mutex_lock(net_mx); 
 if(id<0)or(id>=texcnt)then begin mutex_release(net_mx);exit;end;
 if texres[id]=nil then begin mutex_release(net_mx);exit;end;
 if not texres[id].used then begin mutex_release(net_mx);exit;end;
 n:=string(texres[id].srcn);
 mutex_release(net_mx); 
 
 if trim(n)='' then exit; 
 if fileexists(orb_texdir+'/'+n) then n:=orb_texdir+'/'+n
 else if fileexists(orb_texdir+'2/'+n) then n:=orb_texdir+'2/'+n
 else begin      
  itxg.size:=0;
  itxg.id:=id;   
  getmem(buf,5+sizeof(itxg));
  move(itxg,pbyte(dword(buf)+dword(bs+0))^,sizeof(itxg));
  bs:=bs+sizeof(itxg);     
  xmt_sendpacket(xmt,true,ord('t'),buf,bs);
  freemem(buf);
  exit;
 end; 
         
 
 assignfile(f,n);
 reset(f,1);
 itxg.size:=filesize(f);
 itxg.id:=id;       
 getmem(buf,itxg.size+5+sizeof(itxg));
 move(itxg,pbyte(dword(buf)+dword(bs+0))^,sizeof(itxg));
 bs:=bs+sizeof(itxg);
  
 blockread(f,pbyte(dword(buf)+dword(bs+0))^,itxg.size);  
 bs:=bs+integer(itxg.size);
 closefile(f);
                  
 xmt_sendpacket(xmt,true,ord('t'),buf,bs);
 
 freemem(buf);
end;  
//############################################################################//
procedure sendint(var xmt:xmittyp); 
var buf,dst:pointer;
bs:integer;   
ds:dword;

ipan:ipanpck;
begin   
 if not pan_ex then exit; 
 getmem(buf,net_sml_buffer_size);
 getmem(dst,net_sml_buffer_size);  
 bs:=0;

 //Panels & etc
 mutex_lock(net_mx); 

 ipan.mat:=pan_mat;
 ipan.idx_lng:=pan_idx_lng;
 ipan.trans:=pan_trans; 
 move(ipan,pbyte(dword(buf)+dword(bs))^,sizeof(ipan));
 bs:=bs+sizeof(ipan);

 move(pan_idx[0],pbyte(dword(buf)+dword(bs))^,pan_idx_lng*sizeof(integer)); 
 bs:=bs+pan_idx_lng*sizeof(integer);    

 sendmsh(xmt,@pan_msh,-1,-1,0,false);    
                  
 if use_comp then begin
  ds:=bs;
  encodeLZW(buf,dst,ds);  
  xmt_sendpacket(xmt,false,ord('L'),dst,ds);
 end else begin    
  xmt_sendpacket(xmt,false,ord('L'),buf,bs);
 end;
 
 freemem(buf);
 freemem(dst);
end; 
//############################################################################//
//############################################################################// 
//Network render call
function render_net(fps:integer):integer; stdcall;
{$ifdef no_render}var dc:hdc;{$endif}
begin 
 result:=0;
 conl:=0;
 {$ifdef no_render}
 dc:=GetDC(winh);
 wrcon(dc,'Input goes here.');
 wrcon(dc,'Clients connected: '+stri(net_cls)); 
 wrcon(dc,'Traffic spent: '+stri(net_traf)+ ' bytes');
 wrcon(dc,'Inbound Traffic: '+stri(net_traf_in)+ ' bytes');
 wrcon(dc,'Traffic average: '+stre(net_traf_avg)+ ' Kb/s        ');
 wrcon(dc,'State vector dt: '+stre(1000000/net_stvec_dt)+ ' upd/s         ');
 wrcon(dc,'(Use 1 thru 9 to set)');
 releasedc(winh,dc);
 
 if rtdt(dt63)>100000 then begin
  SetWindowText(winh,pchar('OGLAClient Server running ('+stre(rtdt(dt62)/1000000)+' s)'));
  stdt(dt63);
 end;
 {$endif}
 
  //Update scene
 oapiCameraGlobalPos(              @net_cpos);
 oapiGetGlobalPos(oapiCameraTarget,@net_ctgt);
 oapiGetGlobalVel(oapiCameraTarget,@net_ctgtvel);
 oapiCameraGlobalDir(              @net_cdir);
 oapiCameraRotationMatrix(@net_cm);
 
 net_capr:=oapiCameraAperture;   
 net_cinvc:=ord(oapiCockpitMode=COCKPIT_VIRTUAL);        

 //Update state vectors, load if not loaded
 //Vessel and base meshes are obtained from Orbiter, textures loaded by orbitergl
 //Planet textures and meshes are handled by OGLA entirely
 
 //procplanets(@scene);  
 //procbas(@scene);  
 //procvess(@scene);
end;   
//############################################################################// 
//Render 2D panels
procedure xmit_panel(hSurf:papinteger;hMesh:pointer;t:pmat;transparent:boolean);
var msh:ptypmsh;
i:integer;
begin 
 //if transparent then glBlendFunc(GL_SRC_ALPHA,GL_ONE); 
 //FIXME: Mamory leak ~4Kb/s
 msh:=ldmsh(hMesh,false); 
 if msh=nil then exit;
  
 mutex_lock(net_mx);  
 copy_msh(pan_msh,msh^);
 pan_mat:=t^;
 
 pan_idx_lng:=0;
 for i:=0 to msh.grc-1 do begin
  if msh.grp[i].orbTexIdx>=TEXIDX_MFD0 then begin
  end else pan_idx_lng:=max2i(pan_idx_lng,msh.grp[i].orbTexIdx);
 end;
 pan_idx_lng:=pan_idx_lng+1;
 setlength(pan_idx,pan_idx_lng);
 for i:=0 to pan_idx_lng-1 do begin
  pan_idx[i]:=0;
  if hSurf[i]<>nil then pan_idx[i]:=hSurf[i]^;
 //move(hSurf[0]^,pan_idx[0],pan_idx_lng*sizeof(integer));
 end;
 pan_trans:=transparent;
 pan_ex:=true;
 
 mutex_release(net_mx); 

 //FIXME: Mamory leak ~4Kb/s
 freemsh(msh);
end;      
//############################################################################// 
function o2_op_net(tp:integer;srf:pinteger;x0,y0,x1,y1:integer;fnam:pchar;len:dword):integer;stdcall;
begin 
 result:=0;
 mutex_lock(net_mx);  
 if d2o_cur>=d2o_cnt then begin
  d2o_cnt:=d2o_cnt+1;
  if d2o_cnt>=d2os_siz then begin
   setlength(d2os,d2os_siz*2+1);
   //for i:=d2os_siz to d2os_siz*2-1 do texres[i]:=nil;
   d2os_siz:=d2os_siz*2+1;
  end;
 end; 

 d2os[d2o_cur].tp:=tp;
 if srf=nil then d2os[d2o_cur].srf:=-1 else d2os[d2o_cur].srf:=srf^;
 d2os[d2o_cur].x0:=x0;
 d2os[d2o_cur].x1:=x1;
 d2os[d2o_cur].y0:=y0;
 d2os[d2o_cur].y1:=y1;
 if fnam<>nil then d2os[d2o_cur].fnam:=fnam else d2os[d2o_cur].fnam:='';;
 d2os[d2o_cur].len:=len;

 d2o_cur:=d2o_cur+1;
 mutex_release(net_mx); 
 
 {
       
 if(tp>=6)and(tp<=9)then begin
  pt:=pointer(len);
  npt:=pointer(y0);
 end;
 case tp of 
 
  6:for i:=0 to x0-2 do wrline2D(s.d2.ox+pt[i].x,s.d2.oy+pt[i].y,s.d2.ox+pt[i+1].x,s.d2.oy+pt[i+1].y,s.d2.pncl);
  7:for i:=0 to x0-2 do wrline2D(s.d2.ox+pt[i].x,s.d2.oy+pt[i].y,s.d2.ox+pt[i+1].x,s.d2.oy+pt[i+1].y,s.d2.pncl);
  8:for j:=0 to x0-1 do begin 
   for i:=0 to npt[j]-2 do wrline2D(s.d2.ox+pt[c+i].x,s.d2.oy+pt[c+i].y,s.d2.ox+pt[c+i+1].x,s.d2.oy+pt[c+i+1].y,s.d2.pncl); 
   wrline2D(s.d2.ox+pt[c+npt[j]-1].x,s.d2.oy+pt[c+npt[j]-1].y,s.d2.ox+pt[c].x,s.d2.oy+pt[c].y,s.d2.pncl);
   c:=c+npt[j];
  end;
  9:for j:=0 to x0-1 do begin 
   for i:=0 to npt[j]-2 do wrline2D(s.d2.ox+pt[c+i].x,s.d2.oy+pt[c+i].y,s.d2.ox+pt[c+i+1].x,s.d2.oy+pt[c+i+1].y,s.d2.pncl);
   wrline2D(s.d2.ox+pt[c+npt[j]-1].x,s.d2.oy+pt[c+npt[j]-1].y,s.d2.ox+pt[c].x,s.d2.oy+pt[c].y,s.d2.pncl);
   c:=c+npt[j];
  end;

  17:begin s.d2.fnt:=pointer(len); genfnt(s.d2.fnt);end;
 end;  
 }
end;  
//############################################################################// 
type evt_net_rec=packed record
 id:char;
 sz:dword;
 tp:byte;
 x,y,key:word;
end;
//############################################################################//
function srv_proc_packet(var xmt:xmittyp;buf:pointer;var bs:dword):integer;
var tp:byte;
en:evt_net_rec;
{$ifdef no_render}i:integer;{$endif}
begin 
 result:=0;  
 tp:=pbyte(buf)^; 
 mutex_lock(net_mx);
 case tp of
  1:bs:=bs-6;
  ord('h'):halt;
  ord('m'):begin sendvessmsh(xmt); bs:=bs-5;end;
  ord('v'):begin sendvecs(xmt,true); xmt.go_vecs:=true; bs:=bs-5;end;
  ord('t'):begin send_tx(xmt,pdword(dword(buf)+5)^);bs:=bs-9;end;
  ord('e'):begin 
   move(buf^,en,sizeof(en));
   {$ifdef no_render}
   case en.tp of
    1:begin //up
     if(en.key and 1)<>0 then PostMessage(winh,WM_LBUTTONUP,0,integer(en.x+en.y shl 16));
     if(en.key and 2)<>0 then PostMessage(winh,WM_RBUTTONUP,0,integer(en.x+en.y shl 16));
    end;
    2:begin //dwn
     if(en.key and 1)<>0 then PostMessage(winh,WM_LBUTTONDOWN,0,integer(en.x+en.y shl 16));
     if(en.key and 2)<>0 then PostMessage(winh,WM_RBUTTONDOWN,0,integer(en.x+en.y shl 16));
     if(en.key and 4)<>0 then PostMessage(winh,WM_MOUSEWHEEL,$00780000,integer(en.x+en.y shl 16));
     if(en.key and 8)<>0 then PostMessage(winh,WM_MOUSEWHEEL,$FF880000,integer(en.x+en.y shl 16));
    end;
    3:begin //move
     i:=0;
     if(en.key and 1)<>0 then i:=i+MK_LBUTTON;
     if(en.key and 2)<>0 then i:=i+MK_RBUTTON;
     PostMessage(winh,WM_MOUSEMOVE,i,integer(en.x+en.y shl 16)); 
    end;
    4:PostMessage(winh,WM_KEYDOWN,en.key,0);
    5:PostMessage(winh,WM_KEYUP,en.key,0);
   end;
   {$endif}
   bs:=bs-sizeof(en);
  end;
  else bs:=0;
 end;
 mutex_release(net_mx);
end;
//############################################################################//
procedure srv_get_packet(var xmt:xmittyp);
var buf:pointer;
pck_siz,bs2:dword;
bs_got,bs_left:dword;
begin
 getmem(buf,net_sml_buffer_size);
 bs_got:=xmt.sock.RecvBuffer(buf,net_sml_buffer_size); 
 bs_left:=bs_got;
 net_traf_in:=net_traf_in+integer(bs_got);
 if xmt.sock.lasterror<>0 then exit;  

 while bs_left>0 do begin
  pck_siz:=pdword(dword(buf)+bs_got-bs_left+1)^;
  while bs_left<pck_siz do begin   
   bs2:=xmt.sock.RecvBuffer(pointer(dword(buf)+bs_got),net_sml_buffer_size-integer(bs_got));      
   net_traf_in:=net_traf_in+integer(bs2);
   bs_got:=bs_got+bs2;
   bs_left:=bs_left+bs2;
   if xmt.sock.lasterror<>0 then exit;
  end;                                       
  srv_proc_packet(xmt,pointer(dword(buf)+bs_got-bs_left),bs_left);
 end; 
end;
//############################################################################//
function cli_thr(par:integer):integer;
const blnk:array[0..5]of byte=(1,6,0,0,0,0);
var xmt:xmittyp;
csock:TSocket;
s:string;
//buf:pointer;
//bs:integer;   
dt45,dt46,dt47:integer; 
begin
 net_cls:=net_cls+1;
 result:=0;
 csock:=par;  
 dt49:=getdt;   
 dt45:=getdt;
 dt46:=getdt;
 dt47:=getdt;
 xmt.sock:=TTCPBlockSocket.create;
 if use_udp then xmt.usock:=TUDPBlockSocket.create;
 //getmem(buf,net_sml_buffer_size);
 try
  xmt.go_vecs:=false;
  xmt.Sock.socket:=CSock;
  xmt.sock.GetSins;
  if use_udp then begin
   //xmt.usock.bind('0.0.0.0','15277'); 
   //while xmt.usock.CanRead(100000) do;
   xmt.usock.CreateSocket;
   xmt.usock.connect(xmt.sock.GetRemoteSinIP,stri(xmt.sock.GetRemoteSinPort));
  end;
    
  repeat
   if terminated then break;
   s:=xmt.sock.RecvPacket(1);
   if xmt.sock.lastError<>0 then break;
   if copy(s,1,25)='Orbiter_Givestream_090413' then begin    
    sendnebs(xmt);
    sendstars(xmt);
    sendplanets(xmt); 
    sendtexs(xmt);
    sendvess(xmt);
    
    stdt(dt49);   
    stdt(dt45);
    stdt(dt46);
    stdt(dt47);
    repeat
     if terminated then break;   
     if xmt.sock.WaitingData<>0 then srv_get_packet(xmt);
     if rtdt(dt45)>net_stvec_dt then begin   
      if xmt.go_vecs then begin
       sendvecs(xmt,false); 
       /////////sendtexs(xmt);      //////FIXME - texture update.
       if rtdt(dt47)>1000000 then begin sendint(xmt);stdt(dt47);end;
      end;
      if use_udp then if xmt.usock.lastError<>0 then exit;
      if rtdt(dt46)>2000000 then begin xmt.sock.Sendbuffer(@blnk,6);stdt(dt46);end;
      if xmt.sock.lastError<>0 then exit;
      stdt(dt45);
     end; 
     sleep(net_stvec_dt div 2000);
    until false;

   end else xmt.sock.SendString('Echo: '+s);
   if xmt.sock.lastError<>0 then break;
  until false;   
 finally 
 freedt(dt49);   
 freedt(dt45);
 freedt(dt46);
 freedt(dt47);
 xmt.sock.free;if use_udp then xmt.usock.free; net_cls:=net_cls-1;mutex_release(net_mx); end;
end; 
//############################################################################//
//############################################################################//  
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
function net_thr(par:pointer):integer;
var sock:TTCPBlockSocket;
clientsock:TSocket;
begin
 result:=0;
 sock:=TTCPBlockSocket.Create;
 
 sock.CreateSocket;
 sock.setLinger(true,10);
 sock.bind('0.0.0.0','15276');
 sock.listen; 
 
 repeat
  if terminated then begin sock.free;exit;end;
  if sock.canread(10) then begin
   if sock.WaitingData<>0 then begin
    //srv_get_packet(sock);
    //sock.RecvPacket(60000);
   end;
   ClientSock:=sock.accept;
   if sock.lastError=0 then begin  
    MessageBeep(MB_ICONERROR);
    clithr_thr_id:=BeginThread(nil,0,@cli_thr,pointer(ClientSock),0,clithr_tid);
    //SetThreadPriority(clithr_thr_id,THREAD_PRIORITY_IDLE);
   end;
  end;
  sleep(1000);
 until false;   
end;    
//############################################################################//
//############################################################################//
procedure net_init;
begin
 netthr_thr_id:=BeginThread(nil,0,net_thr,nil,0,netthr_tid);
 //SetThreadPriority(netthr_thr_id,THREAD_PRIORITY_IDLE);
end;
//############################################################################//
begin
 net_mx:=mutex_create;
 mutex_release(net_mx); 
end.   
//############################################################################//
