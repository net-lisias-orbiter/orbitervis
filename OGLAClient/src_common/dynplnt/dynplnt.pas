//############################################################################//
// Orulex: Dynamic planet core
// Released under GNU General Public License
// Made by Artlav 2007-2010 
//############################################################################//
unit dynplnt;
{$ifdef fpc}{$mode delphi}{$endif}
interface
uses asys,dynplntbase,dynplntfiles,dynplnttools,dynplntblock,noir,log,noise,sysutils,maths,strval,tim,grph,polis;
//############################################################################//    
procedure rmplinit(cp:proampl;tp:integer=0);
procedure rmtessel(cp:proampl); 
procedure rmtrn(cp:proampl;cx,sx,cy,sy:double);
function  defgethf(cp:proampl;a:vec;var res:double):vec;  
function  defgetcf(cp:proampl;a:vec;lv:double;lvl:integer):crgba; 
  
procedure clrrplshmap(cp:proampl;c:integer);
procedure clrrplscmap(cp:proampl;c:integer);
procedure clrpls(cp:proampl);  
procedure clrplsmesh(cp:proampl);
//############################################################################//                          
implementation 
//############################################################################//  
function defgethf(cp:proampl;a:vec;var res:double):vec;
var i,t:integer;
h:double;
p,c,an:vec;
begin try 
 //if ocfg.multithreaded then if tthhdi=GetCurrentThreadid then WaitForSingleObject(tthmx,INFINITE);{$endif}
 
 h:=0;
 //Parameters   
 an:=nrvec(a);  
 if an.x=0 then c.y:=3*pi/2 else c.y:=pi+arctan(an.z/an.x);
 if(an.x<0)then c.y:=c.y+sgn(an.z)*pi;
 if(an.x=0)and(an.z=0)then c.x:=pi/2 else c.x:=arctan(an.y/sqrt(sqr(an.x)+sqr(an.z)));
    
 //Flatspaces
 for i:=0 to length(cp^.flat)-1 do if cp^.flat[i].used then begin 
  if (c.x>cp^.flat[i].lth)and(c.y>cp^.flat[i].lnh)and(c.x<cp^.flat[i].ltl)and(c.y<cp^.flat[i].lnl) then begin
   result:=nmulv(an,cp^.radius-0.8);
   res:=-0.8;      
   //if ocfg.multithreaded then if tthhdi=GetCurrentThreadid then releasemutex(tthmx);{$endif}
   exit;
  end;
 end;  
         
 //Function         
 p:=nmulv(an,cp^.radius);   
 //noirna:=p;noirnan:=an;noirmod:=cp^.radius;noiralat:=1000;noiralon:=1000; 
 res:=runexpr(@defnoi,@p,cp^.tfuncc);  
 //res:=ridgetf(p,127769,3,evec)*12777+perlintf(p,227769,4,evec)*6000+perlintf(p,7000,6,evec)*1000;
       
 //Global heightmap
 if cp^.bhmap.used then begin 
  h:=interhmap(@cp^.bhmap,c);

  if cp^.bhmap.op=0 then if h>0 then res:=res+h*cp^.bhmap.scl;
  if cp^.bhmap.op=3 then begin
   res:=res+h*cp^.bhmap.scl;
   if cp^.bels then  else begin
    if h>100 then  else begin
     if h>0 then res:=res*sqrt(h/100) else res:=-0.9;
    end;
   end;
  end;
 end;    
 
 //Heightmaps  
 for i:=0 to length(cp^.hmap)-1 do if cp^.hmap[i].used then begin 
  if (c.x>=cp^.hmap[i].lth)and(c.y>=cp^.hmap[i].lnh)and(c.x<=cp^.hmap[i].ltl)and(c.y<=cp^.hmap[i].lnl) then begin
   h:=interhmap(@cp^.hmap[i],c);
 
   if cp^.hmap[i].op=0 then res:=res+h*cp^.hmap[i].scl;
   if cp^.hmap[i].op=1 then res:=res*h*cp^.hmap[i].scl;
   if cp^.hmap[i].op=2 then res:=h*cp^.hmap[i].scl; 
   if cp^.hmap[i].flg and 1<>0 then if h<0 then res:=-0.9; 
  end;
 end;  
      
 //Base craters      
 if cp^.sbcrlev>0 then for i:=0 to length(cp^.srbs)-1 do if cp^.srbs[i].used then begin 
  if sqr(cp^.srbs[i].pos.x-p.x)+sqr(cp^.srbs[i].pos.y-p.y)+sqr(cp^.srbs[i].pos.z-p.z)<=cp^.srbs[i].r2 then begin

   t:=cp^.srbs[i].t and 7;
   if t=0 then h:=res;
   if(t=2)or(t=3)then h:=crater_sbase_tf(modv(subv(cp^.srbs[i].pos,p)),cp^.srbs[i].r,cp^.srbs[i].h,res);     
   if t=1 then begin
    h:=modv(subv(cp^.srbs[i].pos,p));
    h:=(h-cp^.srbs[i].r/2)/(cp^.srbs[i].r/2);
    h:=h*res;    
   end;
   if t=3 then h:=h+perlintf(@cp.noi,p,1000,3,tvec(1,1,1))*h*5*(1-modvs(subv(cp^.srbs[i].pos,p))/cp^.srbs[i].r2);
   
   if t<>0 then if modvs(subv(cp^.srbs[i].pos,p))<=cp^.srbs[i].r2/4 then h:=-0.1;

   if (cp^.srbs[i].t and 8)<>0 then if abs(h+0.1)<eps then h:=-0.19;
   
   res:=h;
  end;     
 end;   
 
 //Discreet
 //res:=res/9000;
 //res:=round(res*255)/255;
 //res:=res*9000;
      
 result:=nmulv(an,cp^.radius+res);  
 //puttcache(cp,a,result,res);  

 //if ocfg.multithreaded then if tthhdi=GetCurrentThreadid then releasemutex(tthmx);{$endif}
 except 
  wr_log('DefGetH','Undefined function error');
  if ocfg.multithreaded then bigerror(1,'DefGetH') else bigerror(0,'DefGetH');
 end; 
