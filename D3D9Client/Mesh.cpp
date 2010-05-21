// ==============================================================
// Mesh.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

// ==============================================================
// class D3D9Mesh (implementation)
//
// This class represents a mesh in terms of DX7 interface elements
// (vertex buffers, index lists, materials, textures) which allow
// it to be rendered to the D3D7 device.
// ==============================================================

// DX9 port: Mesh objects now work with native indexbuffer objects
// Index buffers are not deep copied, since they won't change.
// Native indexbuffers can be stored in hardware and should improve speed.

#include "Mesh.h"

using namespace oapi;

static D3DMATERIAL9 defmat = {
	{1,1,1,1},
	{1,1,1,1},
	{0,0,0,1},
	{0,0,0,1},0
};

D3D9Mesh::D3D9Mesh (const D3D9Client *client)
{
	gc = client;
	bTemplate = false;
	bVideoMem = (gc->GetFramework()->IsTLDevice() == TRUE);
	nGrp = 0;
	nTex = 1;
	Tex = new LPDIRECT3DTEXTURE9[nTex];
	Tex[0] = 0;
	nMtrl = 0;
}

D3D9Mesh::D3D9Mesh (const D3D9Client *client, GROUPREC *grp, bool deepcopy)
{
	gc = client;
	bTemplate = false;
	bVideoMem = (gc->GetFramework()->IsTLDevice() == TRUE);
	nGrp = 0;
	nTex = 1;
	Tex = new LPDIRECT3DTEXTURE9[nTex];
	Tex[0] = 0;
	nMtrl = 0;
	grp->MtrlIdx = SPEC_DEFAULT;
	grp->TexIdx = SPEC_DEFAULT;
	for (DWORD n = 0; n < MAXTEX; n++) {
		grp->TexIdxEx[n] = SPEC_DEFAULT;
		grp->TexMixEx[n] = 0.0;
	}
	AddGroup (grp, deepcopy);
}

D3D9Mesh::D3D9Mesh (const D3D9Client *client, MESHHANDLE hMesh, bool asTemplate)
{
	DWORD i;
	gc = client;
	bTemplate = asTemplate;
	bVideoMem = (gc->GetFramework()->IsTLDevice() && !bTemplate);
	// template meshes are stored in system memory
	nGrp = oapiMeshGroupCount (hMesh);
	Grp = new GROUPREC*[nGrp];
	for (i = 0; i < nGrp; i++) {
		Grp[i] = new GROUPREC;
		MESHGROUPEX *mg = oapiMeshGroupEx (hMesh, i);
		CopyGroup (Grp[i], mg);
	}
	nTex = oapiMeshTextureCount (hMesh)+1;
	Tex = new LPDIRECT3DTEXTURE9[nTex];
	Tex[0] = 0; // 'no texture'
	for (i = 1; i < nTex; i++) {
		Tex[i] = (LPDIRECT3DTEXTURE9)oapiGetTextureHandle (hMesh, i);
		if (Tex[i])
			Tex[i]->AddRef();
		// no deep copy here - texture templates shouldn't be modified by vessels
	}
	nMtrl = oapiMeshMaterialCount (hMesh);
	if (nMtrl)
		Mtrl = new D3DMATERIAL9[nMtrl];
	for (i = 0; i < nMtrl; i++)
		CopyMaterial (Mtrl+i, oapiMeshMaterial (hMesh, i));
}

