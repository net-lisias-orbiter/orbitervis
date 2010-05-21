//############################################################################// 
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: Procedural graphics
//############################################################################//
unit procgenlib;
interface
uses asys,math,grph,grplib,maths,noise,noir;
//############################################################################//
type 
texcall=function(p:pointer;x,y,par:integer):pointer;  
txmodcall=function(px1,px2:pointer;xs,ys:integer;par1,par2,par3:double):pointer;
mod_desc=record
 prc:txmodcall;
 pc:integer;
 min1,def1,max1:double;
 min2,def2,max2:double;
 min3,def3,max3:double; 
 nam:string;
end;
tex_desc=record
 prc:texcall;
 pmin,pdef,pmax:integer;         
 nam:string;
end;
pgtexop=record
 typ:integer;
 bufa,bufb,xs,ys,para,parb:integer; 
 par1,par2,par3:double;
end;
//############################################################################// 
function tex2sdi(prc:texcall;x,y,par:integer):ptypspr;  

function mandelbrot(p:pointer;wid,hei:integer;xh,yh,xl,yl,nl:double):pointer;
                     
function txmod_shadows(px1,px2:pointer;xs,ys:integer;par1,par2,par3:double):pointer;  
function txmod_blend  (px1,px2:pointer;xs,ys:integer;par1,par2,par3:double):pointer;

function mktx_asph      (p:pointer;x,y,par:integer):pointer;
function mktx_lpad      (p:pointer;x,y,par:integer):pointer;
function mktx_tile      (p:pointer;x,y,par:integer):pointer;   
function mktx_cirgrid   (p:pointer;x,y,par:integer):pointer;
function mktx_atm       (p:pointer;x,y,par:integer):pointer;
function mktx_goldblue  (p:pointer;xs,ys,par:integer):pointer;
function mktx_concrete  (p:pointer;x,y,par:integer):pointer;
function mktx_rust_steel(p:pointer;x,y,par:integer):pointer;
function mktx_steel     (p:pointer;x,y,par:integer):pointer;
 
function mktx_marble       (px:pointer;xs,ys,par:integer):pointer;
function mktx_shadowter    (px:pointer;xs,ys,par:integer):pointer;   
function mktx_isoridges    (p:pointer;x,y,par:integer):pointer;
function mktx_arrow        (px:pointer;x,y,par:integer):pointer;
function mktx_solarpan_sqr (px:pointer;xs,ys,par:integer):pointer;
function mktx_truss        (px:pointer;xs,ys,par:integer):pointer;
function mktx_termblank    (px:pointer;xs,ys,par:integer):pointer;
function mktx_tank         (px:pointer;xs,ys,par:integer):pointer;
function mktx_wood         (p:pointer;xs,ys,par:integer):pointer;     
function mktx_earth(p:pointer;xs,ys,par:integer):pointer;         
function mktx_stars(p:pointer;xs,ys,par:integer):pointer;
function mktx_wallpaper(p:pointer;xs,ys,par:integer):pointer;
function mktx_metal        (p:pointer;xs,ys,par:integer):pointer;
function mktx_newrust_steel(p:pointer;x,y,par:integer):pointer;
function mktx_etc          (px:pointer;xs,ys,par:integer):pointer;

procedure mk_pln(g:ptypmshgrp;xs,ys:double);
procedure mk_crx(g:ptypmshgrp;siz:double;xpos:double=0;ypos:double=0;zpos:double=0);
procedure mk_cube(g:ptypmshgrp;xsiz,ysiz,zsiz:double;xpos:double=0;ypos:double=0;zpos:double=0);    
procedure mk_roundpln(g:ptypmshgrp;c:integer;r:double;ds:boolean;xpos:double=0;ypos:double=0;zpos:double=0);
procedure mk_tor(g:ptypmshgrp;r,thk:double;n1,n2:integer;z_spale:boolean);
procedure mk_sphere(g:ptypmshgrp;nrings:dword;hemisphere:boolean;which_half,texres:integer;scale:double=1);
procedure mk_spherepatch(g:ptypmshgrp;nlng,nlat,ilat,res,bseg:integer;reduce,outside,store_vtx:boolean);                  
procedure mk_ringmsh(g:ptypmshgrp;irad,orad:double;nsect:integer);
//############################################################################//
const txmod_s:array[0..1]of mod_desc=(
 (prc:txmod_shadows;pc:1;min1:0;def1:45 ;max1:90;min2:0;def2:0.5;max2:1;min3:10;def3:25;max3:100),
 (prc:txmod_blend  ;pc:2;min1:0;def1:0.5;max1:1 ;min2:0;def2:0;  max2:0;min3:0; def3:0; max3:0)
);       
//############################################################################//
const tex_s:array[0..21]of tex_desc=(
 (prc:mktx_asph         ;pmin:0;pdef:0;pmax:0;nam:'asphalt'),
 (prc:mktx_lpad         ;pmin:0;pdef:0;pmax:0;nam:'landing pad'),    
 (prc:mktx_tile         ;pmin:0;pdef:0;pmax:0;nam:'tile'),
 (prc:mktx_cirgrid      ;pmin:0;pdef:0;pmax:0;nam:'circular grid'),
 (prc:mktx_atm          ;pmin:0;pdef:0;pmax:0;nam:'old airhaze'),
 (prc:mktx_goldblue     ;pmin:0;pdef:0;pmax:0;nam:'gold and blue'),
 (prc:mktx_concrete     ;pmin:0;pdef:0;pmax:0;nam:'concrete'),
 (prc:mktx_rust_steel   ;pmin:0;pdef:0;pmax:0;nam:'rusted steel'),
 (prc:mktx_steel        ;pmin:0;pdef:0;pmax:0;nam:'steel'),
 (prc:mktx_marble       ;pmin:0;pdef:0;pmax:1;nam:'marble'),
 (prc:mktx_shadowter    ;pmin:0;pdef:0;pmax:2;nam:'shadowed terrain'),
 (prc:mktx_isoridges    ;pmin:0;pdef:1;pmax:3;nam:'isoridges'),
 (prc:mktx_arrow        ;pmin:0;pdef:0;pmax:0;nam:'arrow'),
 (prc:mktx_solarpan_sqr ;pmin:0;pdef:0;pmax:3;nam:'sqr solar panels'),
 (prc:mktx_truss        ;pmin:0;pdef:0;pmax:0;nam:'truss metal'),
 (prc:mktx_termblank    ;pmin:0;pdef:0;pmax:2;nam:'termal blanket'),
 (prc:mktx_tank         ;pmin:0;pdef:0;pmax:1;nam:'tank metal'),
 (prc:mktx_wood         ;pmin:0;pdef:0;pmax:5;nam:'wood'),
 (prc:mktx_wallpaper    ;pmin:0;pdef:0;pmax:1;nam:'wallpaper'),
 (prc:mktx_metal        ;pmin:0;pdef:0;pmax:5;nam:'zinc metal'),
 (prc:mktx_newrust_steel;pmin:0;pdef:0;pmax:0;nam:'new rusted steel'),
 (prc:mktx_etc          ;pmin:0;pdef:0;pmax:5;nam:'etc')
);        
//############################################################################//
implementation  
//############################################################################//
function  rndn(c:double):double;begin result:=(lrandom-0.5)*2*c;end;       
//############################################################################//      
var xnoi:pnoirec;  
//############################################################################//
function tex2sdi(prc:texcall;x,y,par:integer):ptypspr;
var p:pointer;
begin 
 getmem(p,x*y*256);
 prc(p,x,y,par);
 new(result);
 result.srf:=p;  
 result.tp:=1;
 result.xs:=x;
 result.ys:=y;   
 result.cx:=x div 2;
 result.cy:=y div 2;
 result.ldd:=true;
 result.ltyp:=0;   
 result.lfn:='';  
 result.lsc:=0;
 {$ifdef BGR}
 //tx_swap_bgr(p,x,y);
 {$endif}
end;
//############################################################################//
function mandelbrot(p:pointer;wid,hei:integer;xh,yh,xl,yl,nl:double):pointer;
var norm,borne:double;
c,z,z1:vec2;
x,y,k,iter:integer;
xmin,xmax,ymin,ymax:double;
cp:pcrgba;
begin
 iter:=64;
 xmin:=xh; ymin:=yh;
 xmax:=xl; ymax:=yl;
 borne:=2;

 for x:=0 to wid-1 do for y:=0 to hei-1 do begin
  z.x:=0;z.y:=0;
  c.y:=ymin+y*((ymax-ymin)/hei);
  c.x:=xmin+x*((xmax-xmin)/wid);
  if nl<>0 then begin c.y:=c.y+random*nl;c.x:=c.x+random*nl;end;
  
  for k:=0 to iter-1 do begin
   z1.x:=z.x*z.x-z.y*z.y+c.x;
   z1.y:=z.x*z.y+z.y*z.x+c.y;
   z.x:=z1.x;z.y:=z1.y;
   norm:=sqrt(z.x*z.x+z.y*z.y);

   cp:=pointer(intptr(p)+intptr(wid*hei*4-(x*hei+y)*4-4));
   if norm>borne then begin
    cp[2]:=round(255*(k/iter*2.5));
    if (k/iter*2.5)>1 then cp[2]:=255;
    cp[1]:=round(255*(k/iter));
    cp[0]:=0; cp[3]:=255;
    break;
   end else if k=iter-1 then begin cp[0]:=255;cp[1]:=255;cp[2]:=255;cp[3]:=255;end;
  end;
 end;
 result:=p;
