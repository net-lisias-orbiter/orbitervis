//############################################################################//
//OGLAClient interface calls
//Made by Artlav in 2007-2009
//############################################################################//
//To force orbitersdk.h to use <fstream> in any compiler version
#pragma include_alias( <fstream.h>,<fstream> )
#include "Orbitersdk.h"
#include "OglaSDK.h"
//############################################################################//
//Functions
DWORD (__stdcall *poglcSetFlags)(VISHANDLE VesselHandle,DWORD flags);
void(__stdcall *poglcBindLightThruster)(VISHANDLE VesselHandle,oglc_light_rec *lt,THGROUP_HANDLE th);
void(__stdcall *poglcBindLightAnim)(VISHANDLE VesselHandle,oglc_light_rec *lt,int off_is,UINT anim);
oglc_light_rec *(__stdcall *poglcAddLight)(VISHANDLE VesselHandle,int type,VECTOR3 pos,VECTOR3 dir,VECTOR3 col,double spot,double vis_rad,double pwr);
void(__stdcall *poglcBindTexture)(VISHANDLE VesselHandle,int type,int mesh,int group,SURFHANDLE tex);
void(__stdcall *poglcBindExtMesh)(VISHANDLE VesselHandle,int mesh,char *mshname);
//############################################################################//
//Internal
HMODULE tcsdkhlib;
int SetErr=1;
#define oglamod "modules\\ogla.dll"
#define themod  "Modules\\Plugin\\OGLAClient.dll"
//############################################################################//
void InitOglaSDK()
{
 if(SetErr==0)return;

 tcsdkhlib=LoadLibrary(oglamod);
 if(!tcsdkhlib){
  //Disabled for the moment to avoid annoyances
  //MessageBox(NULL,"Library modules\\ogla.dll not found,please check your installation!","Error!",MB_OK|MB_ICONERROR);
 }else{  
  poglcBindLightThruster=(void (__stdcall*)(VISHANDLE,oglc_light_rec*,THGROUP_HANDLE))GetProcAddress(tcsdkhlib,"oglcBindLightThruster");
  poglcBindLightAnim=(void (__stdcall*)(VISHANDLE,oglc_light_rec*,int,UINT))GetProcAddress(tcsdkhlib,"oglcBindLightAnim");
  poglcBindTexture=(void (__stdcall*)(VISHANDLE,int,int,int,SURFHANDLE))GetProcAddress(tcsdkhlib,"oglcBindTexture");
  poglcBindExtMesh=(void (__stdcall*)(VISHANDLE,int,char *))GetProcAddress(tcsdkhlib,"oglcBindExtMesh");
  poglcSetFlags=(DWORD(__stdcall*)(VISHANDLE,DWORD))GetProcAddress(tcsdkhlib,"oglcSetFlags");
  poglcAddLight=(oglc_light_rec *(__stdcall*)(VISHANDLE,int,VECTOR3,VECTOR3,VECTOR3,double,double,double))GetProcAddress(tcsdkhlib,"oglcAddLight");

  if(
     poglcBindLightThruster==NULL||
     poglcBindLightAnim==NULL||
     poglcBindTexture==NULL||
     poglcBindExtMesh==NULL||
     poglcAddLight==NULL||
     oglcSetFlags==NULL
    ){
   //Disabled for the moment to avoid annoyances
   //MessageBox(NULL,"Library modules\\ogla.dll corrupt or wrong version,please check your installation!","Error!",MB_OK|MB_ICONERROR);
  }else if(GetModuleHandle(themod))SetErr=0;
 }
}
//############################################################################//
void oglcBindLightThruster(VISHANDLE VesselHandle,oglc_light_rec *lt,THGROUP_HANDLE th){InitOglaSDK();if(SetErr)return;poglcBindLightThruster(VesselHandle,lt,th);}
void oglcBindLightAnim(VISHANDLE VesselHandle,oglc_light_rec *lt,int off_is,UINT anim){InitOglaSDK();if(SetErr)return;poglcBindLightAnim(VesselHandle,lt,off_is,anim);}
void oglcBindTexture(VISHANDLE VesselHandle,int type,int mesh,int group,SURFHANDLE tex){InitOglaSDK();if(SetErr)return;poglcBindTexture(VesselHandle,type,mesh,group,tex);}
void oglcBindExtMesh(VISHANDLE VesselHandle,int mesh,char *mshname){InitOglaSDK();if(SetErr)return;poglcBindExtMesh(VesselHandle,mesh,mshname);}
//############################################################################//
DWORD           oglcSetFlags(VISHANDLE VesselHandle,DWORD flags)                    {InitOglaSDK();if(SetErr)return 0;return poglcSetFlags(VesselHandle,flags);}
oglc_light_rec *oglcAddLight(VISHANDLE VesselHandle,int type,VECTOR3 pos,VECTOR3 dir,VECTOR3 col,double spot,double vis_rad,double pwr){InitOglaSDK();if(SetErr)return NULL;return poglcAddLight(VesselHandle,type,pos,dir,col,spot,vis_rad,pwr);}
//############################################################################//



