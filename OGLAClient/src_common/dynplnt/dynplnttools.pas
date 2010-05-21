//############################################################################//
// Orulex: Dynamic planet tools
// Released under GNU General Public License
// Made in 2006-2010 by Artyom Litvinovich
//############################################################################//
unit dynplnttools;
{$ifdef fpc}{$mode delphi}{$endif}
interface
uses asys,grph,dynplntbase,maths,math,log,strval{$ifndef no_render},glgr{$endif};
//############################################################################//
const 
Q_SPLIT=0;
Q_MERGE=1;
Q_TEXTURE=2;
//############################################################################//   
procedure del_q(tp:integer;cp:proampl;var q:pqrc);   
procedure en_q(tp:integer;cp:proampl;c:pqrtree;p:integer;t:boolean);

procedure dumpbl(cp:proampl;var n:pqrtree);   
function  getprtex(cp:proampl):ptextyp;
procedure adddr(cp:proampl;b:pqrtree);
procedure addtr(cp:proampl;b:pqrtree);
procedure mvrev(src,dst:pointer);
procedure mvfor(src,dst:pointer;stp:integer);
procedure mvforrev(src,dst:pointer;stp:integer);  

procedure maqaddmkblk(cp:proampl;rt:pqrtree;cn:integer;cnt,dir:vec;qrt,lv,q:integer);
procedure maqaddspl2(cp:proampl;rt:pqrtree);
procedure maqaddprctex(cp:proampl;rt:pqrtree;cn:integer);
procedure maqaddspl4(cp:proampl;rt:pqrtree);
procedure maqaddmrg(cp:proampl;rt:pqrtree);

procedure clpri(cp:proampl;t:pqrtree);     
                                   
procedure makhtex(cp:proampl;tex:ptextyp);
procedure gethtex(cp:proampl;var tex:ptextyp); 
procedure freehtex(cp:proampl;var tex:ptextyp);    
procedure resettx(cp:proampl);
//############################################################################//
implementation 
//############################################################################//  
procedure makhtex(cp:proampl;tex:ptextyp);
var i,o:integer;
p:pbcrgba;
begin              
 getmem(p,(cp.texture_res-1)*(cp.texture_res-1)*4);
 tex.ld:=true;
 o:=0;              
 for i:=0 to cp.texture_res-1 do if i<>cp.texture_res div 2 then begin
  move(tex.tx[i*cp.texture_res],p[o*(cp.texture_res-1)],(cp.texture_res-1)*4);
  o:=o+1;
 end;
 {$ifndef no_render}glgr_make_tex(tex.gltx,cp.texture_res-1,cp.texture_res-1,p,false,true,false,true);{$endif}  
 //glgr_make_tex(tex.gltx,cp.texture_res-1,cp.texture_res-1,@tex.tx[0],false,true,false,true);
 freemem(p);
end;
//############################################################################//  
procedure gethtex(cp:proampl;var tex:ptextyp);
//var i:integer;
begin try
 if tex=nil then exit;
 if not tex.used then exit;
                
 if ocfg.multithreaded then tex.ld:=false else makhtex(cp,tex);   
 
 inc(cp.tex_cnt); 
 except
  wr_log('GetHTex','Texture aquisition error');
  //bigerror(0);
 end;
end;          
//############################################################################//
procedure freehtex(cp:proampl;var tex:ptextyp);
begin try    
 if tex=nil then exit;
 if not tex.used then exit;
 
 tex.ld:=false;
 dec(cp.tex_cnt); 
 {$ifndef no_render}glgr_free_tex(tex.gltx);{$endif}
 tex.gltx:=0;
 tex.uc:=0;
   
 except
  wr_log('DefFreeHTex','Texture release error');
  //bigerror(0);
 end;
end;  
//############################################################################// 
procedure resettx(cp:proampl);
var i:integer;
begin         
 cp.tex_cnt:=0;
 for i:=0 to length(cp.prtex)-1 do if cp.prtex[i]<>nil then begin
  {$ifndef no_render}if cp.prtex[i].used then glgr_free_tex(cp.prtex[i].gltx);{$endif}
  freemem(cp.prtex[i].tx);
  dispose(cp.prtex[i]);
 end;
 setlength(cp.prtex,0);
