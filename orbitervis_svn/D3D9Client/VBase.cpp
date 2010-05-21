// ==============================================================
// VBase.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class vBase (implementation)
//
// A vBase is the visual representation of a surface base
// object (a "spaceport" on the surface of a planet or moon,
// usually with runways or landing pads where vessels can
// land and take off.
// ==============================================================

#include "VBase.h"
#include "TileMgr.h"
#include "D3D9Client.h"

vBase::vBase (OBJHANDLE _hObj, const Scene *scene): vObject (_hObj, scene)
{
	DWORD i;

	// load surface tiles
	ntile = gc->GetBaseTileList (_hObj, &tspec);
	if (ntile) {
		LPDIRECT3D9 d3d = gc->GetDirect3D9();
		LPDIRECT3DDEVICE9 dev = gc->GetDevice();
		tile = new SurfTile[ntile];
		for (i = 0; i < ntile; i++) {
			tile[i].mesh = new D3D9Mesh (gc, tspec[i].mesh);
		}
	}
	
	// load meshes for generic structures
	MESHHANDLE *sbs, *sas;
	DWORD nsbs, nsas;
	gc->GetBaseStructures (_hObj, &sbs, &nsbs, &sas, &nsas);
	if (nstructure_bs = nsbs) {
		structure_bs = new D3D9Mesh*[nsbs];
		for (i = 0; i < nsbs; i++) structure_bs[i] = new D3D9Mesh (gc, sbs[i]);
	}
	if (nstructure_as = nsas) {
		structure_as = new D3D9Mesh*[nsas];
		for (i = 0; i < nsas; i++) structure_as[i] = new D3D9Mesh (gc, sas[i]);
	}
	SetupShadowMeshes ();
	lights = false;
	Tchk = oapiGetSimTime()-1.0;
}

vBase::~vBase ()
{
	DWORD i;

	if (ntile) {
		for (i = 0; i < ntile; i++)
			delete tile[i].mesh;
		delete []tile;
	}
	if (nstructure_bs) {
		for (i = 0; i < nstructure_bs; i++)
			delete structure_bs[i];
		delete []structure_bs;
	}
	if (nstructure_as) {
		for (i = 0; i < nstructure_as; i++)
			delete structure_as[i];
		delete []structure_as;
	}
	if (nshmesh) {
		for (i = 0; i < nshmesh; i++) {
			shmesh[i].vbuf->Release();
			shmesh[i].idx->Release();
		}
		delete []shmesh;
	}
}

