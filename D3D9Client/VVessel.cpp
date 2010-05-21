// ==============================================================
// VVessel.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

#include "VVessel.h"
#include "MeshMgr.h"
#include "Texture.h"

using namespace oapi;

// ==============================================================
// Local prototypes

void TransformPoint (VECTOR3 &p, const D3DMATRIX &T);
void TransformDirection (VECTOR3 &a, const D3DMATRIX &T, bool normalise);

// ==============================================================
// class vVessel (implementation)
//
// A vVessel is the visual representation of a vessel object.
// ==============================================================

vVessel::vVessel (OBJHANDLE _hObj, const Scene *scene): vObject (_hObj, scene)
{
	vessel = oapiGetVesselInterface (_hObj);
	nmesh = 0;
	nanim = 0;
	LoadMeshes ();
	InitAnimations ();
}

vVessel::~vVessel ()
{
	ClearAnimations();
	ClearMeshes();
}

void vVessel::GlobalInit (D3D9Client *gc)
{
	const DWORD texsize = 256; // render target texture size
	if (mfdsurf) mfdsurf->Release();
	// take pixel format from render surface (should make it compatible
	gc->GetDevice()->CreateTexture(texsize, texsize, 1, D3DUSAGE_RENDERTARGET, gc->GetDisplayMode().Format, D3DPOOL_DEFAULT, &mfdsurf, NULL);
	if (defexhausttex) defexhausttex->Release();
	gc->GetTexMgr()->LoadTexture ("Exhaust.dds", &defexhausttex);

	gc->GetDevice()->CreateVertexBuffer(8*sizeof(VERTEX_XYZ_TEX), D3DUSAGE_DYNAMIC, FVF_XYZ_TEX, D3DPOOL_SYSTEMMEM, &ExhaustVtb, NULL);

	VERTEX_XYZ_TEX *vtxb;
	ExhaustVtb->Lock(0, 0, (LPVOID *) &vtxb, 0);
	VERTEX_XYZ_TEX vertices[8] = {
		{0,0,0, 0.24f,0},
		{0,0,0, 0.24f,1},
		{0,0,0, 0.01f,0},
		{0,0,0, 0.01f,1},
		{0,0,0, 0.50390625f, 0.00390625f},
		{0,0,0, 0.99609375f, 0.00390625f},
		{0,0,0, 0.50390625f, 0.49609375f},
		{0,0,0, 0.99609375f, 0.49609375f}
	};
	memcpy(vtxb, vertices, sizeof(VERTEX_XYZ_TEX)*8);
	ExhaustVtb->Unlock();

	WORD indices[12] = {0,1,2, 3,2,1, 4,5,6, 7,6,5}, *data;
	gc->GetDevice()->CreateIndexBuffer(12*sizeof(WORD), D3DUSAGE_WRITEONLY, D3DFMT_INDEX16, D3DPOOL_DEFAULT, &ExhaustIdx, NULL);
	ExhaustIdx->Lock(0, 0, (LPVOID*)&data, 0);
	memcpy(data, indices, sizeof(WORD)*12);
	ExhaustIdx->Unlock();
}

void vVessel::GlobalExit ()
{
	if (mfdsurf) {
		mfdsurf->Release();
		mfdsurf = 0;
	}
	if (defexhausttex) {
		defexhausttex->Release();
		defexhausttex = 0;
	}
	if (ExhaustVtb) {
		ExhaustVtb->Release();
		ExhaustVtb = 0;
	}
	if (ExhaustIdx) {
		ExhaustIdx->Release();
		ExhaustIdx = 0;
	}
}
void vVessel::NotifyEvent (DWORD event, void *context)
{
	switch (event) {
	case EVENT_VESSEL_DELMESH:
		DelMesh ((UINT)context);
		break;
	case EVENT_VESSEL_MESHOFS: {
		DWORD idx = (DWORD)context;
		if (idx < nmesh) {
			VECTOR3 ofs;
			vessel->GetMeshOffset (idx, ofs);
			D3DMAT_Identity (meshlist[idx].trans);
			D3DMAT_SetTranslation (meshlist[idx].trans, &ofs);
		}
		} break;
	}
}

bool vVessel::Update ()
{
	if (!active) return false;

	vObject::Update ();
	UpdateAnimations ();
	return true;
}

