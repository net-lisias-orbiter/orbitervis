// ====================================================================================
// File: D3D9Util.h
// Desc: Helper functions and typing shortcuts for Direct3D programming.
// ====================================================================================

#ifndef __D3DUTIL_H
#define __D3DUTIL_H

// Note: must include OrbiterAPI.h *first* to fix warnings on VS2003+
#include "OrbiterAPI.h"
#include "debug.h"
#include <d3d9.h>
#include <d3dx9.h>

// ------------------------------------------------------------------------------------
// Conversion functions
// ------------------------------------------------------------------------------------

inline void D3DVEC (const VECTOR3 &v, D3DVECTOR &d3dv)
{
	d3dv.x = (float)v.x;
	d3dv.y = (float)v.y;
	d3dv.z = (float)v.z;
}

// ------------------------------------------------------------------------------------
// D3D vector and matrix operations
// ------------------------------------------------------------------------------------

void D3DMAT_Identity (D3DMATRIX *mat);
void D3DMAT_Copy (D3DMATRIX *tgt, const D3DMATRIX *src);
void D3DMAT_SetRotation (D3DMATRIX *mat, const MATRIX3 *rot);
void D3DMAT_SetInvRotation (D3DMATRIX *mat, const MATRIX3 *rot);
void D3DMAT_RotationFromAxis (const D3DVECTOR &axis, float angle, D3DMATRIX *rot);

// Set up a as matrix for ANTICLOCKWISE rotation r around x/y/z-axis
void D3DMAT_RotX (D3DMATRIX *mat, double r);
void D3DMAT_RotY (D3DMATRIX *mat, double r);

void D3DMAT_SetTranslation (D3DMATRIX *mat, const VECTOR3 *trans);
void D3DMAT_MatrixMultiply (D3DMATRIX *res, const D3DMATRIX *a, const D3DMATRIX *b);
bool D3DMAT_VectorMatrixMultiply (D3DVECTOR *res, const D3DVECTOR *v, const D3DMATRIX *mat);
HRESULT D3DMAT_MatrixInvert (D3DMATRIX *res, D3DMATRIX *a);

// ------------------------------------------------------------------------------------
// Vertex formats
// ------------------------------------------------------------------------------------

struct VECTOR2D     { float x, y; };

struct VERTEX_XYZ   { float x, y, z; };                   // transformed vertex
struct VERTEX_XYZH  { float x, y, z, h; };                // untransformed vertex
struct VERTEX_XYZC  { float x, y, z; D3DCOLOR col; };     // untransformed vertex with single colour component
struct VERTEX_XYZHC { float x, y, z, h; D3DCOLOR col; };  // transformed vertex with single colour component
struct VERTEX_XYZHT { float x, y, z, h, u, v; };          // transformed vertex with texture component

#define FVF_XYZHT (D3DFVF_XYZRHW | D3DFVF_TEX1 | D3DFVF_TEXCOORDSIZE2(0))

// untransformed lit vertex with texture coordinates
struct VERTEX_XYZ_TEX {
	float x, y, z;
	float tu, tv;
};
#define FVF_XYZ_TEX ( D3DFVF_XYZ | D3DFVF_TEX1 | D3DFVF_TEXCOORDSIZE2(0) )


// untransformed unlit vertex with two sets of texture coordinates
struct VERTEX_2TEX  {
	float x, y, z, nx, ny, nz;
	float tu0, tv0, tu1, tv1;
	inline VERTEX_2TEX() {}
	//VERTEX_2TEX ()
	//{ x = y = z = nx = ny = nz = tu0 = tv0 = tu1 = tv1 = 0.0f; }
	inline VERTEX_2TEX (D3DVECTOR p, D3DVECTOR n, float u0, float v0, float u1, float v1)
	{ x = p.x, y = p.y, z = p.z, nx = n.x, ny = n.y, nz = n.z;
  	  tu0 = u0, tv0 = v0, tu1 = u1, tv1 = v1; }
};
#define FVF_2TEX ( D3DFVF_XYZ | D3DFVF_NORMAL | D3DFVF_TEX2 | D3DFVF_TEXCOORDSIZE2(0) | D3DFVF_TEXCOORDSIZE2(1) )

// transformed lit vertex with 1 colour definition and one set of texture coordinates
struct VERTEX_TL1TEX {
	float x, y, z, rhw;
	D3DCOLOR col;
	float tu, tv;
};
#define FVF_TL1TEX ( D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_TEX1 | D3DFVF_TEXCOORDSIZE2(0) )

#define FVF_NTVERTEX ( D3DFVF_XYZ | D3DFVF_NORMAL | D3DFVF_TEX1 | D3DFVF_TEXCOORDSIZE2(0) )

// transformed lit vertex with two sets of texture coordinates
struct VERTEX_TL2TEX {
	float x, y, z, rhw;
	D3DCOLOR diff, spec;
	float tu0, tv0, tu1, tv1;
};
#define FVF_TL2TEX ( D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_SPECULAR | D3DFVF_TEX2 | D3DFVF_TEXCOORDSIZE2(0) | D3DFVF_TEXCOORDSIZE2(1) )

//VERTEX_XYZ  *GetVertexXYZ  (DWORD n);
//VERTEX_XYZC *GetVertexXYZC (DWORD n);
// Return pointer to static vertex buffer of given type of at least size n

// ------------------------------------------------------------------------------------
// Miscellaneous helper functions
// ------------------------------------------------------------------------------------

#define SAFE_DELETE(p)  { if(p) { delete (p);     (p)=NULL; } }
#define SAFE_RELEASE(p) { if(p) { (p)->Release(); (p)=NULL; } }

#endif // !__D3DUTIL_H