end;
//############################################################################//  
//############################################################################//  
function txmod_shadows(px1,px2:pointer;xs,ys:integer;par1,par2,par3:double):pointer;
var tx_shd:integer;
p:pbcrgba;
x,y,j:integer;
dh,dl,a:single;  
begin 
 result:=nil;    
 if px1=nil then exit;
 result:=px1; 
 p:=px1;
 
 tx_shd:=max2i(10,xs div 10);
 a:=arctan(par1/180*pi);
 
 for y:=0 to ys-1 do for x:=0 to xs-1 do for j:=0 to tx_shd-1 do begin
  if(x<=j)or(y<=j)then break;
  dh:=p[(x-j-1)+xs*(y-j-1)][3]-p[x+xs*y][3];
  dl:=par3*(j+1);
  if dh/dl>=a then begin
   p[x+xs*y][0]:=round(p[x+xs*y][0]*par2);
   p[x+xs*y][1]:=round(p[x+xs*y][1]*par2);
   p[x+xs*y][2]:=round(p[x+xs*y][2]*par2);
   break;
  end;
 end;
end;
//############################################################################//  
function txmod_blend(px1,px2:pointer;xs,ys:integer;par1,par2,par3:double):pointer;
var p1,p2:pbcrgba;
c1,c2:pcrgba;
x,y:integer;
e:single;  
begin     
 result:=nil;  
 if px1=nil then exit;if px2=nil then exit; 
 result:=px1; 
 p1:=px1;p2:=px2;
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  c1:=@p1[x+xs*y];c2:=@p2[x+xs*y];
  e:=(c2[0]/255)*par1+(c1[0]/255)*(1-par1);if e>1 then e:=1;c1[0]:=round(e*255);
  e:=(c2[1]/255)*par1+(c1[1]/255)*(1-par1);if e>1 then e:=1;c1[1]:=round(e*255);
  e:=(c2[2]/255)*par1+(c1[2]/255)*(1-par1);if e>1 then e:=1;c1[2]:=round(e*255);
 end;
end;
//############################################################################//
//############################################################################//
function mktx_asph(p:pointer;x,y,par:integer):pointer;
var xx,yy:integer;
a:integer;
begin
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin a:=round((0.2+rndn(0.2))*255);pbcrgba(p)[xx+yy*x]:=tcrgba(a,a,a,255);end;
 result:=p;
end;
//############################################################################//
function mktx_lpad(p:pointer;x,y,par:integer):pointer;
var xx,yy,a:integer;
c:crgba;
r,xd,yd,ax,ay:double;
begin
 xd:=x/2; yd:=y/2;
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
  ax:=abs(xx-xd);ay:=abs(yy-yd);
  c[1]:=0;c[2]:=0;
  r:=sqr(ax)+sqr(ay);
  if  r >sqr(xd) then begin c[0]:=0;c[3]:=0;end else
  if (r >sqr(xd-40))and(r<sqr(xd))and(ax>10)and(ay>10) then begin c[0]:=round((0.9+rndn(0.1))*255);c[3]:=255;end else
  if (r >sqr(xd-40))and(r<sqr(xd))and(not((ax>10)and(ay>10))) then begin c[0]:=0;c[3]:=0;end else
  if  r<=sqr(xd-40) then begin a:=round((0.8+rndn(0.2))*255);c[0]:=a;c[1]:=a;c[2]:=a;c[3]:=255;end else
  if (xx=xd)and(ay<10) then begin c[0]:=round((0.9+rndn(0.1))*255);c[3]:=255;end else
  if (yy=yd)and(ax<10) then begin c[0]:=round((0.9+rndn(0.1))*255);c[3]:=255;end;   
  pbcrgba(p)[xx+yy*x]:=tcrgba(c[0],c[1],c[2],c[3]);
 end;
 result:=p;
end;
//############################################################################//
function mktx_tile(p:pointer;x,y,par:integer):pointer;
var xx,yy:integer;
c:crgba;
a:integer;
begin
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
       if ((xx<10 )or (xx>x-10))or ((yy<10 )or (yy>y-10)) then begin c[0]:=round(0.8)*255;c[1]:=0;c[2]:=round(0.4*255);c[3]:=255;end 
  else if ((xx>12 )and(xx<x/2 ))and((yy>12 )and(yy<y/2 )) then begin c[0]:=round(0.8*255*(pnoiNoise(@defnoi,xx/32,yy/32,2/124)/2-0.5));c[1]:=round(0.2*255);c[2]:=0;c[3]:=255;end 
  else if ((xx>x/2)and(xx<x-12))and((yy>y/2)and(yy<y-12)) then begin c[0]:=round(0.8*255*(pnoiNoise(@defnoi,xx/32,yy/32,2/124)/3-0.5));c[1]:=round(0.2*255);c[2]:=0;c[3]:=255;end 
  else begin a:=round((0.8+rndn(0.2))*255*(pnoiNoise(@defnoi,xx/32,yy/32,2/124)/3-0.5));c[0]:=a;c[1]:=a;c[2]:=a;c[3]:=255;end;  
  pbcrgba(p)[xx+yy*x]:=tcrgba(c[0],c[1],c[2],c[3]);
 end;
 result:=p;
end;
//############################################################################//
function mktx_cirgrid(p:pointer;x,y,par:integer):pointer;
var f,f2,xx,yy:integer;
c:crgba;
a:integer;
begin
 f:=128 div 4;
 f2:=f div 2;
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
       if((yy<10 )or (yy>y-10))or((yy>y div 2-10)and(yy<y div 2+10))then begin c[0]:=round(0.8)*255;c[1]:=0;c[2]:=round(0.4*255);c[3]:=255;end 
  else if(xx-(xx div f)*f>x div f2)then begin c[0]:=round(0.8*255*(pnoiNoise(@defnoi,xx/32,yy/32,2/124)/2-0.5));c[1]:=round(0.2*255);c[2]:=0;c[3]:=255;end 
  else begin a:=round((0.8+rndn(0.2))*255*(pnoiNoise(@defnoi,xx/32,yy/32,2/124)/3-0.5));c[0]:=a;c[1]:=a;c[2]:=a;c[3]:=255;end;
  pbcrgba(p)[xx+yy*x]:=tcrgba(c[0],c[1],c[2],c[3]);
 end;
 result:=p;
end;
//############################################################################//
function mktx_atm(p:pointer;x,y,par:integer):pointer;
var xx,yy:integer;
c:crgba;
r:double;
begin
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
  r:=sqrt(sqr(xx-x/2)+sqr(yy-y/2));
  if r>=x/2 then begin c[0]:=0;c[1]:=0;c[2]:=0;c[3]:=0;end;
  if (r>(x/2-40))and(r<x/2) then begin c[0]:=round(0.2*255);c[1]:=round(0.6*255);c[2]:=255;c[3]:=round((1-(r-(x/2-40))/40)*255);end;
  if r<=(x/2-40) then begin c[0]:=round(0.2*255);c[1]:=round(0.6*255);c[2]:=255;c[3]:=round((r/(x/2-40))*255);end;
  pbcrgba(p)[xx+yy*x]:=tcrgba(c[0],c[1],c[2],c[3]);
 end;
 result:=p;
end;
//############################################################################//
function mktx_goldblue(p:pointer;xs,ys,par:integer):pointer;
var x,y,bg,tx_var:integer;
k,kx:single;
bc:crgba;
begin     
 result:=p; 
 xnoi.seed:=round(lrandom*34576);xnoi.ni:=false;   
 bg:=round(log2(xs)/2);
           
 tx_var:=60;  
 for y:=0 to xs-1 do for x:=0 to xs-1 do begin 
  k:=perlintf(xnoi,tvec(x,y,100),32,bg,evec); 
  kx:=perlintf(xnoi,tvec(x,100,y),32,bg,evec);     
  bc:=tcrgba(128+round((2-kx)*128),128+round(kx*128),128+round(kx*128),255);
  
  pbcrgba(p)[x+xs*y]:=tcrgba(bc[0]+round(k*tx_var),bc[1]+round(k*tx_var),bc[2]+round(k*tx_var),255);
 end; 
end;
//############################################################################//
function mktx_concrete(p:pointer;x,y,par:integer):pointer;
var xx,yy:integer;
a:integer;
begin
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin a:=round((0.8+rndn(0.2))*255);pbcrgba(p)[xx+yy*x]:=tcrgba(a,a,a,255);end;
 result:=p;
