#include "Scene.h"
#include "Camera.h"
#include "VPlanet.h"
#include "VVessel.h"
#include "VBase.h"
#include "Particle.h"

using namespace oapi;

static D3DMATRIX ident = {
	1,0,0,0,
	0,1,0,0,
	0,0,1,0,
	0,0,0,1
};

D3DMATERIAL9 def_mat = {{1,1,1,1},{1,1,1,1},{1,1,1,1},{0,0,0,1},0};
const double LABEL_DISTLIMIT = 0.6;

struct PList { // auxiliary structure for object distance sorting
	vPlanet *vo;
	double dist;
};

Scene::Scene (D3D9Client *_gc, DWORD w, DWORD h)
{
	gc = _gc;
	dev = gc->GetDevice();
	viewW = w, viewH = h;
	bDoStencil = gc->UseStencilBuffer();
	zclearflag = D3DCLEAR_ZBUFFER;
	if (bDoStencil) zclearflag |= D3DCLEAR_STENCIL;

	cam = new Camera (dev, w, h);
	csphere = new CelestialSphere (gc);
	vobjFirst = vobjLast = NULL;
	D3DDISPLAYMODE mode = gc->GetDisplayMode();
	VERTEX_XYZHT vertices[4] = {{0-0.5		           , 0-0.5				    , 0, 1.0, 0, 0},
								{(float)mode.Width-0.5f, 0-0.5				    , 0, 1.0, 1, 0},
								{0-0.5		           , (float)mode.Height-0.5f, 0, 1.0, 0, 1},
								{(float)mode.Width-0.5f, (float)mode.Height-0.5f, 0, 1.0, 1, 1}};

	dev->CreateVertexBuffer(4*sizeof(VERTEX_XYZHT), D3DUSAGE_WRITEONLY, FVF_XYZHT, D3DPOOL_DEFAULT, &p2dOverlayBuffer, NULL);
	VERTEX_XYZHT *data;
	p2dOverlayBuffer->Lock(0, 0, (LPVOID*) &data, 0);
	memcpy(data, vertices, sizeof(VERTEX_XYZHT)*4);
	p2dOverlayBuffer->Unlock();
	nstream = 0;
	iVCheck = 0;
	InitGDIResources();
}

Scene::~Scene ()
{
	p2dOverlayBuffer->Release();
	while (vobjFirst) DelVisualRec (vobjFirst);
	delete cam;
	delete csphere;
	delete light;
	if (nstream) {
		for (DWORD j = 0; j < nstream; j++)
			delete pstream[j];
		delete []pstream;
	}
	ExitGDIResources();
}

