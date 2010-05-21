//############################################################################//
// Orulex: Dynamic planet block funtions
// Released under GNU General Public License
// Made in 2006-2010 by Artyom Litvinovich
//############################################################################//
unit dynplntblock;
{$ifdef fpc}{$mode delphi}{$endif}
interface
uses asys,strval,dynplntbase,dynplnttools,sysutils,maths,grph,tim,log,math;
//############################################################################//
procedure blktrn(cp:proampl;blk:pqrtree;adq:boolean);
procedure blksiz(cp:proampl;blk:pqrtree);
procedure blkauxcalc(cp:proampl;blk:pqrtree);
procedure mkblktex(cp:proampl;blk:pqrtree);
procedure blktxcoord(cp:proampl;blk:pqrtree;tp,px,py:double);
function  prctex(cp:proampl;blk:pqrtree;full:boolean=false):boolean;
procedure mkblk(cp:proampl;rt:pqrtree;var blk:pqrtree;cnt,dir:vec;qrt,lv,q:integer);
procedure blksetn(cp:proampl;blk:pqrtree);
procedure blkcedges(cp:proampl;blk:pqrtree); 
procedure blknmlsnei(cp:proampl;blk:pqrtree);
//############################################################################//
implementation    
//############################################################################//
procedure blktrn(cp:proampl;blk:pqrtree;adq:boolean);
var v:pNTVERTEX;
tx,ty,cx,sx,cy,sy:double;  
i:integer;
begin try 
 if(not blk.fin)and(not adq)then exit; 
 assert(blk.mag=BLK_MAG);
 cx:=cos(cp^.xa);sx:=sin(cp^.xa);cy:=cos(cp^.ya);sy:=sin(cp^.ya);
 for i:=0 to PLT_RES*PLT_RES-1 do begin
  blk.mshd[i]:=blk.msh[i];
  v:=@blk.mshd[i];  
 
  tx:=v.x;v.x:=tx*cy+v.z*sy;v.z:=-tx*sy+v.z*cy;
  ty:=v.y;v.y:=ty*cx-v.z*sx;v.z:= ty*sx+v.z*cx; 
  tx:=v.nx;v.nx:=tx*cy+v.nz*sy;v.nz:=-tx*sy+v.nz*cy;    
  ty:=v.ny;v.ny:=ty*cx-v.nz*sx;v.nz:= ty*sx+v.nz*cx; 

  v.y:=v.y-cp^.radius-cp^.AOFF;
 end;
 except
  wr_log('BlkTrn','Transformation error');
  if ocfg.multithreaded then bigerror(1,'BlkTrn') else bigerror(0,'BlkTrn');
 end;
end;
//############################################################################//  
procedure blksiz(cp:proampl;blk:pqrtree);
var i:integer;
begin try   
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 blk.siz:=(cp^.radius/pow(2,(blk.lv-1)))*1.414;  
 
 i:=(PLT_RES-1) div 2+((PLT_RES-1) div 2)*PLT_RES;
 blk.rcnt:=tvec(blk.msh[i].x,blk.msh[i].y,blk.msh[i].z);
 i:=2*(PLT_RES-1) div 4+((PLT_RES-1) div 4)*PLT_RES;blk.rcn[1]:=tvec(blk.msh[i].x,blk.msh[i].y,blk.msh[i].z);
 i:=2*(PLT_RES-1) div 4+2*((PLT_RES-1) div 4)*PLT_RES;blk.rcn[2]:=tvec(blk.msh[i].x,blk.msh[i].y,blk.msh[i].z);
 i:=(PLT_RES-1) div 4+2*((PLT_RES-1) div 4)*PLT_RES;blk.rcn[3]:=tvec(blk.msh[i].x,blk.msh[i].y,blk.msh[i].z);
 i:=(PLT_RES-1) div 4+((PLT_RES-1) div 4)*PLT_RES;blk.rcn[4]:=tvec(blk.msh[i].x,blk.msh[i].y,blk.msh[i].z);

 if blk.siz>cp^.noilv then blk.lvc:=0;
 blk.lvc:=1-(blk.siz/cp^.noilv);

 except
  wr_log('BlkSiz','Undefined error');
  if ocfg.multithreaded then bigerror(1,'BlkSiz') else bigerror(0,'BlkSiz');
 end;  
