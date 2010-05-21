//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLAClient network system
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit otnet;
interface
uses sysutils,blcksock,synsock,synautil,strval,maths,asys,grph,lzw,
glgr,grplib,dogl,oglctypes,glras_surface,otvar,oglautil,oglacalc,ogladata,mfd_api;      
//############################################################################//
var pan_msh:typmsh;
pan_idx:array of integer;
pan_mat:mat;
pan_idx_lng:integer;   
pan_trans:boolean;
need_textures_load:boolean=false;
is_link:boolean=false;
was_tx:boolean;

evt_net:array[0..1000] of evt_net_rec;
evt_net_cur:integer=0;
txrs:array[0..1000]of array[0..8]of byte;
txr_cur:integer=0;
txr_wait:integer=0;
kpre:boolean=false;
//############################################################################//   
procedure upd_cur_ves;
procedure net_init;  
//############################################################################//
implementation                                                                   
var gtp:char;
//############################################################################//
var
terminated:boolean=false;
netthr_thr_id:integer=0;
netthr_tid:cardinal;
netthr_thr_udp_id:integer=0;
netthr_udp_tid:cardinal;
//############################################################################//
procedure upd_cur_ves;
begin
 csw_ob.tp:=TYP_VESSEL;
 csw_ob.id:=cur_ves;
 csw_ob.name:=scene.smobs[cur_ves].name;
 csw_ob.m:=scene.smobs[cur_ves].mass;
 csw_ob.r:=scene.smobs[cur_ves].rad;
 csw_ob.pos:=scene.smobs[cur_ves].pos;
 csw_ob.gps:=tvec(0,0,0);
 csw_ob.glp:=tvec(0,0,0);
 csw_ob.vel:=scene.smobs[cur_ves].vel;
 csw_ob.rot:=scene.smobs[cur_ves].rot;
 csw_ob.dir:=tvec(0,0,0);///BAD
 csw_ob.vrot:=tvec(0,0,0);///BAD
 csw_ob.rotm:=atmat(scene.smobs[cur_ves].rot);
