//############################################################################//
// GLGR OpenGL windowing setup
// Released under GNU General Public License
// Made in 2007-2010 by Artyom Litvinovich
//############################################################################//
unit dogl;
interface   
//############################################################################//
//############################################################################//
//############################################################################//
uses sysutils,asys,grph,maths,strval,bmp,
{$ifdef win32}
windows,messages,opengl1x
{$else}
gl,glu,glx,glext,glut,tim
{$endif}
;
//############################################################################//
type glwin=record 
 {$ifdef win32}
 wnd:HWND;
 dc:HDC;  
 glrc:HGLRC;
 {$endif}
 hnd:integer;
 fs,caps:boolean;
 
 name:string;    
 fpsc,cfps:integer;
 wid,hei,pd:integer;

 eft,lds:cardinal;
 pt:double;
 
 pks:array[0..255+2]of boolean;  
 mbtns:array[0..4]of boolean;

 frmOnTimer:procedure(ct,dt:double);
 frmevent:procedure(evt,x,y:integer;key:word;shift:tshiftstate);
end;
pglwin=^glwin;
//############################################################################//
var
doglon:boolean;
xres,yres:integer;
//glw:pglwin;
gwin:glwin;
doglrdr:boolean=true;
gl_dt:integer;  
gvsync:boolean=false;
//############################################################################//
procedure killoglwin(glw:pglwin); 
function createoglwin(gwin:pglwin):boolean;overload;   
function createoglwin(gwin:pglwin;xs,ys:integer;fs:boolean;frm,tim:pointer;nm:string):boolean;overload;
{$ifdef win32}
function createogl(hdc:thandle;wid,hei,pd:integer;var glrc:HGLRC):boolean;   
function createogl_offscreen:boolean;overload;
function setoglwin(glw:pglwin):boolean;        
procedure win32procmsg; 
{$endif}
procedure doglmain;     
procedure doglswap(wnd:pglwin); 
//############################################################################//
procedure glgr_set3d(glw:pglwin;ap,l,h:double);
procedure glgr_set2d(glw:pglwin);                    
procedure glgr_set_unit2d(glw:pglwin);
procedure glgr_setdefault3d(glw:pglwin;xres:integer=0;yres:integer=0);  
procedure glgr_screenshot(win:pglwin);  
procedure glgr_vsync(en:boolean);      
//############################################################################//
implementation  
//############################################################################//
var
{$ifdef win32}
wir:array of hwnd;
wer:array of pointer;
{$else}
cshift:tshiftstate;  
{$endif}
//############################################################################//
const
FPS_TIMER    =1;                                             // Timer to calculate FPS
FPS_INTERVAL =1000;                                          // Calculate FPS every 1000 ms
DRAW_TIMER   =2;                                             // Timer to calculate FPS
DRAW_INTERVAL=1;                                          // Calculate FPS every 1000 ms
//############################################################################//
//############################################################################// 
{$ifdef win32}
function createogl(hdc:thandle;wid,hei,pd:integer;var glrc:HGLRC):boolean;
var pf:GLuint;
pfd:PIXELFORMATDESCRIPTOR;
begin
 result:=true;
 loadopengl;
        
 with pfd do begin
  nSize          :=sizeof(TPIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
  nVersion       :=1;                              // The version of this data structure
  dwFlags        :=PFD_DRAW_TO_WINDOW or           // Buffer supports drawing to window
                   PFD_SUPPORT_OPENGL or           // Buffer supports OpenGL drawing
                   PFD_DOUBLEBUFFER;               // Supports double buffering
  iPixelType     :=PFD_TYPE_RGBA;                  // RGBA color format
  cColorBits     :=pd;                             // OpenGL color depth
  cRedBits       :=0;                              // Number of red bitplanes
  cRedShift      :=0;                              // Shift count for red bitplanes
  cGreenBits     :=0;                              // Number of green bitplanes
  cGreenShift    :=0;                              // Shift count for green bitplanes
  cBlueBits      :=0;                              // Number of blue bitplanes
  cBlueShift     :=0;                              // Shift count for blue bitplanes
  cAlphaBits     :=0;                              // Not supported
  cAlphaShift    :=0;                              // Not supported
  cAccumBits     :=0;                              // No accumulation buffer
  cAccumRedBits  :=0;                              // Number of red bits in a-buffer
  cAccumGreenBits:=0;                              // Number of green bits in a-buffer
  cAccumBlueBits :=0;                              // Number of blue bits in a-buffer
  cAccumAlphaBits:=0;                              // Number of alpha bits in a-buffer
  cDepthBits     :=32;                             // Specifies the depth of the depth buffer
  cStencilBits   :=16;                             // Stencil buffer
  cAuxBuffers    :=0;                              // Not supported
  iLayerType     :=PFD_MAIN_PLANE;                 // Ignored
  bReserved      :=0;                              // Number of overlay and underlay planes
  dwLayerMask    :=0;                              // Ignored
  dwVisibleMask  :=0;                              // Transparent color of underlay plane
  dwDamageMask   :=0;                              // Ignored
 end;
   
 pf:=choosepixelformat(hdc,@pfd);
 if pf=0 then begin
  messagebox(0,'Unable to find a suitable pixel format','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;
         
 if not setpixelformat(hdc,pf,@pfd) then begin
  messagebox(0,'Unable to set the pixel format','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;
    
 glrc:=wglCreateContext(hdc);
 if glrc=0 then begin
  messagebox(0,'Unable to create an OpenGL rendering context','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;

 if not wglmakecurrent(hdc,glrc) then begin
  messagebox(0,'Unable to activate OpenGL rendering context','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;

 glMatrixMode(GL_PROJECTION); glLoadIdentity; 
 glViewport(0,0,wid,hei);
 gluPerspective(45,wid/hei,0.1,10000000);

 glMatrixMode(GL_MODELVIEW); glLoadIdentity;

 glEnable(GL_TEXTURE_2D);
 glShadeModel(GL_SMOOTH);
 glClearColor(0,0,0.5,1);
 glClearDepth(1);
 glEnable(GL_DEPTH_TEST);
 glDepthFunc(GL_LEQUAL);
 glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);
end;  
{$endif}
//############################################################################//
//############################################################################//
{$ifdef win32}
procedure resoglwin(glw:pglwin);
var odc:HDC;oglrc:HGLRC;
begin
 oglrc:=wglGetCurrentContext;
 odc:=wglGetCurrentDC;
 wglMakeCurrent(glw^.DC,glw^.glrc);

 if (glw^.hei=0)then glw^.hei:=1;               
 scrx:=glw^.wid;
 scry:=glw^.hei;  
 
 glMatrixMode(GL_PROJECTION); glLoadIdentity;      
 glViewport(0,0,glw^.wid,glw^.hei);
 gluPerspective(45,glw^.wid/glw^.hei,0.1,10000000);
                    
 glMatrixMode(GL_MODELVIEW); glLoadIdentity;

 wglMakeCurrent(odc,oglrc);
 xres:=glw^.wid;
 yres:=glw^.hei;
end; 
{$else}  
procedure resoglwin(wid,hei:integer);cdecl;
begin;      
 glw^.hei:=hei;glw^.wid:=wid;
 if (glw^.hei=0)then glw^.hei:=1;            
 scrx:=wid;
 scry:=hei;  
 
 glMatrixMode(GL_PROJECTION); glLoadIdentity;      
 glViewport(0,0,glw^.wid,glw^.hei);
 gluPerspective(45*180/pi,glw^.wid/glw^.hei,0.1,10000000);
                    
 glMatrixMode(GL_MODELVIEW);glLoadIdentity;

 xres:=glw^.wid;
 yres:=glw^.hei;
end;   
{$endif}
//############################################################################//
//############################################################################//
procedure killoglwin(glw:pglwin);
begin
 {$ifdef win32}
 if glw^.fs then begin
  ChangeDisplaySettings(devmode(nil^),0);
  ShowCursor(true);
 end;

 if not wglmakecurrent(glw^.dc,0) then begin
  MessageBox(0,'Release of DC and RC failed!','Error',MB_OK or MB_ICONERROR);
 end;
 if not wgldeletecontext(glw^.glrc) then begin
  MessageBox(0,'Release of rendering context failed!','Error',MB_OK or MB_ICONERROR);
  glw^.glrc:=0;
 end;
 if (glw^.dc=1)and(releasedc(glw^.wnd,glw^.dc)<>0) then begin
  MessageBox(0,'Release of device context failed!','Error',MB_OK or MB_ICONERROR);
  glw^.dc:=0;
 end;
 if (glw^.wnd<>0)and(not destroywindow(glw^.wnd)) then begin
  MessageBox(0,'Unable to destroy window!','Error',MB_OK or MB_ICONERROR);
  glw^.wnd:=0;
 end;
 if not unregisterclass('OpenGL',0) then begin
  MessageBox(0,'Unable to unregister window class!','Error',MB_OK or MB_ICONERROR);
 end;   
{$endif}
end;
//############################################################################//
//############################################################################//
{$ifdef win32}
function wndproc(hwnd:HWND;msg:UINT;wparam:WPARAM;lparam:LPARAM):LRESULT; stdcall;
var cshift:tshiftstate;
i:integer;
glw:pglwin;
s:pCREATESTRUCT;  
lt:dword;
ct,dt:double;

procedure docsh;
begin
 cshift:=[];
 if glw^.pks[VK_SHIFT] then begin
  include(cshift,ssshift);
  if glw^.pks[256] then include(cshift,sslshift);
  if glw^.pks[257] then include(cshift,ssrshift);
 end;
 if glw^.pks[VK_Control] then include(cshift,ssctrl);
 if glw^.pks[VK_menu] then include(cshift,ssalt);
 if glw^.mbtns[0] then include(cshift,ssleft);
 if glw^.mbtns[1] then include(cshift,ssright);
 if glw^.mbtns[2] then include(cshift,ssmiddle);   
 if glw^.mbtns[3] then include(cshift,ssup);
 if glw^.mbtns[4] then include(cshift,ssdown);
end;

begin
 result:=0;
 glw:=nil;
 
 if msg<>WM_CREATE then begin
  for i:=0 to length(wir)-1 do if wir[i]=hwnd then begin
   glw:=wer[i];
   break;
  end;
  if glw=nil then begin
   result:=DefWindowProc(hWnd,Msg,wParam,lParam);
   exit;
  end;
 end;

 case (msg) of
  WM_CREATE:begin
   s:=pointer(lparam);
   i:=length(wir);
   setlength(wir,i+1);
   setlength(wer,i+1);
   wir[i]:=hwnd;
   wer[i]:=s.lpCreateParams; 
   glw:=wer[i];  
   glw^.lds:=gettickcount; 
  end;
  WM_CLOSE:begin
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evclose,0,0,0,[]);
   PostQuitMessage(0);
  end;
  WM_KEYDOWN:begin
   glw^.pks[wparam]:=true;   
   if lparam and $FFFFFF=$2A0001 then glw^.pks[256]:=true;
   if lparam and $FFFFFF=$360001 then glw^.pks[257]:=true;   
   docsh;           
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evkeydwn,0,0,wparam,cshift);
  end;
  WM_KEYUP:begin
   glw^.pks[wparam]:=false;  
   if lparam and $FFFFFF=$2A0001 then glw^.pks[256]:=false;
   if lparam and $FFFFFF=$360001 then glw^.pks[257]:=false;  
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evkeyup,0,0,wparam,cshift);
  end;
  WM_SYSKEYDOWN:begin
   glw^.pks[wparam]:=true;  
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evkeydwn,0,0,wparam,cshift);
  end;
  WM_SYSKEYUP:begin
   glw^.pks[wparam]:=false;  
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evkeyup,0,0,wparam,cshift);
  end;
  WM_SIZE:begin
   glw^.wid:=LOWORD(lparam);
   glw^.hei:=HIWORD(lparam);
   resoglwin(glw);   
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evresize,glw^.wid,glw^.hei,0,[]);
  end;      

  WM_MOUSEMOVE:if doglrdr then begin
   docsh;        
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsmove,lparam mod 65536,lparam div 65536,0,cshift);
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  WM_LBUTTONDOWN:if doglrdr then begin
   glw^.mbtns[0]:=true;
   docsh;           
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsdwn,lparam mod 65536,lparam div 65536,0,cshift);
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  WM_LBUTTONUP:if doglrdr then begin
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsup,lparam mod 65536,lparam div 65536,0,cshift); 
   glw^.mbtns[0]:=false;   
   docsh;
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  WM_RBUTTONDOWN:if doglrdr then begin
   glw^.mbtns[1]:=true;
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsdwn,lparam mod 65536,lparam div 65536,0,cshift);
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  WM_RBUTTONUP:if doglrdr then begin 
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsup,lparam mod 65536,lparam div 65536,0,cshift);
   glw^.mbtns[1]:=false;   
   docsh;
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  WM_MBUTTONDOWN:if doglrdr then begin
   glw^.mbtns[2]:=true;
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsdwn,lparam mod 65536,lparam div 65536,0,cshift);
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  WM_MBUTTONUP:if doglrdr then begin 
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsup,lparam mod 65536,lparam div 65536,0,cshift);
   glw^.mbtns[2]:=false;   
   docsh;
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  WM_MOUSEWHEEL:if doglrdr then begin
   i:=wparam shr 16;
   i:=i*round(wparam/abs(wparam)); 
   glw^.mbtns[3]:=false;
   glw^.mbtns[4]:=false;
   if i>0 then glw^.mbtns[3]:=true;
   if i<0 then glw^.mbtns[4]:=true;
   docsh;
   if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsdwn,lparam mod 65536,lparam div 65536,0,cshift);
   glw^.mbtns[3]:=false;
   glw^.mbtns[4]:=false;
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);


  WM_TIMER:if doglrdr then begin  
   if (wparam and FPS_TIMER)<>0 then begin   
    glw^.fpsc:=round(glw^.fpsc*1000/FPS_INTERVAL);
    glw^.cfps:=glw^.fpsc;
    SetWindowText(hWnd,PChar(glw^.name+' (FPS='+stri(glw^.fpsc)+')'));
    glw^.fpsc:=0;        
   end else begin    
    glw^.fpsc:=glw^.fpsc+1;
                           
    lt:=glw^.eft;
    glw^.eft:=gettickcount-glw^.lds;
    glw^.eft:=(lt+glw^.eft)div 2;

    ct:=(glw^.eft)/1000;
    dt:=(glw^.eft-lt)/1000;
    if doglon then glw^.frmontimer(ct,dt);      
   end;
  end else result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  else begin
   result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  end;
 end;
