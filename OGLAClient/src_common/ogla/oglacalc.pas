//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA Processimgs
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglacalc;
interface     
uses {$ifdef win32}windows,{$else}cthreads,{$endif}
sysutils,math,asys,log,maths,strval,grph,grplib,glgr,dds,opengl1x,dpringbs,procgenlib
{$ifdef orulex},dynplntutil,dynplnt{$endif},{wsutil,wsgrutil,}ogladata,oglasmobs;
//############################################################################//
                             
function getskycol(scn:poglascene;pln:poglas_planet;grnd:boolean=false):crgba;       
function getob_apr(scn:poglascene;gp:vec;s:double):double;
function updoplanet_grnd(scn:poglascene;pln:poglas_planet):integer; 
function updoplanet_clds(scn:poglascene;pln:poglas_planet):integer;   
function updoplanet_lgts(scn:poglascene;pln:poglas_planet):integer;   
procedure ogla_reupdatevals(scn:poglascene);  
{$ifdef orulex}procedure ogla_saferegraph;{$endif}

//############################################################################// 
{$ifdef orulex}       
var gentexthr_running:boolean=false;
gentexthr_inproc:boolean=false;
gentexthr_term:boolean=false;
gentexthr_lv:integer;
gentexthr_thr_id:integer=0;
gentexthr_id:intptr;
gentexthr_pln:poglas_planet;
gentexthr_op:popmeshrec;
gentexthr_scn:poglascene;
//gentexthr_tid:intptr;
gentexthr_post:string;
{$endif}       
//############################################################################//
implementation  
//############################################################################// 
//Sky color calculation
function getskycol(scn:poglascene;pln:poglas_planet;grnd:boolean=false):crgba;
var col:crgba;
cd:crgbad;
cdist,coss,intens:double;
i:integer;
begin try
 col:=tcrgba(0,0,0,0);
 cd:=tcrgbad(0,0,0,0);
 if pln.draw.atm then begin
  cdist:=modv(pln.cpos);
  if cdist<(pln.draw.atmradlimit)then begin
   coss:=smulv(nrvec(pln.cpos),nrvec(pln.pos));
   if not grnd then intens:=min2(1,(1.0839*coss+0.4581))*sqrt(pln.draw.atmrho/pln.draw.atmrho0)
               else intens:=min2(1,(1.0839*coss+0.4581))*sqrt(1);
   if(intens>0)then cd:=tcrgbad(pln.draw.atmcolor0[0]*intens,pln.draw.atmcolor0[1]*intens,pln.draw.atmcolor0[2]*intens,1);
   cd[3]:=min2(intens,0.85);
  end;
  for i:=0 to 3-1 do if(cd[i]>1)then cd[i]:=1;
  col[0]:=round(cd[0]*255);col[1]:=round(cd[1]*255);col[2]:=round(cd[2]*255);col[3]:=round(cd[3]*255);
 end;
 result:=col; 
 except stderr('ORBGL','Error in getskycolor'); end; 
end;       
//############################################################################// 
procedure mk_hazemsh(msh:ptypmsh;nseg:integer);
var i,j:integer;
phi:double;
begin
 setlength(hcosp,nseg);
 setlength(hsinp,nseg);
 msh.grc:=3;  
 msh.used:=true;     
 setlength(msh.grp,3);   
 for i:=0 to 2 do begin
  msh.grp[i].col:=tcrgba(255,255,255,255); 
 
  msh.grp[i].typ:=0;
  msh.grp[i].static:=false;

  setlength(msh.grp[i].trng,nseg*2+2);
  setlength(msh.grp[i].pnts,nseg*2);

  for j:=0 to nseg-1 do begin
   msh.grp[i].trng[j*2+0]:=j*2+1;
   msh.grp[i].trng[j*2+1]:=j*2;
  end; 
  msh.grp[i].trng[nseg*2+0]:=1;
  msh.grp[i].trng[nseg*2+1]:=0;     
 
  for j:=0 to nseg-1 do begin
   msh.grp[i].pnts[j*2+0].tx.x:=j mod 2; 
   if msh.grp[i].pnts[j*2+0].tx.x=1 then msh.grp[i].pnts[j*2+0].tx.x:=1 else if msh.grp[i].pnts[j*2+0].tx.x=0 then msh.grp[i].pnts[j*2+0].tx.x:=0;
   msh.grp[i].pnts[j*2+1].tx.x:=j mod 2;  
   if msh.grp[i].pnts[j*2+1].tx.x=1 then msh.grp[i].pnts[j*2+1].tx.x:=1 else if msh.grp[i].pnts[j*2+1].tx.x=0 then msh.grp[i].pnts[j*2+1].tx.x:=0;
   msh.grp[i].pnts[j*2+0].tx.y:=1;
   msh.grp[i].pnts[j*2+1].tx.y:=0;
   phi:=j/nseg*PI*2;
   hcosp[j]:=cos(phi);
   hsinp[j]:=sin(phi);
  end;             
 end;
end;
//############################################################################// 
function getob_apr(scn:poglascene;gp:vec;s:double):double;
var alt:double;
begin result:=0; try   
 alt:=max(1,modv(subv(gp,scn.cam.pos))-s);
 result:=s*scn.hei*0.5/(alt*tan(scn.camapr));   
 except stderr('Graph','Error in getobapr'); end;  
end;      
//############################################################################// 
procedure mshgrp_from_tile(t:ptilet;g:ptypmshgrp;tx:cardinal;yoff,scl1:double;id:integer);
var mx,my,mz,xx,xy,xz:double;
i:integer;
begin
 t^.msh:=g;t^.tx:=tx;t^.scl1:=scl1;t^.yoff:=yoff;
 t^.id:=id;
 mx:=1e100;my:=1e100;mz:=1e100;xx:=-1e100;xy:=-1e100;xz:=-1e100;
 for i:=0 to length(g^.pnts)-1 do begin
  if g^.pnts[i].pos.x<mx then mx:=g^.pnts[i].pos.x;
  if g^.pnts[i].pos.y<my then my:=g^.pnts[i].pos.y;
  if g^.pnts[i].pos.z<mz then mz:=g^.pnts[i].pos.z;
  if g^.pnts[i].pos.x>xx then xx:=g^.pnts[i].pos.x;
  if g^.pnts[i].pos.y>xy then xy:=g^.pnts[i].pos.y;
  if g^.pnts[i].pos.z>xz then xz:=g^.pnts[i].pos.z;
 end;
 t^.bh:=tvec(mx,my,mz);t^.bl:=tvec(xx,xy,xz);
 t^.med:=vmid2(t^.bh,t^.bl);
 t^.rad:=max2(modv(subv(t^.bh,t^.med)),modv(subv(t^.bl,t^.med)));
 g^.static:=true;
