// ====================================================================================
// File: D3D9Frame.h
// Desc: Class to manage the Direct3D environment objects
//
//       The class is initialized with the Initialize() function, after which
//       the Get????() functions can be used to access the objects needed for
//       rendering. If the device or display needs to be changed, the
//       ChangeDevice() function can be called. If the display window is moved
//       the changes need to be reported with the Move() function.
//
//       After rendering a frame, the ShowFrame() function filps or blits the
//       backbuffer contents to the primary. If surfaces are lost, they can be
//       restored with the RestoreSurfaces() function. Finally, if normal
//       Windows output is needed, the FlipToGDISurface() provides a GDI
//       surface to draw on.
// ====================================================================================

#ifndef D3D9Frame_H
#define D3D9Frame_H

#include "debug.h"
#include <d3d9.h>
#include <d3dx9.h>
#include "D3D9Enum.h"

//-----------------------------------------------------------------------------
// Name: CD3DFramework9
// Desc: The Direct3D sample framework class for DX7. Maintains the D3D
//       surfaces and device used for 3D rendering.
//-----------------------------------------------------------------------------
class CD3DFramework9
{
    // Internal variables for the framework class
    HWND                 m_hWnd;               // The window object
    BOOL                 m_bIsFullscreen;      // Fullscreen vs. windowed
	BOOL				 m_bIsTLDevice;        // device supports hardware transform & lighting
//    BOOL                 m_bIsStereo;          // Stereo view mode
//	BOOL				 m_bNoVSync;           // don't use vertical sync in fullscreen
	BOOL				 m_bSupportStencil;	   // Supports stencil buffer
	BOOL                 m_bSupportsMipmaps;
    DWORD                m_dwRenderWidth;      // Dimensions of the render target
    DWORD                m_dwRenderHeight;
    RECT                 m_rcScreenRect;       // Screen rect for window
//    LPDIRECTDRAW7        m_pDD;                // The DirectDraw object
    LPDIRECT3D9          m_pD3D;               // The Direct3D object
    LPDIRECT3DDEVICE9    m_pd3dDevice;         // The D3D device
//    LPDIRECTDRAWSURFACE7 m_pddsFrontBuffer;    // The primary surface
//    LPDIRECT3DSURFACE9   m_rendertarget;       // The render target surface
//    LPDIRECTDRAWSURFACE7 m_pddsBackBufferLeft; // For stereo modes
//    LPDIRECTDRAWSURFACE7 m_pddsZBuffer;        // The zbuffer surface
//    DWORD                m_dwDeviceMemType;
//	DDPIXELFORMAT		 m_ddpfBackBufferPixelFormat;
//	DWORD				 m_dwZBufferBitDepth;  // Bit depth of z-buffer
//	DWORD                m_dwStencilBitDepth;  // Bit depth of stencil buffer (0 if none)
//	DWORD                m_ddFlipFlag;

    // Internal functions for the framework class
//    HRESULT CreateZBuffer (GUID*);
//    HRESULT CreateFullscreenBuffers (DDSURFACEDESC2*);
//    HRESULT CreateWindowedBuffers ();
//    HRESULT CreateDirectDraw (GUID*, DWORD);

