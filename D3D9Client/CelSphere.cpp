// ==============================================================
// CelSphere.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006-2007 Martin Schweiger
// ==============================================================

// ==============================================================
// Class CelestialSphere (implementation)
//
// This class is responsible for rendering the celestial sphere
// background (stars, constellations, grids, labels, etc.)
// ==============================================================

#include "CelSphere.h"

#define NSEG 64 // number of segments in celestial grid lines

using namespace oapi;

// ==============================================================

CelestialSphere::CelestialSphere (D3D9Client *_gc)
{
	gc = _gc;
	sphere_r = 1e3f; // the actual render distance for the celestial sphere
	                 // is irrelevant, since it is rendered without z-buffer,
	                 // but it must be within the fustrum limits - check this
	                 // in case the near and far planes are dynamically changed!
	LoadStars ();
	LoadConstellationLines ();
	AllocGrids ();
}

// ==============================================================

CelestialSphere::~CelestialSphere ()
{
	DWORD i;

	if (nsbuf) {
		for (i = 0; i < nsbuf; i++)	svtx[i]->Release();
		delete []svtx;
	}
	if (ncline) delete []cnstvtx;
	grdlng->Release();
	grdlat->Release();
}

// ==============================================================

void CelestialSphere::LoadStars ()
{
	nstar = *(int*)gc->GetConfigParam (CFGPRM_NSTARS);
	if (!nstar) return; // nothing to do

	double brightness, contrast;
	brightness = *(float*)gc->GetConfigParam (CFGPRM_STARBRIGHTNESS);
	contrast   = *(float*)gc->GetConfigParam (CFGPRM_STARCONTRAST);

	GraphicsClient::StarRec *star = new GraphicsClient::StarRec[nstar];
	nstar = gc->LoadStars (nstar, star);
	nsbuf = 0;
	if (nstar) {
		// pixel brightness parameters
		const float eps = 1e-2f;
		float brt = (float)brightness;
		float cnt = (float)contrast;
		float v1 = brt*2.0f - 2.0f/(cnt+eps) + 2.0f;  // mv threshold for maximum intensity
		float v2 = brt*2.0f + 2.0f/(cnt+eps) + 3.0f;  // mv threshold for minimum intensity
		float c0 = 0.2f;          // minimum intensity, applied to stars with mv > v2
		float a  = (1.0f-c0)/(v1-v2);
		float b  = 1.0f - a*v1;

		// create the vertex buffers
		
		nsbuf = (nstar+D3DMAXNUMVERTICES-1) / D3DMAXNUMVERTICES; // number of vertex buffers
		svtx = new LPDIRECT3DVERTEXBUFFER9[nsbuf];

		// copy positions and brightness into vertex buffers
		DWORD i, j, idx, nv;
		int lvl, plvl = 256;
		int c;
		double xz;
		for (i = idx = 0; i < nsbuf; i++) {
			nv = (i < nsbuf-1 ? D3DMAXNUMVERTICES : nstar % D3DMAXNUMVERTICES);
			gc->GetDevice()->CreateVertexBuffer(nv*sizeof(VERTEX_XYZC), D3DUSAGE_WRITEONLY, D3DFVF_XYZ | D3DFVF_DIFFUSE, D3DPOOL_DEFAULT, svtx+i, NULL);
			VERTEX_XYZC *vbuf;
			svtx[i]->Lock (0, 0, (LPVOID*)&vbuf, 0);
			for (j = 0; j < nv; j++) {
				GraphicsClient::StarRec &rec = star[idx];
				VERTEX_XYZC &v = vbuf[j];
				xz = sphere_r * cos (rec.lat);
				v.x = (float)(xz * cos (rec.lng));
				v.z = (float)(xz * sin (rec.lng));
				v.y = (float)(sphere_r * sin (rec.lat));

				c = (int)(255 * (min (1.0f, max (c0, a*rec.mag+b))));
				v.col = D3DCOLOR_RGBA (c,c,c,255);
				lvl = (int)(c*256.0*0.5);
				if (lvl > 255) lvl = 255;
				for (int k = lvl; k < plvl; k++) lvlid[k] = idx;
				plvl = lvl;
				idx++;
			}
			svtx[i]->Unlock();
		}
		for (int k = 0; k < plvl; k++) lvlid[k] = idx;
	}
	delete []star;
}

// ==============================================================

void CelestialSphere::LoadConstellationLines ()
{
	const DWORD maxline = 1000; // plenty for default data base, but check with custom data bases!

	GraphicsClient::ConstRec *cline = new GraphicsClient::ConstRec[maxline];
	ncline = gc->LoadConstellationLines (maxline, cline);
	if (ncline) {
		cnstvtx = new VERTEX_XYZ[ncline*2]; // two end points per line
		DWORD n;
		double xz;
		for (n = 0; n < ncline; n++) {
			GraphicsClient::ConstRec *rec = cline+n;
			xz = sphere_r * cos (rec->lat1);
			cnstvtx[n*2].x = (float)(xz * cos(rec->lng1));
			cnstvtx[n*2].z = (float)(xz * sin(rec->lng1));
			cnstvtx[n*2].y = (float)(sphere_r * sin(rec->lat1));
			xz = sphere_r * cos (rec->lat2);
			cnstvtx[n*2+1].x = (float)(xz * cos(rec->lng2));
			cnstvtx[n*2+1].z = (float)(xz * sin(rec->lng2));
			cnstvtx[n*2+1].y = (float)(sphere_r * sin(rec->lat2));
		}
	}
	delete []cline;
}

