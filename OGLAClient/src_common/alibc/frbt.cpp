//############################################################################//
// Frame button
// Made in 2007-2010 by Artlav
//############################################################################//
#include <windows.h>
#include <stdio.h>
#include <math.h>
#include "frbt.h"
#include "stdlib.h"
#include "orbitersdk.h"
#include <windowsx.h>
//############################################################################//
//############################################################################//
HWND rhwnd,hUButt;
HMODULE hliba;

DWORD btnpar;
void (__stdcall *btncall)(DWORD par);
//############################################################################//
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM,LPARAM);
//############################################################################//
void SetButton(HINSTANCE hDLL,const char *bname,const char *mname,DWORD par)
{
	HWND ownd;
	WNDCLASS w;
 btnpar=par;

	hliba=LoadLibrary(mname);
	if(!hliba) MessageBox(NULL, "Module not found.", "Error!", MB_OK); else {
  btncall=(void (__stdcall *)(DWORD)) GetProcAddress(hliba,"btncall");
  if(btncall==NULL) MessageBox(NULL,"Module error.", "Error!", MB_OK); else{ 

	  ownd=FindWindow(NULL,"Orbiter Launchpad");
	  ownd=GetWindow(ownd,GW_CHILD);
   ownd=GetWindow(ownd,GW_HWNDNEXT);
   ownd=GetWindow(ownd,GW_HWNDNEXT);
   ownd=GetWindow(ownd,GW_HWNDNEXT);
   ownd=GetWindow(ownd,GW_HWNDNEXT);
   ownd=GetWindow(ownd,GW_HWNDNEXT);
   ownd=GetWindow(ownd,GW_CHILD);
   ownd=GetWindow(ownd,GW_HWNDNEXT);

		 memset(&w,0,sizeof(WNDCLASS));
	  w.style = 0;
	  w.lpfnWndProc = WndProc;
	  w.hInstance = hDLL;
	  w.hbrBackground = GetStockBrush(WHITE_BRUSH);
	  w.lpszClassName = "ABTN";
	  RegisterClass(&w);
	  rhwnd = CreateWindow("ABTN","C Windows", WS_CHILD | WS_VISIBLE ,10,50,90,35,ownd,NULL,hDLL,NULL);
	  
   HFONT hFont=CreateFont(14,0,0,0,FW_DONTCARE,FALSE,FALSE,FALSE,ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,DEFAULT_PITCH | FF_SWISS,"Arial"); 
   hUButt=CreateWindow("BUTTON",bname,BS_DEFPUSHBUTTON | BS_MULTILINE | WS_CHILD | WS_VISIBLE | WS_TABSTOP,0,0,90,35,rhwnd,NULL,hDLL,NULL);
   SendMessage(hUButt,WM_SETFONT,WPARAM(hFont),TRUE);

   ShowWindow(rhwnd,SW_SHOW);
	  UpdateWindow(rhwnd);
 	}
	}
}
//############################################################################//
void SetButtonbeta(HINSTANCE hDLL,const char *bname,DWORD btnc,DWORD par,HWND ownd)
{
	//HWND ownd;
	WNDCLASS w;

 btncall=(void (__stdcall *)(DWORD))btnc;

/*
	ownd=FindWindow(NULL,"Orbiter Launchpad");
 ownd=GetWindow(ownd,GW_CHILD);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_HWNDNEXT);
 ownd=GetWindow(ownd,GW_CHILD);
*/

	memset(&w,0,sizeof(WNDCLASS));
	w.style = 0;
	w.lpfnWndProc = WndProc;
	w.hInstance = hDLL;
	w.hbrBackground = GetStockBrush(WHITE_BRUSH);
	w.lpszClassName = "ABTN";
	RegisterClass(&w);
	//rhwnd=CreateWindow("ABTN","C Windows",WS_CHILD | WS_VISIBLE,235,111,155,35,ownd,NULL,hDLL,NULL);
	//rhwnd=CreateWindow("ABTN","C Windows",WS_CHILD | WS_VISIBLE,30,210,355,35,ownd,NULL,hDLL,NULL);
 rhwnd=CreateWindow("ABTN","C Windows",WS_CHILD | WS_VISIBLE,30,10,355,35,ownd,NULL,hDLL,NULL);
	  
 HFONT hFont=CreateFont(14,0,0,0,FW_DONTCARE,FALSE,FALSE,FALSE,ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,DEFAULT_PITCH | FF_SWISS,"Arial"); 
 //hUButt=CreateWindow("BUTTON",bname,BS_DEFPUSHBUTTON | BS_TEXT | BS_MULTILINE | WS_CHILD | WS_VISIBLE | WS_TABSTOP,0,0,155,35,rhwnd,NULL,hDLL,NULL);
 hUButt=CreateWindow("BUTTON",bname,BS_DEFPUSHBUTTON | BS_TEXT | BS_MULTILINE | WS_CHILD | WS_VISIBLE | WS_TABSTOP,0,0,355,35,rhwnd,NULL,hDLL,NULL);
 SendMessage(hUButt,WM_SETFONT,WPARAM(hFont),TRUE);

 ShowWindow(rhwnd,SW_SHOW);
	UpdateWindow(rhwnd);
}
//############################################################################//
void DelButton(){DestroyWindow(rhwnd);}
//############################################################################//
LRESULT CALLBACK WndProc(HWND hwnd, UINT Message, WPARAM wparam,LPARAM lparam)
{
	if (Message==WM_COMMAND )
	{
		(*btncall)(btnpar);
		return 0;
	}
	return DefWindowProc(hwnd,Message,wparam,lparam);
}
//############################################################################//
