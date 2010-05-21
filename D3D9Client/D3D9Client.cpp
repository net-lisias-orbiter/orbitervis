// DX9 port: We no longer have access to directdraw, so no more fast-blitting functions.
// These have been translated, but the functions now used may be too slow, especially D3DXLoadSurfaceFromSurface()
// Color Keys are an issue now. They used to be set directly in the LPDIRECTDRAWSURFACE7, but we are now
// using LPDIRECT3DSURFACE9, which does not have a color key value embedded in it. Instead, it has to be
// supplied during copy actions. Color keys are now stored as private data inside the DIRECT3DSURFACE9 structures.
// The front buffer is not available in DX9. When orbiter requests operations on the front buffer by specifying a
// NULL as a SURFHANDLE, a special buffer is used to hold this data, which is merged with the output inside the
// real render loop in Scene.cpp



#define STRICT 1
#define ORBITER_MODULE
#include "orbitersdk.h"
#include "D3D9Client.h"
#include "D3D9Util.h"
#include "Scene.h"
#include "Particle.h"
#include "VVessel.h"
#include "Texture.h"
#include "MeshMgr.h"
#include "TileMgr.h"
#include "RingMgr.h"
#include "HazeMgr.h"
#include "DlgMgr.h"

using namespace oapi;

D3D9Client *g_client = 0;

// ==============================================================
// API interface
// ==============================================================

// ==============================================================
// Initialise module

DLLCLBK void InitModule (HINSTANCE hDLL)
{
	g_client = new D3D9Client (hDLL);
	if (!oapiRegisterGraphicsClient (g_client)) {
		delete g_client;
		g_client = 0;
	}
}

// ==============================================================
// Clean up module

DLLCLBK void ExitModule (HINSTANCE hDLL)
{
	if (g_client) {
		oapiUnregisterGraphicsClient (g_client);
		delete g_client;
		g_client = 0;
	}
}

// ==============================================================
// D3D9Client class implementation
// ==============================================================

D3D9Client::D3D9Client (HINSTANCE hInstance): GraphicsClient (hInstance)
{
	m_pFramework     = NULL;
	pd3dDevice       = NULL;
	hRenderWnd       = NULL;
	bFullscreen      = false;
	bStencil         = false;
	viewW = viewH    = 0;
	viewBPP          = 0;
	vtab             = NULL;
	scene            = NULL;
	meshmgr          = NULL;
	texmgr           = NULL;
	dlgmgr           = NULL;
}

// ==============================================================

D3D9Client::~D3D9Client ()
{
	SAFE_DELETE (m_pFramework);
	D3D9Enum_FreeResources ();
	if (vtab) delete vtab;
	if (scene) delete scene;
	if (meshmgr) delete meshmgr;
	if (texmgr) delete texmgr;
	if (dlgmgr) delete dlgmgr;
}

// ==============================================================

void assertSurface(SURFHANDLE h,  D3DRESOURCETYPE type)
{
	if (!h || ((LPDIRECT3DRESOURCE9)h)->GetType() != type)
	{
		int type = h ? ((LPDIRECT3DRESOURCE9)h)->GetType()  : 0;
		printf("error");
	}
}
bool D3D9Client::clbkInitialise ()
{
	DWORD i;
	char cbuf[256];

	// Perform default setup
	if (!GraphicsClient::clbkInitialise ()) return false;

	// enumerate available D3D devices
	if (FAILED (D3D9Enum_EnumerateDevices ())) {
		WriteLog ("Could not enumerate devices");
		return false;
	}

    // Select a device using user parameters from config file.
	VIDEODATA *data = GetVideoData();
	DeviceId dev_id = {data->deviceidx, data->modeidx, data->fullscreen, false};

	if (!(m_pDeviceInfo = PickDevice (&dev_id)))
		if (FAILED (D3D9Enum_SelectDefaultDevice (&m_pDeviceInfo))) {
			WriteLog ("Could not select a device");
			return false;
		}

    // Create a new CD3DFramework class. This class does all of our D3D
    // initialization and manages the common D3D objects.
    if (NULL == (m_pFramework = new CD3DFramework9())) {
		WriteLog ("Could not create D3D7 framework");
        return false;
    }

	// Output driver info to the Orbiter.log file
	D3D9Enum_DeviceInfo *pDevices;
	DWORD nDevices;
	D3D9Enum_GetDevices (&pDevices, &nDevices);
	sprintf (cbuf, "Enumerated %d devices:", nDevices);
	WriteLog (cbuf);
	for (i = 0; i < nDevices; i++) {
		sprintf (cbuf, "[%c] %s (%cW)",
			pDevices[i].guidDevice == m_pDeviceInfo->guidDevice ? 'x':' ',
			pDevices[i].strDesc, pDevices[i].bHardware ? 'H':'S');
		WriteLog (cbuf);
	}

	// Create the Launchpad video tab interface
	vtab = new VideoTab (this, ModuleInstance(), OrbiterInstance(), LaunchpadVideoTab());

	return true;
}