end;   
//############################################################################//  
//############################################################################//  
procedure del_q(tp:integer;cp:proampl;var q:pqrc);
var i:integer;
begin try     
 if q=nil then exit;
 
 if q^.px<>nil then q^.px^.nx:=q^.nx;
 if q^.nx<>nil then q^.nx^.px:=q^.px;
 case tp of
  Q_TEXTURE:begin
   if cp^.tq[q^.p]=q then cp^.tq[q^.p]:=q^.nx;
   cp^.tqm:=nil;
   for i:=0 to BUCK_CNT-1 do if cp^.tq[i]<>nil then begin cp^.tqm:=cp^.tq[i]; break; end;
  end;
  Q_MERGE:begin
   if cp^.mq[q^.p]=q then cp^.mq[q^.p]:=q^.nx;            
   cp^.mqm:=nil;
   for i:=0 to BUCK_CNT-1 do if cp^.mq[i]<>nil then begin cp^.mqm:=cp^.mq[i]; break; end;
  end;
  Q_SPLIT:begin
   if cp^.sq[q^.p]=q then cp^.sq[q^.p]:=q^.nx;           
   cp^.sqm:=nil; 
   for i:=BUCK_CNT-1 downto 0 do if cp^.sq[i]<>nil then begin cp^.sqm:=cp^.sq[i]; break; end;
  end;
 end;
        
 dispose(q);
 q:=nil;    
 except
  wr_log('Del_Q','Undefined error');
  bigerror(0,'Del_Q');
 end;    
end;    
//############################################################################//  
//FIXME// - compare 
procedure en_q(tp:integer;cp:proampl;c:pqrtree;p:integer;t:boolean);
var q:pqrc;   
i:integer;
eqp:^pqrc;
eq:^apqrc;
begin eq:=nil;eqp:=nil;try  
 if c=nil then exit;
 assert(c.mag=BLK_MAG);
 if not c.used then exit;  
 case tp of
  Q_TEXTURE:begin eq:=@cp^.tq; eqp:=@c.tqp; end;  
  Q_MERGE:begin eq:=@cp^.mq; eqp:=@c.mqp; end;  
  Q_SPLIT:begin eq:=@cp^.sq; eqp:=@c.sqp; end;  
 end;
 if t and (eqp^=nil)then exit;    
        
 q:=eqp^; 
 if q<>nil then begin 
  if q^.p=p then exit;   
  if q^.px<>nil then q^.px^.nx:=q^.nx;
  if q^.nx<>nil then q^.nx^.px:=q^.px;
  if eq^[q^.p]=q then eq^[q^.p]:=q^.nx;    
  q^.p:=p;
 end else begin
  new(q); 
  q^.u:=true;
  q^.i:=c;
  q^.p:=p;
  q^.px:=nil;
  q^.nx:=nil;
  eqp^:=q;
 end;  
              
 if eq^[p]<>nil then eq^[p].px:=q;  
 q^.nx:=eq^[p];  
 q^.px:=nil;  
 eq^[p]:=q;  
 
 case tp of
  Q_TEXTURE:begin
   cp^.tqm:=nil;
   for i:=0 to BUCK_CNT-1 do if cp^.tq[i]<>nil then begin cp^.tqmi:=i; cp^.tqm:=cp^.tq[i]; break; end;                          
  end;
  Q_MERGE:begin
   cp^.mqm:=nil;
   for i:=0 to BUCK_CNT-1 do if cp^.mq[i]<>nil then begin cp^.mqm:=cp^.mq[i]; break; end;   
   while cp^.mqm.nx<>nil do cp^.mqm:=cp^.mqm.nx;                           
  end;
  Q_SPLIT:begin
   cp^.sqm:=nil;
   for i:=BUCK_CNT-1 downto 0 do if cp^.sq[i]<>nil then begin cp^.sqm:=cp^.sq[i]; break; end;                     
  end;
 end;
 except
  wr_log('En_Q','Error in texture queue handling, c='+stri(intptr(c)));
  if ocfg.multithreaded then bigerror(1,'En_Q') else bigerror(0,'En_Q');
 end;  
end; 
//############################################################################//  
procedure dumpbl(cp:proampl;var n:pqrtree);
var i,j:integer;
begin try         
 if n=nil then exit;
 assert(n.mag=BLK_MAG);
       
 n.mag:=0;
 for i:=1 to 4 do if n.n[i]<>nil then begin
  assert(n.n[i].mag=BLK_MAG);
  for j:=1 to 4 do if n.n[i].n[j]=n then n.n[i].n[j]:=nil;
 end;
 
 for i:=1 to 4 do begin 
  //assert(n.c[i]=nil);
  n.n[i]:=nil;
  n.c[i]:=nil;
 end;
  
 del_q(Q_SPLIT,cp,n.sqp);
 del_q(Q_MERGE,cp,n.mqp); 
 del_q(Q_TEXTURE,cp,n.tqp); 
 
 dec(n.draw_tex.uc);
 if n.own_tex<>nil then begin
  dec(n.own_tex.uc);   
  if n.own_tex.uc<=0 then begin
   freehtex(cp,n.own_tex); 
   n.own_tex.used:=false;
  end;
 end;   
 n.draw_tex:=nil;
 n.own_tex:=nil;
 
 if n.dr<>nil then begin
  if n.dr.pr<>nil then n.dr.pr.nx:=n.dr.nx;
  if n.dr.nx<>nil then n.dr.nx.pr:=n.dr.pr;
  if n.dr=cp^.drst then cp^.drst:=n.dr.nx;  
  dispose(n.dr);
  
  cp^.drpolycount:=cp^.drpolycount-blkpcount;
 end;
 if n.tr<>nil then begin
  if n.tr.pr<>nil then n.tr.pr.nx:=n.tr.nx;
  if n.tr.nx<>nil then n.tr.nx.pr:=n.tr.pr;
  if n.tr=cp^.trst then cp^.trst:=n.tr.nx;
  if n.tr=cp^.lsrtu then cp^.lsrtu:=n.tr.nx; 
  dispose(n.tr);
 end;      
 dispose(n);
 cp^.blcount:=cp^.blcount-1;    
 cp^.polycount:=cp^.polycount-blkpcount;
 n:=nil;
 except
  wr_log('DumpBlock','Undefined error n='+stri(intptr(n)));
  if ocfg.multithreaded then bigerror(1,'DumpBlock') else bigerror(0,'DumpBlock');
 end;  