end;
//############################################################################//
function mktx_rust_steel(p:pointer;x,y,par:integer):pointer;
var xx,yy:integer;
c:pcrgba;
a:integer;
r:double;
begin
 mandelbrot(p,x,y,-1.30,0.15,-1.26,0.2,0.01);
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
  c:=pointer(intptr(p)+intptr((xx+yy*y)*4));
  a:=(c[2]-70);//*round((0.1+rndn(0.05))*255);
  if a<70 then a:=0;
  r:=1;//0.8+rndn(0.2);

  if a<>0 then begin
   c[0]:=round(a*(a/255));
   c[1]:=round((a*r*(a/255))/4);
   c[2]:=0;
  end else begin
   c[0]:=100;
   c[1]:=100;
   c[2]:=100+round(0.2*255*(pnoiNoise(@defnoi,xx/32,yy/32,2/124)/2+0.5));
  end;
  c[3]:=255;
 end;
 result:=p;
end;
//############################################################################//
function mktx_steel(p:pointer;x,y,par:integer):pointer;
var xx,yy:integer;
begin
 for yy:=0 to y-1 do for xx:=0 to x-1 do pbcrgba(p)[xx+yy*x]:=tcrgba(100,100,100+round(0.2*255*(pnoiNoise(@defnoi,xx/32,yy/32,2/124)/2+0.5)),255);
 result:=p;
end;
//############################################################################//
function mktx_marble(px:pointer;xs,ys,par:integer):pointer;
var tx_var:integer;
p:pbcrgba;
bc:crgba;
x,y,bg:integer;
k:single;  
begin   
 result:=px;  
 p:=px;
 tx_var:=10;
 case par of
  0:begin
   tx_var:=25;
   bc:=tcrgba(198,198,198,255);
  end;
  1:begin
   tx_var:=30;
   bc:=tcrgba(178,178,148,255);
  end;
 end;
 
 xnoi.seed:=round(lrandom*1356832);xnoi.ni:=false;  
 bg:=round(log2(xs)/2);
 
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  k:=ridgetf(xnoi,tvec(x/xs*8,y/ys*8,1900),1,bg,evec);
  if k>0.9 then k:=2;
  p[x+xs*y]:=addcl(bc,tcrgba(round(k*tx_var),round(k*tx_var),round(k*tx_var),255));
 end;
end;     
//############################################################################//
function mktx_shadowter(px:pointer;xs,ys,par:integer):pointer;
var p:pbcrgba;
bc:crgba;
x,y,bg:integer;
k:single;  
begin     
 result:=px; 
 p:=px;
 case par of
  0:bc:=tcrgba(198,198,0,255);
  1:bc:=tcrgba(178,178,148,255);
 end;
 
 xnoi.seed:=round(lrandom*1356832);xnoi.ni:=false;  
 bg:=round(log2(xs)/2);
        
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  k:=ridgetf(xnoi,tvec(x/xs*8,y/ys*8,1900),1,bg,evec);
  if k<0 then k:=0;
  p[x+xs*y]:=addcl(bc,tcrgba(round(k*255),round(k*255),round(k*255),0));  
  p[x+xs*y][3]:=round(k*255);
 end;
 txmod_shadows(p,nil,xs,ys,45,0.5,25);
 for y:=0 to ys-1 do for x:=0 to xs-1 do p[x+xs*y][3]:=255;
end;     
//############################################################################//    
function mktx_isoridges(p:pointer;x,y,par:integer):pointer;
var xx,yy,i:integer;
c:pcrgba;
r:double;
begin    
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
  c:=@pbcrgba(p)[xx+yy*x];

  r:=(pnoiNoise(@defnoi,xx/32,yy/32,2/124)+1)/2;
  for i:=0 to par+1 do begin
   r:=r*2-1;if (r>=-1)and(r<0)then r:=r+1 else r:=1-r;
   if r<0.5 then r:=1-r;r:=2*(r-0.5);
  end;
  
  c[0]:=round(r*255);
  c[1]:=c[0];
  c[2]:=c[0];
  c[3]:=255;
 end;       
 result:=p;
end;    
//############################################################################//
function mktx_arrow(px:pointer;x,y,par:integer):pointer;
var p:pbcrgba;
xx,yy:integer;
begin    
 result:=px; 
 p:=px;
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
  p[xx+yy*x]:=tcrgba(123,221,212,255);
  if yy<y div 2 then if(xx>(x div 2-2))and(xx<(x div 2+2))then p[xx+yy*x]:=tcrgba(0,0,0,255);
 end;
end;
//############################################################################//
function mktx_solarpan_sqr(px:pointer;xs,ys,par:integer):pointer;
var p:pbcrgba;
co,cb,cp:crgba;
x,y,xa,ya,xo,yo,xc,yc,i:integer;
k:single;
cell_rows,cell_cols,cell_border,xs_cb,ys_cb,cell_coloroff:integer;
begin  
 result:=px;  
 p:=px;
 case par of
  0:begin    
   cell_rows:=6;
   cell_cols:=6;
   cell_border:=2;
   cell_coloroff:=50;
   cp:=tcrgba(cell_coloroff div 2,cell_coloroff div 2,255-cell_coloroff div 2,255);
   cb:=tcrgba(123,121,212,255);
  end;
  1:begin    
   cell_rows:=6;
   cell_cols:=6;
   cell_border:=2;
   cell_coloroff:=20;
   cp:=tcrgba(200-cell_coloroff div 2,150-cell_coloroff div 2,100-cell_coloroff div 2,255);
   cb:=tcrgba(250,214,102,255);
  end;
  2:begin    
   cell_rows:=6;
   cell_cols:=8;
   cell_border:=2;
   cell_coloroff:=50;
   cp:=tcrgba(cell_coloroff div 2,cell_coloroff div 2,220-cell_coloroff div 2,255);
   cb:=tcrgba(123,121,182,255);
  end;
  3:begin    
   cell_rows:=6;
   cell_cols:=8;
   cell_border:=2;
   cell_coloroff:=50;
   cp:=tcrgba(cell_coloroff div 2,cell_coloroff div 2,120-cell_coloroff div 2,255);
   cb:=tcrgba(123,121,182,255);
  end;
  else begin
   cell_rows:=6;
   cell_cols:=8;
   cell_border:=2;
   cell_coloroff:=50;
   cp:=tcrgba(cell_coloroff div 2,cell_coloroff div 2,120-cell_coloroff div 2,255);
   cb:=tcrgba(123,121,182,255);
  end;
 end;

 xs_cb:=xs-cell_border;
 ys_cb:=ys-cell_border;
 
 for y:=0 to ys-1 do for x:=0 to xs-1 do p[x+y*xs]:=cb;
 //for y:=0 to ys-1 do for x:=0 to xs-1 do p[x+y*x]:=cb;

 for ya:=0 to cell_rows-1 do for xa:=0 to cell_cols-1 do begin
  xo:=cell_border+xa*(xs_cb div cell_cols);
  xc:=(xs_cb div cell_cols)-cell_border;
  if xa=cell_cols-1 then xc:=(xs_cb div cell_cols)+(xs_cb mod cell_cols)-cell_border;
  yo:=cell_border+ya*(ys_cb div cell_rows);
  yc:=(ys_cb div cell_rows)-cell_border;
  if ya=cell_rows-1 then yc:=(ys_cb div cell_rows)+(ys_cb mod cell_rows)-cell_border;
  
  co:=addcl(cp,tcrgba(lrandom(cell_coloroff)-cell_coloroff div 2,lrandom(cell_coloroff)-cell_coloroff div 2,lrandom(cell_coloroff)-cell_coloroff div 2,255));
  for y:=0 to yc-1 do for x:=0 to xc-1 do begin
   k:=1;
   for i:=0 to 1 do k:=k-(1/expa[i+4])*ord(((x mod round(8/expa[i]))=0)or((y mod round(8/expa[i]))=0));
   p[x+xo+xs*(y+yo)]:=nmulcl(co,k);
  end;
 end;  
end;
//############################################################################//
function mktx_truss(px:pointer;xs,ys,par:integer):pointer;
var tx_var:integer;
p:pbcrgba;
bc:crgba;
x,y,bg:integer;
k:single;
begin    
 result:=mktx_metal(px,xs,ys,par);
 exit;

 result:=px;  
 p:=px;
 tx_var:=50;
 bc:=tcrgba(138,138,148,255);
 
 xnoi.seed:=round(lrandom*348576);xnoi.ni:=false;
 bg:=round(log2(xs)/2);
 
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  k:=perlintf(xnoi,tvec(x/xs*8,y/ys*8,100),1,bg,evec);
  p[x+xs*y]:=addcl(bc,tcrgba(round(k*tx_var),round(k*tx_var),round(k*tx_var),255));
 end;