void vVessel::LoadMeshes ()
{
	if (nmesh) ClearMeshes();
	MESHHANDLE hMesh;
	const D3D9Mesh *mesh;
	VECTOR3 ofs;
	UINT idx;
	MeshManager *mmgr = gc->GetMeshMgr();

	nmesh = vessel->GetMeshCount();
	meshlist = new MESHREC[nmesh];

	for (idx = 0; idx < nmesh; idx++) {
		if ((hMesh = vessel->GetMeshTemplate (idx)) && (mesh = mmgr->GetMesh (hMesh))) {
			// copy from preloaded template
			meshlist[idx].mesh = new D3D9Mesh (*mesh);
		} else {
			// load on the fly and discard after copying
			hMesh = vessel->CopyMeshFromTemplate (idx);
			meshlist[idx].mesh = new D3D9Mesh (gc, hMesh);
			oapiDeleteMesh (hMesh);
		}
		meshlist[idx].vismode = vessel->GetMeshVisibilityMode (idx);
		vessel->GetMeshOffset (idx, ofs);
		if (length(ofs)) {
			meshlist[idx].trans = new D3DMATRIX;
			D3DMAT_Identity (meshlist[idx].trans);
			D3DMAT_SetTranslation (meshlist[idx].trans, &ofs);
			// currently only mesh translations are supported
		} else {
			meshlist[idx].trans = 0;
		}
	}
}

void vVessel::ClearMeshes ()
{
	if (nmesh) {
		for (UINT i = 0; i < nmesh; i++) {
			if (meshlist[i].mesh) delete meshlist[i].mesh;
			if (meshlist[i].trans) delete meshlist[i].trans;
		}
		delete []meshlist;
		nmesh = 0;
	}
}
void vVessel::DelMesh (UINT idx)
{
	if (idx >= nmesh) return;
	if (!meshlist[idx].mesh) return;
	delete meshlist[idx].mesh;
	meshlist[idx].mesh = 0;
	if (meshlist[idx].trans) {
		delete meshlist[idx].trans;
		meshlist[idx].trans = 0;
	}
}
void vVessel::InitAnimations ()
{
	if (nanim) ClearAnimations();
	nanim = vessel->GetAnimPtr (&anim);
	if (nanim) {
		UINT i;
		animstate = new double[nanim];
		for (i = 0; i < nanim; i++)
			animstate[i] = anim[i].defstate; // reset to default mesh states
	}
}

void vVessel::ClearAnimations ()
{
	if (nanim) {
		delete []animstate;
		nanim = 0;
	}
}

void vVessel::UpdateAnimations (UINT mshidx)
{
	double newstate;
	for (UINT i = 0; i < nanim; i++) {
		if (!anim[i].ncomp) continue;
		if (animstate[i] != (newstate = anim[i].state)) {
			Animate (i, newstate, mshidx);
			animstate[i] = newstate;
		}
	}
}

bool vVessel::Render (LPDIRECT3DDEVICE9 dev)
{
	if (!active) return false;
	Render (dev, false);
	return true;
}