end;         
//############################################################################// 
// Planet patch level computation
function plres(scn:poglascene;pln:poglas_planet):integer;
var alt,apr,ntx,cdist:double;
new_patchres:integer;
begin result:=0; try
 cdist:=modv(pln.cpos);
 if cdist=0 then exit;
 alt:=max(1,cdist-pln.rad);
 apr:=pln.rad*scn.hei*0.5/(alt*tan(scn.camapr));
 if apr>1e100 then exit;
 
 if(apr<PIX_LIM) then begin
  new_patchres:=0;
  //ntx:=0;
 end else begin
  ntx:=PI*2*apr;
  new_patchres:=10;                    
  if(ntx<32768)then new_patchres:=9;
  if(ntx<16384)then new_patchres:=8;  
  if(ntx<8192)then new_patchres:=7;  
  if(ntx<4096)then new_patchres:=6; 
  if(ntx<2048)then new_patchres:=5; 
  if(ntx<512)then new_patchres:=3;
  if(ntx<256)then new_patchres:=2;
  if(ntx<128)then new_patchres:=1;
 end;
 result:=new_patchres;  
 except stderr('ORBGL','Error in plres'); end; 
end;    
//############################################################################//
//############################################################################// 
{$ifdef orulex}
procedure gentex(scn:poglascene;l:integer;pln:poglas_planet;op:popmeshrec;post:string;src:integer=0); forward;
//############################################################################// 
procedure ogla_saferegraph;
begin
 {$ifdef win32}                                           
 if gentexthr_thr_id<>0 then terminatethread(gentexthr_thr_id,0);
 {$else}
 if gentexthr_thr_id<>0 then killthread(gentexthr_thr_id);
 {$endif}
 gentexthr_thr_id:=0;
 gentexthr_inproc:=false;
 gentexthr_running:=false;
end;
//############################################################################// 
function gentexthr(par:pointer){$ifdef cpu64}:int64;register;{$else}:integer;{$endif}
begin
 result:=0;
 gentex(gentexthr_scn,gentexthr_lv,gentexthr_pln,gentexthr_op,gentexthr_post,1);
                          
 gentexthr_running:=false;    
 gentexthr_thr_id:=0;
