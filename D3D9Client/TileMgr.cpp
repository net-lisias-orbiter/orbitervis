// ==============================================================
// TileMgr.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006-2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class TileManager (implementation)
//
// Planetary surface rendering management, including a simple
// LOD (level-of-detail) algorithm for surface patch resolution.
// ==============================================================

#include "TileMgr.h"
#include "VPlanet.h"
#include "Texture.h"

using namespace oapi;

// Max supported patch resolution level
const int MAXPATCHLVL = 10;

static float TEX2_MULTIPLIER = 4.0f; // microtexture multiplier
static LPDIRECT3DVERTEXBUFFER9 bbtarget;  // target buffer for bounding box transformation

D3DMATERIAL9 pmat;
D3DMATERIAL9 watermat = {{1,1,1,1},{1,1,1,1},{1,1,1,1},{0,0,0,0},20.0f};

// =======================================================================
// Local prototypes

void ApplyPatchTextureCoordinates (VBMESH &mesh, LPDIRECT3DVERTEXBUFFER9 vtx, const TEXCRDRANGE &range);

// =======================================================================

TileManager::TileManager (const D3D9Client *gclient, const vPlanet *vplanet)
{
	gc = gclient;
	vp = vplanet;
	obj = vp->Object();
	ntex = 0;
	nhitex = 0;
	nmask = 0;
	nhispec = 0;
	maxlvl = maxbaselvl = 0;
	microtex = 0;
	microlvl = 0.0;
}

// =======================================================================

TileManager::~TileManager ()
{
	DWORD i, maxidx = patchidx[maxbaselvl];

	if (ntex) {
		for (i = 0; i < ntex; i++)
			texbuf[i]->Release();
		delete []texbuf;
	}
	if (nhitex) {
		for (i = 0; i < nhitex; i++)
			hitexbuf[i]->Release();
		delete []hitexbuf;
	}
	if (nmask) {
		for (i = 0; i < nmask; i++)
			specbuf[i]->Release();
		delete []specbuf;
	}
	if (nhispec) {
		for (i = 0; i < nhispec; i++)
			hispecbuf[i]->Release();
		delete []hispecbuf;
	}
	for (i = 0; i < maxidx; i++)
		if (tiledesc[i].vtx) tiledesc[i].vtx->Release();
	delete []tiledesc;
}

// =======================================================================

bool TileManager::LoadPatchData ()
{
	// Read information about specular reflective patch masks
	// from a binary data file

	FILE *binf;
	BYTE minres, maxres, flag;
	int i, idx, npatch;
	nmask = 0;
	char fname[256], cpath[256];
	oapiGetObjectName (obj, fname, 256);
	strcat (fname, "_lmask.bin");

	if (!(bGlobalSpecular || bGlobalLights) || !gc->TexturePath (fname, cpath) || !(binf = fopen (cpath, "rb"))) {

		for (i = 0; i < patchidx[maxbaselvl]; i++)
			tiledesc[i].flag = 1;
		return false; // no specular reflections, no city lights

	} else {

		WORD *tflag = 0;
		LMASKFILEHEADER lmfh;
		fread (&lmfh, sizeof (lmfh), 1, binf);
		if (!strncmp (lmfh.id, "PLTA0100", 8)) { // v.1.00 format
			minres = lmfh.minres;
			maxres = lmfh.maxres;
			npatch = lmfh.npatch;
			tflag = new WORD[npatch];
			fread (tflag, sizeof(WORD), npatch, binf);
		} else {                                 // pre-v.1.00 format
			fseek (binf, 0, SEEK_SET);
			fread (&minres, 1, 1, binf);
			fread (&maxres, 1, 1, binf);
			npatch = patchidx[maxres] - patchidx[minres-1];
			tflag = new WORD[npatch];
			for (i = 0; i < npatch; i++) {
				fread (&flag, 1, 1, binf);
				tflag[i] = flag;
			}
			//LOGOUT1P("*** WARNING: Old-style texture contents file %s_lmask.bin", cbody->Name());
		}
		fclose (binf);

		for (i = idx = 0; i < patchidx[maxbaselvl]; i++) {
			if (i < patchidx[minres-1]) {
				tiledesc[i].flag = 1; // no mask information -> assume opaque, no lights
			} else {
				flag = (BYTE)tflag[idx++];
				tiledesc[i].flag = flag;
				if (((flag & 3) == 3) || (flag & 4))
					nmask++;
			}
		}
		if (tflag) delete []tflag;
		return true;
	}
}

// =======================================================================

bool TileManager::LoadTileData ()
{
	FILE *file;

	if (maxlvl <= 8) // no tile data required
		return false;

	char fname[256], cpath[256];
	oapiGetObjectName (obj, fname, 256);
	strcat (fname, "_tile.bin");
	
	if (!gc->TexturePath (fname, cpath) || !(file = fopen (cpath, "rb")))
		return false;

	DWORD n, i, j;
	fread (&n, sizeof(DWORD), 1, file);
	TILEFILESPEC *tfs = new TILEFILESPEC[n];
	fread (tfs, sizeof(TILEFILESPEC), n, file);

	TILEDESC *tile8 = tiledesc + patchidx[7];
	for (i = 0; i < 364; i++) { // loop over level 8 tiles
		TILEDESC &tile8i = tile8[i];
		for (j = 0; j < 4; j++)
			if (tfs[i].subidx[j])
				AddSubtileData (tile8i, tfs, i, j, 9);
	}

	fclose (file);
	delete []tfs;
	return true;
}

// =======================================================================

bool TileManager::AddSubtileData (TILEDESC &td, TILEFILESPEC *tfs, DWORD idx, DWORD sub, DWORD lvl)
{
	DWORD j, subidx = tfs[idx].subidx[sub];
	TILEFILESPEC &t = tfs[subidx];
	bool bSubtiles = false;
	for (j = 0; j < 4; j++)
		if (t.subidx[j]) { bSubtiles = true; break; }
	if (t.flags || bSubtiles) {
		if ((int)lvl <= maxlvl) {
			td.subtile[sub] = tilebuf->AddTile();
			td.subtile[sub]->flag = t.flags;
			td.subtile[sub]->tex = (LPDIRECT3DTEXTURE9)t.sidx;
			if (bGlobalSpecular || bGlobalLights) {
				if (t.midx != (DWORD)-1) {
					td.subtile[sub]->ltex = (LPDIRECT3DTEXTURE9)t.midx;
				}
			} else {
				td.subtile[sub]->flag = 1; // remove specular flag
			}
			// recursively step down to higher resolutions
			if (bSubtiles) {
				for (j = 0; j < 4; j++) {
					if (t.subidx[j]) AddSubtileData (*td.subtile[sub], tfs, subidx, j, lvl+1);
				}
			}
			nhitex++;
			if (t.midx != (DWORD)-1) nhispec++;
		} else td.subtile[sub] = NULL;
	}
	return true;
}