void Scene::Initialise ()
{
	OBJHANDLE hSun = oapiGetGbodyByIndex(0); // generalise later
	light = new D3D7Light (hSun, D3D7Light::Directional, this, 0);	

    // Set miscellaneous renderstates
	dev->SetRenderState (D3DRS_DITHERENABLE, TRUE);
    dev->SetRenderState (D3DRS_ZENABLE, D3DZB_TRUE);
	dev->SetRenderState (D3DRS_FILLMODE, D3DFILL_SOLID);
	dev->SetRenderState (D3DRS_SHADEMODE, D3DSHADE_GOURAUD);
	dev->SetRenderState (D3DRS_SPECULARENABLE, FALSE);
    dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);
	dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
	dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
	dev->SetRenderState (D3DRS_NORMALIZENORMALS, TRUE);
	dev->SetRenderState (D3DRS_DEPTHBIAS, 0);
	dev->SetRenderState (D3DRS_WRAP0, 0);
	dev->SetRenderState (D3DRS_AMBIENT, *(DWORD*)gc->GetConfigParam (CFGPRM_AMBIENTLEVEL) * 0x01010101);

	// Set texture renderstates
    dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    dev->SetTextureStageState (0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    dev->SetTextureStageState (0, D3DTSS_COLOROP,   D3DTOP_MODULATE);
	dev->SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
	dev->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
	dev->SetSamplerState(1, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
	dev->SetSamplerState(1, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
}

void Scene::CheckVisual (OBJHANDLE hObj)
{
	VECTOR3 pos;
	oapiGetGlobalPos (hObj, &pos);
	double rad = oapiGetSize (hObj);
	double dst = dist (pos, *cam->GetGPos());
	double apprad = (rad*viewH)/(dst*cam->GetTanAp());
	// apparent radius of the object in units of viewport pixels

	VOBJREC *pv = FindVisual (hObj);
	if (!pv) pv = AddVisualRec (hObj);

	if (pv->vobj->IsActive()) {
		if (apprad < 1.0) pv->vobj->Activate (false);
	} else {
		if (apprad > 2.0) pv->vobj->Activate (true);
	}
#ifdef UNDEF
	if (pv) { // object has an associated visual
		if (apprad < 1.0) DelVisualRec (pv); // delete visual
	} else {  // object has not visual
		if (apprad > 2.0) AddVisualRec (hObj); // create visual
	}
#endif
	// the range check has a small hysteresis to avoid continuous
	// creation/deletion for objects at the edge of visibility
}

Scene::VOBJREC *Scene::FindVisual (OBJHANDLE hObj)
{
	VOBJREC *pv;
	for (pv = vobjFirst; pv; pv = pv->next) {
		if (pv->vobj->Object() == hObj) return pv;
	}
	return NULL;
}

void Scene::DelVisualRec (VOBJREC *pv)
{
	// unlink the entry
	if (pv->prev) pv->prev->next = pv->next;
	else          vobjFirst = pv->next;

	if (pv->next) pv->next->prev = pv->prev;
	else          vobjLast = pv->prev;

	// delete the visual, its children and the entry itself
	delete pv->vobj;
	delete pv;
}

Scene::VOBJREC *Scene::AddVisualRec (OBJHANDLE hObj)
{
	// create the visual and entry
	VOBJREC *pv = new VOBJREC;
	pv->vobj = vObject::Create (hObj, this);

	// link entry to end of list
	pv->prev = vobjLast;
	pv->next = NULL;
	if (vobjLast) vobjLast->next = pv;
	else          vobjFirst = pv;
	vobjLast = pv;
	return pv;
}

void Scene::Update ()
{
	cam->Update (); // update camera parameters

	light->Update (); // update light sources

	// check object visibility (one object per frame in the interest
	// of scalability)
	DWORD nobj = oapiGetObjectCount();
	if (iVCheck >= nobj) iVCheck = 0;
	OBJHANDLE hObj = oapiGetObjectByIndex (iVCheck++);
	CheckVisual (hObj);

	// update all existing visuals
	for (VOBJREC *pv = vobjFirst; pv; pv = pv->next) {
		vObject *vo = pv->vobj;
		//OBJHANDLE hObj = vo->Object();
		vo->Update();
	}
	
	// update particle streams - should be skipped when paused
	if (!oapiGetPause()) {
		for (DWORD i = 0; i < nstream;) {
			if (pstream[i]->Expired()) DelParticleStream (i);
			else pstream[i++]->Update();
		}
	}

}

VECTOR3 Scene::SkyColour ()
{
	VECTOR3 col = {0,0,0};
	OBJHANDLE hProxy = oapiCameraProxyGbody();
	if (hProxy && oapiPlanetHasAtmosphere (hProxy)) {
		const ATMCONST *atmp = oapiGetPlanetAtmConstants (hProxy);
		VECTOR3 rc, rp, pc;
		oapiCameraGlobalPos (&rc);
		oapiGetGlobalPos (hProxy, &rp);
		pc = rc-rp;
		double cdist = length (pc);
		if (cdist < atmp->radlimit) {
			ATMPARAM prm;
			oapiGetPlanetAtmParams (hProxy, cdist, &prm);
			normalise (rp);
			double coss = dotp (pc, rp) / -cdist;
			double intens = min (1.0,(1.0839*coss+0.4581)) * sqrt (prm.rho/atmp->rho0);
			// => intensity=0 at sun zenith distance 115?
			//    intensity=1 at sun zenith distance 60?
			if (intens > 0.0)
				col += _V(atmp->color0.x*intens, atmp->color0.y*intens, atmp->color0.z*intens);
		}
		for (int i = 0; i < 3; i++)
			if (col.data[i] > 1.0) col.data[i] = 1.0;
	}
	return col;
}

void Scene::Render ()
{
	int i, j;
	DWORD n;

	Update (); // update camera and visuals

	VECTOR3 bgcol = SkyColour();
	double skybrt = (bgcol.x+bgcol.y+bgcol.z)/3.0;
	D3DCOLOR bg_rgba; // background colour
	bg_rgba = D3DCOLOR_RGBA ((int)(bgcol.x*255), (int)(bgcol.y*255), (int)(bgcol.z*255), 255);

	// Clear the viewport
	dev->Clear (0, NULL, D3DCLEAR_TARGET|zclearflag, bg_rgba, 1.0f, 0L);

	if (FAILED (dev->BeginScene ())) return;

	light->SetLight (dev);
	dev->SetMaterial (&def_mat);
	dev->SetTexture (0, 0);

	// planetarium mode flags
	DWORD plnmode = *(DWORD*)gc->GetConfigParam (CFGPRM_PLANETARIUMFLAG);

	// render celestial sphere (without z-buffer)
	dev->SetTransform (D3DTS_WORLD, &ident);
	dev->SetTexture (0,0);
	dev->SetRenderState (D3DRS_ZENABLE, D3DZB_FALSE);
	dev->SetRenderState (D3DRS_ZWRITEENABLE, FALSE);
	dev->SetRenderState (D3DRS_LIGHTING, FALSE);

	// use explicit colours
	dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TFACTOR);
	dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);

	// planetarium mode (celestial sphere elements)
	if (plnmode & PLN_ENABLE) {

		DWORD dstblend;
		dev->GetRenderState (D3DRS_DESTBLEND, &dstblend);
		dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_ONE);
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
		double linebrt = 1.0-skybrt;

		// render ecliptic grid
		if (plnmode & PLN_EGRID)
			csphere->RenderGrid (dev, _V(0,0,0.4)*linebrt, !(plnmode & PLN_ECL));
		if (plnmode & PLN_ECL)
			csphere->RenderGreatCircle (dev, _V(0,0,0.8)*linebrt);

		// render celestial grid
		if (plnmode & (PLN_CGRID|PLN_EQU)) {
			static double obliquity = 0.4092797095927;
			static double coso = cos(obliquity), sino = sin(obliquity);
			static D3DMATRIX rot = {1.0f,0.0f,0.0f,0.0f,  0.0f,(float)coso,(float)sino,0.0f,  0.0f,-(float)sino,(float)coso,0.0f,  0.0f,0.0f,0.0f,1.0f};
			dev->SetTransform (D3DTS_WORLD, &rot);
			if (plnmode & PLN_CGRID)
				csphere->RenderGrid (dev, _V(0.35,0,0.35)*linebrt, !(plnmode & PLN_EQU));
			if (plnmode & PLN_EQU)
				csphere->RenderGreatCircle (dev, _V(0.7,0,0.7)*linebrt);
			dev->SetTransform (D3DTS_WORLD, &ident);
		}

		// render constellation lines
		if (plnmode & PLN_CONST)
			csphere->RenderConstellations (dev, _V(0.4,0.3,0.2)*linebrt);

		dev->SetRenderState (D3DRS_DESTBLEND, dstblend);
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);

		if (plnmode & PLN_CCMARK) {
			const GraphicsClient::LABELLIST *list;
			DWORD n, nlist;
			HDC hDC = NULL;
			nlist = gc->GetCelestialMarkers (&list);
			for (n = 0; n < nlist; n++) {
				if (list[n].active) {
					if (!hDC) hDC = GetLabelDC (0);
						//hDC = gc->clbkGetSurfaceDC (0);
						//SelectObject (hDC, GetStockObject (NULL_BRUSH));
						//SelectObject (hDC, hLabelFont[0]);
						//SetTextAlign (hDC, TA_CENTER | TA_BOTTOM);
						//SetBkMode (hDC, TRANSPARENT);
					int size = (int)(viewH/80.0*list[n].size+0.5);
					int col = list[n].colour;
					SelectObject (hDC, hLabelPen[col]);
					SetTextColor (hDC, labelCol[col]);
					const GraphicsClient::LABELSPEC *ls = list[n].list;
					for (i = 0; i < list[n].length; i++) {
						RenderDirectionMarker (hDC, ls[i].pos, ls[i].label[0], ls[i].label[1], list[n].shape, size);
					}
				}
			}
			if (hDC) gc->clbkReleaseSurfaceDC (0, hDC);
		}
	}

	// revert to standard colour selection
	dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
	dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_MODULATE);

	csphere->RenderStars (dev, (DWORD)-1, &bgcol);

	// turn on lighting
	dev->SetRenderState (D3DRS_LIGHTING, TRUE);

	// render solar system celestial objects (planets and moons)
	// we render without z-buffer, so need to distance-sort the objects
	VOBJREC *pv;
	int np;
	const int MAXPLANET = 512; // hard limit; should be fixed
	static PList plist[MAXPLANET];

	for (pv = vobjFirst, np = 0; pv && np < MAXPLANET; pv = pv->next) {
		if (!pv->vobj->IsActive()) continue;
		OBJHANDLE hObj = pv->vobj->Object();
		if (oapiGetObjectType (hObj) == OBJTP_PLANET) {
			plist[np].vo = (vPlanet*)pv->vobj;
			plist[np].dist = pv->vobj->CamDist();
			np++;
		}
	}
	int distcomp (const void *arg1, const void *arg2);
	qsort ((void*)plist, np, sizeof(PList), distcomp);
	cam->SetFustrumLimits (10, 1e6);
	for (i = 0; i < np; i++) {
		//  double nplane, fplane;
		//  plist[i].vo->RenderZRange (&nplane, &fplane);
		//  cam->SetFustrumLimits (nplane, fplane);
		// since we are not using z-buffers here, we can adjust the projection
		// matrix at will to make sure the object is within the viewing fustrum
		OBJHANDLE hObj = plist[i].vo->Object();
		plist[i].vo->Render (dev);
		if (plnmode & PLN_ENABLE) {
			if (plnmode & PLN_CMARK) {
				VECTOR3 pp;
				char name[256];
				oapiGetObjectName (hObj, name, 256);
				oapiGetGlobalPos (hObj, &pp);
				RenderObjectMarker (0, pp, name, 0, 0, viewH/80);
			}
			if ((plnmode & PLN_SURFMARK) && (oapiGetObjectType (hObj) == OBJTP_PLANET)) {
				if (plnmode & PLN_LMARK) { // user-defined planetary surface labels
					double rad = oapiGetSize (hObj);
					double apprad = rad/(plist[i].dist * cam->GetTanAp());
					const GraphicsClient::LABELLIST *list;
					DWORD n, nlist;
					HDC hDC = NULL;
					MATRIX3 prot;
					VECTOR3 ppos, cpos;
					nlist = gc->GetSurfaceMarkers (hObj, &list);
					for (n = 0; n < nlist; n++) {
						if (list[n].active && apprad*list[n].distfac > LABEL_DISTLIMIT) {
							if (!hDC) {
								hDC = gc->clbkGetSurfaceDC (0);
								SelectObject (hDC, GetStockObject (NULL_BRUSH));
								SelectObject (hDC, hLabelFont[0]);
								SetTextAlign (hDC, TA_CENTER | TA_BOTTOM);
								SetBkMode (hDC, TRANSPARENT);
								oapiGetRotationMatrix (hObj, &prot);
								oapiGetGlobalPos (hObj, &ppos);
								const VECTOR3 *cp = cam->GetGPos();
								cpos = tmul (prot, *cp-ppos); // camera in local planet coords
							}
							int size = (int)(viewH/80.0*list[n].size+0.5);
							int col = list[n].colour;
							SelectObject (hDC, hLabelPen[col]);
							SetTextColor (hDC, labelCol[col]);
							const GraphicsClient::LABELSPEC *ls = list[n].list;
							VECTOR3 sp;
							for (j = 0; j < list[n].length; j++) {
								if (dotp (ls[j].pos, cpos-ls[j].pos) >= 0.0) { // surface point visible?
									sp = mul (prot, ls[j].pos) + ppos;
									RenderObjectMarker (hDC, sp, ls[j].label[0], ls[j].label[1], list[n].shape, size);
								}
							}
						}
					}
					if (hDC) gc->clbkReleaseSurfaceDC (0, hDC);
				}
			}
		}
	}

	// turn z-buffer back on
	dev->SetRenderState (D3DRS_ZENABLE, D3DZB_TRUE);
	dev->SetRenderState (D3DRS_ZWRITEENABLE, TRUE);

	// render the vessel objects
	cam->SetFustrumLimits (1, 1e5);
	OBJHANDLE hFocus = oapiGetFocusObject();
	vVessel *vFocus = NULL;
	for (pv = vobjFirst; pv; pv = pv->next) {
		if (!pv->vobj->IsActive()) continue;
		OBJHANDLE hObj = pv->vobj->Object();
		if (oapiGetObjectType (hObj) == OBJTP_VESSEL) {
			pv->vobj->Render (dev);
			if (hObj == hFocus) vFocus = (vVessel*)pv->vobj; // remember focus visual
			if ((plnmode & (PLN_ENABLE|PLN_VMARK)) == (PLN_ENABLE|PLN_VMARK)) {
				VECTOR3 gpos;
				char name[256];
				oapiGetGlobalPos (hObj, &gpos);
				oapiGetObjectName (hObj, name, 256);
				RenderObjectMarker (0, gpos, name, 0, 0, viewH/80);
			}
		}
	}
	
	// render static engine exhaust
	for (pv = vobjFirst; pv; pv = pv->next) {
		if (!pv->vobj->IsActive()) continue;
		if (oapiGetObjectType (pv->vobj->Object()) == OBJTP_VESSEL) {
			((vVessel*)(pv->vobj))->RenderExhaust (dev);
		}
	}

	// render exhaust particle system
	LPDIRECT3DTEXTURE9 ptex = 0;
	for (n = 0; n < nstream; n++)
		pstream[n]->Render (dev, ptex);
	if (ptex) dev->SetTexture (0, 0);


	// render the internal parts of the focus object in a separate render pass
	if (oapiCameraInternal() && vFocus) {
		// should also check for internal meshes
		dev->Clear (0, NULL, D3DCLEAR_ZBUFFER,  0, 1.0f, 0L); // clear z-buffer
		double nearp = cam->GetNearlimit();
		double farp  = cam->GetFarlimit ();
		cam->SetFustrumLimits (0.1, oapiGetSize (hFocus));
		vFocus->Render (dev, true);
		cam->SetFustrumLimits (nearp, farp);
	}


	/* Overlay the captured 2d drawings from the orbiter core. Use a blending of dest = max(source,dest)
	   to blend the 2d surface over the output, because the 2d surface lacks an alpha channel.
	*/
	LPDIRECT3DTEXTURE9 overlay =  gc->Get2dOverlayTexture();
	LPDIRECT3DSURFACE9 surface;
	overlay->GetSurfaceLevel(0, &surface);
	dev->StretchRect(gc->GetRenderTarget(), NULL, surface, NULL, D3DTEXF_NONE );
	dev->ColorFill(gc->GetRenderTarget(), NULL, 0);
	surface->Release();

	dev->SetRenderState(D3DRS_LIGHTING, FALSE);
	dev->SetTexture(0, overlay);
	dev->SetFVF(FVF_XYZHT);
	dev->SetStreamSource(0, p2dOverlayBuffer, 0, sizeof(VERTEX_XYZHT));