// ==============================================================

HWND D3D9Client::clbkCreateRenderWindow ()
{
	hRenderWnd = GraphicsClient::clbkCreateRenderWindow ();

#ifdef UNDEF
	if (VideoData.fullscreen) {
		hRenderWnd = CreateWindow (strWndClass, "[D3D9Client]",
			WS_POPUP | WS_VISIBLE,
			CW_USEDEFAULT, CW_USEDEFAULT, 10, 10, 0, 0, hModule, 0);
	} else {
		hRenderWnd = CreateWindow (strWndClass, strWndTitle,
			WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_VISIBLE,
			CW_USEDEFAULT, CW_USEDEFAULT, VideoData.winw, VideoData.winh, 0, 0, hModule, 0);
	}
#endif
	SetWindowText (hRenderWnd, "[D3D9Client]");

	Initialise3DEnvironment();

	return hRenderWnd;
}

// ==============================================================

void D3D9Client::clbkPostCreation ()
{
	if (scene) scene->Initialise();
}

// ==============================================================

void D3D9Client::clbkDestroyRenderWindow ()
{
	GraphicsClient::clbkDestroyRenderWindow();
	Cleanup3DEnvironment();
	hRenderWnd = NULL;
}

// ==============================================================

void D3D9Client::clbkRenderScene ()
{
	scene->Render();
}

// ==============================================================

bool D3D9Client::clbkDisplayFrame ()
{
	Output2DOverlay(p2dOverlaySurface);
//	if (!dlgmgr->Refresh (RenderSurface))
//		m_pFramework->ShowFrame();

	// check for lost surfaces here!
	return true;
}

// ==============================================================

void D3D9Client::clbkStoreMeshPersistent (MESHHANDLE hMesh, const char *fname)
{
	meshmgr->StoreMesh (hMesh);
}
// =======================================================================
// Particle stream functions
// ==============================================================

ParticleStream *D3D9Client::clbkCreateParticleStream (PARTICLESTREAMSPEC *pss)
{
	return NULL;
}

// =======================================================================

ParticleStream *D3D9Client::clbkCreateExhaustStream (PARTICLESTREAMSPEC *pss,
	OBJHANDLE hVessel, const double *lvl, const VECTOR3 *ref, const VECTOR3 *dir)
{
	ExhaustStream *es = new ExhaustStream (this, hVessel, lvl, ref, dir, pss);
	scene->AddParticleStream (es);
	return es;
}

// =======================================================================

ParticleStream *D3D9Client::clbkCreateExhaustStream (PARTICLESTREAMSPEC *pss,
	OBJHANDLE hVessel, const double *lvl, const VECTOR3 &ref, const VECTOR3 &dir)
{
	ExhaustStream *es = new ExhaustStream (this, hVessel, lvl, ref, dir, pss);
	scene->AddParticleStream (es);
	return es;
}

// ======================================================================

ParticleStream *D3D9Client::clbkCreateReentryStream (PARTICLESTREAMSPEC *pss,
	OBJHANDLE hVessel)
{
	ReentryStream *rs = new ReentryStream (this, hVessel, pss);
	scene->AddParticleStream (rs);
	return rs;
}

// ======================================================================

bool D3D9Client::clbkParticleStreamExists (const ParticleStream *ps)
{
	return false;
}

// ==============================================================


// ==============================================================

SURFHANDLE D3D9Client::clbkLoadTexture (const char *fname, DWORD flags)
{
	if (!texmgr) return NULL;
	LPDIRECT3DTEXTURE9 tex = NULL;

	if (flags & 8) // load managed
		texmgr->GetTexture (fname, &tex);
	else           // load individual
		texmgr->LoadTexture (fname, &tex);

	return (SURFHANDLE)tex;
}

// ==============================================================

void D3D9Client::clbkReleaseTexture (SURFHANDLE hTex)
{
	assertSurface(hTex, D3DRTYPE_TEXTURE );
	((LPDIRECT3DTEXTURE9)hTex)->Release();
}