end; 
//############################################################################//
//############################################################################//
function defgetcf(cp:proampl;a:vec;lv:double;lvl:integer):crgba;
var i,bn,cdd,xh,yh,xl,yl:integer;
dx,dy,x,y,yf,c:double;
v:vec;
cmc,cvhh,cvhl,cvlh,cvll:crgba;
r:boolean;
begin try
 if a.x=0 then v.y:=3*pi/2 else v.y:=pi+arctan(a.z/a.x);
 if(a.x<0)then v.y:=v.y+sgn(a.z)*pi;
 if(a.x=0)and(a.z=0)then v.x:=pi/2 else v.x:=arctan(a.y/sqrt(sqr(a.x)+sqr(a.z)));
 
 result:=gclgray;
 
 r:=false;
 if (lvl>=cp^.tlnum-2)and(cp^.tlnum<>0) then r:=intertilex(cp,v,lvl,result);
 if not r then if cp^.txc<>0 then begin
  bn:=0;
  yf:=((pi/2-v.x)/(pi))*cp^.txhf;
  for i:=0 to length(cp^.tx)-1 do if yf>=cp^.txs[i] then bn:=i;
 
  x:=(v.y/(2*pi))*cp^.txw[bn]; 
  y:=yf-cp^.txs[bn];
      
  xh:=trunc(x);yh:=trunc(y);
  xl:=trunc(x)+1;yl:=trunc(y)+1;
  if xl>=cp^.txw[bn] then xl:=cp^.txw[bn]-1;if yl>=cp^.txh[bn] then yl:=cp^.txh[bn]-1;
  if xh>=cp^.txw[bn] then xh:=cp^.txw[bn]-1;if yh>=cp^.txh[bn] then yh:=cp^.txh[bn]-1;
  dx:=x-xh;dy:=y-yh;
     
  cvhh:=cp^.tx[bn][xh+yh*cp^.txw[bn]];cvlh:=cp^.tx[bn][xl+yh*cp^.txw[bn]];
  cvhl:=cp^.tx[bn][xh+yl*cp^.txw[bn]];cvll:=cp^.tx[bn][xl+yl*cp^.txw[bn]];

  result[0]:=round(cvhh[0]*(1-dx)*(1-dy)+cvlh[0]*dx*(1-dy)+cvhl[0]*(1-dx)*dy+cvll[0]*dx*dy);
  result[1]:=round(cvhh[1]*(1-dx)*(1-dy)+cvlh[1]*dx*(1-dy)+cvhl[1]*(1-dx)*dy+cvll[1]*dx*dy);
  result[2]:=round(cvhh[2]*(1-dx)*(1-dy)+cvlh[2]*dx*(1-dy)+cvhl[2]*(1-dx)*dy+cvll[2]*dx*dy);
 end;  
 
 
 for i:=0 to length(cp^.cmap)-1 do if cp^.cmap[i].used then if cp^.cmap[i].pri=0 then begin 
  if (v.x>cp^.cmap[i].lth)and(v.y>cp^.cmap[i].lnh)and(v.x<cp^.cmap[i].ltl)and(v.y<cp^.cmap[i].lnl) then begin  

   cmc:=intercmap(@cp^.cmap[i],v);
 
   if cp^.cmap[i].op=0 then result:=cmc;
   if cp^.cmap[i].op=1 then if (not((cmc[0]=165)and(cmc[1]=168)and(cmc[2]=165)))and(not((cmc[0]=0)and(cmc[1]=0)and(cmc[2]=5))) then result:=cmc;   
   if cp^.cmap[i].op=2 then if not((cmc[0]=0)and(cmc[1]=0)and(cmc[2]=0)) then result:=cmc;   
  end;
 end; 
 for i:=0 to length(cp^.cmap)-1 do if cp^.cmap[i].used then if cp^.cmap[i].pri=1 then begin 
  if (v.x>cp^.cmap[i].lth)and(v.y>cp^.cmap[i].lnh)and(v.x<cp^.cmap[i].ltl)and(v.y<cp^.cmap[i].lnl) then begin  

   cmc:=intercmap(@cp^.cmap[i],v);
 
   if cp^.cmap[i].op=0 then result:=cmc;
   if cp^.cmap[i].op=1 then if (not((cmc[0]=165)and(cmc[1]=168)and(cmc[2]=165)))and(not((cmc[0]=0)and(cmc[1]=0)and(cmc[2]=5))) then result:=cmc;   
   if cp^.cmap[i].op=2 then if not((cmc[0]=0)and(cmc[1]=0)and(cmc[2]=0)) then result:=cmc;   
  end;
 end;
  
 //1.88
 //0.95
 //0.8
 if cp^.mtex then if lv>0.2 then begin
  c:=pnoiNoise(@defnoi,a.x/5,a.y/5,a.z/5)*0.3+pnoiNoise(@defnoi,a.x/50,a.y/50,a.z/50)*0.3+pnoiNoise(@defnoi,a.x/500,a.y/500,a.z/500)*0.3;
  //c:=smnoise3d(a.x/5,a.y/5,a.z/5)*0.3+smnoise3d(a.x/50,a.y/50,a.z/50)*0.3+smnoise3d(a.x/500,a.y/500,a.z/500)*0.3;
  c:=c*(lv*0.9-0.2);
  cdd:=round(result[0]*(1-c));if cdd<0 then cdd:=0;if cdd>255 then cdd:=255;result[0]:=cdd;  
  cdd:=round(result[1]*(1-c));if cdd<0 then cdd:=0;if cdd>255 then cdd:=255;result[1]:=cdd;  
  cdd:=round(result[2]*(1-c));if cdd<0 then cdd:=0;if cdd>255 then cdd:=255;result[2]:=cdd;
 end;

    
 {
 //----Athmospheric shade
 c:=0.8; 
 v:=cp^.geth(cp,a,c);
 //c:=1-(round(c) mod 200)/100;
 x:=vdst(v,cp^.ccampos);
 c:=1-x/50000;
 //if c<0 then c:=-c; 
 if c>1 then c:=1;
 if c<0 then c:=0;
                          
 result[0]:=round(255*0.61-(255*0.61-result[0])*c); 
 result[1]:=round(255*0.8-(255*0.8-result[1])*c); 
 result[2]:=round(255-(255-result[2])*c); 
 //----End Of Athmospheric shade        
 }
 except
  wr_log('defgetc','Undefined color error');
  if ocfg.multithreaded then bigerror(1,'defgetc') else bigerror(0,'defgetc');
 end;  
