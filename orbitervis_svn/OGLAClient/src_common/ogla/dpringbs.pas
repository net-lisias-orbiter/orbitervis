//############################################################################//  
// Orbiter Visualisation Project OpenGL client
// Dynamic ring main           
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit dpringbs;
interface  
uses asys,grph,strval,maths,tim,math;  
//############################################################################//

const
RBLK_RES=500;
BUCK_CNT=4000;

type 
prngtrem=^rngtrem; 

prqrc=^rqrc;     
prdrlstyp=^rdrlstyp;
rqrc=record
 i:prngtrem;
 p:integer;
 u:boolean;
 nx,px:prqrc;
end;
        
rdrlstyp=record
 tr:prngtrem;
 pr,nx:prdrlstyp;
end;

rngtrem=record
 used:boolean;
 cnt,id:vec;
 lng,phi,phl,cntl:single;
 lv:integer;
 siz:double;    
 pris,prim:integer;
 
 c1,c2,c3,c4,bs:prngtrem;   
  
 mqp,sqp,tqp:prqrc;   
 dr,tr:prdrlstyp;
 
 pnts:packed array[0..RBLK_RES-1]of mvec;
 pntc:packed array[0..RBLK_RES-1]of crgbad;
end;

dpring=record
 used:boolean;
 pos:vec;
 obj:pointer;
 r1,r2,rm,rth,thk,othk:double;
 blcount,ptcount,levlimit:integer;  
 drptcount,maxptcount:integer;  
 
 sq,mq:array[0..BUCK_CNT]of prqrc;
 sqm,mqm:prqrc;  
 brs:array[0..3]of prngtrem; 

 rlts:typmsh;
 rngcls:array of crgbad; 
 
 ccampos,campos:vec;
 
 trst,drst,lsrtu:prdrlstyp;
end;
pdpring=^dpring;

//############################################################################//
var
rngpoints:packed array[0..RBLK_RES+4]of word;
                           
procedure dprinit(rn:pdpring);    
procedure dprtessel(rn:pdpring;prit,sect:double);
procedure makedpring(cr:pdpring;r1,r2:double);

implementation  
//############################################################################//

        
//############################################################################//  
procedure radddr(rn:pdpring;b:prngtrem);
begin 
 new(b.dr);
 b.dr.tr:=b;
 b.dr.pr:=nil;
 b.dr.nx:=rn^.drst;
 if rn^.drst=nil then begin
  rn^.drst:=b.dr;  
 end else begin
  rn^.drst.pr:=b.dr;
  rn^.drst:=b.dr;  
 end;
 rn^.drptcount:=rn^.drptcount+RBLK_RES;          
end;
//############################################################################//  
procedure raddtr(rn:pdpring;b:prngtrem);
begin 
 new(b.tr);
 b.tr.tr:=b;
 b.tr.pr:=nil;
 b.tr.nx:=rn^.trst;
 if rn^.trst=nil then begin
  rn^.trst:=b.tr;  
 end else begin
  rn^.trst.pr:=b.tr;
  rn^.trst:=b.tr;  
 end;               
end;   
//############################################################################// 
procedure rdelsplq(rn:pdpring;var q:prqrc);
var i:integer;
begin     
 if q=nil then exit;
 
 if q^.px<>nil then q^.px^.nx:=q^.nx;
 if q^.nx<>nil then q^.nx^.px:=q^.px;
 if rn^.sq[q^.p]=q then rn^.sq[q^.p]:=q^.nx;
           
 rn^.sqm:=nil; 
 for i:=BUCK_CNT-1 downto 0 do if rn^.sq[i]<>nil then begin rn^.sqm:=rn^.sq[i]; break; end;
        
 dispose(q);
 q:=nil;    
