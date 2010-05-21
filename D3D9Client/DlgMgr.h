// ==============================================================
// DlgMgr.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class DialogManager (interface)
//
// Manages dialog boxes during a render session in window and
// fullscreen mode
// ==============================================================

#ifndef __DLGMGR_H
#define __DLGMGR_H

#include "debug.h"
#include <windows.h>
#include <d3d9.h>
#include <d3dx9.h>
#include <ddraw.h>

struct DIALOGENTRY {
	HINSTANCE hInst;
	HWND hDlg;
	int id;
	int psize;
	DWORD flag;
	struct TitleButton {
		DWORD DlgMsg;
		DWORD flag;
		HBITMAP hBmp;
	} tbtn[5];
	void *context;
	struct DIALOGENTRY *prev, *next;
};

class DialogManager {
public:
	DialogManager ();
	~DialogManager ();

	void Init (HWND hAppWnd, bool bFullscreen, LPDIRECT3DDEVICE9 lpD3Ddev);
	void Clear ();

	/// Open a dialog box and add it to the list of open dialogs
	HWND OpenDialog (HINSTANCE hInst, int resId, DLGPROC pDlg, void *context, DWORD flag = 0);

	/// Close a dialog box and remove it from the list
	bool CloseDialog (HWND hDlg);

	/// Refreshes either the front or back buffer with the open dialog boxes
	/// \return true if the front buffer was updated (i.e. no more page flipping required
	///   false if nothing or the back buffer was updated (page flip still required)
	bool Refresh (LPDIRECT3DSURFACE9 RenderSurface);

protected:
	/// Adds an entry to the list of open dialogs
	HWND AddEntry (HINSTANCE hInst, int id, HWND hParent, DLGPROC pDlg, void *context, DWORD flag);

	/// Removes dialog entry. If either 'hDlg' or 'id' is 0,
	/// only the other component is checked
	bool DelEntry (HWND hDlg, HINSTANCE hInst, int id);

	/// Returns window handle of dialog with identifier 'id' if it is in the list
	/// Otherwise returns 0
	HWND IsEntry (HINSTANCE hInst, int id);

private:
	LPDIRECT3DDEVICE9 d3dDev;			  // Direct3d device
	HWND hWnd;                            // render window handle

	DWORD nEntry;                         // number of dialog entries
	DIALOGENTRY *firstEntry, *lastEntry;  // linked list of dialogs

	bool fullscreen;                      // fullscreen flag
};

#endif // !__DLGMGR_H