// =======================================================================

void TileManager::LoadTextures (char *modstr)
{
	int i;

	ntex = patchidx[maxbaselvl];
	texbuf = new LPDIRECT3DTEXTURE9[ntex];
	char fname[256];
	oapiGetObjectName (obj, fname, 256);
	if (modstr) strcat (fname, modstr);
	strcat (fname, ".tex");
	if (ntex = gc->GetTexMgr()->LoadTextures (fname, texbuf, ntex)) {
		while ((int)ntex < patchidx[maxbaselvl]) maxlvl = --maxbaselvl;
		while ((int)ntex > patchidx[maxbaselvl]) texbuf[--ntex]->Release();
		// not enough textures loaded for requested resolution level
		for (i = 0; i < patchidx[maxbaselvl]; i++)
			tiledesc[i].tex = texbuf[i];
	} else {
		delete []texbuf;
		texbuf = 0;
		// no textures at all!
	}

	// load textures for level > 8 tiles
	if (nhitex) {
		hitexbuf = new LPDIRECT3DTEXTURE9[nhitex];
		oapiGetObjectName (obj, fname, 256);
		strcat (fname, "_tile.tex");
		if (nhitex = gc->GetTexMgr()->LoadTextures (fname, hitexbuf, nhitex)) {
			TILEDESC *tile8 = tiledesc + patchidx[7];
			for (i = 0; i < 364; i++) // loop over level 8 patches
				AddSubtileTextures (tile8+i);
		} else { // hitex file not found
			delete []hitexbuf;
			hitexbuf = 0;
		}
	}
}

// =======================================================================

void TileManager::AddSubtileTextures (TILEDESC *td)
{
	for (int j = 0; j < 4; j++) {
		TILEDESC *sub = td->subtile[j];
		if (sub) {
			DWORD idx = (DWORD)sub->tex;
			if (idx < nhitex) sub->tex = hitexbuf[idx];
			else              sub->tex = NULL;
			// recursively load higher resolutions
			AddSubtileTextures (sub);
		}
	}
}

// =======================================================================

void TileManager::LoadSpecularMasks ()
{
	int i;
	DWORD n;
	char fname[256];

	if (nmask) {
		oapiGetObjectName (obj, fname, 256);
		strcat (fname, "_lmask.tex");
		specbuf = new LPDIRECT3DTEXTURE9[nmask];
		if (n = gc->GetTexMgr()->LoadTextures (fname, specbuf, nmask)) {
			if (n < nmask) {
				//LOGOUT1P("Transparency texture mask file too short: %s_lmask.tex", cbody->Name());
				//LOGOUT("Disabling specular reflection for this planet");
				delete []specbuf;
				specbuf = NULL;
				nmask = 0;
				for (i = 0; i < patchidx[maxbaselvl]; i++)
					tiledesc[i].flag = 1;
			} else {
				for (i = n = 0; i < patchidx[maxbaselvl]; i++) {
					if (((tiledesc[i].flag & 3) == 3) || (tiledesc[i].flag & 4)) {
						if (n < nmask) tiledesc[i].ltex = specbuf[n++];
						else tiledesc[i].flag = 1;
					}
					if (!bGlobalLights) tiledesc[i].flag &= 0xFB;
					if (!bGlobalSpecular) tiledesc[i].flag &= 0xFD, tiledesc[i].flag |= 1;
				}
			}
		} else {
			//LOGOUT1P("Transparency texture mask file not found: %s_lmask.tex", cbody->Name());
			//LOGOUT("Disabling specular reflection for this planet");
			nmask = 0;
			for (i = 0; i < patchidx[maxbaselvl]; i++)
				tiledesc[i].flag = 1;
		}
	}

	// load masks for level > 8 tiles
	if (nhispec) {
		oapiGetObjectName (obj, fname, 256);
		strcat (fname, "_tile_lmask.tex");
		hispecbuf = new LPDIRECT3DTEXTURE9[nhispec];
		if (nhispec = gc->GetTexMgr()->LoadTextures (fname, hispecbuf, nhispec)) {
			TILEDESC *tile8 = tiledesc + patchidx[7];
			for (i = 0; i < 364; i++) // loop over level 8 patches
				AddSubtileMasks (tile8+i);
		} else {
			delete []hispecbuf;
			hispecbuf = 0;
		}
	}
}

// =======================================================================

void TileManager::AddSubtileMasks (TILEDESC *td)
{
	for (int j = 0; j < 4; j++) {
		TILEDESC *sub = td->subtile[j];
		if (sub) {
			if (((sub->flag & 3) == 3) || (sub->flag == 4)) {
				DWORD idx = (DWORD)sub->ltex;
				if (idx < nhispec) sub->ltex = hispecbuf[idx];
				else               sub->ltex = NULL;
			}
			if (!bGlobalLights) sub->flag &= 0xFB;
			if (!bGlobalSpecular) sub->flag &= 0xFD, sub->flag |= 1;
			// recursively load higher resolutions
			AddSubtileMasks (sub);
		}
	}
}

// ==============================================================

