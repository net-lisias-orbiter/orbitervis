//############################################################################//
// Orbiter Visualisation Project OpenGL client
// Main File
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
#define build "100608"
#define debug 0
//############################################################################//
#define ORBITER_MODULE
#include "orbitersdk.h"
#include "VideoTab.h"
#include <stdio.h>
#include "ogla.h"
#include "OGLAClient.h"
#include "OGLA2D.h"
#include "../src_common/alibc/oapi.hpp"
#include "../src_common/alibc/frbt.h"
//############################################################################//
using namespace oapi;
OGLAClient *gc=0;
//############################################################################//
//################################### Debug ##################################//
//############################################################################//
void OGLAClient::WriteLog(const char *msg)const{          char cbuf[256]="OGLAClient: ";strcpy(cbuf+12,msg);oapiWriteLog(cbuf);}
void OGLAClient::WriteDbg(const char *msg)const{if(debug){char cbuf[256]="[OGLAClient_dbg]: ";strcpy(cbuf+18,msg);oapiWriteLog(cbuf);}}
//############################################################################//
//################ OGLA rendering system interface init ######################//
//############################################################################//
OGLAClient::OGLAClient(HINSTANCE hInstance):GraphicsClient(hInstance)
{
 hRenderWnd=NULL;
 bFullscreen=false;
 viewW=viewH=viewBPP=0;
 vtab=NULL;
 hlibbtn=LoadLibrary("modules\\oglacfg.dll");
 if(hlibbtn)oglacfg_button=(void(__stdcall *)())GetProcAddress(hlibbtn,"oglacfg_button");
}
//############################################################################//
OGLAClient::~OGLAClient(){if(vtab)delete vtab;FreeLibrary(hlibbtn);hlibbtn=0;DelButton();}
//############################################################################//
//############################ Video tab #####################################//
//############################################################################//
bool OGLAClient::clbkInitialise()
{
 WriteDbg("clbkInitialise");
 if(!GraphicsClient::clbkInitialise())return false;

 VIDEODATA *data=GetVideoData();
 #ifdef no_render
  data->deviceidx=0;
  data->modeidx=0;
  data->fullscreen=false;
  data->winw=640;
  data->winh=480;
 #endif

 WriteLog("Using OpenGL Device");
 vtab=new VideoTab(this,ModuleInstance(),OrbiterInstance(),LaunchpadVideoTab());
 vtab->oglacfg_button_a=oglacfg_button;
 vtab->Initialise();
 return true;
}
//############################################################################//
void OGLAClient::clbkRefreshVideoData(){WriteDbg("clbkRefreshVideoData");if(vtab)vtab->UpdateConfigData();}
//############################################################################//
HWND OGLAClient::clbkCreateRenderWindow()
{
 char cbuf[256];
 WriteDbg("clbkCreateRenderWindow");
 VIDEODATA *data=GetVideoData();
 hRenderWnd=GraphicsClient::clbkCreateRenderWindow();
 
 ogla.initgl(hRenderWnd,&viewW,&viewH,DWORD(data));
  
 WriteLog("3D environment ok");
 sprintf(cbuf,"Viewport: %s %d x %d x %d",bFullscreen?"Fullscreen":"Window",viewW,viewH,viewBPP);
 WriteLog(cbuf);
 return hRenderWnd;
}
//############################################################################//
void OGLAClient::clbkGetViewportSize(DWORD *width,DWORD *height)const{WriteDbg("clbkGetViewportSize");*width=viewW;*height=viewH;}
//############################################################################//
bool OGLAClient::clbkGetRenderParam(DWORD prm,DWORD *value) const
{
 WriteDbg("clbkGetRenderParam");
 switch(prm){
  case RP_COLOURDEPTH :*value=32;return true;
  case RP_ZBUFFERDEPTH:*value=32;return true;
  case RP_STENCILDEPTH:*value=8;return true;
 }
 return false;
}
//############################################################################//
bool  OGLAClient::clbkFullscreenMode()const{WriteDbg("clbkFullscreenMode");  return bFullscreen;}
//############################################################################//
//Followed by LoadTexture calls
//############################################################################//
//############################################################################//
//############################################################################//
DWORD OGLAClient::clbkGetDeviceColour(BYTE r,BYTE g,BYTE b)
{
 WriteDbg("clbkGetDeviceColour");
 //return((DWORD)r<<16)+((DWORD)g<<8)+(DWORD)b;
 return((DWORD)r)+((DWORD)g<<8)+((DWORD)b<<16);
} 
//############################################################################//
BOOL OGLAClient::LaunchpadVideoWndProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
{
 if(vtab)return vtab->WndProc(hWnd,uMsg,wParam,lParam);
    else return FALSE;
}
//############################################################################//
void OGLAClient::clbkPostCreation       (){WriteDbg("clbkPostCreation");ogla.firstrun();}
void OGLAClient::clbkDestroyRenderWindow(bool fastclose){WriteDbg("clbkDestroyRenderWindow");GraphicsClient::clbkDestroyRenderWindow(fastclose);viewW=viewH=viewBPP=0;hRenderWnd=NULL;}
void OGLAClient::clbkCloseSession       (bool fastclose){}
void OGLAClient::clbkPreOpenPopup       (){WriteDbg("clbkPreOpenPopup");}
void OGLAClient::clbkTimeJump           (double simt,double simdt,double mjd){}
void OGLAClient::clbkRenderScene        (){WriteDbg("clbkRenderScene");udc=ogla.render(cfps);Render2DOverlay();fpsc++;}
void OGLAClient::clbkRender2DPanel      (SURFHANDLE *hSurf,MESHHANDLE hMesh,MATRIX3 *T,bool transparent){WriteDbg("clbkRender2DPanel");ogla.render2D(hSurf,hMesh,T,transparent?1:0);}
bool OGLAClient::clbkDisplayFrame       (){WriteDbg("clbkDisplayFrame");ogla.out2d();return true;}
//############################################################################//
//########################## Mesh functions ##################################//
//############################################################################//
int        OGLAClient::clbkEditMeshGroup  (DEVMESHHANDLE hMesh,DWORD grpidx,GROUPEDITSPEC *ges) {                         ogla.meshop(1,&hMesh,NULL,NULL,grpidx,ges);return 0;}
MESHHANDLE OGLAClient::clbkGetMesh        (VISHANDLE vis,UINT idx)                              {DEVMESHHANDLE hMesh=NULL;ogla.meshop(0,&hMesh,vis,NULL,idx,NULL);return hMesh;}
bool       OGLAClient::clbkSetMeshTexture (DEVMESHHANDLE hMesh,DWORD texidx,SURFHANDLE tex)     {                         ogla.meshop(2,&hMesh,NULL,tex,texidx,NULL);return true;}
int        OGLAClient::clbkSetMeshMaterial(DEVMESHHANDLE hMesh,DWORD matidx,const MATERIAL *mat){                         ogla.meshop(4,&hMesh,NULL,(void*)mat,matidx,NULL);return 0;}
bool       OGLAClient::clbkSetMeshProperty(DEVMESHHANDLE hMesh,DWORD property,DWORD value)
{
/*
 D3D7Mesh *mesh=(D3D7Mesh*)hMesh;
 switch(property){
  case MESHPROPERTY_MODULATEMATALPHA:
   mesh->EnableMatAlpha(value!=0);
   return true;
 }
 */
 return false;
}
int        OGLAClient::clbkVisEvent           (OBJHANDLE hObj,VISHANDLE vis,DWORD msg,UINT context){ogla.meshop(3,(int**)(&hObj),vis,(void*)context,msg,NULL);return 1;}
void       OGLAClient::clbkStoreMeshPersistent(MESHHANDLE hMesh,const char *fname){WriteDbg("clbkStoreMeshPersistent");}
void       OGLAClient::clbkNewVessel          (OBJHANDLE hVessel)                 {WriteDbg("clbkNewVessel");}
void       OGLAClient::clbkDeleteVessel       (OBJHANDLE hVessel)                 {WriteDbg("clbkDeleteVessel");UnregisterVisObject(hVessel);}
//############################################################################//
//##################### Particle stream functions ############################//
//############################################################################//
ParticleStream *OGLAClient::clbkCreateParticleStream(PARTICLESTREAMSPEC *pss){WriteDbg("clbkCreateParticleStream");return NULL;}
bool OGLAClient::clbkParticleStreamExists(const ParticleStream *ps){WriteDbg("clbkParticleStreamExists");return false;}
//############################################################################//
ParticleStream *OGLAClient::clbkCreateExhaustStream(PARTICLESTREAMSPEC *pss,OBJHANDLE hVessel, const double *lvl, const VECTOR3 *ref, const VECTOR3 *dir)
{
 WriteDbg("clbkCreateExhaustStream1");
 ParticleStream *es=new ParticleStream(this,pss);
 ogla.addps(0,(DWORD)es,pss,hVessel,lvl,ref,dir);
 return es;
}
//############################################################################//
ParticleStream *OGLAClient::clbkCreateExhaustStream(PARTICLESTREAMSPEC *pss,OBJHANDLE hVessel, const double *lvl, const VECTOR3 &ref, const VECTOR3 &dir)
{
 WriteDbg("clbkCreateExhaustStream2");
 ParticleStream *es=new ParticleStream(this,pss);
 ogla.addps(0,(DWORD)es,pss,hVessel,lvl,&ref,&dir);
 return es;
}
//############################################################################//
ParticleStream *OGLAClient::clbkCreateReentryStream(PARTICLESTREAMSPEC *pss,OBJHANDLE hVessel)
{
 WriteDbg("clbkCreateReentryStream3");
 ParticleStream *rs=new ParticleStream(this,pss);
 //ogla.addps(0,(DWORD)es,pss,hVessel,lvl,&ref,&dir);
 return rs;
}
//############################################################################//
//########################### Surface functions ##############################//
//############################################################################//
SURFHANDLE OGLAClient::clbkLoadTexture  (const char *fname,DWORD flags)       {WriteDbg("clbkLoadTexture");  return ogla.loadtex(fname,flags);}
SURFHANDLE OGLAClient::clbkCreateSurface(DWORD w,DWORD h,SURFHANDLE hTemplate){WriteDbg("clbkCreateSurface");return ogla.maksrf(w,h,hTemplate,0);}
SURFHANDLE OGLAClient::clbkCreateTexture(DWORD w,DWORD h)                     {WriteDbg("clbkCreateTexture");return ogla.maksrf(w,h,0,1);}

