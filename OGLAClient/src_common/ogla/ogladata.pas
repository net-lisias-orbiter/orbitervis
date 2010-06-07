//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA data definitions
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit ogladata;
interface
uses asys,grph,maths{$ifndef no_render},dogl,glpars,dpringbs,{$ifdef orulex}dynplntbase,{$endif}grpcam,opengl1x{$endif};
//############################################################################// 
const oglaver='100608';
//############################################################################// 
const 
MAXPATCHRES=8;
HORIZON_HAZE_NSEG=64;  // number of mesh segments
PIX_LIM=1;

MESHVIS_NEVER   =$00;
MESHVIS_EXTERNAL=$01;
MESHVIS_COCKPIT =$02;
MESHVIS_ALWAYS  =MESHVIS_EXTERNAL+MESHVIS_COCKPIT;
MESHVIS_VC      =$04;
MESHVIS_EXTPASS =$10;

SMOB_VESSEL=0;
SMOB_BASE=1;

OGLA_LIGHT_SPOT=0;
OGLA_LIGHT_OMNI=1;

const            
max_surf_dist = 1e4;
max_centre_dist = 0.9e6;

//############################################################################// 
//############################################################################// 

type oplhazetyp=record
 basecol:crgbad;
 rad:double;      // planet radius
 hralt:double;    // relative horizon altitude
 dens0:double;    // atmosphere density factor
 hshift:double;   // horizon reference shift factor
 cloudalt:double; // cloud layer altitude
 hscale:double;   // inner haze ring radius (in planet radii)
 tx:cardinal;
 hasclouds:bytebool;
end; 
poplhazetyp=^oplhazetyp; 

{$ifndef no_render}
tilet=record
 yoff,scl1:double;
 tx:cardinal;
 id:integer;
 msh:ptypmshgrp;
 bh,bl,med:vec;
 rad:double;
end;
ptilet=^tilet;
tiles=record
 til:array of tilet;
 cnt:cardinal;
 done:boolean;
end;

pTILEDESC=^TILEDESC;
TILEDESC=record
 grp:ptypmshgrp;
	flag:dword;
	subtile:array[0..3]of pTILEDESC;   //sub-tiles for the next resolution level
	ofs:dword;                         //refers back to the master list entry for the tile
end;

opmeshrec=record    
 bin_loaded:boolean;
 sml_tiles:array[1..MAXPATCHRES]of tiles;   
 tiles:array of TILEDESC;  
 nmask,npatch:integer;
 
 cnt,curld,avl,res:integer;  
 rot:double; 
      
 tx:array of cardinal;      
 ptx:array of pointer;   
   
 lv0msh:typmsh;
 umsh,umshld,umshck,umshav:boolean;
end;
popmeshrec=^opmeshrec;

drawplanetrec=record  
 atm:boolean; 
 was_haze:boolean; 
 atmrho,atmrho0,atmradlimit,cloudrot:double;
 atmcolor0:crgbad;  
 haze:poplhazetyp;    
 hazmsh:typmsh;
 
 {$ifdef orulex}dynpl:proampl;{$endif}
  
 dist_scale,maxdist:double;
 apr:double;
 nrst:boolean;
          
 grnd,clds,lgts:opmeshrec;    
 gen,genused:boolean;  
 dtn:integer;
 
 rng:pdpring;
 ringmsh:typmsh;
 ringex:boolean;
 ringtx:array[0..2]of cardinal;
 rngcls:array of crgbad;
 ringmin,ringmax:double;
end;
pdrawplanetrec=^drawplanetrec;
{$endif}

panimationcomp=^animationcomp;
ppanimationcomp=^panimationcomp; 
animationcompap=array[0..100000]of panimationcomp; 
ppanimationcompap=^animationcompap;
animationcomp=record
 state0:double;     ///< first end state
 state1:double;     ///< second end state
 trans:pointer;       ///< transformation
 parent:panimationcomp;    ///< parent transformation
 children:ppanimationcompap; ///< list of children
 nchildren:dword;           ///< number of children
end;                
 
panimation=^animation;
animation=record
 defstate:double;          ///< default animation state in the mesh
 state:double;             ///< current state
 ncomp:dword;               ///< number of components
 comp:ppanimationcompap;     ///< list of components
end;          
animationa=array[0..100000]of animation;
panimationa=^animationa;

vesexhtype=record
 tex:dword;
 lvl,lscale,wscale:double;
 pos,dir:vec;
end;

draw_light_rec=record
 ison:boolean;
 tp:integer;
 spot,rad,pwr,setpwr:double;
 pos,dir:vec;  
 
 bndtp:integer;
 bndob:dword;
 col:crgba;
end;
pdraw_light_rec=^draw_light_rec;
     
