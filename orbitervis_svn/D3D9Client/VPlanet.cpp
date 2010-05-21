// ==============================================================
// VPlanet.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

// ==============================================================
// class vPlanet (implementation)
//
// A vPlanet is the visual representation of a "planetary" object
// (planet, moon, asteroid).
// Currently this only supports spherical objects, without
// variations in elevation.
// ==============================================================

#define D3D_OVERLOADS

#include "D3D9Client.h"
#include "VPlanet.h"
#include "VBase.h"
#include "Camera.h"
#include "SurfMgr.h"
#include "CloudMgr.h"
#include "HazeMgr.h"
#include "RingMgr.h"

using namespace oapi;

// ==============================================================

static double farplane = 1e6;

// ==============================================================

vPlanet::vPlanet (OBJHANDLE _hObj, const Scene *scene): vObject (_hObj, scene)
{
	rad = (float)oapiGetSize (_hObj);
	render_rad = 0.1f*rad;
	dist_scale = 1.0f;
	surfmgr = new SurfaceManager (gc, this);
	hazemgr = 0;
	hashaze = *(bool*)gc->GetConfigParam (CFGPRM_ATMHAZE) &&
		oapiPlanetHasAtmosphere (_hObj);
	bRipple = *(bool*)gc->GetConfigParam (CFGPRM_SURFACERIPPLE) &&
		*(bool*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_SURFACERIPPLE);
	if (bRipple) surfmgr->SetMicrotexture ("waves.dds");

	shadowalpha = (float)(1.0 - *(double*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_SHADOWCOLOUR));
	bVesselShadow = *(bool*)gc->GetConfigParam (CFGPRM_VESSELSHADOWS) &&
		shadowalpha >= 0.01;

	clouddata = 0;
	if (*(bool*)gc->GetConfigParam (CFGPRM_CLOUDS) &&
		*(bool*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_HASCLOUDS)) {
		clouddata = new CloudData;
		clouddata->cloudmgr = new CloudManager (gc, this);
		clouddata->cloudrad = rad + *(double*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_CLOUDALT);
		clouddata->cloudshadow = *(bool*)gc->GetConfigParam (CFGPRM_CLOUDSHADOWS);
		if (clouddata->cloudshadow) {
			clouddata->shadowalpha = 1.0f - *(float*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_CLOUDSHADOWCOL);
			if (clouddata->shadowalpha < 0.01f) clouddata->cloudshadow = false;
		}
		if (*(bool*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_CLOUDMICROTEX)) {
			clouddata->cloudmgr->SetMicrotexture ("cloud1.dds");
			clouddata->microalt0 = *(double*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_CLOUDMICROALTMIN);
			clouddata->microalt1 = *(double*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_CLOUDMICROALTMAX);
		}
	}

	if (*(bool*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_HASRINGS)) {
		double minrad = *(double*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_RINGMINRAD);
		double maxrad = *(double*)oapiGetObjectParam (_hObj, OBJPRM_PLANET_RINGMAXRAD);
		ringmgr = new RingManager (this, minrad, maxrad);
		render_rad = rad*(float)maxrad;
	} else {
		ringmgr = 0;
	}

	patchres = 0;

	nbase = oapiGetBaseCount (_hObj);
	vbase = new vBase*[nbase];
	for (DWORD i = 0; i < nbase; i++)
		vbase[i] = NULL;
}

// ==============================================================

vPlanet::~vPlanet ()
{
	if (nbase) {
		for (DWORD i = 0; i < nbase; i++)
			if (vbase[i]) delete vbase[i];
		delete []vbase;
	}
	delete surfmgr;
	if (clouddata) {
		delete clouddata->cloudmgr;
		delete clouddata;
	}
	if (hazemgr) delete hazemgr;
	if (ringmgr) delete ringmgr;
}

// ==============================================================