// ==============================================================

HWND D3D9Client::clbkOpenDialog (HINSTANCE hInst, int resId, DLGPROC pDlg, void *context, DWORD flag)
{
	return dlgmgr->OpenDialog (hInst, resId, pDlg, context, flag);
}

// ==============================================================

bool D3D9Client::clbkCloseDialog (HWND hDlg)
{
	return dlgmgr->CloseDialog (hDlg);
}

// ==============================================================

void D3D9Client::clbkNewVessel (OBJHANDLE hVessel)
{
	scene->NewVessel (hVessel);
}

// ==============================================================
void D3D9Client::clbkDeleteVessel (OBJHANDLE hVessel)
{
	scene->DeleteVessel (hVessel);
}

// ==============================================================

void D3D9Client::clbkVesselEvent (OBJHANDLE hVessel, DWORD event, void *context)
{
	scene->VesselEvent (hVessel, event, context);
}

// ==============================================================

HRESULT D3D9Client::Initialise3DEnvironment ()
{
	HRESULT hr;
	VIDEODATA *data = GetVideoData();
	DWORD dwFrameworkFlags = D3DFW_ZBUFFER;

	if (data->fullscreen) dwFrameworkFlags |= D3DFW_FULLSCREEN;
	if (data->novsync)    dwFrameworkFlags |= D3DFW_NOVSYNC;
	m_pDeviceInfo->ddsdFullscreenMode.Height = data->winh;
	m_pDeviceInfo->ddsdFullscreenMode.Width= data->winw;

	if (SUCCEEDED (hr = m_pFramework->Initialize (hRenderWnd, m_pDeviceInfo, &m_pDeviceInfo->ddsdFullscreenMode, data->trystencil, dwFrameworkFlags))) {
		WriteLog ("3D environment ok");

//		pDD        = m_pFramework->GetDirectDraw();
        pD3D       = m_pFramework->GetDirect3D();
        pd3dDevice = m_pFramework->GetD3DDevice();

		// Get dimensions of the render surface 
		D3DDISPLAYMODE DisplayMode;
		pd3dDevice->GetDisplayMode(0, &DisplayMode);
		viewW = data->winw;
		viewH = data->winh;
		viewBPP = getBPP(DisplayMode.Format);
		
		pd3dDevice->CreateTexture(viewW, viewH, 1, D3DUSAGE_RENDERTARGET, DisplayMode.Format, D3DPOOL_DEFAULT, &p2dOverlayTexture, NULL);
		pd3dDevice->CreateOffscreenPlainSurface(viewW,viewH,DisplayMode.Format, D3DPOOL_DEFAULT, &p2dOverlaySurface, NULL);
		
		// Get additional parameters
		bFullscreen = (m_pFramework->IsFullscreen() ? true:false);
		bStencil = data->trystencil && m_pFramework->HasStencil();

		// Output some render parameters to the log
		LogRenderParams();

		// Create the mesh manager instance
		meshmgr = new MeshManager (this);

		// Create the texture manager instance
		texmgr = new TextureManager (this);

		// Create the dialog manager instance
		dlgmgr = new DialogManager;
		dlgmgr->Init (hRenderWnd, data->fullscreen, pd3dDevice);

		// Device-specific initialisations
		TileManager::GlobalInit (this);
		RingManager::GlobalInit (this);
		HazeManager::GlobalInit (this);
		D3D9ParticleStream::GlobalInit (this);
		vObject::GlobalInit (this);
		vVessel::GlobalInit (this);

		// Create scene instance
		scene = new Scene (this, viewW, viewH);
	} else {
		WriteLog ("Could not initialise 3D environment");
	}
	return hr;
}

// ==============================================================

void D3D9Client::Cleanup3DEnvironment ()
{
	if (scene) {
		delete scene;
		scene = NULL;
	}
	if (texmgr) {
		delete texmgr;
		texmgr = NULL;
	}
	if (dlgmgr) {
		delete dlgmgr;
		dlgmgr = NULL;
	}
	p2dOverlaySurface->Release();
	p2dOverlayTexture->Release();
	TileManager::GlobalExit();
	D3D9ParticleStream::GlobalExit();
	vVessel::GlobalExit();
	m_pFramework->DestroyObjects();
	pd3dDevice = NULL;
	viewW = viewH = 0;
}

// ==============================================================

