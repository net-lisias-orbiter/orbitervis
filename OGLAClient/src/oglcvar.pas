//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLAClient variables file
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglcvar;
interface  
uses windows,asys,grph,maths,oapi,orbitergl{$ifndef no_render},ogladata{$endif};
//############################################################################//
const initstrs='TheOGLA';   
//############################################################################//
type ogla_interface=record 
 //Out  
 initgl  :procedure(hwnd:dword;w,h:pdword;vd:pVIDEODATA);stdcall;   
 render  :function (fps:integer):integer;stdcall;
 loadtex :function (fnam:pchar;flg:dword):pinteger;stdcall;  
 reltex  :function (tex:pinteger):boolean;stdcall;    
 getsdc  :function (s:pinteger):HDC;stdcall;       
 relsdc  :procedure(s:pinteger;dc:hdc);stdcall; 
 gsrfsiz :function (s:pinteger;w,h:pdword):boolean;stdcall;  
 maksrf  :function (w,h:dword;tmp:pinteger;tp:integer):pinteger;stdcall;
 fillsr  :function (s:pinteger;x,y,w,h,col:dword):boolean;stdcall;   
 out2D   :procedure;stdcall;
 firstrun:procedure;stdcall;  
 meshop  :procedure(tp:integer;var hMesh:ptypmsh;vis:integer;tex:pinteger;idx:dword;ges:pGROUPEDITSPEC);stdcall;        
 render2D:procedure(hSurf:papinteger;hMesh:pointer;t:pmat;transparent:integer);stdcall; 
 addps   :procedure(tp:integer;es:dword;pss:pPARTICLESTREAMSPEC;hVessel:ohnd;lvl:pdouble;ref,dir:pvec);stdcall;
 blit    :function (tp:integer;tgt:pinteger;tgtx,tgty,tgtw,tgth:dword;src:pinteger;srcx,srcy,srcw,srch,flag:dword):boolean;stdcall;
 keydown :procedure(Key:Word;Shift:byte);stdcall;    
 keyup   :procedure(Key:Word;Shift:byte);stdcall;   
 mouse   :procedure(t:integer;x,y:integer;Shift:byte);stdcall; 
 o2_op   :function (tp:integer;srf:pinteger;x0,y0,x1,y1:integer;fnam:pchar;len:dword):integer;stdcall;
 
 //In
 render_font   :procedure(fn:integer;str:pchar);cdecl; 
 text_width    :function (fn:integer;str:pchar):integer;cdecl; 
 getbase       :function (id:ohnd):pbasetp;cdecl; 
 visop         :procedure(tp:integer;ob:ohnd;vis:pointer);cdecl; 
 vcsurf        :function (tp,n:integer;mf:pointer):pinteger;cdecl;  
 getconfigparam:function (par:dword):pointer;cdecl;      
 getmsurf      :function (tp,p:integer):pinteger;cdecl; 
 font_mode:pinteger;    
 shfps:integer;
end;
pogla_interface=^ogla_interface;  
//############################################################################//
var
ogli:pogla_interface;

//Test for load
initstr:string;  
firstrun:boolean;

net_mx:mutex_typ;
winh:dword;
conl:integer=0;
net_cls:integer=0;
net_stvec_dt:integer=100000;
net_traf:integer=0;
net_traf_in:integer=0;
net_traf_prv:integer=0;
net_traf_avg:double=0;
  
net_cpos,net_ctgt,net_ctgtvel,net_cdir:vec;
net_cm:mat;

net_capr:double;
net_cinvc:integer;

dt62,dt63,dt65,dt66:integer;
          
{$ifndef no_render}
//The scene
scene:oglascene;
sysogla:oglainf;                                 
{$endif}

//Logo
logotx:cardinal;
cfps:integer;
//############################################################################// 
procedure wrcon(dc:hdc;s:string);        
//############################################################################// 
implementation  
//############################################################################//
procedure wrcon(dc:hdc;s:string);
begin
 TextOutA(dc,10,10+conl*16,pchar(s),length(s));
 conl:=conl+1;
end;  
//############################################################################//
begin
end.   
//############################################################################//