end;
//############################################################################//  
procedure blkauxcalc(cp:proampl;blk:pqrtree);
const qx:array[0..5]of array[0..2]of integer=((-1,0,1),(-1,0,-1),(0,1,-1),(0,1,1),(1,1,0),(-1,1,0));
const dx:array[0..5]of array[0..2]of integer=((1,0,0),(1,0,0),(0,0,1),(0,0,-1),(-1,0,0),(1,0,0));
var vn:vec;
begin try        
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 blk.f:=1/pow(2,(blk.lv-1));
 blk.u:=(2*cp^.radius/(PLT_RES-1))*blk.f;

 vn:=addv(blk.cnt,nmulv(tvec(cp^.radius*qx[blk.qrt][0],cp^.radius*qx[blk.qrt][1],cp^.radius*qx[blk.qrt][2]),blk.f));
 blk.dxx:=blk.u*dx[blk.qrt][0];blk.dyx:=blk.u*dx[blk.qrt][1];blk.dzx:=blk.u*dx[blk.qrt][2]; 
   
 blk.dxy:=-blk.dxx*(PLT_RES)-blk.dir.x*blk.u;
 blk.dyy:=-blk.dyx*(PLT_RES)-blk.dir.y*blk.u;
 blk.dzy:=-blk.dzx*(PLT_RES)-blk.dir.z*blk.u;  
 blk.ut:=(2*cp^.radius/(cp.texture_res-1))*blk.f;
 blk.dxxt:=(blk.dxx/blk.u)*blk.ut;
 blk.dyxt:=(blk.dyx/blk.u)*blk.ut;
 blk.dzxt:=(blk.dzx/blk.u)*blk.ut; 
 blk.dxyt:=-blk.dxxt*(cp.texture_res)-blk.dir.x*blk.ut;
 blk.dyyt:=-blk.dyxt*(cp.texture_res)-blk.dir.y*blk.ut;
 blk.dzyt:=-blk.dzxt*(cp.texture_res)-blk.dir.z*blk.ut;

 blk.vn:=vn;           
 except
  wr_log('BlkAuxCalc','Undefined auxillary error');
  if ocfg.multithreaded then bigerror(1,'BlkAuxCalc') else bigerror(0,'BlkAuxCalc');
 end; 
end;
//############################################################################//  
procedure mkblktex(cp:proampl;blk:pqrtree);
begin try   
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 blk.own_tex:=getprtex(cp);
 blk.own_tex.used:=true;  
 blk.own_tex.ld:=false;
 blk.own_tex.fin:=false; 
 blk.own_tex.id:=blk.id;
 blk.own_tex.vn:=blk.vn;
 blk.own_tex.gy:=0;
 blk.own_tex.uc:=0;
 blk.own_tex.lv:=blk.lv; 
 blk.own_tex.gltx:=0;
 blk.own_tex.gletx:=notx;
 if lowercase(cp.name)<>'earth' then blk.own_tex.gletx:=etx[random(2)];

 en_q(Q_TEXTURE,cp,blk,blk.prit,false);

 if blk.bs=nil then begin
  blk.draw_tex:=blk.own_tex;  
  blk.draw_tex.uc:=1;  
  prctex(cp,blk,true);
 end else begin 
  blk.draw_tex:=blk.bs.draw_tex;
  inc(blk.draw_tex.uc); 
 end;   
 blk.txo:=0;
 blk.tyo:=0;    
      
 except
  wr_log('MkBlkTex','Texture init error');
  if ocfg.multithreaded then bigerror(1,'MkBlkTex') else bigerror(0,'MkBlkTex');
 end;      
end;
//############################################################################//  
procedure blktxcoord(cp:proampl;blk:pqrtree;tp,px,py:double);
var x,y:integer;
p:pNTVERTEX;
xd:double;
begin try 
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 xd:=(PLT_RES-1)*tp*((cp.texture_res)/(cp.texture_res));  
 for y:=0 to PLT_RES-1 do begin
  for x:=0 to PLT_RES-1 do begin
   p:=@blk.msh[x+y*PLT_RES];  
   p.tu:=px+x/xd;
   p.tv:=py+y/xd;            
  end;
 end;           
 except
  wr_log('BlkTxCoord','Undefined error');
  if ocfg.multithreaded then bigerror(1,'BlkTxCoord') else bigerror(0,'BlkTxCoord');
 end; 
