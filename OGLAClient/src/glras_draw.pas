//############################################################################//
// Orbiter Visualisation Project OpenGL client
// Raster functions
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit glras_draw;
interface
uses sysutils,asys,strval,maths,log,glras_surface,opengl1x,grph,glgr;//,dogl;                         
//############################################################################// 
function o2_op(tp:integer;srf:pinteger;x0,y0,x1,y1:integer;fnam:pchar;len:dword):integer;stdcall;
function oglc_blit(tp:integer;tgt:psurfinfo;tgtx,tgty,tgtw,tgth:dword;src:psurfinfo;srcx,srcy,srcw,srch,flag:dword):boolean;
procedure clrsrf(s:pinteger;x,y,w,h,col:dword);  
procedure decompress_srf(s:psurfinfo); 
//############################################################################// 
implementation
//############################################################################// 
//FIXME: Single-threaded...
var fbonow:dword=0;           
//############################################################################// 
function set_fbo(tgt:psurfinfo;fbo:dword):boolean;
begin
 result:=false;
 if tgt<>nil then begin  
  if tgt.tex=0 then exit;    
  if tgt.tex=notx then exit;   
  assert(tgt.mag=SURFH_MAG);
  if not gl_14_fbo_sup then exit;  
  //if tgt.compressed then dbgtolog('o2_op','compressed texture operations ('+tgt.srcn+')');   
  if tgt.compressed then decompress_srf(tgt);
  if fbo=0 then fbo:=tgt.d2.fbo;
  if fbo=0 then begin glGenFramebuffersext(1,@tgt.d2.fbo);fbo:=tgt.d2.fbo;end;
  //tgt.f_clr:=false; //??    
  if fbonow<>fbo then begin  

   glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,0,0); 
   glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,fbo);    
   glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,tgt.tex,0);    


   if glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)<>GL_FRAMEBUFFER_COMPLETE_EXT then begin   
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,0,0); 
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);  
    fbonow:=0;   
    exit;   
   end;       
         
   fbonow:=fbo;    
   glViewport(0,0,tgt.w,tgt.h);
   glMatrixMode(GL_PROJECTION);glLoadIdentity;  
   glOrtho(-0.5,tgt.w-0.5,-0.5,tgt.h-0.5,-1,1); 
   glMatrixMode(GL_MODELVIEW);glLoadIdentity; 
   {
   glEnable(GL_TEXTURE_2D);  
   glDisable(GL_LIGHTING); 
   gldisable(GL_DEPTH_TEST);      
   glBindTexture(GL_TEXTURE_2D,tgt.tex); 
   glBegin(GL_QUADS);
    glColor4f(1,1,1,1); 
    glTexCoord2f(0,0); glVertex2f(0,0);     
    glTexCoord2f(1,0); glVertex2f(0+tgt.w,0);   
    glTexCoord2f(1,1); glVertex2f(0+tgt.w,0+tgt.h);   
    glTexCoord2f(0,1); glVertex2f(0,0+tgt.h);
   glEnd;  
   glBindTexture(GL_TEXTURE_2D,0);
   }
  end;
 end else begin  
  tgt:=@scrsrf;
  assert(tgt.mag=SURFH_MAG);        
  if fbonow<>0 then begin
   if gl_14_fbo_sup then begin 
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,0,0); 
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0); 
    fbonow:=0;   
   end;  
   glViewport(0,0,tgt.w,tgt.h);
   glMatrixMode(GL_PROJECTION);glLoadIdentity;  
   //glOrtho(-0.5,tgt.w-0.5,tgt.h-0.5,-0.5,-1,1);  
   glOrtho(-0.5,tgt.w-0.5,-0.5,tgt.h-0.5,-1,1); 
   glMatrixMode(GL_MODELVIEW);glLoadIdentity; 
  end;
 end;  
 result:=true;
 if tgt<>nil then if tgt.tex<>0 then if tgt.f_clr then begin   
  glClearColor(0,0,0,0);     
  glClear(GL_COLOR_BUFFER_BIT);   
  tgt.f_clr:=false;   
 end;
 glenable(GL_BLEND);
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);  
 gldisable(GL_DEPTH_TEST); 
 gldisable(GL_TEXTURE_2D);
 gldisable(GL_LIGHTING);
 gldisable(GL_CULL_FACE);
 gldisable(GL_STENCIL_TEST);
 glHint(GL_POINT_SMOOTH_HINT,GL_FASTEST); 
