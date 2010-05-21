// ====================================================================================
// File: D3D9Frame.cpp
// Desc: Class functions to implement a Direct3D app framework.
// ====================================================================================

// DX9 port: This file has been mostly rewritten. DX9 has a lot of functionality that we'd
// like to use. We no longer need to manage our own backbuffers.

#define STRICT
#include <windows.h>
#include "D3D9Frame.h"
#include "D3D9Util.h"

//-----------------------------------------------------------------------------
// Name: CD3DFramework9()
// Desc: The constructor. Clears static variables
//-----------------------------------------------------------------------------
CD3DFramework9::CD3DFramework9 ()
{
	m_hWnd               = NULL;
	m_bIsFullscreen      = FALSE;
	m_bIsTLDevice        = FALSE;
	m_bSupportStencil    = FALSE;
//	m_bIsStereo          = FALSE;
//	m_bNoVSync           = FALSE;
//	m_bSupportsMipmaps   = FALSE;
	m_dwRenderWidth      = 0L;
	m_dwRenderHeight     = 0L;
//	m_dwZBufferBitDepth  = 0L;
//	m_dwStencilBitDepth  = 0L;

//	m_pddsFrontBuffer    = NULL;
//	m_pddsBackBuffer     = NULL;
//	m_pddsBackBufferLeft = NULL;
     
//	m_pddsZBuffer        = NULL;
	m_pd3dDevice         = NULL;
//	m_pDD                = NULL;
	m_pD3D               = NULL;
//	m_dwDeviceMemType    = NULL;

//	m_ddFlipFlag         = DDFLIP_WAIT;
}

//-----------------------------------------------------------------------------
// Name: ~CD3DFramework9()
// Desc: The destructor. Deletes all objects
//-----------------------------------------------------------------------------
CD3DFramework9::~CD3DFramework9 ()
{
    DestroyObjects ();
}

//-----------------------------------------------------------------------------
// Name: DestroyObjects()
// Desc: Cleans everything up upon deletion. This code returns an error
//       if any of the objects have remaining reference counts.
//-----------------------------------------------------------------------------
HRESULT CD3DFramework9::DestroyObjects ()
{
    LONG nDD  = 0L; // Number of outstanding DDraw references
    LONG nD3D = 0L; // Number of outstanding D3DDevice references
	HRESULT hr;

//    if (m_pDD) m_pDD->SetCooperativeLevel(m_hWnd, DDSCL_NORMAL);

    // Do a safe check for releasing the D3DDEVICE. RefCount must be zero.
    if (m_pd3dDevice) {
#if 0
        // TODO: implement error handling or remove the error check
		if (FAILED (hr = m_pd3dDevice->SetTexture(0,0))) // make sure last texture is released
			/*LOGOUT_DDERR(hr)*/;
        if (0 < (nD3D = m_pd3dDevice->Release()))
            /*LOGOUT_ERR("D3DDevice object is still referenced!")*/;
#endif
        hr = m_pd3dDevice->SetTexture(0,0);
        nD3D = m_pd3dDevice->Release();
    }
    m_pd3dDevice = NULL;

    // TODO: this looks like a memory leak -- investigate it
	// RocketTwinky: This was commented out because the buffers are no longer created in DX9, so no need to release them
//    SAFE_RELEASE (m_pddsBackBuffer);
//    SAFE_RELEASE (m_pddsBackBufferLeft);
//    SAFE_RELEASE (m_pddsZBuffer);
//    SAFE_RELEASE (m_pddsFrontBuffer);
    SAFE_RELEASE (m_pD3D);

	/*
	if (m_pDD) {
        // Do a safe check for releasing DDRAW. RefCount must be zero.
        if (0 < (nDD = m_pDD->Release()))
			/*LOGOUT1P("ERROR: DDraw object is still referenced: %d", nDD)*/;
/*	}
    m_pDD = NULL;
*/
    // Return successful, unless there are outstanding DD or D3DDevice refs.
    return (nDD==0 && nD3D==0) ? S_OK : D3DFWERR_NONZEROREFCOUNT;
}