bool vPlanet::Update ()
{
	if (!active) return false;

	vObject::Update();

	int i, j;
	float rad_scale = rad;
	bool rescale = false;
	dist_scale = 1.0f;

	if (cdist+render_rad > farplane && cdist-rad > 1e4) {
		rescale = true;
		dist_scale = (FLOAT)(farplane/(cdist+render_rad));
	}
	if (rescale) {
		rad_scale *= dist_scale;
		mWorld._41 *= dist_scale;
		mWorld._42 *= dist_scale;
		mWorld._43 *= dist_scale;
	}

	// scale up from template sphere radius 1
	mWorld._11 *= rad_scale; mWorld._12 *= rad_scale; mWorld._13 *= rad_scale;
	mWorld._21 *= rad_scale; mWorld._22 *= rad_scale; mWorld._23 *= rad_scale;
	mWorld._31 *= rad_scale; mWorld._32 *= rad_scale; mWorld._33 *= rad_scale;

	// cloud layer world matrix
	if (clouddata) {
		clouddata->rendermode = (cdist < clouddata->cloudrad ? 1:0);
		if (cdist > clouddata->cloudrad*(1.0-1.5e-4)) clouddata->rendermode |= 2;
		if (clouddata->rendermode & 1) {
			clouddata->viewap = acos (rad/cloudrad);
			if (rad < cdist) clouddata->viewap += acos (rad/cdist);
		} else {
			clouddata->viewap = 0;
		}

		float cloudscale = (float)(clouddata->cloudrad/rad);
		double cloudrot = *(double*)oapiGetObjectParam (hObj, OBJPRM_PLANET_CLOUDROTATION);

		// world matrix for cloud shadows on the surface
		memcpy (&clouddata->mWorldC0, &mWorld, sizeof (D3DMATRIX));
		if (cloudrot) {
			static D3DMATRIX crot = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
			crot._11 =   crot._33 = (float)cos(cloudrot);
			crot._13 = -(crot._31 = (float)sin(cloudrot));
			D3DMAT_MatrixMultiply (&clouddata->mWorldC0, &clouddata->mWorldC0, &crot);
		}

		// world matrix for cloud layer
		memcpy (&clouddata->mWorldC, &clouddata->mWorldC0, sizeof (D3DMATRIX));
		for (i = 0; i < 3; i++)
			for (j = 0; j < 3; j++) {
				clouddata->mWorldC.m[i][j] *= cloudscale;
			}
			
		// set microtexture intensity
		double alt = cdist-rad;
		double lvl = (clouddata->microalt1-alt)/(clouddata->microalt1-clouddata->microalt0);
		clouddata->cloudmgr->SetMicrolevel (max (0, min (1, lvl)));
	}

	// check all base visuals
	if (nbase) {
		VECTOR3 pos, cpos = *scn->GetCamera()->GetGPos();
		double scale = (double)scn->ViewH()/scn->GetCamera()->GetTanAp();
		for (DWORD i = 0; i < nbase; i++) {
			OBJHANDLE hBase = oapiGetBaseByIndex (hObj, i);
			oapiGetGlobalPos (hBase, &pos);
			double rad = oapiGetSize (hBase);
			double dst = dist (pos, cpos);
			double apprad = rad*scale/dst;
			if (vbase[i]) { // base visual exists
				if (apprad < 1.0) { // out of visual range
					delete vbase[i];
					vbase[i] = 0;
				}
			} else {        // base visual doesn't exist
				if (apprad > 2.0) { // within visual range
					vbase[i] = new vBase (hBase, scn);
				}
			}
			if (vbase[i])
				vbase[i]->Update();
		}
	}
	return true;
}

// ==============================================================