void OGLAClient::clbkReleaseTexture(SURFHANDLE hTex)                  {WriteDbg("clbkReleaseTexture");            ogla.reltex(hTex);}
bool OGLAClient::clbkReleaseSurface(SURFHANDLE surf)                  {WriteDbg("clbkReleaseSurface");     return ogla.reltex(surf);}
void OGLAClient::clbkIncrSurfaceRef(SURFHANDLE surf)                  {WriteDbg("clbkIncrSurfaceRef");            ogla.maksrf(0,0,surf,2);}
bool OGLAClient::clbkGetSurfaceSize(SURFHANDLE surf,DWORD *w,DWORD *h){WriteDbg("clbkGetSurfaceSize");     return ogla.gsrfsiz(surf,w,h);}
bool OGLAClient::clbkSetSurfaceColourKey(SURFHANDLE surf,DWORD ckey)  {WriteDbg("clbkSetSurfaceColourKey");return ogla.o2_op(13,surf,0,0,0,0,0,ckey)!=0;}
bool OGLAClient::clbkBlt(SURFHANDLE tgt,DWORD tgtx,DWORD tgty,SURFHANDLE src,DWORD flag)const                                                                       {WriteDbg("clbkBlta");        return ogla.blit(0,tgt,tgtx,tgty,0,0,src,0,0,0,0,flag);}
bool OGLAClient::clbkBlt(SURFHANDLE tgt,DWORD tgtx,DWORD tgty,SURFHANDLE src,DWORD srcx,DWORD srcy,DWORD w,DWORD h,DWORD flag) const                                {WriteDbg("clbkBltb");        return ogla.blit(1,tgt,tgtx,tgty,0,0,src,srcx,srcy,w,h,flag);}
bool OGLAClient::clbkScaleBlt(SURFHANDLE tgt,DWORD tgtx,DWORD tgty,DWORD tgtw,DWORD tgth,SURFHANDLE src,DWORD srcx,DWORD srcy,DWORD srcw,DWORD srch,DWORD flag)const{WriteDbg("clbkScaleBlt");    return ogla.blit(2,tgt,tgtx,tgty,tgtw,tgth,src,srcx,srcy,srcw,srch,flag);}
bool OGLAClient::clbkFillSurface(SURFHANDLE surf,DWORD col)const                                                                                                    {WriteDbg("clbkFillSurfacea");return ogla.fillsr(surf,0,0,0,0,col);}
bool OGLAClient::clbkFillSurface(SURFHANDLE surf,DWORD tgtx,DWORD tgty,DWORD w,DWORD h,DWORD col)const                                                              {WriteDbg("clbkFillSurfaceb");return ogla.fillsr(surf,tgtx,tgty,w,h,col);}
HDC  OGLAClient::clbkGetSurfaceDC    (SURFHANDLE surf)        {WriteDbg("clbkGetSurfaceDC");    return ogla.getsdc(surf);}
void OGLAClient::clbkReleaseSurfaceDC(SURFHANDLE surf,HDC hDC){WriteDbg("clbkReleaseSurfaceDC");       ogla.relsdc(surf,hDC);}
//############################################################################//
//############################## OGLA 2D #####################################//
//############################################################################//
oapi::Sketchpad *OGLAClient::clbkGetSketchpad(SURFHANDLE surf)        {WriteDbg("clbkGetSketchpad");    return new OGLAPad(surf,(DWORD)ogla.o2_op,(DWORD)ogla.getsdc,(DWORD)ogla.relsdc);}
void             OGLAClient::clbkReleaseSketchpad(oapi::Sketchpad *sp){WriteDbg("clbkReleaseSketchpad");if(sp){delete sp;}}
Font  *OGLAClient::clbkCreateFont  (int height,bool prop,char *face,Font::Style style,int orientation)const{WriteDbg("clbkCreateFont");return new OGLAFont(height,prop,face,style,orientation);}
void   OGLAClient::clbkReleaseFont (Font *font)const                                {WriteDbg("clbkReleaseFont"); delete font;}
Pen   *OGLAClient::clbkCreatePen   (int style,int width,DWORD col)const             {WriteDbg("clbkCreatePen");   return new OGLAPen(style,width,col);}
void   OGLAClient::clbkReleasePen  (Pen *pen)const                                  {WriteDbg("clbkReleasePen");  delete pen;}
Brush *OGLAClient::clbkCreateBrush (DWORD col)const                                 {WriteDbg("clbkCreateBrush"); return new OGLABrush (col);}
void   OGLAClient::clbkReleaseBrush(Brush *brush)const                              {WriteDbg("clbkReleaseBrush");delete brush;}
//############################################################################//
//########################### AUX functions ##################################//
//############################################################################//
DWORD      getbase       (OBJHANDLE _hObj)                {gc->GetBaseStructures(_hObj,&cbt.sbs,&cbt.nsbs,&cbt.sas,&cbt.nsas);return DWORD(&cbt);}
void      *getconfigparam(DWORD paramtype)                {return (void*)gc->GetConfigParam(paramtype);}
SURFHANDLE getmsurf      (int tp,int p)                   {if(tp==0)return gc->GetMFDSurface(p);else return 0;}
void       visop         (int op,OBJHANDLE ob,VISHANDLE v){if(oapiGetObjectType(ob)!=OBJTP_INVALID)if(op==0)gc->RegisterVisObject(ob,v);else gc->UnregisterVisObject(ob);}
SURFHANDLE vcsurf        (int op,int n,void* mf)          {if(op==0)return(void*)gc->GetVCHUDSurface((const VCHUDSPEC **)mf);else return(void*)gc->GetVCMFDSurface(n,(const VCMFDSPEC **)mf);}
//############################################################################//
//################################# Input ####################################//
//############################################################################//
void docsh(){cshift=1*pks[VK_SHIFT]+2*pks[VK_CONTROL]+4*pks[VK_MENU]+8*mbtns[0]+16*mbtns[1]+32*mbtns[2];}
//############################################################################//
LRESULT OGLAClient::RenderWndProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
{
 WriteDbg("RenderWndProc");
 char cbuf[256];
 
 switch (uMsg) {
  case WM_KEYDOWN: pks[wParam]=1;docsh();ogla.keydown(wParam,cshift);break;
  case WM_KEYUP:   pks[wParam]=0;docsh();ogla.keyup(wParam,cshift);  break;

  case WM_SYSCOMMAND:
		 switch(wParam){
		  case SC_KEYMENU:return 1;
		  case SC_MOVE:
		  case SC_SIZE:
		  case SC_MAXIMIZE:
		  case SC_MONITORPOWER:if(bFullscreen)return 1;break;
		 }
		 break;
 	case WM_SYSKEYUP:if(bFullscreen)return 0;

  case WM_MOUSEMOVE:             docsh();ogla.mouse(2,lParam%65536,lParam/65536,cshift);break;
  case WM_LBUTTONDOWN:mbtns[0]=1;docsh();ogla.mouse(0,lParam%65536,lParam/65536,cshift);break;
  case WM_LBUTTONUP:             docsh();ogla.mouse(1,lParam%65536,lParam/65536,cshift);mbtns[0]=0;docsh();break;
  case WM_RBUTTONDOWN:mbtns[1]=1;docsh();ogla.mouse(0,lParam%65536,lParam/65536,cshift);break;
  case WM_RBUTTONUP:             docsh();ogla.mouse(1,lParam%65536,lParam/65536,cshift);mbtns[1]=0;docsh();break;
  case WM_TIMER:
   if(wParam==1){
    cfps=fpsc;
    if(ogla.show_fps)sprintf(cbuf,"Orbiter 2010 OGLA %s (FPS=%d Polys=%d Rate=%.2f MTri/s)",build,fpsc,udc,udc*fpsc/1e6);
                else sprintf(cbuf,"Orbiter 2010 OGLA %s",build);
    SetWindowText(hWnd,cbuf);
    fpsc=0;              
   }
   break;
 }
 return GraphicsClient::RenderWndProc(hWnd,uMsg,wParam,lParam);
}
//############################################################################//
void loadint()
{
 loadint("modules\\ogla.dll");
 if(hlib){
  ogla_interface_get=(void(__stdcall *)(ogla_interface*))GetProcAddress(hlib,"ogla_interface_get");
  if(!ogla_interface_get){MessageBox(NULL,"Wrong ogla.dll version. Check installation.","Error!",MB_OK);exit(-1);}
  
  ogla.render_font=render_font;
  ogla.text_width=text_width;
  ogla.font_mode=&font_mode; 
  ogla.getbase=getbase;
  ogla.visop=visop;
  ogla.vcsurf=vcsurf;
  ogla.getconfigparam=getconfigparam;
  ogla.getmsurf=getmsurf;
  
  ogla_interface_get(&ogla);
 }else{MessageBox(NULL,"ogla.dll not found. Check installation.","Error!",MB_OK);exit(-1);}
 
 init_o2d();
}
//############################################################################//
DLLCLBK void InitModule(HINSTANCE hDLL){gc=new OGLAClient(hDLL);if(!oapiRegisterGraphicsClient(gc)){delete gc;gc=0;}loadint();}
DLLCLBK void ExitModule(HINSTANCE hDLL){if(gc){oapiUnregisterGraphicsClient(gc);delete gc; gc=0;}FreeLibrary(hlib);}
//############################################################################//