end;     
{$endif}
//############################################################################//
{$ifndef win32}
//############################################################################//
procedure docsh;
var md:integer; 
begin
 cshift:=[];
 md:=glutGetModifiers;
 if(md and GLUT_ACTIVE_SHIFT)<>0 then include(cshift,ssshift);
 if(md and GLUT_ACTIVE_SHIFT)<>0 then include(cshift,sslshift);
 if(md and GLUT_ACTIVE_CTRL)<>0 then include(cshift,ssctrl);
 if(md and GLUT_ACTIVE_ALT)<>0 then include(cshift,ssalt);
 if glw^.mbtns[0] then include(cshift,ssleft);
 if glw^.mbtns[1] then include(cshift,ssright);
 if glw^.mbtns[2] then include(cshift,ssmiddle);
 if glw^.mbtns[3] then include(cshift,ssup);
 if glw^.mbtns[4] then include(cshift,ssdown);
end;
//############################################################################//
procedure keysinp(key:byte;x,y:integer);cdecl;begin docsh;if assigned(glw^.frmevent) then glw^.frmevent(glgr_evkeydwn,0,0,128+key,cshift);end;
procedure keyupsinp(key:byte;x,y:integer);cdecl;begin docsh;if assigned(glw^.frmevent) then glw^.frmevent(glgr_evkeyup,0,0,128+key,cshift);end;
procedure keyinp(key:byte;x,y:integer);cdecl;begin docsh;if assigned(glw^.frmevent) then glw^.frmevent(glgr_evkeydwn,0,0,key,cshift);end;
procedure keyupinp(key:byte;x,y:integer);cdecl;begin docsh;if assigned(glw^.frmevent) then glw^.frmevent(glgr_evkeyup,0,0,key,cshift);end;
procedure msmove(x,y:integer);cdecl;begin if assigned(glw^.frmevent) then glw^.frmevent(glgr_evmsmove,x,y,0,cshift);end;     
//############################################################################//
procedure msdown(btn,stat,x,y:integer);cdecl;
begin
 if btn=GLUT_LEFT_BUTTON then glw^.mbtns[0]:=stat=GLUT_DOWN;
 if btn=GLUT_RIGHT_BUTTON then glw^.mbtns[1]:=stat=GLUT_DOWN;
 if btn=3 then glw^.mbtns[3]:=stat=GLUT_DOWN;
 if btn=4 then glw^.mbtns[4]:=stat=GLUT_DOWN;
 docsh;

 if assigned(glw^.frmevent) then if stat=GLUT_DOWN then glw^.frmevent(glgr_evmsdwn,x,y,0,cshift);
 if assigned(glw^.frmevent) then if stat=GLUT_UP then glw^.frmevent(glgr_evmsup,x,y,0,cshift);