void TileManager::Render (LPDIRECT3DDEVICE9 dev, D3DMATRIX &wmat, int level, double viewap)
{
	MATRIX3 grot;
	VECTOR3 gpos;
	D3DMATRIX imat;

	level = min (level, maxlvl);

	RenderParam.dev = dev;
	D3DMAT_Copy (&RenderParam.wmat, &wmat);
	D3DMAT_MatrixInvert (&imat, &wmat);
	RenderParam.cdir = _V(imat._41, imat._42, imat._43); // camera position in local coordinates (units of planet radii)
	normalise (RenderParam.cdir);                        // camera direction

	oapiGetRotationMatrix (obj, &grot);
	oapiGetGlobalPos (obj, &gpos);

	RenderParam.cdist = vp->CamDist() / vp->rad; // camera distance in units of planet radius
	RenderParam.viewap = (viewap ? viewap : acos (1.0/max (1.0, RenderParam.cdist)));
	RenderParam.sdir = tmul (grot, -gpos);
	normalise (RenderParam.sdir); // sun direction in planet frame

	// limit resolution for fast camera movements
	double limitstep, cstep = acos (dotp (RenderParam.cdir, pcdir));
	int maxlevel = 10;
	for (limitstep = 0.005; cstep > limitstep && maxlevel > 5; limitstep *= 2.0)
		maxlevel--;
	level = min (level, maxlevel);

	RenderParam.tgtlvl = level;

	int startlvl = min (level, 8);
	int hemisp, ilat, ilng, idx;
	int  nlat = NLAT[startlvl];
	int *nlng = NLNG[startlvl];
	int texofs = patchidx[startlvl-1];
	TILEDESC *td = tiledesc + texofs;

	TEXCRDRANGE range = {0,1,0,1};

	if (level <= 4) {

		RenderSimple (level, td);

	} else {

		for (hemisp = idx = 0; hemisp < 2; hemisp++) {
			if (hemisp) // flip world transformation to southern hemisphere
				D3DMAT_MatrixMultiply (&RenderParam.wmat, &RenderParam.wmat, &Rsouth);
			for (ilat = nlat-1; ilat >= 0; ilat--) {
				for (ilng = 0; ilng < nlng[ilat]; ilng++) {
					ProcessTile (startlvl, hemisp, ilat, nlat, ilng, nlng[ilat], td+idx, range, td[idx].tex, td[idx].ltex, td[idx].flag);
					idx++;
				}
			}
		}
	}

	pcdir = RenderParam.cdir; // store camera direction
}

// =======================================================================

void TileManager::ProcessTile (int lvl, int hemisp, int ilat, int nlat, int ilng, int nlng,
	TILEDESC *tile, const TEXCRDRANGE &range, LPDIRECT3DTEXTURE9 tex, LPDIRECT3DTEXTURE9 ltex, DWORD flag)
{
	// Check if patch is visible from camera position
	static const double rad0 = sqrt(2.0)*PI*0.5;
	VECTOR3 cnt = TileCentre (hemisp, ilat, nlat, ilng, nlng);
	double rad = rad0/(double)nlat;
	double adist = acos (dotp (RenderParam.cdir, cnt)) - rad;
	if (adist >= RenderParam.viewap) {
		tilebuf->DeleteSubTiles (tile); // remove tile descriptions below
		return;
	}

	// Set world transformation matrix for patch
	SetWorldMatrix (ilng, nlng);

	// Check if patch bounding box intersects viewport
	if (!TileInView (lvl, ilat)) {
		tilebuf->DeleteSubTiles (tile); // remove tile descriptions below
		return;
	}

	// Reduce resolution for distant patches
	bool bStepDown = (lvl < RenderParam.tgtlvl);
	if (bStepDown && lvl > 8 && adist > hipatchrad*RenderParam.viewap) {
		bStepDown = (lvl < RenderParam.tgtlvl-1);
	}

	// Recursion to next level: subdivide into 2x2 patch
	if (bStepDown) {
		int i, j, idx = 0;
		float du = (range.tumax-range.tumin) * 0.5f;
		float dv = (range.tvmax-range.tvmin) * 0.5f;
		TEXCRDRANGE subrange;
		static TEXCRDRANGE fullrange = {0,1,0,1};
		for (i = 1; i >= 0; i--) {
			subrange.tvmax = (subrange.tvmin = range.tvmin + (1-i)*dv) + dv;
			for (j = 0; j < 2; j++) {
				subrange.tumax = (subrange.tumin = range.tumin + j*du) + du;
				TILEDESC *subtile = tile->subtile[idx];
				if (!subtile)
					tile->subtile[idx] = subtile = tilebuf->AddTile();
				ProcessTile (lvl+1, hemisp, ilat*2+i, nlat*2, ilng*2+j, nlng*2, subtile,
					subtile->tex ? fullrange:subrange, subtile->tex ? subtile->tex:tex, subtile->tex ? subtile->ltex:ltex, subtile->tex ? subtile->flag:flag);
				idx++;
			}
		}
	} else {
		// actually render the tile at this level
		double sdist = acos (dotp (RenderParam.sdir, cnt));
		if (sdist > PI*0.5+rad && flag & 2) flag &= 0xFD, flag |= 1; // supress specular reflection on dark side
		RenderTile (lvl, hemisp, ilat, nlat, ilng, nlng, sdist, tile, range, tex, ltex, flag);
		tilebuf->DeleteSubTiles (tile); // remove tile descriptions below
	}
}

// ==============================================================

void TileManager::RenderSimple (int level, TILEDESC *tile)
{
	// render complete sphere (used at low LOD levels)

	extern D3DMATERIAL9 def_mat;
	int idx, npatch = patchidx[level] - patchidx[level-1];
	RenderParam.dev->SetTransform (D3DTS_WORLD, &RenderParam.wmat);

	for (idx = 0; idx < npatch; idx++) {

		VBMESH &mesh = PATCH_TPL[level][idx]; // patch template
		bool purespec = ((tile[idx].flag & 3) == 2);
		bool mixedspec = ((tile[idx].flag & 3) == 3);

		// step 1: render full patch, either completely diffuse or completely specular
		if (purespec) { // completely specular
			RenderParam.dev->GetMaterial (&pmat);
			RenderParam.dev->SetMaterial (&watermat);
			RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, TRUE);
		}
		//RenderParam.dev->SetMaterial (&def_mat);
		RenderParam.dev->SetTexture (0, tile[idx].tex);
		
		RenderParam.dev->SetIndices(mesh.idx);
		RenderParam.dev->SetStreamSource(0, mesh.vb, 0, sizeof(VERTEX_2TEX));
		RenderParam.dev->SetFVF(FVF_2TEX);
		RenderParam.dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, mesh.nv, 0, mesh.ni/3);


		if (purespec) {
			RenderParam.dev->SetMaterial (&pmat);
			RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, FALSE);
		}

		// step 2: add specular highlights (mixed patches only)
		if (mixedspec) {
			RenderParam.dev->GetMaterial (&pmat);
			RenderParam.dev->SetMaterial (&watermat);
			RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, TRUE);
			RenderParam.dev->SetRenderState (D3DRS_ALPHABLENDENABLE, TRUE);
			RenderParam.dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_INVSRCALPHA);
			RenderParam.dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_ONE);
			RenderParam.dev->SetTexture (0, tile[idx].ltex);

			RenderParam.dev->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, mesh.nv, 0, mesh.ni/3);

			RenderParam.dev->SetMaterial (&pmat);
			RenderParam.dev->SetRenderState (D3DRS_SPECULARENABLE, FALSE);
			RenderParam.dev->SetRenderState (D3DRS_ALPHABLENDENABLE, FALSE);
			RenderParam.dev->SetRenderState (D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
			RenderParam.dev->SetRenderState (D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
		}
	}
}

