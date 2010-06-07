//############################################################################//
// Orbiter Visualisation Project OpenGL client
// Texture and raster basic tools
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit glras_surface;
interface   
uses sysutils,asys,grph,log,dds,strval{$ifndef no_render},glgr,grplib{$endif};
//############################################################################//     
const 
SURFH_MAG=$48567392;
type
surfd2=record
 fbo:cardinal;
 on2d:boolean;
 curx,cury,prevx,prevy,txalign,txvalign:integer;
 brushcl,pencl,textcl,textbckcl:crgba;
 font,font_height:integer;
end;
psurfd2=^surfd2;
surfinfo=record
 mag:dword;
 used,f_clr,global,toload,xmit,compressed,smooth,mipmap,additive:boolean;
 tex:cardinal; 
 w,h,ckey,id:cardinal;
 uc:integer; 
 srcn:string[255];
    
 gdi:pointer;
 d2:psurfd2;
end;  
psurfinfo=^surfinfo;

//############################################################################//    
//Texture repository
var
texres:array of psurfinfo;
texcnt:integer=0;
orb_texdir,orb_mshdir:string;

//Screen surface
scrsrf:surfinfo; 

//In  
render_font:procedure(fn:integer;str:pchar;mode:integer);cdecl; 
text_width:function(fn:integer;str:pchar):integer;cdecl; 
//############################################################################//  
// "Texture manager"      
function txadd(tex:psurfinfo):integer;        
function txget(tex:pinteger):psurfinfo;
function txfind(nam:string):integer;   
function get_texture_file_by_name(fn:string):string;    
function create_surface(fnam:string;w,h:integer;global,compressed,smooth,mipmap:boolean):integer;   
function create_screen_surface(w,h:integer):integer;
//############################################################################//  
implementation      
//############################################################################//
function get_texture_file_by_name(fn:string):string;
var i:integer;
begin
 result:='';
 for i:=1 to length(fn) do if fn[i]='\' then fn[i]:='/';
 
      if fileexists(orb_texdir+'/' +fn)           then fn:=orb_texdir+'/' +fn
 else if fileexists(orb_texdir+'2/'+fn)           then fn:=orb_texdir+'2/'+fn
 else if fileexists(orb_texdir+'/' +lowercase(fn))then fn:=orb_texdir+'/' +lowercase(fn)
 else if fileexists(orb_texdir+'2/'+lowercase(fn))then fn:=orb_texdir+'2/'+lowercase(fn);
 
 if not fileexists(fn)then fn:='';
 result:=fn;
end;
//############################################################################//
// "Textures manager" 
//############################################################################//
function txget(tex:pinteger):psurfinfo;
var p:pointer;
x,y,ct,len:integer;
n:string;
begin result:=nil;try
 if tex=nil then exit;
 if(tex^<0)or(tex^>=texcnt)then exit;
 if texres[tex^]=nil then exit;
 if not texres[tex^].used then exit; 
 assert(texres[tex^].mag=SURFH_MAG);
 
 result:=texres[tex^];
 if result<>nil then if result.toload then begin
  result.toload:=false;
  {$ifndef no_render}
  n:=get_texture_file_by_name(trim(string(result.srcn)));
  if n='' then if trim(string(result.srcn))<>'' then wr_log('oglctex','No texture "'+trim(string(result.srcn))+'"');
  
  if result.srcn='' then begin
   glgr_makeblank_tex(result.tex,result.w,result.h,false,false,false)
  end else if n<>'' then begin
       
   if isdds_comp(n) and(result.compressed and gl_comp_sup) then begin
    loaddds(n,x,y,p,ct,len,true);
    glgr_make_texfcomp(result.tex,x,y,p,ct,len,true,result.smooth,true);
   end else begin    
    if loadbitmap(n,x,y,p)=nil then begin if fileexists(n) then wr_log('oglctex','Unloadable texture "'+n+'"');exit;end;     
    glgr_make_tex(result.tex,x,y,p,result.compressed,result.smooth,true,result.mipmap);
   end; 
   //wr_dbg('txget','result.tex='+stri(result.tex)+' fnam='+result.srcn);  
   result.w:=x;
   result.h:=y;  
   freemem(p);   
  end;
  {$endif}
 end;   
 except stderr('OGLCTEX','Error in txget'); end; 
