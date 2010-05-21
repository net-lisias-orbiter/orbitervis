// ==============================================================
// Class VideoTab (implementation)
// Manages the user selections in the "Video" tab of the Orbiter
// Launchpad dialog.
// ==============================================================

// Note: must include D3D9Client.h *first* to fix warnings on VS 2003+
#include "D3D9Client.h"
#include "VideoTab.h"
#include "resource.h"
#include "resource_video.h"
#include <stdio.h>

using namespace oapi;

// ==============================================================
// Constructor

VideoTab::VideoTab (D3D9Client *gc, HINSTANCE _hInst, HINSTANCE _hOrbiterInst, HWND hVideoTab)
{
	gclient      = gc;
	hInst        = _hInst;
	hOrbiterInst = _hOrbiterInst;
	hTab         = hVideoTab;
	Initialise (gclient->CurrentDevice());
}

// ==============================================================
// Dialog message handler

BOOL VideoTab::WndProc (HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg) {
	case WM_INITDIALOG:
		return TRUE;
	case WM_COMMAND:
		switch (LOWORD(wParam)) {
		case IDC_VID_DEVICE:
			if (HIWORD(wParam) == CBN_SELCHANGE) {
				DWORD idx = SendDlgItemMessage (hWnd, IDC_VID_DEVICE, CB_GETCURSEL, 0, 0);
				D3D9Enum_DeviceInfo *dev = gclient->PickDevice (idx);
				if (idx) {
					gclient->SelectDevice (dev);
					SelectDevice (dev);
				}
				return TRUE;
			}
			break;
		case IDC_VID_MODE:
			if (HIWORD(wParam) == CBN_SELCHANGE) {
				DWORD idx;
				idx = SendDlgItemMessage (hWnd, IDC_VID_MODE, CB_GETCURSEL, 0, 0);
				SelectMode (gclient->CurrentDevice(), idx);
				return TRUE;
			}
			break;
		case IDC_VID_BPP:
			if (HIWORD(wParam) == CBN_SELCHANGE) {
				DWORD idx;
				idx = SendDlgItemMessage (hWnd, IDC_VID_BPP, CB_GETCURSEL, 0, 0);
				SelectBPP (gclient->CurrentDevice(), idx);
				return TRUE;
			}
			break;
		case IDC_VID_FULL:
			if (HIWORD(wParam) == BN_CLICKED) {
				SelectDispmode (gclient->CurrentDevice(), FALSE);
				return TRUE;
			}
			break;
		case IDC_VID_WINDOW:
			if (HIWORD(wParam) == BN_CLICKED) {
				SelectDispmode (gclient->CurrentDevice(), TRUE);
				return TRUE;
			}
			break;
		case IDC_VID_WIDTH:
			if (HIWORD(wParam) == EN_CHANGE) {
				SelectWidth ();
				return TRUE;
			}
			break;
		case IDC_VID_HEIGHT:
			if (HIWORD(wParam) == EN_CHANGE) {
				SelectHeight ();
				return TRUE;
			}
			break;
		case IDC_VID_ASPECT:
			if (HIWORD(wParam) == BN_CLICKED) {
				SelectWidth ();
				return TRUE;
			}
			break;
		case IDC_VID_INFO:
			DialogBox (hInst, MAKEINTRESOURCE(IDD_DIALOG1), hTab, AboutDlgProc);
			return TRUE;
		}
		break;
	}
	return FALSE;
}

// ==============================================================
// Initialise the Launchpad "video" tab