// =======================================================================
// returns the direction of the tile centre from the planet centre in local
// planet coordinates

VECTOR3 TileManager::TileCentre (int hemisp, int ilat, int nlat, int ilng, int nlng)
{
	double cntlat = PI*0.5 * ((double)ilat+0.5)/(double)nlat,      slat = sin(cntlat), clat = cos(cntlat);
	double cntlng = PI*2.0 * ((double)ilng+0.5)/(double)nlng + PI, slng = sin(cntlng), clng = cos(cntlng);
	if (hemisp) return _V(clat*clng, -slat, -clat*slng);
	else        return _V(clat*clng,  slat,  clat*slng);
}

// =======================================================================
bool TileManager::TileInView (int lvl, int ilat)
{
	const double eps = 1e-3;
	bool bx1, bx2, by1, by2, bz1, bz2, bbvis;
	int v;
	float x, y;
	VBMESH &mesh = PATCH_TPL[lvl][ilat];
	D3DXVECTOR3 vtx[8];

	D3DVIEWPORT9 ViewPort;
	D3DXMATRIX Projection, View, World;
	RenderParam.dev->GetViewport(&ViewPort);
	RenderParam.dev->GetTransform(D3DTS_PROJECTION, &Projection);
	RenderParam.dev->GetTransform(D3DTS_VIEW, &View);
	RenderParam.dev->GetTransform(D3DTS_WORLDMATRIX(0), &World);

	D3DXVec3ProjectArray(vtx, sizeof(D3DXVECTOR3), mesh.bb, sizeof(D3DXVECTOR3), &ViewPort, &Projection, &View, &World, 8); 

	bx1 = bx2 = by1 = by2 = bz1 = bz2 = bbvis = false;
	for (v = 0; v < 8; v++) {
		if (vtx[v].z > 0.0)  bz1 = true;
		if (vtx[v].z <= 1.0+eps) bz2 = true;
		if (vtx[v].z <= 1.0) x =  vtx[v].x, y =  vtx[v].y;
		else                 x = -vtx[v].x, y = -vtx[v].y;
		if (x > vpX0)        bx1 = true;
		if (x < vpX1)        bx2 = true;
		if (y > vpY0)        by1 = true;
		if (y < vpY1)        by2 = true;
		if (bbvis = bx1 && bx2 && by1 && by2 && bz1 && bz2) break;
	}
	return bbvis;
}

// =======================================================================

void TileManager::SetWorldMatrix (int ilng, int nlng)
{
	// set up world transformation matrix
	D3DMATRIX rtile, wtrans;
	double lng = PI*2.0 * (double)ilng/(double)nlng + PI; // add pi so texture wraps at +-180°
	D3DMAT_RotY (&rtile, lng);
	D3DMAT_MatrixMultiply (&wtrans, &RenderParam.wmat, &rtile);
	RenderParam.dev->SetTransform (D3DTS_WORLD, &wtrans);
}

// ==============================================================

bool TileManager::SpecularColour (D3DCOLORVALUE *col)
{
	if (!atmc) {
		col->r = col->g = col->b = spec_base;
		return false;
	} else {
		double fac = 0.7; // needs thought ...
		double cosa = dotp (RenderParam.cdir, RenderParam.sdir);
		double alpha = 0.5*acos(cosa); // sun reflection angle
		double scale = sin(alpha)*fac;
		col->r = (float)max(0.0, spec_base - scale*atmc->color0.x);
		col->g = (float)max(0.0, spec_base - scale*atmc->color0.y);
		col->b = (float)max(0.0, spec_base - scale*atmc->color0.z);
		return true;
	}
}

// ==============================================================