end;
//############################################################################//  
procedure rdelmrgq(rn:pdpring;var q:prqrc);
var i:integer;
begin    
 if q=nil then exit;
 
 if q^.px<>nil then q^.px^.nx:=q^.nx;
 if q^.nx<>nil then q^.nx^.px:=q^.px;
 if rn^.mq[q^.p]=q then rn^.mq[q^.p]:=q^.nx;
            
 rn^.mqm:=nil;
 for i:=0 to BUCK_CNT-1 do if rn^.mq[i]<>nil then begin rn^.mqm:=rn^.mq[i]; break; end;
        
 dispose(q);
 q:=nil;      
end; 
//############################################################################//  
procedure rdumpbl(rn:pdpring;var n:prngtrem);
begin 
 rdelsplq(rn,n.sqp);
 rdelmrgq(rn,n.mqp); 
   
 if n.dr<>nil then begin
  if n.dr.pr<>nil then n.dr.pr.nx:=n.dr.nx;
  if n.dr.nx<>nil then n.dr.nx.pr:=n.dr.pr;
  if n.dr=rn^.drst then rn^.drst:=n.dr.nx;  
  dispose(n.dr);
  
  rn^.drptcount:=rn^.drptcount-RBLK_RES;
 end;
 if n.tr<>nil then begin
  if n.tr.pr<>nil then n.tr.pr.nx:=n.tr.nx;
  if n.tr.nx<>nil then n.tr.nx.pr:=n.tr.pr;
  if n.tr=rn^.trst then rn^.trst:=n.tr.nx;
  if n.tr=rn^.lsrtu then rn^.lsrtu:=n.tr.nx; 
  dispose(n.tr);
 end;  
 dispose(n);
 
 rn^.blcount:=rn^.blcount-1;
 rn^.ptcount:=rn^.ptcount-RBLK_RES;  
 n:=nil;        
end;     
//############################################################################//  
//FIXME// - compare
procedure renqs(rn:pdpring;c:prngtrem;p:integer;t:boolean);
var q:prqrc;
i:integer;
begin  
 if c=nil then exit;
 if not c.used then exit;  
 if t and (c.sqp=nil)then exit;    
        
 q:=c.sqp; 
 if q<>nil then begin 
  if q^.p=p then exit;
  if q^.px<>nil then q^.px^.nx:=q^.nx;
  if q^.nx<>nil then q^.nx^.px:=q^.px;
  if rn^.sq[q^.p]=q then rn^.sq[q^.p]:=q^.nx;    
  q^.p:=p;
 end else begin
  new(q); 
  q^.u:=true;
  q^.i:=c;
  q^.p:=p;
  q^.px:=nil;
  q^.nx:=nil;
  c.sqp:=q;
 end;  
              
 if rn^.sq[p]<>nil then  rn^.sq[p].px:=q;  
 q^.nx:=rn^.sq[p];  
 q^.px:=nil;  
 rn^.sq[p]:=q;  
              
 rn^.sqm:=nil;
 for i:=BUCK_CNT-1 downto 0 do if rn^.sq[i]<>nil then begin rn^.sqm:=rn^.sq[i]; break; end;              
end;
//############################################################################//  
procedure renqm(rn:pdpring;c:prngtrem;p:integer;t:boolean);
var q:prqrc;   
i:integer;
begin
 if c=nil then exit;
 if not c.used then exit;  
 if t and (c.mqp=nil)then exit;    
        
 q:=c.mqp; 
 if q<>nil then begin 
  if q^.p=p then exit;   
  if q^.px<>nil then q^.px^.nx:=q^.nx;
  if q^.nx<>nil then q^.nx^.px:=q^.px;
  if rn^.mq[q^.p]=q then rn^.mq[q^.p]:=q^.nx;    
  q^.p:=p;
 end else begin
  new(q); 
  q^.u:=true;
  q^.i:=c;
  q^.p:=p;
  q^.px:=nil;
  q^.nx:=nil;
  c.mqp:=q;
 end;  
              
 if rn^.mq[p]<>nil then  rn^.mq[p].px:=q;  
 q^.nx:=rn^.mq[p];  
 q^.px:=nil;  
 rn^.mq[p]:=q;  
 
 rn^.mqm:=nil;
 for i:=0 to BUCK_CNT-1 do if rn^.mq[i]<>nil then begin rn^.mqm:=rn^.mq[i]; break; end;                     
