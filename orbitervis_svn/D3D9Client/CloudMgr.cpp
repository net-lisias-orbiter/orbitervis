// ==============================================================
// CloudMgr.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class CloudManager (implementation)
//
// Planetary rendering management for cloud layers, including a simple
// LOD (level-of-detail) algorithm for patch resolution.
// ==============================================================

#include "CloudMgr.h"
#include "VPlanet.h"
#include "Texture.h"

using namespace oapi;

// =======================================================================

CloudManager::CloudManager (const D3D9Client *gclient, const vPlanet *vplanet)
: TileManager (gclient, vplanet)
{
	maxlvl = min (*(int*)gc->GetConfigParam (CFGPRM_SURFACEMAXLEVEL),        // global setting
	              *(int*)oapiGetObjectParam (obj, OBJPRM_PLANET_SURFACEMAXLEVEL)); // planet-specific setting
	maxbaselvl = min (8, maxlvl);
	pcdir = _V(1,0,0);
	hipatchrad = *(double*)gc->GetConfigParam (CFGPRM_SURFACEPATCHAP);
	lightfac = *(double*)gc->GetConfigParam (CFGPRM_SURFACELIGHTBRT);
	nmask = 0;
	nhitex = nhispec = 0;

	atmc = oapiGetPlanetAtmConstants (obj);

	int maxidx = patchidx[maxbaselvl];
	tiledesc = new TILEDESC[maxidx];
	memset (tiledesc, 0, maxidx*sizeof(TILEDESC));

	for (int i = 0; i < patchidx[maxbaselvl]; i++)
		tiledesc[i].flag = 1;
	LoadTextures ("_cloud");
}

// =======================================================================

void CloudManager::Render (LPDIRECT3DDEVICE9 dev, D3DMATRIX &wmat, int level, double viewap)
{
	DWORD pAlpha;
	dev->GetRenderState (D3DRS_ALPHABLENDENABLE, &pAlpha);
	if (!pAlpha)
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_CLAMP);

	bool do_micro = (microtex && microlvl > 0.01);
	if (do_micro) {
		dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);
		dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
		dev->SetTextureStageState (1, D3DTSS_COLOROP, D3DTOP_MODULATE);
		dev->SetTextureStageState (1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
		dev->SetTextureStageState (1, D3DTSS_COLORARG2, D3DTA_CURRENT);

		dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_ADDSMOOTH);
		dev->SetTextureStageState (0, D3DTSS_TEXCOORDINDEX, 1);

		dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
		dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
		dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);
		dev->SetTexture (0, microtex);
		dev->SetTextureStageState (0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
		dev->SetTextureStageState (0, D3DTSS_ALPHAARG2, D3DTA_TFACTOR);
		dev->SetTextureStageState (1, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
		dev->SetTextureStageState (1, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
		dev->SetTextureStageState (1, D3DTSS_ALPHAARG2, D3DTA_CURRENT);
		dev->SetTextureStageState (1, D3DTSS_TEXCOORDINDEX, 0);
		dev->SetSamplerState(1, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
		dev->SetSamplerState(1, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
		dev->SetSamplerState(1, D3DSAMP_ADDRESSW, D3DTADDRESS_CLAMP);
		double alpha = 1.0-microlvl;
		dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_RGBA(255, 255, 255, (int)(255*alpha)));
		cloudtexidx = 1;
	} else {
		cloudtexidx = 0;
	}

	TileManager::Render (dev, wmat, level, viewap);

	if (do_micro) {
		dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_MODULATE);
		dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
		dev->SetTextureStageState (1, D3DTSS_COLOROP, D3DTOP_DISABLE);

		dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
		dev->SetTextureStageState (0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
		dev->SetTextureStageState (0, D3DTSS_ALPHAARG2, D3DTA_CURRENT);
		dev->SetTextureStageState (0, D3DTSS_TEXCOORDINDEX, 0);
		dev->SetTextureStageState (1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
		dev->SetTexture (1, 0);
	}

	dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
	dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);

	if (!pAlpha)
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);
}

// =======================================================================

void CloudManager::RenderTile (int lvl, int hemisp, int ilat, int nlat, int ilng, int nlng, double sdist,
	TILEDESC *tile, const TEXCRDRANGE &range, LPDIRECT3DTEXTURE9 tex, LPDIRECT3DTEXTURE9 ltex, DWORD flag)
{
	LPDIRECT3DVERTEXBUFFER9 vb;        // processed vertex buffer
	VBMESH &mesh = PATCH_TPL[lvl][ilat]; // patch template

	if (range.tumin == 0 && range.tumax == 1) {
		vb = mesh.vb; // use vertex buffer directly
	} else {
		if (!tile->vtx) {
			gc->GetDevice()->CreateVertexBuffer(mesh.nv*sizeof(VERTEX_2TEX), D3DUSAGE_WRITEONLY, FVF_2TEX, D3DPOOL_DEFAULT, &tile->vtx, NULL);

			ApplyPatchTextureCoordinates (mesh, tile->vtx, range);
		}
		vb = tile->vtx; // use buffer with transformed texture coords
	}

	// step 1: render full patch, either completely diffuse or completely specular
	RenderParam.dev->SetTexture (cloudtexidx, tex);
	RenderParam.dev->SetIndices(mesh.idx);
	RenderParam.dev->SetStreamSource(0, vb, 0, sizeof(VERTEX_2TEX));
	RenderParam.dev->SetFVF(FVF_2TEX);
	RenderParam.dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, mesh.nv, 0, mesh.ni/3);
}
