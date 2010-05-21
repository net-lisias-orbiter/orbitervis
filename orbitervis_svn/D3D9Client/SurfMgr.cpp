// ==============================================================
// SurfMgr.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class SurfaceManager (implementation)
//
// Planetary surface rendering management, including a simple
// LOD (level-of-detail) algorithm for surface patch resolution.
// ==============================================================

#include "SurfMgr.h"
#include "VPlanet.h"
#include "Texture.h"

using namespace oapi;

// =======================================================================

SurfaceManager::SurfaceManager (const D3D9Client *gclient, const vPlanet *vplanet)
: TileManager (gclient, vplanet)
{
	maxlvl = min (*(int*)gc->GetConfigParam (CFGPRM_SURFACEMAXLEVEL),        // global setting
	              *(int*)oapiGetObjectParam (obj, OBJPRM_PLANET_SURFACEMAXLEVEL)); // planet-specific setting
	maxbaselvl = min (8, maxlvl);
	pcdir = _V(1,0,0);
	hipatchrad = *(double*)gc->GetConfigParam (CFGPRM_SURFACEPATCHAP);
	lightfac = *(double*)gc->GetConfigParam (CFGPRM_SURFACELIGHTBRT);
	spec_base = 0.95f;
	atmc = oapiGetPlanetAtmConstants (obj);

	int maxidx = patchidx[maxbaselvl];
	tiledesc = new TILEDESC[maxidx];
	memset (tiledesc, 0, maxidx*sizeof(TILEDESC));

	LoadPatchData ();
	LoadTileData ();
	LoadTextures ();
	LoadSpecularMasks ();
}

// =======================================================================

void SurfaceManager::SetMicrotexture (const char *fname)
{
	TileManager::SetMicrotexture (fname);
	spec_base = (microtex ? 1.05f : 0.95f); // increase specular intensity to compensate for "ripple" losses
}

// =======================================================================

void SurfaceManager::Render (LPDIRECT3DDEVICE9 dev, D3DMATRIX &wmat, int level, double viewap)
{
	dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_CLAMP);

	// modify colour of specular reflection component
	if (bGlobalSpecular) {
		extern D3DMATERIAL9 watermat;
		SpecularColour (&watermat.Specular);
		watermat.Power = (microtex ? 20.0f : 25.0f);
	}

	TileManager::Render (dev, wmat, level, viewap);

	dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);

}

// =======================================================================