end;
//############################################################################//
procedure set_tex(txbuf:pointer;sz:dword;id:integer);
var f:file;
n,d,cd,k:string;
i:integer;
begin     
 if(id<0)or(id>=texcnt)then exit;
 if texres[id]=nil then exit;
 if not texres[id].used then exit;
 
 n:=string(texres[id].srcn);
 if trim(n)='' then exit;
 for i:=1 to length(n) do if n[i]='\' then n[i]:='/';
 i:=getlsymp(n,'/');
 if i=0 then begin
  n:=n;
  d:=orb_texdir;
 end else begin                         
  d:=orb_texdir+'/'+copy(n,1,i-1);
  n:=copy(n,i+1,length(n));
 end;
 if not directoryexists(d) then begin
  getdir(0,cd);
  if(cd[length(cd)]<>'/')and(cd[length(cd)]<>'\')then cd:=cd+'/';  
  k:=cd+d; 
  for i:=1 to length(k) do if k[i]='/' then k[i]:='\';
  forcedirectories(k);
 end;
 assignfile(f,d+'/'+n);
 rewrite(f,1);
 blockwrite(f,txbuf^,sz);
 closefile(f);
 texres[id].toload:=true;
 need_textures_load:=true;
end;
//############################################################################//
procedure chk_tx(id:integer);
var n:string;
i:integer;
begin   
 n:=string(texres[id].srcn);
 for i:=1 to length(n) do if n[i]='\' then n[i]:='/';
      if fileexists(orb_texdir+'/'+n) then n:=orb_texdir+'/'+n
 else if fileexists(orb_texdir+'2/'+n) then n:=orb_texdir+'2/'+n
 else if fileexists(orb_texdir+'/'+lowercase(n)) then n:=orb_texdir+'/'+lowercase(n)
 else if fileexists(orb_texdir+'2/'+lowercase(n)) then n:=orb_texdir+'2/'+lowercase(n) else begin
  txrs[txr_cur][0]:=ord('t');
  pdword(@txrs[txr_cur][1])^:=9;
  pdword(@txrs[txr_cur][5])^:=id;
  txr_cur:=txr_cur+1;
 end;
end;
//############################################################################//
function proc_packet(buf:pointer;var bs:dword):integer;
var i,j,sz,starcnt,nid:integer;
txbuf:pointer;
s:dword;
n:string;
v,v1:vec;
m1:mat;
c:crgba;
r:double;
o:dword;
atm:integer;

tp:byte;
xbuf:pointer;
tex:psurfinfo;

vpck:vecspck;
apck:atmpck;
mpck:mainpck;
iplnt:iplntpck;
ives:ivespck;   
imsh:imshpck; 
igrp:imshgrppck; 
msh:ptypmsh;    
ipan:ipanpck;  
itex:itexpck;
itxg:itxgpck;
begin   
 tp:=pbyte(buf)^;   
 gtp:=chr(tp);
 mutex_lock(net_mx);
 case tp of
  1:bs:=bs-6;
  ord('v'):begin   
   bs:=bs-pdword(dword(buf)+1)^-5;
   if use_comp then begin
    getmem(xbuf,pdword(dword(buf)+1)^*10);
    decodelzw(pdword(dword(buf)+5),xbuf,pdword(dword(buf)+1)^,pdword(dword(buf)+1)^*10);    
    xbuf:=pdword(dword(xbuf)-5);
   end else xbuf:=buf;
   sz:=pdword(dword(xbuf)+5)^;
   s:=9;
   for i:=0 to sz-1 do begin
    move(pbyte(dword(xbuf)+s)^,vpck,sizeof(vpck));
    case vpck.tp of
     1:begin
      scene.cam.pos:=vpck.v1;
      scene.cam.dir:=vpck.v2;
      scene.cam.tgt:=vpck.v3;
      scene.cam.rtmat:=vpck.m1;
      scene.cam.brtmat:=@scene.cam.rtmat;      
      s:=s+sizeof(vpck);
      
      move(pbyte(dword(xbuf)+s)^,mpck,sizeof(mpck));
      scene.camapr:=mpck.apr;
      scene.invc:=mpck.invc<>0;
      scene.cam.tgtvel:=mpck.tgtvel;
      s:=s+sizeof(mpck);
     end;
     2:begin
      scene.star[vpck.id].pos:=vpck.v1;
      s:=s+sizeof(vpck);
     end;
     3:begin
      scene.plnt[vpck.id].pos:=vpck.v1;
      scene.plnt[vpck.id].vel:=vpck.v2;
      scene.plnt[vpck.id].rot:=tamat(vpck.m1);
      s:=s+sizeof(vpck);

      swmg_planets[vpck.id].pos:=scene.plnt[vpck.id].pos;
      swmg_planets[vpck.id].vel:=scene.plnt[vpck.id].vel;
      swmg_planets[vpck.id].rot:=scene.plnt[vpck.id].rot;
      swmg_planets[vpck.id].rotm:=atmat(scene.plnt[vpck.id].rot);
      
      if scene.plnt[vpck.id].draw.atm then begin  
       move(pbyte(dword(xbuf)+s)^,apck,sizeof(apck));
       scene.plnt[vpck.id].draw.atmradlimit:=apck.radlimit;  
       scene.plnt[vpck.id].draw.clds.rot:=apck.cldrot;
       scene.plnt[vpck.id].draw.atmrho:=apck.rho;
       scene.plnt[vpck.id].draw.atmrho0:=apck.rho0;
       scene.plnt[vpck.id].draw.atmcolor0[0]:=apck.color0.x;
       scene.plnt[vpck.id].draw.atmcolor0[1]:=apck.color0.y;
       scene.plnt[vpck.id].draw.atmcolor0[2]:=apck.color0.z;
       scene.plnt[vpck.id].draw.atmcolor0[3]:=255;
       s:=s+sizeof(apck);
      end;
     end;
     4:begin
      nid:=get_smob_by_id(@scene,vpck.id);
      if nid<>-1 then begin
       scene.smobs[nid].pos:=vpck.v1;
       scene.smobs[nid].vel:=vpck.v2;
       scene.smobs[nid].draw.cp:=vpck.b1;
       scene.smobs[nid].rot:=tamat(vpck.m1); 
       if nid=cur_ves then begin
        csw_ob.pos:=scene.smobs[nid].pos;
        csw_ob.vel:=scene.smobs[nid].vel;
        csw_ob.rot:=scene.smobs[nid].rot;
        csw_ob.rotm:=atmat(scene.smobs[nid].rot);
       end;
      end;
      s:=s+sizeof(vpck);
     end;
     else s:=s+sizeof(vpck);
    end;
   end;
  end;
  ord('T'):begin   
   bs:=bs-pdword(dword(buf)+1)^-5;
   if use_comp then begin
    getmem(xbuf,pdword(dword(buf)+1)^*10);
    decodelzw(pdword(dword(buf)+5),xbuf,pdword(dword(buf)+1)^,pdword(dword(buf)+1)^*10);    
    xbuf:=pdword(dword(xbuf)-5);
   end else xbuf:=buf;
   sz:=pdword(dword(xbuf)+5)^;
   s:=9;
   for i:=0 to sz-1 do begin
    move(pbyte(dword(xbuf)+s)^,itex,sizeof(itex));
    s:=s+sizeof(itex);

    if texcnt<=itex.id then begin
     setlength(texres,itex.id*2+1);
     for j:=texcnt to itex.id*2+1-1 do texres[j]:=nil;
     texcnt:=itex.id*2+1;
    end;
    if texres[itex.id]=nil then new(texres[itex.id]);
    
    need_textures_load:=true;

    texres[itex.id].xmit:=false; 
    texres[itex.id].w:=itex.w; 
    texres[itex.id].h:=itex.h; 
    texres[itex.id].ckey:=itex.ckey; 
    texres[itex.id].f_clr:=itex.f_clr; 
    texres[itex.id].srcn:=itex.srcn; 
    
    texres[itex.id].used:=true; 
    texres[itex.id].tex:=notx; 
    texres[itex.id].d2:=nil;
    texres[itex.id].mag:=SURFH_MAG;
    texres[itex.id].uc:=1;  
    texres[itex.id].global:=false; 
    texres[itex.id].toload:=true;  
    writeln('Received texture description #',i,', "',texres[itex.id].srcn,'"');
    if trim(texres[itex.id].srcn)<>'' then chk_tx(itex.id);
   end;
   if txr_cur=0 then was_tx:=true;
  end;
  ord('t'):begin   
   bs:=bs-pdword(dword(buf)+1)^-5;
   if use_comp then begin
    getmem(xbuf,pdword(dword(buf)+1)^*10);
    decodelzw(pdword(dword(buf)+5),xbuf,pdword(dword(buf)+1)^,pdword(dword(buf)+1)^*10);    
    xbuf:=pdword(dword(xbuf)-5);
   end else xbuf:=buf;
   s:=5;

   txr_wait:=txr_wait-1;

   move(pbyte(dword(xbuf)+s)^,itxg,sizeof(itxg));
   s:=s+sizeof(itxg);

   if itxg.size<>0 then begin
    getmem(txbuf,itxg.size);
    move(pbyte(dword(xbuf)+s)^,txbuf^,itxg.size);   
    writeln('Received texture #',itxg.id);  
    set_tex(txbuf,itxg.size,itxg.id);  
    freemem(txbuf);
   end;
  end;
  ord('m'):begin
   bs:=bs-pdword(dword(buf)+1)^-5;
   if use_comp then begin
    getmem(xbuf,pdword(dword(buf)+1)^*5);
    decodelzw(pdword(dword(buf)+5),xbuf,pdword(dword(buf)+1)^,pdword(dword(buf)+1)^*5);
    xbuf:=pdword(dword(xbuf)-5);
   end else xbuf:=buf;
   s:=5;
   move(pbyte(dword(xbuf)+s)^,imsh,sizeof(imsh));
   s:=s+sizeof(imsh);
   nid:=get_smob_by_id(@scene,imsh.id);
   if nid<>-1 then begin
    writeln('Received mesh #',imsh.n,' for vessel "',scene.smobs[nid].name,'"');
    if scene.smobs[nid].draw.nmesh<=imsh.n then begin
     scene.smobs[nid].draw.nmesh:=imsh.n+1;
     setlength(scene.smobs[nid].draw.mshs,scene.smobs[nid].draw.nmesh);
     setlength(scene.smobs[nid].draw.mshv,scene.smobs[nid].draw.nmesh);
     //new(scene.smobs[nid].draw.mshs[imsh.id]);
    end;
    new(scene.smobs[nid].draw.mshs[imsh.n]);
    msh:=scene.smobs[nid].draw.mshs[imsh.n];  
    scene.smobs[nid].draw.mshv[imsh.n]:=imsh.vis;
   end else begin  
    writeln('Received Panel');
    msh:=@pan_msh;
   end; 
   msh.used:=true;
   msh.flg:=imsh.flg;
   msh.grc:=imsh.grc;
   msh.txc:=imsh.txc;
   msh.need_fin:=false;
   setlength(msh.grp,msh.grc);
   for i:=0 to msh.grc-1 do begin
    mkcln_mshgrp(@msh.grp[i]);    
    move(pbyte(dword(xbuf)+s)^,igrp,sizeof(igrp));
    s:=s+sizeof(igrp); 
    setlength(msh.grp[i].pnts,igrp.pnts_cnt);
    setlength(msh.grp[i].trng,igrp.trng_cnt);
    msh.grp[i].dif.tx:=notx; 
    tex:=txget(@igrp.xmit_tx);
    if tex<>nil then begin
     assert(tex.mag=SURFH_MAG); 
     msh.grp[i].dif.tx:=tex.tex;
    end;
    msh.grp[i].center:=igrp.center;
    msh.grp[i].col:=igrp.col;
    msh.grp[i].cole:=igrp.cole;
    msh.grp[i].cols:=igrp.cols;
    msh.grp[i].spow:=igrp.spow;
    msh.grp[i].typ:=igrp.typ;
    msh.grp[i].tag:=igrp.tag;
    msh.grp[i].orbTexIdx:=igrp.orbTexIdx;  
    for j:=0 to igrp.pnts_cnt-1 do begin
     move(pbyte(dword(xbuf)+s)^,msh.grp[i].pnts[j],sizeof(msh.grp[i].pnts[j]));
     s:=s+sizeof(msh.grp[i].pnts[j]); 
    end;
    for j:=0 to igrp.trng_cnt-1 do begin
     move(pbyte(dword(xbuf)+s)^,msh.grp[i].trng[j],sizeof(msh.grp[i].trng[j]));
     s:=s+sizeof(msh.grp[i].trng[j]); 
    end;
   end;
  end;
  ord('L'):begin
   bs:=bs-pdword(dword(buf)+1)^-5;
   if use_comp then begin
    getmem(xbuf,pdword(dword(buf)+1)^*5);
    decodelzw(pdword(dword(buf)+5),xbuf,pdword(dword(buf)+1)^,pdword(dword(buf)+1)^*5);
    xbuf:=pdword(dword(xbuf)-5);
   end else xbuf:=buf;
   s:=5;
   move(pbyte(dword(xbuf)+s)^,ipan,sizeof(ipan));
   s:=s+sizeof(ipan);

   pan_mat:=ipan.mat;
   pan_idx_lng:=ipan.idx_lng;
   pan_trans:=ipan.trans; 

   setlength(pan_idx,pan_idx_lng);
   move(pbyte(dword(buf)+dword(s))^,pan_idx[0],pan_idx_lng*sizeof(integer));   
   setlength(pan_idx,pan_idx_lng+1);
   //s:=s+pan_idx_lng*sizeof(integer); 
  end;
  ord('h'):halt;
  ord('n'):begin 
   scene.nebcnt:=pdword(dword(buf)+5)^;
   bs:=bs-9;
  end;
  ord('s'):begin 
   starcnt:=pdword(dword(buf)+5)^; 
   s:=9;
   setlength(scene.star,starcnt);
   for i:=0 to starcnt-1 do begin
    new(scene.star[i]);
    setlength(n,pdword(dword(buf)+s)^);
    move(pdword(dword(buf)+s+4)^,n[1],pdword(dword(buf)+s)^);
    s:=s+4+dword(length(n));
       
    o:=pdword(dword(buf)+s)^;       
    move(pbyte(dword(buf)+s+4)^,v,24);
    r:=pdouble(dword(buf)+s+28)^; 
    move(pbyte(dword(buf)+s+36)^,c,4);
    s:=s+40;
       
    oglaset_star(scene.star[i],n,o,v,r,c);
   end;  
   bs:=bs-s;
  end;
  ord('p'):begin    
   setlength(scene.plnt,pdword(dword(buf)+5)^); 
   swmg_planets_cnt:=pdword(dword(buf)+5)^; 
   setlength(swmg_planets,swmg_planets_cnt);
    
   s:=9;
   for i:=0 to length(scene.plnt)-1 do begin
    move(pbyte(dword(buf)+s)^,iplnt,sizeof(iplnt));
    new(scene.plnt[i]);
    new(scene.plnt[i].draw);
  
    //Rndspl('Loading Planets ('+n+')'); 
       
    //Basics
    oglaset_plntbase(@scene,scene.plnt[i],iplnt.nam,iplnt.ob,iplnt.pos,iplnt.rot,iplnt.rad,iplnt.isatm<>0);
    scene.plnt[i].mass:=iplnt.mass;
    
    //Haze
    if scene.plnt[i].draw.atm then begin  
     scene.plnt[i].draw.haze^:=iplnt.h;
     scene.plnt[i].draw.haze^.tx:=dhtx;
    end;
    //Rings
    //if pbytebool(oapiGetObjectParam(d,OBJPRM_PLANET_HASRINGS))^ then oglasetplntring(scn.plnt[n],pdouble(oapiGetObjectParam(d,OBJPRM_PLANET_RINGMINRAD))^,pdouble(oapiGetObjectParam(d,OBJPRM_PLANET_RINGMAXRAD))^);

    new(swmg_planets[i]);
    swmg_planets[i].tp:=TYP_PLANET;
    swmg_planets[i].id:=i;
    swmg_planets[i].name:=scene.plnt[i].name;
    swmg_planets[i].m:=scene.plnt[i].mass;
    swmg_planets[i].r:=scene.plnt[i].rad;
    swmg_planets[i].pos:=scene.plnt[i].pos;
    swmg_planets[i].gps:=tvec(0,0,0);
    swmg_planets[i].glp:=tvec(0,0,0);
    swmg_planets[i].vel:=scene.plnt[i].vel;
    swmg_planets[i].rot:=scene.plnt[i].rot;
    swmg_planets[i].dir:=tvec(0,0,0);///BAD
    swmg_planets[i].vrot:=tvec(0,0,0);///BAD
    swmg_planets[i].rotm:=atmat(scene.plnt[i].rot);
    swmg_planets[i].ref:=nil;
    
    s:=s+sizeof(iplnt);
    //Init state
    //updoplanet(@scene,scene.plnt[i]);       
    //updoplanetcl(@scene,scene.plnt[i]);
   end;  
   bs:=bs-s;
  end; 
  ord('i'):begin   {
   if iss_m=nil then begin
    new(iss_m);
    loadmsh(iss_m,'Meshes/ProjectAlpha_ISS.msh','Textures/');
   end;    }

   setlength(scene.smobs,pdword(dword(buf)+5)^);
   s:=9;
   for i:=0 to length(scene.smobs)-1 do begin
    move(pbyte(dword(buf)+s)^,ives,sizeof(ives));
    new(scene.smobs[i]);
    new(scene.smobs[i].draw);

    scene.smobs[i].name:=ives.nam;
    scene.smobs[i].rad:=ives.rad;
    scene.smobs[i].id:=ives.id;
    scene.smobs[i].pos:=ives.pos;
    scene.smobs[i].vel:=ives.vel;
    scene.smobs[i].mass:=ives.mass;
    scene.smobs[i].tp:=SMOB_VESSEL; //FIXME
    scene.smobs[i].rot:=tamat(ives.rotm);
       

    scene.smobs[i].draw.nanim:=0;
    scene.smobs[i].draw.anim:=nil; 
    setlength(scene.smobs[i].draw.animstate,0);
    setlength(scene.smobs[i].draw.exh,0);
    
    scene.smobs[i].draw.obj:=nil; 
    scene.smobs[i].draw.semit:=0;
    scene.smobs[i].draw.lights_cnt:=0;
    setlength(scene.smobs[i].draw.lights,scene.smobs[i].draw.lights_cnt);
    scene.smobs[i].draw.vc_shadows:=false;


    scene.smobs[i].draw.nmesh:=0;
    setlength(scene.smobs[i].draw.mshs,scene.smobs[i].draw.nmesh);
    setlength(scene.smobs[i].draw.mshv,scene.smobs[i].draw.nmesh);
                      {
    scene.smobs[i].draw.mshv[0]:=MESHVIS_EXTERNAL;
    scene.smobs[i].draw.mshs[0]:=iss_m;
    scene.smobs[i].draw.drmsh:=true;
    scene.smobs[i].draw.apr:=10;    
    scene.smobs[i].draw.anim:=nil;
    scene.smobs[i].draw.nanim:=0;  
    scene.smobs[i].draw.cp:=false;
    scene.smobs[i].draw.lt0:=tquat(1,1,1,1);  
            }
    if i=cur_ves then upd_cur_ves;
            
    s:=s+sizeof(ives);
   end;
   bs:=bs-s;
  end;
  else bs:=0;
 end;
 mutex_release(net_mx);
end;
//############################################################################//
function net_thr_udp(port:integer):integer;
label 2;
var usock:TUDPBlockSocket;     
buf:pointer;
pck_siz,bs2:dword;
bs_got,bs_left:dword;
begin          
 usock:=nil;result:=0;  
 getmem(buf,net_buffer_size);
 try      
  usock:=TUDPBlockSocket.Create;
  usock.bind('0.0.0.0',stri(port));
  repeat
   //usock:=TUDPBlockSocket.Create;
   //usock.Connect(net_srv,'15277');
   if usock.lasterror<>0 then begin writeln('No link, ',usock.LastErrorDesc);sleep(1000);usock.closesocket;usock.free;usock:=nil;end 
                         else break;
  until false;

  repeat  
   bs_got:=usock.RecvBuffer(buf,net_buffer_size);
   bs_left:=bs_got;
   if usock.lasterror<>0 then begin writeln('Link lost (1, ',gtp,', bs_left=',bs_left,',bs_got=',bs_got,', pck_siz=',pck_siz,'), ',usock.LastErrorDesc);usock.closesocket;usock.free;usock:=nil;exit;end;       
   while bs_left>0 do begin
    pck_siz:=pdword(dword(buf)+bs_got-bs_left+1)^;
    while bs_left<pck_siz do begin   
     bs2:=usock.RecvBuffer(pointer(dword(buf)+bs_got),net_buffer_size-bs_got);
     bs_got:=bs_got+bs2;
     bs_left:=bs_left+bs2;
     if usock.lasterror<>0 then begin writeln('Link lost(2, ',gtp,', bs_left=',bs_left,',bs_got=',bs_got,', pck_siz=',pck_siz,', ntp=',pchar(dword(buf)+0)^,'), ',usock.LastErrorDesc);usock.closesocket;usock.free;usock:=nil;exit;end;
    end;                                       
    proc_packet(pointer(dword(buf)+bs_got-bs_left),bs_left);
    while need_textures_load do sleep(10);
   end;  
  until false;

   
  usock.closesocket;
 finally freemem(buf);usock.Free; end;
end;
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
function net_thr(par:pointer):integer;
label 1;
var sock:TTCPBlockSocket;
buf:pointer;
pck_siz,bs2:dword;
bs_got,bs_left:dword;
i:integer;
begin
 sock:=nil;result:=0;
 getmem(buf,net_buffer_size);
 try
  repeat
   1:
   sock:=TTCPBlockSocket.Create;
   sock.Connect(net_srv,'15276');
   if sock.lasterror<>0 then begin writeln('No link, ',sock.LastErrorDesc);is_link:=false;  sleep(1000);sock.closesocket;sock.free;sock:=nil;end 
                        else break;
  until false;

  if use_udp then netthr_thr_udp_id:=BeginThread(nil,0,@net_thr_udp,pointer(sock.getlocalsinport),0,netthr_udp_tid);
  sock.SendString('Orbiter_Givestream_090413');
  is_link:=true;
  
  repeat  
   while sock.WaitingData=0 do begin
    if kpre then begin
     mutex_lock(net_mx);
     kpre:=false;
     for i:=0 to evt_net_cur-1 do begin
      evt_net[i].id:='e';
      evt_net[i].sz:=sizeof(evt_net[i]);
      sock.Sendbuffer(@evt_net[i],sizeof(evt_net[i]));
     end;
     evt_net_cur:=0;
     mutex_release(net_mx);
    end;
    if txr_cur>0 then begin
     mutex_lock(net_mx);
     txr_wait:=txr_wait+txr_cur;
     for i:=0 to txr_cur-1 do sock.Sendbuffer(@txrs[i],9);
     was_tx:=true;
     txr_cur:=0;
     mutex_release(net_mx);
    end;
    sleep(1);
   end; 
    
   bs_got:=sock.RecvBuffer(buf,net_buffer_size);
   bs_left:=bs_got;
   if sock.lasterror<>0 then begin writeln('Link lost (1, ',gtp,', bs_left=',bs_left,',bs_got=',bs_got,', pck_siz=',pck_siz,'), ',sock.LastErrorDesc);is_link:=false;sock.closesocket;sock.free;sock:=nil;sleep(1000);goto 1;end;       
   while bs_left>0 do begin
    pck_siz:=pdword(dword(buf)+bs_got-bs_left+1)^;
    while bs_left<pck_siz do begin   
     bs2:=sock.RecvBuffer(pointer(dword(buf)+bs_got),net_buffer_size-bs_got);
     bs_got:=bs_got+bs2;
     bs_left:=bs_left+bs2;
     if sock.lasterror<>0 then begin writeln('Link lost(2, ',gtp,', bs_left=',bs_left,',bs_got=',bs_got,', pck_siz=',pck_siz,', ntp=',pchar(dword(buf)+0)^,'), ',sock.LastErrorDesc);is_link:=false;sock.closesocket;sock.free;sock:=nil;sleep(1000);goto 1;end;
    end;                                       
    proc_packet(pointer(dword(buf)+bs_got-bs_left),bs_left);
    while need_textures_load do sleep(10);
    if was_tx and(txr_wait=0)then begin
     sock.SendString('m'#5#0#0#0);
     sock.SendString('v'#5#0#0#0);
     was_tx:=false;
    end;
   end;  
  until false;
  
  sock.closesocket;
 finally freemem(buf);sock.Free; end;
end;
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