end;
//############################################################################//  
function prctex(cp:proampl;blk:pqrtree;full:boolean=false):boolean;
var vn,vi:vec;
x,y,ox,oy:integer;
c:crgba;
begin      
 result:=true;
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 if blk.own_tex=nil then exit;
 if not blk.own_tex.used then exit;
 if blk.own_tex.fin then exit;
 
 case blk.q of
  0:begin ox:=cp.texture_res div 2;oy:=0;end;
  1:begin ox:=cp.texture_res div 2;oy:=cp.texture_res div 2;end;
  2:begin ox:=0;oy:=cp.texture_res div 2;end;
  3:begin ox:=0;oy:=0;end;
  else begin ox:=0;oy:=0;end;
 end;
 
 vn:=blk.own_tex.vn;  
 for y:=blk.own_tex.gy to cp.texture_res-1 do begin
  for x:=0 to cp.texture_res-1 do begin
   vi:=nmulv(nrvec(vn),cp^.radius);
    
   if(blk.bs<>nil)and(blk.bs.own_tex<>nil)and(blk.bs.own_tex.fin)and(x mod 2=0)and(y mod 2=0)then begin
    c:=blk.bs.own_tex.tx[x div 2+ox+(y div 2+oy)*cp.texture_res];
   end else c:=cp^.fgetc(cp,vi,blk.lvc,blk.lv);  
                     
   blk.own_tex.tx[x+y*cp.texture_res]:=c;
   
   vn.x:=vn.x+blk.dxxt;
   vn.y:=vn.y+blk.dyxt;
   vn.z:=vn.z+blk.dzxt; 
  end;
  vn.x:=vn.x+blk.dxyt;
  vn.y:=vn.y+blk.dyyt;
  vn.z:=vn.z+blk.dzyt; 
  if not full then if rtdt(dt21)>cp^.main_queue_time_slice then begin
   if y<>cp.texture_res-1 then begin
    blk.own_tex.vn:=vn;
    blk.own_tex.gy:=y+1;
    result:=false;
    //maqaddprctex(cp,blk,-1);
    exit;
   end;
  end;  
 end;     
 
 if blk.bs<>nil then begin            
  dec(blk.draw_tex.uc);
  if blk.draw_tex.uc<=0 then freehtex(cp,blk.draw_tex); 
 end;
  
 gethtex(cp,blk.own_tex);
 blk.own_tex.fin:=true;
 blk.draw_tex:=blk.own_tex;
 blk.draw_tex.uc:=1;  
 blk.txo:=0;
 blk.tyo:=0; 
 
 del_q(Q_TEXTURE,cp,blk.tqp);  

 blktxcoord(cp,blk,1,0,0);  
 blktrn(cp,blk,true); 
end;
//############################################################################//  
//############################################################################// 
//############################################################################// 
procedure blknmls(cp:proampl;blk:pqrtree);
var v1,v2,v3:pNTVERTEX;
j:integer;
p,q,n:vec;
begin         
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 for j:=0 to rplspcount div 3-1 do begin
  v1:=@blk.msh[rplspoints[j*3+0]];
  v2:=@blk.msh[rplspoints[j*3+1]];
  v3:=@blk.msh[rplspoints[j*3+2]];   

  p.x:=v2.x-v1.x;p.y:=v2.y-v1.y;p.z:=v2.z-v1.z;
  q.x:=v3.x-v1.x;q.y:=v3.y-v1.y;q.z:=v3.z-v1.z;

  n:=nrvec(vmulv(p,q));

  v1.nx:=n.x;v1.ny:=n.y;v1.nz:=n.z;
  v2.nx:=n.x;v2.ny:=n.y;v2.nz:=n.z;
  v3.nx:=n.x;v3.ny:=n.y;v3.nz:=n.z;   
 end;
end;
//############################################################################// 
function xqrt(qrt,n,x,y:integer):integer;
begin
 result:=-1;
 if n=-1 then exit;
 case qrt of
  0:case n of
   1:result:=(PLT_RES-1-y)+0*PLT_RES;               
   2:result:=x+0*PLT_RES;
   3:result:=y+0*PLT_RES;  
   4:result:=(PLT_RES-1-x)+0*PLT_RES;    
  end;
  1:case n of
   1:result:=y+(PLT_RES-1)*PLT_RES;               
   2:result:=(PLT_RES-1-x)+(PLT_RES-1)*PLT_RES;
   3:result:=(PLT_RES-1-y)+(PLT_RES-1)*PLT_RES;  
   4:result:=x+(PLT_RES-1)*PLT_RES;    
  end;
  2:case n of
   1:result:=0+y*PLT_RES;      
   2:result:=(PLT_RES-1)+x*PLT_RES;
   3:result:=(PLT_RES-1)+y*PLT_RES;   
   4:result:=(PLT_RES-1)+(PLT_RES-1-x)*PLT_RES;
  end;
  3:case n of
   1:result:=0+y*PLT_RES;   
   2:result:=0+(PLT_RES-1-x)*PLT_RES;
   3:result:=(PLT_RES-1)+y*PLT_RES; 
   4:result:=0+x*PLT_RES;
  end;
  4:case n of     
   1:result:=0+y*PLT_RES;          
   2:result:=(PLT_RES-1-x)+(PLT_RES-1)*PLT_RES;
   3:result:=(PLT_RES-1)+y*PLT_RES;   
   4:result:=(PLT_RES-1-x)+0*PLT_RES;
  end;
  5:case n of
   1:result:=0+y*PLT_RES;           
   2:result:=x+0*PLT_RES;
   3:result:=(PLT_RES-1)+y*PLT_RES;   
   4:result:=x+(PLT_RES-1)*PLT_RES;
  end;
 end;
