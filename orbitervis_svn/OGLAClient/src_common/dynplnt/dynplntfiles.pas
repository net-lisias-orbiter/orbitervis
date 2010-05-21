//############################################################################//
// Orulex: Dynamic planet file functions
// Released under GNU General Public License
// Made in 2006-2010 by Artyom Litvinovich
//############################################################################//
unit dynplntfiles;
{$ifdef fpc}{$mode delphi}{$endif}
interface
uses dynplntbase,dynplnttools,asys,sysutils,maths,bmp,log,strval,grph,grplib,dds,math;
//############################################################################//
function interhmap(hmap:phmaptyp;v:vec):double;
function intercmap(cmap:pcmaptyp;v:vec):crgba;     
function intertilex(cp:proampl;v:vec;lv:integer;var res:crgba):boolean;

procedure getcmap(cp:proampl;nn,str:string;th,tl,nh,nl:double;op:integer;us:integer);     
procedure getctile(cp:proampl;ip:quat;nn:string);
procedure getflat(cp:proampl;ip:quat;nn:string);
procedure gethmap(cp:proampl;nn,str:string;th,tl,nh,nl,scl:double;op,flg:integer;us:integer);
procedure geth8map(cp:proampl;nn,str:string;th,tl,nh,nl,scl:double;op,flg:integer;us:integer);
procedure getheihmap(cp:proampl;nn,str:string;th,tl,nh,nl,scl:double;op,flg:integer;us:integer;gl:boolean);     
function  chpltexh(cp:proampl;tdir:string):boolean;  
function  ldpltex(cp:proampl;tdir:string;def:boolean):boolean;   
//############################################################################//
implementation 
//############################################################################//  
function interhmap(hmap:phmaptyp;v:vec):double;
var xh,yh,xl,yl,w:integer;
x,y:double;
a,b,c,d,dx,dy:double;
begin try
 x:=(v.y-hmap.lnh)/hmap.sln;
 y:=hmap.h-(v.x-hmap.lth)/hmap.slt;

 xh:=trunc(x);yh:=trunc(y);
 xl:=trunc(x)+1;yl:=trunc(y)+1;
 w:=hmap.w;
 if xl>=hmap.w then xl:=hmap.w-1;if yl>=hmap.h then yl:=hmap.h-1;
 if xh>=hmap.w then xh:=hmap.w-1;if yh>=hmap.h then yh:=hmap.h-1;  
 dx:=x-xh;dy:=y-yh;

 a:=hmap.dat[xh+yh*w];c:=hmap.dat[xh+yl*w];
 b:=hmap.dat[xl+yh*w];d:=hmap.dat[xl+yl*w];

 result:=round(a*(1-dx)*(1-dy)+b*dx*(1-dy)+c*(1-dx)*dy+d*dx*dy);
          
 except
  wr_log('InterHmap','Heightmap interpolation failure');
  if ocfg.multithreaded then bigerror(1,'InterHmap') else bigerror(0,'InterHmap');
  result:=0;
 end;  
end;  
//############################################################################//  
function intercmap(cmap:pcmaptyp;v:vec):crgba;
var x,y:double;
cvhh,cvhl,cvlh,cvll:crgba;
xh,yh,xl,yl,w:integer;
dx,dy:double;
begin try  
 x:=(v.y-cmap.lnh)/cmap.sln;
 y:=cmap.h-(v.x-cmap.lth)/cmap.slt;
 
 xh:=trunc(x);yh:=trunc(y);
 xl:=trunc(x)+1;yl:=trunc(y)+1;  
 w:=cmap.w;
 if xl>=cmap.w then xl:=cmap.w-1;if yl>=cmap.h then yl:=cmap.h-1;
 if xh>=cmap.w then xh:=cmap.w-1;if yh>=cmap.h then yh:=cmap.h-1;
 dx:=x-xh;dy:=y-yh;
     
 cvhh:=cmap.dat[xh+yh*w];cvhl:=cmap.dat[xh+yl*w];
 cvlh:=cmap.dat[xl+yh*w];cvll:=cmap.dat[xl+yl*w];

 result[0]:=round(cvhh[0]*(1-dx)*(1-dy)+cvlh[0]*dx*(1-dy)+cvhl[0]*(1-dx)*dy+cvll[0]*dx*dy);
 result[1]:=round(cvhh[1]*(1-dx)*(1-dy)+cvlh[1]*dx*(1-dy)+cvhl[1]*(1-dx)*dy+cvll[1]*dx*dy);
 result[2]:=round(cvhh[2]*(1-dx)*(1-dy)+cvlh[2]*dx*(1-dy)+cvhl[2]*(1-dx)*dy+cvll[2]*dx*dy);
 result[3]:=255;
          
 except
  wr_log('InterCMap','Bitmap interpolation failure');
  if ocfg.multithreaded then bigerror(1,'InterCMap') else bigerror(0,'InterCMap');
 end;  
end; 
//############################################################################//  
function intertilex(cp:proampl;v:vec;lv:integer;var res:crgba):boolean;
var clnh,clth,dt,dn,csln,cslt:double;
x,y:double;
xh,yh,xl,yl:integer;
var n,i,c,q:integer;
p:pointer;
rl,fl:boolean;
xi,yi,fc:integer;

cvhh,cvhl,cvlh,cvll:crgba;
dx,dy:double;

const
ltb:array[0..7]of integer=(32,32,30,28,24,18,12,6);
lto:array[0..7]of integer=(150,118,88,60,36,18, 6,0);
ltor:array[0..7]of integer=(0,32,64,94,122,146,164,176);
ltoff=11.25*(pi/180);