end;            
//############################################################################// 
procedure clear_fbo(fbo:dword);
begin
 if gl_14_fbo_sup then begin
  if fbo<>0 then glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,fbo);
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,0,0);
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);    
  fbonow:=0; 
 end;  
end;              
//############################################################################// 
//############################################################################// 
procedure decompress_srf(s:psurfinfo);
var sz:integer;
buf:pointer;
begin
 if s=nil then exit;     
 if not s.compressed then exit;
 assert(s.mag=SURFH_MAG); 
 
 s.compressed:=false;
 
 //dbgtolog('decompress_srf','decompressed texture ('+s.srcn+')');   
 sz:=s.w*s.h*4;
 getmem(buf,sz);
        
 if s.d2<>nil then if s.d2.fbo<>0 then begin
  clear_fbo(s.d2.fbo);
  s.d2.on2d:=false; 
 end;
          
 glBindTexture(GL_TEXTURE_2D,s.tex);
 glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE,buf);
 glgr_remake_tex(s.tex,s.w,s.h,buf,false,false,true);  
 freemem(buf); 
end;          
//############################################################################// 
procedure set_srf_ckey(s:psurfinfo;nkey:dword);
var i,sz:integer;
buf:pdworda;
begin  
 if s=nil then exit;     
 assert(s.mag=SURFH_MAG); 
 if s.tex=0 then exit;
 if s.ckey=nkey then exit;

 sz:=s.w*s.h*4;
 getmem(buf,sz);
        
 if s.d2<>nil then if s.d2.fbo<>0 then begin
  clear_fbo(s.d2.fbo);
  s.d2.on2d:=false; 
 end;
          
 glBindTexture(GL_TEXTURE_2D,s.tex);
 glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE,buf);
 for i:=0 to s.h*s.w-1 do begin
  if(buf[i] and $00FFFFFF)=s.ckey then buf[i]:=buf[i] and $FFFFFF+$FF000000;
  if(buf[i] and $00FFFFFF)=nkey then buf[i]:=buf[i] and $FFFFFF;
 end;
 glgr_remake_tex(s.tex,s.w,s.h,buf,false,false,true);  
 freemem(buf);  
 s.ckey:=nkey;
end;
//############################################################################// 
procedure clrsrf(s:pinteger;x,y,w,h,col:dword);
var sr:psurfinfo;
begin 
 sr:=txget(s);                    
 if sr<>nil then begin
  if sr.tex=0 then exit;    
  if sr.tex=notx then exit;   
  if not gl_14_fbo_sup then exit;  
  assert(sr.mag=SURFH_MAG);     
 end else if s=nil then begin
  sr:=@scrsrf;  
 end else exit;
  
 if(x=0)and(y=0)and(w=0)and(h=0)then begin
  w:=sr.w;
  h:=sr.h;
 end;

 //FIXME: Crutch - HUD additive
 if not sr.additive then col:=col+$FF000000;                     
 //if col<>0 then col:=col+$FF000000;   
 o2_op(99,s,0,0,0,0,nil,0);  
 glEnable(GL_SCISSOR_TEST);
 glScissor(x,y,w-1,h-1);
 glClearColor((col and $FF)/255,((col and $FF00) shr 8)/255,((col and $FF0000) shr 16)/255,((col and $FF000000) shr 24)/255);     
 glClear(GL_COLOR_BUFFER_BIT);
 glDisable(GL_SCISSOR_TEST);   
 glClearColor(1,1,1,1);   
 o2_op(98,s,0,0,0,0,nil,0);    
end;     
//############################################################################//
//############################################################################//  
//############################################################################// 
function get2dsys(s:psurfinfo):boolean;
begin
 result:=false;    
 if not set_fbo(s,0)then exit;
 if s=nil then s:=@scrsrf;
 assert(s.mag=SURFH_MAG);  
 
 
 s.d2.curx:=0;
 s.d2.cury:=0;  
 s.d2.prevx:=0;
 s.d2.prevy:=0;
 s.d2.font:=-1;
 s.d2.font_height:=1;
 s.d2.brushcl:=gclaz;
 s.d2.pencl:=gclaz;
 s.d2.textcl:=gclwhite;
 s.d2.textbckcl:=gclaz;  
 s.d2.on2d:=true; 
 s.d2.txalign:=0;
 s.d2.txvalign:=0;
 result:=true;   
end;
//############################################################################// 
procedure free2dsys(s:psurfinfo);
begin          
 if s=nil then exit;
 if s.tex=0 then exit;
 assert(s.mag=SURFH_MAG);
 if s.d2=nil then exit;
 s.d2.on2d:=false;
 clear_fbo(0);
 glViewport(0,0,scrx,scry);
 glFlush;
