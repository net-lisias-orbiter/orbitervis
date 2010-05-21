// ==============================================================
// Class VideoTab (interface)
// Manages the user selections in the "Video" tab of the Orbiter
// Launchpad dialog.
// ==============================================================

#ifndef __VIDEOTAB_H
#define __VIDEOTAB_H

#include "D3D9Enum.h"

namespace oapi { class D3D9Client; }

// ==============================================================

class VideoTab {
public:
	VideoTab (oapi::D3D9Client *gc, HINSTANCE _hInst, HINSTANCE _hOrbiterInst, HWND hVideoTab);

	BOOL WndProc (HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
	// Video tab message handler

	void UpdateConfigData ();
	// copy dialog state back to parameter structure

protected:
	void Initialise (D3D9Enum_DeviceInfo *dev);
	// Initialise dialog elements

	void SelectDevice (D3D9Enum_DeviceInfo *dev);
	// Update dialog after user device selection

	void SelectDispmode (D3D9Enum_DeviceInfo *dev, BOOL bWindow);
	// Update dialog after user fullscreen/window selection

	void SelectMode (D3D9Enum_DeviceInfo *dev, DWORD idx);
	// Update dialog after fullscreen mode selection

	void SelectBPP (D3D9Enum_DeviceInfo *dev, DWORD idx);
	// Update dialog after fullscreen colour depth selection

	void SelectWidth ();
	// Update dialog after window width selection

	void SelectHeight ();
	// Update dialog after window height selection

private:
	static BOOL CALLBACK AboutDlgProc (HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

	oapi::D3D9Client *gclient;
	HINSTANCE hOrbiterInst; // orbiter instance handle
	HINSTANCE hInst;        // module instance handle
	HWND hTab;              // window handle of the video tab
};

#endif // !__VIDEOTAB_H