end;
//############################################################################//  
function getprtex(cp:proampl):ptextyp;
var i,c:integer;
begin
 c:=-1;
 for i:=0 to length(cp^.prtex)-1 do if cp^.prtex[i]<>nil then if not cp^.prtex[i].used then begin c:=i; break; end;
 if c=-1 then for i:=0 to length(cp^.prtex)-1 do if cp^.prtex[i]=nil then begin 
  c:=i; 
  new(cp^.prtex[i]);  
  getmem(cp^.prtex[i].tx,cp.texture_res*cp.texture_res*4);
  break;
 end;
 if c=-1 then begin
  c:=length(cp^.prtex);
  setlength(cp^.prtex,c*2+1);
  for i:=c to length(cp^.prtex)-1 do cp^.prtex[i]:=nil;
  new(cp^.prtex[c]);
  getmem(cp^.prtex[c].tx,cp.texture_res*cp.texture_res*4);
 end;
 result:=cp^.prtex[c];
end;
//############################################################################//  
procedure adddr(cp:proampl;b:pqrtree);
begin try    
 if b=nil then exit;
 assert(b.mag=BLK_MAG);
 new(b.dr);
 b.dr.tr:=b;
 b.dr.pr:=nil;
 b.dr.nx:=cp^.drst;
 if cp^.drst=nil then begin
  cp^.drst:=b.dr;  
 end else begin
  cp^.drst.pr:=b.dr;
  cp^.drst:=b.dr;  
 end;
 cp^.drpolycount:=cp^.drpolycount+blkpcount;         
 except
  wr_log('AddDr','Undefined error');
  if ocfg.multithreaded then bigerror(1,'AddDr') else bigerror(0,'AddDr');
 end;  
end;
//############################################################################//  
procedure addtr(cp:proampl;b:pqrtree);
begin try    
 if b=nil then exit;
 assert(b.mag=BLK_MAG);
 new(b.tr);
 b.tr.tr:=b;
 b.tr.pr:=nil;
 b.tr.nx:=cp^.trst;
 if cp^.trst=nil then begin
  cp^.trst:=b.tr;  
 end else begin
  cp^.trst.pr:=b.tr;
  cp^.trst:=b.tr;  
 end;               
 except
  wr_log('AddTr','Undefined error');
  if ocfg.multithreaded then bigerror(1,'AddTr') else bigerror(0,'AddTr');
 end;  
end;
//############################################################################//
procedure mvrev(src,dst:pointer);
var i:integer;
begin
 for i:=0 to 255 do pdword(intptr(dst)+intptr(i*4))^:=pdword(intptr(src)+intptr((255-i)*4))^;
end;
//############################################################################//  
procedure mvfor(src,dst:pointer;stp:integer);
var i,j,st1:integer;
begin   
 st1:=stp-1;
 for i:=0 to 255 do for j:=0 to st1 do pdword(intptr(dst)+intptr(i*4*stp+j*4))^:=pdword(intptr(src)+intptr(i*4))^;
end;
//############################################################################//  
procedure mvforrev(src,dst:pointer;stp:integer);
var i,j,st1:integer;
begin
 st1:=stp-1;
 for i:=0 to 255 do for j:=0 to st1 do pdword(intptr(dst)+intptr(i*4*stp+j*4))^:=pdword(intptr(src)+intptr((255-i)*4))^;