bool vVessel::Render (LPDIRECT3DDEVICE9 dev, bool internalpass)
{
	if (!active) return false;
	UINT i, mfd;
	bool bWorldValid = false;

	bool bCockpit = (oapiCameraInternal() && hObj == oapiGetFocusObject());
	// render cockpit view

	bool bVC = (bCockpit && oapiCockpitMode() == COCKPIT_VIRTUAL);
	// render virtual cockpit

	const VCHUDSPEC *hudspec;
	const VCMFDSPEC *mfdspec[MAXMFD];
	SURFHANDLE sHUD, sMFD[MAXMFD];

	if (bVC) {
		sHUD = gc->GetVCHUDSurface (&hudspec);
		for (mfd = 0; mfd < MAXMFD; mfd++)
			sMFD[mfd] = gc->GetVCMFDSurface (mfd, &mfdspec[mfd]);
	}

	for (i = 0; i < nmesh; i++) {
		if (!meshlist[i].mesh) continue;

		// check if mesh should be rendered in this pass
		WORD vismode = meshlist[i].vismode;
		if (bCockpit) {
			if (internalpass && (vismode & MESHVIS_EXTPASS)) continue;
			if (!(vismode & MESHVIS_COCKPIT)) {
				if ((!bVC) || (!(vismode & MESHVIS_VC))) continue;
			}
		} else {
			if (!(vismode & MESHVIS_EXTERNAL)) continue;
		}

		// transform mesh
		if (meshlist[i].trans) {
			D3DMATRIX mWorldTrans;
			D3DMAT_MatrixMultiply (&mWorldTrans, &mWorld, meshlist[i].trans);
			dev->SetTransform (D3DTS_WORLD, &mWorldTrans);
			bWorldValid = false;
		} else if (!bWorldValid) {
			dev->SetTransform (D3DTS_WORLD, &mWorld);
			bWorldValid = true;
		}

		// render mesh
		meshlist[i].mesh->Render (dev);

		// render VC HUD and MFDs
		if (bVC) {
			LPDIRECT3DSURFACE9 mfdsurfSurface;
			mfdsurf->GetSurfaceLevel(0, &mfdsurfSurface);

			// render VC MFD displays
			for (mfd = 0; mfd < MAXMFD; mfd++) {
				if (sMFD[mfd] && mfdspec[mfd]->nmesh == i) {
					gc->clbkBlt (mfdsurfSurface, 0, 0, sMFD[mfd]);
					dev->SetTexture (0, mfdsurf);
					meshlist[i].mesh->RenderGroup (dev, meshlist[i].mesh->GetGroup(mfdspec[mfd]->ngroup));
				}
			}

			// render VC HUD
			if (sHUD && hudspec->nmesh == i) {
				gc->clbkBlt (mfdsurfSurface, 0, 0, sHUD);
				// we need to copy the HUD surface here, because the generic sHUD handle
				// doesn't contain a texture attribute, so can't be used as a texture
				dev->SetTexture (0, mfdsurf);
				dev->SetRenderState (D3DRS_LIGHTING, FALSE);
				dev->SetRenderState (D3DRS_ZENABLE, D3DZB_FALSE);
				dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_ONE);
				meshlist[i].mesh->RenderGroup (dev, meshlist[i].mesh->GetGroup(hudspec->ngroup));
				dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
				dev->SetRenderState (D3DRS_LIGHTING, TRUE);
				dev->SetRenderState (D3DRS_ZENABLE, D3DZB_TRUE);
			}
			mfdsurfSurface->Release();
		}
	}
	return true;
}