end;      
//############################################################################//
function mktx_termblank(px:pointer;xs,ys,par:integer):pointer;
var p:pbcrgba;
bc:crgba;
x,y,bg:integer;
k:single;  
begin   
 result:=px;   
 p:=px;
 
 if par=0 then bc:=tcrgba(250,240,0,255) else
 if par=1 then bc:=tcrgba(250,250,220,255)
          else bc:=tcrgba(255,255,255,255);

 xnoi.seed:=round(lrandom*1356832);xnoi.ni:=false;  
 bg:=round(log2(xs)/2);
        
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  k:=ridgetf(xnoi,tvec(x/xs*8,y/ys*8,1900),1+ord(par=2),bg,evec);
  if k<0 then k:=0;
  if k<0.5 then k:=1-k;
  if par=2 then k:=(k-0.5)/0.5*0.1+0.9;
  p[x+xs*y]:=nmulcl(bc,k); 
  p[x+xs*y][3]:=round(k*255);
 end;  
 k:=0.65;
 if par=2 then k:=0.9;
 txmod_shadows(p,nil,xs,ys,45,k,25);
 for y:=0 to ys-1 do for x:=0 to xs-1 do p[x+xs*y][3]:=255;
end;      
//############################################################################//
function mktx_tank(px:pointer;xs,ys,par:integer):pointer;
var tx_var,i:integer;
p:pbcrgba;
bc:crgba;
x,y,bg:integer;
k:single;  
begin  
 result:=px;   
 p:=px;
 tx_var:=40;
 bc:=tcrgba(125,145,125,255);
 
 xnoi.seed:=round(lrandom*2456324562);xnoi.ni:=false;
 bg:=round(log2(xs)/2);
 
 if par=0 then for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  k:=perlintf(xnoi,tvec(x/xs*4,y/ys*4,100),1,bg,evec);
  if(x mod (xs div 4))=0 then k:=-1; 
  p[x+xs*y]:=addcl(bc,tcrgba(round(k*tx_var),round(k*tx_var),round(k*tx_var),255));
 end;
 if par=1 then for y:=0 to ys-1 do for x:=0 to xs-1 do begin  
  k:=0; 
  //if par=6 then for i:=0 to 5 do k:=k+(1/expa[i])*ord((((x*y) mod round(64/expa[i]))<6));
  for i:=0 to 5 do k:=k+(1/expa[i+2])*ord(((x mod round(64/expa[i]))<2)or((y mod round(64/expa[i]))<2)); 
  p[x+y*xs]:=addcl(tcrgba(170,180,150,255),nmulcl(tcrgba(245,220,240,255),k/2));
 end; 
end;     
//############################################################################// 
function mktx_wood(p:pointer;xs,ys,par:integer):pointer;
var x,y,i,bg:integer;
k,kx,kz:single;
bc,wc:crgba;
begin     
 result:=p; 
 xnoi.seed:=round(lrandom*34576);xnoi.ni:=false;   
 bg:=round(log2(xs)/2);
 
 i:=(par mod 3)*5; 
 wc:=tcrgba(60,60,20,255);
 bc:=tcrgba(140,60,20,255); 
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  kz:=perlintf(xnoi,tvec(x,y,100),32,bg,evec);  
  k:=kz;                             
  if par<3 then begin
   k:=k*2-1;if (k>=-1)and(k<0)then k:=k+1 else k:=1-k;
   k:=(k-0.5)*2;
  end;
  kx:=perlintf(xnoi,tvec(x+k*i,y+k*10,100),32,bg,tvec(0.5,5+i,1))*0.5+0.5;  
    
  pbcrgba(p)[x+y*xs]:=addcl(addcl(bc,tcrgba(round(kz*10),round(kz*10),round(kz*10),255)),nmulcl(wc,kx));
 end;
end;   
//############################################################################// 
function mktx_earth(p:pointer;xs,ys,par:integer):pointer;
var x,y,i,bg:integer;
k,kx,kz:single;
bc,wc:crgba;
begin     
 result:=p; 
 xnoi.seed:=round(lrandom*34576);xnoi.ni:=false;   
 bg:=round(log2(xs)/2);
 
 i:=(par mod 3)*5; 
 wc:=tcrgba(140,0,0,255);
 bc:=tcrgba(0,140,0,255); 
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  kz:=perlintf(xnoi,tvec(x,y,100),32,bg,evec);  
  k:=kz;                             
  if par<3 then begin
   k:=k*2-1;if (k>=-1)and(k<0)then k:=k+1 else k:=1-k;
   k:=(k-0.5)*2;
  end;
  kx:=perlintf(xnoi,tvec(x+k*i,y+k*10,100),32,bg,tvec(0.5,5+i,1))*0.5+0.5;  
    
  pbcrgba(p)[x+y*xs]:=addcl(addcl(bc,tcrgba(round(kz*10),round(kz*10),round(kz*10),255)),nmulcl(wc,kx));
 end;
end;  
//############################################################################// 
function mktx_stars(p:pointer;xs,ys,par:integer):pointer;
var x,y,i{,bg}:integer;
//k,kx,kz:single;
//bc,wc:crgba;
begin  
 result:=p; 
{   
 xnoi.seed:=round(lrandom*34576);xnoi.ni:=false;   
 bg:=round(log2(xs)/2);
 
 i:=(par mod 3)*5; 
 wc:=tcrgba(140,0,0,255);
 bc:=tcrgba(0,140,0,255); 
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  kz:=perlintf(xnoi,tvec(x,y,100),32,bg,evec);  
  k:=kz;                             
  if par<3 then begin
   k:=k*2-1;if (k>=-1)and(k<0)then k:=k+1 else k:=1-k;
   k:=(k-0.5)*2;
  end;
  kx:=perlintf(xnoi,tvec(x+k*i,y+k*10,100),32,bg,tvec(0.5,5+i,1))*0.5+0.5;  
    
  pbcrgba(p)[x+y*xs]:=addcl(addcl(bc,tcrgba(round(kz*10),round(kz*10),round(kz*10),255)),nmulcl(wc,kx));
 end;
 }   
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  pbcrgba(p)[x+y*xs]:=gclblack;
 end;
 for y:=0 to ys div 4-1 do for x:=0 to xs div 4-1 do begin
  i:=lrandom(255);
  pbcrgba(p)[x*4+y*4*xs]:=tcrgba(i,i,i,255);
 end;
end;    
//############################################################################// 
function mktx_wallpaper(p:pointer;xs,ys,par:integer):pointer;
var x,y,bg:integer;
k,kx,sc:single;
bc,wc:crgba;
begin     
 result:=p; 
 xnoi.seed:=round(lrandom*34576);xnoi.ni:=false;   
 bg:=round(log2(xs)/2);
 
 wc:=tcrgba(60,60,20,255);
 bc:=tcrgba(140,60,20,255); 
 if par=0 then for y:=0 to ys-1 do for x:=0 to xs-1 do begin  
  k:=sqr(perlintf(xnoi,tvec(x,y,1000),1.5,bg,evec)*0.5+0.5);  
  pbcrgba(p)[x+xs*y]:=tcrgba(170+round(k*20),120+round(k*50),70+round(k*70),255);
 end;   
 if par=1 then for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  sc:=xs/4;
  kx:=perlintf(xnoi,tvec(x,y,1000),sc/4,bg,evec); 
  k:=sqr(perlintf(xnoi,tvec(x,y,1000),sc,bg,tvec(1+kx*0.5,1+kx*0.5,1+kx*0.5))*0.5+0.5);    
  pbcrgba(p)[x+xs*y]:=tcrgba(170+round(k*20),120+round(k*50),70+round(k*70),255);
 end; 
end;  
//############################################################################// 
function mktx_metal(p:pointer;xs,ys,par:integer):pointer;
var x,y,i,bg:integer;
k,kx,kz:single;
bc,wc:crgba;
begin   
 result:=p; 
 xnoi.seed:=round(lrandom*34576);xnoi.ni:=false;   
 bg:=round(log2(xs)/2);
 
 i:=(par mod 3)*5; 
 wc:=tcrgba(20,40,40,255);
 bc:=tcrgba(120,120,130,255);
 for y:=0 to ys-1 do for x:=0 to xs-1 do begin
  kz:=perlintf(xnoi,tvec(x,y,100),32,bg,evec);  
  k:=kz;                             
  if par<3 then begin
   k:=k*2-1;if (k>=-1)and(k<0)then k:=k+1 else k:=1-k;
   k:=(k-0.5)*2;
  end;
  kx:=perlintf(xnoi,tvec(x+k*i,y+k*10,100),32,bg,tvec(0.5,5+i,1))*0.5+0.5;  
    
  pbcrgba(p)[x+y*xs]:=addcl(addcl(bc,tcrgba(round(kz*10),round(kz*10),round(kz*10),255)),nmulcl(wc,kx));
 end;
