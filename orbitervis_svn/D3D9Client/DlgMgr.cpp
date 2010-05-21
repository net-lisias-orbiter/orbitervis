// ==============================================================
// DlgMgr.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class DialogManager (implementation)
//
// Manages dialog boxes during a render session in window and
// fullscreen mode
// ==============================================================

// DX9 port: This file needs work. It's probably broken. The refresh()
// function retrieves some DC's, which are unavailable in DX9.

#include "DlgMgr.h"
#include "OrbiterAPI.h"
#include <stdio.h>

static DIALOGENTRY *de_create = 0;

DialogManager::DialogManager ()
{
	d3dDev = NULL;
	nEntry = 0;
	firstEntry = NULL;
	lastEntry = NULL;
	fullscreen = true;
}

DialogManager::~DialogManager ()
{
	Clear();
}

void DialogManager::Init (HWND hAppWnd, bool bFullscreen, LPDIRECT3DDEVICE9 lpD3Ddev)
{
	Clear();
	hWnd        = hAppWnd;
	fullscreen  = bFullscreen;
	d3dDev      = lpD3Ddev;
}

void DialogManager::Clear ()
{
	DIALOGENTRY *tmp;
	while (firstEntry) {
		tmp = firstEntry;
		firstEntry = firstEntry->next;
		delete tmp;
	}
	lastEntry = NULL;
	nEntry = 0;
}

HWND DialogManager::OpenDialog (HINSTANCE hInst, int resId, DLGPROC pDlg, void *context, DWORD flag)
{
	if ((flag & DLG_ALLOWMULTI) == 0)
		if (IsEntry (hInst, resId)) return NULL; // already open, and multiple instances not allowed
	return AddEntry (hInst, resId, hWnd, pDlg, context, flag);
}

bool DialogManager::CloseDialog (HWND hDlg)
{
	if (!DelEntry (hDlg, 0, 0)) return false;
	DestroyWindow (hDlg);

	return true;
}

bool DialogManager::Refresh (LPDIRECT3DSURFACE9 RenderSurface)
{
	if (!nEntry || !fullscreen) return false;

    return false;   // must return a known value here!

/* TODO: FIX THIS!
	if (clipper) {
		front->SetClipper (clipper);
		front->Blt(NULL, back, NULL, DDBLT_WAIT, NULL);
		return true;
		// true: indicates that the render target is already copied (no flipping required)
	} else {
		RECT rc;
		int x, y, cx, cy;
		HDC	hdcScreen, hdcBackBuffer;
		HRGN hrgn;
		DIALOGENTRY *tmp;
		hdcScreen = GetDC(NULL);
		back->GetDC (&hdcBackBuffer);
		for (tmp = firstEntry; tmp; tmp = tmp->next) { // need to ensure the right window order here!
			HWND hDlg = tmp->hDlg;
			GetWindowRect (hDlg, &rc);
			x  = rc.left;
			y  = rc.top;
			cx = rc.right - rc.left;
			cy = rc.bottom - rc.top;

			// If window has a complex region associated with it, be sure to include it in the draw
			hrgn = CreateRectRgn(0, 0, 0, 0);
			if (GetWindowRgn(hDlg, hrgn) == COMPLEXREGION) {
				OffsetRgn(hrgn, rc.left, rc.top);
				SelectClipRgn(hdcBackBuffer, hrgn);
			}

			BitBlt (hdcBackBuffer, x, y, cx, cy, hdcScreen, x, y, SRCCOPY);

			// Remove clipping region and clean up
			SelectClipRgn (hdcBackBuffer, NULL);
			DeleteObject(hrgn);
		}
		back->ReleaseDC (hdcBackBuffer);
		ReleaseDC (NULL, hdcScreen);
		return false;
		// false: indicates that the page still needs to be flipped
	}
	*/
}

HWND DialogManager::AddEntry (HINSTANCE hInst, int id, HWND hParent, DLGPROC pDlg, void *context, DWORD flag)
{
	DIALOGENTRY *tmp = new DIALOGENTRY;
	de_create    = tmp;
	tmp->hInst   = hInst;
	tmp->id      = id;
	tmp->flag    = flag;
	tmp->context = context;

	memset (tmp->tbtn, 0, 5*sizeof(DIALOGENTRY::TitleButton));
	int i = 0;
	if (flag & DLG_CAPTIONCLOSE) tmp->tbtn[i++].DlgMsg = IDCANCEL;
	if (flag & DLG_CAPTIONHELP)  tmp->tbtn[i++].DlgMsg = IDHELP;

//	if (hParent) dd->FlipToGDISurface();
		
	tmp->hDlg = CreateDialogParam (hInst, MAKEINTRESOURCE(id),
        hParent, pDlg, (LPARAM)context);

	tmp->prev    = lastEntry;
	tmp->next    = NULL;
	SetWindowLong (tmp->hDlg, DWL_USER, (LONG)tmp);

	if (lastEntry)
		lastEntry->next = tmp;
	else
		firstEntry = tmp;

	lastEntry = tmp;
	nEntry++;

	RECT r;
	ShowWindow (tmp->hDlg, SW_SHOWNOACTIVATE);
	GetWindowRect (tmp->hDlg, &r);
	tmp->psize = r.bottom-r.top;
	de_create = 0;

	return tmp->hDlg;
}

bool DialogManager::DelEntry (HWND hDlg, HINSTANCE hInst, int id)
{
	DIALOGENTRY *tmp;
	for (tmp = firstEntry; tmp; tmp = tmp->next) {
		if (hDlg && hDlg != tmp->hDlg) continue;
		if (hInst && hInst != tmp->hInst) continue;
		if (id && id != tmp->id) continue;

		if (tmp == firstEntry) firstEntry = tmp->next;
		if (tmp == lastEntry)  lastEntry  = tmp->prev;
		if (tmp->prev) tmp->prev->next = tmp->next;
		if (tmp->next) tmp->next->prev = tmp->prev;
		delete tmp;
		nEntry--;
		return true;
	}
	return false;
}

HWND DialogManager::IsEntry (HINSTANCE hInst, int id)
{
	DIALOGENTRY *tmp = firstEntry;
	while (tmp) {
		if (tmp->hInst == hInst && tmp->id == id) return tmp->hDlg;
		tmp = tmp->next;
	}
	return 0;
}