bool vVessel::RenderExhaust (LPDIRECT3DDEVICE9 dev)
{
	if (!active) return false;
	DWORD i, nexhaust = vessel->GetExhaustCount();
	if (!nexhaust) return true; // nothing to do

	bool need_setup = true;
	double lvl, lscale, wscale, xsize, zsize;
	VECTOR3 pos, dir, cdir;
	LPDIRECT3DTEXTURE9 tex, ptex = 0;
	static D3DMATERIAL9 engmat = { // emissive material for engine exhaust
		{0,0,0,1},
		{0,0,0,1},
		{0,0,0,1},
		{1,1,1,1},
		0.0
	};
	for (i = 0; i < nexhaust; i++) {
		if (!(lvl = vessel->GetExhaustLevel (i))) continue;
		vessel->GetExhaustSpec (i, &lscale, &wscale, &pos, &dir, (SURFHANDLE*)&tex);

		if (need_setup) { // initialise render state
			MATRIX3 R;
			vessel->GetRotationMatrix (R);
			cdir = tmul (R, cpos);
			dev->SetRenderState (D3DRS_ZWRITEENABLE, FALSE);
			dev->SetMaterial (&engmat);
			dev->SetTransform (D3DTS_WORLD, &mWorld);
			need_setup = false;
		}
		if (!tex) tex = defexhausttex;
		if (tex != ptex) dev->SetTexture (0, ptex = tex);

		xsize = sqrt (zsize = lvl);
		dev->SetIndices(ExhaustIdx);
		VERTEX_XYZ_TEX *data;
		ExhaustVtb->Lock(0, 0, (LPVOID*) &data, 0);
		SetExhaustVertices (-dir, cdir, pos, zsize*lscale, xsize*wscale, data);
		ExhaustVtb->Unlock();
		dev->SetStreamSource(0, ExhaustVtb, 0, sizeof(VERTEX_XYZ_TEX));
		dev->SetFVF(FVF_XYZ_TEX);
		
		dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, 8, 0, 4);

	}
	if (!need_setup) { // reset render state
		dev->SetRenderState (D3DRS_ZWRITEENABLE, TRUE);
	}
	return true;
}
void vVessel::RenderGroundShadow (LPDIRECT3DDEVICE9 dev, OBJHANDLE hPlanet)
{
	static const double eps = 1e-2;
	static const double shadow_elev_limit = 0.07;
	double d, alt, R;
	VECTOR3 pp, sd, pvr;
	oapiGetGlobalPos (hPlanet, &pp); // planet global pos
	vessel->GetGlobalPos (sd);       // vessel global pos
	pvr = sd-pp;                     // planet-relative vessel position
	d = length(pvr);                 // vessel-planet distance
	R = oapiGetSize (hPlanet);       // planet mean radius
	alt = d-R;                       // altitude above surface
	if (alt*eps > vessel->GetSize()) // too high to cast a shadow
		return;
	normalise (sd);                  // shadow projection direction

	// calculate the intersection of the vessel's shadow with the planet surface
	double fac1 = dotp (sd, pvr);
	if (fac1 > 0.0)                  // shadow doesn't intersect planet surface
		return;
	double csun = -fac1/d;           // sun elevation above horizon
	if (csun < shadow_elev_limit)    // sun too low to cast shadow
		return;
	double arg  = fac1*fac1 - (dotp (pvr, pvr) - R*R);
	if (arg <= 0.0)                  // shadow doesn't intersect with planet surface
		return;
	double a = -fac1 - sqrt(arg);

	MATRIX3 vR;
	vessel->GetRotationMatrix (vR);
	VECTOR3 sdv = tmul (vR, sd);     // projection direction in vessel frame
	VECTOR3 shp = sdv*a;             // projection point
	VECTOR3 hnp = sd*a + pvr; normalise (hnp); // horizon normal
	VECTOR3 hn = tmul (vR, hnp);     // horizon normal in vessel frame

	// perform projections
	double nr0 = dotp (hn, shp);
	double nd  = dotp (hn, sdv);
	VECTOR3 sdvs = sdv / nd;

	DWORD j;

	// build shadow projection matrix
	D3DMATRIX mProj, mProjWorld, mProjWorldShift;
	mProj._11 = 1.0f - (float)(sdvs.x*hn.x);
	mProj._12 =      - (float)(sdvs.y*hn.x);
	mProj._13 =      - (float)(sdvs.z*hn.x);
	mProj._14 = 0;
	mProj._21 =      - (float)(sdvs.x*hn.y);
	mProj._22 = 1.0f - (float)(sdvs.y*hn.y);
	mProj._23 =      - (float)(sdvs.z*hn.y);
	mProj._24 = 0;
	mProj._31 =      - (float)(sdvs.x*hn.z);
	mProj._32 =      - (float)(sdvs.y*hn.z);
	mProj._33 = 1.0f - (float)(sdvs.z*hn.z);
	mProj._34 = 0;
	mProj._41 =        (float)(sdvs.x*nr0);
	mProj._42 =        (float)(sdvs.y*nr0);
	mProj._43 =        (float)(sdvs.z*nr0);
	mProj._44 = 1;
	D3DMAT_MatrixMultiply (&mProjWorld, &mWorld, &mProj);
	bool isProjWorld = false;

	// modify depth of shadows at dawn/dusk
	DWORD tfactor;
	bool resetalpha = false;
	if (gc->UseStencilBuffer()) {
		double scale = min (1, (csun-0.07)/0.015);
		if (scale < 1) {
			dev->GetRenderState (D3DRS_TEXTUREFACTOR, &tfactor);
			double modalpha = scale*(tfactor>>24)/256.0;
			dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_COLORVALUE(0,0,0,modalpha));
			resetalpha = true;
		}
	}

	// project all vessel meshes. This should be replaced by a dedicated shadow mesh
	for (UINT i = 0; i < nmesh; i++) {
		if (!meshlist[i].mesh) continue;
		if (!(meshlist[i].vismode & MESHVIS_EXTERNAL)) continue; // only render shadows for externally visible meshes
		D3D9Mesh *mesh = meshlist[i].mesh;
		if (meshlist[i].trans) {
			// add mesh offset to transformation
			D3DMAT_MatrixMultiply (&mProjWorldShift, &mProjWorld, meshlist[i].trans);
			dev->SetTransform (D3DTS_WORLD, &mProjWorldShift);
			isProjWorld = false;
		} else {
			if (!isProjWorld) {
				dev->SetTransform (D3DTS_WORLD, &mProjWorld);
				isProjWorld = true;
			}
		}
		for (j = 0; j < mesh->GroupCount(); j++) {
			D3D9Mesh::GROUPREC *grp = mesh->GetGroup(j);
			if (grp->UsrFlag & 1) continue; // "no shadow" flag
			mesh->RenderGroup (dev, grp);	
		}
	}
	if (resetalpha)
		dev->SetRenderState (D3DRS_TEXTUREFACTOR, tfactor);
}