end;
//############################################################################//
procedure DisplayWindow;cdecl;  
var ct,dt:double;
lt:integer;
begin
 glw^.fpsc:=glw^.fpsc+1;
                           
 lt:=glw^.eft;
 glw^.eft:=round(rtdt(gl_dt)/1000000-glw^.lds);
 glw^.eft:=(lt+glw^.eft)div 2;

 ct:=(glw^.eft)/1000;
 dt:=rtdt(gl_dt)-glw^.pt;
 glw^.pt:=rtdt(gl_dt);
 if doglon then glw^.frmontimer(ct,dt/1000000); 
end;
//############################################################################//
procedure OnTimer(value:Integer);cdecl;
begin
 glutPostRedisplay;
 if value>=1000 then begin
  value:=0;
  glw^.fpsc:=round(glw^.fpsc*1000/FPS_INTERVAL);
  glw^.cfps:=glw^.fpsc;
  glutsetwindowtitle(PChar(glw^.name+' (FPS='+stri(glw^.fpsc)+')'));
  glw^.fpsc:=0;
 end;
 glutTimerFunc(20,@OnTimer,value+20);
end;    
//############################################################################//
{$endif} 
//############################################################################//
{$ifdef win32}  
//############################################################################//
function createoglwin(gwin:pglwin):boolean;overload;
var wdcl:TWndClass;
dws,dwes:DWORD;
dmss:DEVMODE;
hins:HINST;  
begin
 hins:=getmodulehandle(nil);
 zeromemory(@wdcl,sizeof(wdcl));

 with wdcl do begin
  style        :=CS_HREDRAW or            // Redraws entire window if length changes
                 CS_VREDRAW or            // Redraws entire window if height changes
                 CS_OWNDC;                // Unique device context for the window
  lpfnWndProc  :=@wndproc;                // Set the window procedure to our func WndProc
  hInstance    :=hins;
  hCursor      :=loadcursor(0,IDC_CROSS);
  lpszClassName:='OpenGL';
 end;

 if RegisterClass(wdcl)=0 then begin
  MessageBox(0,'Failed to register the window class!','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;

 if gwin^.fs then begin
  zeromemory(@dmss,sizeof(dmss));
  with dmss do begin
   dmSize      :=sizeof(dmss);
   dmPelsWidth :=gwin^.wid;                    // Window width
   dmPelsHeight:=gwin^.hei;                    // Window height
   dmBitsPerPel:=gwin^.pd;                     // Window color depth
   dmFields    :=DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
  end;

  if (changedisplaysettings(dmss,CDS_FULLSCREEN)=DISP_CHANGE_FAILED) then begin
   MessageBox(0,'Unable to switch to fullscreen!','Error',MB_OK or MB_ICONERROR);
   gwin^.fs:=false;
  end;
 end;

 if (gwin^.fs) then begin
  dws:=WS_POPUP        or        // Creates a popup window
       WS_CLIPCHILDREN or        // Doesn't draw within child windows
       WS_CLIPSIBLINGS;          // Doesn't draw within sibling windows
  dwes:=WS_EX_APPWINDOW;         // Top level window
  showcursor(false);
 end else begin
  dws:=WS_OVERLAPPEDWINDOW or    // Creates an overlapping window
       WS_CLIPCHILDREN or        // Doesn't draw within child windows
       WS_CLIPSIBLINGS;          // Doesn't draw within sibling windows
  dwes:=WS_EX_APPWINDOW or       // Top level window
        WS_EX_WINDOWEDGE;        // Border with a raised edge
 end;
        
 gwin^.wnd:=createwindowex(dwes,       // Extended window styles
                       'OpenGL',   // Class name
                       pchar(gwin^.name),// Window title (caption)
                       dws,        // Window styles
                       0, 0,       // Window position
                       gwin^.wid,gwin^.hei,    // Size of window
                       0,          // No parent window
                       0,          // No menu
                       hins,       // Instance
                       gwin);       // Pass gwin to WM_CREATE

 
 if gwin^.wnd=0 then begin
  killoglwin(gwin);
  MessageBox(0,'Unable to create window!','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;

 gwin^.dc:= getdc(gwin^.wnd);
 if gwin^.dc=0 then begin
  killoglwin(gwin);
  MessageBox(0,'Unable to get a device context!','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;

 if not createogl(gwin^.dc,gwin^.wid,gwin^.hei,gwin^.pd,gwin^.glrc) then begin
  MessageBox(0,'Unable to set an OpenGL!','Error',MB_OK or MB_ICONERROR);
  killoglwin(gwin);
  result:=false;
  exit;
 end;

 settimer(gwin^.wnd,FPS_TIMER,FPS_INTERVAL,nil);
 settimer(gwin^.wnd,DRAW_TIMER,DRAW_INTERVAL,nil);
 //showwindow(gwin^.wnd,SW_SHOW);
 showwindow(gwin^.wnd,SW_SHOWMAXIMIZED);
 setforegroundwindow(gwin^.wnd);
 setfocus(gwin^.wnd);

 result:=true;
end;
{$else}
function createoglwin(gwin:pglwin):boolean;
begin
 result:=false;
 glw:=gwin;

 glutInit(@argc,argv);
 if glw^.fs then begin
  glutInitDisplayMode(GLUT_RGB or GLUT_DEPTH or GLUT_DOUBLE);
  glutinitwindowsize(glw^.wid,glw^.hei);
  glutCreateWindow(pchar(glw^.name));
  glutfullscreen;
 end else begin
  glutInitDisplayMode(GLUT_RGB or GLUT_DEPTH or GLUT_DOUBLE);
  glutinitwindowsize(glw^.wid,glw^.hei);
  glutCreateWindow(pchar(glw^.name));
 end;
 glutsetcursor(GLUT_CURSOR_CROSSHAIR);
 glutDisplayFunc(@DisplayWindow);
  
 glutkeyboardfunc(@keyinp);
 glutkeyboardupfunc(@keyupinp);
 glutspecialfunc(@keysinp);
 glutspecialupfunc(@keyupsinp);
 glutmotionfunc(@msmove);
 glutpassivemotionfunc(@msmove);
 glutmousefunc(@msdown);
  
 glutTimerFunc(20,@OnTimer,0);
 glutReshapeFunc(@resoglwin);

 result:=true;
end;  
{$endif}      
//############################################################################//   
function createoglwin(gwin:pglwin;xs,ys:integer;fs:boolean;frm,tim:pointer;nm:string):boolean;overload;
begin    
 scrx:=xs;scry:=ys;   
 gwin.fs:=fs;gwin.name:=nm;gwin.wid:=xs;gwin.hei:=ys;gwin.pd:=32;
 gwin.frmevent:=frm;gwin.frmontimer:=tim;
 result:=createoglwin(gwin);
 glgr_vsync(gvsync);    
end;   
//############################################################################//   
{$ifdef win32}
function createogl_offscreen:boolean;overload;   
var glrc:HGLRC;
dc:hdc;
info:BITMAPINFO;
bm:hbitmap;
bits:pointer;
pfd:pixelformatdescriptor;
pf:integer;
begin    
 result:=false;
 loadopengl; 

 dc:=CreateCompatibleDC(0);
 fillchar(info,sizeof(info),0);
 //code - info
 bm:=CreateDIBSection(dc,info,DIB_RGB_COLORS,bits,0,0);
//code
 SelectObject(dc,bm);   
 fillchar(pfd,sizeof(pfd),0);
//code - pfd
 pf:=ChoosePixelFormat(dc,@pfd);
 SetPixelFormat(dc,pf,@pfd);
 
 glrc:=wglCreateContext(dc);
 if glrc=0 then begin
  messagebox(0,'Unable to create an OpenGL rendering context','Error',MB_OK or MB_ICONERROR);
  exit;
 end;
 if not wglmakecurrent(dc,glrc) then begin
  messagebox(0,'Unable to activate OpenGL rendering context','Error',MB_OK or MB_ICONERROR);
  exit;
 end;    
 result:=true;
end;  
{$endif}
//############################################################################//   
//############################################################################//
{$ifdef win32}
function wmain:integer; stdcall;
var lmsg:tmsg;
fin:boolean;
begin
 fin:=false; 
 while not fin do begin
  if PeekMessage(lmsg,0,0,0,PM_REMOVE) then if (lmsg.message=WM_QUIT) then fin:=true else begin
   TranslateMessage(lmsg);
   DispatchMessage(lmsg);
  end;
 end;
 //killoglwin(@gwin);
 result:=lmsg.wparam;  
end;
//############################################################################//
procedure win32procmsg;
var lmsg:tmsg;
begin          
 doglrdr:=false;
 if PeekMessage(lmsg,0,0,0,PM_REMOVE) then if (lmsg.message=WM_QUIT) then halt else begin
  TranslateMessage(lmsg);
  DispatchMessage(lmsg);
 end;           
 doglrdr:=true;
end;
{$endif}
//############################################################################//
procedure doglmain;
begin 
 {$ifdef win32}wmain;{$else}gl_dt:=getdt;stdt(gl_dt);glutMainLoop;{$endif}
end;
//############################################################################//
procedure doglswap(wnd:pglwin);
begin
 {$ifdef win32}glFlush;SwapBuffers(wnd.dc);{$else}glutSwapBuffers;{$endif}
end;
//############################################################################//
//############################################################################//
{$ifdef win32}
function setoglwin(glw:pglwin):boolean;
var dwes:DWORD;
dmss:DEVMODE;
begin
 if glw^.wnd=0 then begin
  killoglwin(glw);
  MessageBox(0,'Unable to create window!','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;

 if glw^.fs then begin
  zeromemory(@dmss,sizeof(dmss));
  with dmss do begin
   dmSize      :=sizeof(dmss);
   dmPelsWidth :=glw^.wid;                    // Window width
   dmPelsHeight:=glw^.hei;                    // Window height
   dmBitsPerPel:=glw^.pd;                     // Window color depth
   dmFields    :=DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
  end;

  if (changedisplaysettings(dmss,CDS_FULLSCREEN)=DISP_CHANGE_FAILED) then begin
   MessageBox(0,'Unable to switch to fullscreen!','Error',MB_OK or MB_ICONERROR);
   glw^.fs:=false;
  end;
  
  //showcursor(false);
  MoveWindow(glw^.wnd,0,0,glw^.wid,glw^.hei,true);
  dwes:=GetWindowLong(glw^.wnd,GWL_EXSTYLE) or WS_EX_TOPMOST;
  SetWindowLong(glw^.wnd,GWL_EXSTYLE,dwes);
  //SetWindowLong(glw^.wnd,GWL_STYLE,dws);
  //AdjustWindowRect(rc,WS_POPUP or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,false);
 end;

 glw^.dc:=getdc(glw^.wnd);
 if glw^.dc=0 then begin
  killoglwin(glw);
  MessageBox(0,'Unable to get a device context!','Error',MB_OK or MB_ICONERROR);
  result:=false;
  exit;
 end;
 

 if not createogl(glw^.dc,glw^.wid,glw^.hei,glw^.pd,glw^.glrc) then begin
  MessageBox(0,'Unable to set an OpenGL!','Error',MB_OK or MB_ICONERROR);
  killoglwin(glw);
  result:=false;
  exit;
 end;
       
 settimer(glw^.wnd,FPS_TIMER,FPS_INTERVAL,nil);
 settimer(glw^.wnd,DRAW_TIMER,DRAW_INTERVAL,nil);
         
 result:=true;
end;
{$endif}
//############################################################################//
//############################################################################//
procedure glgr_set2d(glw:pglwin);
begin        
 glViewport(0,0,glw.wid,glw.hei);
 glMatrixMode(GL_PROJECTION); glLoadIdentity; 
 glOrtho(-0.5,glw^.wid-0.5,glw^.hei-0.5,-0.5,1000,-1000);
 glMatrixMode(GL_MODELVIEW); glLoadIdentity; 
end;
//############################################################################//
procedure glgr_set_unit2d(glw:pglwin);
begin        
 glViewport(0,0,glw.wid,glw.hei);
 glMatrixMode(GL_PROJECTION);glLoadIdentity; 
 glOrtho(-1,1,-1,1,1000,-1000);
 glMatrixMode(GL_MODELVIEW);glLoadIdentity; 
end;
//############################################################################//    
procedure glgr_set3d(glw:pglwin;ap,l,h:double);
begin
 glViewport(0,0,glw.wid,glw.hei);
 glMatrixMode(GL_PROJECTION); glLoadIdentity;
 gluPerspective(ap,glw^.wid/glw^.hei,l,h);
 glMatrixMode(GL_MODELVIEW); glLoadIdentity;  
end;   
//############################################################################//
procedure glgr_setdefault3d(glw:pglwin;xres:integer=0;yres:integer=0);  
var v:mquat;
begin    
 glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
 glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
 glHint(GL_POINT_SMOOTH_HINT,GL_NICEST);
 
 glenable(GL_LINE_SMOOTH);
 
 glColorMaterial(GL_FRONT_AND_BACK,GL_DIFFUSE);
 glenable(GL_COLOR_MATERIAL);
 
 glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,0);
 v:=tmquat(0.5,0.5,0.7,1);glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@v.x); 
 v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@v.x);  
 v:=tmquat(0,0,0,0);glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,@v.x);

 glLightModelf(GL_LIGHT_MODEL_LOCAL_VIEWER,1);
 glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL,GL_SEPARATE_SPECULAR_COLOR);
 
 glShadeModel(GL_SMOOTH);
 glLineWidth(1);
 glEnable(GL_NORMALIZE);
 glenable(GL_POINT_SMOOTH);
 
 glClearColor(1,0,0,1);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
 glenable(GL_DEPTH_TEST); 
 glEnable(GL_TEXTURE_2D);
 glEnable(GL_BLEND);
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   
 ////if gl_2_sup then glUseProgram(0);
 
 glEnable(GL_LIGHTING);
 glPointSize(1);

 glEnable(GL_CULL_FACE);
 glCullFace(GL_BACK);
 glFrontFace(GL_CW);  
         
 if xres<>0 then begin
  glViewport(0,0,xres,yres);
  glMatrixMode(GL_PROJECTION); glLoadIdentity;
  gluPerspective(45,xres/yres,0.1,1000000);
  glMatrixMode(GL_MODELVIEW); glLoadIdentity;  
 end else glgr_set3d(glw,45,0.1,1000000);     
 glscalef(1,1,-1);
end;      
//############################################################################//
procedure glgr_screenshot(win:pglwin);
var p:pointer;
begin
 glPixelStorei(GL_PACK_ALIGNMENT,4);
 glPixelStorei(GL_PACK_ROW_LENGTH,0);
 glPixelStorei(GL_PACK_SKIP_ROWS,0);
 glPixelStorei(GL_PACK_SKIP_PIXELS,0);
    
 getmem(p,win.wid*win.hei*4);
 glReadPixels(0,0,win.wid,win.hei,GL_BGRA,GL_UNSIGNED_INT_8_8_8_8_REV,p);

 storeBMP32('screenshot-'+getdatestamp+'.bmp',p,win.wid,win.hei,false,false);

 freemem(p);
end;          
//############################################################################//
procedure glgr_vsync(en:boolean); // true -- VSync включен, false -- выключен
begin
 {$ifdef win32}
 wglSwapIntervalEXT:=GLGetProcAddress('wglSwapIntervalEXT');
 if assigned(wglSwapIntervalEXT) then wglSwapIntervalEXT(ord(en));
 {$endif}
end;       
//############################################################################//
//############################################################################//
begin   
 doglon:=true;
end.  
//############################################################################//