end;
//############################################################################// 
//############################################################################// 
procedure gentex(scn:poglascene;l:integer;pln:poglas_planet;op:popmeshrec;post:string;src:integer=0);   
const pi2=pi/2;pi3=pi/3;pi4=pi/4;pi6=pi/6;pi8=pi/8;pi9=pi/9;pi12=pi/12;pi14=pi/14;pi15=pi/15;pi16=pi/16;  
var i,j,x,y,re,lv,cnt,bo,po,pl:dword;
la,lo:double;
v:vec;
tp:integer;
id:cardinal;
begin 
 lo:=0;la:=0;bo:=0;cnt:=0;
 //Rest      
 //pln.draw.dynpl.maxcloudgenlv:=5;
 if post='_cloud' then begin
  tp:=1;            
  if l>pln.draw.dynpl.maxcloudgenlv then l:=pln.draw.dynpl.maxcloudgenlv;
  op.avl:=pln.draw.dynpl.maxcloudgenlv;
 end else begin     
  tp:=0;
  if l>pln.draw.dynpl.maxgenlv then l:=pln.draw.dynpl.maxgenlv;    
  op.avl:=pln.draw.dynpl.maxgenlv;
 end;
 if l<=0 then exit;
 if l<=op.curld then exit;
 if pln.draw.dynpl=nil then exit;
 if not pln.draw.dynpl.used then rmplinit(pln.draw.dynpl,1); 
 if tp=0 then if @pln.draw.dynpl.fgetc=nil then exit;
 if tp=1 then if @pln.draw.dynpl.fgetv=nil then exit;



 
 if src=0 then begin
  if gentexthr_running or gentexthr_inproc then exit;
  gentexthr_running:=true;
  gentexthr_inproc:=true;
  gentexthr_lv:=l;
  gentexthr_pln:=pln;
  gentexthr_id:=pln.obj;
  gentexthr_post:=post;
  gentexthr_op:=op;
  gentexthr_scn:=scn;
  {$ifdef win32}gentexthr_thr_id:=BeginThread(nil,0,gentexthr,nil,0,id);{$else}gentexthr_thr_id:=BeginThread(gentexthr);{$endif}
  exit;
 end;  


 
 if op.curld=0 then op.cnt:=0;
 po:=op.cnt;  
 case po of
  0:pl:=1;
  1:pl:=2;
  2:pl:=3;
  3:pl:=4;
  5:pl:=5;
  13:pl:=6;
  37:pl:=7;
  137:pl:=8;
  else exit;
 end;
 
 case l of
  1:op.cnt:=1;
  2:op.cnt:=2;
  3:op.cnt:=3;
  4:op.cnt:=5;   
  5:op.cnt:=13; 
  6:op.cnt:=37;
  7:op.cnt:=137;
  8:op.cnt:=501;  
 end;
 setlength(op.tx,op.cnt); 
 setlength(op.ptx,op.cnt);
 for i:=po to op.cnt-1 do op.ptx[i]:=nil;
 


 for lv:=pl to l do begin
  case lv of
   1:begin cnt:=1;bo:=0;end;
   2:begin cnt:=1;bo:=1;end;
   3:begin cnt:=1;bo:=2;end;
   4:begin cnt:=2;bo:=3;end;
   5:begin cnt:=8;bo:=5;end;
   6:begin cnt:=24;bo:=13;end;
   7:begin cnt:=100;bo:=37;end;
   8:begin cnt:=364;bo:=137;end;
  end;


  for i:=0 to cnt-1 do begin   
   re:=64;
   if lv=2 then re:=128;
   if lv>=3 then re:=256;
   getmem(op.ptx[bo+i],re*re*4);
   
   for y:=0 to re-1 do for x:=0 to re-1 do begin
    if gentexthr_term then begin
     gentexthr_term:=false;        
     gentexthr_running:=false;    
     gentexthr_thr_id:=0;  
     gentexthr_inproc:=false;   
     for j:=po to op.cnt-1 do if op.ptx[j]<>nil then begin freemem(op.ptx[j]);op.ptx[j]:=nil;end;
     exit;
    end;
    case lv of
     1..4:begin
      if lv<=3 then lo:=(x/re)*2*pi+pi+pi;
      if lv=4 then begin
       if i=0 then lo:=(x/re)*pi;
       if i=1 then lo:=(x/re)*pi+pi;
      end;
      la:=pi2-(y/re)*pi;
     end;
     5:begin
      if i<4  then begin la:= pi2-(y/re)*pi2;lo:= (x/re)*pi2+pi2* i;   end;
      if i>=4 then begin la:=-pi2+(y/re)*pi2;lo:=-(x/re)*pi2-pi2*(i-4);end;
     end;
     6:begin
      if(i<4)           then begin la:= pi2-(y/re)*pi4;lo:= (x/re)*pi2+pi2* i;    end;
      if(i>= 4)and(i<12)then begin la:= pi4-(y/re)*pi4;lo:= (x/re)*pi4+pi4*(i- 4);end;
      if(i>=12)and(i<16)then begin la:=-pi2+(y/re)*pi4;lo:=-(x/re)*pi2-pi2*(i-12);end;
      if(i>=16)         then begin la:=-pi4+(y/re)*pi4;lo:=-(x/re)*pi4-pi4*(i-16);end;
     end;
     7:begin
      if(i<6)           then begin la:= pi2      -(y/re)*pi8;lo:= (x/re)*pi3+pi3* i;    end;
      if(i>= 6)and(i<18)then begin la:= pi2-  pi8-(y/re)*pi8;lo:= (x/re)*pi6+pi6*(i- 6);end;
      if(i>=18)and(i<34)then begin la:= pi2-2*pi8-(y/re)*pi8;lo:= (x/re)*pi8+pi8*(i-18);end;
      if(i>=34)and(i<50)then begin la:= pi2-3*pi8-(y/re)*pi8;lo:= (x/re)*pi8+pi8*(i-34);end;
      if(i>=50)and(i<56)then begin la:=-pi2      +(y/re)*pi8;lo:=-(x/re)*pi3-pi3*(i-50);end;
      if(i>=56)and(i<68)then begin la:=-pi2+  pi8+(y/re)*pi8;lo:=-(x/re)*pi6-pi6*(i-56);end;
      if(i>=68)and(i<84)then begin la:=-pi2+2*pi8+(y/re)*pi8;lo:=-(x/re)*pi8-pi8*(i-68);end;
      if(i>=84)         then begin la:=-pi2+3*pi8+(y/re)*pi8;lo:=-(x/re)*pi8-pi8*(i-84);end;
     end;
     8:begin
      if(i<6)             then begin la:= pi2       -(y/re)*pi16;lo:= (x/re)*pi3 +pi3*  i;    end;      
      if(i>=  6)and(i< 18)then begin la:= pi2-1*pi16-(y/re)*pi16;lo:= (x/re)*pi6 +pi6* (i- 6);end;      
      if(i>= 18)and(i< 36)then begin la:= pi2-2*pi16-(y/re)*pi16;lo:= (x/re)*pi9 +pi9* (i-18);end;
      if(i>= 36)and(i< 60)then begin la:= pi2-3*pi16-(y/re)*pi16;lo:= (x/re)*pi12+pi12*(i-36);end;
      if(i>= 60)and(i< 88)then begin la:= pi2-4*pi16-(y/re)*pi16;lo:= (x/re)*pi14+pi14*(i-60);end;
      if(i>= 88)and(i<118)then begin la:= pi2-5*pi16-(y/re)*pi16;lo:= (x/re)*pi15+pi15*(i-88);end;
      if(i>=118)and(i<150)then begin la:= pi2-6*pi16-(y/re)*pi16;lo:= (x/re)*pi16+pi16*(i-118);end;
      if(i>=150)and(i<182)then begin la:= pi2-7*pi16-(y/re)*pi16;lo:= (x/re)*pi16+pi16*(i-150);end;
      if(i>=182)and(i<188)then begin la:=-pi2       +(y/re)*pi16;lo:=-(x/re)*pi3 -pi3* (i-182);end;
      if(i>=188)and(i<200)then begin la:=-pi2+  pi16+(y/re)*pi16;lo:=-(x/re)*pi6 -pi6* (i-188);end;
      if(i>=200)and(i<218)then begin la:=-pi2+2*pi16+(y/re)*pi16;lo:=-(x/re)*pi9 -pi9* (i-200);end;
      if(i>=218)and(i<242)then begin la:=-pi2+3*pi16+(y/re)*pi16;lo:=-(x/re)*pi12-pi12*(i-218);end;
      if(i>=242)and(i<270)then begin la:=-pi2+4*pi16+(y/re)*pi16;lo:=-(x/re)*pi14-pi14*(i-242);end;
      if(i>=270)and(i<300)then begin la:=-pi2+5*pi16+(y/re)*pi16;lo:=-(x/re)*pi15-pi15*(i-270);end;
      if(i>=300)and(i<332)then begin la:=-pi2+6*pi16+(y/re)*pi16;lo:=-(x/re)*pi16-pi16*(i-300);end;
      if(i>=332)          then begin la:=-pi2+7*pi16+(y/re)*pi16;lo:=-(x/re)*pi16-pi16*(i-332);end;
     end;
    end;  
    
    lo:=lo-pi;
    v.x:=cos(la)*cos(lo);
    v.z:=cos(la)*sin(lo);
    v.y:=sin(la);
    if tp=0 then pbcrgba(op.ptx[bo+i])[x+y*re]:=pln.draw.dynpl.fgetc(pln.draw.dynpl,v,0.1,-3)
            else pbcrgba(op.ptx[bo+i])[x+y*re]:=pln.draw.dynpl.fgetv(pln.draw.dynpl,v);
   end; 
  end;
 end;