end;
//############################################################################//
//############################################################################//
function defgetvf(cp:proampl;a:vec):crgba;
var d,pc:double;
v,an,p:vec;
dt3:integer;
begin try
 dt3:=getdt;
 stdt(dt3);  
 if a.x=0 then v.y:=3*pi/2 else v.y:=pi+arctan(a.z/a.x);
 if(a.x<0)then v.y:=v.y+sgn(a.z)*pi;
 if(a.x=0)and(a.z=0)then v.x:=pi/2 else v.x:=arctan(a.y/sqrt(sqr(a.x)+sqr(a.z)));

 an:=nrvec(a);
 p:=nmulv(an,cp^.radius);  
            
 pc:=1-cp.cld_prc; 
 d:=perlintf(@cp.noi,p,cp^.radius/4,8,evec)/2+0.5;  
 if d<pc then d:=0 else d:=(d-pc)*2;
 
 result:=cp.cld_col;
 result[3]:=round(255*(result[3]/255)*d);
 if d>1 then result[3]:=255;

 cp^.fnccltim:=cp^.fnccltim+rtdt(dt3); 
 freedt(dt3);       
 except
  wr_log('defgetc','Undefined color error');
  if ocfg.multithreaded then bigerror(1,'defgetc') else bigerror(0,'defgetc');
 end;  
end;
//############################################################################//
//############################################################################//
function rmsplit(cp:proampl;blk:pqrtree):boolean;
var u,v:vec;
//i:integer;
f:double;
begin try 
 result:=false;
 if blk=nil then exit;
 if not blk.used then exit; 
 if blk.c[1]<>nil then exit; 
 assert(blk.mag=BLK_MAG);
           
 if ocfg.multithreaded then mutex_lock(tthmx);
 del_q(Q_SPLIT,cp,blk.sqp); 
 if blk.c[1]<>nil then begin
  if blk.lv>3 then en_q(Q_MERGE,cp,blk,blk.prim,false);
  exit;
 end;
 
 
 f:=pow(2,blk.lv);
 if abs(blk.cnt.x)=cp^.radius then u:=tvec(blk.cnt.x/cp^.radius,0,0);
 if abs(blk.cnt.y)=cp^.radius then u:=tvec(0,blk.cnt.y/cp^.radius,0);
 if abs(blk.cnt.z)=cp^.radius then u:=tvec(0,0,blk.cnt.z/cp^.radius);
 u:=nmulv(vmulv(u,blk.dir),cp^.radius/f);
 v:=nmulv(blk.dir,cp^.radius/f);
   
 
 maqaddmkblk(cp,blk,1,addv(addv(blk.cnt,nmulv(u, 1)),nmulv(v, 1)),blk.dir,blk.qrt,blk.lv+1,0);
 maqaddmkblk(cp,blk,2,addv(addv(blk.cnt,nmulv(u, 1)),nmulv(v,-1)),blk.dir,blk.qrt,blk.lv+1,1);
 maqaddmkblk(cp,blk,3,addv(addv(blk.cnt,nmulv(u,-1)),nmulv(v,-1)),blk.dir,blk.qrt,blk.lv+1,2);
 maqaddmkblk(cp,blk,4,addv(addv(blk.cnt,nmulv(u,-1)),nmulv(v, 1)),blk.dir,blk.qrt,blk.lv+1,3);
 maqaddspl2(cp,blk);
 //for i:=1 to 4 do maqaddprctex(cp,blk,i);
 maqaddspl4(cp,blk);    
 if ocfg.multithreaded then mutex_release(tthmx);

 if blk.lv>=3 then cp^.predone:=true;
          
 except
  wr_log('RmSplit','Undefined Split error');
  if ocfg.multithreaded then bigerror(1,'RmSplit') else bigerror(0,'RmSplit');
  result:=false;
 end; 