void SurfaceManager::RenderTile (int lvl, int hemisp, int ilat, int nlat, int ilng, int nlng, double sdist,
	TILEDESC *tile, const TEXCRDRANGE &range, LPDIRECT3DTEXTURE9 tex, LPDIRECT3DTEXTURE9 ltex, DWORD flag)
{
	extern D3DMATERIAL9 pmat;
	extern D3DMATERIAL9 watermat;
	LPDIRECT3DVERTEXBUFFER9 vb;        // processed vertex buffer
	VBMESH &mesh = PATCH_TPL[lvl][ilat]; // patch template

	if (range.tumin == 0 && range.tumax == 1) {
		vb = mesh.vb; // use vertex buffer directly
	} else {
		if (!tile->vtx) {
			gc->GetDevice()->CreateVertexBuffer(mesh.nv * sizeof(VERTEX_2TEX), D3DUSAGE_WRITEONLY, FVF_2TEX, D3DPOOL_DEFAULT, &tile->vtx, NULL);			
			ApplyPatchTextureCoordinates (mesh, tile->vtx, range);			
		}
		vb = tile->vtx; // use buffer with transformed texture coords
	}

	bool purespec = ((flag & 3) == 2);
	bool mixedspec = ((flag & 3) == 3);
	bool spec_singlerender = (purespec && !microtex);
	bool lights = ((flag & 4) && (sdist > 1.4));

	// step 1: render full patch, either completely diffuse or completely specular
	if (spec_singlerender) { // completely specular
		RenderParam.dev->GetMaterial (&pmat);
		RenderParam.dev->SetMaterial (&watermat);
		RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, TRUE);
	}
	RenderParam.dev->SetTexture (0, tex);
	RenderParam.dev->SetStreamSource(0, vb, 0, sizeof(VERTEX_2TEX));
	RenderParam.dev->SetFVF(FVF_2TEX);
	RenderParam.dev->SetIndices(mesh.idx);
	RenderParam.dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, mesh.nv, 0, mesh.ni/3);

	if (spec_singlerender) {
		RenderParam.dev->SetMaterial (&pmat);
		RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, FALSE);
	}

	// step 2: add city lights
	// note: I didn't find a way to include this as a texture stage in the
	// previous pass, because the lights need to be multiplied with a factor before
	// adding
	if (lights) {
		double fac = lightfac;
		if (sdist < 1.9) fac *= (sdist-1.4)/(1.9-1.4);
		RenderParam.dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_RGBA((int)(255*fac),(int)(255*fac),(int)(255*fac),255));
		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_MODULATE);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLORARG2, D3DTA_TFACTOR);
		RenderParam.dev->SetTexture (0, ltex);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
		RenderParam.dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
		RenderParam.dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_ONE);
		RenderParam.dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_ONE);

		RenderParam.dev->SetStreamSource(0, vb, 0, sizeof(VERTEX_2TEX));
		RenderParam.dev->SetFVF(FVF_2TEX);
		RenderParam.dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, mesh.nv, 0, mesh.ni/3);

		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_MODULATE);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLORARG2, D3DTA_CURRENT);
		RenderParam.dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);
		RenderParam.dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
		RenderParam.dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
	}

	// step 3: add specular highlights (mixed patches only)
	if (mixedspec) {

		RenderParam.dev->GetMaterial (&pmat);
		RenderParam.dev->SetMaterial (&watermat);
		RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, TRUE);
		RenderParam.dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
		RenderParam.dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_INVSRCALPHA);
		RenderParam.dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_ONE);
		RenderParam.dev->SetTexture (0, ltex);

		if (microtex) {
			RenderParam.dev->SetTexture (1, microtex);
			RenderParam.dev->SetTextureStageState (1, D3DTSS_COLOROP, D3DTOP_SELECTARG1);
			RenderParam.dev->SetTextureStageState (1, D3DTSS_COLORARG1, D3DTA_CURRENT);
			RenderParam.dev->SetTextureStageState (1, D3DTSS_ALPHAOP, D3DTOP_ADD/*MODULATE*/);
			RenderParam.dev->SetTextureStageState (1, D3DTSS_TEXCOORDINDEX, 1);
			RenderParam.dev->SetSamplerState(1, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
			RenderParam.dev->SetSamplerState(1, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
			RenderParam.dev->SetSamplerState(1, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);
		}
		
		RenderParam.dev->SetStreamSource(0, vb, 0, sizeof(VERTEX_2TEX));
		RenderParam.dev->SetFVF(FVF_2TEX);
		RenderParam.dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, mesh.nv, 0, mesh.ni/3);

		if (microtex) {
			RenderParam.dev->SetTexture (1, 0);
			RenderParam.dev->SetTextureStageState (1, D3DTSS_COLOROP, D3DTOP_DISABLE);
			RenderParam.dev->SetTextureStageState (1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
			RenderParam.dev->SetTextureStageState (1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
			RenderParam.dev->SetTextureStageState (1, D3DTSS_TEXCOORDINDEX, 0);
		}

		RenderParam.dev->SetMaterial (&pmat);
		RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, FALSE);
		RenderParam.dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);
		RenderParam.dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
		RenderParam.dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);

	} else if (purespec && microtex) {

		RenderParam.dev->GetMaterial (&pmat);
		RenderParam.dev->SetMaterial (&watermat);
		RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, TRUE);
		RenderParam.dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
		RenderParam.dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_INVSRCALPHA);
		RenderParam.dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_ONE);
		RenderParam.dev->SetTexture (0, microtex);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TFACTOR);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_TEXCOORDINDEX, 1);
		RenderParam.dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
		RenderParam.dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
		RenderParam.dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);
		RenderParam.dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_RGBA(0,0,0,255));

		RenderParam.dev->SetStreamSource(0, vb, 0, sizeof(VERTEX_2TEX));
		RenderParam.dev->SetFVF(FVF_2TEX);
		RenderParam.dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, mesh.nv, 0, mesh.ni/3);

		RenderParam.dev->SetTextureStageState (0, D3DTSS_TEXCOORDINDEX, 0);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_MODULATE);
		RenderParam.dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
		RenderParam.dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
		RenderParam.dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
		RenderParam.dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_CLAMP);


		RenderParam.dev->SetMaterial (&pmat);
		RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, FALSE);
		RenderParam.dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);
		RenderParam.dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
		RenderParam.dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);

	}
}