void VideoTab::Initialise (D3D9Enum_DeviceInfo *dev)
{
	GraphicsClient::VIDEODATA *data = gclient->GetVideoData();
	
	D3D9Enum_DeviceInfo *devlist;
	char cbuf[20];
	DWORD i, ndev;
	D3D9Enum_GetDevices (&devlist, &ndev);

	SendDlgItemMessage (hTab, IDC_VID_DEVICE, CB_RESETCONTENT, 0, 0);
	for (i = 0; i < ndev; i++) {
		SendMessage (GetDlgItem (hTab, IDC_VID_DEVICE), CB_ADDSTRING, 0,
			(LPARAM)(devlist[i].strDesc));
	}
	SendDlgItemMessage (hTab, IDC_VID_DEVICE, CB_SELECTSTRING, data->deviceidx, (LPARAM)dev->strDesc);
	SendDlgItemMessage (hTab, IDC_VID_ENUM, BM_SETCHECK, data->forceenum ? BST_CHECKED : BST_UNCHECKED, 0);
	SendDlgItemMessage (hTab, IDC_VID_STENCIL, BM_SETCHECK, data->trystencil ? BST_CHECKED : BST_UNCHECKED, 0);
	SendDlgItemMessage (hTab, IDC_VID_VSYNC, BM_SETCHECK, data->novsync ? BST_CHECKED : BST_UNCHECKED, 0);

	SetWindowText (GetDlgItem (hTab, IDC_VID_WIDTH), _itoa (data->winw, cbuf, 10));
	SetWindowText (GetDlgItem (hTab, IDC_VID_HEIGHT), _itoa (data->winh, cbuf, 10));
	SendDlgItemMessage (hTab, IDC_VID_ASPECT, BM_SETCHECK,
		data->winw == (4*data->winh)/3 || data->winh == (3*data->winw)/4 ? BST_CHECKED : BST_UNCHECKED, 0);

	SelectDevice (dev);
	SelectDispmode (dev, data->fullscreen ? FALSE:TRUE);

	ShowWindow (GetDlgItem (hTab, IDC_VID_INFO), SW_SHOW);
}

// ==============================================================
// Respond to user device selection

void VideoTab::SelectDevice (D3D9Enum_DeviceInfo *dev)
{
	DWORD i, j;
	char cbuf[256];
	D3DDISPLAYMODE &cmode = dev->ddsdFullscreenMode;
	DWORD nres = 0, *wres = new DWORD[dev->dwNumModes], *hres = new DWORD[dev->dwNumModes];
	DWORD nbpp = 0, *bpp = new DWORD[dev->dwNumModes];

	SendDlgItemMessage (hTab, IDC_VID_MODE, CB_RESETCONTENT, 0, 0);
	SendDlgItemMessage (hTab, IDC_VID_BPP, CB_RESETCONTENT, 0, 0);

	for (i = 0; i < dev->dwNumModes; i++) {
		D3DDISPLAYMODE *ddsd = dev->pddsdModes+i;
		DWORD w = ddsd->Width, h = ddsd->Height;
		for (j = 0; j < nres; j++) if (wres[j] == w && hres[j] == h) break;
		if (j == nres) wres[nres] = w, hres[nres] = h, nres++;
		DWORD bc = getBPP(ddsd->Format);
		for (j = 0; j < nbpp; j++) if (bpp[j] == bc) break;
		if (j == nbpp) bpp[nbpp++] = bc;
	}
	for (i = 0; i < nres; i++) {
		sprintf (cbuf, "%d x %d", wres[i], hres[i]);
		SendDlgItemMessage (hTab, IDC_VID_MODE, CB_ADDSTRING, 0, (LPARAM)cbuf);
		SendDlgItemMessage (hTab, IDC_VID_MODE, CB_SETITEMDATA, i, (LPARAM)(hres[i]<<16 | wres[i]));
		if (wres[i] == cmode.Width && hres[i] == cmode.Height)
			SendDlgItemMessage (hTab, IDC_VID_MODE, CB_SETCURSEL, i, 0);
	}
	for (i = 0; i < nbpp; i++) {
		sprintf (cbuf, "%d", bpp[i]);
		SendDlgItemMessage (hTab, IDC_VID_BPP, CB_ADDSTRING, 0, (LPARAM)cbuf);
		SendDlgItemMessage (hTab, IDC_VID_BPP, CB_SETITEMDATA, i, (LPARAM)(bpp[i]));
		if (bpp[i] == getBPP(cmode.Format))
			SendDlgItemMessage (hTab, IDC_VID_BPP, CB_SETCURSEL, i, 0);
	}
	for (i = 0; i < 2; i++)
		EnableWindow (GetDlgItem (hTab, IDC_VID_FULL+i), TRUE);
	SendDlgItemMessage (hTab, dev->bWindowed ? IDC_VID_WINDOW:IDC_VID_FULL, BM_CLICK, 0, 0);
	for (i = 0; i < 2; i++)
		EnableWindow (GetDlgItem (hTab, IDC_VID_FULL+i), dev->bDesktopCompatible);
	delete []wres;
	delete []hres;
	delete []bpp;
}