begin n:=0;csln:=0;cslt:=0;result:=false;try
 result:=false;  
 n:=floor(v.x/ltoff); 
 if n>=0 then begin   
  clth:=n*ltoff;dt:=ltoff/2;   
  i:=ltb[n];c:=n;n:=i;                  
  n:=floor((v.y*(180/pi))/(360/n));
  clnh:=n*(360/i)*(pi/180);
  dn:=(360/i)*(pi/180)/2;    
  n:=n+lto[c];  
  rl:=false;   
 end else begin  
  clth:=n*ltoff;dt:=ltoff/2;      
  n:=-n-1; 
  i:=ltb[n];c:=n;n:=i;                  
  n:=floor((v.y*(180/pi))/(360/n));
  clnh:=n*(360/i)*(pi/180);
  dn:=(360/i)*(pi/180)/2;    
  n:=364-ltor[c]-n-1;
  rl:=true; 
 end;
       
 fl:=false;
 fc:=6;
 repeat
  q:=0;
  if(v.x< clth+dt)and(v.y< clnh+dn)then q:=2 else
  if(v.x>=clth+dt)and(v.y< clnh+dn)then q:=0 else
  if(v.x< clth+dt)and(v.y>=clnh+dn)then q:=3 else
  if(v.x>=clth+dt)and(v.y>=clnh+dn)then q:=1;
  if rl then q:=3-q; 

  c:=cp.tilexspc[n].sid;
  if cp.tilexspc[n].subidx[q]=0 then if fc=0 then exit else break;
  n:=cp.tilexspc[n].subidx[q];               
        
  if rl then q:=3-q; 
  if q=2 then begin end else
  if q=0 then begin clth:=clth+dt;end else
  if q=3 then begin clnh:=clnh+dn;end else
  if q=1 then begin clth:=clth+dt;clnh:=clnh+dn;end;   
  //if rl then q:=3-q; 
  cslt:=dt/255;
  csln:=dn/255;   
  dt:=dt/2;dn:=dn/2; 
     
  fc:=fc+1;
 until fl; 
 
 if n>=length(cp.tilex)then exit;  
 if n<0 then exit;  
 if c=-1 then exit;
      
 if not cp.tilex[n].ld then begin
  if ocfg.multithreaded then mutex_lock(tthmx);
  if c<30000 then loadltexn(cp.tilexfn,c,p,false) else loadltexoff(cp.tilexfn,c,p,false);
  
  setlength(cp.tilex[n].dat,256*256);
  if not rl then move(p^,cp.tilex[n].dat[0],256*256*4);
  if rl then for yi:=0 to 256-1 do for xi:=0 to 256-1 do cp.tilex[n].dat[xi+256*yi]:=pcrgba(intptr(p)+cardinal(255-xi+256*(255-yi))*4)^; 
  freemem(p);
  cp.tilex[n].ld:=true;
  if ocfg.multithreaded then mutex_release(tthmx);
 end;   
      
 result:=true;
  
 x:=(v.y-clnh)/csln;
 y:=256-(v.x-clth)/cslt;
 
 xh:=trunc(x);yh:=trunc(y);
 xl:=trunc(x)+1;yl:=trunc(y)+1;  
 if xl>=256 then xl:=256-1;if yl>=256 then yl:=256-1;if xh>=256 then xh:=256-1;if yh>=256 then yh:=256-1;
 if xl<0 then xl:=0;if yl<0 then yl:=0;if xh<0 then xh:=0;if yh<0 then yh:=0;
 dx:=x-xh;dy:=y-yh;
     
 cvhh:=cp.tilex[n].dat[xh+yh*256];cvhl:=cp.tilex[n].dat[xh+yl*256];
 cvlh:=cp.tilex[n].dat[xl+yh*256];cvll:=cp.tilex[n].dat[xl+yl*256];

 res[0]:=round(cvhh[0]*(1-dx)*(1-dy)+cvlh[0]*dx*(1-dy)+cvhl[0]*(1-dx)*dy+cvll[0]*dx*dy);
 res[1]:=round(cvhh[1]*(1-dx)*(1-dy)+cvlh[1]*dx*(1-dy)+cvhl[1]*(1-dx)*dy+cvll[1]*dx*dy);
 res[2]:=round(cvhh[2]*(1-dx)*(1-dy)+cvlh[2]*dx*(1-dy)+cvhl[2]*(1-dx)*dy+cvll[2]*dx*dy);    
      
 except
  wr_log('intertilex','Undefined intertilex error, n='+stri(n));
  if ocfg.multithreaded then bigerror(1,'intertilex') else bigerror(0,'intertilex');
 end;     