end;              
//############################################################################//
function mktx_newrust_steel(p:pointer;x,y,par:integer):pointer;
var xx,yy:integer;
c:pcrgba;
r:double;
begin    
 for yy:=0 to y-1 do for xx:=0 to x-1 do begin
  c:=@pbcrgba(p)[xx+yy*x];

  r:=pnoiNoise(@defnoi,xx/32,yy/32,2/124); 
  r:=r*2;
  if (r>-2)and(r<0)then r:=r+1 else r:=1-r; 
  if r<0 then r:=0;if r>1 then r:=1;
  
  r:=r*2-1;if (r>=-1)and(r<0)then r:=r+1 else r:=1-r;
  r:=r*2-1;if (r>=-1)and(r<0)then r:=r+1 else r:=1-r;
  r:=r*2-1;if (r>=-1)and(r<0)then r:=r+1 else r:=1-r;
  r:=r*2-1;if (r>=-1)and(r<0)then r:=r+1 else r:=1-r;
    
  
       {
  if r>0.5 then begin
   c[0]:=round(r*255);
   c[1]:=0;
   c[2]:=0;
  end;
  if r>0.7 then begin
   c[0]:=round(r*255);
   c[1]:=round(r*255);
   c[2]:=0;
  end;  }
     
  c[0]:=round(r*255);
  c[1]:=c[0];
  c[2]:=c[0];
  
  {
  c[0]:=100;
  c[1]:=100;
  c[2]:=100+round(0.2*255*(pnoiNoise(@defnoi,xx/32,yy/32,2/124)/2+0.5));
   }
  c[3]:=255;
 end;       
 result:=p;
end;   
//############################################################################//
function mktx_etc(px:pointer;xs,ys,par:integer):pointer;
var p:pbcrgba;
x,y,bg,i,tx_var:integer;
k,kx,ky,kz:single; 
bc:crgba;  
begin    
 result:=px; 
 tx_var:=60;  
 p:=px;
 xnoi.seed:=round(lrandom*34576);xnoi.ni:=false;   
 bg:=6; 
 case par of 
  0:begin 
   for y:=0 to xs-1 do for x:=0 to xs-1 do begin 
    k:=perlintf(xnoi,tvec(x,y,100),32,bg,evec); 
    kx:=perlintf(xnoi,tvec(x,100,y),32,bg,evec); 
    ky:=perlintf(xnoi,tvec(100,x,y),32,bg,evec); 
    kz:=perlintf(xnoi,tvec(y,x,100),32,bg,evec);     
    bc:=tcrgba(128+round(kx*128),128+round(ky*128),128+round(kz*128),255);
  
    p[x+xs*y]:=tcrgba(bc[0]+round(k*tx_var),bc[1]+round(k*tx_var),bc[2]+round(k*tx_var),255);
   end; 
  end; 
  1:begin
   for y:=0 to xs-1 do for x:=0 to xs-1 do begin
    kx:=perlintf(xnoi,tvec(x,y,100),16,bg,evec); 
    ky:=perlintf(xnoi,tvec(100,x,y),16,bg,evec); 
    kz:=perlintf(xnoi,tvec(y,x,100),16,bg,evec);
    k:=perlintf(xnoi,tvec(x+kx*8,y+ky*8,100+kz*8),32,bg,tvec(kx,ky,kz))*0.5+0.5;    
    p[x+xs*y]:=tcrgba(round(k*255),round(k*255),round(k*255),255);
   end; 
  end;  
  2:begin
   for y:=0 to xs-1 do for x:=0 to xs-1 do begin
    kx:=perlintf(xnoi,tvec(x,y,1000),32,bg,evec); 
    k:=perlintf(xnoi,tvec(x+kx*8,y+kx*8,1000+kx*8),128,bg,tvec(kx,kx,kx))*0.5+0.5;   
    p[x+xs*y]:=tcrgba(round(k*255),round(k*255),round(k*255),255);
   end; 
  end;  
  3:begin
  //panels
   for y:=0 to ys-1 do for x:=0 to xs-1 do begin
    k:=0;
    for i:=0 to 5 do k:=k+(1/expa[i])*ord(((x mod round(64/expa[i]))=0)or((y mod round(64/expa[i]))=0));
    p[x+xs*y]:=tcrgba(0+round(k*150),10+round(k*190),80+round(k*160),255);
   end; 
  end;  
  4:begin
   for y:=0 to ys-1 do for x:=0 to xs-1 do begin     
    kx:=perlintf(xnoi,tvec(x,y,100),32,bg,evec)*16; 
    ky:=perlintf(xnoi,tvec(100,x,y),32,bg,evec)*16; 

    k:=0;
    for i:=0 to 5 do k:=k+(1/expa[i])*ord(((round(x+kx) mod round(64/expa[i]))=0)or((round(y+ky) mod round(64/expa[i]))=0));
    p[x+xs*y]:=tcrgba(50+round(k*150),50+round(k*150),50+round(k*190),255);
   end;  
  end;   
  5:begin
   for y:=0 to ys-1 do for x:=0 to xs-1 do begin  
    k:=1*ord(((x+y*xs) mod 674=0)or((x+1+y*xs) mod 674=0)or((x+(y+1)*xs) mod 674=0)or((x+1+(y+1)*xs) mod 674=0));
    p[x+y*xs]:=nmulcl(tcrgba(180,180,180,255),1-k);
   end; 
  end; 
 end; 
end; 
//############################################################################//
//############################################################################//
procedure maddv(g:ptypmshgrp;nx,ny,nz,x,y,z,tx,ty:double);
var i,j:integer;
begin
 i:=length(g.trng);
 j:=length(g.pnts);
 setlength(g.trng,i+1);
 setlength(g.pnts,j+1);

 g.pnts[j].nml:=tmvec(nx,ny,nz);
 g.pnts[j].tx :=tmvec2(tx,ty);
 g.pnts[j].pos:=tmvec(x,y,z);
 g.trng[i]:=j;
end;
//############################################################################//
function gnml(v1,v2,v3:vec):vec;
begin
 result:=vmulv(subv(v1,v2),subv(v2,v3));
 result:=nrvec(result);
end;
//############################################################################//
procedure mktv(g:ptypmshgrp;r1,r2,phi,psi,tx,ty:double;zcrx:boolean);
var nx,ny,nz:double;
begin
 nx:=cos(phi)*cos(psi);
 ny:=sin(psi);
 nz:=sin(phi)*cos(psi);
 maddv(g,nx,ny,nz,r1*cos(phi)+r2*nx,r2*ny+ord(zcrx)*3*cos(phi*4),r1*sin(phi)+r2*nz,tx,ty);
end;
//############################################################################//
//############################################################################//
procedure mk_pln(g:ptypmshgrp;xs,ys:double);
begin
 g.typ:=0;
 setlength(g.trng,6);
 setlength(g.pnts,4);

 g.pnts[0].nml:=tmvec(0,0,1);g.pnts[0].tx :=tmvec2(0,1);g.pnts[0].pos:=tmvec(-0.5*xs, 0.5*ys,0);
 g.pnts[1].nml:=tmvec(0,0,1);g.pnts[1].tx :=tmvec2(0,0);g.pnts[1].pos:=tmvec(-0.5*xs,-0.5*ys,0);
 g.pnts[2].nml:=tmvec(0,0,1);g.pnts[2].tx :=tmvec2(1,0);g.pnts[2].pos:=tmvec( 0.5*xs,-0.5*ys,0);
 g.pnts[3].nml:=tmvec(0,0,1);g.pnts[3].tx :=tmvec2(1,1);g.pnts[3].pos:=tmvec( 0.5*xs, 0.5*ys,0);

 g.trng[0]:=0;g.trng[1]:=3;g.trng[2]:=2;
 g.trng[3]:=2;g.trng[4]:=1;g.trng[5]:=0;
