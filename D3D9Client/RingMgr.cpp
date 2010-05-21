// ==============================================================
// RingMgr.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class RingManager (implementation)
// ==============================================================

#define D3D_OVERLOADS
#include "RingMgr.h"
#include "Texture.h"

using namespace oapi;

RingManager::RingManager (const vPlanet *vplanet, double inner_rad, double outer_rad)
{
	vp = vplanet;
	irad = inner_rad;
	orad = outer_rad;
	rres = (DWORD)-1;
	tres = 0;
	ntex = 0;
	for (DWORD i = 0; i < MAXRINGRES; i++) {
		mesh[i] = 0;
		tex[i] = 0;
	}
}

RingManager::~RingManager ()
{
	DWORD i;
	for (i = 0; i < 3; i++)
		if (mesh[i]) delete mesh[i];
	for (i = 0; i < ntex; i++)
		tex[i]->Release();
}

void RingManager::GlobalInit (const D3D9Client *gclient)
{
	gc = gclient;
}

void RingManager::SetMeshRes (DWORD res)
{
	if (res != rres) {
		rres = res;
		if (!mesh[res])
			mesh[res] = CreateRing (irad, orad, 8+res*4);
		if (!ntex)
			ntex = LoadTextures();
		tres = min (rres, ntex-1);
	}
}

DWORD RingManager::LoadTextures ()
{
	char fname[256];
	oapiGetObjectName (vp->Object(), fname, 256);
	strcat (fname, "_ring.tex");
	return gc->GetTexMgr()->LoadTextures (fname, tex, MAXRINGRES);
}

bool RingManager::Render (LPDIRECT3DDEVICE9 dev, D3DMATRIX &mWorld)
{
	DWORD ablend;
	MATRIX3 grot;
	static D3DMATRIX imat, *ringmat;
	oapiGetRotationMatrix (vp->Object(), &grot);
	VECTOR3 ppos = tmul(grot, -vp->cpos);
	if (ppos.y >= 0) { // camera above equator
		ringmat = &mWorld;
	} else {           // flip rings
		int i;
		for (i = 0; i < 4; i++) imat.m[0][i] =  mWorld.m[0][i];
		for (i = 0; i < 4; i++) imat.m[1][i] = -mWorld.m[1][i];
		for (i = 0; i < 4; i++) imat.m[2][i] = -mWorld.m[2][i];
		for (i = 0; i < 4; i++) imat.m[3][i] =  mWorld.m[3][i];
		ringmat = &imat;
	}

	dev->SetTransform (D3DTS_WORLD, ringmat);
	dev->SetTexture (0, tex[tres]);
	dev->GetRenderState (D3DRS_ALPHABLENDENABLE, &ablend);
	if (!ablend)
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);

	mesh[rres]->RenderGroup (dev, mesh[rres]->GetGroup(0));

	if (!ablend)
		dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);

	return true;
}

// =======================================================================
// CreateRing
// Creates mesh for rendering planetary ring system. Creates a ring
// with nsect quadrilaterals. Smoothing the corners of the mesh is
// left to texture transparency. Nsect should be an even number.
// Disc is in xz-plane centered at origin facing up. Size is such that
// a ring of inner radius irad (>=1) and outer radius orad (>irad)
// can be rendered on it.

D3D9Mesh *RingManager::CreateRing (double irad, double orad, int nsect)
{
	int i, j;

	D3D9Mesh::GROUPREC *grp = new D3D9Mesh::GROUPREC;
	grp->nVtx = 2*nsect;

	LPDIRECT3D9 d3d = gc->GetDirect3D9();
	LPDIRECT3DDEVICE9 dev = gc->GetDevice();

	grp->nIdx = 6*nsect;
    // {DEB} dev->CreateIndexBuffer(sizeof(WORD)*grp->nIdx, 0, D3DFMT_INDEX16, D3DPOOL_DEFAULT, &grp->Idx, NULL);
    dev->CreateIndexBuffer(sizeof(WORD)*grp->nIdx, D3DUSAGE_WRITEONLY, D3DFMT_INDEX16, D3DPOOL_DEFAULT, &grp->Idx, NULL);  // must be write-only to avoid performance penalty here!

	NTVERTEX *Vtx;
	WORD *Idx;
    // {DEB} dev->CreateVertexBuffer(sizeof(NTVERTEX) * grp->nVtx, 0, FVF_NTVERTEX, D3DPOOL_DEFAULT, &grp->VtxBuf, NULL);
    dev->CreateVertexBuffer(sizeof(NTVERTEX) * grp->nVtx, D3DUSAGE_WRITEONLY, FVF_NTVERTEX, D3DPOOL_DEFAULT, &grp->VtxBuf, NULL);  // must be write-only to avoid performance penalty here!

	grp->VtxBuf->Lock(0, 0, (LPVOID*)&Vtx, D3DLOCK_DISCARD);
	grp->Idx->Lock(0, 0, (LPVOID*)&Idx, D3DLOCK_DISCARD);

	double alpha = PI/(double)nsect;
	float nrad = (float)(orad/cos(alpha)); // distance for outer nodes
	float ir = (float)irad;
	float fo = (float)(0.5*(1.0-orad/nrad));
	float fi = (float)(0.5*(1.0-irad/nrad));

	for (i = j = 0; i < nsect; i++) {
		double phi = i*2.0*alpha;
		float cosp = (float)cos(phi), sinp = (float)sin(phi);
		Vtx[i*2].x = nrad*cosp;  Vtx[i*2+1].x = ir*cosp;
		Vtx[i*2].z = nrad*sinp;  Vtx[i*2+1].z = ir*sinp;
		Vtx[i*2].y = Vtx[i*2+1].y = 0.0;
		Vtx[i*2].nx = Vtx[i*2+1].nx = Vtx[i*2].nz = Vtx[i*2+1].nz = 0.0;
		Vtx[i*2].ny = Vtx[i*2+1].ny = 1.0;
		if (!(i&1)) Vtx[i*2].tu = fo,  Vtx[i*2+1].tu = fi;  //fac;
		else        Vtx[i*2].tu = 1.0f-fo,  Vtx[i*2+1].tu = 1.0f-fi; //1.0f-fac;
		Vtx[i*2].tv = 0.0f, Vtx[i*2+1].tv = 1.0f;

		Idx[j++] = i*2;
		Idx[j++] = i*2+1;
		Idx[j++] = (i*2+2) % (2*nsect);
		Idx[j++] = (i*2+3) % (2*nsect);
		Idx[j++] = (i*2+2) % (2*nsect);
		Idx[j++] = i*2+1;
	}
	grp->VtxBuf->Unlock();
	grp->Idx->Unlock();
	return new D3D9Mesh (gc, grp, false);
}

const oapi::D3D9Client *RingManager::gc = 0;