end;
//############################################################################//
//############################################################################//
procedure maqaddmkblk(cp:proampl;rt:pqrtree;cn:integer;cnt,dir:vec;qrt,lv,q:integer);
begin         
 if rt=nil then exit;
 assert(rt.mag=BLK_MAG);
 cp.maq[cp.maqt].tp:=1;
 cp.maq[cp.maqt].rt:=rt;
 cp.maq[cp.maqt].cn:=cn;
 cp.maq[cp.maqt].cnt:=cnt;
 cp.maq[cp.maqt].dir:=dir;  
 cp.maq[cp.maqt].qrt:=qrt;
 cp.maq[cp.maqt].lv:=lv;
 cp.maq[cp.maqt].q:=q;
 
 inc(cp.maqt);inc(cp.maqs);if cp.maqt>=MAQ_SIZ then cp.maqt:=0;
end;
//############################################################################//
procedure maqaddspl2(cp:proampl;rt:pqrtree);
begin        
 if rt=nil then exit;
 assert(rt.mag=BLK_MAG);
 cp.maq[cp.maqt].tp:=2;
 cp.maq[cp.maqt].rt:=rt;
 
 inc(cp.maqt);inc(cp.maqs);if cp.maqt>=MAQ_SIZ then cp.maqt:=0;
end;
//############################################################################//
procedure maqaddprctex(cp:proampl;rt:pqrtree;cn:integer);
begin         
 if rt=nil then exit;
 assert(rt.mag=BLK_MAG);
 cp.maq[cp.maqt].tp:=3;
 cp.maq[cp.maqt].rt:=rt;
 cp.maq[cp.maqt].cn:=cn;
 
 inc(cp.maqt);inc(cp.maqs);if cp.maqt>=MAQ_SIZ then cp.maqt:=0;
end;   
//############################################################################//
procedure maqaddspl4(cp:proampl;rt:pqrtree);
begin              
 if rt=nil then exit;
 assert(rt.mag=BLK_MAG);
 cp.maq[cp.maqt].tp:=4;
 cp.maq[cp.maqt].rt:=rt;
 
 inc(cp.maqt);inc(cp.maqs);if cp.maqt>=MAQ_SIZ then cp.maqt:=0;
end;
//############################################################################//
procedure maqaddmrg(cp:proampl;rt:pqrtree);
begin         
 if rt=nil then exit;
 assert(rt.mag=BLK_MAG);
 cp.maq[cp.maqt].tp:=5;
 cp.maq[cp.maqt].rt:=rt;
 
 inc(cp.maqt);inc(cp.maqs);if cp.maqt>=MAQ_SIZ then cp.maqt:=0;
end;
//############################################################################//  
procedure clpri(cp:proampl;t:pqrtree); 
var kv:vec;
d,tvs,tvm,tvt:double;
i:integer;
begin i:=0;try           
 if t=nil then exit;
 assert(t.mag=BLK_MAG);
 if not t.fin then exit; 

 kv:=t.rcnt;
 d:=sqr(cp^.campos.x-kv.x)+sqr(cp^.campos.y-kv.y)+sqr(cp^.campos.z-kv.z);

 tvs:=0;
 tvm:=1;
 if cp^.texture_gen_order=1 then 
  tvt:=1-t.lv/cp.levlimit else 
  tvt:=t.lv/cp.levlimit;
 tvt:=tvt*(log2(d)/log2(sqr(cp^.radius)));
 
 if d<sqr(cp^.texture_range_factor*t.siz) then tvs:=0.9;
                                
 for i:=1 to 4 do if t.n[i]<>nil then if t.n[i].mag<>blk_mag then t.n[i]:=nil;
 for i:=1 to 4 do if t.n[i]<>nil then if t.n[i].c[1]<>nil then if t.n[i].c[1].c[1]<>nil then tvs:=1;i:=0;
    
 if tvs=0 then tvm:=0;
 
 if t.c[1]=nil then tvm:=1; 
 if t.lv>=cp.levlimit then tvs:=0;
 
 
 t.pris:=round(tvs*BUCK_CNT); 
 if t.pris<0 then t.pris:=0;if t.pris>=BUCK_CNT then t.pris:=BUCK_CNT-1;
 t.prim:=round(tvm*BUCK_CNT); 
 if t.prim<0 then t.prim:=0;if t.prim>=BUCK_CNT then t.prim:=BUCK_CNT-1;
 t.prit:=round(tvt*BUCK_CNT); 
 if t.prit<0 then t.prit:=0;if t.prit>=BUCK_CNT then t.prit:=BUCK_CNT-1;
 
 en_q(Q_MERGE,cp,t,t.prim,true); 
 en_q(Q_SPLIT,cp,t,t.pris,true);  
 en_q(Q_TEXTURE,cp,t,t.prit,true);       
 except
  wr_log('ClPri','Error in priority computation, i='+stri(i)+'t.fin='+stri(ord(t.fin)));
  if ocfg.multithreaded then bigerror(1,'ClPri') else bigerror(0,'ClPri');
 end;   
end; 
//############################################################################//
//############################################################################//  
begin
end.
//############################################################################//  