void D3D9Client::Output2DOverlay (LPDIRECT3DSURFACE9 RenderSurface)
{
	// Write out the orbiter debug string
	const char *msg = oapiDebugString();
	if (msg[0]) {
		HDC hDC;
		RenderSurface->GetDC(&hDC);
		ExtTextOut (hDC, 0, viewH-16, 0, NULL, msg, strlen(msg), NULL);
		RenderSurface->ReleaseDC (hDC);
	}
}

// ==============================================================

D3D9Enum_DeviceInfo *D3D9Client::PickDevice (DeviceId *id)
{
	D3D9Enum_DeviceInfo *devlist, *dv;
	DWORD ndev;
	D3D9Enum_GetDevices (&devlist, &ndev);

	if (!id || id->dwDevice < 0 || id->dwDevice >= ndev)
		return NULL;
	dv = devlist + id->dwDevice;

	if (id->dwMode >= 0 && id->dwMode < dv->dwNumModes)
		dv->dwCurrentMode = id->dwMode;
	else
		dv->dwCurrentMode = 0;
	dv->ddsdFullscreenMode = dv->pddsdModes[dv->dwCurrentMode];

	if (!id->bFullscreen && dv->bDesktopCompatible)
		dv->bWindowed = TRUE;
	else
		dv->bWindowed = FALSE;

	if (!id->bStereo && dv->bStereoCompatible)
		dv->bStereo = TRUE;
	else
		dv->bStereo = FALSE;

	return dv;
}

// ==============================================================
// copy video options from the video tab

void D3D9Client::clbkRefreshVideoData ()
{
	if (vtab)
		vtab->UpdateConfigData();
}

// ==============================================================
// Fullscreen mode flag

bool D3D9Client::clbkFullscreenMode () const
{
	return bFullscreen;
}

// ==============================================================
// return the dimensions of the render viewport

void D3D9Client::clbkGetViewportSize (DWORD *width, DWORD *height) const
{
	*width = viewW, *height = viewH;
}

// ==============================================================
// Returns a specific render parameter

bool D3D9Client::clbkGetRenderParam (DWORD prm, DWORD *value) const
{
	/*
	switch (prm) {
	case RP_COLOURDEPTH:
		*value = viewBPP;
		return true;
	case RP_ZBUFFERDEPTH:
		* value = GetFramework()->GetZBufferBitDepth();
		return true;
	case RP_STENCILDEPTH:
		*value = GetFramework()->GetStencilBitDepth();
		return true;
	}*/
	switch (prm) {
	case RP_COLOURDEPTH:
		*value = viewBPP;
		return true;
	case RP_ZBUFFERDEPTH:
		* value = 16; 
		return true;
	case RP_STENCILDEPTH:
		*value = 16;
		return true;
	}

	return false;
}

// ==============================================================
// Message handler for render window

LRESULT D3D9Client::RenderWndProc (HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg) {
    case WM_MOVE:
        // If in windowed mode, move the Framework's window
        if (m_pFramework && m_pDeviceInfo->bWindowed)
            m_pFramework->Move ((SHORT)LOWORD(lParam), (SHORT)HIWORD(lParam));
        break;
	}
	return GraphicsClient::RenderWndProc (hWnd, uMsg, wParam, lParam);
}

// ==============================================================
// Message handler for Launchpad "video" tab

BOOL D3D9Client::LaunchpadVideoWndProc (HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	if (vtab)
		return vtab->WndProc (hWnd, uMsg, wParam, lParam);
	else
		return FALSE;
}

// ==============================================================

void D3D9Client::LogRenderParams () const
{
	char cbuf[256];

	sprintf (cbuf, "Viewport: %s %d x %d",
		bFullscreen ? "Fullscreen":"Window", viewW, viewH);
	WriteLog (cbuf);
	strcpy (cbuf, "Hardware T&L capability: ");
	strcat (cbuf, GetFramework()->IsTLDevice() ? "Yes":"No");
	WriteLog (cbuf);
	/*
	if (GetFramework()->GetZBufferBitDepth()) {
		sprintf (cbuf, "Z-buffer depth: %d bit", GetFramework()->GetZBufferBitDepth());
		WriteLog (cbuf);
	}
	if (GetFramework()->GetStencilBitDepth()) {
		sprintf (cbuf, "Stencil buffer depth: %d bit", GetFramework()->GetStencilBitDepth());
		WriteLog (cbuf);
	}*/
}

// ==============================================================

void D3D9Client::WriteLog (const char *msg) const
{
	char cbuf[256] = "D3D9Client: ";
	strcpy (cbuf+12, msg);
	oapiWriteLog (cbuf);
}