end; 
//############################################################################//
procedure getcmap(cp:proampl;nn,str:string;th,tl,nh,nl:double;op:integer;us:integer);
var i:integer;
c:integer;
w,h:integer;
p:pointer;
begin try 
 if loadBitmap(cp.texdir+'2'+ch_slash+str+'.bmp',w,h,p)=nil then if loadBitmap(cp.texdir+'2'+ch_slash+str+'.dds',w,h,p)=nil then 
 if loadBitmap(cp.texdir+ch_slash+str+'.bmp',w,h,p)=nil then if loadBitmap(cp.texdir+ch_slash+str+'.dds',w,h,p)=nil then begin                 
  wr_log('getcmap','Notice: File "'+cp.texdir+ch_slash+str+'.bmp'+'" not found or not loadable.');
  exit;
 end;
 c:=-1;
 for i:=0 to length(cp^.cmap)-1 do if not cp^.cmap[i].used then begin c:=i; break; end;
 if c=-1 then begin
  c:=length(cp^.cmap);
  setlength(cp^.cmap,c+1);  
 end;  
 cp^.cmap[c].used:=true;
 cp^.cmap[c].lth:=th*(pi/180);
 cp^.cmap[c].ltl:=tl*(pi/180);
 cp^.cmap[c].lnh:=nh*(pi/180);
 cp^.cmap[c].lnl:=nl*(pi/180);
 cp^.cmap[c].w:=w;
 cp^.cmap[c].h:=h;
 cp^.cmap[c].op:=op;
 cp^.cmap[c].tp:=0; 
 cp^.cmap[c].nam:=nn;
 cp^.cmap[c].pri:=us;
 
 cp^.cmap[c].slt:=(cp^.cmap[c].ltl-cp^.cmap[c].lth)/(h-1);
 cp^.cmap[c].sln:=(cp^.cmap[c].lnl-cp^.cmap[c].lnh)/(w-1);
 
 setlength(cp^.cmap[c].dat,w*h);
 for i:=0 to w*h-2 do cp^.cmap[c].dat[i]:=pcrgba(intptr(p)+cardinal(i)*4)^;    
 freemem(p);           
 except
  wr_log('GetCMap','Bitmap loading error');
  if ocfg.multithreaded then bigerror(1,'GetCMap') else bigerror(0,'GetCMap');
 end; 
end;  
//############################################################################//  
procedure getctile(cp:proampl;ip:quat;nn:string);
var th,tl,nh,nl,r:double;
op:integer;
s:string;

l,x,y:integer;
begin try
 l:=round(ip.x);
 x:=round(ip.y);
 y:=round(ip.z);
 s:=cp^.name+'_'+stri(l)+'_';if x<0 then s:=s+'W' else s:=s+'E';s:=s+trimsl(stri(abs(x)),4,'0')+'_';if y<0 then s:=s+'S' else s:=s+'N';s:=s+trimsl(stri(abs(y)),4,'0');

 //if ip.t=1 then op:=0;
 //if ip.t=3 then 
 op:=1;
 r:=360/(512*pow(2,l));
 th:=r*y;
 tl:=r*y+r;
 nh:=r*x;
 nl:=r*x+r;
 {
 if nh<0 then nh:=360+nh;
 if nl<0 then nl:=360+nl;
 }
 nh:=180+nh;
 nl:=180+nl;
 getcmap(cp,'Tile-'+nn,s,th,tl,nh,nl,op,1);           
 except
  wr_log('GetCTile','Tile loading error');
  if ocfg.multithreaded then bigerror(1,'GetCTile') else bigerror(0,'GetCTile');
 end; 
end;
//############################################################################//
procedure getflat(cp:proampl;ip:quat;nn:string);
var c,i:integer;
begin try   
 c:=-1;
 for i:=0 to length(cp^.flat)-1 do if not cp^.flat[i].used then begin c:=i; break; end;
 if c=-1 then begin
  c:=length(cp^.flat);
  setlength(cp^.flat,c+1);  
 end;  
 cp^.flat[c].used:=true;
 cp^.flat[c].lth:=ip.x*(pi/180);
 cp^.flat[c].ltl:=ip.y*(pi/180);
 cp^.flat[c].lnh:=ip.z*(pi/180);
 cp^.flat[c].lnl:=ip.w*(pi/180); 
 cp^.flat[c].nam:=nn;            
 except
  wr_log('GetFlat','Undefined error');
  if ocfg.multithreaded then bigerror(1,'GetFlat') else bigerror(0,'GetFlat');
 end; 
end;    
//############################################################################//
procedure gethmap(cp:proampl;nn,str:string;th,tl,nh,nl,scl:double;op,flg:integer;us:integer);
var i:integer;
c:integer;
w,h:integer;
p:pointer;
begin try    
 if us=0 then exit;
 if loadBitmap(cp.hmapdir+ch_slash+str+'.bmp',w,h,p)=nil then begin                 
  wr_log('gethmap','Notice: File "'+cp.hmapdir+ch_slash+str+'.bmp'+'" not found or not loadable.');
  exit;
 end;
 c:=-1;
 for i:=0 to length(cp^.hmap)-1 do if not cp^.hmap[i].used then begin c:=i; break; end;
 if c=-1 then begin
  c:=length(cp^.hmap);
  setlength(cp^.hmap,c+1);  
 end;  
 cp^.hmap[c].used:=true;
 cp^.hmap[c].lth:=th*(pi/180);
 cp^.hmap[c].ltl:=tl*(pi/180);
 cp^.hmap[c].lnh:=nh*(pi/180);
 cp^.hmap[c].lnl:=nl*(pi/180);
 cp^.hmap[c].scl:=scl/32768;
 cp^.hmap[c].w:=w;
 cp^.hmap[c].h:=h;
 cp^.hmap[c].op:=op;
 cp^.hmap[c].tp:=0; 
 cp^.hmap[c].flg:=flg; 
 cp^.hmap[c].nam:=nn;
 
 cp^.hmap[c].slt:=(cp^.hmap[c].ltl-cp^.hmap[c].lth)/(h-1);
 cp^.hmap[c].sln:=(cp^.hmap[c].lnl-cp^.hmap[c].lnh)/(w-1);
 
 setlength(cp^.hmap[c].dat,w*h);
 for i:=0 to w*h-2 do cp^.hmap[c].dat[i]:=((pdword(intptr(p)+cardinal(i)*4)^)and $FF)*128;    
 freemem(p);                    
 except
  wr_log('GetHMap','Hmap Loading error');
  if ocfg.multithreaded then bigerror(1,'GetHMap') else bigerror(0,'GetHMap');
 end; 