void vVessel::SetExhaustVertices (const VECTOR3 &edir, const VECTOR3 &cdir, const VECTOR3 &ref,
	double lscale, double wscale, VERTEX_XYZ_TEX *ev)
{
	// need to rotate the billboard so it faces the observer
	const float flarescale = 7.0;
	VECTOR3 sdir = crossp (cdir, edir); normalise (sdir);
	VECTOR3 tdir = crossp (cdir, sdir); normalise (tdir);
	float rx = (float)ref.x, ry = (float)ref.y, rz = (float)ref.z;
	float sx = (float)(sdir.x*wscale);
	float sy = (float)(sdir.y*wscale);
	float sz = (float)(sdir.z*wscale);
	float ex = (float)(edir.x*lscale);
	float ey = (float)(edir.y*lscale);
	float ez = (float)(edir.z*lscale);
	ev[1].x = (ev[0].x = rx + sx) + ex;
	ev[1].y = (ev[0].y = ry + sy) + ey;
	ev[1].z = (ev[0].z = rz + sz) + ez;
	ev[3].x = (ev[2].x = rx - sx) + ex;
	ev[3].y = (ev[2].y = ry - sy) + ey;
	ev[3].z = (ev[2].z = rz - sz) + ez;
	wscale *= flarescale, sx *= flarescale, sy *= flarescale, sz *= flarescale;
	float tx = (float)(tdir.x*wscale);
	float ty = (float)(tdir.y*wscale);
	float tz = (float)(tdir.z*wscale);
	ev[4].x = rx - sx + tx;   ev[5].x = rx + sx + tx;
	ev[4].y = ry - sy + ty;   ev[5].y = ry + sy + ty;
	ev[4].z = rz - sz + tz;   ev[5].z = rz + sz + tz;
	ev[6].x = rx - sx - tx;   ev[7].x = rx + sx - tx;
	ev[6].y = ry - sy - ty;   ev[7].y = ry + sy - ty;
	ev[6].z = rz - sz - tz;   ev[7].z = rz + sz - tz;
}

void vVessel::Animate (UINT an, double state, UINT mshidx)
{
	double s0, s1, ds;
	UINT i, ii;
	D3DMATRIX T;
	ANIMATION *A = anim+an;
	for (ii = 0; ii < A->ncomp; ii++) {
		i = (state > animstate[an] ? ii : A->ncomp-ii-1);
		ANIMATIONCOMP *AC = A->comp[i];
		if (mshidx != (UINT)-1 && mshidx != AC->trans->mesh) continue;
		s0 = animstate[an]; // current animation state in the visual
		if      (s0 < AC->state0) s0 = AC->state0;
		else if (s0 > AC->state1) s0 = AC->state1;
		s1 = state;           // required animation state
		if      (s1 < AC->state0) s1 = AC->state0;
		else if (s1 > AC->state1) s1 = AC->state1;
		if ((ds = (s1-s0)) == 0) continue; // nothing to do for this component
		ds /= (AC->state1 - AC->state0);   // stretch to range 0..1

		// Build transformation matrix
		switch (AC->trans->Type()) {
		case MGROUP_TRANSFORM::NULLTRANSFORM:
			D3DMAT_Identity (&T);
			AnimateComponent (AC, T);
			break;
		case MGROUP_TRANSFORM::ROTATE: {
			MGROUP_ROTATE *rot = (MGROUP_ROTATE*)AC->trans;
			D3DVECTOR ax = {(float)(rot->axis.x), (float)(rot->axis.y), (float)(rot->axis.z)};
			D3DMAT_RotationFromAxis (ax, (float)ds*rot->angle, &T);
			float dx = (float)(rot->ref.x), dy = (float)(rot->ref.y), dz = (float)(rot->ref.z);
			T._41 = dx - T._11*dx - T._21*dy - T._31*dz;
			T._42 = dy - T._12*dx - T._22*dy - T._32*dz;
			T._43 = dz - T._13*dx - T._23*dy - T._33*dz;
			AnimateComponent (AC, T);
			} break;
		case MGROUP_TRANSFORM::TRANSLATE: {
			MGROUP_TRANSLATE *lin = (MGROUP_TRANSLATE*)AC->trans;
			D3DMAT_Identity (&T);
			T._41 = (float)(ds*lin->shift.x);
			T._42 = (float)(ds*lin->shift.y);
			T._43 = (float)(ds*lin->shift.z);
			AnimateComponent (AC, T);
			} break;
		case MGROUP_TRANSFORM::SCALE: {
			MGROUP_SCALE *scl = (MGROUP_SCALE*)AC->trans;
			s0 = (s0-AC->state0)/(AC->state1-AC->state0);
			s1 = (s1-AC->state0)/(AC->state1-AC->state0);
			D3DMAT_Identity (&T);
			T._11 = (float)((s1*(scl->scale.x-1)+1)/(s0*(scl->scale.x-1)+1));
			T._22 = (float)((s1*(scl->scale.y-1)+1)/(s0*(scl->scale.y-1)+1));
			T._33 = (float)((s1*(scl->scale.z-1)+1)/(s0*(scl->scale.z-1)+1));
			T._41 = (float)scl->ref.x * (1.0f-T._11);
			T._42 = (float)scl->ref.y * (1.0f-T._22);
			T._43 = (float)scl->ref.z * (1.0f-T._33);
			AnimateComponent (AC, T);
			} break;
		}
	}
}