end;
//############################################################################//
procedure mk_crx(g:ptypmshgrp;siz:double;xpos:double=0;ypos:double=0;zpos:double=0);
var v:vec;
t,d:double;
begin
 siz:=siz/2;
 g.typ:=0;
 d:=0.125*siz;
 t:=(d/2);

 v:=gnml(tvec(d,d,0),tvec(0,siz,0),tvec(0,0,t));
 maddv(g,v.x,v.y,v.z, d+xpos,  d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z, 0+xpos,siz+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z, 0+xpos,  0+ypos, t+zpos,0,0);
 v:=gnml(tvec(0,0,t),tvec(0,siz,0),tvec(-d,d,0));
 maddv(g,v.x,v.y,v.z, 0+xpos,  0+ypos, t+zpos,0,0);
 maddv(g,v.x,v.y,v.z, 0+xpos,siz+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z,-d+xpos,  d+ypos, 0+zpos,-d/siz,d/siz);
 v:=gnml(tvec(0,0,t),tvec(0,siz,0),tvec(d,d,0));
 maddv(g,v.x,v.y,v.z, 0+xpos,  0+ypos,-t+zpos,0,0);
 maddv(g,v.x,v.y,v.z, 0+xpos,siz+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z, d+xpos,  d+ypos, 0+zpos,-d/siz,d/siz);
 v:=gnml(tvec(-d,d,0),tvec(0,siz,0),tvec(0,0,t));
 maddv(g,v.x,v.y,v.z,-d+xpos,  d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z, 0+xpos,siz+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z, 0+xpos,  0+ypos,-t+zpos,0,0);

 v:=gnml(tvec(d,-d,0),tvec(0,0,t),tvec(0,-siz,0));
 maddv(g,v.x,v.y,v.z, d+xpos,  -d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z, 0+xpos,   0+ypos, t+zpos,0,0);
 maddv(g,v.x,v.y,v.z, 0+xpos,-siz+ypos, 0+zpos,1,1);
 v:=gnml(tvec(0,0,t),tvec(-d,-d,0),tvec(0,-siz,0));
 maddv(g,v.x,v.y,v.z, 0+xpos,   0+ypos, t+zpos,0,0); 
 maddv(g,v.x,v.y,v.z,-d+xpos,  -d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z, 0+xpos,-siz+ypos, 0+zpos,1,1);
 v:=gnml(tvec(0,-siz,0),tvec(0,0,t),tvec(d,d,0));
 maddv(g,v.x,v.y,v.z, 0+xpos,-siz+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z, 0+xpos,   0+ypos,-t+zpos,0,0);
 maddv(g,v.x,v.y,v.z, d+xpos,  -d+ypos, 0+zpos,-d/siz,d/siz);
 v:=gnml(tvec(-d,d,0),tvec(0,0,t),tvec(0,-siz,0));
 maddv(g,v.x,v.y,v.z,-d+xpos,  -d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z, 0+xpos,   0+ypos,-t+zpos,0,0);
 maddv(g,v.x,v.y,v.z, 0+xpos,-siz+ypos, 0+zpos,1,1);

 v:=gnml(tvec(0,0,t),tvec(siz,0,0),tvec(d,d,0));
 maddv(g,v.x,v.y,v.z,  0+xpos, 0+ypos, t+zpos,0,0);
 maddv(g,v.x,v.y,v.z,siz+xpos, 0+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z,  d+xpos, d+ypos, 0+zpos,-d/siz,d/siz);
 v:=gnml(tvec(0,0,t),tvec(d,-d,0),tvec(siz,0,0));
 maddv(g,v.x,v.y,v.z,  0+xpos, 0+ypos, t+zpos,0,0);
 maddv(g,v.x,v.y,v.z,  d+xpos,-d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z,siz+xpos, 0+ypos, 0+zpos,1,1);
 v:=gnml(tvec(0,0,-t),tvec(d,d,0),tvec(siz,0,0));
 maddv(g,v.x,v.y,v.z,  0+xpos, 0+ypos,-t+zpos,0,0);
 maddv(g,v.x,v.y,v.z,  d+xpos, d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z,siz+xpos, 0+ypos, 0+zpos,1,1);
 v:=gnml(tvec(0,0,-t),tvec(siz,0,0),tvec(d,-d,0));
 maddv(g,v.x,v.y,v.z,  0+xpos, 0+ypos,-t+zpos,0,0);
 maddv(g,v.x,v.y,v.z,siz+xpos, 0+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z,  d+xpos,-d+ypos, 0+zpos,-d/siz,d/siz);

 v:=gnml(tvec(0,0,t),tvec(-d,d,0),tvec(-siz,0,0));
 maddv(g,v.x,v.y,v.z,   0+xpos, 0+ypos, t+zpos,0,0);
 maddv(g,v.x,v.y,v.z,  -d+xpos, d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z,-siz+xpos, 0+ypos, 0+zpos,1,1);
 v:=gnml(tvec(0,0,t),tvec(-siz,0,0),tvec(-d,-d,0));
 maddv(g,v.x,v.y,v.z,   0+xpos, 0+ypos, t+zpos,0,0);
 maddv(g,v.x,v.y,v.z,-siz+xpos, 0+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z,  -d+xpos,-d+ypos, 0+zpos,-d/siz,d/siz);
 v:=gnml(tvec(0,0,-t),tvec(-siz,0,0),tvec(-d,d,0));
 maddv(g,v.x,v.y,v.z,   0+xpos, 0+ypos,-t+zpos,0,0);
 maddv(g,v.x,v.y,v.z,-siz+xpos, 0+ypos, 0+zpos,1,1);
 maddv(g,v.x,v.y,v.z,  -d+xpos, d+ypos, 0+zpos,-d/siz,d/siz);
 v:=gnml(tvec(0,0,-t),tvec(-d,-d,0),tvec(-siz,0,0));
 maddv(g,v.x,v.y,v.z,   0+xpos, 0+ypos,-t+zpos,0,0);
 maddv(g,v.x,v.y,v.z,  -d+xpos,-d+ypos, 0+zpos,-d/siz,d/siz);
 maddv(g,v.x,v.y,v.z,-siz+xpos, 0+ypos, 0+zpos,1,1);
end;
//############################################################################//
//############################################################################//
procedure mk_cube(g:ptypmshgrp;xsiz,ysiz,zsiz:double;xpos:double=0;ypos:double=0;zpos:double=0);
begin
 g.typ:=0; 
 //z+
 maddv(g, 0, 0, 1,-0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,0,1);
 maddv(g, 0, 0, 1,-0.5*xsiz+xpos,-0.5*ysiz+ypos, 0.5*zsiz+zpos,0,0);
 maddv(g, 0, 0, 1, 0.5*xsiz+xpos,-0.5*ysiz+ypos, 0.5*zsiz+zpos,1,0);
 maddv(g, 0, 0, 1,-0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,0,1);  
 maddv(g, 0, 0, 1, 0.5*xsiz+xpos,-0.5*ysiz+ypos, 0.5*zsiz+zpos,1,0);
 maddv(g, 0, 0, 1, 0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,1,1);
     
 //z-
 maddv(g, 0, 0,-1,-0.5*xsiz+xpos, 0.5*ysiz+ypos,-0.5*zsiz+zpos,0,1);
 maddv(g, 0, 0,-1, 0.5*xsiz+xpos, 0.5*ysiz+ypos,-0.5*zsiz+zpos,1,1);
 maddv(g, 0, 0,-1, 0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,1,0);
 maddv(g, 0, 0,-1,-0.5*xsiz+xpos, 0.5*ysiz+ypos,-0.5*zsiz+zpos,0,1);
 maddv(g, 0, 0,-1, 0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,1,0);
 maddv(g, 0, 0,-1,-0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,0,0);  

 //x+
 maddv(g, 1, 0, 0, 0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,1,1);
 maddv(g, 1, 0, 0, 0.5*xsiz+xpos,-0.5*ysiz+ypos, 0.5*zsiz+zpos,1,0);
 maddv(g, 1, 0, 0, 0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,0,0);  
 maddv(g, 1, 0, 0, 0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,1,1);  
 maddv(g, 1, 0, 0, 0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,0,0);  
 maddv(g, 1, 0, 0, 0.5*xsiz+xpos, 0.5*ysiz+ypos,-0.5*zsiz+zpos,0,1);
 
 //x-
 maddv(g,-1, 0, 0,-0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,0,0);
 maddv(g,-1, 0, 0,-0.5*xsiz+xpos,-0.5*ysiz+ypos, 0.5*zsiz+zpos,1,0);
 maddv(g,-1, 0, 0,-0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,1,1);
 maddv(g,-1, 0, 0,-0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,0,0);  
 maddv(g,-1, 0, 0,-0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,1,1);
 maddv(g,-1, 0, 0,-0.5*xsiz+xpos, 0.5*ysiz+ypos,-0.5*zsiz+zpos,0,1);
 
 //y+
 maddv(g, 0, 1, 0, 0.5*xsiz+xpos, 0.5*ysiz+ypos,-0.5*zsiz+zpos,0,1);
 maddv(g, 0, 1, 0,-0.5*xsiz+xpos, 0.5*ysiz+ypos,-0.5*zsiz+zpos,0,0);
 maddv(g, 0, 1, 0,-0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,1,0);
 maddv(g, 0, 1, 0, 0.5*xsiz+xpos, 0.5*ysiz+ypos,-0.5*zsiz+zpos,0,1);  
 maddv(g, 0, 1, 0,-0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,1,0);
 maddv(g, 0, 1, 0, 0.5*xsiz+xpos, 0.5*ysiz+ypos, 0.5*zsiz+zpos,1,1);
 
 //y-
 maddv(g, 0,-1, 0, 0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,0,1);
 maddv(g, 0,-1, 0, 0.5*xsiz+xpos,-0.5*ysiz+ypos, 0.5*zsiz+zpos,1,1);
 maddv(g, 0,-1, 0,-0.5*xsiz+xpos,-0.5*ysiz+ypos, 0.5*zsiz+zpos,1,0);
 maddv(g, 0,-1, 0, 0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,0,1); 
 maddv(g, 0,-1, 0,-0.5*xsiz+xpos,-0.5*ysiz+ypos, 0.5*zsiz+zpos,1,0);
 maddv(g, 0,-1, 0,-0.5*xsiz+xpos,-0.5*ysiz+ypos,-0.5*zsiz+zpos,0,0);
