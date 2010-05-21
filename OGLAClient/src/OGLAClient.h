//############################################################################//
// Orbiter Visualisation Project OpenGL client
// Main file headers
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
#ifndef __OGLAClient_H
#define __OGLAClient_H
//############################################################################//
struct DeviceId{
	DWORD dwDevice;
	DWORD dwMode;
	BOOL  bFullscreen;
	BOOL  bStereo;
};
//############################################################################//
namespace oapi{
//############################################################################//
//OGLAClient class interface
//The OpenGL render client for Orbiter
//############################################################################//
class OGLAClient:public GraphicsClient{
friend class ::VideoTab;
public:
	OGLAClient(HINSTANCE hInstance);
	~OGLAClient();
//############################################################################//
	BOOL LaunchpadVideoWndProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam);
	LRESULT RenderWndProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam);
	void clbkRefreshVideoData();
	bool clbkFullscreenMode()const;
	void clbkGetViewportSize(DWORD *width,DWORD *height)const;
	bool clbkGetRenderParam(DWORD prm,DWORD *value)const;
	int clbkVisEvent (OBJHANDLE hObj, VISHANDLE vis, DWORD msg, UINT context);
	virtual MESHHANDLE clbkGetMesh (VISHANDLE vis, UINT idx);
	int clbkEditMeshGroup (DEVMESHHANDLE hMesh, DWORD grpidx, GROUPEDITSPEC *ges);
	oapi::ParticleStream *clbkCreateParticleStream (PARTICLESTREAMSPEC *pss);
	oapi::ParticleStream *clbkCreateExhaustStream (PARTICLESTREAMSPEC *pss,OBJHANDLE hVessel, const double *lvl, const VECTOR3 *ref, const VECTOR3 *dir);
	oapi::ParticleStream *clbkCreateExhaustStream (PARTICLESTREAMSPEC *pss,OBJHANDLE hVessel, const double *lvl, const VECTOR3 &ref, const VECTOR3 &dir);
	oapi::ParticleStream *clbkCreateReentryStream (PARTICLESTREAMSPEC *pss,OBJHANDLE hVessel);
	bool clbkParticleStreamExists (const oapi::ParticleStream *ps);
	void clbkReleaseTexture(SURFHANDLE hTex);
	bool clbkSetMeshTexture (DEVMESHHANDLE hMesh, DWORD texidx, SURFHANDLE tex);
	int  clbkSetMeshMaterial (DEVMESHHANDLE hMesh, DWORD matidx, const MATERIAL *mat);
	bool clbkSetMeshProperty (DEVMESHHANDLE hMesh, DWORD property, DWORD value);
	void clbkPreOpenPopup ();
	void clbkNewVessel (OBJHANDLE hVessel);
	void clbkDeleteVessel(OBJHANDLE hVessel);
	void clbkRender2DPanel (SURFHANDLE *hSurf, MESHHANDLE hMesh, MATRIX3 *T,bool transparent=false);
	SURFHANDLE clbkLoadTexture(const char *fname,DWORD flags=0);
	SURFHANDLE clbkCreateSurface (DWORD w, DWORD h, SURFHANDLE hTemplate = NULL);
	SURFHANDLE clbkCreateTexture (DWORD w, DWORD h);
	void clbkIncrSurfaceRef (SURFHANDLE surf);
	bool clbkReleaseSurface(SURFHANDLE surf);
	bool clbkGetSurfaceSize (SURFHANDLE surf, DWORD *w, DWORD *h);
	bool clbkSetSurfaceColourKey(SURFHANDLE surf,DWORD ckey);
	DWORD clbkGetDeviceColour(BYTE r,BYTE g,BYTE b);
	bool clbkBlt(SURFHANDLE tgt,DWORD tgtx,DWORD tgty,SURFHANDLE src,DWORD flag=0)const;
	bool clbkBlt(SURFHANDLE tgt,DWORD tgtx,DWORD tgty,SURFHANDLE src,DWORD srcx,DWORD srcy,DWORD w,DWORD h,DWORD flag=0)const;
	virtual bool clbkScaleBlt(SURFHANDLE tgt, DWORD tgtx, DWORD tgty, DWORD tgtw, DWORD tgth,
		                         SURFHANDLE src, DWORD srcx, DWORD srcy, DWORD srcw, DWORD srch, DWORD flag = 0) const;
	bool clbkFillSurface(SURFHANDLE surf,DWORD col)const;
	bool clbkFillSurface(SURFHANDLE surf,DWORD tgtx,DWORD tgty,DWORD w,DWORD h,DWORD col)const;
	HDC  clbkGetSurfaceDC(SURFHANDLE surf);
	void clbkReleaseSurfaceDC(SURFHANDLE surf,HDC hDC);
	void WriteLog(const char *msg)const;
	void WriteDbg(const char *msg)const;
//############################################################################//
protected:
	bool clbkInitialise();
	HWND clbkCreateRenderWindow();
	void clbkPostCreation();
	void clbkCloseSession (bool fastclose);
	void clbkDestroyRenderWindow(bool fastclose);
	void clbkRenderScene();
	void clbkTimeJump (double simt, double simdt, double mjd);
	bool clbkDisplayFrame();
	void clbkStoreMeshPersistent(MESHHANDLE hMesh,const char *fname);
//############################################################################//
	oapi::Sketchpad *clbkGetSketchpad (SURFHANDLE surf);
	void clbkReleaseSketchpad (oapi::Sketchpad *sp);
	oapi::Font *clbkCreateFont(int height, bool prop, char *face, oapi::Font::Style style = oapi::Font::NORMAL, int orientation = 0) const;
	void clbkReleaseFont (oapi::Font *font) const;
	oapi::Pen *clbkCreatePen (int style, int width, DWORD col) const;
	void clbkReleasePen (oapi::Pen *pen) const;
	oapi::Brush *clbkCreateBrush (DWORD col) const;
	void clbkReleaseBrush (oapi::Brush *brush) const;
//############################################################################//
private:
	void LogRenderParams()const;

	HWND hRenderWnd;        //render window handle
	bool bFullscreen;       //fullscreen render mode flag
	DWORD viewW,viewH;      //dimensions of the render viewport
	DWORD viewBPP;          //bit depth of render viewport
	VideoTab *vtab;         //video selection user interface
 int fpsc,cfps,udc;      //FPS counters
};
//############################################################################//
};
#endif
//############################################################################//