end;
{$endif}
//############################################################################//  
//############################################################################// 
procedure load_binfile(scn:poglascene;op:popmeshrec;nm,post:string);
var minres,maxres,flag:byte;
i,idx,maxlv:integer; 
fn:string;  
f:file;
tflag:pworda;
lmfh:LMASKFILEHEADER;    
begin
 if not op.bin_loaded then begin
  op.bin_loaded:=true;
  maxlv:=min2i(MAXPATCHRES,scn.feat.max_plnt_lv);
  
  setlength(op.tiles,patch_idx[maxlv]);
  fillchar(op.tiles[0],patch_idx[maxlv]*sizeof(TILEDESC),0);
	 for i:=0 to patch_idx[maxlv]-1 do op.tiles[i].flag:=1;
  
  if post='_lmask' then begin
   fn:=scn.sys.texdir+'2/'+nm+post+'.bin';
   if not fileexists(fn) then fn:=scn.sys.texdir+'/'+nm+post+'.bin';   
   if fileexists(fn) then begin   
    assignfile(f,fn);
    filemode:=0;
    reset(f,1);
   
    op.nmask:=0;
    //tflag:=nil;
    blockread(f,lmfh,sizeof(lmfh));
    
    if lmfh.id='PLTA0100' then begin // v.1.00 format
     minres:=lmfh.minres;
     maxres:=lmfh.maxres;
     op.npatch:=lmfh.npatch;
     getmem(tflag,op.npatch*2);
     blockread(f,tflag[0],2*op.npatch);
    end else begin                                 // pre-v.1.00 format
     seek(f,0);  
     blockread(f,minres,1);
     blockread(f,maxres,1);
     op.npatch:=patch_idx[maxres]-patch_idx[minres-1];
     getmem(tflag,op.npatch*2);
     for i:=0 to op.npatch-1 do begin  
      blockread(f,flag,1);
      tflag[i]:=flag;
     end;
    end;
    closefile(f);

    idx:=0;
    for i:=0 to patch_idx[maxlv]-1 do begin
     if i<patch_idx[minres-1] then begin
      op.tiles[i].flag:=1; // no mask information -> assume opaque, no lights
     end else begin
      flag:=tflag[idx];
      inc(idx);
      op.tiles[i].flag:=flag;
      if ((flag and 3)=3) or ((flag and 4)<>0) then inc(op.nmask);
     end;
    end;
    if tflag<>nil then freemem(tflag);
   end;
  end;
 end;
end;      
//############################################################################// 
procedure gen_tiles(op:popmeshrec;lv:integer);
var n,j:integer;
begin
 for n:=1 to lv do if not op.sml_tiles[n].done then begin
  setlength(op.sml_tiles[n].til,patch_sml_tiles_cnt[n]);
  op.sml_tiles[n].cnt:=patch_sml_tiles_cnt[n];
  op.sml_tiles[n].done:=true;
  case n of
   1..3:mshgrp_from_tile(@op.sml_tiles[n].til[0],@defmsh[n].grp[0],op.tx[n-1],0,1,n-1);   
   4:begin 
    mshgrp_from_tile(@op.sml_tiles[n].til[0],@defmsh[n].grp[0],op.tx[3],0,1,3);
    mshgrp_from_tile(@op.sml_tiles[n].til[1],@defmsh[n].grp[1],op.tx[4],0,1,4);   
   end;  
   5:begin 
    for j:=0 to 7 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[0],op.tx[05+j],180+nbool(j>3)*j*90,nbool(j<=3),05+j);    
   end;
   6:begin  
    for j:=00 to 03 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[0],op.tx[13+j-00],180-(j-00)*90,1,13+j-00);
    for j:=04 to 11 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[1],op.tx[17+j-04],180-(j-04)*45,1,17+j-04);
    for j:=12 to 19 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[1],op.tx[29+j-12],180+(j-12)*45,-1,29+j-12);
    for j:=20 to 23 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[0],op.tx[25+j-20],180+(j-20)*90,-1,25+j-20); 
   end;
   7:begin  
    for j:=00 to 05 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[0],op.tx[037+j],180-(j-00)*60,1,037+j);
    for j:=06 to 17 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[1],op.tx[037+j],180-(j-06)*30,1,037+j);
    for j:=18 to 33 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[2],op.tx[037+j],180-(j-18)*22.5,1,037+j);
    for j:=34 to 49 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[3],op.tx[037+j],180-(j-34)*22.5,1,037+j);
   
    for j:=50 to 99 do mshgrp_from_tile(@op.sml_tiles[n].til[j],op.sml_tiles[n].til[j-50].msh,op.tx[037+j],360-op.sml_tiles[n].til[j-50].yoff,-1,037+j);  
   end;
   8:begin    
    for j:=000 to 005 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[0],op.tx[137+j],180-(j-000)*60,1,137+j);
    for j:=006 to 017 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[1],op.tx[137+j],180-(j-006)*30,1,137+j); 
    for j:=018 to 035 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[2],op.tx[137+j],180-(j-018)*20,1,137+j); 
    for j:=036 to 059 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[3],op.tx[137+j],180-(j-036)*15,1,137+j);  
    for j:=060 to 087 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[4],op.tx[137+j],180-(j-060)*12.857142857142857142857142857143,1,137+j);
    for j:=088 to 117 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[5],op.tx[137+j],180-(j-088)*12,1,137+j); 
    for j:=118 to 149 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[6],op.tx[137+j],180-(j-118)*11.25,1,137+j); 
    for j:=150 to 181 do mshgrp_from_tile(@op.sml_tiles[n].til[j],@defmsh[n].grp[7],op.tx[137+j],180-(j-150)*11.25,1,137+j); 
    
    for j:=182 to 363 do mshgrp_from_tile(@op.sml_tiles[n].til[j],op.sml_tiles[n].til[j-182].msh,op.tx[137+j],360-op.sml_tiles[n].til[j-182].yoff,-1,137+j);
   end;
   else exit;
  end;
 end;