//-----------------------------------------------------------------------------
// Name: Initialize()
// Desc: Creates the internal objects for the framework
//-----------------------------------------------------------------------------
HRESULT CD3DFramework9::Initialize (HWND hWnd, D3D9Enum_DeviceInfo *pDeviceInfo, D3DDISPLAYMODE* pMode, bool bTryStencil, DWORD dwFlags)
{
    HRESULT hr;

    // Check params. Note: A NULL mode is valid for windowed modes only.
    if ((NULL==hWnd ) || (NULL==pMode && (dwFlags&D3DFW_FULLSCREEN)))
        return E_INVALIDARG;

    // Setup state for windowed/fullscreen mode
    m_hWnd          = hWnd;
//	m_bIsStereo     = FALSE;
    m_bIsFullscreen = (dwFlags & D3DFW_FULLSCREEN) ? TRUE : FALSE;
	m_bIsTLDevice   = ( pDeviceInfo->DevCaps & D3DDEVCAPS_HWTRANSFORMANDLIGHT);
//	m_bNoVSync      = (dwFlags & D3DFW_NOVSYNC) ? TRUE : FALSE;
	m_dwRenderHeight= pMode->Height;
	m_dwRenderWidth = pMode->Width;

    // Support stereoscopic viewing for fullscreen modes which support it
/*	if ((dwFlags & D3DFW_STEREO) && (dwFlags & D3DFW_FULLSCREEN))
		if (pMode->ddsCaps.dwCaps2 & DDSCAPS2_STEREOSURFACELEFT)
			m_bIsStereo = TRUE;
*/
    // Create the D3D rendering environment (surfaces, device, viewport, and so forth.)
    if (FAILED (hr = CreateEnvironment (pDeviceInfo, pMode, bTryStencil, dwFlags))) {
        DestroyObjects ();
        return hr;
    }

//	m_ddFlipFlag = DDFLIP_WAIT;
//	if (m_bIsStereo) m_ddFlipFlag |= DDFLIP_STEREO;
//	if (m_bNoVSync)  m_ddFlipFlag |= DDFLIP_NOVSYNC;

    return S_OK;
}

//-----------------------------------------------------------------------------
// Name: CreateEnvironment()
// Desc: Creates the internal objects for the framework
//-----------------------------------------------------------------------------
HRESULT CD3DFramework9::CreateEnvironment (D3D9Enum_DeviceInfo *pDeviceInfo, D3DDISPLAYMODE* pMode, bool bTryStencil, DWORD dwFlags)
{
    HRESULT hr;

    // Select the default memory type, for whether the device is HW or SW
	/*
	if (pDeviceInfo->DevType == D3DDEVTYPE_HAL )
        m_dwDeviceMemType = DDSCAPS_VIDEOMEMORY;
	else if (pDeviceInfo->DevCaps & D3DDEVCAPS_HWTRANSFORMANDLIGHT )
        m_dwDeviceMemType = DDSCAPS_VIDEOMEMORY;
    else
        m_dwDeviceMemType = DDSCAPS_SYSTEMMEMORY;
*/
    // Create the DDraw object
	/*
    hr = CreateDirectDraw (pDriverGUID, dwFlags);
    if (FAILED (hr)) return hr;

    // Create the front and back buffers, and attach a clipper
    if (dwFlags & D3DFW_FULLSCREEN) hr = CreateFullscreenBuffers (pMode);
    else                            hr = CreateWindowedBuffers ();
    if (FAILED (hr)) return hr;
*/
    // Create the Direct3D object and the Direct3DDevice object
    hr = CreateDirect3D (pDeviceInfo, pMode, bTryStencil, (dwFlags | D3DFW_NOVSYNC) != 0);
    if (FAILED (hr)) return hr;
/*
    // Create and attach the zbuffer
    if (dwFlags & D3DFW_ZBUFFER)
        hr = CreateZBuffer( pDeviceGUID );
    if (FAILED (hr)) return hr;
*/
    return S_OK;
}