void vBase::SetupShadowMeshes ()
{
	nshmesh = 0;

	// Get mesh geometries for all base structures
	DWORD i, j, k, m, nmesh, ngrp, nssh;
	MESHHANDLE *ssh;
	double *ecorr;
	gc->GetBaseShadowGeometry (hObj, &ssh, &ecorr, &nssh);
	if (!nssh) return;

	// Re-assemble meshes according to surface elevation correction heights.
	// All objects with similar corrections can use the same transformation
	// matrix and can therefore be merged for improved performance.
	// This only works for static meshes. Any dynamically animated meshes
	// should be stored separately.
	struct EGROUP {
		MESHHANDLE *mesh;
		DWORD nmesh, nvtx, nidx;
		int bin;
	} *eg;
	const double d_ecorr = 0.2; // correction bin width
	for (i = 0; i < nssh; i++) {
		int bin = (int)(ecorr[i]/d_ecorr);
		for (j = 0; j < nshmesh; j++)
			if (bin == eg[j].bin) break;
		if (j == nshmesh) {   // create new bin
			EGROUP *tmp = new EGROUP[nshmesh+1];
			if (nshmesh) {
				memcpy (tmp, eg, nshmesh*sizeof(EGROUP));
				delete []eg;
			}
			eg = tmp;
			eg[nshmesh].nmesh = eg[nshmesh].nvtx = eg[nshmesh].nidx = 0;
			eg[nshmesh].bin = bin;
			nshmesh++;
		}
		nmesh = eg[j].nmesh;
		MESHHANDLE *tmp = new MESHHANDLE[nmesh+1];
		if (nmesh) {
			memcpy (tmp, eg[j].mesh, nmesh*sizeof(MESHHANDLE));
			delete []eg[j].mesh;
		}
		eg[j].mesh = tmp;
		eg[j].mesh[nmesh] = ssh[i];
		ngrp = oapiMeshGroupCount (ssh[i]);
		for (k = 0; k < ngrp; k++) {
			MESHGROUP *grp = oapiMeshGroup (ssh[i], k);
			if (grp->UsrFlag & 1) continue; // "no shadows" flag
			eg[j].nvtx += grp->nVtx;
			eg[j].nidx += grp->nIdx;
		}
		eg[j].nmesh++;
	}

	shmesh = new ShadowMesh[nshmesh];
	LPDIRECT3D9 d3d = gc->GetDirect3D9();
	VERTEX_XYZ *vtx;
	for (i = 0; i < nshmesh; i++) {
		gc->GetDevice()->CreateVertexBuffer(eg[i].nvtx * sizeof(VERTEX_XYZ), D3DUSAGE_WRITEONLY, D3DFVF_XYZ, D3DPOOL_DEFAULT, &shmesh[i].vbuf, NULL);
		gc->GetDevice()->CreateIndexBuffer(eg[i].nidx * sizeof(WORD), D3DUSAGE_WRITEONLY, D3DFMT_INDEX16, D3DPOOL_DEFAULT, &shmesh[i].idx, NULL);
		LPWORD idx;
		
		shmesh[i].vbuf->Lock(0, 0, (LPVOID*)&vtx, D3DLOCK_DISCARD);
		shmesh[i].idx->Lock(0, 0, (LPVOID*)&idx, D3DLOCK_DISCARD);
		shmesh[i].nvtx = 0;
		shmesh[i].nidx = 0;
		shmesh[i].ecorr = (eg[i].bin-0.5)*d_ecorr;
		for (j = 0; j < eg[i].nmesh; j++) {
			MESHHANDLE mesh = eg[i].mesh[j];
			ngrp = oapiMeshGroupCount (mesh);
			for (k = 0; k < ngrp; k++) {
				MESHGROUP *grp = oapiMeshGroup (mesh, k);
				if (grp->UsrFlag & 1) continue; // "no shadows" flag
				VERTEX_XYZ *vtgt = vtx + shmesh[i].nvtx;
				WORD *itgt = idx + shmesh[i].nidx;
				NTVERTEX *vsrc = grp->Vtx;
				WORD *isrc = grp->Idx;
				WORD iofs = (WORD)shmesh[i].nvtx;
				for (m = 0; m < grp->nVtx; m++) {
					vtgt[m].x = vsrc[m].x;
					vtgt[m].y = vsrc[m].y;
					vtgt[m].z = vsrc[m].z;
				}
				for (m = 0; m < grp->nIdx; m++)
					*itgt++ = *isrc++ + iofs;
				shmesh[i].nvtx += grp->nVtx;
				shmesh[i].nidx += grp->nIdx;
			}
		}
		shmesh[i].vbuf->Unlock();
		shmesh[i].idx->Unlock();
	}

	for (i = 0; i < nshmesh; i++)
		delete []eg[i].mesh;
	delete []eg;

	for (i = 0; i < nssh; i++)
		oapiDeleteMesh (ssh[i]);
}

bool vBase::Update ()
{
	if (!vObject::Update()) return false;

	static const double csun_lights = RAD*1.0; // sun elevation at which lights are switched on
	double simt = oapiGetSimTime();
	if (simt > Tchk) {
		VECTOR3 pos, sdir;
		MATRIX3 rot;
		oapiGetGlobalPos (hObj, &pos); normalise(pos);
		oapiGetRotationMatrix (hObj, &rot);
		sdir = tmul (rot, -pos);
		double csun = sdir.y;
		bool night = csun < csun_lights;
		if (lights != night) {
			DWORD i;
			for (i = 0; i < nstructure_bs; i++)
				structure_bs[i]->SetTexMixture (1, night ? 1.0f:0.0f);
			for (i = 0; i < nstructure_as; i++)
				structure_as[i]->SetTexMixture (1, night ? 1.0f:0.0f);
			lights = night;
		}
	}
	return true;
}

bool vBase::RenderSurface (LPDIRECT3DDEVICE9 dev)
{
	// note: assumes z-buffer disabled

	if (!active) return false;

	DWORD i;
	dev->SetTransform (D3DTS_WORLD, &mWorld);

	// render tiles
	if (ntile) {
		DWORD i;
		dev->SetTransform (D3DTS_WORLD, &mWorld);
		dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
		dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
		dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_CLAMP);
		for (i = 0; i < ntile; i++) {
			dev->SetTexture (0, (LPDIRECT3DTEXTURE9)tspec[i].tex);
			tile[i].mesh->Render (dev);
		}
		dev->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
		dev->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
		dev->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);
	}
	
	// render generic objects under shadows
	for (i = 0; i < nstructure_bs; i++)
		structure_bs[i]->Render (dev);

	// render surface shadows (TODO)

	return true;
}

bool vBase::RenderStructures (LPDIRECT3DDEVICE9 dev)
{
	// note: assumes z-buffer enabled

	if (!active) return false;

	DWORD i;
	dev->SetTransform (D3DTS_WORLD, &mWorld);

	// render generic objects above shadows
	for (i = 0; i < nstructure_as; i++)
		structure_as[i]->Render (dev);

	return true;
}