	HRESULT CreateDirect3D (D3D9Enum_DeviceInfo *pDeviceInfo, D3DDISPLAYMODE* pMode, bool bTryStencil, bool bNoVsync);
	HRESULT CreateEnvironment (D3D9Enum_DeviceInfo *pDeviceInfo, D3DDISPLAYMODE* pMode, bool bTryStencil, DWORD dwFlags);

public:
    // Access functions for DirectX objects
//    inline LPDIRECTDRAW7        GetDirectDraw() const        { return m_pDD; }
    inline LPDIRECT3D9          GetDirect3D() const          { return m_pD3D; }
    inline LPDIRECT3DDEVICE9    GetD3DDevice() const         { return m_pd3dDevice; }
//    inline LPDIRECTDRAWSURFACE7 GetFrontBuffer() const       { return m_pddsFrontBuffer; }
//    inline LPDIRECTDRAWSURFACE7 GetBackBuffer() const        { return m_pddsBackBuffer; }
//    inline LPDIRECT3DSURFACE9 GetRenderSurface() const     { return m_rendertarget; }
//    inline LPDIRECTDRAWSURFACE7 GetRenderSurfaceLeft() const { return m_pddsBackBufferLeft; }
//    inline DWORD                GetRenderWidth() const       { return m_dwRenderWidth; }      // Dimensions of the render target
//  inline DWORD                GetRenderHeight() const	     { return m_dwRenderHeight; }      // Dimensions of the render target
//	inline DWORD                GetDeviceMemType() const     { return m_dwDeviceMemType; }
//	inline DWORD                GetZBufferBitDepth() const   { return m_dwZBufferBitDepth; }
//	inline DWORD                GetStencilBitDepth() const   { return m_dwStencilBitDepth; }
//	inline BOOL                 SupportsMipmaps() const      { return m_bSupportsMipmaps; }
//	inline const RECT          &GetScreenRect() const        { return m_rcScreenRect; }

    // Functions to aid rendering
    HRESULT RestoreSurfaces();
//    HRESULT ShowFrame();
    HRESULT FlipToGDISurface( BOOL bDrawFrame = FALSE );

    // Functions for managing screen and viewport bounds
    inline BOOL    IsFullscreen() const         { return m_bIsFullscreen; }
	inline BOOL    IsTLDevice() const           { return m_bIsTLDevice; }
	inline BOOL    HasStencil() const		    { return m_bSupportStencil; }
//    inline BOOL    IsStereo() const             { return m_bIsStereo; }
    VOID    Move( INT x, INT y );

    // Creates the Framework
	HRESULT Initialize (HWND hWnd, D3D9Enum_DeviceInfo *pDeviceInfo, D3DDISPLAYMODE* pMode, bool bTryStencil, DWORD dwFlags);
    HRESULT DestroyObjects();

            CD3DFramework9();
           ~CD3DFramework9();
};

//-----------------------------------------------------------------------------
// Flags used for the Initialize() method of a CD3DFramework object
//-----------------------------------------------------------------------------
#define D3DFW_FULLSCREEN    0x00000001 // Use fullscreen mode
#define D3DFW_STEREO        0x00000002 // Use stereo-scopic viewing
#define D3DFW_ZBUFFER       0x00000004 // Create and use a zbuffer
#define D3DFW_NO_FPUSETUP   0x00000008 // Don't use default DDSCL_FPUSETUP flag
#define D3DFW_NOVSYNC		0x00000010 // Don't use vertical sync in fullscreen

//-----------------------------------------------------------------------------
// Errors that the Initialize() and ChangeDriver() calls may return
//-----------------------------------------------------------------------------
#define D3DFWERR_INITIALIZATIONFAILED 0x82000000
#define D3DFWERR_NODIRECTDRAW         0x82000001
#define D3DFWERR_COULDNTSETCOOPLEVEL  0x82000002
#define D3DFWERR_NODIRECT3D           0x82000003
#define D3DFWERR_NO3DDEVICE           0x82000004
#define D3DFWERR_NOZBUFFER            0x82000005
#define D3DFWERR_INVALIDZBUFFERDEPTH  0x82000006
#define D3DFWERR_NOVIEWPORT           0x82000007
#define D3DFWERR_NOPRIMARY            0x82000008
#define D3DFWERR_NOCLIPPER            0x82000009
#define D3DFWERR_BADDISPLAYMODE       0x8200000a
#define D3DFWERR_NOBACKBUFFER         0x8200000b
#define D3DFWERR_NONZEROREFCOUNT      0x8200000c
#define D3DFWERR_NORENDERTARGET       0x8200000d
#define D3DFWERR_INVALIDMODE          0x8200000e
#define D3DFWERR_NOTINITIALIZED       0x8200000f

#endif // !D3D9Frame_H