end; 
//############################################################################//  
procedure rclpri(rn:pdpring;t:prngtrem); 
var kv:vec;
d,tvs,tvm:double;
begin
 kv:=t.cnt;
 d:=sqr(rn^.campos.x-kv.x)+sqr(rn^.campos.y-kv.y)+sqr(rn^.campos.z-kv.z);

 tvs:=log2(t.siz)/log2(d{*abs(rn^.campos.y)});
 tvm:=tvs; 
 
 t.pris:=round(tvs*BUCK_CNT); 
 if t.pris<0 then t.pris:=0;if t.pris>=BUCK_CNT then t.pris:=BUCK_CNT-1;
 t.prim:=round(tvm*BUCK_CNT); 
 if t.prim<0 then t.prim:=0;if t.prim>=BUCK_CNT then t.prim:=BUCK_CNT-1;
 
 renqm(rn,t,t.prim,true); 
 renqs(rn,t,t.pris,true);   
end;
//############################################################################//  
procedure rntsiz(rn:pdpring;blk:prngtrem);
//var i:integer;
begin
 blk.siz:=(rn.rth/pow(2,(blk.lv-1)))*1.414;  
 //i:=PLT_RES*PLT_RES div 2;
 //blk.rcnt:=tvec(blk.msh[i].x,blk.msh[i].y,blk.msh[i].z);

 //if blk.siz>cp^.noilv then blk.lvc:=0;
 //blk.lvc:=1-(blk.siz/cp^.noilv);
end;
//############################################################################//
procedure mkrnt(rn:pdpring;rt:prngtrem;var blk:prngtrem;cnt:vec;lv,tp:integer);
var i:integer;
l,f:double;
v:vec;
begin 
 f:=0;
 if tp<>-1 then begin
  l:=0;f:=0;
  case tp of
   0:begin l:=rt.cntl+rt.lng/4;f:=rt.phi+rt.phl/4;end;
   1:begin l:=rt.cntl-rt.lng/4;f:=rt.phi+rt.phl/4;end;
   2:begin l:=rt.cntl-rt.lng/4;f:=rt.phi-rt.phl/4;end;
   3:begin l:=rt.cntl+rt.lng/4;f:=rt.phi-rt.phl/4;end;
  end;
  cnt:=tvec(l*sin(f),0,l*cos(f));
 end;

 new(blk);
 blk.used:=true;
 blk.c1:=nil;blk.c2:=nil;blk.c3:=nil;blk.c4:=nil;
 blk.bs:=rt;  
 blk.cnt:=cnt;
 blk.cntl:=modv(cnt);  
 blk.lv:=lv;
 blk.sqp:=nil;
 blk.mqp:=nil;
 blk.dr:=nil;
 blk.tr:=nil;    
 blk.pris:=0;
 blk.prim:=0;
 blk.id:=blk.cnt;  

 blk.lng:=rn.rth/pow(2,lv-1);
 blk.phl:=(pi/2)/pow(2,lv-1); 

 if tp<>-1 then begin
  blk.phi:=f;
 end else begin
  v:=nrvec(cnt);
  if v.x=0 then blk.phi:=ord(v.z<0)*(pi);
  if v.z=0 then blk.phi:=pi-sgn(v.x)*(pi/2);        
  if(v.x>0)and(v.z>0)then blk.phi:=arctan(v.x/v.z);
  if(v.x>0)and(v.z<0)then blk.phi:=pi-arctan(v.x/(-v.z));
  if(v.x<0)and(v.z<0)then blk.phi:=pi+arctan(-v.x/(-v.z));
  if(v.x<0)and(v.z>0)then blk.phi:=3*pi/2+arctan(1-(-v.x/v.z));
 end;
 

 for i:=0 to RBLK_RES-1 do begin
  l:=random*blk.lng-blk.lng/2+blk.cntl;
  f:=random*blk.phl-blk.phl/2+blk.phi;
  v:=tvec(l*sin(f),random*rn.thk-rn.thk/2,l*cos(f));
  
  blk.pnts[i]:=v2m(v);
  if length(rn.rngcls)<>0 then blk.pntc[i]:=rn.rngcls[round((length(rn.rngcls)-6)*(l-rn.r1)/rn.rth)+6] else blk.pntc[i]:=tcrgbad(1,0,0,1);
 end;
 
 rntsiz(rn,blk);
 
 rn^.blcount:=rn^.blcount+1;
 rn^.ptcount:=rn^.ptcount+RBLK_RES;             
