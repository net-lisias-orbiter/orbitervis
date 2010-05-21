//############################################################################//
// Class VideoTab (implementation)
// Manages the user selections in the "Video" tab of the Orbiter
// Launchpad dialog.
// Made in 2007-2010 by Artlav
// Based on Martins 2008 code
//############################################################################//
#include "VideoTab.h"
#include "OGLAClient.h"
#include "../rsrc\resource.h"
#include "resource_video.h"
#include <stdio.h>
#include "../src_common/alibc/frbt.h"
//############################################################################//
using namespace oapi;
//############################################################################//
VideoTab::VideoTab(OGLAClient *gc,HINSTANCE _hInst,HINSTANCE _hOrbiterInst,HWND hVideoTab)
{
	gclient     =gc;
	hInst       =_hInst;
	hOrbiterInst=_hOrbiterInst;
	hTab        =hVideoTab;
}
//############################################################################//
BOOL VideoTab::WndProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
{
	switch(uMsg){
	case WM_INITDIALOG:return TRUE;
	case WM_COMMAND:
		switch(LOWORD(wParam)){
		case IDC_VID_MODE:
   if(HIWORD(wParam)==CBN_SELCHANGE){
			 DWORD idx;
				idx=SendDlgItemMessage(hWnd,IDC_VID_MODE,CB_GETCURSEL,0,0);
				SelectMode(idx);
				return TRUE;
			}
			break;
		case IDC_VID_FULL:  if(HIWORD(wParam)==BN_CLICKED){SelectDispmode(FALSE);return TRUE;}break;
		case IDC_VID_WINDOW:if(HIWORD(wParam)==BN_CLICKED){SelectDispmode(TRUE);return TRUE;}break;
		case IDC_VID_WIDTH: if(HIWORD(wParam)==EN_CHANGE) {SelectWidth();return TRUE;}break;
		case IDC_VID_HEIGHT:if(HIWORD(wParam)==EN_CHANGE) {SelectHeight();return TRUE;}break;
  case IDC_VID_ASPECT:if(HIWORD(wParam)==BN_CLICKED){SelectFixedAspect();SelectWidth();return TRUE;}	break;
		case IDC_VID_4X3:
		case IDC_VID_16X10:
		case IDC_VID_16X9:  if(HIWORD(wParam)==BN_CLICKED){aspect_idx=LOWORD(wParam)-IDC_VID_4X3;SelectWidth();return TRUE;}break;
		case IDC_VID_INFO:  DialogBox(hInst,MAKEINTRESOURCE(IDD_DIALOG1),hTab,AboutDlgProc);return TRUE;}
		break;
	}
	return FALSE;
}
//############################################################################//
//############################################################################//
void VideoTab::Initialise()
{
	char cbuf[255]; 
 DEVMODE dm;
 int i,n,x,y;
 GraphicsClient::VIDEODATA *data=gclient->GetVideoData();

 //Relocation
 DestroyWindow(GetDlgItem(hTab,IDC_VID_DEVICE));
 DestroyWindow(GetDlgItem(hTab,IDC_VID_ENUM));
 DestroyWindow(GetDlgItem(hTab,IDC_VID_STENCIL));
 DestroyWindow(GetDlgItem(hTab,IDC_VID_STENCIL+98));  
 DestroyWindow(GetDlgItem(hTab,IDC_VID_PAGEFLIP));
 /*
 RECT wrc,prc,rc;
 GetWindowRect(hTab,&wrc);
 for(i=0;i<2;i++){
  GetWindowRect(GetDlgItem(hTab,IDC_VID_STENCIL+99+i),&prc);GetClientRect(GetDlgItem(hTab,IDC_VID_STENCIL+99+i),&rc);
  MoveWindow(GetDlgItem(hTab,IDC_VID_STENCIL+99+i),prc.left-wrc.left-2,prc.top-wrc.top-2-98,rc.right,rc.bottom,false);
 }
 for(i=0;i<2;i++){
  GetWindowRect(GetDlgItem(hTab,IDC_VID_FULL+i),&prc);GetClientRect(GetDlgItem(hTab,IDC_VID_FULL+i),&rc);
  MoveWindow(GetDlgItem(hTab,IDC_VID_FULL+i),prc.left-wrc.left-2,prc.top-wrc.top-2-98,rc.right,rc.bottom,false);
 }
 for(i=0;i<5;i++){
  GetWindowRect(GetDlgItem(hTab,IDC_VID_STATIC5+i),&prc);GetClientRect(GetDlgItem(hTab,IDC_VID_STATIC5+i),&rc);
  MoveWindow(GetDlgItem(hTab,IDC_VID_STATIC5+i),prc.left-wrc.left-2,prc.top-wrc.top-2-98,rc.right,rc.bottom,false);
 }
 for(i=0;i<9;i++){
  GetWindowRect(GetDlgItem(hTab,IDC_VID_STATIC7+i),&prc);GetClientRect(GetDlgItem(hTab,IDC_VID_STATIC7+i),&rc);
  MoveWindow(GetDlgItem(hTab,IDC_VID_STATIC7+i),prc.left-wrc.left-2,prc.top-wrc.top-2-98,rc.right,rc.bottom,false);
 }
 */
	ShowWindow(GetDlgItem(hTab,IDC_VID_INFO),SW_SHOW);

 //Windowed
 //data->winw=800;
 //data->winh=600;
	SetWindowText(GetDlgItem(hTab,IDC_VID_WIDTH) ,_itoa(data->winw,cbuf,10));
	SetWindowText(GetDlgItem(hTab,IDC_VID_HEIGHT),_itoa(data->winh,cbuf,10));
	SendDlgItemMessage(hTab,IDC_VID_ASPECT,BM_SETCHECK,data->winw==(4*data->winh)/3 || data->winh == (3*data->winw)/4 ? BST_CHECKED:BST_UNCHECKED, 0);

 //Fullscreen
 //data->novsync=true;
 //data->fullscreen=false;
	SendDlgItemMessage(hTab,IDC_VID_VSYNC,  BM_SETCHECK,data->novsync?BST_CHECKED:BST_UNCHECKED,0);
	SendDlgItemMessage(hTab,IDC_VID_MODE,CB_RESETCONTENT,0,0);
	SendDlgItemMessage(hTab,IDC_VID_BPP ,CB_RESETCONTENT,0,0);
 n=0;i=0;x=-1;y=-1;
 while(EnumDisplaySettings(0,i,&dm)){
  if(dm.dmBitsPerPel==32)if((x!=dm.dmPelsWidth)||(y!=dm.dmPelsHeight)){
   x=dm.dmPelsWidth;y=dm.dmPelsHeight;
	  sprintf(cbuf,"%d x %d",x,y);
	  SendDlgItemMessage(hTab,IDC_VID_MODE,CB_ADDSTRING,0,(LPARAM)cbuf);
	  SendDlgItemMessage(hTab,IDC_VID_MODE,CB_SETITEMDATA,n,(LPARAM)(y<<16 | x));
   n++;
  }
  i++;
 }
	if(data->modeidx>=n)SendDlgItemMessage(hTab,IDC_VID_MODE,CB_SETCURSEL,0,0);
 else SendDlgItemMessage(hTab,IDC_VID_MODE,CB_SETCURSEL,data->modeidx,0);

 //BPP
	SendDlgItemMessage(hTab,IDC_VID_BPP,CB_ADDSTRING  ,0,(LPARAM)"16");
	SendDlgItemMessage(hTab,IDC_VID_BPP,CB_SETITEMDATA,0,(LPARAM)(16));
	SendDlgItemMessage(hTab,IDC_VID_BPP,CB_ADDSTRING  ,1,(LPARAM)"24");
	SendDlgItemMessage(hTab,IDC_VID_BPP,CB_SETITEMDATA,1,(LPARAM)(24));
	SendDlgItemMessage(hTab,IDC_VID_BPP,CB_ADDSTRING  ,2,(LPARAM)"32");
	SendDlgItemMessage(hTab,IDC_VID_BPP,CB_SETITEMDATA,2,(LPARAM)(32));
	SendDlgItemMessage(hTab,IDC_VID_BPP,CB_SETCURSEL  ,2,0);

      if(data->winw==( 4*data->winh)/3  || data->winh==(3 *data->winw)/4 )aspect_idx=1;
	else if(data->winw==(16*data->winh)/10 || data->winh==(10*data->winw)/16)aspect_idx=2;
	else if(data->winw==(16*data->winh)/9  || data->winh==(9 *data->winw)/16)aspect_idx=3;
	else aspect_idx=0;
	SendDlgItemMessage(hTab,IDC_VID_ASPECT,BM_SETCHECK,aspect_idx?BST_CHECKED:BST_UNCHECKED,0);
	if(aspect_idx)aspect_idx--;
	SendDlgItemMessage(hTab,IDC_VID_4X3+aspect_idx,BM_SETCHECK,BST_CHECKED,0);

 //Etc
	if(data->fullscreen)SendDlgItemMessage(hTab,IDC_VID_FULL,BM_CLICK,0,0);
	if(!data->fullscreen)SendDlgItemMessage(hTab,IDC_VID_WINDOW,BM_CLICK,0,0);
	SelectDispmode(!data->fullscreen);

 if(oglacfg_button_a)SetButtonbeta(0,"OGLAClient features\n     Configuration",DWORD(oglacfg_button_a),0,hTab);
}
//############################################################################//
void VideoTab::SelectDispmode(BOOL bWindow)
{
	DWORD i;
	for(i=0;i<5;i++)EnableWindow(GetDlgItem(hTab,IDC_VID_STATIC5+i),!bWindow);
	for(i=0;i<9;i++)EnableWindow(GetDlgItem(hTab,IDC_VID_STATIC7+i), bWindow);
}
//############################################################################//
void VideoTab::SelectMode(DWORD idx)
{
 DWORD data,w,h;
	data=SendDlgItemMessage(hTab,IDC_VID_MODE,CB_GETITEMDATA,idx,0);
	w=data & 0xFFFF;
	h=data>>16;
 gclient->bFullscreen=true;
	gclient->viewW=w;
 gclient->viewH=h;
}
//############################################################################//
static int aspect_wfac[4]={4,16,16};
static int aspect_hfac[4]={3,10,9};
void VideoTab::SelectWidth()
{
	if(SendDlgItemMessage(hTab,IDC_VID_ASPECT,BM_GETCHECK,0,0)==BST_CHECKED){
		char cbuf[128];
		int w,h,wfac=aspect_wfac[aspect_idx],hfac=aspect_hfac[aspect_idx];
		GetWindowText(GetDlgItem(hTab,IDC_VID_WIDTH), cbuf,127);w=atoi(cbuf);
		GetWindowText(GetDlgItem(hTab,IDC_VID_HEIGHT),cbuf,127);h=atoi(cbuf);
		if(w!=(wfac*h)/hfac){
			h=(hfac*w)/wfac;
			SetWindowText(GetDlgItem(hTab,IDC_VID_HEIGHT),_itoa(h,cbuf,10));
		}
	}
}
//############################################################################//
void VideoTab::SelectHeight()
{
	if(SendDlgItemMessage(hTab,IDC_VID_ASPECT,BM_GETCHECK,0,0)==BST_CHECKED){
		char cbuf[128];
		int w,h,wfac=aspect_wfac[aspect_idx],hfac=aspect_hfac[aspect_idx];
		GetWindowText(GetDlgItem(hTab,IDC_VID_WIDTH), cbuf,127);w=atoi(cbuf);
		GetWindowText(GetDlgItem(hTab,IDC_VID_HEIGHT),cbuf,127);h=atoi(cbuf);
		if(h!=(hfac*w)/wfac){
			w=(wfac*h)/hfac;
			SetWindowText(GetDlgItem(hTab,IDC_VID_WIDTH),_itoa(w,cbuf,10));
		}
	}
}    
//############################################################################//
void VideoTab::SelectFixedAspect()
{
	bool fixed_aspect=(SendDlgItemMessage(hTab,IDC_VID_ASPECT,BM_GETCHECK,0,0)==BST_CHECKED);
	for(int i=0;i<3;i++)EnableWindow(GetDlgItem(hTab,IDC_VID_4X3+i),fixed_aspect?TRUE:FALSE);
}
//############################################################################//
//############################################################################//
void VideoTab::UpdateConfigData()
{
	char cbuf[128];
	DWORD i,dat,bpp;
	GraphicsClient::VIDEODATA *data=gclient->GetVideoData();

 data->deviceidx=0;
	data->modeidx=SendDlgItemMessage(hTab,IDC_VID_MODE,CB_GETCURSEL,0,0);
	data->fullscreen=(SendDlgItemMessage(hTab,IDC_VID_FULL,   BM_GETCHECK,0,0)==BST_CHECKED);
	data->novsync   =(SendDlgItemMessage(hTab,IDC_VID_VSYNC,  BM_GETCHECK,0,0)==BST_CHECKED);
	data->trystencil=(SendDlgItemMessage(hTab,IDC_VID_STENCIL,BM_GETCHECK,0,0)==BST_CHECKED);
	data->forceenum =(SendDlgItemMessage(hTab,IDC_VID_ENUM,   BM_GETCHECK,0,0)==BST_CHECKED);

 if(!data->fullscreen){
	 GetWindowText(GetDlgItem(hTab,IDC_VID_WIDTH), cbuf,127);data->winw=atoi(cbuf);
	 GetWindowText(GetDlgItem(hTab,IDC_VID_HEIGHT),cbuf,127);data->winh=atoi(cbuf);
 }else{
	 i  =SendDlgItemMessage(hTab,IDC_VID_BPP, CB_GETCURSEL,  0,0);
	 bpp=SendDlgItemMessage(hTab,IDC_VID_BPP, CB_GETITEMDATA,i,0);
	 dat=SendDlgItemMessage(hTab,IDC_VID_MODE,CB_GETITEMDATA,data->modeidx,0);
  data->winw=dat&0xFFFF;
  data->winh=dat>>16;
 }
}
//############################################################################//
//############################################################################//
BOOL CALLBACK VideoTab::AboutDlgProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
{
	switch(uMsg){
	 case WM_INITDIALOG:
	 	char cbuf[1024];
	 	LoadString((HINSTANCE)GetWindowLong(hWnd,GWL_HINSTANCE),IDS_STRING1,cbuf,1024);
	 	SetWindowText(GetDlgItem(hWnd,IDC_EDIT1),cbuf);
	 	return TRUE;
	 case WM_COMMAND:switch(LOWORD(wParam)){
	  case IDOK:
	 	case IDCANCEL:EndDialog(hWnd,0);break;
  }
	}
	return FALSE;
}
//############################################################################//