end;
//############################################################################// 
{$ifdef orulex}
procedure applygen(pln:poglas_planet;op:popmeshrec;var lv:integer);
var i,j:integer;
begin try
 pln.draw.genused:=true;  
 lv:=gentexthr_lv; 
 for i:=lv-1 to op.cnt-1 do begin  
  case i of
   0:j:=64;
   1:j:=128;
   else j:=256;
  end;
  glgr_make_tex(op.tx[i],j,j,op.ptx[i],false,true,true,false); 
  freemem(op.ptx[i]);
  op.ptx[i]:=nil;  
  op.curld:=lv;
 end;    
 gentexthr_inproc:=false;
 except on e:exception do stderr('ORBGL','Error in applygen, '+e.message); end; 
end;
{$endif}   
//############################################################################// 
procedure proc_lv1to8(scn:poglascene;pln:poglas_planet;op:popmeshrec;nm,post:string;var lv:integer);
var s:string; 
lt:boolean;  
i,j:integer;  
w,h,c,l:aointeger;
pp:apointer;     
tx_tmp:array of cardinal; 
begin try
 if (lv>op.curld)and(lv<=op.avl) then begin       
  if lv>8 then exit;  
  s:='Loading '+scn.sys.texdir+'/'+nm+post+'.tex ';
  
  lt:=true;
       if not loadtex(scn.sys.texdir+'2/'+nm+post+'.tex',w,h,op.cnt,pp,c,l,gl_comp_sup)
  then if not loadtex(scn.sys.texdir+'/' +nm+post+'.tex',w,h,op.cnt,pp,c,l,gl_comp_sup)
  then if not loadtex(scn.sys.texdir+'/plntdefault_'+stri(pln.draw.dtn)+post+'.tex',w,h,op.cnt,pp,c,l,gl_comp_sup) then lt:=false;

  if not lt then begin   
   if pln.draw.gen then begin    
    {$ifdef orulex}
     lv:=op.curld+1;     
     gentex(scn,lv,pln,op,post);     

     if(not gentexthr_running)and(gentexthr_inproc)and(pln.obj=gentexthr_id)and(post=gentexthr_post)then begin     
      applygen(pln,op,lv);  
     end else begin  
      lv:=op.curld;  
      s:=s+'ERROR';   
     end;
    {$else}
     lv:=0;   
     s:=s+'ERROR';
    {$endif}
   end else begin
    lv:=0;      
    s:=s+'ERROR';
   end;     
  end else begin  
   s:=s+'OK';
   setlength(op.tx,op.cnt);
    
   if gl_comp_sup then for i:=0 to op.cnt-1 do glgr_make_texfcomp(op.tx[i],w[i],h[i],pp[i],c[i],l[i],scn.feat.tx_compress,scn.feat.tx_smooth,true)
                  else for i:=0 to op.cnt-1 do glgr_make_tex     (op.tx[i],w[i],h[i],pp[i]          ,scn.feat.tx_compress,scn.feat.tx_smooth,true,scn.feat.tx_mipmap);
   for i:=0 to op.cnt-1 do freemem(pp[i]);
              	
   setlength(pp,0);
   setlength(w,0);
   setlength(h,0);
   setlength(c,0);
   setlength(l,0);
         
   if post='_lmask' then if op.bin_loaded then begin  
    setlength(tx_tmp,op.cnt);
    move(op.tx[0],tx_tmp[0],op.cnt*4);
    setlength(op.tx,op.npatch);
    
    j:=0;
    for i:=0 to op.npatch-1 do begin
     op.tx[i]:=notx;
     if ((op.tiles[i].flag and 3)=3) or ((op.tiles[i].flag and 4)<>0) then begin
      op.tx[i]:=tx_tmp[j];
      j:=j+1;
     end;
    end;
    setlength(tx_tmp,0);
    op.cnt:=op.npatch;  
   end;  
   
   case op.cnt of
    1:lv:=1;
    2:lv:=2;
    3:lv:=3;
    5:lv:=4;
    13:lv:=5;
    37:lv:=6;
    137:lv:=7;
    501:lv:=8;
    else if op.cnt>501 then lv:=MAXPATCHRES;
   end;  

   op.avl:=lv;
   op.curld:=lv;
  end;  
  if lt then wr_log('PLNT',s); 
 end{$ifdef orulex} else if pln.draw.gen then if(not gentexthr_running)and(gentexthr_inproc)and(pln.obj=gentexthr_id)and(post=gentexthr_post)then applygen(pln,op,lv){$endif};
          
 if(op.curld>0)and(lv=0)then if(not pln.draw.gen)or(not pln.draw.genused)then begin     
  if op.tx[0]<>4294967295 then glDeleteTextures(op.cnt,@op.tx[0]); 
  for i:=0 to length(op.tx)-1 do op.tx[i]:=0; 
  for i:=1 to MAXPATCHRES do begin
   setlength(op.sml_tiles[i].til,0);
   op.sml_tiles[i].cnt:=0;
   op.sml_tiles[i].done:=false;
  end;
  setlength(op.tx,0);
  op.curld:=0;
  wr_log('PLNT','Released '+nm+post+'.tex ');   
 end;   
 except stderr('ORBGL','Error in proc_lv1to8'); end; 