end;
//############################################################################//
//############################################################################//
procedure mk_roundpln(g:ptypmshgrp;c:integer;r:double;ds:boolean;xpos:double=0;ypos:double=0;zpos:double=0);     
var i,t,p:integer;
x,y:double;
begin       
 g.typ:=0;
 
 t:=length(g.trng);
 p:=length(g.pnts);
 setlength(g.trng,t+c*3+ord(ds)*c*3);
 setlength(g.pnts,p+c+1);

 g.pnts[p+0].nml:=tmvec(0,0,1);
 g.pnts[p+0].tx :=tmvec2(0.5,0.5);
 g.pnts[p+0].pos:=tmvec(xpos,ypos,zpos);
 //g.trng[t]:=p;

 for i:=0 to c-1 do begin
  x:=sin(i/c*pi*2);
  y:=cos(i/c*pi*2);
  g.pnts[p+i+1].nml:=tmvec(0,0,1);
  g.pnts[p+i+1].tx :=tmvec2(0.5+0.5*x,0.5+0.5*y);
  g.pnts[p+i+1].pos:=tmvec(xpos+r*x,ypos+r*y,zpos);
 end;
 for i:=0 to c-1 do begin
  g.trng[t+i*3+2]:=p;
  g.trng[t+i*3+1]:=p+1+i;
  g.trng[t+i*3+0]:=p+1+i+1;
  if i=c-1 then g.trng[t+i*3+0]:=p+1;
 end;
 if ds then for i:=0 to c-1 do begin
  g.trng[t+i*3+c*3+0]:=p;
  g.trng[t+i*3+c*3+1]:=p+1+i;
  g.trng[t+i*3+c*3+2]:=p+1+i+1;
  if i=c-1 then g.trng[t+i*3+c*3+2]:=p+1;
 end;
end;
//############################################################################//
procedure mk_tor(g:ptypmshgrp;r,thk:double;n1,n2:integer;z_spale:boolean);
var phi1,phi2,psi1,psi2:double;
i,i2,j,j2:integer;
begin
 g.typ:=0;
 for i:=0 to n1-1 do begin
  if i<n1-1 then i2:=i+1 else i2:=0;
  phi1:=2*i*Pi/n1;
  phi2:=2*i2*Pi/n1;
  for j:=0 to n2-1 do begin
   if j<n2-1 then j2:=j+1 else j2:=0;
   psi1:=2*j*Pi/n2;
   psi2:=2*j2*Pi/n2;

   mktv(g,r,thk,phi1,psi1,5*i/n1,j/n2,z_spale);
   mktv(g,r,thk,phi1,psi2,5*i/n1,(j+1)/n2,z_spale);
   mktv(g,r,thk,phi2,psi2,5*(i+1)/n1,(j+1)/n2,z_spale);
                                                
   mktv(g,r,thk,phi1,psi1,5*i/n1,j/n2,z_spale);   
   mktv(g,r,thk,phi2,psi2,5*(i+1)/n1,(j+1)/n2,z_spale);
   mktv(g,r,thk,phi2,psi1,5*(i+1)/n1,j/n2,z_spale);
  end;
 end;
end;
//############################################################################//
// Create a spherical mesh of radius 1 and resolution defined by nrings
// Below is a list of #vertices and #indices against nrings:
//
//lv nrings  nvtx   nidx  texres (nidx = 12 nrings^2)
//0    4       38    192  1x32
//1    6       80    432  1x64
//2    8      138    768  1x128
//3   12      302   1728  1x256
//4   16      530   3072  2x256
//    20      822   4800
//    24     1178   6912  
procedure mk_sphere(g:ptypmshgrp;nrings:dword;hemisphere:boolean;which_half,texres:integer;scale:double=1);
var nVtx,nIdx:dword;
x,y,nvstx,nisdx,wNorthVtx,wSouthVtx,p1,p2,p3:word;
fDAng,fDAngY0,fDAngX0:double;
x1,x2:dword;
du,a,y0,r0,tv,tu:double;
v,pvy,nvy:vec;
begin    
 g.typ:=0;
 
 // Allocate memory for the vertices and indices
 if hemisphere then begin
  nVtx:=nrings*(nrings+1)+2;
  nIdx:=6*nrings*nrings;
 end else begin
  nVtx:=nrings*(2*nrings+1)+2;
  nIdx:=12*nrings*nrings;
 end;

 setlength(g.pnts,nVtx);
 setlength(g.trng,nIdx);

 //Counters
 nvstx:=0; nisdx:=0;
 //vstx:=Vtx; isdx:=Idx;

 //Angle deltas for constructing the sphere's vertices
 fDAng  :=PI/nrings;
 fDAngY0:=fDAng;
 
 x1:=nrings*(1-dword(ord(hemisphere))+1);
 x2:=x1+1;
 du:=0.5/texres;
 a:=(1-2*du)/x1;

 // Make the middle of the sphere
 for y:=0 to nrings-1 do begin
  y0:=cos(fDAngY0);
  r0:=sin(fDAngY0);
	tv:=fDAngY0/PI;

  for x:=0 to x2-1 do begin
   fDAngX0:=x*fDAng-PI;  // subtract Pi to wrap at +-180°
   if(hemisphere and (which_half=1))then fDAngX0:=fDAngX0+PI;
   v:=tvec(r0*cos(fDAngX0),y0,r0*sin(fDAngX0));
   tu:=a*x+du;
   //tu:=x/x1;
   g.pnts[nvstx]:=tpntyps(v,v,tu,tv);
   nvstx:=nvstx+1;
  end;
  fDAngY0:=fDAngY0+fDAng;
 end;

 for y:=0 to nrings-2 do for x:=0 to x1-1 do begin
  g.trng[nisdx+0]:=((y+0)*x2+(x+0));
  g.trng[nisdx+1]:=((y+0)*x2+(x+1));
  g.trng[nisdx+2]:=((y+1)*x2+(x+0));
  g.trng[nisdx+3]:=((y+0)*x2+(x+1));
  g.trng[nisdx+4]:=((y+1)*x2+(x+1));
  g.trng[nisdx+5]:=((y+1)*x2+(x+0)); 
  nisdx:=nisdx+6;
 end;
 
 // Make top and bottom
 pvy:=tvec(0, 1, 0); nvy:=tvec(0,-1,0);
 wNorthVtx:=nvstx;
 g.pnts[nvstx]:=tpntyps(pvy,pvy,0.5,0);
 nvstx:=nvstx+1;
 wSouthVtx:=nvstx;
 g.pnts[nvstx]:=tpntyps(nvy,nvy,0.5,1);
 //nvstx:=nvstx+1;
 y:=nrings-2;

 for x:=0 to x1-1 do begin
  p1:=wSouthVtx;
  p2:=(y)*x2+(x+0);
  p3:=(y)*x2+(x+1);    
  g.trng[nisdx+0]:=p1;
  g.trng[nisdx+1]:=p3;
  g.trng[nisdx+2]:=p2;
  nisdx:=nisdx+3;
 end;
 for x:=0 to x1-1 do begin
  p1:=wNorthVtx;
  p2:=(0)*x2+(x+0);
  p3:=(0)*x2+(x+1);    
  g.trng[nisdx+0]:=p1;
  g.trng[nisdx+1]:=p3;
  g.trng[nisdx+2]:=p2;
  nisdx:=nisdx+3;
 end;
 scale_mshgrp(g^,tmvec(scale,scale,scale));