end;
//############################################################################//
procedure dprsplit(rn:pdpring;blk:prngtrem);
begin
 if not blk.used then exit;
 rdelsplq(rn,blk.sqp); 
  
 renqm(rn,blk,blk.prim,false); 
 if blk.c1<>nil then exit;
  
 mkrnt(rn,blk,blk.c1,tvec(0,0,0),blk.lv+1,0);
 mkrnt(rn,blk,blk.c2,tvec(0,0,0),blk.lv+1,1);
 mkrnt(rn,blk,blk.c3,tvec(0,0,0),blk.lv+1,2);
 mkrnt(rn,blk,blk.c4,tvec(0,0,0),blk.lv+1,3);  
 
 radddr(rn,blk.c1);
 radddr(rn,blk.c2);
 radddr(rn,blk.c3); 
 radddr(rn,blk.c4);    
 raddtr(rn,blk.c1);
 raddtr(rn,blk.c2);
 raddtr(rn,blk.c3); 
 raddtr(rn,blk.c4); 

 if blk.dr<>nil then begin
  if blk.dr.pr<>nil then blk.dr.pr.nx:=blk.dr.nx;
  if blk.dr.nx<>nil then blk.dr.nx.pr:=blk.dr.pr;
  if blk.dr=rn^.drst then rn^.drst:=blk.dr.nx;  
  dispose(blk.dr);
  blk.dr:=nil;  
  rn^.drptcount:=rn^.drptcount-RBLK_RES;
 end;              

 if blk.lv<rn^.levlimit then begin
  renqs(rn,blk.c1,blk.c1.pris,false);
  renqs(rn,blk.c2,blk.c2.pris,false);
  renqs(rn,blk.c3,blk.c3.pris,false);
  renqs(rn,blk.c4,blk.c4.pris,false);
 end; 
end; 
//############################################################################//
procedure dprunite(rn:pdpring;blk:prngtrem);
begin
 if blk=nil then exit;
 if not blk.used then exit; 
 rdelmrgq(rn,blk.mqp);  
 renqs(rn,blk,blk.pris,false);
  
 if blk.c1=nil then  exit; 
 if blk.c1.c1<>nil then dprunite(rn,blk.c1);
 if blk.c2.c1<>nil then dprunite(rn,blk.c2);
 if blk.c3.c1<>nil then dprunite(rn,blk.c3);
 if blk.c4.c1<>nil then dprunite(rn,blk.c4);

 if blk.dr=nil then begin
  new(blk.dr);
  blk.dr.tr:=blk;
  blk.dr.pr:=nil;
  blk.dr.nx:=rn^.drst;
  rn^.drst.pr:=blk.dr;
  rn^.drst:=blk.dr;
  
  rn^.drptcount:=rn^.drptcount+RBLK_RES;
 end;         
  
 rdumpbl(rn,blk.c1);
 rdumpbl(rn,blk.c2);
 rdumpbl(rn,blk.c3);
 rdumpbl(rn,blk.c4);