end;
//############################################################################// 
function transopmesh(scn:poglascene;pln:poglas_planet;op:popmeshrec;nm,post:string):integer;
var lv:integer;
begin result:=0;try  
 lv:=plres(scn,pln);   
 if lv<0 then lv:=0;   
 if lv>MAXPATCHRES then lv:=MAXPATCHRES; 
 if lv>scn.feat.max_plnt_lv then lv:=scn.feat.max_plnt_lv;   
 if op.avl>0 then if lv>op.avl then lv:=op.avl;    
 
 if not op.umshck then begin   
  op.umshck:=true;         
  op.umshav:=fileexists(scn.sys.mshdir+'\'+nm+post+'.msh');    
 end;    
 if op.umsh and op.umshld then exit;     
 if op.umshav and((not op.umsh)or(not op.umshld))then begin  
  if loadmsh(@op.lv0msh,scn.sys.mshdir+'\'+nm+post+'.msh',scn.sys.texdir+'\')=1 then begin 
   op.umsh:=true;   
   op.umshld:=true;    
   glgr_fintex(@op.lv0msh,scn.feat.tx_mipmap); 
   op.lv0msh.used:=true;  
   exit;         
  end else op.umshav:=false;    
 end;       

 load_binfile(scn,op,nm,post);  
 proc_lv1to8(scn,pln,op,nm,post,lv);  
 gen_tiles(op,lv);   
                 
 result:=lv;
 except stderr('ORBGL','Error in transopmesh'); end; 
end;     
//############################################################################//
//############################################################################// 
function updoplanetring(scn:poglascene;pln:poglas_planet):integer;
var i,n,pdc:integer;
w,h,c,l:aointeger;
pp:apointer;
tx:array of cardinal;
s:string;
lt:boolean;
begin n:=0;result:=0;i:=0; try
 if(pln.draw.ringex)and((pln.draw.ringtx[0]=notx)or(pln.draw.ringtx[0]=0))then begin 
  s:='Loading '+scn.sys.texdir+'/'+pln.name+'_ring.tex ';
                 lt:=loadtex(scn.sys.texdir+'2/'+pln.name+'_ring.tex',w,h,pdc,pp,c,l,gl_comp_sup);
  if not lt then lt:=loadtex(scn.sys.texdir+'/'+pln.name+'_ring.tex',w,h,pdc,pp,c,l,gl_comp_sup);  
  if not lt then lt:=loadtex(scn.sys.texdir+'/default_ring.tex',w,h,pdc,pp,c,l,gl_comp_sup);
  
  if not lt then begin 
   if pln.draw.gen then begin
    pln.draw.ringtx[0]:=notx;
    pln.draw.ringtx[1]:=notx;
    if pln.draw.ringtx[2]=notx then pln.draw.ringtx[2]:=defrngtx1;
    setlength(pln.draw.rngcls,10);
    for i:=0 to 10-1 do pln.draw.rngcls[i]:=tcrgbad(random,random,random,1);  
    //setlength(pln.draw.rngcls,h[2]);
    //for i:=0 to h[2]-1 do pln.draw.rngcls[i]:=tcrgba2d(pcrgba(intptr(pp[2])+intptr(w[2] div 2+(h[2]-1-i)*w[2])*sizeof(crgba))^);
    i:=9;
   end;
  end else begin
   s:=s+'OK';
   if pdc>3 then pdc:=3;
   setlength(tx,pdc);
    
   if gl_comp_sup then for i:=0 to pdc-1 do glgr_make_texfcomp(pln.draw.ringtx[i],w[i],h[i],pp[i],c[i],l[i],scn.feat.tx_compress,scn.feat.tx_smooth,true)
                  else for i:=0 to pdc-1 do glgr_make_tex     (pln.draw.ringtx[i],w[i],h[i],pp[i]          ,scn.feat.tx_compress,scn.feat.tx_smooth,true,scn.feat.tx_mipmap);
   
   for i:=0 to pdc-1 do freemem(pp[i]);
   setlength(pp,0);setlength(w,0);setlength(h,0);setlength(c,0);setlength(l,0);

                   
                  lt:=loadtex(scn.sys.texdir+'2/'+pln.name+'_ring.tex',w,h,pdc,pp,c,l,false);
   if not lt then lt:=loadtex(scn.sys.texdir+'/'+pln.name+'_ring.tex',w,h,pdc,pp,c,l,false); 
   if not lt then loadtex(scn.sys.texdir+'/default_ring.tex',w,h,pdc,pp,c,l,false);
  
   setlength(pln.draw.rngcls,h[2]);
   for i:=0 to h[2]-1 do 
    pln.draw.rngcls[i]:=tcrgba2d(pcrgba(intptr(pp[2])+intptr(w[2] div 2+(h[2]-1-i)*w[2])*sizeof(crgba))^);

    
   for i:=0 to pdc-1 do freemem(pp[i]);i:=pdc-1;
   setlength(pp,0);setlength(w,0);setlength(h,0);setlength(c,0);setlength(l,0);
   
  end;
  if lt then wr_log('PLNTR',s);
 end;

 pln.draw.ringmsh.grc:=1;
 setlength(pln.draw.ringmsh.grp,pln.draw.ringmsh.grc);
   
 pln.draw.ringmsh.grp[0].col:=tcrgba(255,255,255,255);
 pln.draw.ringmsh.grp[0].dif.tx:=pln.draw.ringtx[2];
 mk_ringmsh(@pln.draw.ringmsh.grp[0],pln.draw.ringmin,pln.draw.ringmax,8+4*2);
 pln.draw.ringmsh.used:=true;     

 n:=-1;
 except 
  stderr('ORBGL','Error in updoplanetring (n='+stri(n)+' i='+stri(i)+')'); 
 end; 
end;
//############################################################################// 
// Planet loading - making sphere patches
// Needs generalising. 
function updoplanet_grnd(scn:poglascene;pln:poglas_planet):integer;
var i:integer;
begin result:=0;try   
 {$ifdef orulex}
 if scn.feat.orulex then begin
  if pln.draw.dynpl=nil then begin 
   new(pln.draw.dynpl);
   pln.draw.dynpl.used:=false;
  end;
  if(pln.draw.nrst)and(modv(pln.cpos)<4*pln.rad)then if not pln.draw.dynpl.used then begin
   clrpls(pln.draw.dynpl);
        
   pln.draw.dynpl.id:=pln.obj;
   chplanet(pln.draw.dynpl,pln.name,pln.rad);  
   pln.draw.dtn:=pln.draw.dynpl.deftxn;
  end;

  if(pln.draw.nrst)and(modv(pln.cpos)-pln.rad<pln.draw.dynpl.altitude_limit)then if(not pln.draw.dynpl.used)or(not pln.draw.dynpl.lded) then begin
   clrpls(pln.draw.dynpl);

   pln.draw.dynpl.id:=pln.obj;
   chplanet(pln.draw.dynpl,pln.name,pln.rad); 
   pln.draw.dtn:=pln.draw.dynpl.deftxn;
   loadpl(pln.draw.dynpl);
   if scn.skip_step<>nil then scn.skip_step^:=true;
  end; 
 end;
 {$endif}   
 
 if(pln.draw.nrst)and(modv(pln.cpos)<2*pln.rad)then begin
  if pln.draw.ringex then if pln.draw.rng=nil then begin
   new(pln.draw.rng);
   makedpring(pln.draw.rng,pln.draw.ringmin*pln.rad,pln.draw.ringmax*pln.rad);
  
   setlength(pln.draw.rng.rngcls,length(pln.draw.rngcls));
   for i:=0 to length(pln.draw.rngcls)-1 do pln.draw.rng.rngcls[i]:=pln.draw.rngcls[i];  
   dprinit(pln.draw.rng);
  end;
 end;  
             
 if(pln.draw.hazmsh.grc=0)and(pln.draw.haze<>nil)then mk_hazemsh(@pln.draw.hazmsh,HORIZON_HAZE_NSEG);
 updoplanetring(scn,pln);
 result:=transopmesh(scn,pln,@pln.draw.grnd,pln.name,'');

 except stderr('ORBGL','Error in updoplanet_grnd'); end; 
end;  
//############################################################################//
//############################################################################//
function updoplanet_clds(scn:poglascene;pln:poglas_planet):integer;
begin result:=0;try
 if not pln.draw.atm then exit;
 if not pln.draw.haze.hasclouds then exit;
 result:=transopmesh(scn,pln,@pln.draw.clds,pln.name,'_cloud');
 
 except stderr('ORBGL','Error in updoplanet_clds'); end; 
end;    
//############################################################################//
function updoplanet_lgts(scn:poglascene;pln:poglas_planet):integer;
begin result:=0;try
 result:=transopmesh(scn,pln,@pln.draw.lgts,pln.name,'_lmask');
 
 except stderr('ORBGL','Error in updoplanet_lgts'); end; 
end;             
//############################################################################//
procedure ogla_reupdatevals(scn:poglascene);
var i,j,k:integer;
ee,newstate,ds,mm:double;  
d:vec; 
anim:panimationa; 
cl:crgba;
begin try  
 scn.cam.rot:=tamat(scn.cam.rtmat);           
 scn.cam.dir:=tvec(0,0,1); 
 vrotz(scn.cam.dir,-scn.cam.rot.z);
 vroty(scn.cam.dir,-scn.cam.rot.y);
 vrotx(scn.cam.dir,-scn.cam.rot.x);           
 scn.cam.up:=tvec(0,1,0); 
 vrotz(scn.cam.up,-scn.cam.rot.z);
 vroty(scn.cam.up,-scn.cam.rot.y);
 vrotx(scn.cam.up,-scn.cam.rot.x); 
 
 //Planets
 if length(oplbuf)<>length(scn.plnt) then setlength(oplbuf,length(scn.plnt));
 if length(opldsbuf)<>length(scn.plnt) then setlength(opldsbuf,length(scn.plnt));

 for i:=0 to length(scn.plnt)-1 do begin 
  scn.plnt[i].cpos:=subv(scn.plnt[i].pos,scn.cam.pos);  
  //Sunlight from nearest star
  if length(scn.star)<>0 then begin
   mm:=1e100;k:=0;
   for j:=0 to length(scn.star)-1 do if modv(subv(scn.star[j].pos,scn.cam.pos))<mm then begin
    mm:=modv(subv(scn.star[j].pos,scn.cam.pos));
    k:=j;
   end; 
   scn.plnt[i].starlightpos:=scn.star[k].pos; 
   scn.plnt[i].starlightcol:=scn.star[k].col; 
  end;
  
  scn.plnt[i].lcampos:=subv(scn.cam.pos,scn.plnt[i].pos);   
  vrotx(scn.plnt[i].lcampos,scn.plnt[i].rot.x);   
  vroty(scn.plnt[i].lcampos,scn.plnt[i].rot.y); 
  vrotz(scn.plnt[i].lcampos,scn.plnt[i].rot.z); 
 
  scn.plnt[i].lcamdir:=scn.cam.dir;   
  vrotx(scn.plnt[i].lcamdir,scn.plnt[i].rot.x);   
  vroty(scn.plnt[i].lcamdir,scn.plnt[i].rot.y); 
  vrotz(scn.plnt[i].lcamdir,scn.plnt[i].rot.z); 

  scn.plnt[i].lcamrpos:=scn.plnt[i].cpos;
  vrotx(scn.plnt[i].lcamrpos,scn.plnt[i].rot.x);   
  vroty(scn.plnt[i].lcamrpos,scn.plnt[i].rot.y); 
  vrotz(scn.plnt[i].lcamrpos,scn.plnt[i].rot.z);       
  scn.plnt[i].lcamrpos:=nmulv(scn.plnt[i].lcamrpos,-1/scn.plnt[i].rad);  
  
  scn.plnt[i].lstarpos:=subv(scn.plnt[i].starlightpos,scn.plnt[i].pos);   
  vrotx(scn.plnt[i].lstarpos,scn.plnt[i].rot.x);   
  vroty(scn.plnt[i].lstarpos,scn.plnt[i].rot.y); 
  vrotz(scn.plnt[i].lstarpos,scn.plnt[i].rot.z); 
 end;         

 //Vessels & Bases           
 for i:=0 to length(scn.smobs)-1 do if scn.smobs[i]<>nil then begin 
  scn.smobs[i].cpos:=subv(scn.smobs[i].pos,scn.cam.pos); 
                
  ds:=1e100;
  scn.smobs[i].pgpos:=tvec(0,0,0);
  scn.smobs[i].pgsiz:=0;  
  scn.smobs[i].near_plnt:=-1;
  for j:=0 to length(scn.plnt)-1 do if modv(scn.plnt[j].cpos)<ds then begin
   scn.smobs[i].pgpos:=scn.plnt[j].pos;
   scn.smobs[i].pgsiz:=scn.plnt[j].rad;
   scn.smobs[i].near_plnt:=j;
   ds:=modv(scn.plnt[j].cpos);
  end;  
      
  if scn.smobs[i].draw<>nil then begin
   //Planet shadows 
   scn.smobs[i].draw.lt0:=tquat(1,1,1,1);
   if scn.smobs[i].near_plnt<>-1 then begin    
    if scn.feat.starlight_colored then begin
     cl:=scn.plnt[scn.smobs[i].near_plnt].starlightcol;
     scn.smobs[i].draw.lt0:=tquat(cl[0]/255,cl[1]/255,cl[2]/255,1);
    end;
    ee:=line2sph(scn.smobs[i].pos,scn.plnt[scn.smobs[i].near_plnt].starlightpos,scn.smobs[i].pgpos,scn.smobs[i].pgsiz,d); 
    d:=subv(scn.smobs[i].pgpos,d);
    if (ee>0)and(smulv(subv(scn.smobs[i].pgpos,scn.smobs[i].pos),subv(scn.smobs[i].pgpos,scn.plnt[scn.smobs[i].near_plnt].starlightpos))<=0) then begin
     scn.smobs[i].draw.lt0:=tquat(gl_amb.x,gl_amb.y,gl_amb.z,1);
    end else begin
     //scn.smobs[i].draw.lt0:=tquat(min2(1-modv(d)-scn.smobs[i].pgsiz,1),0,0,0);
    end;
   end;
      
   scn.smobs[i].draw.apr:=getob_apr(scn,scn.smobs[i].pos,scn.smobs[i].rad); 
   scn.smobs[i].draw.drmsh:=scn.smobs[i].draw.apr>3; 
  
   //Culling 
   ee:=line2sph(scn.cam.pos,scn.smobs[i].pos,scn.smobs[i].pgpos,scn.smobs[i].pgsiz,d);
   d:=subv(scn.smobs[i].pgpos,d);
   
   if (ee>0)and(scn.smobs[i].pgsiz-modv(d)>scn.smobs[i].rad)and(modvs(subv(subv(scn.smobs[i].pgpos,scn.cam.pos),d))<modvs(subv(scn.cam.pos,scn.smobs[i].pos))) then begin
    scn.smobs[i].draw.drmsh:=false;
    scn.smobs[i].draw.apr:=0;
   end; 
  
   //Animations
   anim:=scn.smobs[i].draw.anim;
   if anim<>nil then for j:=0 to scn.smobs[i].draw.nanim-1 do begin
    if anim[j].ncomp=0 then continue;
    newstate:=anim[j].state;
    if scn.smobs[i].draw.animstate[j]<>newstate then begin
     smob_animate(scn.smobs[i],j,newstate);
     scn.smobs[i].draw.animstate[j]:=newstate;
    end;
   end;
  end;
 end;
       
 except stderr('OGLA','Error in oglareupdatevals'); end; 
end;
//############################################################################//
procedure mkdefmsh;
var i,j:integer;
begin            
 setlength(defmsh[1].grp,1);
 setlength(defmsh[2].grp,1);
 setlength(defmsh[3].grp,1); 
 setlength(defmsh[4].grp,2);  
 setlength(defmsh[5].grp,1); 
 setlength(defmsh[6].grp,2);  
 setlength(defmsh[7].grp,4); 
 setlength(defmsh[8].grp,8);
 for j:=1 to 8 do begin
  defmsh[j].used:=true;
  defmsh[j].grc:=length(defmsh[j].grp);
  for i:=0 to defmsh[j].grc-1 do begin defmsh[j].grp[i].col:=tcrgba(255,255,255,255);defmsh[j].grp[i].dif.tx:=notx;end;
 end;
 
 mk_sphere(@defmsh[1].grp[0],6,false,0,64);
 
 mk_sphere(@defmsh[2].grp[0],8,false,0,128); 
   
 mk_sphere(@defmsh[3].grp[0],12,false,0,256);   
   
 mk_sphere(@defmsh[4].grp[0],16,true,0,256); 
 mk_sphere(@defmsh[4].grp[1],16,true,1,256); 
         
 mk_spherepatch(@defmsh[5].grp[0],4,1,0,18,-1,true,true,false);
       
 mk_spherepatch(@defmsh[6].grp[1],8,2,0,10,16,true,true,false);  
 mk_spherepatch(@defmsh[6].grp[0],4,2,1,12,-1,true,true,false); 
        
 mk_spherepatch(@defmsh[7].grp[3],16,4,0,12,12,false,true,false); 
 mk_spherepatch(@defmsh[7].grp[2],16,4,1,12,12,false,true,false); 
 mk_spherepatch(@defmsh[7].grp[1],12,4,2,10,16,true ,true,false);  
 mk_spherepatch(@defmsh[7].grp[0],06,4,3,12,-1,true ,true,false); 

 mk_spherepatch(@defmsh[8].grp[7],32,8,0,12,15,false,true,true); 
 mk_spherepatch(@defmsh[8].grp[6],32,8,1,12,15,false,true,true); 
 mk_spherepatch(@defmsh[8].grp[5],30,8,2,12,16,false,true,true);  
 mk_spherepatch(@defmsh[8].grp[4],28,8,3,12,12,false,true,true);  
 mk_spherepatch(@defmsh[8].grp[3],24,8,4,12,12,false,true,true); 
 mk_spherepatch(@defmsh[8].grp[2],18,8,5,12,12,false,true,true); 
 mk_spherepatch(@defmsh[8].grp[1],12,8,6,10,16,true ,true,true);  
 mk_spherepatch(@defmsh[8].grp[0],06,8,7,12,-1,true ,true,true);  
end;
//############################################################################//
begin
 mkdefmsh;
end.    
//############################################################################//