end;
//############################################################################//
procedure mk_spherepatch(g:ptypmshgrp;nlng,nlat,ilat,res,bseg:integer;reduce,outside,store_vtx:boolean);  
const c1=1;c2=0;  
var
i,j,nVtx,nIdx,nseg,n,nofs0,nofs1:integer;
minlat,maxlat,lat,minlng,maxlng,lng:double;
slat,clat,slng,clng:double;
tmp:word;
pos,tpos:vec; 
clat0,clng0,clat1,clng1,slat0,slng0,slat1,slng1,tu0,tv0,tu1,tv1:double;
ex,ey,ez,pref,tpmin,tpmax:vec;
r:mat;
begin     
 g.typ:=0;
 
 minlat:=PI*0.5*ilat/nlat;
 maxlat:=PI*0.5*(ilat+1)/nlat;
 minlng:=0;
 maxlng:=PI*2/nlng;
 if(bseg<0)or(ilat=(nlat-1))then bseg:=(nlat-ilat)*res;

 // generate nodes
 nVtx:=(bseg+1)*(res+1);
 if reduce then nVtx:=nVtx-((res+1)*res) div 2; 
  
 setlength(g.pnts,nVtx);
 ///////////////////////////////////////////VERTEX_2TEX *Vtx = new VERTEX_2TEX[nVtx];

 // create transformation for bounding box
 // we define the local coordinates for the patch so that the x-axis points
 // from (minlng,minlat) corner to (maxlng,minlat) corner (origin is halfway between)
 // y-axis points from local origin to middle between (minlng,maxlat) and (maxlng,maxlat)
 // bounding box is created in this system and then transformed back to planet coords.
 clat0:=cos(minlat); slat0:=sin(minlat);
 clng0:=cos(minlng); slng0:=sin(minlng);
 clat1:=cos(maxlat); slat1:=sin(maxlat);
 clng1:=cos(maxlng); slng1:=sin(maxlng);
 ex:=nrvec(tvec(clat0*clng1-clat0*clng0,0,clat0*slng1-clat0*slng0));
 ey:=nrvec(tvec(0.5*(clng0+clng1)*(clat1-clat0),slat1-slat0,0.5*(slng0+slng1)*(clat1-clat0)));
 ez:=vmulv(ey,ex);
 R[0]:=ex; R[1]:=ey; R[2]:=ez;
 pref:=tvec(0.5*(clat0*clng1+clat0*clng0),slat0,0.5*(clat0*slng1+clat0*slng0)); // origin

 n:=0;
 for i:=0 to res do begin  // loop over longitudinal strips
	lat:=minlat+(maxlat-minlat)*i/res;
	slat:=sin(lat); clat:=cos(lat);
	if reduce then nseg:=bseg-i else nseg:=bseg;
	for j:=0 to nseg do begin 
	 if nseg<>0 then lng:=minlng+(maxlng-minlng)*j/nseg else lng:=0;
	 slng:=sin(lng); clng:=cos(lng);
	 pos:=tvec(clat*clng,slat,clat*slng);
	 tpos:=lvmat(r,subv(pos,pref));                                                    ////////////////////////////////////////
	 if n=0 then begin
		tpmin:=tpos;
		tpmax:=tpos;
	 end else begin
    if(tpos.x<tpmin.x)then tpmin.x:=tpos.x else if(tpos.x>tpmax.x)then tpmax.x:=tpos.x;
    if(tpos.y<tpmin.y)then tpmin.y:=tpos.y else if(tpos.y>tpmax.y)then tpmax.y:=tpos.y;
    if(tpos.z<tpmin.z)then tpmin.z:=tpos.z else if(tpos.z>tpmax.z)then tpmax.z:=tpos.z;
	 end;

   if nseg<>0 then tu0:=(c1*j)/nseg+c2 else tu0:=0.5;
   tv0:=(c1*(res-i))/res+c2;
   //if nseg<>0 then tu1:=tu0*TEX2_MULTIPLIER else tu1:=0.5;
   //tv1:=tv0*TEX2_MULTIPLIER;
   g.pnts[n]:=tpntyps(pos,pos,tu0,tv0);

	 if(not outside)then g.pnts[n].nml:=nmulv(g.pnts[n].nml,-1);
   
	 n:=n+1;
  end;
 end;

	// generate faces   
 nIdx:=2*res*bseg*3;
 if reduce then nIdx:=res*(2*bseg-res)*3; 
 setlength(g.trng,nIdx);
 for i:=0 to nIdx-1 do g.trng[i]:=0;

 n:=0; nofs0:=0;
 for i:=0 to res-1 do begin
  if reduce then nseg:=bseg-i else nseg:=bseg;
	nofs1:=nofs0+nseg+1;
	for j:=0 to nseg-1 do begin  
	 g.trng[n+0]:=nofs0+j;
	 g.trng[n+1]:=nofs1+j;
	 g.trng[n+2]:=nofs0+j+1; 
   n:=n+3;          
	 if reduce and (j=(nseg-1))then break; 
	 g.trng[n+0]:=nofs0+j+1;
	 g.trng[n+1]:=nofs1+j;
	 g.trng[n+2]:=nofs1+j+1;  
   n:=n+3;       
	end;
  nofs0:=nofs1;
 end;
         
	if(not outside)then for i:=0 to nIdx-1 do begin
   tmp:=g.trng[i*3+1];
   g.trng[i*3+1]:=g.trng[i*3+2];
   g.trng[i*3+2]:=tmp;
  end;  


  {    
	D3DVERTEXBUFFERDESC vbd = 
	[ sizeof(D3DVERTEXBUFFERDESC), vbMemCaps | D3DVBCAPS_WRITEONLY, FVF_2TEX, nVtx ];
	d3d->CreateVertexBuffer (&vbd, &mesh.vb, 0);
	LPVOID data;
	mesh.vb->Lock (DDLOCK_WAIT | DDLOCK_WRITEONLY | DDLOCK_DISCARDCONTENTS, (LPVOID*)&data, NULL);
	memcpy (data, Vtx, nVtx*sizeof(VERTEX_2TEX));
	mesh.vb->Unlock();
	mesh.vb->Optimize (dev, 0);

	if (store_vtx) begin
		mesh.vtx = Vtx;
	end else begin
		delete []Vtx;
		mesh.vtx = 0;
	end
	mesh.nv  = nVtx;
	mesh.idx = Idx;
	mesh.ni  = nIdx;

	// set bounding box
	static D3DVERTEXBUFFERDESC bbvbd =[ sizeof(D3DVERTEXBUFFERDESC), D3DVBCAPS_SYSTEMMEMORY, D3DFVF_XYZ, 8 ];
	VERTEX_XYZ *V;
	d3d->CreateVertexBuffer (&bbvbd, &mesh.bb, 0);
	mesh.bb->Lock (DDLOCK_WAIT | DDLOCK_WRITEONLY | DDLOCK_DISCARDCONTENTS, (LPVOID*)&V, NULL);
	// transform bounding box back to patch coordinates
	pos = tmul (R, _V(tpmin.x, tpmin.y, tpmin.z)) + pref;
	V[0].x = D3DVAL(pos.x); V[0].y = D3DVAL(pos.y); V[0].z = D3DVAL(pos.z);
	pos = tmul (R, _V(tpmax.x, tpmin.y, tpmin.z)) + pref;
	V[1].x = D3DVAL(pos.x); V[1].y = D3DVAL(pos.y); V[1].z = D3DVAL(pos.z);
	pos = tmul (R, _V(tpmin.x, tpmax.y, tpmin.z)) + pref;
	V[2].x = D3DVAL(pos.x); V[2].y = D3DVAL(pos.y); V[2].z = D3DVAL(pos.z);
	pos = tmul (R, _V(tpmax.x, tpmax.y, tpmin.z)) + pref;
	V[3].x = D3DVAL(pos.x); V[3].y = D3DVAL(pos.y); V[3].z = D3DVAL(pos.z);
	pos = tmul (R, _V(tpmin.x, tpmin.y, tpmax.z)) + pref;
	V[4].x = D3DVAL(pos.x); V[4].y = D3DVAL(pos.y); V[4].z = D3DVAL(pos.z);
	pos = tmul (R, _V(tpmax.x, tpmin.y, tpmax.z)) + pref;
	V[5].x = D3DVAL(pos.x); V[5].y = D3DVAL(pos.y); V[5].z = D3DVAL(pos.z);
	pos = tmul (R, _V(tpmin.x, tpmax.y, tpmax.z)) + pref;
	V[6].x = D3DVAL(pos.x); V[6].y = D3DVAL(pos.y); V[6].z = D3DVAL(pos.z);
	pos = tmul (R, _V(tpmax.x, tpmax.y, tpmax.z)) + pref;
	V[7].x = D3DVAL(pos.x); V[7].y = D3DVAL(pos.y); V[7].z = D3DVAL(pos.z);
	mesh.bb->Unlock ();
  }
end;     
//############################################################################//                   
procedure mk_ringmsh(g:ptypmshgrp;irad,orad:double;nsect:integer);
var i,j:integer;
alpha,nrad,ir,fo,fi,phi,cosp,sinp:double;
begin    
 setlength(g.trng,6*nsect);
 setlength(g.pnts,2*nsect);

 alpha:=pi/nsect;
 nrad:=orad/cos(alpha); //distance for outer nodes
 ir:=irad;
 fo:=0.5*(1-orad/nrad);
 fi:=0.5*(1-irad/nrad);

 j:=0;
 for i:=0 to nsect-1 do begin
	phi:=i*2*alpha;
	cosp:=cos(phi);
  sinp:=sin(phi);

  g.pnts[i*2  ].pos:=tmvec(nrad*cosp,0,nrad*sinp); 
  g.pnts[i*2  ].nml:=tmvec(0,1,0); 
  g.pnts[i*2+1].pos:=tmvec(ir*cosp,0,ir*sinp); 
  g.pnts[i*2+1].nml:=tmvec(0,1,0); 

  if((i and 1)=0)then begin 
   g.pnts[i*2  ].tx.x:=fo;
   g.pnts[i*2+1].tx.x:=fi;
  end else begin
   g.pnts[i*2  ].tx.x:=1-fo;
   g.pnts[i*2+1].tx.x:=1-fi;
  end;       
  g.pnts[i*2  ].tx.y:=0;
  g.pnts[i*2+1].tx.y:=1;

  g.trng[j]:=i*2;j:=j+1;
  g.trng[j]:=i*2+1;j:=j+1;
  g.trng[j]:=(i*2+2)mod(2*nsect);j:=j+1;
  g.trng[j]:=(i*2+3)mod(2*nsect);j:=j+1;
  g.trng[j]:=(i*2+2)mod(2*nsect);j:=j+1;
  g.trng[j]:=i*2+1;j:=j+1;
 end;
end;  
//############################################################################//
begin  
 new(xnoi);
end.  
//############################################################################//