void TileManager::GlobalInit (D3D9Client *gclient)
{
	LPDIRECT3D9 d3d = gclient->GetDirect3D9();
	LPDIRECT3DDEVICE9 dev = gclient->GetDevice();

	bGlobalSpecular = *(bool*)gclient->GetConfigParam (CFGPRM_SURFACEREFLECT);
	bGlobalRipple   = bGlobalSpecular && *(bool*)gclient->GetConfigParam (CFGPRM_SURFACERIPPLE);
	bGlobalLights   = *(bool*)gclient->GetConfigParam (CFGPRM_SURFACELIGHTS);

	// Level 1 patch template
	CreateSphere (d3d, dev, PATCH_TPL_1, 6, false, 0, 64);

	// Level 2 patch template
	CreateSphere (d3d, dev, PATCH_TPL_2, 8, false, 0, 128);

	// Level 3 patch template
	CreateSphere (d3d, dev, PATCH_TPL_3, 12, false, 0, 256);

	// Level 4 patch templates
	CreateSphere (d3d, dev, PATCH_TPL_4[0], 16, true, 0, 256);
	CreateSphere (d3d, dev, PATCH_TPL_4[1], 16, true, 1, 256);

	// Level 5 patch template
	CreateSpherePatch (d3d, dev, PATCH_TPL_5, 4, 1, 0, 18);

	// Level 6 patch templates
	CreateSpherePatch (d3d, dev, PATCH_TPL_6[0], 8, 2, 0, 10, 16);
	CreateSpherePatch (d3d, dev, PATCH_TPL_6[1], 4, 2, 1, 12);

	// Level 7 patch templates
	CreateSpherePatch (d3d, dev, PATCH_TPL_7[0], 16, 4, 0, 12, 12, false);
	CreateSpherePatch (d3d, dev, PATCH_TPL_7[1], 16, 4, 1, 12, 12, false);
	CreateSpherePatch (d3d, dev, PATCH_TPL_7[2], 12, 4, 2, 10, 16, true);
	CreateSpherePatch (d3d, dev, PATCH_TPL_7[3],  6, 4, 3, 12, -1, true);

	// Level 8 patch templates
	CreateSpherePatch (d3d, dev, PATCH_TPL_8[0], 32, 8, 0, 12, 15, false, true, true);
	CreateSpherePatch (d3d, dev, PATCH_TPL_8[1], 32, 8, 1, 12, 15, false, true, true);
	CreateSpherePatch (d3d, dev, PATCH_TPL_8[2], 30, 8, 2, 12, 16, false, true, true);
	CreateSpherePatch (d3d, dev, PATCH_TPL_8[3], 28, 8, 3, 12, 12, false, true, true);
	CreateSpherePatch (d3d, dev, PATCH_TPL_8[4], 24, 8, 4, 12, 12, false, true, true);
	CreateSpherePatch (d3d, dev, PATCH_TPL_8[5], 18, 8, 5, 12, 12, false, true, true);
	CreateSpherePatch (d3d, dev, PATCH_TPL_8[6], 12, 8, 6, 10, 16, true,  true, true);
	CreateSpherePatch (d3d, dev, PATCH_TPL_8[7],  6, 8, 7, 12, -1, true,  true, true);

	// Patch templates for level 9 and beyond
	const int n = 8;
	const int nlng8[8] = {32,32,30,28,24,18,12,6};
	const int res8[8] = {15,15,16,12,12,12,12,12};
	int mult = 2, idx, lvl, i, j;
	for (lvl = 9; lvl <= MAXPATCHLVL; lvl++) {
		idx = 0;
		for (i = 0; i < 8; i++) {
			for (j = 0; j < mult; j++) {
				if (idx < n*mult)
					CreateSpherePatch (d3d, dev, PATCH_TPL[lvl][idx], nlng8[i]*mult, n*mult, idx, 12, res8[i], false, true, true);
				else
					CreateSpherePatch (d3d, dev, PATCH_TPL[lvl][idx], nlng8[i]*mult, n*mult, idx, 12, -1, true, true, true);
				idx++;
			}
		}
		mult *= 2;
	}

	// create the system-wide tile cache
	tilebuf = new TileBuffer;

	// create the vertex buffer for tile bounding box checks
	dev->CreateVertexBuffer(8*sizeof(VERTEX_XYZ), 0, D3DFVF_XYZ, D3DPOOL_SYSTEMMEM, &bbtarget, NULL);

	// viewport size for clipping calculations
	D3DVIEWPORT9 vp;
	dev->GetViewport (&vp);
	vpX0 = vp.X, vpX1 = vpX0 + vp.Width;
	vpY0 = vp.Y, vpY1 = vpY0 + vp.Height;

	// rotation matrix for flipping patches onto southern hemisphere
	D3DMAT_RotX (&Rsouth, PI);
}

// ==============================================================

void TileManager::GlobalExit ()
{
	int i;
	DestroyVBMesh (PATCH_TPL_1);
	DestroyVBMesh (PATCH_TPL_2);
	DestroyVBMesh (PATCH_TPL_3);
	for (i = 0; i <  2; i++) DestroyVBMesh (PATCH_TPL_4[i]);
	DestroyVBMesh (PATCH_TPL_5);
	for (i = 0; i <  2; i++) DestroyVBMesh (PATCH_TPL_6[i]);
	for (i = 0; i <  4; i++) DestroyVBMesh (PATCH_TPL_7[i]);
	for (i = 0; i <  8; i++) DestroyVBMesh (PATCH_TPL_8[i]);

	const int n = 8;
	int mult = 2, lvl;
	for (lvl = 9; lvl <= MAXPATCHLVL; lvl++) {
		for (i = 0; i < n*mult; i++) DestroyVBMesh (PATCH_TPL[lvl][i]);
		mult *= 2;
	}
	delete tilebuf;

	bbtarget->Release();
	bbtarget = 0;
}

// ==============================================================

void TileManager::SetMicrotexture (const char *fname)
{
	if (fname) gc->GetTexMgr()->GetTexture (fname, &microtex);
	else microtex = 0;
}

// ==============================================================

void TileManager::SetMicrolevel (double lvl)
{
	microlvl = lvl;
}

// ==============================================================
// CreateSphere()
// Create a spherical mesh of radius 1 and resolution defined by nrings
// Below is a list of #vertices and #indices against nrings:
//
// nrings  nvtx   nidx   (nidx = 12 nrings^2)
//   4       38    192
//   6       80    432
//   8      138    768
//  12      302   1728
//  16      530   3072
//  20      822   4800
//  24     1178   6912

