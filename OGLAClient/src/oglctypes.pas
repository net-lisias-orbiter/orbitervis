//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLAClient Main
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglctypes;
interface
uses asys,maths,grph,ogladata;
//############################################################################//  
//OGLC features
type featsrec=record
 camx,camy,camdir:integer;
 auxinfo,gdiemu,server_on:boolean;
end;  
//############################################################################//  
//Network packets
vecspck=packed record
 tp,id,tp2:integer;
 v1,v2,v3:vec;
 b1:boolean;
 m1:mat;   
end;  
atmpck=packed record
 radlimit,cldrot,rho,rho0:double; 
 color0:vec;
end;   
mainpck=packed record
 apr:double;
 invc:byte; 
 tgtvel:vec;
end;   
ivespck=packed record
 nam:string[255];
 id:dword;
 pos,vel:vec;
 rad,mass:double;
 rotm:mat;
end; 
iplntpck=packed record
 nam:string[255];
 ob:dword;
 pos,vel,rot:vec;    
 rad,mass:double;
 isatm:byte;
 h:oplhazetyp;
end;    
imshpck=packed record
 id,n:integer;
 vis:dword;
 flg:byte;
 grc:integer;
 txc:integer;
end;  
imshgrppck=packed record      
 pnts_cnt,trng_cnt:integer; 
 tx:cardinal;
 center:vec;   
 col,cole,cols:crgba;  
 spow:single;
 typ,primt:byte;
 tag:integer;
 orbTexIdx,xmit_tx:dword;  
end;  
ipanpck=packed record
 mat:mat;
 idx_lng:integer;   
 trans:boolean;
end; 
itexpck=packed record
 id:integer;
 f_clr:boolean;
 w,h,ckey:cardinal;
 srcn:string[255];
end;   
itxgpck=packed record
 id:integer;
 size:dword;
end;   
id2opck=packed record
 tp:integer;
 srf:integer;
 x0,y0,x1,y1:integer;
 fnam:string[255];
 len:dword;  
end; 
//Back packets
type evt_net_rec=packed record
 id:char;
 sz:dword;
 tp:byte;
 x,y,key:word;
end;
//############################################################################//  
var feats:featsrec; 
do_check_ng:boolean=true;
use_udp:boolean=false;  
use_comp:boolean=false;  
net_buffer_size:integer=32*1024*1024;
net_med_buffer_size:integer=1024*1024;
net_sml_buffer_size:integer=64*1024;
//############################################################################// 
implementation                  
//############################################################################//
begin
end. 
//############################################################################//