draw_rec=record
 tp,nmesh:integer;
 mshs:array of ptypmsh;
 lt0:quat;   
 lights_cnt:integer;
 lights:array of pdraw_light_rec;
 apr,siz:double;
 drmsh:boolean;
 semit:byte;
               
 obj:pointer;
 mshv:array of dword;  
 anim:panimationa;
 nanim:integer;
 animstate:array of double;
 
 cp,vc_shadows:boolean;

 exh:array of vesexhtype;  
end;
pdraw_rec=^draw_rec;
apdraw_rec=array of pdraw_rec;
//############################################################################// 
{$ifndef no_render}
//############################################################################// 
type oglainf=record
 texdir,mshdir:string;   
 gwin:pglwin;
end;
poglainf=^oglainf;
//############################################################################//
type 
oglas_nebula=record   
 gps,pgps:vec;
 rad:double;
 tx:dword;
 col:crgba;
end;
poglas_nebula=^oglas_nebula;

oglas_star=record   
 pos,vel:vec;
 rad:double;
 obj:intptr;
  
 name:string[64];  
 msh :ptypmsh;
 col:crgba;
end;
poglas_star=^oglas_star;

oglas_planet=record
 pos,vel,cpos,rot:vec;
 starlightpos,lcampos,lcamdir,lcamrpos,lstarpos:vec;
 rad,rrad,mass:double; 
 obj:intptr;
 starlightcol:crgba;
 
 name:string[64];
 draw:pdrawplanetrec;   
end;
poglas_planet=^oglas_planet;

oglas_smob=record
 tp:integer;
 pos,cpos,rot,vel:vec;
 rad,mass:double; 
 ob:pointer; 
 id:dword;
 name:string[64];  
 draw:pdraw_rec;

 pgpos:vec;
 pgsiz:double;
 near_plnt:integer;
end;
poglas_smob=^oglas_smob;

oglas_pstrm=record
 pos,dir:pvec;
 lv:pdouble; 
 cpos:vec;
 obj,es:intptr;
 tp:integer;
 ps:ppararr;
end;
poglas_pstrm=^oglas_pstrm;
{$endif}
oglafeat=record  
 tx_smooth,tx_compress,tx_mipmap:boolean;
 clouds,cloudshadows,multilight,shadows,mlight_terrain,orulex,advanced,camera2,autores,fxsky,advatm,wireframe,postplane,camera_light,starlight_colored,stereo,rayleigh,planet_light,realrings:boolean;       
 shres,shmres,cmtres,orures,drwm,fxsky_res:dword;
 angl_dist:double;
 max_plnt_lv,projection:integer;
end;
poglafeat=^oglafeat;
{$ifndef no_render}

oglascene=record
 stars:paopstartyp;
 firstrun:boolean; 
 skip_step:pboolean;

 cur_sv:integer;
   
 cmdmod:boolean; 
 cmdmkey,scrskey:word;
 cmdmpref,scrskeynam:string;

 nebs:array of poglas_nebula;
 star:array of poglas_star;
 plnt:array of poglas_planet;
 smobs:array of poglas_smob;
 pss :array of poglas_pstrm;
          
 invc,drsky,fixedsky,fixedsky_done:boolean;
 fps:integer;
 fxsky_tx:array[0..6]of dword;
 fxsky_fbo:dword;

 screen_fbo,screen_tx,screen_depth_fbo:dword;
 shi,shj:aointeger;
 
 cam,cam1,cam2:camrec;
 tgtname:string;
 camerot:mat;
 camapr:double;
 wid,hei,nebcnt:integer;
 sky:double;
 skycolor,skycolor_grnd:crgba;
 tx,itx:cardinal;
 axes:array of array[0..3]of integer;
 axes_cnt:integer;
 axes_pos:array[0..2]of array[0..2]of vec;
 
 sys:poglainf;
 feat:oglafeat;
 can_rayleigh:boolean;
end;
poglascene=^oglascene;

//############################################################################// 
//############################################################################// 
var              
hcosp,hsinp:array of double;
oplbuf:array of poglas_planet;
opldsbuf:adouble;
shscr,noitx,defrngtx1,defrngtx2,nebscr:cardinal;
defrng:array[0..1]of pointer;

shmtex,cmtx,dhtx:cardinal;
haztxz:cardinal;
//haztxc:cardinal;
fpp,npp:double;

//Star
starmsh:typmsh;
gals_tx:dword;  
defexhausttex:cardinal;
//############################################################################//        
//############################################################################// 
var defmsh:array[1..MAXPATCHRES]of typmsh;        
//############################################################################// 
const
patch_sml_tiles_cnt:array[1..MAXPATCHRES]of integer=(1,1,1,2,8,24,100,364);
patch_idx:array[0..8]of integer=(0,1,2,3,5,13,37,137,501);
{$endif}
//############################################################################// 
implementation
//############################################################################// 
//############################################################################// 
begin
end.     
//############################################################################// 