//-----------------------------------------------------------------------------
// Name: EnumZBufferFormatsCallback()
// Desc: Simply returns the first matching enumerated z-buffer format
//-----------------------------------------------------------------------------
/*
static HRESULT WINAPI EnumZBufferFormatsCallback (DDPIXELFORMAT* pddpf, VOID* pContext)
{
    DDPIXELFORMAT* pddpfOut = (DDPIXELFORMAT*)pContext;

    if (pddpfOut->dwRGBBitCount == pddpf->dwRGBBitCount) {
        (*pddpfOut) = (*pddpf);
        return D3DENUMRET_CANCEL;
    }

    return D3DENUMRET_OK;
}

//-----------------------------------------------------------------------------
// Name: CreateDirectDraw()
// Desc: Create the DirectDraw interface
//-----------------------------------------------------------------------------

HRESULT CD3DFramework9::CreateDirectDraw (GUID* pDriverGUID, DWORD dwFlags)
{
	HRESULT hr;
    // Create the DirectDraw interface
    if (FAILED (hr = DirectDrawCreateEx (pDriverGUID, (VOID**)&m_pDD,
                                    IID_IDirectDraw7, NULL))) {
        //LOGOUT("ERROR: Could not create DirectDraw");
		//LOGOUT_DDERR(hr);
        return D3DFWERR_NODIRECTDRAW;
    }

    // Set the Windows cooperative level
    DWORD dwCoopFlags = DDSCL_NORMAL;
    if (m_bIsFullscreen)
        dwCoopFlags = DDSCL_ALLOWREBOOT | DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN;

    // floating point optimisation flag
    if (dwFlags & D3DFW_NO_FPUSETUP) dwCoopFlags |= DDSCL_FPUPRESERVE;
	else                             dwCoopFlags |= DDSCL_FPUSETUP;

    if (FAILED (hr = m_pDD->SetCooperativeLevel (m_hWnd, dwCoopFlags))) {
        //LOGOUT("ERROR: Couldn't set coop level");
		//LOGOUT_DDERR(hr);
        return D3DFWERR_COULDNTSETCOOPLEVEL;
    }

    // Check that we are NOT in a palettized display. That case will fail,
    // since the Direct3D framework doesn't use palettes.
    DDSURFACEDESC2 ddsd;
    ddsd.dwSize = sizeof(ddsd);
    m_pDD->GetDisplayMode (&ddsd);
    if (ddsd.ddpfPixelFormat.dwRGBBitCount <= 8) {
		//LOGOUT("ERROR: Display mode bpp <= 8");
        return D3DFWERR_INVALIDMODE;
	}

	//LOGOUT("DirectDraw interface OK");
    return S_OK;
}
*/
//-----------------------------------------------------------------------------
// Name: CreateFullscreenBuffers()
// Desc: Creates the primary and (optional) backbuffer for rendering.
//       Windowed mode and fullscreen mode are handled differently.
//-----------------------------------------------------------------------------
/*
HRESULT CD3DFramework9::CreateFullscreenBuffers (DDSURFACEDESC2* pddsd)
{
    HRESULT hr;

    // Get the dimensions of the screen bounds
    // Store the rectangle which contains the renderer
    SetRect (&m_rcScreenRect, 0, 0, pddsd->dwWidth, pddsd->dwHeight);
    m_dwRenderWidth  = m_rcScreenRect.right  - m_rcScreenRect.left;
    m_dwRenderHeight = m_rcScreenRect.bottom - m_rcScreenRect.top;

    // Set the display mode to the requested dimensions. Check for
    // 320x200x8 modes, and set flag to avoid using ModeX
    DWORD dwModeFlags = 0;

    if ((320==m_dwRenderWidth) && (200==m_dwRenderHeight) &&
        (8==pddsd->ddpfPixelFormat.dwRGBBitCount))
        dwModeFlags |= DDSDM_STANDARDVGAMODE;

    if (FAILED (m_pDD->SetDisplayMode (m_dwRenderWidth, m_dwRenderHeight,
                                pddsd->ddpfPixelFormat.dwRGBBitCount,
                                pddsd->dwRefreshRate, dwModeFlags))) {
        //LOGOUT("Can't set display mode");
        return D3DFWERR_BADDISPLAYMODE;
    }

    // Setup to create the primary surface w/backbuffer
    DDSURFACEDESC2 ddsd;
    ZeroMemory (&ddsd, sizeof(ddsd));
    ddsd.dwSize            = sizeof (ddsd);
    ddsd.dwFlags           = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
    ddsd.ddsCaps.dwCaps    = DDSCAPS_PRIMARYSURFACE | DDSCAPS_3DDEVICE |
                             DDSCAPS_FLIP | DDSCAPS_COMPLEX;
    ddsd.dwBackBufferCount = 1;

    // Support for stereoscopic viewing
    if (m_bIsStereo) {
        ddsd.ddsCaps.dwCaps  |= DDSCAPS_VIDEOMEMORY;
        ddsd.ddsCaps.dwCaps2 |= DDSCAPS2_STEREOSURFACELEFT;
    }

    // Create the primary surface
    if (FAILED (hr = m_pDD->CreateSurface (&ddsd, &m_pddsFrontBuffer, NULL))) {
        //LOGOUT("Error: Can't create primary surface");
        if (hr != DDERR_OUTOFVIDEOMEMORY) return D3DFWERR_NOPRIMARY;
        //LOGOUT("Error: Out of video memory");
        return DDERR_OUTOFVIDEOMEMORY;
    }

    // Get the backbuffer, which was created along with the primary.
    DDSCAPS2 ddscaps = { DDSCAPS_BACKBUFFER, 0, 0, 0 };
    if (FAILED (hr = m_pddsFrontBuffer->GetAttachedSurface (&ddscaps, &m_pddsBackBuffer))) {
        //LOGOUT("Error: Can't get the backbuffer");
        return D3DFWERR_NOBACKBUFFER;
    }

    // Increment the backbuffer count (for consistency with windowed mode)
    m_pddsBackBuffer->AddRef ();

    // Support for stereoscopic viewing
    if (m_bIsStereo) {
        // Get the left back buffer, which was created along with the primary.
        DDSCAPS2 ddscaps = { 0, DDSCAPS2_STEREOSURFACELEFT, 0, 0 };
        if (FAILED (hr = m_pddsBackBuffer->GetAttachedSurface (&ddscaps, &m_pddsBackBufferLeft))) {
            //LOGOUT("Error: Can't get the left back buffer");
            return D3DFWERR_NOBACKBUFFER;
        }
        m_pddsBackBufferLeft->AddRef ();
    }

	ZeroMemory (&m_ddpfBackBufferPixelFormat, sizeof (DDPIXELFORMAT));
	m_ddpfBackBufferPixelFormat.dwSize = sizeof (DDPIXELFORMAT);
	if (FAILED (hr = m_pddsBackBuffer->GetPixelFormat (&m_ddpfBackBufferPixelFormat))) {
		//LOGOUT("ERROR: Check on backbuffer pixel format failed");
		//LOGOUT_DDERR(hr);
	}

	hr = m_pddsBackBuffer->GetSurfaceDesc (&ddsd);
	
    return S_OK;
}

//-----------------------------------------------------------------------------
// Name: CreateWindowedBuffers()
// Desc: Creates the primary and (optional) backbuffer for rendering.
//       Windowed mode and fullscreen mode are handled differently.
//-----------------------------------------------------------------------------
HRESULT CD3DFramework9::CreateWindowedBuffers ()
{
    HRESULT hr;

    // Get the dimensions of the viewport and screen bounds
    GetClientRect (m_hWnd, &m_rcScreenRect);
    ClientToScreen (m_hWnd, (POINT*)&m_rcScreenRect.left);
    ClientToScreen (m_hWnd, (POINT*)&m_rcScreenRect.right);
    m_dwRenderWidth  = m_rcScreenRect.right  - m_rcScreenRect.left;
    m_dwRenderHeight = m_rcScreenRect.bottom - m_rcScreenRect.top;

    // Create the primary surface
    DDSURFACEDESC2 ddsd;
    ZeroMemory (&ddsd, sizeof(ddsd));
    ddsd.dwSize         = sizeof(ddsd);
    ddsd.dwFlags        = DDSD_CAPS;
    ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;

    if (FAILED (hr = m_pDD->CreateSurface (&ddsd, &m_pddsFrontBuffer, NULL))) {
        //LOGOUT("Error: Can't create primary surface");
        if (hr != DDERR_OUTOFVIDEOMEMORY) return D3DFWERR_NOPRIMARY;
        //LOGOUT("Error: Out of video memory");
        return DDERR_OUTOFVIDEOMEMORY;
    }

    // If in windowed-mode, create a clipper object
    LPDIRECTDRAWCLIPPER pcClipper;
    if (FAILED (hr = m_pDD->CreateClipper (0, &pcClipper, NULL))) {
        //LOGOUT("Error: Couldn't create clipper");
        return D3DFWERR_NOCLIPPER;
    }

    // Associate the clipper with the window
    pcClipper->SetHWnd (0, m_hWnd);
    m_pddsFrontBuffer->SetClipper (pcClipper);
    SAFE_RELEASE (pcClipper);

    // Create a backbuffer
    ddsd.dwFlags        = DDSD_WIDTH | DDSD_HEIGHT | DDSD_CAPS;
    ddsd.dwWidth        = m_dwRenderWidth;
    ddsd.dwHeight       = m_dwRenderHeight;
    ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN | DDSCAPS_3DDEVICE;

    if (FAILED (hr = m_pDD->CreateSurface (&ddsd, &m_pddsBackBuffer, NULL))) {
        //LOGOUT("Error: Couldn't create the backbuffer");
        if (hr != DDERR_OUTOFVIDEOMEMORY)
            return D3DFWERR_NOBACKBUFFER;
        //LOGOUT("Error: Out of video memory");
        return DDERR_OUTOFVIDEOMEMORY;
    }

	ZeroMemory (&m_ddpfBackBufferPixelFormat, sizeof (DDPIXELFORMAT));
	m_ddpfBackBufferPixelFormat.dwSize = sizeof (DDPIXELFORMAT);
	hr = m_pddsBackBuffer->GetPixelFormat (&m_ddpfBackBufferPixelFormat);
	hr = m_pddsBackBuffer->GetSurfaceDesc (&ddsd);

    return S_OK;
}
*/
//-----------------------------------------------------------------------------
// Name: CreateDirect3D()
// Desc: Create the Direct3D interface
//-----------------------------------------------------------------------------
HRESULT CD3DFramework9::CreateDirect3D (D3D9Enum_DeviceInfo *pDeviceInfo, D3DDISPLAYMODE* pMode, bool bTryStencil, bool bNoVsync)
{
	DWORD Behaviourflags = D3DCREATE_FPU_PRESERVE;	// Orbiter needs double-precision FPU

	Behaviourflags |= D3DCREATE_HARDWARE_VERTEXPROCESSING;

	if ((m_pD3D = Direct3DCreate9(D3D_SDK_VERSION)) == NULL)
		return D3DFWERR_NODIRECT3D;

	// Create the device
	D3DPRESENT_PARAMETERS pp;
	pp.BackBufferWidth = pMode->Width;
	pp.BackBufferHeight = pMode->Height;
	pp.BackBufferFormat = m_bIsFullscreen ? pMode->Format : D3DFMT_UNKNOWN;
	pp.BackBufferCount = 1;
	pp.MultiSampleType = D3DMULTISAMPLE_NONE;
	pp.MultiSampleQuality = 0;
	pp.SwapEffect = D3DSWAPEFFECT_DISCARD;
	pp.hDeviceWindow = this->m_hWnd;
	pp.Windowed = this->m_bIsFullscreen ? FALSE : TRUE;
	pp.EnableAutoDepthStencil = TRUE;
	pp.Flags = 0;
	pp.FullScreen_RefreshRateInHz = this->m_bIsFullscreen ? pMode->RefreshRate : 0;
	pp.PresentationInterval = bNoVsync ? D3DPRESENT_INTERVAL_IMMEDIATE : D3DPRESENT_INTERVAL_DEFAULT;

	D3DFORMAT depthStencil1[] = {D3DFMT_D24S8, D3DFMT_D32, D3DFMT_D16, D3DFMT_UNKNOWN};		// Modes with depth stencil
	D3DFORMAT depthStencil2[] = {D3DFMT_D32, D3DFMT_D16, D3DFMT_UNKNOWN};					// Modes with no depth stencil

	// Test supported depthstencil formats
	D3DFORMAT *depthStencil = bTryStencil ? depthStencil1 : depthStencil2;
	int index = 0;
	while ((pp.AutoDepthStencilFormat = depthStencil[index++]) != D3DFMT_UNKNOWN)
	{
		if (SUCCEEDED(m_pD3D->CheckDeviceFormat(pDeviceInfo->AdapterId, pDeviceInfo->DevType, pMode->Format,  D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, pp.AutoDepthStencilFormat)))
			break;
	}

	m_bSupportStencil = pp.AutoDepthStencilFormat == D3DFMT_D24S8;

	HRESULT hr = m_pD3D->CreateDevice(pDeviceInfo->AdapterId, pDeviceInfo->DevType, m_hWnd, Behaviourflags, &pp, &m_pd3dDevice);
	if (FAILED(hr))
		return D3DFWERR_NO3DDEVICE;
	

	// The following code checks whether the device supports mipmapped textures
    D3DCAPS9  d3dDesc;
    ZeroMemory (&d3dDesc, sizeof(D3DCAPS9 ));
    m_pd3dDevice->GetDeviceCaps (&d3dDesc);
	// check if device supports mipmaping 
	m_bSupportsMipmaps = d3dDesc.TextureCaps & D3DPTEXTURECAPS_MIPMAP ? TRUE : FALSE;

    // Finally, set the viewport for the newly created device
    D3DVIEWPORT9 vp = { 0, 0, m_dwRenderWidth, m_dwRenderHeight, 0.0f, 1.0f };
	SetRect (&m_rcScreenRect, 0, 0, m_dwRenderWidth, m_dwRenderHeight);
    m_dwRenderWidth  = m_rcScreenRect.right  - m_rcScreenRect.left;
    m_dwRenderHeight = m_rcScreenRect.bottom - m_rcScreenRect.top;


    if (FAILED (m_pd3dDevice->SetViewport (&vp))) {
        //LOGOUT("ERROR: Could not set current viewport to device");
        return D3DFWERR_NOVIEWPORT;
    }

	//LOGOUT("Direct3D interface OK");
    return S_OK;
}