end;     
//############################################################################//
//############################################################################//
procedure dprtessel(rn:pdpring;prit,sect:double);
var ps,pm:double;
ib:boolean;
d:prdrlstyp;
dt:integer;
begin
 rn^.campos:=rn^.ccampos;
 ib:=false;
 if prit=0 then prit:=1000;//rn^.prit;
 if sect=0 then sect:=1000;//rn^.sect;

 d:=rn^.lsrtu;
 if d=nil then d:=rn^.trst;
 if d=nil then exit;

 dt:=getdt;
 stdt(dt); 
 repeat
  if (d.tr.sqp<>nil)or(d.tr.mqp<>nil) then begin
   rclpri(rn,d.tr); 
   if rtdt(dt)>=prit then begin
    ib:=true;  
    rn^.lsrtu:=d.nx;
    break;
   end;   
  end;  
  d:=d.nx;
 until d=nil;
 if not ib then rn^.lsrtu:=rn^.trst;
      
 if rn^.sqm=nil then ps:=maxint else ps:=rn^.sqm^.p;
 if rn^.mqm=nil then pm:=0 else pm:=rn^.mqm^.p;
 stdt(dt);
 while ((rn^.drptcount<rn^.maxptcount)or(ps>pm))and(rtdt(dt)<sect) do begin
  if (rn^.drptcount>=rn^.maxptcount)then begin
   if rn^.mqm=nil then break;
   dprunite(rn,rn^.mqm^.i);
  end else begin    
   if rn^.sqm=nil then break; 
   dprsplit(rn,rn^.sqm^.i);
  end; 
  if rn^.sqm=nil then ps:=maxint else ps:=rn^.sqm^.p;
  if rn^.mqm=nil then pm:=0 else pm:=rn^.mqm^.p;
 end;
 //stdt(5);
 freedt(dt);
  
 if not ib then rn^.lsrtu:=nil;
end;
//############################################################################//
procedure dprinit(rn:pdpring);
var i:integer;
begin
 rn.used:=true;

 for i:=0 to BUCK_CNT-1 do rn^.sq[i]:=nil;
 for i:=0 to BUCK_CNT-1 do rn^.mq[i]:=nil;
 rn^.sqm:=nil;
 rn^.mqm:=nil;  
                                                               
 mkrnt(rn,nil,rn.brs[0],tvec(0,0, rn^.rm),1,-1);  
 mkrnt(rn,nil,rn.brs[1],tvec( rn^.rm,0,0),1,-1);  
 mkrnt(rn,nil,rn.brs[2],tvec(0,0,-rn^.rm),1,-1);
 mkrnt(rn,nil,rn.brs[3],tvec(-rn^.rm,0,0),1,-1);  
 for i:=0 to 3 do radddr(rn,rn.brs[i]);
 for i:=0 to 3 do raddtr(rn,rn.brs[i]); 

 rn^.drptcount:=4*RBLK_RES; 
 rn.blcount:=0;
 rn.ptcount:=0;
 
  
 for i:=0 to 3 do rclpri(rn,rn.brs[i]);  
 for i:=0 to 3 do renqs(rn,rn.brs[i],rn.brs[i].pris,false); 
 //dprsplit(rn,rn.brs[0]);
 //dprsplit(rn,rn.brs[0].c1);
end;
//############################################################################//
//############################################################################//
procedure makedpring(cr:pdpring;r1,r2:double);
var i:integer;
begin
 cr.used:=true;
 cr.pos:=tvec(0,0,0);
 //cr.obj:=cp;
 cr.thk:=1*1e3;
 cr.othk:=50*1e3;
 cr.r1:=r1;
 cr.r2:=r2;
 cr.rm:=cr.r1+(cr.r2-cr.r1)/2;
 cr.rth:=cr.r2-cr.r1;
 cr.levlimit:=20;
 cr.maxptcount:=100000;

 setlength(cr.rngcls,256);
 for i:=0 to 255 do cr.rngcls[i]:=tcrgbad(i/255,1-i/255,0,1);
end;

//############################################################################//
var i:integer;
begin
 for i:=0 to RBLK_RES+4-1 do rngpoints[i]:=i;
end.  
//############################################################################//