void TileManager::CreateSphere (LPDIRECT3D9 d3d, LPDIRECT3DDEVICE9 dev, VBMESH &mesh, DWORD nrings, bool hemisphere, int which_half, int texres)
{
	// Allocate memory for the vertices and indices
	DWORD       nVtx = hemisphere ? nrings*(nrings+1)+2 : nrings*(2*nrings+1)+2;
	DWORD       nIdx = hemisphere ? 6*nrings*nrings : 12*nrings*nrings;
	VERTEX_2TEX* Vtx = new VERTEX_2TEX[nVtx];


	HRESULT hr=dev->CreateIndexBuffer(nIdx*sizeof(WORD), D3DUSAGE_WRITEONLY, D3DFMT_INDEX16, D3DPOOL_DEFAULT, &mesh.idx, NULL);
	WORD *Idx;
	mesh.idx->Lock(0, 0, (LPVOID*)&Idx, 0);


	// Counters
    WORD x, y, nvtx = 0, nidx = 0;
	VERTEX_2TEX *vtx = Vtx;
	WORD *idx = Idx;

	// Angle deltas for constructing the sphere's vertices
    FLOAT fDAng   = (FLOAT)PI / nrings;
    FLOAT fDAngY0 = fDAng;
	DWORD x1 = (hemisphere ? nrings : nrings*2);
	DWORD x2 = x1+1;
	FLOAT du = 0.5f/(FLOAT)texres;
	FLOAT a  = (1.0f-2.0f*du)/(FLOAT)x1;

    // Make the middle of the sphere
    for (y = 0; y < nrings; y++) {
        FLOAT y0 = (FLOAT)cos(fDAngY0);
        FLOAT r0 = (FLOAT)sin(fDAngY0);
		FLOAT tv = fDAngY0/(FLOAT)PI;

        for (x = 0; x < x2; x++) {
            FLOAT fDAngX0 = x*fDAng - (FLOAT)PI;  // subtract Pi to wrap at +-180°
			if (hemisphere && which_half) fDAngX0 += (FLOAT)PI;

			D3DVECTOR v = {r0*(FLOAT)cos(fDAngX0), y0, r0*(FLOAT)sin(fDAngX0)};
			FLOAT tu = a*(FLOAT)x + du;
			//FLOAT tu = x/(FLOAT)x1;

            *vtx++ = VERTEX_2TEX (v, v, tu, tv, tu, tv);
			nvtx++;
        }
        fDAngY0 += fDAng;
    }

    for (y = 0; y < nrings-1; y++) {
        for (x = 0; x < x1; x++) {
            *idx++ = (WORD)( (y+0)*x2 + (x+0) );
            *idx++ = (WORD)( (y+0)*x2 + (x+1) );
            *idx++ = (WORD)( (y+1)*x2 + (x+0) );
            *idx++ = (WORD)( (y+0)*x2 + (x+1) );
            *idx++ = (WORD)( (y+1)*x2 + (x+1) );
            *idx++ = (WORD)( (y+1)*x2 + (x+0) ); 
			nidx += 6;
        }
    }
    // Make top and bottom
	D3DVECTOR pvy = {0, 1, 0}, nvy = {0,-1,0};
	WORD wNorthVtx = nvtx;
    *vtx++ = VERTEX_2TEX (pvy, pvy, 0.5f, 0.0f, 0.5f, 0.0f);
    nvtx++;
	WORD wSouthVtx = nvtx;
    *vtx++ = VERTEX_2TEX (nvy, nvy, 0.5f, 1.0f, 0.5f, 1.0f);
    nvtx++;

    for (x = 0; x < x1; x++) {
		WORD p1 = wSouthVtx;
		WORD p2 = (WORD)( (y)*x2 + (x+0) );
		WORD p3 = (WORD)( (y)*x2 + (x+1) );

        *idx++ = p1;
        *idx++ = p3;
        *idx++ = p2;
		nidx += 3;
    }

    for (x = 0; x < x1; x++) {
		WORD p1 = wNorthVtx;
		WORD p2 = (WORD)( (0)*x2 + (x+0) );
		WORD p3 = (WORD)( (0)*x2 + (x+1) );

        *idx++ = p1;
        *idx++ = p3;
        *idx++ = p2;
		nidx += 3;
    }

	LPVOID data;
	
	dev->CreateVertexBuffer(nVtx * sizeof(VERTEX_2TEX), D3DUSAGE_WRITEONLY, FVF_2TEX, D3DPOOL_DEFAULT, &mesh.vb, NULL);	
	

	mesh.vb->Lock (0, 0, (LPVOID*)&data, 0);
	memcpy (data, Vtx, nVtx*sizeof(VERTEX_2TEX));
	mesh.vb->Unlock();
	delete []Vtx;
	mesh.nv  = nVtx;
	mesh.idx->Unlock();
	mesh.ni  = nIdx;
	mesh.bb = 0;
	mesh.vtx = 0;
}

// ==============================================================