void vBase::RenderGroundShadow (LPDIRECT3DDEVICE9 dev)
{
	if (!nshmesh) return; // nothing to do

	static const double shadow_elev_limit = 0.07;
	double d, csun, nr0;
	VECTOR3 pp, sd, pvr;
	OBJHANDLE hPlanet = oapiGetBasePlanet (hObj); // planet handle
	oapiGetGlobalPos (hPlanet, &pp);              // planet global pos
	oapiGetGlobalPos (hObj, &sd);                 // base global pos
	pvr = sd-pp;                                  // planet-relative base position
	d = length (pvr);                             // planet radius at base location
	normalise (sd);                               // shadow projection direction

	double fac1 = dotp (sd, pvr);
	if (fac1 > 0.0)                               // base is on planet night-side
		return;
	csun = -fac1/d;                               // sun elevation above horizon
	if (csun < shadow_elev_limit)                 // sun too low to cast shadow
		return;

	MATRIX3 vR;
	oapiGetRotationMatrix (hObj, &vR);
	VECTOR3 sdv = tmul (vR, sd);     // projection direction in base frame
	VECTOR3 hnp = pvr; normalise(hnp);
	VECTOR3 hn = tmul (vR, hnp);     // horizon normal in vessel frame

	// perform projections
	double nd = dotp (hn, sdv);
	VECTOR3 sdvs = sdv / nd;
	if (!sdvs.y) return; // required for plane offset correction

	DWORD i;

	// build shadow projection matrix
	D3DMATRIX mProj, mProjWorld, mProjWorldShift;
	mProj._11 = (float)(1.0 - sdvs.x*hn.x);
	mProj._12 = (float)(    - sdvs.y*hn.x);
	mProj._13 = (float)(    - sdvs.z*hn.x);
	mProj._14 = 0;
	mProj._21 = (float)(    - sdvs.x*hn.y);
	mProj._22 = (float)(1.0 - sdvs.y*hn.y);
	mProj._23 = (float)(    - sdvs.z*hn.y);
	mProj._24 = 0;
	mProj._31 = (float)(    - sdvs.x*hn.z);
	mProj._32 = (float)(    - sdvs.y*hn.z);
	mProj._33 = (float)(1.0 - sdvs.z*hn.z);
	mProj._34 = 0;
	mProj._41 = 0;
	mProj._42 = 0;
	mProj._43 = 0;
	mProj._44 = 1;
	D3DMAT_MatrixMultiply (&mProjWorld, &mWorld, &mProj);
	memcpy (&mProjWorldShift, &mProjWorld, sizeof(D3DMATRIX));

	// modify depth of shadows at dawn/dusk
	DWORD tfactor;
	bool resetalpha = false;
	if (gc->UseStencilBuffer()) {
		double scale = min (1, (csun-0.07)/0.015);
		if (scale < 1) {
			dev->GetRenderState (D3DRS_TEXTUREFACTOR, &tfactor);
			float modalpha = (float)(scale*(tfactor>>24)/256.0);
			dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_COLORVALUE(0,0,0,modalpha));
			resetalpha = true;
		}
	}

	dev->SetTransform (D3DTS_WORLD, &mProjWorld);
	for (i = 0; i < nshmesh; i++) {

		// add shadow plane offset to transformation
		nr0 = shmesh[i].ecorr/sdvs.y;
		mProjWorldShift._41 = mProjWorld._41 + (float)(nr0*(sdvs.x*mWorld._11 + sdvs.y*mWorld._21 + sdvs.z*mWorld._31));
		mProjWorldShift._42 = mProjWorld._42 + (float)(nr0*(sdvs.x*mWorld._12 + sdvs.y*mWorld._22 + sdvs.z*mWorld._32));
		mProjWorldShift._43 = mProjWorld._43 + (float)(nr0*(sdvs.x*mWorld._13 + sdvs.y*mWorld._23 + sdvs.z*mWorld._33));
		dev->SetTransform (D3DTS_WORLD, &mProjWorldShift);
		dev->SetIndices(shmesh[i].idx);
		dev->SetStreamSource(0, shmesh[i].vbuf, 0, sizeof(VERTEX_XYZ));
		dev->SetFVF(D3DFVF_XYZ);

		dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, shmesh[i].nvtx, 0, shmesh[i].nidx/3);
//		dev->DrawIndexedPrimitiveVB (D3DPT_TRIANGLELIST, shmesh[i].vbuf, 0, shmesh[i].nvtx, shmesh[i].idx, shmesh[i].nidx, 0);

	}
}