end;
//############################################################################//
//############################################################################//
function rmunite(cp:proampl;blk:pqrtree):boolean;
var i:integer;
begin try   
 result:=false; 
 if blk=nil then exit;
 if not blk.used then exit;  
 assert(blk.mag=BLK_MAG);
           
 if ocfg.multithreaded then mutex_lock(tthmx);
 del_q(Q_MERGE,cp,blk.mqp);  
 if blk.c[1]=nil then begin en_q(Q_SPLIT,cp,blk,blk.pris,false);exit;end;
 for i:=1 to 4 do if blk.c[i].c[1]<>nil then rmunite(cp,blk.c[i]);
           
 maqaddmrg(cp,blk);    
 if ocfg.multithreaded then mutex_release(tthmx);

 result:=true;          
 except
  wr_log('RmUnite','Undefined Unite error');
  if ocfg.multithreaded then bigerror(1,'RmUnite') else bigerror(0,'RmUnite'); 
  result:=false;
 end;  
end;    
//############################################################################//
//############################################################################// 
procedure rmdomaq(cp:proampl); 
var k:pmaqrec;
i,j,l:integer;
begin k:=nil;try
 if cp.maqs>0 then begin
  k:=@cp.maq[cp.maqc];   
  case k.tp of
   1:begin       
    if ocfg.multithreaded then mutex_lock(tthmx);   
    assert(k.rt.mag=blk_mag);     
    mkblk(cp,k.rt,k.rt.c[k.cn],k.cnt,k.dir,k.qrt,k.lv,k.q); 
    if ocfg.multithreaded then mutex_release(tthmx);  
   end;
   2:begin    
    if ocfg.multithreaded then mutex_lock(tthmx);    
            
    blksetn(cp,k.rt); 
    
    for i:=1 to 4 do if k.rt.n[i]<>nil then assert(k.rt.n[i].mag=blk_mag);
    for i:=1 to 4 do if k.rt.c[i]<>nil then assert(k.rt.c[i].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].c[j]<>nil then assert(k.rt.n[i].c[j].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].n[j]<>nil then assert(k.rt.n[i].n[j].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do for l:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].c[j]<>nil then if k.rt.n[i].c[j].n[l]<>nil then assert(k.rt.n[i].c[j].n[l].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do for l:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].c[j]<>nil then if k.rt.n[i].c[j].c[l]<>nil then assert(k.rt.n[i].c[j].c[l].mag=blk_mag);  
    for i:=1 to 4 do for j:=1 to 4 do for l:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].n[j]<>nil then if k.rt.n[i].n[j].n[l]<>nil then assert(k.rt.n[i].n[j].n[l].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do for l:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].n[j]<>nil then if k.rt.n[i].n[j].c[l]<>nil then assert(k.rt.n[i].n[j].c[l].mag=blk_mag);
        
    if k.rt.n[1]<>nil then if k.rt.n[1].qrt=k.rt.qrt then begin assert(k.rt.n[1].mag=BLK_MAG);assert((k.rt.n[1].n[3]=k.rt));end;
    if k.rt.n[2]<>nil then if k.rt.n[2].qrt=k.rt.qrt then begin assert(k.rt.n[2].mag=BLK_MAG);assert((k.rt.n[2].n[4]=k.rt));end;
    if k.rt.n[3]<>nil then if k.rt.n[3].qrt=k.rt.qrt then begin assert(k.rt.n[3].mag=BLK_MAG);assert((k.rt.n[3].n[1]=k.rt));end;
    if k.rt.n[4]<>nil then if k.rt.n[4].qrt=k.rt.qrt then begin assert(k.rt.n[4].mag=BLK_MAG);assert((k.rt.n[4].n[2]=k.rt));end;  
      
    for i:=1 to 4 do blkcedges(cp,k.rt.c[i]);   
    if k.rt.n[1]<>nil then begin blkcedges(cp,k.rt.n[1].c[3]);blkcedges(cp,k.rt.n[1].c[4]);end;
    if k.rt.n[2]<>nil then begin blkcedges(cp,k.rt.n[2].c[1]);blkcedges(cp,k.rt.n[2].c[4]);end;
    if k.rt.n[3]<>nil then begin blkcedges(cp,k.rt.n[3].c[1]);blkcedges(cp,k.rt.n[3].c[2]);end;
    if k.rt.n[4]<>nil then begin blkcedges(cp,k.rt.n[4].c[2]);blkcedges(cp,k.rt.n[4].c[3]);end; 
           
    for i:=1 to 4 do k.rt.c[i].fin:=true;
    if ocfg.multithreaded then mutex_release(tthmx);  
   end;
   //3:if k.cn=-1 then prctex(cp,k.rt) else prctex(cp,k.rt.c[k.cn]);
   4:begin
    if ocfg.multithreaded then mutex_lock(tthmx); 
    for i:=1 to 4 do begin adddr(cp,k.rt.c[i]);addtr(cp,k.rt.c[i]);end; 
    if k.rt.dr<>nil then begin
     if k.rt.dr.pr<>nil then k.rt.dr.pr.nx:=k.rt.dr.nx;
     if k.rt.dr.nx<>nil then k.rt.dr.nx.pr:=k.rt.dr.pr;
     if k.rt.dr=cp^.drst then cp^.drst:=k.rt.dr.nx;  
     dispose(k.rt.dr);
     k.rt.dr:=nil;  
     cp^.drpolycount:=cp^.drpolycount-blkpcount;
     //dec(k.rt.draw_tex.uc);
     //if k.rt.draw_tex.uc<=0 then freehtex(k.rt.draw_tex); 
    end;     
    if k.rt.lv<cp^.levlimit then for i:=1 to 4 do en_q(Q_SPLIT,cp,k.rt.c[i],k.rt.c[i].pris,false);  
    k.rt.fin:=true;     
    if k.rt.lv>3 then en_q(Q_MERGE,cp,k.rt,k.rt.prim,false); 
    for i:=1 to 4 do blktrn(cp,k.rt.c[i],true); 
    if ocfg.multithreaded then mutex_release(tthmx);
   end;
   5:begin  
    if ocfg.multithreaded then mutex_lock(tthmx);
    assert(k.rt.mag=blk_mag);
    if k.rt.dr=nil then begin
     adddr(cp,k.rt);  
     //inc(k.rt.draw_tex.uc);
     //if k.rt.draw_tex.uc=1 then gethtex(cp,k.rt.draw_tex);
    end;   
    for i:=1 to 4 do dumpbl(cp,k.rt.c[i]);                   
    for i:=1 to 4 do if k.rt.n[i]<>nil then assert(k.rt.n[i].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].c[j]<>nil then assert(k.rt.n[i].c[j].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].n[j]<>nil then assert(k.rt.n[i].n[j].mag=blk_mag);   
    for i:=1 to 4 do for j:=1 to 4 do for l:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].c[j]<>nil then if k.rt.n[i].c[j].n[l]<>nil then assert(k.rt.n[i].c[j].n[l].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do for l:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].c[j]<>nil then if k.rt.n[i].c[j].c[l]<>nil then assert(k.rt.n[i].c[j].c[l].mag=blk_mag);  
    for i:=1 to 4 do for j:=1 to 4 do for l:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].n[j]<>nil then if k.rt.n[i].n[j].n[l]<>nil then assert(k.rt.n[i].n[j].n[l].mag=blk_mag);
    for i:=1 to 4 do for j:=1 to 4 do for l:=1 to 4 do if k.rt.n[i]<>nil then if k.rt.n[i].n[j]<>nil then if k.rt.n[i].n[j].c[l]<>nil then assert(k.rt.n[i].n[j].c[l].mag=blk_mag);
    
    for i:=1 to 4 do if k.rt.n[i]<>nil then for j:=1 to 4 do blkcedges(cp,k.rt.n[i].c[j]);      
    assert(k.rt.mag=blk_mag);
    en_q(Q_SPLIT,cp,k.rt,k.rt.pris,false);  
    k.rt.fin:=true; 
    if ocfg.multithreaded then mutex_release(tthmx);  
   end;
  end;
  cp.maqc:=cp.maqc+1;
  if cp.maqc>=MAQ_SIZ then cp.maqc:=0;
  dec(cp.maqs);
 end;            
 except
  wr_log('rmdomaq','Undefined error, k.rt='+stri(intptr(@k.rt))+'');
  if ocfg.multithreaded then bigerror(1,'rmdomaq') else bigerror(0,'rmdomaq'); 
 end;  