void TileManager::CreateSpherePatch (LPDIRECT3D9 d3d, LPDIRECT3DDEVICE9 dev, VBMESH &mesh, int nlng, int nlat, int ilat, int res, int bseg, bool reduce, bool outside, bool store_vtx)
{
	const float c1 = 1.0f, c2 = 0.0f;
	int i, j, nVtx, nIdx, nseg, n, nofs0, nofs1;
	double minlat, maxlat, lat, minlng, maxlng, lng;
	double slat, clat, slng, clng;
	WORD tmp;
	VECTOR3 pos, tpos;

	minlat = PI*0.5 * (double)ilat/(double)nlat;
	maxlat = PI*0.5 * (double)(ilat+1)/(double)nlat;
	minlng = 0;
	maxlng = PI*2.0/(double)nlng;
	if (bseg < 0 || ilat == nlat-1) bseg = (nlat-ilat)*res;

	// generate nodes
	nVtx = (bseg+1)*(res+1);
	if (reduce) nVtx -= ((res+1)*res)/2;
	VERTEX_2TEX *Vtx = new VERTEX_2TEX[nVtx];

	// create transformation for bounding box
	// we define the local coordinates for the patch so that the x-axis points
	// from (minlng,minlat) corner to (maxlng,minlat) corner (origin is halfway between)
	// y-axis points from local origin to middle between (minlng,maxlat) and (maxlng,maxlat)
	// bounding box is created in this system and then transformed back to planet coords.
	double clat0 = cos(minlat), slat0 = sin(minlat);
	double clng0 = cos(minlng), slng0 = sin(minlng);
	double clat1 = cos(maxlat), slat1 = sin(maxlat);
	double clng1 = cos(maxlng), slng1 = sin(maxlng);
	VECTOR3 ex = {clat0*clng1 - clat0*clng0, 0, clat0*slng1 - clat0*slng0}; normalise(ex);
	VECTOR3 ey = {0.5*(clng0+clng1)*(clat1-clat0), slat1-slat0, 0.5*(slng0+slng1)*(clat1-clat0)}; normalise(ey);
	VECTOR3 ez = crossp (ey, ex);
	MATRIX3 R = {ex.x, ex.y, ex.z,  ey.x, ey.y, ey.z,  ez.x, ez.y, ez.z};
	VECTOR3 pref = {0.5*(clat0*clng1 + clat0*clng0), slat0, 0.5*(clat0*slng1 + clat0*slng0)}; // origin
	VECTOR3 tpmin, tpmax; 

	for (i = n = 0; i <= res; i++) {  // loop over longitudinal strips
		lat = minlat + (maxlat-minlat) * (double)i/(double)res;
		slat = sin(lat), clat = cos(lat);
		nseg = (reduce ? bseg-i : bseg);
		for (j = 0; j <= nseg; j++) {
			lng = (nseg ? minlng + (maxlng-minlng) * (double)j/(double)nseg : 0.0);
			slng = sin(lng), clng = cos(lng);
			pos = _V(clat*clng, slat, clat*slng);
			tpos = mul (R, pos-pref);
			if (!n) {
				tpmin = tpos;
				tpmax = tpos;
			} else {
				if      (tpos.x < tpmin.x) tpmin.x = tpos.x;
			    else if (tpos.x > tpmax.x) tpmax.x = tpos.x;
				if      (tpos.y < tpmin.y) tpmin.y = tpos.y;
				else if (tpos.y > tpmax.y) tpmax.y = tpos.y;
				if      (tpos.z < tpmin.z) tpmin.z = tpos.z;
				else if (tpos.z > tpmax.z) tpmax.z = tpos.z;
			}

			Vtx[n].x = Vtx[n].nx = (float)(pos.x);
			Vtx[n].y = Vtx[n].ny = (float)(pos.y);
			Vtx[n].z = Vtx[n].nz = (float)(pos.z);
			Vtx[n].tu0 = (float)(nseg ? (c1*j)/nseg+c2 : 0.5f); // overlap to avoid seams
			Vtx[n].tv0 = (float)((c1*(res-i))/res+c2);
			Vtx[n].tu1 = (nseg ? Vtx[n].tu0 * TEX2_MULTIPLIER : 0.5f);
			Vtx[n].tv1 = Vtx[n].tv0 * TEX2_MULTIPLIER;
			if (!outside) {
				Vtx[n].nx = -Vtx[n].nx;
				Vtx[n].ny = -Vtx[n].ny;
				Vtx[n].nz = -Vtx[n].nz;
			}
			n++;
		}
	}

	// generate faces
	nIdx = (reduce ? res * (2*bseg-res) : 2*res*bseg) * 3;
	// {DEB} dev->CreateIndexBuffer(nIdx*sizeof(WORD), 0, D3DFMT_INDEX16, D3DPOOL_DEFAULT, &mesh.idx, NULL);
    dev->CreateIndexBuffer(nIdx*sizeof(WORD), D3DUSAGE_WRITEONLY, D3DFMT_INDEX16, D3DPOOL_DEFAULT, &mesh.idx, NULL);  // must be write-only to avoid performance penalty here!

	WORD *Idx;
	mesh.idx->Lock(0, 0, (LPVOID*)&Idx, 0);

	for (i = n = nofs0 = 0; i < res; i++) {
		nseg = (reduce ? bseg-i : bseg);
		nofs1 = nofs0+nseg+1;
		for (j = 0; j < nseg; j++) {
			Idx[n++] = nofs0+j;
			Idx[n++] = nofs1+j;
			Idx[n++] = nofs0+j+1;
			if (reduce && j == nseg-1) break;
			Idx[n++] = nofs0+j+1;
			Idx[n++] = nofs1+j;
			Idx[n++] = nofs1+j+1;
		}
		nofs0 = nofs1;
	}
	if (!outside)
		for (i = 0; i < nIdx/3; i += 3)
			tmp = Idx[i+1], Idx[i+1] = Idx[i+2], Idx[i+2] = tmp;
	mesh.idx->Unlock();

	dev->CreateVertexBuffer(nVtx * sizeof(VERTEX_2TEX), D3DUSAGE_WRITEONLY, FVF_2TEX, D3DPOOL_DEFAULT, &mesh.vb, NULL);

	LPVOID data;
	mesh.vb->Lock (0, 0, (LPVOID*)&data, 0);
	memcpy (data, Vtx, nVtx*sizeof(VERTEX_2TEX));
	mesh.vb->Unlock();

	if (store_vtx) {
		mesh.vtx = Vtx;
	} else {
		delete []Vtx;
		mesh.vtx = 0;
	}
	mesh.nv  = nVtx;
	mesh.ni  = nIdx;

	// set bounding box

//	dev->CreateVertexBuffer(8*sizeof(VERTEX_XYZ), 0, D3DFVF_XYZ, D3DPOOL_SYSTEMMEM, &mesh.bb, NULL);
	D3DXVECTOR3 *V = mesh.bb = new D3DXVECTOR3[8];	

	// transform bounding box back to patch coordinates
	pos = tmul (R, _V(tpmin.x, tpmin.y, tpmin.z)) + pref;
	V[0].x = (float)(pos.x); V[0].y = (float)(pos.y); V[0].z = (float)(pos.z);
	pos = tmul (R, _V(tpmax.x, tpmin.y, tpmin.z)) + pref;
	V[1].x = (float)(pos.x); V[1].y = (float)(pos.y); V[1].z = (float)(pos.z);
	pos = tmul (R, _V(tpmin.x, tpmax.y, tpmin.z)) + pref;
	V[2].x = (float)(pos.x); V[2].y = (float)(pos.y); V[2].z = (float)(pos.z);
	pos = tmul (R, _V(tpmax.x, tpmax.y, tpmin.z)) + pref;
	V[3].x = (float)(pos.x); V[3].y = (float)(pos.y); V[3].z = (float)(pos.z);
	pos = tmul (R, _V(tpmin.x, tpmin.y, tpmax.z)) + pref;
	V[4].x = (float)(pos.x); V[4].y = (float)(pos.y); V[4].z = (float)(pos.z);
	pos = tmul (R, _V(tpmax.x, tpmin.y, tpmax.z)) + pref;
	V[5].x = (float)(pos.x); V[5].y = (float)(pos.y); V[5].z = (float)(pos.z);
	pos = tmul (R, _V(tpmin.x, tpmax.y, tpmax.z)) + pref;
	V[6].x = (float)(pos.x); V[6].y = (float)(pos.y); V[6].z = (float)(pos.z);
	pos = tmul (R, _V(tpmax.x, tpmax.y, tpmax.z)) + pref;
	V[7].x = (float)(pos.x); V[7].y = (float)(pos.y); V[7].z = (float)(pos.z);
}