end;           
//############################################################################//
function txadd(tex:psurfinfo):integer;
var i,c:integer;
begin result:=-1;try
 if tex=nil then exit; 
 assert(tex.mag=SURFH_MAG);
 c:=-1;
 for i:=0 to texcnt-1 do if texres[i]<>nil then if not texres[i].used then begin c:=i; break; end;
 if c=-1 then for i:=0 to texcnt-1 do if texres[i]=nil then begin c:=i; break; end;
 if c=-1 then begin
  setlength(texres,texcnt*2+1);
  for i:=texcnt to texcnt*2-1 do texres[i]:=nil;
  c:=texcnt;
  texcnt:=texcnt*2+1;
 end;
 texres[c]:=tex;
 result:=c;     
 except stderr('OGLCTEX','Error in txadd'); end; 
end;    
//############################################################################//
function txfind(nam:string):integer;
var i:integer;
begin result:=-1; try
 for i:=0 to texcnt-1 do if texres[i]<>nil then if texres[i].used then if texres[i].srcn=nam then begin 
  assert(texres[i].mag=SURFH_MAG);
  result:=i;
  exit;
 end;      
 except stderr('OGLCTEX','Error in txfind (nam='+nam+')'); end; 
end;  
//############################################################################//
function create_surface(fnam:string;w,h:integer;global,compressed,smooth,mipmap:boolean):integer;
var srf:psurfinfo;
begin
 new(srf);    
 srf.used:=true; 
 srf.tex:=notx; 
 srf.d2:=nil;
 srf.gdi:=nil;
 srf.mag:=SURFH_MAG;
 srf.srcn:=fnam; 
 srf.uc:=1;  
 srf.f_clr:=false; 
 srf.additive:=false;  
 srf.global:=global;    
 srf.compressed:=compressed; 
 srf.smooth:=true;
 srf.mipmap:=false; 
 srf.toload:=true; 
 srf.ckey:=$13245567;   
 srf.w:=w;
 srf.h:=h; 
 srf.xmit:=true;   
 result:=txadd(srf);  
end;
//############################################################################//
function create_screen_surface(w,h:integer):integer;
var srf:psurfinfo;
begin
 srf:=@scrsrf;
     
 srf.used:=true;   
 srf.tex:=0; 
 srf.gdi:=nil;
 srf.mag:=SURFH_MAG;
 srf.srcn:=''; 
 srf.uc:=1;  
 srf.f_clr:=false; 
 srf.additive:=false;  
 srf.global:=false;    
 srf.compressed:=false; 
 srf.smooth:=true;
 srf.mipmap:=false; 
 srf.toload:=false; 
 srf.ckey:=$13245567;   
 srf.w:=w;
 srf.h:=h; 
 srf.xmit:=false;   

 new(srf.d2);
 srf.d2.on2d:=false; 
 srf.d2.fbo:=0;  
 srf.d2.font_height:=1;
 srf.d2.curx:=0;
 srf.d2.cury:=0;  
 srf.d2.prevx:=0;
 srf.d2.prevy:=0;
 srf.d2.font:=-1;
 srf.d2.font_height:=1;
 srf.d2.brushcl:=gclaz;
 srf.d2.pencl:=gclaz;
 srf.d2.textcl:=gclwhite;
 srf.d2.textbckcl:=gclaz;  
 srf.d2.on2d:=true; 
 srf.d2.txalign:=0;
 srf.d2.txvalign:=0;
   
 result:=txadd(srf); 
end;
//############################################################################//
begin
end. 
//############################################################################//
