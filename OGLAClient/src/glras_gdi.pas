//############################################################################//
// Orbiter Visualisation Project OpenGL client
// Surface <-> GDI interface
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit glras_gdi;
interface 
uses windows,asys,glgr,opengl1x,dogl,glras_surface;//,bmp,strval;  
//############################################################################//     
type
surfgdi=record
 dc:dword;
 bm:dword;
 bmi:bitmapinfo;
 buf:pointer;
end;
psurfgdi=^surfgdi; 
//############################################################################// 
procedure hdctotex(tex:psurfinfo);
procedure textohdc(tex:psurfinfo);
procedure textohdcclr(tex:psurfinfo);
procedure settodc(tex:psurfinfo);  
//############################################################################// 
implementation      
//############################################################################//
procedure hdctotex(tex:psurfinfo);
var gdi:psurfgdi;
begin      
 if tex=nil then exit; 
 assert(tex.mag=SURFH_MAG); 
 gdi:=tex.gdi;
 if gdi=nil then exit;   
 if gdi.buf=nil then exit;    
 if tex.tex=0 then exit;   
 SelectObject(gdi.dc,gdi.bm);//gdierr:=GetLastError;  
 tex.f_clr:=false;    

 if gl_14_fbo_sup then if tex.d2<>nil then if tex.d2.fbo<>0 then begin
  tex.d2.on2d:=false;          
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,tex.d2.fbo);
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,0,0);
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);
 end;  

 GetDIBits(gdi.dc,gdi.bm,0,tex.h,gdi.buf,gdi.bmi,DIB_RGB_Colors);//gdierr:=GetLastError;     
 //storeBMP32('gdito-'+stri(tex.tex)+'-'+getdatestamp+'.bmp',gdi.buf,tex.w,tex.h,false,false);
 glgr_remake_texbgr(tex.tex,tex.w,tex.h,gdi.buf,false,false,false); 
end;    
//############################################################################// 
procedure textohdc(tex:psurfinfo);     
var gdi:psurfgdi;
begin         
 if tex=nil then exit; 
 assert(tex.mag=SURFH_MAG); 
 gdi:=tex.gdi;
 if gdi=nil then exit;   
 if gdi.buf=nil then exit;   
 if tex.tex=0 then exit;   
 SelectObject(gdi.dc,gdi.bm);//gdierr:=GetLastError;  
                        
 glBindTexture(GL_TEXTURE_2D,tex.tex);
 glGetTexImage(GL_TEXTURE_2D,0,GL_BGRA,GL_UNSIGNED_BYTE,gdi.buf);           
 //storeBMP32('togdi-'+stri(tex.tex)+'-'+getdatestamp+'.bmp',gdi.buf,tex.w,tex.h,false,false);
 SetDIBits(gdi.dc,gdi.bm,0,tex.h,gdi.buf,gdi.bmi,DIB_RGB_Colors);//gdierr:=GetLastError; 
end;   
//############################################################################// 
procedure textohdcclr(tex:psurfinfo);         
var gdi:psurfgdi;
begin       
 if tex=nil then exit; 
 assert(tex.mag=SURFH_MAG); 
 gdi:=tex.gdi;
 if gdi=nil then exit;   
 if gdi.buf=nil then exit;     
 if tex.tex=0 then exit;   
 SelectObject(gdi.dc,gdi.bm);//gdierr:=GetLastError;  
 
 ZeroMemory(gdi.buf,tex.w*tex.h*4);
 SetDIBits(gdi.dc,gdi.bm,0,tex.h,gdi.buf,gdi.bmi,DIB_RGB_Colors);//gdierr:=GetLastError; 
end;      
//############################################################################// 
procedure settodc(tex:psurfinfo);          
var gdi:psurfgdi;
begin        
 if tex=nil then exit; 
 assert(tex.mag=SURFH_MAG); 
 gdi:=tex.gdi;
 if gdi<>nil then exit;    
 if tex.tex=0 then exit;    
 new(gdi); 
 gdi.dc:=0;   
 getmem(gdi.buf,tex.w*tex.h*4);                    
 fillchar(gdi.buf^,tex.w*tex.h*4,255);
        
 gdi.dc:=CreateCompatibleDC(gwin.dc);//gdierr:=GetLastError;  
 gdi.bm:=CreateBitmap(tex.w,tex.h,1,32,gdi.buf);//gdierr:=GetLastError;         
 SelectObject(gdi.dc,gdi.bm);//gdierr:=GetLastError;  

 ZeroMemory(@gdi.bmi.bmiHeader,sizeof(BITMAPINFOHEADER));
 gdi.bmi.bmiHeader.biSize       :=sizeof(BITMAPINFOHEADER);
 gdi.bmi.bmiHeader.biWidth      :=tex.w;
 gdi.bmi.bmiHeader.biHeight     :=-tex.h;
 gdi.bmi.bmiHeader.biPlanes     :=1;
 gdi.bmi.bmiHeader.biCompression:=BI_RGB;
 gdi.bmi.bmiHeader.biBitCount   :=32;  
 tex.gdi:=gdi;

	SetBkMode(gdi.dc,TRANSPARENT); // transparent text background
	SelectObject(gdi.dc,GetStockObject(NULL_BRUSH)); // no fill
	SelectObject(gdi.dc,GetStockObject(NULL_PEN));   // no outline
end;  
//############################################################################//
begin
end. 
//############################################################################//