end;
//############################################################################//  
procedure blknmlsnei(cp:proampl;blk:pqrtree);
var x,y,xo,yo,n,o1:integer;
nr,ps,v,v1,v2:vec;
a1,a2,alt:double;
p,p1,p2:pNTVERTEX;
e1,e2,e3,e4:boolean;
label 4;
begin p1:=nil;p2:=nil;try
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 e1:=false;e2:=false;e3:=false;e4:=false;
 if blk.n[1]=nil then e1:=true;
 if blk.n[2]=nil then e2:=true;
 if blk.n[3]=nil then e3:=true;
 if blk.n[4]=nil then e4:=true;
 if e1 and e2 and e3 and e4 then exit; 
               
 if not e1 then assert(blk.n[1].mag=BLK_MAG);
 if not e2 then assert(blk.n[2].mag=BLK_MAG);
 if not e3 then assert(blk.n[3].mag=BLK_MAG);
 if not e4 then assert(blk.n[4].mag=BLK_MAG);
               
 for y:=0 to PLT_RES-1 do for x:=0 to PLT_RES-1 do if(x=0)or(y=0)or(x=PLT_RES-1)or(y=PLT_RES-1)then begin  
  if(x=PLT_RES-1)and(e1)then goto 4;
  if(y=PLT_RES-1)and(e2)then goto 4;
  if(x=0)and e3 then goto 4;
  if(y=0)and e4 then goto 4;  
           
  n:=-1;o1:=-1;
  if(x=PLT_RES-1)then begin n:=1;o1:=0+y*PLT_RES;end;
  if(y=PLT_RES-1)then begin n:=2;o1:=x+0*PLT_RES;end;
  if(x=0)then begin n:=3;o1:=(PLT_RES-1)+y*PLT_RES;end;
  if(y=0)then begin n:=4;o1:=x+(PLT_RES-1)*PLT_RES;end;  
  if n<>-1 then if blk.n[n].qrt<>blk.qrt then o1:=xqrt(blk.qrt,n,x,y);    
  if o1=-1 then goto 4;
           
  p:=@blk.msh_base[x+y*PLT_RES];
  p1:=@blk.n[n].msh_base[o1];
  nr.x:=(p.nx+p1.nx)/2;
  nr.y:=(p.ny+p1.ny)/2;
  nr.z:=(p.nz+p1.nz)/2; 
  ps:=tvec(p.x,p.y,p.z);
  
  p:=@blk.msh[x+y*PLT_RES];
  p1:=@blk.n[n].msh[o1];

  p.nx:=nr.x;p.ny:=nr.y;p.nz:=nr.z;p1.nx:=nr.x;p1.ny:=nr.y;p1.nz:=nr.z;
  p.x :=ps.x;p.y :=ps.y;p.z :=ps.z;p1.x :=ps.x;p1.y :=ps.y;p1.z :=ps.z;
    
  continue;
  4:    
  if(((x=0)or(x=PLT_RES-1))and((y mod 2=0)or(y=0)or(y=PLT_RES-1)))or(((y=0)or(y=PLT_RES-1))and((x mod 2=0)or(x=0)or(x=PLT_RES-1)))then begin
   if blk.bs=nil then continue;
   xo:=0;yo:=0;       
   if blk.bs.c[4]=blk then begin xo:=0;yo:=0;end;
   if blk.bs.c[1]=blk then begin xo:=(PLT_RES-1)div 2;yo:=0;end; 
   if blk.bs.c[2]=blk then begin xo:=(PLT_RES-1)div 2;yo:=(PLT_RES-1)div 2;end; 
   if blk.bs.c[3]=blk then begin xo:=0;yo:=(PLT_RES-1)div 2;end; 
   p1:=nil;         
   if(x=PLT_RES-1)then p1:=@blk.bs.msh_base[xo+(PLT_RES-1)div 2+(yo+y div 2)*PLT_RES];
   if(y=PLT_RES-1)then p1:=@blk.bs.msh_base[xo+x div 2+(yo+(PLT_RES-1)div 2)*PLT_RES];
   if(x=0)then p1:=@blk.bs.msh_base[xo+(yo+y div 2)*PLT_RES];
   if(y=0)then p1:=@blk.bs.msh_base[(xo+x div 2)+yo*PLT_RES];   
   if p1=nil then continue;  
    
   p:=@blk.msh[x+y*PLT_RES];
   p.nx:=p1.nx;p.ny:=p1.ny;p.nz:=p1.nz; 
   p.x:=p1.x;p.y:=p1.y;p.z:=p1.z; 
  end else begin    
   p:=@blk.msh[x+y*PLT_RES];
   if (x=0)or(x=PLT_RES-1) then begin p1:=@blk.msh_base[x+(y+1)*PLT_RES];p2:=@blk.msh_base[x+(y-1)*PLT_RES];end;
   if (y=0)or(y=PLT_RES-1) then begin p1:=@blk.msh_base[(x+1)+y*PLT_RES];p2:=@blk.msh_base[(x-1)+y*PLT_RES];end;
   
   v.x:=p.x;v.y:=p.y;v.z:=p.z;
   v1.x:=p1.x;v1.y:=p1.y;v1.z:=p1.z;
   v2.x:=p2.x;v2.y:=p2.y;v2.z:=p2.z;
   a1:=modv(v1);
   a2:=modv(v2);         
   alt:=(a1+a2)/2;
  
   v:=nmulv(nrvec(v),alt);
   p.x:=v.x;p.y:=v.y;p.z:=v.z;
   
   p.nx:=(p1.nx+p2.nx)/2;p.ny:=(p1.ny+p2.ny)/2;p.nz:=(p1.nz+p2.nz)/2;
  end;
 end;           
 except
  on E: Exception do begin
   wr_log('blknmlsnei','Undefined error, blk='+stri(intptr(@blk))+': '+E.Message);
   if ocfg.multithreaded then bigerror(1,'MkBlk') else bigerror(0,'MkBlk');
  end;
 end; 