//-----------------------------------------------------------------------------
// Name: CreateZBuffer()
// Desc: Internal function called by Create() to make and attach a zbuffer
//       to the renderer
//-----------------------------------------------------------------------------
/*
HRESULT CD3DFramework9::CreateZBuffer (GUID* pDeviceGUID)
{
    HRESULT hr;

    // Check if the device supports z-bufferless hidden surface removal. If so,
    // we don't really need a z-buffer
    D3DCAPS9 ddDesc;
    m_pd3dDevice->GetDeviceCaps (&ddDesc);
    if (ddDesc.RasterCaps & D3DPRASTERCAPS_ZBUFFERLESSHSR) {
		//LOGOUT("Zbuffer: not required");
        return S_OK;
	}

    // Get z-buffer dimensions from the render target
    DDSURFACEDESC2 ddsd;
    ddsd.dwSize = sizeof(ddsd);
    m_pddsBackBuffer->GetSurfaceDesc (&ddsd);

    // Setup the surface desc for the z-buffer.
    ddsd.dwFlags        = DDSD_WIDTH | DDSD_HEIGHT | DDSD_CAPS | DDSD_PIXELFORMAT;
    ddsd.ddsCaps.dwCaps = DDSCAPS_ZBUFFER | m_dwDeviceMemType;
    ddsd.ddpfPixelFormat.dwSize = 0;  // Tag the pixel format as unitialized.

    // Get an appropiate pixel format from enumeration of the formats. On the
    // first pass, we look for a zbuffer dpeth which is equal to the frame
    // buffer depth (as some cards unfornately require this).
    m_pD3D->EnumZBufferFormats (*pDeviceGUID, EnumZBufferFormatsCallback,
                                (VOID*)&ddsd.ddpfPixelFormat);
    if (0 == ddsd.ddpfPixelFormat.dwSize) {
        // Try again, just accepting any 16-bit zbuffer
        ddsd.ddpfPixelFormat.dwRGBBitCount = 16;
        m_pD3D->EnumZBufferFormats (*pDeviceGUID, EnumZBufferFormatsCallback,
                                    (VOID*)&ddsd.ddpfPixelFormat);
            
        if (0 == ddsd.ddpfPixelFormat.dwSize) {
			//LOGOUT("ERROR: Device does not support requested zbuffer format");
            return D3DFWERR_NOZBUFFER;
        }
    }

	m_dwZBufferBitDepth = ddsd.ddpfPixelFormat.dwZBufferBitDepth;
	m_dwStencilBitDepth = ddsd.ddpfPixelFormat.dwStencilBitDepth;

    // Create and attach a z-buffer
    if (FAILED (hr = m_pDD->CreateSurface (&ddsd, &m_pddsZBuffer, NULL))) {
        //LOGOUT("ERROR: Could not create a ZBuffer surface");
        if (hr != DDERR_OUTOFVIDEOMEMORY)
            return D3DFWERR_NOZBUFFER;
        //LOGOUT("ERROR: Out of video memory");
        return DDERR_OUTOFVIDEOMEMORY;
    }

    if (FAILED (m_pddsBackBuffer->AddAttachedSurface (m_pddsZBuffer))) {
        //LOGOUT("ERROR: Could not attach zbuffer to render surface");
        return D3DFWERR_NOZBUFFER;
    }

    // For stereoscopic viewing, attach zbuffer to left surface as well
    if (m_bIsStereo) {
        if (FAILED (m_pddsBackBufferLeft->AddAttachedSurface (m_pddsZBuffer))) {
            //LOGOUT("ERROR: Could not attach zbuffer to left render surface");
            return D3DFWERR_NOZBUFFER;
        }
    }

    // Finally, this call rebuilds internal structures
    if (FAILED (m_pd3dDevice->SetRenderTarget (m_pddsBackBuffer, 0L))) {
        //LOGOUT("ERROR: SetRenderTarget() failed after attaching zbuffer!");
        return D3DFWERR_NOZBUFFER;
    }

    return S_OK;
}
*/
//-----------------------------------------------------------------------------
// Name: RestoreSurfaces()
// Desc: Checks for lost surfaces and restores them if lost. Note: Don't
//       restore render surface, since it's just a duplicate ptr.
//-----------------------------------------------------------------------------
HRESULT CD3DFramework9::RestoreSurfaces ()
{
	// Restore all surfaces (including video memory vertex buffers)
//	m_pDD->RestoreAllSurfaces ();

    return S_OK;
}