end;
//############################################################################//
//############################################################################//  
procedure rmtrn(cp:proampl;cx,sx,cy,sy:double);
var d:pdrlstyp;
begin        
 if not cp^.lded then exit; 
 d:=cp^.trst;
 repeat        
  if d.tr.mag<>BLK_MAG then exit;
  blktrn(cp,d.tr,false);
  d:=d.nx;
 until d=nil; 
end;  
//############################################################################//
//############################################################################//
procedure rmtessel(cp:proampl);
var ps,pm:double;
ib:boolean;
d:pdrlstyp;
begin try 
 if cp=nil then exit;
 if not cp^.lded then exit; 
 cp^.campos:=cp^.ccampos;
 ib:=false;

 stdt(dt1);

 if not ocfg.multithreaded then begin
  cp^.stat_balancing:=0;
  cp^.fnctim:=0;
  cp^.fnccltim:=0;
  cp^.stat_main_queue:=0;
  cp^.stat_priorities:=0;
  cp^.tottim:=0;
 end;        

 if cp.maqs<>0 then begin 
  stdt(dt21);
  while(cp.maqs>0)and(rtdt(dt21)<cp^.main_queue_time_slice)do rmdomaq(cp);
  cp^.tottim:=cp^.tottim+rtdt(dt1);
  cp^.stat_main_queue:=cp^.stat_main_queue+rtdt(dt21);
  exit;
 end;
 
 stdt(dt22);
 d:=cp^.lsrtu;
 if d=nil then d:=cp^.trst;
 if d=nil then exit;
 if d.tr.mag<>BLK_MAG then exit;
 repeat
  if (d.tr.sqp<>nil)or(d.tr.mqp<>nil) then begin
   clpri(cp,d.tr); 
   if rtdt(dt22)>=cp.priorities_time_slice then begin ib:=true;cp^.lsrtu:=d.nx;break;end;
  end;
  d:=d.nx;
 until d=nil;
 if not ib then cp^.lsrtu:=cp^.trst; 
 cp^.stat_priorities:=cp^.stat_priorities+rtdt(dt22);

 if cp^.sqm=nil then ps:=0 else ps:=cp^.sqm^.p;
 if cp^.mqm=nil then pm:=BUCK_CNT-1 else pm:=cp^.mqm^.p;
 
 stdt(dt23);
 while (((cp^.drpolycount<cp^.maxpolycount)and(ps>0))or((cp^.drpolycount>=cp^.maxpolycount)and(pm<BUCK_CNT-1)))and(rtdt(dt23)<cp.balancing_time_slice) do begin
  if (cp^.drpolycount>=cp^.maxpolycount)or(ps=0)then begin
   if cp^.mqm=nil then break;
   if pm<BUCK_CNT-1 then rmunite(cp,cp^.mqm^.i);
  end else begin
   if cp^.sqm=nil then break; 
   if ps>0 then rmsplit(cp,cp^.sqm^.i);
  end; 
  if cp^.sqm=nil then ps:=0 else ps:=cp^.sqm^.p;
  if cp^.mqm=nil then pm:=BUCK_CNT-1 else pm:=cp^.mqm^.p;
 end;
 cp^.tottim:=cp^.tottim+rtdt(dt1); 
 cp^.stat_balancing:=cp^.stat_balancing+rtdt(dt23); 
 //stdt(dt5);

 if not ib then cp^.lsrtu:=nil;

 stdt(dt23);
 while((rtdt(dt23)<cp^.textures_time_slice)and(cp^.tqm<>nil))do prctex(cp,cp^.tqm.i);
 //if(cp^.tqm<>nil) then prctex(cp,cp^.tqm.i);

 except
  wr_log('RmTessel','Undefined tesselation error');
  if ocfg.multithreaded then bigerror(1,'RmTessel') else bigerror(0,'RmTessel');
 end; 