//	dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_ONE);
//	dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_ONE);
	dev->SetRenderState (D3DRS_BLENDOP, D3DBLENDOP_MAX);	
	dev->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2);
//	dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
//	dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
	dev->SetRenderState (D3DRS_BLENDOP, D3DBLENDOP_ADD);
	dev->SetRenderState(D3DRS_LIGHTING, TRUE);
	dev->EndScene();
	dev->Present(NULL, NULL, NULL, NULL);
}

// ==============================================================

void Scene::RenderVesselShadows (OBJHANDLE hPlanet, float depth) const
{
	// performance note: the device parameters should only be set if
	// any vessels actually want to render their shadows

	// set device parameters
	if (bDoStencil) {
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
		dev->SetRenderState (D3DRS_STENCILENABLE, TRUE);
		dev->SetRenderState (D3DRS_STENCILREF, 1);
		dev->SetRenderState (D3DRS_STENCILMASK, 1);
		dev->SetRenderState (D3DRS_STENCILFUNC, D3DCMP_NOTEQUAL);
		dev->SetRenderState (D3DRS_STENCILPASS, D3DSTENCILOP_REPLACE);
	} else {
		depth = 1; // without stencil buffer, use black shadows
	}

	dev->SetTextureStageState (0, D3DTSS_ALPHAARG1, D3DTA_TFACTOR);
	dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_COLORVALUE(0,0,0,depth));
	dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);
	dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TFACTOR);

	// render vessel shadows
	VOBJREC *pv;
	for (pv = vobjFirst; pv; pv = pv->next) {
		if (!pv->vobj->IsActive()) continue;
		if (oapiGetObjectType (pv->vobj->Object()) == OBJTP_VESSEL)
			((vVessel*)(pv->vobj))->RenderGroundShadow (dev, hPlanet);
	}	

	// reset device parameters
	if (bDoStencil) {
		dev->SetRenderState (D3DRS_STENCILENABLE, FALSE);
	} else
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);

	dev->SetTextureStageState (0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
	// render particle shadows
	LPDIRECT3DTEXTURE9 tex = 0;
	for (DWORD j = 0; j < nstream; j++) {
		pstream[j]->RenderGroundShadow (dev, tex);
	}
	dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_MODULATE);
	dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
}

