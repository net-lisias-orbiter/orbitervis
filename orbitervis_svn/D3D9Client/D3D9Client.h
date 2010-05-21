#ifndef __D3D9Client_H
#define __D3D9Client_H

// must be defined before windows includes to fix warnings on VS 2003+
#if defined(_MSC_VER) && (_MSC_VER >= 1300 ) // Microsoft Visual Studio Version 2003 and higher
#define _CRT_SECURE_NO_DEPRECATE 
#define _CRT_NONSTDC_NO_WARNINGS
#include <fstream>
#else  // older MSVC++ versions
#include <fstream.h>
#endif

#include "debug.h"
#include <d3d9.h>
#include <d3dx9.h>
#include "GraphicsAPI.h"
#include "D3D9Enum.h"
#include "D3D9Frame.h"
#include "VideoTab.h"
#include <stdio.h>

class DialogManager;
class MeshManager;
class TextureManager;
class Scene;

//HRESULT clbkConfirmDevice (DDCAPS*, D3DDEVICEDESC7*);

//-----------------------------------------------------------------------------
// Name: DeviceID
// Desc: Identifies a device/mode from a device list
//-----------------------------------------------------------------------------
struct DeviceId {
	DWORD dwDevice;
	DWORD dwMode;
	BOOL  bFullscreen;
	BOOL  bStereo;
};

namespace oapi {

// ==============================================================
// D3D9Client class interface
/// The DX7 render client for Orbiter
// ==============================================================

class D3D9Client: public GraphicsClient {
	friend class ::VideoTab;
	friend class ::Scene;
	friend class ::MeshManager;
	friend class ::TextureManager;

public:
	D3D9Client (HINSTANCE hInstance);
	~D3D9Client ();