// ==============================================================

void CelestialSphere::AllocGrids ()
{
	int i, j, idx;
	double lng, lat, xz, y;

	gc->GetDevice()->CreateVertexBuffer(sizeof(VERTEX_XYZ)*(NSEG+1)*11, D3DUSAGE_WRITEONLY, D3DFVF_XYZ, D3DPOOL_DEFAULT, &grdlng, NULL);
	VERTEX_XYZ *vbuf;
	grdlng->Lock (0, 0, (LPVOID*)&vbuf, 0);
	for (j = idx = 0; j <= 10; j++) {
		lat = (j-5)*15*RAD;
		xz = sphere_r * cos(lat);
		y  = sphere_r * sin(lat);
		for (i = 0; i <= NSEG; i++) {
			lng = 2.0*PI * (double)i/(double)NSEG;
			vbuf[idx].x = (float)(xz * cos(lng));
			vbuf[idx].z = (float)(xz * sin(lng));
			vbuf[idx].y = (float)y;
			idx++;
		}
	}
	grdlng->Unlock();

	gc->GetDevice()->CreateVertexBuffer(sizeof(VERTEX_XYZ)*(NSEG+1)*12, D3DUSAGE_WRITEONLY, D3DFVF_XYZ, D3DPOOL_DEFAULT, &grdlat, NULL);
	grdlat->Lock (0, 0, (LPVOID*)&vbuf, 0);
	for (j = idx = 0; j < 12; j++) {
		lng = j*15*RAD;
		for (i = 0; i <= NSEG; i++) {
			lat = 2.0*PI * (double)i/(double)NSEG;
			xz = sphere_r * cos(lat);
			y  = sphere_r * sin(lat);
			vbuf[idx].x = (float)(xz * cos(lng));
			vbuf[idx].z = (float)(xz * sin(lng));
			vbuf[idx].y = (float)y;
			idx++;
		}
	}
	grdlat->Unlock();
}

// ==============================================================

void CelestialSphere::RenderStars (LPDIRECT3DDEVICE9 dev, DWORD nmax, const VECTOR3 *bgcol)
{
	// render in chunks, because some graphics cards have a limit in the
	// vertex list size

	DWORD i, j;
	if (nmax > nstar) nmax = nstar; // sanity check

	if (bgcol) { // suppress stars darker than the background
		int bglvl = min (255, (int)((min(bgcol->x,1.0) + min(bgcol->y,1.0) + min(bgcol->z,1.0))*128.0));
		nmax = min (nmax, (DWORD)lvlid[bglvl]);
	}

	for (i = j = 0; i < nmax; i += D3DMAXNUMVERTICES, j++)
	{
		dev->SetStreamSource(0, svtx[j], 0, sizeof(VERTEX_XYZC));
		dev->SetFVF(D3DFVF_XYZ | D3DFVF_DIFFUSE);
		dev->DrawPrimitive(D3DPT_POINTLIST, 0, min (nmax-i, D3DMAXNUMVERTICES));
	}
}

// ==============================================================

void CelestialSphere::RenderConstellations (LPDIRECT3DDEVICE9 dev, VECTOR3 &col)
{
	dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_RGBA((int)(255*col.x),(int)(255*col.y),(int)(255*col.z),255));

	dev->SetFVF(D3DFVF_XYZ);
	dev->DrawPrimitiveUP(D3DPT_LINELIST, ncline, cnstvtx, sizeof(VERTEX_XYZ));
}

// ==============================================================

void CelestialSphere::RenderGreatCircle (LPDIRECT3DDEVICE9 dev, VECTOR3 &col)
{
	dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_RGBA((int)(255*col.x),(int)(255*col.y),(int)(255*col.z),255));
	dev->SetStreamSource(0, grdlng, 0, sizeof(VERTEX_XYZ));
	dev->SetFVF(D3DFVF_XYZ);
	dev->DrawPrimitive(D3DPT_LINESTRIP, 5*(NSEG+1), NSEG+1);
}

// ==============================================================

void CelestialSphere::RenderGrid (LPDIRECT3DDEVICE9 dev, VECTOR3 &col, bool eqline)
{
	int i;
	dev->SetFVF(D3DFVF_XYZ);
	dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_RGBA((int)(255*col.x),(int)(255*col.y),(int)(255*col.z),255));
	dev->SetStreamSource(0, grdlng, 0, sizeof(VERTEX_XYZ));
	for (i = 0; i <= 10; i++) if (eqline || i != 5)
		dev->DrawPrimitive(D3DPT_LINESTRIP, i*(NSEG+1), NSEG);
	dev->SetStreamSource(0, grdlat, 0, sizeof(VERTEX_XYZ));
	for (i = 0; i < 12; i++)
		dev->DrawPrimitive(D3DPT_LINESTRIP, i * (NSEG+1), NSEG);
}