// ==============================================================
HDC Scene::GetLabelDC (int mode)
{
	HDC hDC = gc->clbkGetSurfaceDC (0);
	SelectObject (hDC, GetStockObject (NULL_BRUSH));
	SelectObject (hDC, hLabelPen[mode]);
	SelectObject (hDC, hLabelFont[0]);
	SetTextAlign (hDC, TA_CENTER | TA_BOTTOM);
	SetTextColor (hDC, labelCol[mode]);
	SetBkMode (hDC, TRANSPARENT);
	return hDC;
}

// ==============================================================
void Scene::RenderDirectionMarker (HDC hDC, const VECTOR3 &rdir, const char *label1, const char *label2, int mode, int scale)
{
	bool local_hdc = (hDC == 0);
	int x, y;
	D3DVECTOR homog;
	D3DVECTOR dir = {(float)-rdir.x, (float)-rdir.y, (float)-rdir.z};
	D3DMAT_VectorMatrixMultiply (&homog, &dir, cam->GetProjectionViewMatrix());
	if (homog.x >= -1.0f && homog.x <= 1.0f &&
		homog.y >= -1.0f && homog.y <= 1.0f &&
		homog.z >=  0.0f) {
		if (hypot (homog.x, homog.y) < 1e-6) {
			x = viewW/2, y = viewH/2;
		} else {
			x = (int)(viewW*0.5*(1.0f+homog.x));
			y = (int)(viewH*0.5*(1.0f-homog.y));
		}
		if (local_hdc) hDC = GetLabelDC (mode);

		switch (mode) {
		case 0: // box
			Rectangle (hDC, x-scale, y-scale, x+scale+1, y+scale+1);
			break;
		case 1: // circle
			Ellipse (hDC, x-scale, y-scale, x+scale+1, y+scale+1);
			break;
		case 2: // diamond
			MoveToEx (hDC, x, y-scale, NULL);
			LineTo (hDC, x+scale, y); LineTo (hDC, x, y+scale);
			LineTo (hDC, x-scale, y); LineTo (hDC, x, y-scale);
			break;
		case 3: { // delta
			int scl1 = (int)(scale*1.1547);
			MoveToEx (hDC, x, y-scale, NULL);
			LineTo (hDC, x+scl1, y+scale); LineTo (hDC, x-scl1, y+scale); LineTo (hDC, x, y-scale);
			} break;
		case 4: { // nabla
			int scl1 = (int)(scale*1.1547);
			MoveToEx (hDC, x, y+scale, NULL);
			LineTo (hDC, x+scl1, y-scale); LineTo (hDC, x-scl1, y-scale); LineTo (hDC, x, y+scale);
			} break;
		case 5: { // cross
			int scl1 = scale/4;
			MoveToEx (hDC, x, y-scale, NULL); LineTo (hDC, x, y-scl1);
			MoveToEx (hDC, x, y+scale, NULL); LineTo (hDC, x, y+scl1);
			MoveToEx (hDC, x-scale, y, NULL); LineTo (hDC, x-scl1, y);
			MoveToEx (hDC, x+scale, y, NULL); LineTo (hDC, x+scl1, y);
			} break;
		case 6: { // X
			int scl1 = scale/4;
			MoveToEx (hDC, x-scale, y-scale, NULL); LineTo (hDC, x-scl1, y-scl1);
			MoveToEx (hDC, x-scale, y+scale, NULL); LineTo (hDC, x-scl1, y+scl1);
			MoveToEx (hDC, x+scale, y-scale, NULL); LineTo (hDC, x+scl1, y-scl1);
			MoveToEx (hDC, x+scale, y+scale, NULL); LineTo (hDC, x+scl1, y+scl1);
			} break;
		}
		if (label1) TextOut (hDC, x, y-scale, label1, strlen (label1));
		if (label2) TextOut (hDC, x, y+scale+labelSize[0], label2, strlen (label2));
		if (local_hdc) gc->clbkReleaseSurfaceDC (0, hDC);
	}
}