end; 
//############################################################################//  
//############################################################################// 
function dbg_xtex(srf:psurfinfo):string;
begin
 if srf=nil then result:='nil' else result:=stri(srf.tex)+'('+srf.srcn+')';
end;
//############################################################################// 
function o2o_dbgtxt(tp:integer;tgt:psurfinfo;x0,y0,x1,y1:integer;fnam:pchar;len:dword):string;  
var i:integer;
pt:pivec2ar;
begin
 result:=dbg_xtex(tgt)+':';      
 case tp of
  99:result:=result+'get2dsys';
  98:result:=result+'free2dsys';
  0:result:=result+'put_text('+stri(x0)+','+stri(y0)+','+fnam+')';
  1:result:=result+'gotoxy('+stri(x0)+','+stri(y0)+')';
  2:result:=result+'lineto('+stri(x0)+','+stri(y0)+')';
  3:result:=result+'line('+stri(x0)+','+stri(y0)+','+stri(x1)+','+stri(y1)+')';
  4:result:=result+'putsqr2D('+stri(x0)+','+stri(y0)+','+stri(x1)+','+stri(y1)+')';
  5:result:=result+'wrellipse2D('+stri(x0)+','+stri(y0)+','+stri(x1)+','+stri(y1)+')';  
  6:begin
   pt:=pointer(len);
   result:=result+'Polygon(';
   for i:=0 to x0-1 do result:=result+'['+stri(pt[i].x)+','+stri(pt[i].y)+']';
   result:=result+')'; 
  end;
  7:begin                  
   pt:=pointer(len);
   result:=result+'Polyline(';
   for i:=0 to x0-1 do result:=result+'['+stri(pt[i].x)+','+stri(pt[i].y)+']';
   result:=result+')'; 
  end;  
  8:result:=result+'wrpix2D('+stri(x0)+','+stri(y0)+')';
  11:result:=result+'pen_color('+stri(len and $FF)+','+stri((len and $FF00) shr 8)+','+stri((len and $FF0000) shr 16)+')';
  12:result:=result+'background_color('+stri(len and $FF)+','+stri((len and $FF00) shr 8)+','+stri((len and $FF0000) shr 16)+')';
  13:result:=result+'color_key('+stri(len and $FF)+','+stri((len and $FF00) shr 8)+','+stri((len and $FF0000) shr 16)+')';
  14:result:=result+'goto('+stri(x0)+','+stri(y0)+')';
  15:result:=result+'txt_color('+stri(len and $FF)+','+stri((len and $FF00) shr 8)+','+stri((len and $FF0000) shr 16)+')';
  16:result:=result+'txt_bck_color('+stri(len and $FF)+','+stri((len and $FF00) shr 8)+','+stri((len and $FF0000) shr 16)+')';
  17:result:=result+'gen_font('+stri(x0)+',['+stri(len and $FF)+','+stri((len and $FF00) shr 8)+','+stri((len and $FF0000) shr 16)+'])';
  18:result:=result+'text_len';//+fnam+')';
  19:result:=result+'text_hei';    
  20:result:=result+'align('+stri(x0)+','+stri(y0)+')';
  else result:=result+'etc('+stri(tp)+')';
 end;   