end;
//############################################################################//
procedure geth8map(cp:proampl;nn,str:string;th,tl,nh,nl,scl:double;op,flg:integer;us:integer);
var i:integer;
c:integer;
w,h:cardinal;
p:pointer;
f:file;

FileHeader:BITMAPFILEHEADER;
InfoHeader:BITMAPINFOHEADER;
Palette:array of RGBQUAD;

blen:integer;
plen:cardinal;


begin try    
 if us=0 then exit;
 if not fileexists(cp.hmapdir+ch_slash+str+'.bmp') then begin                 
  wr_log('geth8map','Notice: File "'+cp.hmapdir+ch_slash+str+'.bmp'+'" not found or not loadable.');
  exit;
 end;
 assignfile(f,cp.hmapdir+ch_slash+str+'.bmp');
 reset(f,1);

 blockRead(f,FileHeader,SizeOf(FileHeader));
 blockRead(f,InfoHeader,SizeOf(InfoHeader));

 plen:=InfoHeader.biClrUsed*4;
 if InfoHeader.biBitCount=8 then if plen=0 then plen:=256*4;
 if InfoHeader.biBitCount=4 then if plen=0 then plen:=16*4;
 if InfoHeader.biBitCount=1 then if plen=0 then plen:=2*4;
 SetLength(Palette,plen div 4);
 blockRead(f,Palette[0],plen);

 w:=InfoHeader.biWidth;
 h:=InfoHeader.biHeight;
 blen:=InfoHeader.biSizeImage;
 if blen=0 then blen:=Fileheader.bfsize-Fileheader.bfoffbits;

 //Get the actual pixel data
 GetMem(p,blen);
 blockRead(f,p^,blen);
 
 c:=-1;
 for i:=0 to length(cp^.hmap)-1 do if not cp^.hmap[i].used then begin c:=i; break; end;
 if c=-1 then begin
  c:=length(cp^.hmap);
  setlength(cp^.hmap,c+1);  
 end;  
 cp^.hmap[c].used:=true;
 cp^.hmap[c].lth:=th*(pi/180);
 cp^.hmap[c].ltl:=tl*(pi/180);
 cp^.hmap[c].lnh:=nh*(pi/180);
 cp^.hmap[c].lnl:=nl*(pi/180);
 cp^.hmap[c].scl:=scl/32768;
 cp^.hmap[c].w:=w;
 cp^.hmap[c].h:=h;
 cp^.hmap[c].op:=op;  
 cp^.hmap[c].tp:=1;    
 cp^.hmap[c].flg:=flg; 
 cp^.hmap[c].nam:=nn;
 
 cp^.hmap[c].slt:=(cp^.hmap[c].ltl-cp^.hmap[c].lth)/(h-1);
 cp^.hmap[c].sln:=(cp^.hmap[c].lnl-cp^.hmap[c].lnh)/(w-1);
 
 setlength(cp^.hmap[c].dat,w*h);
 for i:=0 to w*h-1 do cp^.hmap[c].dat[i]:=(pshortint(intptr(p)+cardinal(i))^)*128;

 freemem(p);
 closefile(f);          
 except
  wr_log('GetH8Map','Undefined error');
  if ocfg.multithreaded then bigerror(1,'GetH8Map') else bigerror(0,'GetH8Map');
 end; 
end; 
//############################################################################//
procedure getheihmap(cp:proampl;nn,str:string;th,tl,nh,nl,scl:double;op,flg:integer;us:integer;gl:boolean);
var i:integer;
c:integer;
w,h:cardinal;
f:file;
a:smallint;
hm:phmaptyp;
begin try      
 if us=0 then exit;
 if not fileexists(cp.hmapdir+ch_slash+str+'.hei') then begin                 
  wr_log('getheihmap','Notice: File "'+cp.hmapdir+ch_slash+str+'.hei'+'" not found or not loadable.');
  exit;
 end;
 assignfile(f,cp.hmapdir+ch_slash+str+'.hei');
 reset(f,1);

 blockread(f,w,4);
 blockread(f,h,4);
 
 if not gl then begin
  c:=-1;
  for i:=0 to length(cp^.hmap)-1 do if not cp^.hmap[i].used then begin c:=i; break; end;
  if c=-1 then begin
   c:=length(cp^.hmap);
   setlength(cp^.hmap,c+1);  
  end;  
  hm:=@cp^.hmap[c];
 end else hm:=@cp^.bhmap;
 
 hm.used:=true;
 hm.lth:=th*(pi/180);
 hm.ltl:=tl*(pi/180);
 hm.lnh:=nh*(pi/180);
 hm.lnl:=nl*(pi/180);
 hm.scl:=scl/32768;
 hm.w:=w;
 hm.h:=h;
 hm.op:=op;     
 hm.tp:=2;     
 hm.flg:=flg;   
 hm.nam:=nn;
 
 hm.slt:=(hm.ltl-hm.lth)/(h-1);
 hm.sln:=(hm.lnl-hm.lnh)/(w-1);
 
 setlength(hm.dat,w*h);
 blockread(f,hm.dat[0],system.filesize(f)-8);

 closefile(f);
 if flg and 1<>0 then for i:=0 to w*h-2 do begin
  a:=hm.dat[i];
  if a<0 then a:=-1;
  hm.dat[i]:=a;
 end;            
 except
  wr_log('GetHeiHMap','Undefined HEI loading error');
  if ocfg.multithreaded then bigerror(1,'GetHeiHMap') else bigerror(0,'GetHeiHMap');
 end; 