void vPlanet::CheckResolution ()
{
	double alt = max (1.0, cdist-rad);
	double apr = rad * scn->ViewH()*0.5 / (alt * scn->GetCamera()->GetTanAp());
	// apparent planet radius in units of screen pixels

	int new_patchres;
	double ntx;

	if (apr < 2.5) { // render planet as 2x2 pixels
		new_patchres = 0;
		ntx = 0;
	} else {
		ntx = PI*2.0 * apr;

		if (ntx < 1024) {
			if (ntx < 256)
				new_patchres = (ntx < 128 ? 1 : 2);
			else
				new_patchres = (ntx < 512 ? 3 : 4);
		} else if (ntx < 16384) {
			if (ntx < 4096)
				new_patchres = (ntx < 2048 ? 5 : 6);
			else
				new_patchres = (ntx < 8192 ? 7 : 8);
		} else {
			if (ntx < 32768)
				new_patchres = 9;
			else
				new_patchres = 10;
		}
	}
	if (new_patchres != patchres) {
		if (hashaze) {
			if (new_patchres < 3) {
				if (hazemgr) { delete hazemgr; hazemgr = 0; }
			} else {
				if (!hazemgr) { hazemgr = new HazeManager (scn->GetClient(), this); }
			}
		}
		if (ringmgr) {
			int ringres = (new_patchres <= 3 ? 0 : new_patchres <= 4 ? 1:2);
			ringmgr->SetMeshRes (ringres);
		}

		patchres = new_patchres;
	}
}

// ==============================================================

void vPlanet::RenderZRange (double *nplane, double *fplane)
{
	double d = dotp (*scn->GetCamera()->GetGDir(), cpos);
	*fplane = max (1e3, d+rad*1.2);
	*nplane = max (1e0, d-rad*1.2);
	*fplane = min (*fplane, *nplane*1e5);
}

// ==============================================================

bool vPlanet::Render (LPDIRECT3DDEVICE9 dev)
{
	if (!active) return false;

	if (patchres == 0) { // render as 2x2 pixel block
		RenderDot (dev);
	} else {             // render as sphere
		bool ringpostrender = false;
		if (ringmgr) {
			if (cdist < rad*ringmgr->InnerRad()) { // camera inside inner ring edge
				ringmgr->Render (dev, mWorld);
			} else {
				// if the planet has a ring system we update the z-buffer
				// but don't do z-checking for the planet surface
				// This strategy could do with some reconsideration
				dev->SetRenderState (D3DRS_ZENABLE, TRUE);
				dev->SetRenderState (D3DRS_ZWRITEENABLE, TRUE);
				dev->SetRenderState (D3DRS_ZFUNC, D3DCMP_ALWAYS);
				ringpostrender = true;
			}
		}

		if (clouddata && (clouddata->rendermode & 1))
			RenderCloudLayer (dev, D3DCULL_CW);           // render clouds from below
		if (hazemgr) hazemgr->Render (dev, mWorld);       // horizon ring
		RenderSphere (dev);                               // planet surface
		if (nbase) RenderBaseStructures (dev);
		if (ringpostrender) {
			// reset z-comparison function and disable z-buffer
			dev->SetRenderState (D3DRS_ZFUNC, D3DCMP_LESSEQUAL);
			dev->SetRenderState (D3DRS_ZENABLE, FALSE);
		}
		if (clouddata && (clouddata->rendermode & 2))
			RenderCloudLayer (dev, D3DCULL_CCW);		  // render clouds from above
		if (hazemgr) hazemgr->Render (dev, mWorld, true); // haze across planet disc
		if (ringpostrender) {
			// turn z-buffer on for ring system
			dev->SetRenderState (D3DRS_ZENABLE, TRUE);
			ringmgr->Render (dev, mWorld);
			dev->SetRenderState (D3DRS_ZENABLE, FALSE);
			dev->SetRenderState (D3DRS_ZWRITEENABLE, FALSE);
		}
	}
	return true;
}

// ==============================================================

void vPlanet::RenderDot (LPDIRECT3DDEVICE9 dev)
{
	// to do
}

// ==============================================================