// ==============================================================
// Respond to user selection of fullscreen/window mode

void VideoTab::SelectDispmode (D3D9Enum_DeviceInfo *dev, BOOL bWindow)
{
	DWORD i;
	for (i = 0; i < 5; i++)
		EnableWindow (GetDlgItem (hTab, IDC_VID_STATIC5+i), !bWindow);
	for (i = 0; i < 6; i++)
		EnableWindow (GetDlgItem (hTab, IDC_VID_STATIC7+i), bWindow);
	dev->bWindowed = bWindow;
}

// ==============================================================
// Respond to user selection of fullscreen resolution

void VideoTab::SelectMode (D3D9Enum_DeviceInfo *dev, DWORD idx)
{
	DWORD i, data, w, h, mode, bpp, ibpp, usebpp;
	data = SendDlgItemMessage (hTab, IDC_VID_MODE, CB_GETITEMDATA, idx, 0);
	w    = data & 0xFFFF;
	h    = data >> 16;
	// check that this resolution is compatible with the current bpp setting
	idx  = SendDlgItemMessage (hTab, IDC_VID_BPP, CB_GETCURSEL, 0, 0);
	bpp  = SendDlgItemMessage (hTab, IDC_VID_BPP, CB_GETITEMDATA, idx, 0);
	for (i = mode = usebpp = 0; i < dev->dwNumModes; i++) {
		D3DDISPLAYMODE *ddsd = dev->pddsdModes+i;
		if (ddsd->Width != w || ddsd->Height != h) continue;
		ibpp = getBPP(ddsd->Format);
		if (ibpp == bpp)   { usebpp = ibpp; mode = i; break; } // found match
		if (ibpp > usebpp) { usebpp = ibpp; mode = i; } // best match so far
	}
	dev->dwCurrentMode = mode;
	dev->ddsdFullscreenMode = dev->pddsdModes[dev->dwCurrentMode];
	// if a bpp change was required, notify the bpp control
	if (bpp != usebpp) {
		char cbuf[20];
		SendDlgItemMessage (hTab, IDC_VID_BPP, CB_SELECTSTRING, -1,
			(LPARAM)_itoa (usebpp, cbuf, 10));
	}
}

// ==============================================================
// Respond to user selection of fullscreen colour depth

void VideoTab::SelectBPP (D3D9Enum_DeviceInfo *dev, DWORD idx)
{
	DWORD i, data, w, h, mode, bpp, iw, usew;
	bpp  = SendDlgItemMessage (hTab, IDC_VID_BPP, CB_GETITEMDATA, idx, 0);
	// check that this bitdepth is compatible with the current resolution
	idx  = SendDlgItemMessage (hTab, IDC_VID_MODE, CB_GETCURSEL, 0, 0);
	data = SendDlgItemMessage (hTab, IDC_VID_MODE, CB_GETITEMDATA, idx, 0);
	w    = data & 0xFFFF;
	h    = data >> 16;
	for (i = mode = usew = 0; i < dev->dwNumModes; i++) {
		D3DDISPLAYMODE *ddsd = dev->pddsdModes+i;
		if (getBPP(ddsd->Format) != bpp) continue;
		iw = ddsd->Width;
		if (iw == w)   { usew = iw; mode = i; break; } // found match
		if (iw > usew) { usew = iw; mode = i; }   // best match so far
	}
	dev->dwCurrentMode = mode;
	dev->ddsdFullscreenMode = dev->pddsdModes[dev->dwCurrentMode];
	// if a mode change was required, notify the mode control
	if (w != usew) {
		char cbuf[20];
		SendDlgItemMessage (hTab, IDC_VID_MODE, CB_SELECTSTRING, -1,
			(LPARAM)_itoa (usew, cbuf, 10));
	}
}

// ==============================================================
// Respond to user selection of render window width

void VideoTab::SelectWidth ()
{
	if (SendDlgItemMessage (hTab, IDC_VID_ASPECT, BM_GETCHECK, 0, 0) == BST_CHECKED) {
		char cbuf[128];
		int w, h;
		GetWindowText (GetDlgItem (hTab, IDC_VID_WIDTH),  cbuf, 127); w = atoi(cbuf);
		GetWindowText (GetDlgItem (hTab, IDC_VID_HEIGHT), cbuf, 127); h = atoi(cbuf);
		if (w != (4*h)/3) {
			h = (3*w)/4;
			SetWindowText (GetDlgItem (hTab, IDC_VID_HEIGHT), itoa (h, cbuf, 10));
		}
	}
}