//-----------------------------------------------------------------------------
// Name: Move()
// Desc: Moves the screen rect for windowed renderers
//-----------------------------------------------------------------------------
VOID CD3DFramework9::Move (INT x, INT y)
{
    if (TRUE == m_bIsFullscreen) return;
    SetRect (&m_rcScreenRect, x, y, x + m_dwRenderWidth, y + m_dwRenderHeight);
}

//-----------------------------------------------------------------------------
// Name: FlipToGDISurface()
// Desc: Puts the GDI surface in front of the primary, so that dialog
//       boxes and other windows drawing funcs may happen.
//-----------------------------------------------------------------------------
/*
HRESULT CD3DFramework9::FlipToGDISurface (BOOL bDrawFrame)
{
    if (m_pDD && m_bIsFullscreen) {
        m_pDD->FlipToGDISurface ();
        if (bDrawFrame) {
            DrawMenuBar (m_hWnd);
            RedrawWindow (m_hWnd, NULL, NULL, RDW_FRAME);
        }
    }

    return S_OK;
}

//-----------------------------------------------------------------------------
// Name: ShowFrame()
// Desc: Show the frame on the primary surface, via a blt or a flip.
//-----------------------------------------------------------------------------

HRESULT CD3DFramework9::ShowFrame ()
{
    if (NULL == m_pddsFrontBuffer)
        return D3DFWERR_NOTINITIALIZED;

    if (m_bIsFullscreen) {
        // We are in fullscreen mode, so perform a flip.
        return m_pddsFrontBuffer->Flip (NULL, m_ddFlipFlag);
    } else {
        // We are in windowed mode, so perform a blit.
        return m_pddsFrontBuffer->Blt (&m_rcScreenRect, m_pddsBackBuffer,
                                       NULL, DDBLT_WAIT, NULL);
    }
}

*/