end;
//############################################################################//  
function chpltexh(cp:proampl;tdir:string):boolean;   
var c,i:integer;
//s:integer;
n:dword;
f:file;
hdr:array[0..7]of char;
begin try c:=0;
 result:=false;      
 cp.tlnum:=0;
 if fileexists(tdir+'/'+cp.name+'_tile.tex')and fileexists(tdir+'/'+cp.name+'_tile.bin') then begin 
  result:=true;
  assignfile(f,tdir+'/'+cp.name+'_tile.tex');
  reset(f,1);
  //s:=filesize(f);
  closefile(f);
  cp.tlnum:=9;
  cp.tilexfn:=tdir+'/'+cp.name+'_tile.tex';

  //FIXME: ...
  assignfile(f,tdir+'/'+cp.name+'_tile.bin');
  reset(f,1);  
  blockread(f,hdr,8);
  if(hdr[0]='P')and(hdr[1]='L')and(hdr[2]='T')and(hdr[3]='S')then else seek(f,0); 

  
  blockread(f,n,4);  
  setlength(cp.tilex,n);
  setlength(cp.tilexspc,n);
  blockread(f,cp.tilexspc[0],32*n);
  closefile(f);

  for i:=0 to c-1 do begin
   cp.tilex[i].ld:=false;
   cp.tilex[i].lv:=cp.tlnum;
   {
   if(i>=0)and(i<=21)then begin
    cp.tilex[i].lth:=70*(pi/180);
    cp.tilex[i].ltl:=90*(pi/180);
    cp.tilex[i].lnh:=(i*(360/22))*(pi/180);
    cp.tilex[i].lnl:=((i+1)*(360/22))*(pi/180);
   end;                          
   cp.tilex[i].slt:=(cp.tilex[i].ltl-cp.tilex[i].lth)/255;
   cp.tilex[i].sln:=(cp.tilex[i].lnl-cp.tilex[i].lnh)/255;
   }
  end;
 end;

  {
   8:begin    
    setlength(cp.txw,13);setlength(cp.txh,13);setlength(cp.tx,13);setlength(cp.txs,13);
    cp.txw[ 0]:=1536;cp.txh[ 0]:=256 ;cp.txs[ 0]:=0   ;setlength(cp.tx[ 0],cp.txw[ 0]*cp.txh[ 0]); 
    cp.txw[ 1]:=3072;cp.txh[ 1]:=256 ;cp.txs[ 1]:=256 ;setlength(cp.tx[ 1],cp.txw[ 1]*cp.txh[ 1]); 
    cp.txw[ 2]:=4608;cp.txh[ 2]:=256 ;cp.txs[ 2]:=512 ;setlength(cp.tx[ 2],cp.txw[ 2]*cp.txh[ 2]); 
    cp.txw[ 3]:=6144;cp.txh[ 3]:=256 ;cp.txs[ 3]:=768 ;setlength(cp.tx[ 3],cp.txw[ 3]*cp.txh[ 3]); 
    cp.txw[ 4]:=7168;cp.txh[ 4]:=256 ;cp.txs[ 4]:=1024;setlength(cp.tx[ 4],cp.txw[ 4]*cp.txh[ 4]); 
    cp.txw[ 5]:=7680;cp.txh[ 5]:=256 ;cp.txs[ 5]:=1280;setlength(cp.tx[ 5],cp.txw[ 5]*cp.txh[ 5]); 
    cp.txw[ 6]:=8192;cp.txh[ 6]:=1024;cp.txs[ 6]:=1536;setlength(cp.tx[ 6],cp.txw[ 6]*cp.txh[ 6]); 
    cp.txw[ 7]:=7680;cp.txh[ 7]:=256 ;cp.txs[ 7]:=2560;setlength(cp.tx[ 7],cp.txw[ 7]*cp.txh[ 7]); 
    cp.txw[ 8]:=7168;cp.txh[ 8]:=256 ;cp.txs[ 8]:=2816;setlength(cp.tx[ 8],cp.txw[ 8]*cp.txh[ 8]); 
    cp.txw[ 9]:=6144;cp.txh[ 9]:=256 ;cp.txs[ 9]:=3072;setlength(cp.tx[ 9],cp.txw[ 9]*cp.txh[ 9]); 
    cp.txw[10]:=4608;cp.txh[10]:=256 ;cp.txs[10]:=3328;setlength(cp.tx[10],cp.txw[10]*cp.txh[10]); 
    cp.txw[11]:=3072;cp.txh[11]:=256 ;cp.txs[11]:=3584;setlength(cp.tx[11],cp.txw[11]*cp.txh[11]); 
    cp.txw[12]:=1536;cp.txh[12]:=256 ;cp.txs[12]:=3840;setlength(cp.tx[12],cp.txw[12]*cp.txh[12]); 
    cp.txhf:=4096;   

    for i:=0 to 255 do for j:=0 to  6-1 do move (pointer(intptr(pp[137+j])+intptr(i*256*4))^,cp.tx[ 0][j*256+i*1536],256*4);
    for i:=0 to 255 do for j:=0 to 12-1 do move (pointer(intptr(pp[143+j])+intptr(i*256*4))^,cp.tx[ 1][j*256+i*3072],256*4);
    for i:=0 to 255 do for j:=0 to 18-1 do move (pointer(intptr(pp[155+j])+intptr(i*256*4))^,cp.tx[ 2][j*256+i*4608],256*4);
    for i:=0 to 255 do for j:=0 to 24-1 do move (pointer(intptr(pp[173+j])+intptr(i*256*4))^,cp.tx[ 3][j*256+i*6144],256*4);
    for i:=0 to 255 do for j:=0 to 28-1 do move (pointer(intptr(pp[197+j])+intptr(i*256*4))^,cp.tx[ 4][j*256+i*7168],256*4);
    for i:=0 to 255 do for j:=0 to 30-1 do move (pointer(intptr(pp[225+j])+intptr(i*256*4))^,cp.tx[ 5][j*256+i*7680],256*4);  
    for i:=0 to 255 do for j:=0 to 32-1 do move (pointer(intptr(pp[255+j])+intptr(i*256*4))^,cp.tx[ 6][j*256+(i+000)*8192],256*4);   
    for i:=0 to 255 do for j:=0 to 32-1 do move (pointer(intptr(pp[287+j])+intptr(i*256*4))^,cp.tx[ 6][j*256+(i+256)*8192],256*4);  
    for i:=0 to 255 do for j:=0 to 32-1 do mvrev(pointer(intptr(pp[500-j])+intptr(i*256*4)),@cp.tx[ 6][j*256+(255-i+512)*8192]);
    for i:=0 to 255 do for j:=0 to 32-1 do mvrev(pointer(intptr(pp[468-j])+intptr(i*256*4)),@cp.tx[ 6][j*256+(255-i+768)*8192]);    
    for i:=0 to 255 do for j:=0 to 30-1 do mvrev(pointer(intptr(pp[436-j])+intptr(i*256*4)),@cp.tx[ 7][j*256+(255-i)*7680]); 
    for i:=0 to 255 do for j:=0 to 28-1 do mvrev(pointer(intptr(pp[406-j])+intptr(i*256*4)),@cp.tx[ 8][j*256+(255-i)*7168]);  
    for i:=0 to 255 do for j:=0 to 24-1 do mvrev(pointer(intptr(pp[378-j])+intptr(i*256*4)),@cp.tx[ 9][j*256+(255-i)*6144]); 
    for i:=0 to 255 do for j:=0 to 18-1 do mvrev(pointer(intptr(pp[354-j])+intptr(i*256*4)),@cp.tx[10][j*256+(255-i)*4608]); 
    for i:=0 to 255 do for j:=0 to 12-1 do mvrev(pointer(intptr(pp[336-j])+intptr(i*256*4)),@cp.tx[11][j*256+(255-i)*3072]); 
    for i:=0 to 255 do for j:=0 to  6-1 do mvrev(pointer(intptr(pp[324-j])+intptr(i*256*4)),@cp.tx[12][j*256+(255-i)*1536]);  
   end;   
  end;
  for i:=0 to length(pp)-1 do freemem(pp[i]);
 end; 
 }    
  
 except on E:exception do begin
  {
  if nn=0 then wr_log('LdPlTex','Undefined TEX loading error ('+e.message+')');
  if nn=4 then wr_log('LdPlTex','Error loading global texture ('+e.message+')');
  bigerror(nn,'LdPlTex'); 
  }      
  result:=false;
 end;end;