// ==============================================================
// Respond to user selection of render window height

void VideoTab::SelectHeight ()
{
	if (SendDlgItemMessage (hTab, IDC_VID_ASPECT, BM_GETCHECK, 0, 0) == BST_CHECKED) {
		char cbuf[128];
		int w, h;
		GetWindowText (GetDlgItem (hTab, IDC_VID_WIDTH),  cbuf, 127); w = atoi(cbuf);
		GetWindowText (GetDlgItem (hTab, IDC_VID_HEIGHT), cbuf, 127); h = atoi(cbuf);
		if (h != (3*w)/4) {
			w = (4*h)/3;
			SetWindowText (GetDlgItem (hTab, IDC_VID_WIDTH), itoa (w, cbuf, 10));
		}
	}
}

// ==============================================================
// copy dialog state back to parameter structure

void VideoTab::UpdateConfigData ()
{
	char cbuf[128];
	DWORD i, dat, w, h, bpp, ndev, nmod;
	GraphicsClient::VIDEODATA *data = gclient->GetVideoData();

	D3D9Enum_DeviceInfo *devlist, *dev;
	D3D9Enum_GetDevices (&devlist, &ndev);

	// device parameters
	i   = SendDlgItemMessage (hTab, IDC_VID_DEVICE, CB_GETCURSEL, 0, 0);
	if (i >= ndev) i = 0; // should not happen
	dev = devlist+i;
	data->deviceidx = i;
	i   = SendDlgItemMessage (hTab, IDC_VID_MODE, CB_GETCURSEL, 0, 0);
	dat = SendDlgItemMessage (hTab, IDC_VID_MODE, CB_GETITEMDATA, i, 0);
	w   = dat & 0xFFFF;
	h   = dat >> 16;
	i   = SendDlgItemMessage (hTab, IDC_VID_BPP, CB_GETCURSEL, 0, 0);
	bpp = SendDlgItemMessage (hTab, IDC_VID_BPP, CB_GETITEMDATA, i, 0);
	nmod = dev->dwNumModes;
	data->modeidx = 0; // in case there is a problem
	for (i = 0; i < nmod; i++) {
		if (dev->pddsdModes[i].Width == w && dev->pddsdModes[i].Height == h &&
			getBPP(dev->pddsdModes[i].Format) == bpp) {
			data->modeidx = i;
			break;
		}
	}

	data->fullscreen = (SendDlgItemMessage (hTab, IDC_VID_FULL, BM_GETCHECK, 0, 0) == BST_CHECKED);
	data->novsync    = (SendDlgItemMessage (hTab, IDC_VID_VSYNC, BM_GETCHECK, 0, 0) == BST_CHECKED);
	data->trystencil = (SendDlgItemMessage (hTab, IDC_VID_STENCIL, BM_GETCHECK, 0, 0) == BST_CHECKED);
	data->forceenum  = (SendDlgItemMessage (hTab, IDC_VID_ENUM, BM_GETCHECK, 0, 0) == BST_CHECKED);
	GetWindowText (GetDlgItem (hTab, IDC_VID_WIDTH),  cbuf, 127); data->winw = atoi(cbuf);
	GetWindowText (GetDlgItem (hTab, IDC_VID_HEIGHT), cbuf, 127); data->winh = atoi(cbuf);
}

// ==============================================================

BOOL CALLBACK VideoTab::AboutDlgProc (HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg) {
	case WM_INITDIALOG: {
		char cbuf[1024];
		LoadString ((HINSTANCE)GetWindowLong (hWnd, GWL_HINSTANCE), IDS_STRING1, cbuf, 1024);
		SetWindowText (GetDlgItem (hWnd, IDC_EDIT1), cbuf);
		} return TRUE;
	case WM_COMMAND:
		switch (LOWORD(wParam)) {
		case IDOK:
		case IDCANCEL:
			EndDialog (hWnd, 0);
			break;
		}
	}
	return FALSE;
}