end;   
//############################################################################// 
procedure blkrefls(cp:proampl;blk:pqrtree);
var j,n:integer;
begin    
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 if blk.crd and (not blk.crdf) then begin
  for j:=0 to rplspcount-1 do begin blk.refpts[j]:=rplspoints[j];blk.nrefpts[j]:=rplspoints[j];end;
 end else exit;

 for j:=0 to rplspcount div 3-1 do begin
  n:=ord(blk.mshr[rplspoints[j*3+0]])+ord(blk.mshr[rplspoints[j*3+1]])+ord(blk.mshr[rplspoints[j*3+2]]);
  if n<=cp.refidx then begin
   blk.refpts[j*3+0]:=0;blk.refpts[j*3+1]:=0;blk.refpts[j*3+2]:=0;
  end else begin
   blk.nrefpts[j*3+0]:=0;blk.nrefpts[j*3+1]:=0;blk.nrefpts[j*3+2]:=0;
  end;
 end;
end;     
//############################################################################// 
//############################################################################// 
procedure mkblk(cp:proampl;rt:pqrtree;var blk:pqrtree;cnt,dir:vec;qrt,lv,q:integer);
var x,y,i,ox,oy:integer;
alt,l,nl:double;
vn,vi,v:vec;
p:pNTVERTEX;
begin try    
 if rt<>nil then assert(rt.mag=BLK_MAG);
 new(blk);   
 blk.mag:=BLK_MAG;
 blk.used:=true;
 for i:=1 to 4 do begin blk.c[i]:=nil;blk.n[i]:=nil;end;    
 blk.bs:=rt;  
 blk.cnt:=cnt;
 blk.qrt:=qrt;
 blk.lv:=lv;
 blk.dir:=dir;
 blk.sqp:=nil;
 blk.mqp:=nil;
 blk.tqp:=nil;
 blk.draw_tex:=nil;
 blk.own_tex:=nil;
 blk.dr:=nil;
 blk.tr:=nil;
 blk.cld:=true;
 blk.crd:=false;
 blk.crdf:=true;
 blk.pris:=0;
 blk.prim:=0;
 blk.prit:=0;
 blk.vbo:=0;
 blk.id:=blk.cnt;  
 blk.q:=q;    
 blk.fin:=false;  
   
 case q of
  0:begin ox:=PLT_RES div 2;oy:=0;end;
  1:begin ox:=PLT_RES div 2;oy:=PLT_RES div 2;end;
  2:begin ox:=0;oy:=PLT_RES div 2;end;
  3:begin ox:=0;oy:=0;end;
  else begin ox:=0;oy:=0;end;
 end;
 blkauxcalc(cp,blk);
            
 vn:=blk.vn;      
 for y:=0 to PLT_RES-1 do begin
  for x:=0 to PLT_RES-1 do begin
   p:=@blk.msh[x+y*PLT_RES];
   blk.mshr[x+y*PLT_RES]:=false;
  
   vi:=nmulv(nrvec(vn),cp^.radius);
   alt:=0;
   if(blk.bs<>nil)and(x mod 2=0)and(y mod 2=0)then begin
    v.x:=blk.bs.msh[x div 2+ox+(y div 2+oy)*PLT_RES].x;
    v.y:=blk.bs.msh[x div 2+ox+(y div 2+oy)*PLT_RES].y;
    v.z:=blk.bs.msh[x div 2+ox+(y div 2+oy)*PLT_RES].z;
    alt:=modv(v)-cp.radius;
   end else v:=cp^.fgeth(cp,vi,alt); 
   
   if abs(alt+0.1)>eps then 
    blk.cld:=false;
   if abs(alt+0.9)<eps then begin
    blk.crd:=true;   
    blk.mshr[x+y*PLT_RES]:=true;
   end else blk.crdf:=false; 
   p.x:=v.x;p.y:=v.y;p.z:=v.z;
   
   vn.x:=vn.x+blk.dxx;
   vn.y:=vn.y+blk.dyx;
   vn.z:=vn.z+blk.dzx;
  end;
  vn.x:=vn.x+blk.dxy;
  vn.y:=vn.y+blk.dyy;
  vn.z:=vn.z+blk.dzy;   
 end;
 blknmls(cp,blk);
 blksiz(cp,blk);
 
 blk.prit:=round((log2(blk.siz)/log2(sqr(cp^.radius)))*BUCK_CNT);   
 if blk.prit<0 then blk.prit:=0;if blk.prit>=BUCK_CNT then blk.prit:=BUCK_CNT-1;
 
 blktxcoord(cp,blk,1,0,0); 
 
 blkrefls(cp,blk);
 
 mkblktex(cp,blk);
 if blk.bs<>nil then begin
  l:=pow(2,lv-blk.draw_tex.lv);nl:=1/l;
  if q=0 then blktxcoord(cp,blk,l,blk.bs.txo+nl,blk.bs.tyo+00);
  if q=1 then blktxcoord(cp,blk,l,blk.bs.txo+nl,blk.bs.tyo+nl);
  if q=2 then blktxcoord(cp,blk,l,blk.bs.txo+00,blk.bs.tyo+nl);
  if q=3 then blktxcoord(cp,blk,l,blk.bs.txo+00,blk.bs.tyo+00); 
  if q=0 then begin blk.txo:=blk.bs.txo+nl;blk.tyo:=blk.bs.tyo+00;end; 
  if q=1 then begin blk.txo:=blk.bs.txo+nl;blk.tyo:=blk.bs.tyo+nl;end; 
  if q=2 then begin blk.txo:=blk.bs.txo+00;blk.tyo:=blk.bs.tyo+nl;end; 
  if q=3 then begin blk.txo:=blk.bs.txo+00;blk.tyo:=blk.bs.tyo+00;end; 
 end;  
 blktrn(cp,blk,true);  
    
 for y:=0 to PLT_RES-1 do for x:=0 to PLT_RES-1 do blk.msh_base[x+y*PLT_RES]:=blk.msh[x+y*PLT_RES];
 
 cp^.blcount:=cp^.blcount+1;
 cp^.polycount:=cp^.polycount+blkpcount;            
 except
  on E: Exception do begin
   wr_log('MkBlk','Undefined error: '+E.Message);
   if ocfg.multithreaded then bigerror(1,'MkBlk') else bigerror(0,'MkBlk');
  end;
 end; 