end;
//############################################################################//  
//############################################################################//  
procedure rmplinit(cp:proampl;tp:integer=0);
var i,nn:integer;
begin nn:=0; try  
 if not assigned(cp^.fgeth) then cp^.fgeth:=defgethf;
 if not assigned(cp^.fgetc) then cp^.fgetc:=defgetcf;
 if not assigned(cp^.fgetv) then cp^.fgetv:=defgetvf;
 cp^.noi.seed:=cp.seed;
 cp^.noi.ci:=false;
 cp^.noi.ni:=false;
 cp^.maxblcount:=round(cp^.maxpolycount/blkpcount); 
 if cp^.texdir='' then cp^.texdir:='textures';
 if cp^.hmapdir='' then cp^.hmapdir:='heightmaps';
 
 cp^.used:=true; 
 cp^.predone:=false;
 cp^.blcount:=0;   
 cp^.texture_res:=ocfg.texture_res;

 for i:=0 to BUCK_CNT-1 do begin cp^.sq[i]:=nil;cp^.mq[i]:=nil;cp^.tq[i]:=nil;end;
 cp^.sqm:=nil;cp^.mqm:=nil;  cp^.tqm:=nil;
 cp^.maqc:=0;cp^.maqt:=0;cp^.maqs:=0;
 
 if tp=0 then begin
  if cp^.refidx<0 then cp^.refidx:=0;
  if cp^.refidx>3 then cp^.refidx:=3;

  for i:=0 to length(cp^.prtex)-1 do if cp^.prtex[i]<>nil then dispose(cp^.prtex[i]);
  setlength(cp^.prtex,0);  
                                                               
  mkblk(cp,nil,cp.qrs[0],tvec( 0, cp^.radius, 0),tvec(0,0, 1),0,1,0);  
  mkblk(cp,nil,cp.qrs[1],tvec( 0,-cp^.radius, 0),tvec(0,0,-1),1,1,0);  
  mkblk(cp,nil,cp.qrs[2],tvec( cp^.radius, 0, 0),tvec(0,1, 0),2,1,0);
  mkblk(cp,nil,cp.qrs[3],tvec(-cp^.radius, 0, 0),tvec(0,1, 0),3,1,0);
  mkblk(cp,nil,cp.qrs[4],tvec( 0, 0, cp^.radius),tvec(0,1, 0),4,1,0);
  mkblk(cp,nil,cp.qrs[5],tvec( 0, 0,-cp^.radius),tvec(0,1, 0),5,1,0);  
  for i:=0 to 5 do begin
   adddr(cp,cp.qrs[i]);
   addtr(cp,cp.qrs[i]);  
   cp.qrs[i].fin:=true;
   clpri(cp,cp.qrs[i]);  
   en_q(Q_SPLIT,cp,cp.qrs[i],cp.qrs[i].pris,false); 
  end;
  cp^.drpolycount:=6*blkpcount; 
 
  cp.qrs[0].n[1]:=cp.qrs[2];cp.qrs[0].n[2]:=cp.qrs[5];cp.qrs[0].n[3]:=cp.qrs[3];cp.qrs[0].n[4]:=cp.qrs[4]; 
  cp.qrs[1].n[1]:=cp.qrs[2];cp.qrs[1].n[2]:=cp.qrs[4];cp.qrs[1].n[3]:=cp.qrs[3];cp.qrs[1].n[4]:=cp.qrs[5]; 
  cp.qrs[2].n[1]:=cp.qrs[4];cp.qrs[2].n[2]:=cp.qrs[1];cp.qrs[2].n[3]:=cp.qrs[5];cp.qrs[2].n[4]:=cp.qrs[0];
  cp.qrs[3].n[1]:=cp.qrs[5];cp.qrs[3].n[2]:=cp.qrs[1];cp.qrs[3].n[3]:=cp.qrs[4];cp.qrs[3].n[4]:=cp.qrs[0];
  cp.qrs[4].n[1]:=cp.qrs[3];cp.qrs[4].n[2]:=cp.qrs[1];cp.qrs[4].n[3]:=cp.qrs[2];cp.qrs[4].n[4]:=cp.qrs[0];
  cp.qrs[5].n[1]:=cp.qrs[2];cp.qrs[5].n[2]:=cp.qrs[1];cp.qrs[5].n[3]:=cp.qrs[3];cp.qrs[5].n[4]:=cp.qrs[0];
  for i:=0 to 5 do blknmlsnei(cp,cp.qrs[i]); 
 end;
  
 nn:=2;
 if not ldpltex(cp,cp^.texdir+'2',false) then if not ldpltex(cp,cp^.texdir,false) then ldpltex(cp,cp^.texdir,true); 
 if not chpltexh(cp,cp^.texdir+'2')then chpltexh(cp,cp^.texdir);
        
 nn:=3;          
 for i:=cp^.level_of_global_heightmap downto 1 do if fileexists(cp^.hmapdir+'\'+cp^.name+'-lv'+stri(i)+'.hei') then begin
  cp^.level_of_global_heightmap:=i;
  try
   getheihmap(cp,'Global',cp^.name+'-lv'+stri(i),-90,90,0,360,32768,cp^.glhmop,cp^.glhmtr,1,true);
  except
   continue;
  end;
  break;
 end;   
 
 except on E:exception do begin
  if nn=0 then wr_log('RmPlInit','Undefined initialization error ('+e.message+')');
  if nn=2 then wr_log('RmPlInit','Error loading global texture ('+e.message+')');
  if nn=3 then wr_log('RmPlInit','Error loading global heightmap ('+e.message+')');
  bigerror(nn,'RmPlInit');
 end; end;
end;
//############################################################################//
//############################################################################//
procedure clrrplshmap(cp:proampl;c:integer);
begin try   
 if c=-1 then begin
  cp^.bhmap.used:=false; 
  cp^.bhmap.nam:='';
  setlength(cp^.bhmap.dat,0);
  exit;
 end;
 if c>=length(cp^.hmap) then exit;
 if c<0 then exit;
 cp^.hmap[c].used:=false;
 cp^.hmap[c].lth:=0;
 cp^.hmap[c].ltl:=0;
 cp^.hmap[c].lnh:=0;
 cp^.hmap[c].lnl:=0;
 cp^.hmap[c].scl:=0;
 cp^.hmap[c].w:=0;
 cp^.hmap[c].h:=0;
 cp^.hmap[c].op:=0; 
 cp^.hmap[c].tp:=0;  
 cp^.hmap[c].nam:='';
 
 cp^.hmap[c].slt:=0;
 cp^.hmap[c].sln:=0;
                 
 setlength(cp^.hmap[c].dat,0);         
 except
  wr_log('ClrRplsHmap','Undefined error');
  if ocfg.multithreaded then bigerror(1,'ClrRplsHmap') else bigerror(0,'ClrRplsHmap');
 end; 
end;
//############################################################################//  
procedure clrrplscmap(cp:proampl;c:integer);
begin try 
 if c>=length(cp^.cmap) then exit;
 if c<0 then exit;
 cp^.cmap[c].used:=false;
 cp^.cmap[c].lth:=0;
 cp^.cmap[c].ltl:=0;
 cp^.cmap[c].lnh:=0;
 cp^.cmap[c].lnl:=0;
 cp^.cmap[c].w:=0;
 cp^.cmap[c].h:=0;
 cp^.cmap[c].op:=0; 
 cp^.cmap[c].tp:=0;  
 cp^.cmap[c].nam:='';
 
 cp^.cmap[c].slt:=0;
 cp^.cmap[c].sln:=0;
                 
 setlength(cp^.cmap[c].dat,0);           
 except
  wr_log('ClrRplsCMap','Undefined error');
  if ocfg.multithreaded then bigerror(1,'ClrRplsCMap') else bigerror(0,'ClrRplsCMap');
 end; 
end;
//############################################################################//
procedure clrpls(cp:proampl);
var i:integer;
d,n:pdrlstyp;
p:pqrtree;
begin try 
 if cp=nil then exit;
 if not cp^.used then exit;      
 if apln=cp then dp_thr_term;
 cp^.used:=false;cp^.lded:=false;cp^.predone:=false;   
 cp^.fgeth:=defgethf;
 cp^.fgetc:=defgetcf;
 cp^.fgetv:=defgetvf;     
 cp^.noi.seed:=cp.seed;
 cp^.noi.ci:=false;
 cp^.noi.ni:=false;
 for i:=-1 to length(cp^.hmap)-1 do clrrplshmap(cp,i);
 for i:=-1 to length(cp^.cmap)-1 do clrrplscmap(cp,i);
 for i:= 0 to length(cp^.flat)-1 do cp^.flat[i].used:=false;   
 setlength(cp^.hmap,0);setlength(cp^.cmap,0);setlength(cp^.flat,0);
 
 setlength(cp.txw,0);setlength(cp.txh,0);setlength(cp.txs,0);
 for i:=0 to length(cp^.tx)-1 do setlength(cp.tx[i],0); 
 setlength(cp.tx,0);setlength(cp.srbs,0);

 d:=cp.trst; 
 if d=nil then exit;
 repeat
  n:=d.nx;
  p:=d.tr;
  dumpbl(cp,p);  
  d:=n; 
 until d=nil; 
  
 resettx(cp);   

 for i:=0 to 5 do cp.qrs[i]:=nil;  
 //---------------------------------------------------------------------------//
 setlength(cp.craters,0);
 cp.name:='';cp.texdir:='';cp.hmapdir:='';cp.tfuncs:='';cp.cfuncs:='';
 cp.speccol:=tvec(0,0,0);cp.ccampos:=tvec(0,0,0);
 cp.campos:=tvec(0,0,0);
                     
 cp.maqc:=0;cp.maqt:=0;cp.maqs:=0;
 cp.radius:=0;cp.seed:=0;cp.aoff:=0;cp.terid:=0;cp.levlimit:=0;cp.noilv:=0;
 cp.xa:=0;cp.ya:=0;cp.altitude_limit:=0;
 cp.blend_limit:=0;cp.specpow:=0;cp.textures_time_slice:=0;cp.balancing_time_slice:=0;cp.main_queue_time_slice:=0;cp.priorities_time_slice:=0;cp.texex:=0;
 cp.texnd:=0;cp.txc:=0;cp.txhf:=0;cp.stat_balancing:=0;cp.stat_main_queue:=0;
 cp.tottim:=0;cp.stat_priorities:=0;cp.fnctim:=0;cp.fnccltim:=0; cp.blcount:=0;
 cp.polycount:=0;cp.drpolycount:=0;cp.maxpolycount:=0;cp.maxblcount:=0;
 cp.sbcrlev:=0;cp.cratercnt:=0;cp.level_of_global_heightmap:=0;cp.glhmop:=0;cp.glhmtr:=0;
 
 cp.firstrun:=false;cp.basck:=false;cp.bels:=false;cp.mtex:=false;
 cp.fgeth:=nil;cp.fgetc:=nil;cp.fgetv:=nil;

 except
  wr_log('ClrPls','Undefined planet destruction error');
  //if ocfg.multithreaded then bigerror(1,'ClrPls') else bigerror(0,'ClrPls');
 end; 
end;
//############################################################################//
procedure clrplsmesh(cp:proampl);
var i:integer;
d,n:pdrlstyp;
p:pqrtree;
begin try 
 if not cp^.used then exit;

 d:=cp.trst; 
 if d=nil then exit;
 repeat
  n:=d.nx;
  p:=d.tr;
  dumpbl(cp,p);  
  d:=n; 
 until d=nil;

 for i:=0 to 5 do cp.qrs[i]:=nil;  
 //---------------------------------------------------------------------------//
 cp^.blcount:=0; 
 {
 for i:=0 to TCH_SIZ-1 do cp^.tch[i].tag:=tvec(0,0,0);
 cp^.ctchtim:=0;
 cp^.chut:=0;
 cp^.chms:=0;     
 cp^.chwr:=0;
 }
 for i:=0 to BUCK_CNT-1 do begin cp^.sq[i]:=nil;cp^.mq[i]:=nil;cp^.tq[i]:=nil;end;
 cp^.sqm:=nil;cp^.mqm:=nil;cp^.tqm:=nil;   
                
 resettx(cp);  
                                                               
 mkblk(cp,nil,cp.qrs[0],tvec( 0, cp^.radius, 0),tvec(0,0, 1),0,1,0);  
 mkblk(cp,nil,cp.qrs[1],tvec( 0,-cp^.radius, 0),tvec(0,0,-1),1,1,0);  
 mkblk(cp,nil,cp.qrs[2],tvec( cp^.radius, 0, 0),tvec(0,1, 0),2,1,0);
 mkblk(cp,nil,cp.qrs[3],tvec(-cp^.radius, 0, 0),tvec(0,1, 0),3,1,0);
 mkblk(cp,nil,cp.qrs[4],tvec( 0, 0, cp^.radius),tvec(0,1, 0),4,1,0);
 mkblk(cp,nil,cp.qrs[5],tvec( 0, 0,-cp^.radius),tvec(0,1, 0),5,1,0);  
 for i:=0 to 5 do begin
  adddr(cp,cp.qrs[i]);
  addtr(cp,cp.qrs[i]);
  cp.qrs[i].fin:=true;
  clpri(cp,cp.qrs[i]);  
  en_q(Q_SPLIT,cp,cp.qrs[i],cp.qrs[i].pris,false); 
 end;
 cp^.drpolycount:=6*blkpcount;
  
                               
 //---------------------------------------------------------------------------//
 cp^.tfuncc:=compexpr(cp^.tfuncs);   
 //cp.ctchtim:=0;cp.chut:=0;cp.chms:=0;cp.chwr:=0;
 cp.texex:=0;cp.texnd:=0;cp.tottim:=0;cp.stat_main_queue:=0;
 cp.stat_priorities:=0;cp.stat_balancing:=0;cp.fnctim:=0;cp.fnccltim:=0;
 cp.predone:=false;
      
 except
  wr_log('ClrPls','Undefined planet destruction error');
  if ocfg.multithreaded then bigerror(1,'ClrPls') else bigerror(0,'ClrPls');
 end; 
end;
//############################################################################//
//############################################################################//
begin        
 dt1:=getdt;
 dt22:=getdt;
 dt23:=getdt;
 dt21:=getdt;
end.
//############################################################################//  