end; 
//############################################################################// 
function o2_op(tp:integer;srf:pinteger;x0,y0,x1,y1:integer;fnam:pchar;len:dword):integer;stdcall;
var pt:pivec2ar;
i,j,c,o,ho:integer; 
tgt:psurfinfo;
on2,isnil:boolean;
begin pt:=nil;
 result:=0;  
          
 //if not firstrun then if oapiCameraInternal and (oapiCockpitMode=COCKPIT_VIRTUAL) then gl_amb:=zvec;
 
 tgt:=txget(srf); 
 if(tgt=nil)and(srf<>nil)then exit;
 isnil:=tgt=nil;
 
 //wr_log('o2_op',o2o_dbgtxt(tp,tgt,x0,y0,x1,y1,fnam,len));   

 if tp<10 then if tgt<>nil then if not gl_14_fbo_sup then exit;
 
 if tgt<>nil then if tgt.d2=nil then begin
  if tgt.w<2 then exit;
  if tgt.h<2 then exit;   
  if tgt.tex=0 then exit;    
  if tgt.tex=notx then exit;  
  assert(tgt.mag=SURFH_MAG);  
  new(tgt.d2);
  tgt.d2.on2d:=false; 
  tgt.d2.fbo:=0;
 end; 

 on2:=false;
 if tgt<>nil then on2:=tgt.d2.on2d;
 if tp<10 then if(on2)or(tgt=nil)then if not set_fbo(tgt,0) then exit;    
 if tgt=nil then if tp<98 then if not set_fbo(tgt,0) then exit;
 if tgt=nil then if tp<98 then tgt:=@scrsrf;
 
 if(tp>=6)and(tp<=7)then pt:=pointer(len);
 case tp of 
  99:get2dsys(tgt);
  98:free2dsys(tgt);
  
  0:begin
   gldisable(GL_Lighting);                      
   glColor4f(tgt.d2.textcl[0]/255,tgt.d2.textcl[1]/255,tgt.d2.textcl[2]/255,tgt.d2.textcl[3]/255);   
   o:=0;
   ho:=0;

        if tgt.d2.txalign=0 then o:=0
   else if tgt.d2.txalign=1 then o:=text_width(tgt.d2.font,fnam) div 2
   else if tgt.d2.txalign=2 then o:=text_width(tgt.d2.font,fnam);
        if tgt.d2.txvalign=0 then ho:=0
   else if tgt.d2.txvalign=1 then ho:=tgt.d2.font_height div 2
   else if tgt.d2.txvalign=2 then ho:=tgt.d2.font_height;

   glRasterPos3f(tgt.d2.prevx+x0-o,tgt.d2.prevy+y0+abs(tgt.d2.font_height-ho),0);
   render_font(tgt.d2.font,fnam,ord(isnil)*99);           
  end;
  1:begin tgt.d2.curx:=x0;tgt.d2.cury:=y0;end;
  //Nice
  //2:begin wrline2D(tgt.d2.prevx+tgt.d2.curx ,tgt.d2.prevy+tgt.d2.cury ,tgt.d2.prevx+x0+1,tgt.d2.prevy+y0+1,tgt.d2.pencl);tgt.d2.curx:=x0;tgt.d2.cury:=y0;end;
  //3:begin wrline2D(tgt.d2.prevx+x0          ,tgt.d2.prevy+y0          ,tgt.d2.prevx+x1+1,tgt.d2.prevy+y1+1,tgt.d2.pencl);tgt.d2.curx:=x1;tgt.d2.cury:=y1;end;
  //4:      putsqr2D(tgt.d2.prevx+min2i(x0,x1),tgt.d2.prevy+min2i(y0,y1),abs(x1-x0)     +1,abs(y1-y0)     +1,tgt.d2.brushcl,tgt.d2.pencl);
  //Orbiter
  2:begin wrline2D(tgt.d2.prevx+tgt.d2.curx ,tgt.d2.prevy+tgt.d2.cury +1,tgt.d2.prevx+x0  ,tgt.d2.prevy+y0+1,tgt.d2.pencl);tgt.d2.curx:=x0;tgt.d2.cury:=y0;end;
  3:begin wrline2D(tgt.d2.prevx+x0          ,tgt.d2.prevy+y0          +1,tgt.d2.prevx+x1  ,tgt.d2.prevy+y1+1,tgt.d2.pencl);tgt.d2.curx:=x1;tgt.d2.cury:=y1;end;
  4:      putsqr2D(tgt.d2.prevx+min2i(x0,x1),tgt.d2.prevy+min2i(y0,y1)+1,abs(x1-x0)     -1,abs(y1-y0)     -1,tgt.d2.brushcl,tgt.d2.pencl);
  5:wrellipse2D(tgt.d2.prevx+x0,tgt.d2.prevy+y0,tgt.d2.prevx+x1,tgt.d2.prevy+y1,tgt.d2.pencl);
  6:begin  
   gldisable(GL_CULL_FACE);
   glBindTexture(GL_TEXTURE_2D,0);     
   glBegin(GL_TRIANGLE_FAN);
    glColor4f(tgt.d2.brushcl[0]/255,tgt.d2.brushcl[1]/255,tgt.d2.brushcl[2]/255,tgt.d2.brushcl[3]/255); 
    for i:=0 to x0-1 do glVertex2f(tgt.d2.prevx+pt[i].x,tgt.d2.prevy+pt[i].y);   
   glEnd;       
   for i:=0 to x0-2 do wrline2D(tgt.d2.prevx+pt[i].x,tgt.d2.prevy+pt[i].y,tgt.d2.prevx+pt[i+1].x,tgt.d2.prevy+pt[i+1].y,tgt.d2.pencl);
  end;
  7:for i:=0 to x0-2 do wrline2D(tgt.d2.prevx+pt[i].x,tgt.d2.prevy+pt[i].y,tgt.d2.prevx+pt[i+1].x,tgt.d2.prevy+pt[i+1].y,tgt.d2.pencl);
  8:wrpix2D(tgt.d2.prevx+x0,tgt.d2.prevy+y0,gclred);   //FIXME: color?

  11:tgt.d2.pencl:=tcrgba(len and $FF,(len and $FF00) shr 8,(len and $FF0000) shr 16,255*ord(((len and $FFFFFF)<>(tgt.ckey and $FFFFFF))and(x1=0)));
  12:tgt.d2.brushcl:=tcrgba(len and $FF,(len and $FF00) shr 8,(len and $FF0000) shr 16,255*ord(((len and $FFFFFF)<>(tgt.ckey and $FFFFFF))and(x1=0)));
  13:set_srf_ckey(tgt,len);
  14:begin tgt.d2.prevx:=x0;tgt.d2.prevy:=y0;end;
  15:tgt.d2.textcl:=tcrgba(len and $FF,(len and $FF00) shr 8,(len and $FF0000) shr 16,255);
  16:tgt.d2.textbckcl:=tcrgba(len and $FF,(len and $FF00) shr 8,(len and $FF0000) shr 16,255);
  17:begin tgt.d2.font_height:=len;tgt.d2.font:=x0;end;
  18:if tgt.d2.font<>-1 then result:=text_width(tgt.d2.font,pchar(copy(fnam,1,x0)));
  19:if tgt.d2.font<>-1 then result:=abs(tgt.d2.font_height)+(text_width(tgt.d2.font,'askdbv76587yuKJVHSKJFGIBREGF68') div 30) shl 16;    
  20:begin tgt.d2.txalign:=x0;tgt.d2.txvalign:=y0;end;
 end;   