// =======================================================================
// Surface functions
// =======================================================================
SURFHANDLE D3D9Client::clbkCreateSurface (DWORD w, DWORD h)
{

	LPDIRECT3DSURFACE9 surf;
	if (FAILED(pd3dDevice->CreateOffscreenPlainSurface(w, h, m_pDeviceInfo->ddsdFullscreenMode.Format, D3DPOOL_DEFAULT, &surf, NULL)))
			return NULL;
	return (SURFHANDLE)surf;
}

bool D3D9Client::clbkReleaseSurface (SURFHANDLE surf)
{
	assertSurface(surf, D3DRTYPE_SURFACE);
	if (surf) {
		((LPDIRECT3DSURFACE9)surf)->Release();
		return true;
	} else
		return false;
}

bool D3D9Client::clbkGetSurfaceSize (SURFHANDLE surf, DWORD *w, DWORD *h)
{
	assertSurface(surf, D3DRTYPE_SURFACE);
	LPDIRECT3DSURFACE9 surface = (LPDIRECT3DSURFACE9) surf;
	D3DSURFACE_DESC desc;

	surface->GetDesc(&desc);
	*w = desc.Width;
	*h = desc.Height;
	return true;
}

bool D3D9Client::clbkSetSurfaceColourKey (SURFHANDLE surf, DWORD ckey)
{
//	DDCOLORKEY ck = {ckey,ckey};
//	((LPDIRECTDRAWSURFACE7)surf)->SetColorKey (DDCKEY_SRCBLT, &ck);
	// {C2E805B3-8EFA-4198-BAB6-ED4BC13D8AD3}
	assertSurface(surf, D3DRTYPE_SURFACE);
	D3DCOLOR color = (D3DCOLOR) ckey;
	LPDIRECT3DRESOURCE9 resource = (LPDIRECT3DRESOURCE9) surf;
	resource->SetPrivateData(ColorKeyGUID, &color, sizeof(color), 0);
	return true;
}
D3DCOLOR D3D9Client::GetColorKey(SURFHANDLE surf) const
{
	D3DCOLOR value;
	assertSurface(surf, D3DRTYPE_SURFACE);
	DWORD DataSize = sizeof(value);
	LPDIRECT3DRESOURCE9 resource = (LPDIRECT3DRESOURCE9) surf;
	if (FAILED(resource->GetPrivateData(ColorKeyGUID, &value, &DataSize)))
		return 0;
	return value;
}

DWORD D3D9Client::clbkGetDeviceColour (BYTE r, BYTE g, BYTE b)
{
	return D3DCOLOR_XRGB(r, g, b);
}


// =======================================================================
// Blitting functions
// =======================================================================

bool D3D9Client::clbkBlt (SURFHANDLE tgt, DWORD tgtx, DWORD tgty, SURFHANDLE src, DWORD flag) const
{
	LPDIRECT3DSURFACE9 ps_tgt=(LPDIRECT3DSURFACE9)tgt;
	LPDIRECT3DSURFACE9 ps_src = (LPDIRECT3DSURFACE9)src;
	D3DSURFACE_DESC Desc;
	if (!ps_tgt)
		ps_tgt = p2dOverlaySurface;
	assertSurface(ps_tgt, D3DRTYPE_SURFACE);
	assertSurface(src, D3DRTYPE_SURFACE);

	ps_src->GetDesc(&Desc);
	POINT point = {tgtx, tgty};
	RECT rect = { tgtx, tgty, tgtx+Desc.Width, tgty+Desc.Height } ;
	pd3dDevice->StretchRect(ps_src, NULL, ps_tgt, &rect, D3DTEXF_NONE);
	//D3DXLoadSurfaceFromSurface(ps_tgt, NULL, &rect, ps_src, NULL, NULL, D3DX_FILTER_NONE, GetColorKey(tgt));

//	ps_tgt->BltFast (tgtx, tgty, ps_src, NULL, DDBLTFAST_WAIT | flag);
	return true;
}