void Scene::RenderObjectMarker (HDC hDC, const VECTOR3 &gpos, const char *label1, const char *label2, int mode, int scale)
{
	VECTOR3 dp (gpos - *cam->GetGPos());
	normalise (dp);
	RenderDirectionMarker (hDC, dp, label1, label2, mode, scale);
}

void Scene::NewVessel (OBJHANDLE hVessel)
{
	CheckVisual (hVessel);
}

void Scene::DeleteVessel (OBJHANDLE hVessel)
{
	VOBJREC *pv = FindVisual (hVessel);
	if (pv) DelVisualRec (pv);
}

void Scene::VesselEvent (OBJHANDLE hVessel, DWORD event, void *context)
{
	VOBJREC *pv = FindVisual (hVessel);
	if (pv) pv->vobj->NotifyEvent (event, context);
}
void Scene::AddParticleStream (D3D9ParticleStream *_pstream)
{
	D3D9ParticleStream **tmp = new D3D9ParticleStream*[nstream+1];
	if (nstream) {
		memcpy (tmp, pstream, nstream*sizeof(D3D9ParticleStream*));
		delete []pstream;
	}
	pstream = tmp;
	pstream[nstream++] = _pstream;
}

void Scene::DelParticleStream (DWORD idx)
{
	D3D9ParticleStream **tmp;
	if (nstream > 1) {
		DWORD i, j;
		tmp = new D3D9ParticleStream*[nstream-1];
		for (i = j = 0; i < nstream; i++)
			if (i != idx) tmp[j++] = pstream[i];
	} else tmp = 0;
	delete pstream[idx];
	delete []pstream;
	pstream = tmp;
	nstream--;
}

void Scene::InitGDIResources ()
{
	for (int i = 0; i < 6; i++)
		hLabelPen[i] = CreatePen (PS_SOLID, 0, labelCol[i]);
	labelSize[0] = max (viewH/60, 14);
	hLabelFont[0] = CreateFont (labelSize[0], 0, 0, 0, 400, TRUE, 0, 0, 0, 3, 2, 1, 49, "Arial");
}

void Scene::ExitGDIResources ()
{
	int i;
	for (i = 0; i < 6; i++)
		DeleteObject (hLabelPen[i]);
	for (i = 0; i < 1; i++)
		DeleteObject (hLabelFont[i]);
}

int distcomp (const void *arg1, const void *arg2)
{
	double d1 = ((PList*)arg1)->dist;
	double d2 = ((PList*)arg2)->dist;
	return (d1 > d2 ? -1 : d1 < d2 ? 1 : 0);
}

COLORREF Scene::labelCol[6] = {0x00FFFF, 0xFFFF00, 0x4040FF, 0xFF00FF, 0x40FF40, 0xFF8080};