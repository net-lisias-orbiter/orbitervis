//############################################################################//
// SpaceWay Orbit MFD
// Made in 2005-2010 by Artyom Litvinovich
// Since 2009 based on FreeOrbitMFD code by C J Plooy (cornware-cjp@lycos.nl) 
//############################################################################//
unit mfd_api;
interface
uses asys,grph,strval,maths,glgr;
//############################################################################//
const
TYP_STAR=0;
TYP_PLANET=1;
TYP_MOON=2;
TYP_VESSEL=3;
TYP_STARGATE=4;
 
type
pobjtype=^objtype;
objtype=record 
 tp,id:integer;
 name:string;
 m,r:double;
 pos,gps,glp,vel,rot,dir,vrot:vec; 
 rotm:mat; 
 ref:pobjtype; 
end;

drwinfo=record
 tx:cardinal;
 p:pbcrgba;
 xp,yp,xs,ys:integer;
end;
pdrwinfo=^drwinfo; 

lst_prc_typ=procedure(ps:integer;p:pointer);
inp_prc_typ=procedure(st:string;p:pointer);

mfdtyp=record
 used:boolean;
 name:string;
 
 p:pointer;
 
 prinit:procedure(p:pointer;xs,ys:integer;tgt:pobjtype);
 prdraw:procedure(dr:pdrwinfo;p:pointer);
 prtimer:procedure(p:pointer;dt,ct:double);
 prkeyinp:procedure(p:pointer;tp,key:byte;shift:tshiftstate);
end;     
//############################################################################//  
procedure swmg_text(dr:pdrwinfo;txt:string;x,y:integer;cl:crgba);      
procedure swmg_textcnt(dr:pdrwinfo;txt:string;x,y:integer;cl:crgba);
procedure swmg_line(dr:pdrwinfo;xh,yh,xl,yl:integer;cl:crgba);
procedure swmg_ellipse(dr:pdrwinfo;xh,yh,xl,yl:integer;cl:crgba);
procedure swmg_sqr(dr:pdrwinfo;x,y,xs,ys:integer;cla,clb:crgba);
procedure swmg_pixel(dr:pdrwinfo;x,y:integer;cl:crgba);            
function mkmfdtyp(name:string;p,init,draw,timer,keyinp:pointer):mfdtyp;    
procedure mkcbcallback(nam:string;cbk:lst_prc_typ;par:pointer);   
//############################################################################//
var swmg_planets:array of pobjtype;
swmg_planets_cnt:integer;        
//############################################################################//
implementation
//############################################################################//
procedure swmg_text(dr:pdrwinfo;txt:string;x,y:integer;cl:crgba);
begin
 wrtxt2D(txt,1,dr.xp+x,dr.yp+y,cl);
end;    
//############################################################################//         
procedure swmg_textcnt(dr:pdrwinfo;txt:string;x,y:integer;cl:crgba);
begin
 wrtxtcnt2D(txt,1,dr.xp+x,dr.yp+y,cl);
end;                   
//############################################################################//
procedure swmg_line(dr:pdrwinfo;xh,yh,xl,yl:integer;cl:crgba);
begin
 if not inrect(xh,yh,0,0,dr.xs-1,dr.ys-1)then exit;
 if not inrect(xl,yl,0,0,dr.xs-1,dr.ys-1)then exit;
 wrline2D(dr.xp+xh,dr.yp+yh,dr.xp+xl,dr.yp+yl,cl);
end;                                 
//############################################################################//
procedure swmg_ellipse(dr:pdrwinfo;xh,yh,xl,yl:integer;cl:crgba);
begin
 if not inrect(xh,yh,0,0,dr.xs-1,dr.ys-1)then exit;
 if not inrect(xl,yl,0,0,dr.xs-1,dr.ys-1)then exit;
 wrellipse2D(dr.xp+xh,dr.yp+yh,dr.xp+xl,dr.yp+yl,cl);
end;
//############################################################################//
procedure swmg_sqr(dr:pdrwinfo;x,y,xs,ys:integer;cla,clb:crgba);
begin
 if not inrect(x,y,0,0,dr.xs-1,dr.ys-1)then exit;
 if not inrect(x+xs,y+ys,0,0,dr.xs-1,dr.ys-1)then exit;
 putsqr2D(dr.xp+x,dr.yp+y,xs,ys,cla,clb);
end;       
//############################################################################//
procedure swmg_pixel(dr:pdrwinfo;x,y:integer;cl:crgba);  
begin
 if not inrect(x,y,0,0,dr.xs-1,dr.ys-1)then exit;
 wrpix2D(dr.xp+x,dr.yp+y,cl);
end;                
//############################################################################//
function mkmfdtyp(name:string;p,init,draw,timer,keyinp:pointer):mfdtyp;
begin
 result.p:=p;
 result.name:=name;
 result.prinit:=init;
 result.prdraw:=draw;
 result.prtimer:=timer;
 result.prkeyinp:=keyinp;
end;                   
//############################################################################//  
procedure mkcbcallback(nam:string;cbk:lst_prc_typ;par:pointer);   
var i:integer;
begin
{
 sw_menu.lst_name:=nam;
 setlength(sw_menu.lst_str,sw_un.cbcnt);   
 for i:=0 to sw_un.cbcnt-1 do sw_menu.lst_str[i]:=sw_un.cb[i].obj.name;
 sw_menu.lst_prc:=cbk;
 sw_menu.lst_sel:=0;
 sw_menu.par:=par;
 
 sw_menu.prev_int_st:=sw_menu.int_st;
 sw_menu.int_st:=IST_LST;
 }
end;
//############################################################################//   
begin
end.   
//############################################################################//

