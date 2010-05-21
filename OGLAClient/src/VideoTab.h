//############################################################################//
// Class VideoTab (interface)
// Manages the user selections in the "Video" tab of the Orbiter
// Launchpad dialog.
// Made in 2007-2010 by Artlav
// Based on Martins 2008 code
//############################################################################//
#ifndef __VIDEOTAB_H
#define __VIDEOTAB_H
//############################################################################//
#include "GraphicsAPI.h"
#include "resource_video.h"
#include <stdio.h>
//############################################################################//
namespace oapi{class OGLAClient;}
//############################################################################//
class VideoTab{
public:
	HWND hTab;              //window handle of the video tab
	VideoTab(oapi::OGLAClient *gc,HINSTANCE _hInst,HINSTANCE _hOrbiterInst,HWND hVideoTab);
	BOOL WndProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam);//Video tab message handler
	void UpdateConfigData();//copy dialog state back to parameter structure
	void Initialise();
 void(__stdcall *oglacfg_button_a)();
protected:
	void SelectDispmode(BOOL bWindow);//Update dialog after user fullscreen/window selection
	void SelectMode(DWORD idx);//Update dialog after fullscreen mode selection
	void SelectWidth();	//Update dialog after window width selection
	void SelectHeight();//Update dialog after window height selection
 void SelectFixedAspect();
private:
	static BOOL CALLBACK AboutDlgProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam);
	oapi::OGLAClient *gclient;
	HINSTANCE hOrbiterInst; //orbiter instance handle
	HINSTANCE hInst;        //module instance handle
 int aspect_idx;         //fixed aspect ratio index
};
//############################################################################//
#endif // !__VIDEOTAB_H
//############################################################################//