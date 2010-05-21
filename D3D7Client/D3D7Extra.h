// Management of the configuration dialogs under the "Extra"
// Launchpad tab

#ifndef __D3D7EXTRA_H
#define __D3D7EXTRA_H

#include "orbitersdk.h"

class D3D7Config;

class D3D7ClientCfg: public LaunchpadItem {
public:
	D3D7ClientCfg (): LaunchpadItem () {}
	char *Name ();
	char *Description ();
};

class D3D7PlanetRenderCfg: public LaunchpadItem {
public:
	D3D7PlanetRenderCfg (D3D7Config *_cfg): LaunchpadItem (), cfg(_cfg) {}
	char *Name ();
	char *Description ();
	void InitDialog (HWND hDlg);
	void Update (HWND hDlg);
	void Apply (HWND hDlg);
	void CloseDialog (HWND hDlg);
	bool clbkOpen (HWND hLaunchpad);

private:
	D3D7Config *cfg;
	static BOOL CALLBACK DlgProc (HWND, UINT, WPARAM, LPARAM);
};

#endif // !__D3D7EXTRA_H