	/**
	 * \brief Message handler for 'video' tab in Orbiter Launchpad dialog.
	 *
	 * Passes the message on to the VideoTab::WndProc() method.
	 * \param hWnd window handle for video tab
	 * \param uMsg Windows message
	 * \param wParam WPARAM message value
	 * \param lParam LPARAM message value
	 * \return The return value of the VideoTab::WndProc() method.
	 */
	BOOL LaunchpadVideoWndProc (HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

	/**
	 * \brief Render window message handler.
	 * \param hWnd render window handle
	 * \param mMsg Windows message identifier
	 * \param wParam WPARAM message parameter
	 * \param lParam LPARAM message parameter
	 * \return The return value depends on the message being processed.
	 * \note Currently this only intercepts the WM_MOVE message in windowed mode
	 *   to allow DirectX to adjust the render target position.
	 * \note All other messages are passed on to the base class method.
	 */
	LRESULT RenderWndProc (HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

	/**
	 * \brief Copies video options from the video tab.
	 *
	 * Scans the dialog elements of the Launchpad video tab and stores the values
	 * in the GraphicsClient::VIDEODATA structure pointed to by GetVideoData().
	 */
	void clbkRefreshVideoData ();

	/**
	 * \brief Fullscreen mode flag
	 * \return true in fullscreen mode, false in windowed mode.
	 */
	bool clbkFullscreenMode () const;

	/**
	 * \brief Returns the dimensions of the render viewport
	 * \param width render viewport width [pixel]
	 * \param height render viewport height [pixel]
	 */
	void clbkGetViewportSize (DWORD *width, DWORD *height) const;

	/**
	 * \brief Returns a specific render parameter
	 * \param prm[in] parameter identifier (see \sa renderprm)
	 * \param value[out] value of the queried parameter
	 * \return true if the specified parameter is supported, false if not.
	 */
	bool clbkGetRenderParam (DWORD prm, DWORD *value) const;

	// particle stream methods
	oapi::ParticleStream *clbkCreateParticleStream (PARTICLESTREAMSPEC *pss);
	oapi::ParticleStream *clbkCreateExhaustStream (PARTICLESTREAMSPEC *pss,
		OBJHANDLE hVessel, const double *lvl, const VECTOR3 *ref, const VECTOR3 *dir);
	oapi::ParticleStream *clbkCreateExhaustStream (PARTICLESTREAMSPEC *pss,
		OBJHANDLE hVessel, const double *lvl, const VECTOR3 &ref, const VECTOR3 &dir);
	oapi::ParticleStream *clbkCreateReentryStream (PARTICLESTREAMSPEC *pss,
		OBJHANDLE hVessel);
	bool clbkParticleStreamExists (const oapi::ParticleStream *ps);

	/**
	 * \brief Texture request
	 *
	 * Read a single texture in DXT? format from a file into a device-specific
	 * texture object, and return a generic surface handle for it
	 * \param fname texture file name with relative path
	 * \param flags texture properties (see documentation of parent class method)
	 */
	SURFHANDLE clbkLoadTexture (const char *fname, DWORD flags = 0);

	void clbkReleaseTexture (SURFHANDLE hTex);
	// Release a texture from the device

	/// \brief Request for displaying a dialog box
	HWND clbkOpenDialog (HINSTANCE hInst, int resId, DLGPROC pDlg, void *context, DWORD flag = 0);

	/// \brief Request for closing an existing dialog box
	bool clbkCloseDialog (HWND hDlg);

	/**
	 * \brief React to vessel creation
	 * \param hVessel object handle of new vessel
	 * \note Calls Scene::NewVessel() to check for visual
	 */
	void clbkNewVessel (OBJHANDLE hVessel);

	/**
	 * \brief React to vessel destruction
	 * \param hVessel object handle of vessel to be destroyed
	 * \note Calls Scene::DeleteVessel() to remove the visual
	 */
	void clbkDeleteVessel (OBJHANDLE hVessel);

	/**
	 * \brief Vessel event notification
	 *
	 * Calls Scene::VesselEvent to allow the vessel visual to react to the event.
	 * \param hVessel vessel handle
	 * \param event event type
	 * \param context event-dependent context data
	 */
	void clbkVesselEvent (OBJHANDLE hVessel, DWORD event, void *context);

	/// Returns the DirectDraw object
  //  inline const LPDIRECTDRAW7        GetDirectDraw() const   { return pDD; }

	/// Returns the Direct3D object
	inline const LPDIRECT3D9          GetDirect3D9() const    { return pD3D; }

	/// Returns the Direct3D device
    inline const LPDIRECT3DDEVICE9    GetDevice() const       { return pd3dDevice; }

	/// Returns the 2d overlay surface
	inline const LPDIRECT3DSURFACE9   GetRenderTarget() const { return p2dOverlaySurface; }

	/// Returns the 2d overlay texture
	inline const LPDIRECT3DTEXTURE9   Get2dOverlayTexture() const { return p2dOverlayTexture; }

	/// Returns a pointer to the render framework
	inline const CD3DFramework9*      GetFramework() const    { return m_pFramework; }

	/// Returns a pointer to the scene object
	inline       Scene*               GetScene() const        { return scene; }

	/// Returns a pointer to the texture manager
	inline       TextureManager*      GetTexMgr() const       { return texmgr; }

	/// Returns a pointer to the mesh manager
	inline       MeshManager*         GetMeshMgr() const      { return meshmgr; }

	/**
	 * \brief Indicates use of stencil buffers.
	 * \return \e true if a stencil buffer is supported by the current
	 *   device, and if the user has requested stencil buffers, \e false
	 *   otherwise.
	 */
	inline bool UseStencilBuffer() const { return bStencil; }

	/// Returns the current display mode
	inline D3DDISPLAYMODE GetDisplayMode() const  { return m_pDeviceInfo->ddsdFullscreenMode; }

	//void SetDefault (D3DVERTEXBUFFERDESC &vbdesc) const;
	// Sets the dwCaps entry of vbdesc to system or video memory, depending
	// of whether a T&L device is used.

	// ==================================================================
	/// \name Surface-related methods
	// @{

	/**
	 * \brief Creates a new surface
	 * \param w surface width [pixels]
	 * \param h surface height [pixels]
	 * \return surface handle (LPDIRECT3DSUFRACE9 cast to SURFHANDLE)
	 */
	SURFHANDLE clbkCreateSurface (DWORD w, DWORD h);


	/**
	 * \brief Releases an existing surface
	 * \param surf surface handle
	 * \return true on success, false if surf==NULL
	 */
	bool clbkReleaseSurface (SURFHANDLE surf);

	/**
	 * \brief Return the width and height of a surface
	 * \param surf surface handle
	 * \param w surface width
	 * \param h surface height
	 * \return true
	 */
	bool clbkGetSurfaceSize (SURFHANDLE surf, DWORD *w, DWORD *h);

	/**
	 * \brief Set transparency colour key for a surface
	 * \param surf surface handle
	 * \param ckey transparency colour key value
	 * \note Only source colour keys are currently supported.
	 */
	bool clbkSetSurfaceColourKey (SURFHANDLE surf, DWORD ckey);
	D3DCOLOR D3D9Client::GetColorKey(SURFHANDLE surf) const;

	/**
	 * \brief Convert an RGB colour triplet into a device-specific colour value.
	 * \param r red component
	 * \param g green component
	 * \param b blue component
	 * \return colour value
	 */
	DWORD clbkGetDeviceColour (BYTE r, BYTE g, BYTE b);
	// @}

	// ==================================================================
	/// \name Surface blitting methods
	// @{

	/**
	 * \brief Copy one surface into an area of another one.
	 * \param tgt target surface handle
	 * \param tgtx left edge of target rectangle
	 * \param tgty top edge of target rectangle
	 * \param src source surface handle
	 * \param flag device-specific parameters
	 * \return true
	 * \note Uses IDirectDrawSurface7::BltFast method
	 */
	bool clbkBlt (SURFHANDLE tgt, DWORD tgtx, DWORD tgty, SURFHANDLE src, DWORD flag = 0) const;

	/**
	 * \brief Copy an area from one surface to another.
	 * \param tgt target surfac handle
	 * \param tgtx left edge of target rectangle
	 * \param tgty top edge of target rectangle
	 * \param src source surface handle
	 * \param srcx left edge of source rectangle
	 * \param srcy top edge of source rectangle
	 * \param w width of rectangle
	 * \param h height of rectangle
	 * \param flag device-specific parameters
	 * \return true
	 */
	bool clbkBlt (SURFHANDLE tgt, DWORD tgtx, DWORD tgty, SURFHANDLE src, DWORD srcx, DWORD srcy, DWORD w, DWORD h, DWORD flag = 0) const;

	/**
	 * \brief Copy a rectangle from one surface to another, stretching or shrinking as required.
	 * \param tgt target surface handle
	 * \param tgtx left edge of target rectangle
	 * \param tgty top edge of target rectangle
	 * \param tgtw width of target rectangle
	 * \param tgth height of target rectangle
	 * \param src source surface handle
	 * \param srcx left edge of source rectangle
	 * \param srcy top edge of source rectangle
	 * \param srcw width of source rectangle
	 * \param srch height of source rectangle
	 * \param flag blitting parameters
	 * \return true
	 */
	virtual bool clbkScaleBlt (SURFHANDLE tgt, DWORD tgtx, DWORD tgty, DWORD tgtw, DWORD tgth,
		                       SURFHANDLE src, DWORD srcx, DWORD srcy, DWORD srcw, DWORD srch, DWORD flag = 0) const;

	/**
	 * \brief Fills a surface with a uniform colour
	 * \param surf surface handle
	 * \param col fill colour value
	 * \return true on success, false if the fill operation cannot be performed.
	 * \sa clbkGetDeviceColour
	 */
	bool clbkFillSurface (SURFHANDLE surf, DWORD col) const;

	/**
	 * \brief Fills an area in a surface with a uniform colour
	 * \param surf surface handle
	 * \param tgtx left edge of target rectangle
	 * \param tgty top edge of target rectangle
	 * \param w width of rectangle
	 * \param h height of rectangle
	 * \param col colour value
	 * \return true
	 */
	bool clbkFillSurface (SURFHANDLE surf, DWORD tgtx, DWORD tgty, DWORD w, DWORD h, DWORD col) const;
	// @}

	// ==================================================================
	/// \name GDI-related methods
	// @{

	/**
	 * \brief Returns a Windows graphics device interface handle for a surface
	 * \param surf surface handle
	 * \return GDI handle
	 */
	HDC clbkGetSurfaceDC (SURFHANDLE surf);

	/**
	 * \brief Release a Windows graphics device interface
	 * \param surf surface handle
	 * \param hDC GDI handle
	 */
	void clbkReleaseSurfaceDC (SURFHANDLE surf, HDC hDC);
	// @}

	void WriteLog (const char *msg) const;

protected:
	/**
	 * \brief Graphics client initialisation
	 *
	 *   - Enumerates devices and selects one.
	 *   - Creates a CD3DFramework9 instance
	 *   - Creates a VideoTab instance
	 *
	 * \return true on success
	 */
	bool clbkInitialise ();

	/**
	 * \brief Start of simulation session
	 *
	 * - Calls parent class method to create the render window
	 * - Calls Initialise3DEnvironment to set up the environment
	 */
	HWND clbkCreateRenderWindow ();

	/// \brief Finalise session creation
	///
	/// - Initialises the scene
	void clbkPostCreation ();

	/// \brief End of simulation session
	///
	/// - Calls parent class method
	/// - Calls Cleanup3DEnvironment to clean device objects
	void clbkDestroyRenderWindow ();

	/// \brief Per-frame render call
	///
	/// - Renders the scene into the back buffer
	/// - Flips the back buffer into view
	void clbkRenderScene ();

	/**
	 * \brief Display rendered scene
	 * \return true
	 */
	bool clbkDisplayFrame ();

	/**
	 * \brief Store preloaded meshes persistently in device-specific format
	 * \param hMesh mesh handle
	 * \param fname mesh file name
	 */
	void clbkStoreMeshPersistent (MESHHANDLE hMesh, const char *fname);

	D3D9Enum_DeviceInfo *PickDevice (DeviceId *id);
	// Pick a device according to requested features
	// If no device matches the criteria, NULL is returned

	inline D3D9Enum_DeviceInfo *PickDevice (DWORD idx) { return m_pDeviceInfo = D3D9Enum_GetDevice (idx); }
	// Pick a device from the list by index
	// If the index is out of range, NULL is returned

	/// \brief Return the currently selected device
	inline D3D9Enum_DeviceInfo *CurrentDevice () const { return m_pDeviceInfo; }

	inline bool SelectDevice (D3D9Enum_DeviceInfo *dev) { if (dev) { m_pDeviceInfo = dev; return true; } else  return false; }
	// Select 'dev' as the current video device
	// If dev==NULL, false is returned

	/// \brief Set up device-specific per-session render environment
	///
	/// - Creates the render framework, including DirectDraw and Direct3D objects,
	///   Direct3D device, texture manager, and scene instance.
	/// - Allows individual components (such as the TileManager and HazeManager)
	///   to initialise their global device-specific objects.
	HRESULT Initialise3DEnvironment ();

	/// \brief Clean up the device framework
	void Cleanup3DEnvironment ();

	/// \brief Output 2D graphics on top of the render window
	///
	/// Obtains the GDI of the render surface to output 2D data after
	/// rendering the 3D scene (glass cockpit, date info, etc.)
	void Output2DOverlay (LPDIRECT3DSURFACE9);

private:
	void LogRenderParams () const;

    D3D9Enum_DeviceInfo* m_pDeviceInfo;
//	LPDIRECTDRAW7        pDD;
    LPDIRECT3D9          pD3D;
    LPDIRECT3DDEVICE9    pd3dDevice;
	LPDIRECT3DSURFACE9   p2dOverlaySurface;
	LPDIRECT3DTEXTURE9   p2dOverlayTexture;

	CD3DFramework9*		 m_pFramework;
	HWND hRenderWnd;        // render window handle

	bool bFullscreen;       // fullscreen render mode flag
	bool bStencil;          // use stencil buffers
	DWORD viewW, viewH;     // dimensions of the render viewport
	DWORD viewBPP;          // bit depth of render viewport

	//friend HRESULT ::clbkConfirmDevice (DDCAPS*, D3DDEVICEDESC7*);
	// device enumeration callback function
	VideoTab *vtab;         // video selection user interface
	Scene *scene;           // Scene description
	MeshManager *meshmgr;   // mesh manager
	TextureManager *texmgr; // texture manager
	DialogManager *dlgmgr;  // dialog manager
	static const GUID ColorKeyGUID;
}; // class D3D9Client

}; // namespace oapi

#endif // !__D3D9Client_H