void vPlanet::RenderSphere (LPDIRECT3DDEVICE9 dev)
{
	surfmgr->Render (dev, mWorld, patchres);          // surface
	if (nbase) {
		RenderBaseSurfaces (dev);					  // base surfaces
		RenderBaseShadows (dev, shadowalpha);         // base shadows
	}
	if (clouddata && clouddata->cloudshadow)
		RenderCloudShadows (dev);                     // cloud shadows
	if (hObj == oapiCameraProxyGbody())
	// cast shadows only on planet closest to camera
		scn->RenderVesselShadows (hObj, shadowalpha); // vessel shadows

}

// ==============================================================

void vPlanet::RenderCloudLayer (LPDIRECT3DDEVICE9 dev, DWORD cullmode)
{
	if (cullmode != D3DCULL_CCW) dev->SetRenderState (D3DRS_CULLMODE, cullmode);
	clouddata->cloudmgr->Render (dev, clouddata->mWorldC, min(patchres,8), clouddata->viewap); // clouds
	if (cullmode != D3DCULL_CCW) dev->SetRenderState (D3DRS_CULLMODE, D3DCULL_CCW);
}

// ==============================================================

void vPlanet::RenderCloudShadows (LPDIRECT3DDEVICE9 dev)
{
	D3DMATERIAL9 pmat;
	static D3DMATERIAL9 cloudmat = {{0,0,0,1},{0,0,0,1},{0,0,0,0},{0,0,0,0},0};

	float alpha = clouddata->shadowalpha;
	cloudmat.Diffuse.a = cloudmat.Ambient.a = alpha;

	dev->GetMaterial (&pmat);
	dev->SetMaterial (&cloudmat);

	DWORD ablend;
	dev->GetRenderState (D3DRS_ALPHABLENDENABLE, &ablend);
	if (!ablend)
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
	dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

	clouddata->cloudmgr->Render (dev, clouddata->mWorldC0, min(patchres,8), clouddata->viewap);

	dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
	if (!ablend)
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);
	dev->SetMaterial (&pmat);
}

// ==============================================================

void vPlanet::RenderBaseSurfaces (LPDIRECT3DDEVICE9 dev)
{
	for (DWORD i = 0; i < nbase; i++)
		if (vbase[i])
			vbase[i]->RenderSurface (dev);
}
// ==============================================================

void vPlanet::RenderBaseShadows (LPDIRECT3DDEVICE9 dev, float depth)
{
	// set device parameters
	if (scn->hasStencil()) {
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

	for (DWORD i = 0; i < nbase; i++)
		if (vbase[i])
			vbase[i]->RenderGroundShadow (dev);

	// reset device parameters
	if (scn->hasStencil()) {
		dev->SetRenderState (D3DRS_STENCILENABLE, FALSE);
	} else
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
	dev->SetTextureStageState (0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
	dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_MODULATE);
	dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
}

// ==============================================================



void vPlanet::RenderBaseStructures (LPDIRECT3DDEVICE9 dev)
{
	bool zmod = false, zcheck = false;
	DWORD bz, bzw;

	for (DWORD i = 0; i < nbase; i++) {
		if (vbase[i]) {
			if (!zcheck) { // enable zbuffer
				dev->GetRenderState (D3DRS_ZENABLE, &bz);
				dev->GetRenderState (D3DRS_ZWRITEENABLE, &bzw);
				if (!bz || !bzw) {
					dev->SetRenderState (D3DRS_ZENABLE, TRUE);
					dev->SetRenderState (D3DRS_ZWRITEENABLE, TRUE);
					scn->GetCamera()->SetFustrumLimits (1, 1e5);
					zmod = true;
				}
				zcheck = true;
			}
			vbase[i]->RenderStructures (dev);
		}
	}
	if (zmod) {
		dev->SetRenderState (D3DRS_ZENABLE, bz);
		dev->SetRenderState (D3DRS_ZWRITEENABLE, bzw);
		scn->GetCamera()->SetFustrumLimits (10, 1e6);
	}
}