void vVessel::AnimateComponent (ANIMATIONCOMP *comp, const D3DMATRIX &T)
{
	UINT i;
	MGROUP_TRANSFORM *trans = comp->trans;

	if (trans->mesh == LOCALVERTEXLIST) { // transform a list of individual vertices

		VECTOR3 *vtx = (VECTOR3*)trans->grp;
		for (i = 0; i < trans->ngrp; i++)
			TransformPoint (vtx[i], T);

	} else {                              // transform mesh groups

		if (trans->mesh >= nmesh) return; // mesh index out of range
		D3D9Mesh *mesh = meshlist[trans->mesh].mesh;
		if (!mesh) return;

		if (trans->grp) { // animate individual mesh groups
			for (i = 0; i < trans->ngrp; i++)
				mesh->TransformGroup (trans->grp[i], &T);
		} else {          // animate complete mesh
//			mesh->Transform (T);
		}
	}

	// recursively transform all child animations
	for (i = 0; i < comp->nchildren; i++) {
		ANIMATIONCOMP *child = comp->children[i];
		AnimateComponent (child, T);
		switch (child->trans->Type()) {
		case MGROUP_TRANSFORM::NULLTRANSFORM:
			break;
		case MGROUP_TRANSFORM::ROTATE: {
			MGROUP_ROTATE *rot = (MGROUP_ROTATE*)child->trans;
			TransformPoint (rot->ref, T);
			TransformDirection (rot->axis, T, true);
			} break;
		case MGROUP_TRANSFORM::TRANSLATE: {
			MGROUP_TRANSLATE *lin = (MGROUP_TRANSLATE*)child->trans;
			TransformDirection (lin->shift, T, false);
			} break;
		case MGROUP_TRANSFORM::SCALE: {
			MGROUP_SCALE *scl = (MGROUP_SCALE*)child->trans;
			TransformPoint (scl->ref, T);
			// we can't transform anisotropic scaling vector
			} break;
		}
	}
}

LPDIRECT3DTEXTURE9 vVessel::mfdsurf = 0;
LPDIRECT3DTEXTURE9 vVessel::defexhausttex = 0;
LPDIRECT3DVERTEXBUFFER9 vVessel::ExhaustVtb = 0;
LPDIRECT3DINDEXBUFFER9 vVessel::ExhaustIdx = 0;

// ==============================================================
// Nonmember helper functions

void TransformPoint (VECTOR3 &p, const D3DMATRIX &T)
{
	double x = p.x*T._11 + p.y*T._21 + p.z*T._31 + T._41;
	double y = p.x*T._12 + p.y*T._22 + p.z*T._32 + T._42;
	double z = p.x*T._13 + p.y*T._23 + p.z*T._33 + T._43;
	double w = p.x*T._14 + p.y*T._24 + p.z*T._34 + T._44;
    p.x = x/w;
	p.y = y/w;
	p.z = z/w;
}

void TransformDirection (VECTOR3 &a, const D3DMATRIX &T, bool normalise)
{
	double x = a.x*T._11 + a.y*T._21 + a.z*T._31;
	double y = a.x*T._12 + a.y*T._22 + a.z*T._32;
	double z = a.x*T._13 + a.y*T._23 + a.z*T._33;
	a.x = x, a.y = y, a.z = z;
	if (normalise) {
		double len = sqrt (x*x + y*y + z*z);
		a.x /= len;
		a.y /= len;
		a.z /= len;
	}
}