end;
//############################################################################//  
function ldpltex(cp:proampl;tdir:string;def:boolean):boolean;   
var i,j,lv,nn:integer;
w,h,c,l:aointeger;
pp:apointer;
r:boolean;
begin nn:=0;try
 lv:=0;
 nn:=4;
 result:=false;  
 r:=loadtex(tdir+'/'+cp.name+'.tex',w,h,cp.txc,pp,c,l,false);
 if def then r:=loadtex(tdir+'/plntdefault_'+stri(cp.deftxn)+'.tex',w,h,cp.txc,pp,c,l,false);
 
 if not r then begin
  cp.txc:=0
 end else begin  
  nn:=0;
  result:=true;
  case cp.txc of
   1:lv:=1;
   2:lv:=2;
   3:lv:=3;
   5:lv:=4;
   13:lv:=5;
   37:lv:=6;
   137:lv:=7;
   501:lv:=8;
  end;   
  setlength(cp.txw,1);setlength(cp.txh,1);setlength(cp.tx,1);setlength(cp.txs,1);
  case lv of
   1:begin
    cp.txw[0]:=w[0];cp.txh[0]:=h[0];
    setlength(cp.tx[0],cp.txw[0]*cp.txh[0]);  
    cp.txhf:=h[0];
    move(pp[0]^,cp.tx[0][0],cp.txw[0]*cp.txh[0]*4);
   end;
   2:begin
    cp.txw[0]:=w[1];cp.txh[0]:=h[1];
    setlength(cp.tx[0],cp.txw[0]*cp.txh[0]);  
    cp.txhf:=h[1];
    move(pp[1]^,cp.tx[0][0],cp.txw[0]*cp.txh[0]*4);
   end;
   3:begin
    cp.txw[0]:=w[2];cp.txh[0]:=h[2];
    setlength(cp.tx[0],cp.txw[0]*cp.txh[0]);       
    cp.txhf:=h[2];
    move(pp[2]^,cp.tx[0][0],cp.txw[0]*cp.txh[0]*4);
   end;
   4:begin
    cp.txw[0]:=512;cp.txh[0]:=256;
    setlength(cp.tx[0],cp.txw[0]*cp.txh[0]);   
    cp.txhf:=256;
    for i:=0 to 255 do begin
     move(pointer(intptr(pp[3])+intptr(i*256*4))^,cp.tx[0][0+i*512],256*4);
     move(pointer(intptr(pp[4])+intptr(i*256*4))^,cp.tx[0][256+i*512],256*4);
    end;
   end;
   5:begin
    cp.txw[0]:=1024;cp.txh[0]:=512;
    setlength(cp.tx[0],cp.txw[0]*cp.txh[0]);  
    cp.txhf:=512;
    for i:=0 to 255 do begin
     move(pointer(intptr(pp[5])+intptr(i*256*4))^,cp.tx[0][000+i*1024],256*4);
     move(pointer(intptr(pp[6])+intptr(i*256*4))^,cp.tx[0][256+i*1024],256*4);
     move(pointer(intptr(pp[7])+intptr(i*256*4))^,cp.tx[0][512+i*1024],256*4);
     move(pointer(intptr(pp[8])+intptr(i*256*4))^,cp.tx[0][768+i*1024],256*4);
    end;
    for i:=0 to 255 do begin
     mvrev(pointer(intptr(pp[12])+intptr(i*256*4)),@cp.tx[0][000+(255-i+256)*1024]);
     mvrev(pointer(intptr(pp[11])+intptr(i*256*4)),@cp.tx[0][256+(255-i+256)*1024]);
     mvrev(pointer(intptr(pp[10])+intptr(i*256*4)),@cp.tx[0][512+(255-i+256)*1024]);
     mvrev(pointer(intptr(pp[09])+intptr(i*256*4)),@cp.tx[0][768+(255-i+256)*1024]);
    end;
   end;
   6:begin
    cp.txw[0]:=2048;cp.txh[0]:=1024;
    setlength(cp.tx[0],cp.txw[0]*cp.txh[0]); 
    cp.txhf:=1024;
    for i:=0 to 255 do for j:=0 to 4-1 do mvfor   (pointer(intptr(pp[13+j])+intptr(i*256*4)) ,@cp.tx[0][j*256*2+i*2048],2);
    for i:=0 to 255 do for j:=0 to 8-1 do move    (pointer(intptr(pp[17+j])+intptr(i*256*4))^,cp.tx[0][j*256+(i+256)*2048],256*4);
    for i:=0 to 255 do for j:=0 to 8-1 do mvrev   (pointer(intptr(pp[36-j])+intptr(i*256*4)) ,@cp.tx[0][j*256+(255-i+512)*2048]); 
    for i:=0 to 255 do for j:=0 to 4-1 do mvforrev(pointer(intptr(pp[28-j])+intptr(i*256*4)) ,@cp.tx[0][j*256*2+(255-i+768)*2048],2); 
   end;   
   7:begin
    setlength(cp.txw,5);setlength(cp.txh,5);setlength(cp.tx,5);setlength(cp.txs,5);
    cp.txw[0]:=1536;cp.txh[0]:=256 ;cp.txs[0]:=0   ;setlength(cp.tx[0],cp.txw[0]*cp.txh[0]); 
    cp.txw[1]:=3072;cp.txh[1]:=256 ;cp.txs[1]:=256 ;setlength(cp.tx[1],cp.txw[1]*cp.txh[1]); 
    cp.txw[2]:=4096;cp.txh[2]:=1024;cp.txs[2]:=512 ;setlength(cp.tx[2],cp.txw[2]*cp.txh[2]); 
    cp.txw[3]:=3072;cp.txh[3]:=256 ;cp.txs[3]:=1536;setlength(cp.tx[3],cp.txw[3]*cp.txh[3]); 
    cp.txw[4]:=1536;cp.txh[4]:=256 ;cp.txs[4]:=1792;setlength(cp.tx[4],cp.txw[4]*cp.txh[4]); 
    cp.txhf:=2048;       
    
    for i:=0 to 255 do for j:=0 to  6-1 do move (pointer(intptr(pp[ 37+j])+intptr(i*256*4))^,cp.tx[0][j*256+i*1536],256*4);
    for i:=0 to 255 do for j:=0 to 12-1 do move (pointer(intptr(pp[ 43+j])+intptr(i*256*4))^,cp.tx[1][j*256+i*3072],256*4);
    for i:=0 to 255 do for j:=0 to 16-1 do move (pointer(intptr(pp[ 55+j])+intptr(i*256*4))^,cp.tx[2][j*256+(i+000)*4096],256*4);   
    for i:=0 to 255 do for j:=0 to 16-1 do move (pointer(intptr(pp[ 71+j])+intptr(i*256*4))^,cp.tx[2][j*256+(i+256)*4096],256*4);  
    for i:=0 to 255 do for j:=0 to 16-1 do mvrev(pointer(intptr(pp[136-j])+intptr(i*256*4)),@cp.tx[2][j*256+(255-i+512)*4096]);
    for i:=0 to 255 do for j:=0 to 16-1 do mvrev(pointer(intptr(pp[120-j])+intptr(i*256*4)),@cp.tx[2][j*256+(255-i+768)*4096]);
    for i:=0 to 255 do for j:=0 to 12-1 do mvrev(pointer(intptr(pp[104-j])+intptr(i*256*4)),@cp.tx[3][j*256+(255-i)*3072]);
    for i:=0 to 255 do for j:=0 to  6-1 do mvrev(pointer(intptr(pp[ 92-j])+intptr(i*256*4)),@cp.tx[4][j*256+(255-i)*1536]);
   end;  
   8:begin    
    setlength(cp.txw,13);setlength(cp.txh,13);setlength(cp.tx,13);setlength(cp.txs,13);
    cp.txw[ 0]:=1536;cp.txh[ 0]:=256 ;cp.txs[ 0]:=0   ;setlength(cp.tx[ 0],cp.txw[ 0]*cp.txh[ 0]); 
    cp.txw[ 1]:=3072;cp.txh[ 1]:=256 ;cp.txs[ 1]:=256 ;setlength(cp.tx[ 1],cp.txw[ 1]*cp.txh[ 1]); 
    cp.txw[ 2]:=4608;cp.txh[ 2]:=256 ;cp.txs[ 2]:=512 ;setlength(cp.tx[ 2],cp.txw[ 2]*cp.txh[ 2]); 
    cp.txw[ 3]:=6144;cp.txh[ 3]:=256 ;cp.txs[ 3]:=768 ;setlength(cp.tx[ 3],cp.txw[ 3]*cp.txh[ 3]); 
    cp.txw[ 4]:=7168;cp.txh[ 4]:=256 ;cp.txs[ 4]:=1024;setlength(cp.tx[ 4],cp.txw[ 4]*cp.txh[ 4]); 
    cp.txw[ 5]:=7680;cp.txh[ 5]:=256 ;cp.txs[ 5]:=1280;setlength(cp.tx[ 5],cp.txw[ 5]*cp.txh[ 5]); 
    cp.txw[ 6]:=8192;cp.txh[ 6]:=1024;cp.txs[ 6]:=1536;setlength(cp.tx[ 6],cp.txw[ 6]*cp.txh[ 6]); 
    cp.txw[ 7]:=7680;cp.txh[ 7]:=256 ;cp.txs[ 7]:=2560;setlength(cp.tx[ 7],cp.txw[ 7]*cp.txh[ 7]); 
    cp.txw[ 8]:=7168;cp.txh[ 8]:=256 ;cp.txs[ 8]:=2816;setlength(cp.tx[ 8],cp.txw[ 8]*cp.txh[ 8]); 
    cp.txw[ 9]:=6144;cp.txh[ 9]:=256 ;cp.txs[ 9]:=3072;setlength(cp.tx[ 9],cp.txw[ 9]*cp.txh[ 9]); 
    cp.txw[10]:=4608;cp.txh[10]:=256 ;cp.txs[10]:=3328;setlength(cp.tx[10],cp.txw[10]*cp.txh[10]); 
    cp.txw[11]:=3072;cp.txh[11]:=256 ;cp.txs[11]:=3584;setlength(cp.tx[11],cp.txw[11]*cp.txh[11]); 
    cp.txw[12]:=1536;cp.txh[12]:=256 ;cp.txs[12]:=3840;setlength(cp.tx[12],cp.txw[12]*cp.txh[12]); 
    cp.txhf:=4096;   

    for i:=0 to 255 do for j:=0 to  6-1 do move (pointer(intptr(pp[137+j])+intptr(i*256*4))^,cp.tx[ 0][j*256+i*1536],256*4);
    for i:=0 to 255 do for j:=0 to 12-1 do move (pointer(intptr(pp[143+j])+intptr(i*256*4))^,cp.tx[ 1][j*256+i*3072],256*4);
    for i:=0 to 255 do for j:=0 to 18-1 do move (pointer(intptr(pp[155+j])+intptr(i*256*4))^,cp.tx[ 2][j*256+i*4608],256*4);
    for i:=0 to 255 do for j:=0 to 24-1 do move (pointer(intptr(pp[173+j])+intptr(i*256*4))^,cp.tx[ 3][j*256+i*6144],256*4);
    for i:=0 to 255 do for j:=0 to 28-1 do move (pointer(intptr(pp[197+j])+intptr(i*256*4))^,cp.tx[ 4][j*256+i*7168],256*4);
    for i:=0 to 255 do for j:=0 to 30-1 do move (pointer(intptr(pp[225+j])+intptr(i*256*4))^,cp.tx[ 5][j*256+i*7680],256*4);  
    for i:=0 to 255 do for j:=0 to 32-1 do move (pointer(intptr(pp[255+j])+intptr(i*256*4))^,cp.tx[ 6][j*256+(i+000)*8192],256*4);   
    for i:=0 to 255 do for j:=0 to 32-1 do move (pointer(intptr(pp[287+j])+intptr(i*256*4))^,cp.tx[ 6][j*256+(i+256)*8192],256*4);  
    for i:=0 to 255 do for j:=0 to 32-1 do mvrev(pointer(intptr(pp[500-j])+intptr(i*256*4)),@cp.tx[ 6][j*256+(255-i+512)*8192]);
    for i:=0 to 255 do for j:=0 to 32-1 do mvrev(pointer(intptr(pp[468-j])+intptr(i*256*4)),@cp.tx[ 6][j*256+(255-i+768)*8192]);    
    for i:=0 to 255 do for j:=0 to 30-1 do mvrev(pointer(intptr(pp[436-j])+intptr(i*256*4)),@cp.tx[ 7][j*256+(255-i)*7680]); 
    for i:=0 to 255 do for j:=0 to 28-1 do mvrev(pointer(intptr(pp[406-j])+intptr(i*256*4)),@cp.tx[ 8][j*256+(255-i)*7168]);  
    for i:=0 to 255 do for j:=0 to 24-1 do mvrev(pointer(intptr(pp[378-j])+intptr(i*256*4)),@cp.tx[ 9][j*256+(255-i)*6144]); 
    for i:=0 to 255 do for j:=0 to 18-1 do mvrev(pointer(intptr(pp[354-j])+intptr(i*256*4)),@cp.tx[10][j*256+(255-i)*4608]); 
    for i:=0 to 255 do for j:=0 to 12-1 do mvrev(pointer(intptr(pp[336-j])+intptr(i*256*4)),@cp.tx[11][j*256+(255-i)*3072]); 
    for i:=0 to 255 do for j:=0 to  6-1 do mvrev(pointer(intptr(pp[324-j])+intptr(i*256*4)),@cp.tx[12][j*256+(255-i)*1536]);  
   end;   
  end;
  for i:=0 to length(pp)-1 do freemem(pp[i]);
 end;      
 except on E:exception do begin
  if nn=0 then wr_log('LdPlTex','Undefined TEX loading error ('+e.message+')');
  if nn=4 then wr_log('LdPlTex','Error loading global texture ('+e.message+')');
  bigerror(nn,'LdPlTex');       
  result:=false;
 end;end;
end;
//############################################################################//
begin
end.
//############################################################################//  