bool D3D9Client::clbkBlt (SURFHANDLE tgt, DWORD tgtx, DWORD tgty, SURFHANDLE src, DWORD srcx, DWORD srcy, DWORD w, DWORD h, DWORD flag) const
{
	LPDIRECT3DSURFACE9 ps_tgt = (LPDIRECT3DSURFACE9)tgt;
	if (!ps_tgt)
		ps_tgt = p2dOverlaySurface;
assertSurface(ps_tgt, D3DRTYPE_SURFACE);
assertSurface(src, D3DRTYPE_SURFACE);
	RECT srcr = {srcx, srcy, srcx+w, srcy+h};
	RECT tgtr = {tgtx, tgty, tgtx+w, tgty+h};
	LPDIRECT3DSURFACE9 ps_src = (LPDIRECT3DSURFACE9)src;
	//D3DXLoadSurfaceFromSurface(ps_tgt, NULL, &tgtr, ps_src, NULL, &srcr, D3DX_FILTER_NONE, GetColorKey(tgt));
	pd3dDevice->StretchRect(ps_src, &srcr, ps_tgt, &tgtr, D3DTEXF_NONE);

//	ps_tgt->BltFast (tgtx, tgty, ps_src, &srcr, DDBLTFAST_WAIT | flag);
	return true;	
}

bool D3D9Client::clbkScaleBlt (SURFHANDLE tgt, DWORD tgtx, DWORD tgty, DWORD tgtw, DWORD tgth,
		                       SURFHANDLE src, DWORD srcx, DWORD srcy, DWORD srcw, DWORD srch, DWORD flag) const
{
	LPDIRECT3DSURFACE9 ps_tgt = (LPDIRECT3DSURFACE9)tgt;
	LPDIRECT3DSURFACE9 ps_src = (LPDIRECT3DSURFACE9)src;
	if (!ps_tgt)
		ps_tgt = p2dOverlaySurface;
assertSurface(ps_tgt, D3DRTYPE_SURFACE);
assertSurface(src, D3DRTYPE_SURFACE);
	RECT srcr = {srcx, srcy, srcx+srcw, srcy+srch};
	RECT tgtr = {tgtx, tgty, tgtx+tgtw, tgty+tgth};
	pd3dDevice->StretchRect(ps_src, &srcr, ps_tgt, &tgtr, D3DTEXF_LINEAR);
	//D3DXLoadSurfaceFromSurface(ps_tgt, NULL, &tgtr, ps_src, NULL, &srcr, D3DX_FILTER_NONE, GetColorKey(tgt));
//	ps_tgt->Blt (&tgtr, ps_src, &srcr, DDBLT_WAIT | flag, 0);
	return true;
}

bool D3D9Client::clbkFillSurface (SURFHANDLE surf, DWORD col) const
{
	assertSurface(surf, D3DRTYPE_SURFACE);
	return (pd3dDevice->ColorFill((LPDIRECT3DSURFACE9)surf, NULL, col) == D3D_OK);
}

bool D3D9Client::clbkFillSurface (SURFHANDLE surf, DWORD tgtx, DWORD tgty, DWORD w, DWORD h, DWORD col) const
{
	assertSurface(surf, D3DRTYPE_SURFACE);
	RECT r = {tgtx, tgty, tgtx+w, tgty+h};
	return (pd3dDevice->ColorFill((LPDIRECT3DSURFACE9)surf, &r, col) == D3D_OK);
}

// =======================================================================
// GDI functions
// =======================================================================
HDC D3D9Client::clbkGetSurfaceDC (SURFHANDLE surf)
{
	LPDIRECT3DSURFACE9 ps = (LPDIRECT3DSURFACE9)surf;
	if (!ps)
		ps = p2dOverlaySurface;
	assertSurface(ps, D3DRTYPE_SURFACE);
	HDC hDC;
	ps->GetDC (&hDC);
	return hDC;
}

void D3D9Client::clbkReleaseSurfaceDC (SURFHANDLE surf, HDC hDC)
{
	LPDIRECT3DSURFACE9 ps = (LPDIRECT3DSURFACE9)surf;
	if (!ps)
		ps = p2dOverlaySurface;
assertSurface(ps, D3DRTYPE_SURFACE);
	ps->ReleaseDC (hDC);
}

const GUID D3D9Client::ColorKeyGUID = { 0xc2e805b3, 0x8efa, 0x4198, { 0xba, 0xb6, 0xed, 0x4b, 0xc1, 0x3d, 0x8a, 0xd3 } };


//-----------------------------------------------------------------------------
// Name: ConfirmDevice()
// Desc: Allow application to reject 3D devices during enumeration
//-----------------------------------------------------------------------------
/*
HRESULT clbkConfirmDevice (DDCAPS*, D3DDEVICEDESC7*)
{
	// put checks in here if desired - currently we admit all devices
	return S_OK;
}
*/