D3D9Mesh::D3D9Mesh (const D3D9Mesh &mesh)
{
	// note: 'mesh' must be a template mesh, because we may not be able to
	// access vertex data in video memory
	DWORD i;
	gc = mesh.gc;
	bTemplate = false;
	bVideoMem = (gc->GetFramework()->IsTLDevice() ? true:false);
	nGrp = mesh.nGrp;
	Grp = new GROUPREC*[nGrp];
	for (i = 0; i < nGrp; i++)
	{
		Grp[i] = new GROUPREC;
		CopyGroup (Grp[i], mesh.Grp[i]);
	}
	nTex = mesh.nTex;
	Tex = new LPDIRECT3DTEXTURE9[nTex];
	for (i = 0; i < nTex; i++) {
		Tex[i] = mesh.Tex[i];
		// no deep copy here - texture templates shouldn't be modified by vessels
		if (Tex[i])
			Tex[i]->AddRef();
	}
	nMtrl = mesh.nMtrl;
	if (nMtrl)
		Mtrl = new D3DMATERIAL9[nMtrl];
	memcpy (Mtrl, mesh.Mtrl, nMtrl*sizeof(D3DMATERIAL9));
}

D3D9Mesh::~D3D9Mesh ()
{
	ClearGroups();
	if (nTex) delete []Tex;
	if (nMtrl) delete []Mtrl;
}

DWORD D3D9Mesh::AddGroup (GROUPREC *grp, bool deepcopy)
{
	GROUPREC **tmp = new GROUPREC*[nGrp+1];
	if (nGrp) {
		memcpy (tmp, Grp, nGrp*sizeof(GROUPREC*));
		delete []Grp;
	}
	Grp = tmp;
	if (deepcopy) CopyGroup (Grp[nGrp], grp);
	else          Grp[nGrp] = grp;

	return nGrp++;
}
bool D3D9Mesh::CopyGroup (GROUPREC *tgt, const GROUPREC *src)
{
	D3DVERTEXBUFFER_DESC desc;

	tgt->nVtx = src->nVtx;
	tgt->nIdx = src->nIdx;
	tgt->TexIdx = src->TexIdx;
	memcpy (tgt->TexIdxEx, src->TexIdxEx, MAXTEX*sizeof(DWORD));
	memcpy (tgt->TexMixEx, src->TexMixEx, MAXTEX*sizeof(float));
	tgt->MtrlIdx = src->MtrlIdx;
	tgt->UsrFlag = src->UsrFlag;
	tgt->IntFlag = src->IntFlag;

	src->VtxBuf->GetDesc(&desc);

	// create the vertex buffer
	LPDIRECT3D9 d3d = gc->GetDirect3D9();
	LPDIRECT3DDEVICE9 dev = gc->GetDevice();
	LPVOID data, srcdata;
	bool bVMem = (bVideoMem && (tgt->IntFlag & 0x04));
	if (FAILED(dev->CreateVertexBuffer(desc.Size, desc.Usage, desc.FVF, desc.Pool, &tgt->VtxBuf, NULL)))
		return false;

	tgt->VtxBuf->Lock (0, 0, (LPVOID*)&data, 0);
	src->VtxBuf->Lock (0, 0, (LPVOID*)&srcdata, 0);
	memcpy (data, srcdata, desc.Size);
	tgt->VtxBuf->Unlock();
	src->VtxBuf->Unlock();

	tgt->Idx = src->Idx;		// Only shallow copy the index buffers.
	tgt->Idx->AddRef();

	return true;
}