end;
//############################################################################//    
//############################################################################// 
procedure blksetn(cp:proampl;blk:pqrtree);
var i,j:integer;
begin try
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
             
 assert(blk.c[1]<>nil);
 assert(blk.c[2]<>nil);
 assert(blk.c[3]<>nil);
 assert(blk.c[4]<>nil);
 
 blk.c[1].n[2]:=blk.c[2];
 blk.c[1].n[3]:=blk.c[4];
 blk.c[2].n[3]:=blk.c[3];
 blk.c[2].n[4]:=blk.c[1];
 blk.c[3].n[4]:=blk.c[4];
 blk.c[3].n[1]:=blk.c[2];
 blk.c[4].n[1]:=blk.c[1];
 blk.c[4].n[2]:=blk.c[3];
 
 if blk.n[1]<>nil then begin  
  assert(blk.n[1].mag=BLK_MAG);
  if(blk.n[1].qrt=blk.qrt)or((blk.n[1].qrt>1)and(blk.qrt>1))then begin
   if blk.n[1].c[3]<>nil then begin blk.c[2].n[1]:=blk.n[1].c[3];blk.n[1].c[3].n[3]:=blk.c[2];end; 
   if blk.n[1].c[4]<>nil then begin blk.c[1].n[1]:=blk.n[1].c[4];blk.n[1].c[4].n[3]:=blk.c[1];end; 
  end else if(blk.qrt=1)and(blk.n[1].qrt=2)then begin 
   if blk.n[1].c[2]<>nil then begin blk.c[2].n[1]:=blk.n[1].c[2];blk.n[1].c[2].n[2]:=blk.c[2];end; 
   if blk.n[1].c[3]<>nil then begin blk.c[1].n[1]:=blk.n[1].c[3];blk.n[1].c[3].n[2]:=blk.c[1];end; 
  end else if(blk.qrt=0)and(blk.n[1].qrt=2)then begin 
   if blk.n[1].c[4]<>nil then begin blk.c[2].n[1]:=blk.n[1].c[4];blk.n[1].c[4].n[4]:=blk.c[2];end; 
   if blk.n[1].c[1]<>nil then begin blk.c[1].n[1]:=blk.n[1].c[1];blk.n[1].c[1].n[4]:=blk.c[1];end; 
  end;
 end;
   
 if blk.n[2]<>nil then begin   
  assert(blk.n[2].mag=BLK_MAG); 
  if blk.n[2].qrt=blk.qrt then begin
   if blk.n[2].c[4]<>nil then begin blk.c[3].n[2]:=blk.n[2].c[4];blk.n[2].c[4].n[4]:=blk.c[3];end; 
   if blk.n[2].c[1]<>nil then begin blk.c[2].n[2]:=blk.n[2].c[1];blk.n[2].c[1].n[4]:=blk.c[2];end; 
  end else if blk.n[2].qrt=1 then case blk.qrt of
   2:begin 
    if blk.n[2].c[1]<>nil then begin blk.c[3].n[2]:=blk.n[2].c[1];blk.n[2].c[1].n[1]:=blk.c[3];end; 
    if blk.n[2].c[2]<>nil then begin blk.c[2].n[2]:=blk.n[2].c[2];blk.n[2].c[2].n[1]:=blk.c[2];end; 
   end;
   3:begin 
    if blk.n[2].c[3]<>nil then begin blk.c[3].n[2]:=blk.n[2].c[3];blk.n[2].c[3].n[3]:=blk.c[3];end; 
    if blk.n[2].c[4]<>nil then begin blk.c[2].n[2]:=blk.n[2].c[4];blk.n[2].c[4].n[3]:=blk.c[2];end; 
   end;
   4:begin 
    if blk.n[2].c[2]<>nil then begin blk.c[3].n[2]:=blk.n[2].c[2];blk.n[2].c[2].n[2]:=blk.c[3];end; 
    if blk.n[2].c[3]<>nil then begin blk.c[2].n[2]:=blk.n[2].c[3];blk.n[2].c[3].n[2]:=blk.c[2];end; 
   end;
   5:begin 
    if blk.n[2].c[4]<>nil then begin blk.c[3].n[2]:=blk.n[2].c[4];blk.n[2].c[4].n[4]:=blk.c[3];end; 
    if blk.n[2].c[1]<>nil then begin blk.c[2].n[2]:=blk.n[2].c[1];blk.n[2].c[1].n[4]:=blk.c[2];end; 
   end;
  end else if(blk.qrt=1)and(blk.n[2].qrt=4)then begin 
   if blk.n[2].c[2]<>nil then begin blk.c[3].n[2]:=blk.n[2].c[2];blk.n[2].c[2].n[2]:=blk.c[3];end; 
   if blk.n[2].c[3]<>nil then begin blk.c[2].n[2]:=blk.n[2].c[3];blk.n[2].c[3].n[2]:=blk.c[2];end; 
  end else if(blk.qrt=0)and(blk.n[2].qrt=5)then begin 
   if blk.n[2].c[4]<>nil then begin blk.c[3].n[2]:=blk.n[2].c[4];blk.n[2].c[4].n[4]:=blk.c[3];end; 
   if blk.n[2].c[1]<>nil then begin blk.c[2].n[2]:=blk.n[2].c[1];blk.n[2].c[1].n[4]:=blk.c[2];end; 
  end;
 end;
 
 if blk.n[3]<>nil then begin   
  assert(blk.n[3].mag=BLK_MAG);   
  if(blk.n[3].qrt=blk.qrt)or((blk.n[3].qrt>1)and(blk.qrt>1))then begin
   if blk.n[3].c[1]<>nil then begin blk.c[4].n[3]:=blk.n[3].c[1];blk.n[3].c[1].n[1]:=blk.c[4];end; 
   if blk.n[3].c[2]<>nil then begin blk.c[3].n[3]:=blk.n[3].c[2];blk.n[3].c[2].n[1]:=blk.c[3];end; 
  end else if(blk.qrt=1)and(blk.n[3].qrt=3)then begin 
   if blk.n[3].c[2]<>nil then begin blk.c[4].n[3]:=blk.n[3].c[2];blk.n[3].c[2].n[2]:=blk.c[4];end; 
   if blk.n[3].c[3]<>nil then begin blk.c[3].n[3]:=blk.n[3].c[3];blk.n[3].c[3].n[2]:=blk.c[3];end; 
  end else if(blk.qrt=0)and(blk.n[3].qrt=3)then begin 
   if blk.n[3].c[4]<>nil then begin blk.c[4].n[3]:=blk.n[3].c[4];blk.n[3].c[4].n[4]:=blk.c[4];end; 
   if blk.n[3].c[1]<>nil then begin blk.c[3].n[3]:=blk.n[3].c[1];blk.n[3].c[1].n[4]:=blk.c[3];end; 
  end;
 end;
 
 if blk.n[4]<>nil then begin  
  assert(blk.n[4].mag=BLK_MAG);      
  if blk.n[4].qrt=blk.qrt then begin
   if blk.n[4].c[2]<>nil then begin blk.c[1].n[4]:=blk.n[4].c[2];blk.n[4].c[2].n[2]:=blk.c[1];end; 
   if blk.n[4].c[3]<>nil then begin blk.c[4].n[4]:=blk.n[4].c[3];blk.n[4].c[3].n[2]:=blk.c[4];end;  
  end else if blk.n[4].qrt=0 then case blk.qrt of
   2:begin 
    if blk.n[4].c[1]<>nil then begin blk.c[1].n[4]:=blk.n[4].c[1];blk.n[4].c[1].n[1]:=blk.c[1];end; 
    if blk.n[4].c[2]<>nil then begin blk.c[4].n[4]:=blk.n[4].c[2];blk.n[4].c[2].n[1]:=blk.c[4];end;  
   end;
   3:begin 
    if blk.n[4].c[3]<>nil then begin blk.c[1].n[4]:=blk.n[4].c[3];blk.n[4].c[3].n[3]:=blk.c[1];end; 
    if blk.n[4].c[4]<>nil then begin blk.c[4].n[4]:=blk.n[4].c[4];blk.n[4].c[4].n[3]:=blk.c[4];end;  
   end;
   4:begin 
    if blk.n[4].c[4]<>nil then begin blk.c[1].n[4]:=blk.n[4].c[4];blk.n[4].c[4].n[4]:=blk.c[1];end; 
    if blk.n[4].c[1]<>nil then begin blk.c[4].n[4]:=blk.n[4].c[1];blk.n[4].c[1].n[4]:=blk.c[4];end;  
   end;
   5:begin 
    if blk.n[4].c[2]<>nil then begin blk.c[1].n[4]:=blk.n[4].c[2];blk.n[4].c[2].n[2]:=blk.c[1];end; 
    if blk.n[4].c[3]<>nil then begin blk.c[4].n[4]:=blk.n[4].c[3];blk.n[4].c[3].n[2]:=blk.c[4];end;   
   end;
  end else if(blk.qrt=1)and(blk.n[4].qrt=5)then begin 
   if blk.n[4].c[2]<>nil then begin blk.c[1].n[4]:=blk.n[4].c[2];blk.n[4].c[2].n[2]:=blk.c[1];end; 
   if blk.n[4].c[3]<>nil then begin blk.c[4].n[4]:=blk.n[4].c[3];blk.n[4].c[3].n[2]:=blk.c[4];end;  
  end else if(blk.qrt=0)and(blk.n[4].qrt=4)then begin 
   if blk.n[4].c[4]<>nil then begin blk.c[1].n[4]:=blk.n[4].c[4];blk.n[4].c[4].n[4]:=blk.c[1];end; 
   if blk.n[4].c[1]<>nil then begin blk.c[4].n[4]:=blk.n[4].c[1];blk.n[4].c[1].n[4]:=blk.c[4];end;  
  end;
 end;
     
 except
  wr_log('BlkSetN','Neighborhood error');
  if ocfg.multithreaded then bigerror(1,'BlkSetN') else bigerror(0,'BlkSetN');
 end; 
end;
//############################################################################//  
//############################################################################// 
procedure blkcedges(cp:proampl;blk:pqrtree);
begin try 
 if blk=nil then exit;
 assert(blk.mag=BLK_MAG);
 blknmlsnei(cp,blk); 
 blktrn(cp,blk,true);
 except
  wr_log('BlkCEdges','Edges do not meet');
  if ocfg.multithreaded then bigerror(1,'BlkCEdges') else bigerror(0,'BlkCEdges');
 end; 
end;
//############################################################################//  
begin
end.
//############################################################################//  