// ==============================================================

void TileManager::DestroyVBMesh (VBMESH &mesh)
{
	mesh.vb->Release();
	mesh.vb  = 0;
	mesh.nv  = 0;
	if (mesh.bb) {
//		mesh.bb->Release();
		delete mesh.bb;
		mesh.bb  = 0;
	}
	mesh.idx->Release();
	mesh.idx = 0;
	if (mesh.vtx) {
		delete []mesh.vtx;
		mesh.vtx = 0;
	}
	mesh.ni  = 0;
}

// ==============================================================
// static member initialisation

int TileManager::patchidx[9] = {0, 1, 2, 3, 5, 13, 37, 137, 501};

bool TileManager::bGlobalSpecular = false;
bool TileManager::bGlobalRipple = false;
bool TileManager::bGlobalLights = false;

TileBuffer *TileManager::tilebuf = NULL;
D3DMATRIX   TileManager::Rsouth;

VBMESH TileManager::PATCH_TPL_1;
VBMESH TileManager::PATCH_TPL_2;
VBMESH TileManager::PATCH_TPL_3;
VBMESH TileManager::PATCH_TPL_4[2];
VBMESH TileManager::PATCH_TPL_5;
VBMESH TileManager::PATCH_TPL_6[2];
VBMESH TileManager::PATCH_TPL_7[4];
VBMESH TileManager::PATCH_TPL_8[8];
VBMESH TileManager::PATCH_TPL_9[16];
VBMESH TileManager::PATCH_TPL_10[32];
VBMESH *TileManager::PATCH_TPL[11] = {
	0, &PATCH_TPL_1, &PATCH_TPL_2, &PATCH_TPL_3, PATCH_TPL_4, &PATCH_TPL_5,
	PATCH_TPL_6, PATCH_TPL_7, PATCH_TPL_8, PATCH_TPL_9, PATCH_TPL_10
};

int TileManager::NLAT[9] = {0,1,1,1,1,1,2,4,8};
int TileManager::NLNG5[1] = {4};
int TileManager::NLNG6[2] = {8,4};
int TileManager::NLNG7[4] = {16,16,12,6};
int TileManager::NLNG8[8] = {32,32,30,28,24,18,12,6};
int *TileManager::NLNG[9] = {0,0,0,0,0,NLNG5,NLNG6,NLNG7,NLNG8};

DWORD TileManager::vpX0, TileManager::vpX1, TileManager::vpY0, TileManager::vpY1;

// =======================================================================
// Nonmember functions

void ApplyPatchTextureCoordinates (VBMESH &mesh, LPDIRECT3DVERTEXBUFFER9 vtx, const TEXCRDRANGE &range)
{
	VERTEX_2TEX *tgtdata;
	vtx->Lock (0, 0, (LPVOID*)&tgtdata, 0);
	if (mesh.vtx) { // direct access to vertex data
		memcpy (tgtdata, mesh.vtx, mesh.nv*sizeof(VERTEX_2TEX));
	} else {        // need to lock the buffer
		VERTEX_2TEX *srcdata;
		mesh.vb->Lock (0, 0, (LPVOID*)&srcdata, D3DLOCK_READONLY);
		memcpy (tgtdata, srcdata, mesh.nv*sizeof(VERTEX_2TEX));
		mesh.vb->Unlock();
	}
	float tuscale = range.tumax-range.tumin, tuofs = range.tumin;
	float tvscale = range.tvmax-range.tvmin, tvofs = range.tvmin;
	for (DWORD i = 0; i < mesh.nv; i++) {
		tgtdata[i].tu0 = tgtdata[i].tu0*tuscale + tuofs;
		tgtdata[i].tv0 = tgtdata[i].tv0*tvscale + tvofs;
	}
	vtx->Unlock();
}


// =======================================================================
// =======================================================================
// Class TileBuffer: implementation

TileBuffer::TileBuffer()
{
	nbuf = 0;
	nused = 0;
	last = 0;
}

// =======================================================================

TileBuffer::~TileBuffer()
{
	if (nbuf) {
		for (DWORD i = 0; i < nbuf; i++)
			if (buf[i]) {
				if (buf[i]->vtx)
					buf[i]->vtx->Release();
				delete buf[i];
			}
		delete []buf;
	}
}

// =======================================================================

TILEDESC *TileBuffer::AddTile ()
{
	TILEDESC *td = new TILEDESC;
	memset (td, 0, sizeof(TILEDESC));
	DWORD i, j;

	if (nused == nbuf) {
		TILEDESC **tmp = new TILEDESC*[nbuf+16];
		if (nbuf) {
			memcpy (tmp, buf, nbuf*sizeof(TILEDESC*));
			delete []buf;
		}
		memset (tmp+nbuf, 0, 16*sizeof(TILEDESC*));
		buf = tmp;
		nbuf += 16;
		last = nused;
	} else {
		for (i = 0; i < nbuf; i++) {
			j = (i+last)%nbuf;
			if (!buf[j]) {
				last = j;
				break;
			}
		}
        /* TODO: implement this or delete the if block
		if (i == nbuf)
			/* Problems! */;
	}
	buf[last] = td;
	td->ofs = last;
	nused++;
	return td;
}

// =======================================================================

void TileBuffer::DeleteSubTiles (TILEDESC *tile)
{
	for (DWORD i = 0; i < 4; i++)
		if (tile->subtile[i]) {
			if (DeleteTile (tile->subtile[i]))
				tile->subtile[i] = 0;
		}
}

// =======================================================================

bool TileBuffer::DeleteTile (TILEDESC *tile)
{
	bool del = true;
	for (DWORD i = 0; i < 4; i++)
		if (tile->subtile[i]) {
			if (DeleteTile (tile->subtile[i]))
				tile->subtile[i] = 0;
			else
				del = false;
		}
	if (tile->vtx) {
		tile->vtx->Release();
		tile->vtx = 0;
	}
	if (tile->tex || !del) {
		return false; // tile or subtile contains texture -> don't deallocate
	} else {
		buf[tile->ofs] = 0; // remove from list
		delete tile;
		nused--;
		return true;
	}
}