end;  
//############################################################################// 
//############################################################################// 
//############################################################################// 
//############################################################################// 
//Texture blitting
function oglc_blit(tp:integer;tgt:psurfinfo;tgtx,tgty,tgtw,tgth:dword;src:psurfinfo;srcx,srcy,srcw,srch,flag:dword):boolean;
begin result:=false; try      
 //wr_log('oglc_blit','begin('+stri(tp)+','+dbg_xtex(src)+' to '+dbg_xtex(tgt)+')');   
  
 if src=nil then exit;   
 assert(src.mag=SURFH_MAG); 
 if tgt<>nil then if not gl_14_fbo_sup then exit;  
     
 //if not firstrun then if oapiCameraInternal and (oapiCockpitMode=COCKPIT_VIRTUAL) then gl_amb:=zvec;  
 
 if gl_14_fbo_sup then if rndfbo=0 then glGenFramebuffersext(1,@rndfbo); 
 if not set_fbo(tgt,rndfbo) then exit;   
 if tgt=nil then tgt:=@scrsrf;
 if src.ckey<>$13245567 then glenable(GL_BLEND) else gldisable(GL_BLEND); 
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);  
 gldisable(GL_CULL_FACE);   
 gldisable(GL_STENCIL_TEST);   

 
 //glgr_surf_screenshot(src.tex,src.w,src.h);
 try
 case tp of
  0:puttx2Dsh(src.tex,tgtx,tgty,src.w,src.h,0,0,1,1,false,gclwhite);
  1:puttx2Dsh(src.tex,tgtx,tgty,srcw,srch,srcx/src.w,srcy/src.h,(srcx+srcw)/src.w,(srcy+srch)/src.h,false,gclwhite);
  2:puttx2Dsh(src.tex,tgtx,tgty,tgtw,tgth,srcx/src.w,srcy/src.h,(srcx+srcw)/src.w,(srcy+srch)/src.h,false,gclwhite);
 end;        
 except 
  if tgt<>nil then wr_log('oglc_blit','puttx2Dsh(fail tgt.srcn='+tgt.srcn+')')
              else wr_log('oglc_blit','puttx2Dsh(fail tgt.srcn=nil)');
 end;        
 result:=true;   
         
 clear_fbo(0); 
 
 glFlush;  
 //wr_log('oglc_blit','end');  
 except on ex:exception do stderr('OGLTEX','(oglc_blit) '+ex.message+' (hc='+stri(ex.helpcontext)+')'); end;
end;   
//############################################################################//
begin
end. 
//############################################################################//