bool D3D9Mesh::CopyGroup (GROUPREC *grp, const MESHGROUPEX *mg)
{
	grp->nVtx = mg->nVtx;
	grp->nIdx = mg->nIdx;
	grp->TexIdx = mg->TexIdx;
	memcpy (grp->TexIdxEx, mg->TexIdxEx, MAXTEX*sizeof(DWORD));
	memcpy (grp->TexMixEx, mg->TexMixEx, MAXTEX*sizeof(float));
	if (grp->TexIdx != SPEC_DEFAULT && grp->TexIdx != SPEC_INHERIT) grp->TexIdx++;
	for (DWORD n = 0; n < MAXTEX; n++)
		if (grp->TexIdxEx[n] != SPEC_DEFAULT) grp->TexIdxEx[n]++;
	grp->MtrlIdx = mg->MtrlIdx;
	grp->UsrFlag = mg->UsrFlag;
	grp->IntFlag = mg->Flags;

	// create the vertex buffer
	LPDIRECT3D9 d3d = gc->GetDirect3D9();
	LPDIRECT3DDEVICE9 dev = gc->GetDevice();
	LPVOID data;
	bool bVMem = (bVideoMem && (mg->Flags & 0x04));

	// {DEB} if (FAILED(dev->CreateVertexBuffer(sizeof(NTVERTEX)*grp->nVtx, 0, FVF_NTVERTEX, D3DPOOL_DEFAULT, &grp->VtxBuf, NULL)))
    if (FAILED(dev->CreateVertexBuffer(sizeof(NTVERTEX)*grp->nVtx, D3DUSAGE_WRITEONLY, FVF_NTVERTEX, D3DPOOL_DEFAULT, &grp->VtxBuf, NULL)))  // must be D3DUSAGE_WRITEONLY to avoid performance penalty!
		return false;

		// need to come up with a more graceful exit
	grp->VtxBuf->Lock (0, 0, (LPVOID*)&data, 0);
	memcpy (data, mg->Vtx, grp->nVtx*sizeof(NTVERTEX));
		// warning: this assumes consistency of Orbiter's NTVERTEX struct with
		// D3DVERTEX. Generally, this will need to be copied element by element	
	grp->VtxBuf->Unlock();

	if (FAILED(dev->CreateIndexBuffer(grp->nIdx *sizeof(WORD), D3DUSAGE_WRITEONLY, D3DFMT_INDEX16, D3DPOOL_DEFAULT, &grp->Idx, NULL)))
		return false;
	grp->Idx->Lock (0, 0, &data, 0);
	memcpy(data, mg->Idx, grp->nIdx*sizeof(WORD));
	grp->Idx->Unlock();

	return true;
}

bool D3D9Mesh::CopyMaterial (D3DMATERIAL9 *mat9, MATERIAL *mat)
{
	memcpy (mat9, mat, sizeof (D3DMATERIAL9));
	return true;
	// exploits the fact that D3DMATERIAL9 and MATERIAL are identical
	// structures. In general, this needs to be converted from one
	// structure to the other.
}

void D3D9Mesh::DeleteGroup (GROUPREC *grp)
{
	if (grp->VtxBuf) grp->VtxBuf->Release();
	if (grp->Idx) grp->Idx->Release();
	delete grp;
}

void D3D9Mesh::ClearGroups ()
{
	if (nGrp) {
		for (DWORD g = 0; g < nGrp; g++) 
			DeleteGroup (Grp[g]);
		delete []Grp;
		nGrp = 0;
	}
}
void D3D9Mesh::SetTexMixture (DWORD ntex, float mix)
{
	ntex--;
	for (DWORD g = 0; g < nGrp; g++) {
		if (Grp[g]->TexIdxEx[ntex] != SPEC_DEFAULT)
			Grp[g]->TexMixEx[ntex] = mix;
	}
}

void D3D9Mesh::RenderGroup (LPDIRECT3DDEVICE9 dev, GROUPREC *grp)
{
#ifdef UNDEF
	if (setstate) {
		if (grp->TexIdx[0] != SPEC_INHERIT) {
			if (grp->TexIdx[0] < nTex)
				dev->SetTexture (0, Tex[grp->TexIdx[0]]);
			else
				dev->SetTexture (0, 0);
		}
		if (grp->MtrlIdx != SPEC_INHERIT) {
			if (grp->MtrlIdx < nMtrl)
				dev->SetMaterial (Mtrl+grp->MtrlIdx);
			else
				dev->SetMaterial (&defmat);
		}
	}
#endif

	dev->SetIndices(grp->Idx);
	dev->SetFVF(FVF_NTVERTEX);
	dev->SetStreamSource(0, grp->VtxBuf, 0, sizeof(NTVERTEX));
	dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, grp->nVtx, 0, grp->nIdx/3);
}

void D3D9Mesh::Render (LPDIRECT3DDEVICE9 dev)
{
	dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
	DWORD g, j, n, mi, pmi, ti, pti;
	bool skipped = false;
	bool texstage[MAXTEX] = {false};

	for (g = 0; g < nGrp; g++) {
		if (Grp[g]->UsrFlag & 2) { // user skip
			skipped = true;
			continue;
		}

		// set material
		if ((mi = Grp[g]->MtrlIdx) == SPEC_INHERIT && skipped) // find last valid material
			for (j = g-1; j >= 0; j--)
				if ((mi = Grp[j]->MtrlIdx) != SPEC_INHERIT) break;
		if (mi != SPEC_INHERIT && (!g || mi != pmi)) {
			D3DMATERIAL9 *mat = (mi != SPEC_DEFAULT ? Mtrl+mi : &defmat);
			dev->SetMaterial (mat);
			// need to check for specular here
			pmi = mi;
		}
		
		// set primary texture
		if ((ti = Grp[g]->TexIdx) == SPEC_INHERIT && skipped) // find last valid texture
			for (j = g-1; j >= 0; j--)
				if ((ti = Grp[j]->TexIdx) != SPEC_INHERIT) break;
		if (ti != SPEC_INHERIT && (!g || (ti != pti))) {
			dev->SetTexture (0, ti != SPEC_DEFAULT ? Tex[ti] : 0);
			pti = ti;
		}

		// set additional textures
		for (n = 0; n < MAXTEX; n++) {
			if (Grp[g]->TexMixEx[n] && (ti = Grp[g]->TexIdxEx[n]) != SPEC_DEFAULT) {
				dev->SetTexture (n+1, Tex[ti]);
				dev->SetTextureStageState (n+1, D3DTSS_COLOROP, D3DTOP_ADD);
				dev->SetSamplerState(n+1, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP);
				dev->SetSamplerState(n+1, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP);
				dev->SetSamplerState(n+1, D3DSAMP_ADDRESSW, D3DTADDRESS_WRAP);
				texstage[n] = true;
			} else if (texstage[n]) {
				dev->SetTextureStageState (n+1, D3DTSS_COLOROP, D3DTOP_DISABLE);
				texstage[n] = false;
			}
		}


		RenderGroup (dev, Grp[g]);
	}
	for (n = 0; n < MAXTEX; n++) {
		if (texstage[n]) 
			dev->SetTextureStageState (n+1, D3DTSS_COLOROP, D3DTOP_DISABLE);
	}
}

void D3D9Mesh::TransformGroup (DWORD n, const D3DMATRIX *m)
{
	GROUPREC *grp = Grp[n];
	int i, nv = grp->nVtx;
	NTVERTEX *vtx;
	grp->VtxBuf->Lock (0, 0, (LPVOID*)&vtx, 0);
	FLOAT x, y, z, w;

	for (i = 0; i < nv; i++) {
		NTVERTEX &v = vtx[i];
		x = v.x*m->_11 + v.y*m->_21 + v.z* m->_31 + m->_41;
		y = v.x*m->_12 + v.y*m->_22 + v.z* m->_32 + m->_42;
		z = v.x*m->_13 + v.y*m->_23 + v.z* m->_33 + m->_43;
		w = v.x*m->_14 + v.y*m->_24 + v.z* m->_34 + m->_44;
    	v.x = x/w;
		v.y = y/w;
		v.z = z/w;

		x = v.nx*m->_11 + v.ny*m->_21 + v.nz* m->_31;
		y = v.nx*m->_12 + v.ny*m->_22 + v.nz* m->_32;
		z = v.nx*m->_13 + v.ny*m->_23 + v.nz* m->_33;
		w = 1.0f/(FLOAT)sqrt (x*x + y*y + z*z);
		v.nx = x*w;
		v.ny = y*w;
		v.nz = z*w;
	}
	grp->VtxBuf->Unlock();
	//if (GrpSetup) SetupGroup (grp);
}

