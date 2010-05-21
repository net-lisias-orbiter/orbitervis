// =======================================================================
// Particle system for exhaust contrails

#define STRICT 1
#include "Particle.h"
#include "Scene.h"
#include "Camera.h"
#include "Texture.h"
#include <stdio.h>

static bool needsetup = true;
static VERTEX_XYZ_TEX evtx[MAXPARTICLE*4]; // vertex list for emissive trail (no normals)
static NTVERTEX       dvtx[MAXPARTICLE*4]; // vertex list for diffusive trail
static WORD           idx[MAXPARTICLE*6];  // index list

static float tu[8*4] = {0.0,0.5,0.5,0.0, 0.5,1.0,1.0,0.5, 0.0,0.5,0.5,0.0, 0.5,1.0,1.0,0.5,
						0.5,0.5,0.0,0.0, 1.0,1.0,0.5,0.5, 0.5,0.5,0.0,0.0, 1.0,1.0,0.5,0.5};
static float tv[8*4] = {0.0,0.0,0.5,0.5, 0.0,0.0,0.5,0.5, 0.5,0.5,1.0,1.0, 0.5,0.5,1.0,1.0,
						0.0,0.5,0.5,0.0, 0.0,0.5,0.5,0.0, 0.5,1.0,1.0,0.5, 0.5,1.0,1.0,0.5};

using namespace oapi;

static PARTICLESTREAMSPEC DefaultParticleStreamSpec = {
	0,                            // flags
	8.0,                          // creation size
	0.5,                          // creation rate
	100,                          // emission velocity
	0.3,                          // velocity randomisation
	8.0,                          // lifetime
	0.5,                          // growth rate
	3.0,                          // atmospheric slowdown
	PARTICLESTREAMSPEC::DIFFUSE,  // render lighting method
	PARTICLESTREAMSPEC::LVL_SQRT, // mapping from level to alpha
	0, 1,						  // lmin and lmax levels for mapping
	PARTICLESTREAMSPEC::ATM_PLOG, // mapping from atmosphere to alpha
	1e-4, 1						  // amin and amax densities for mapping
};

LPDIRECT3DTEXTURE9 D3D9ParticleStream::deftex = 0;
bool D3D9ParticleStream::bShadows = false;

D3D9ParticleStream::D3D9ParticleStream (GraphicsClient *_gc, PARTICLESTREAMSPEC *pss): ParticleStream (_gc, pss)
{
	d3d9c = (D3D9Client*)_gc;
	cam_ref = d3d9c->GetScene()->GetCamera()->GetGPos();
	src_ref = 0;
	src_ofs = _V(0,0,0);
	interval = 0.1;
	SetSpecs (pss ? pss : &DefaultParticleStreamSpec);
	t0 = oapiGetSimTime();
	active = false;
	pfirst = NULL;
	plast = NULL;
	np = 0;
	D3DMAT_Identity (&mWorld);

	if (needsetup) {
		int i, j, k, r, ofs;
		for (i = j = 0; i < MAXPARTICLE; i++) {
			ofs = i*4;
			idx[j++] = ofs;
			idx[j++] = ofs+2;
			idx[j++] = ofs+1;
			idx[j++] = ofs+2;
			idx[j++] = ofs;
			idx[j++] = ofs+3;
			r = rand() & 7;
			for (k = 0; k < 4; k++) {
				evtx[ofs+k].tu = dvtx[ofs+k].tu = tu[r*4+k];
				evtx[ofs+k].tv = dvtx[ofs+k].tv = tv[r*4+k];
			}
		}
		needsetup = false;
	}
}

D3D9ParticleStream::~D3D9ParticleStream()
{
	while (pfirst) {
		ParticleSpec *tmp = pfirst;
		pfirst = pfirst->next;
		delete tmp;
	}
}

void D3D9ParticleStream::GlobalInit (oapi::D3D9Client *gclient)
{
	gclient->GetTexMgr()->LoadTexture ("contrail1.dds", &deftex);
	bShadows = *(bool*)gclient->GetConfigParam (CFGPRM_VESSELSHADOWS);
}

void D3D9ParticleStream::GlobalExit ()
{
	if (deftex) {
		deftex->Release();
		deftex = 0;
	}
}

void D3D9ParticleStream::SetSpecs (PARTICLESTREAMSPEC *pss)
{
	SetParticleHalflife (pss->lifetime);
	size0 = pss->srcsize;
	speed = pss->v0;
	vrand = pss->srcspread;
	alpha = pss->growthrate;
	beta  = pss->atmslowdown;
	pdensity = pss->srcrate;
	diffuse = (pss->ltype == PARTICLESTREAMSPEC::DIFFUSE);
	lmap  = pss->levelmap;
	lmin  = pss->lmin, lmax = pss->lmax;
	amap  = pss->atmsmap;
	amin  = pss->amin;
	switch (amap) {
	case PARTICLESTREAMSPEC::ATM_PLIN: afac = 1.0/(pss->amax-amin); break;
	case PARTICLESTREAMSPEC::ATM_PLOG: afac = 1.0/log(pss->amax/amin); break;
	}
	tex = (pss->tex ? (LPDIRECT3DTEXTURE9)pss->tex : deftex);
}

void D3D9ParticleStream::SetParticleHalflife (double pht)
{
	exp_rate = RAND_MAX/pht;
	stride = max (1, min (20,(int)pht));
	ipht2 = 0.5/pht;
}

void D3D9ParticleStream::SetObserverRef (const VECTOR3 *cam)
{
	cam_ref = cam;
}

void D3D9ParticleStream::SetSourceRef (const VECTOR3 *src)
{
	src_ref = src;
}

void D3D9ParticleStream::SetSourceOffset (const VECTOR3 &ofs)
{
	src_ofs = ofs;
}

void D3D9ParticleStream::SetIntensityLevelRef (double *lvl)
{
	level = lvl;
}

double D3D9ParticleStream::Level2Alpha (double level) const
{
	switch (lmap) {
	case PARTICLESTREAMSPEC::LVL_FLAT:
		return lmin;
	case PARTICLESTREAMSPEC::LVL_LIN:
		return level;
	case PARTICLESTREAMSPEC::LVL_SQRT:
		return sqrt (level);
	case PARTICLESTREAMSPEC::LVL_PLIN:
		return max (0, min (1, (level-lmin)/(lmax-lmin)));
	case PARTICLESTREAMSPEC::LVL_PSQRT:
		return (level <= lmin ? 0 : level >= lmax ? 1 : sqrt ((level-lmin)/(lmax-lmin)));
	}
	return 0; // should not happen
}

double D3D9ParticleStream::Atm2Alpha (double prm) const
{
	switch (amap) {
	case PARTICLESTREAMSPEC::ATM_FLAT:
		return amin;
	case PARTICLESTREAMSPEC::ATM_PLIN:
		return max (0, min (1, (prm-amin)*afac));
	case PARTICLESTREAMSPEC::ATM_PLOG:
		return max (0, min (1, log(prm/amin)*afac));
	}
	return 0; // should not happen
}

ParticleSpec *D3D9ParticleStream::CreateParticle (const VECTOR3 &pos, const VECTOR3 &vel, double size,
	double alpha)
{
	ParticleSpec *p = new ParticleSpec;
	p->pos = pos;
	p->vel = vel;
	p->size = size;
	p->alpha0 = alpha;
	p->t0 = oapiGetSimTime();
	p->texidx = (rand() & 7) * 4;
	p->flag = 0;
	p->next = NULL;
	p->prev = plast;
	if (plast) plast->next = p;
	else       pfirst = p;
	plast = p;
	np++;

	if (np > MAXPARTICLE)
		DeleteParticle (pfirst);

	return p;
}

void D3D9ParticleStream::DeleteParticle (ParticleSpec *p)
{
	if (p->prev) p->prev->next = p->next;
	else         pfirst = p->next;
	if (p->next) p->next->prev = p->prev;
	else         plast = p->prev;
	delete p;
	np--;
}

void D3D9ParticleStream::Update ()
{
	ParticleSpec *p, *tmp;
	double dt = oapiGetSimStep();

	for (p = pfirst; p;) {
		if (dt * exp_rate > rand()) {
			tmp = p;
			p = p->next;
			DeleteParticle (tmp);
		} else {
			p->pos += p->vel*dt;
			p = p->next;
		}
	}
}

void D3D9ParticleStream::Timejump ()
{
	while (pfirst) {
		ParticleSpec *tmp = pfirst;
		pfirst = pfirst->next;
		delete tmp;
	}
	pfirst = NULL;
	plast = NULL;
	np = 0;
	t0 = oapiGetSimTime();
}

void D3D9ParticleStream::SetDParticleCoords (const VECTOR3 &ppos, double scale, NTVERTEX *vtx)
{
	VECTOR3 cdir = ppos;
	double ux, uy, uz, vx, vy, vz, len;
	if (cdir.y || cdir.z) {
		ux =  0;
		uy =  cdir.z;
		uz = -cdir.y;
		len = scale / sqrt (uy*uy + uz*uz);
		uy *= len;
		uz *= len;
		vx = cdir.y*cdir.y + cdir.z*cdir.z;
		vy = -cdir.x*cdir.y;
		vz = -cdir.x*cdir.z;
		len = scale / sqrt(vx*vx + vy*vy + vz*vz);
		vx *= len;
		vy *= len;
		vz *= len;
	} else {
		ux = 0;
		uy = scale;
		uz = 0;
		vx = 0;
		vy = 0;
		vz = scale;
	}
	vtx[0].x = (float)(ppos.x-ux-vx);
	vtx[0].y = (float)(ppos.y-uy-vy);
	vtx[0].z = (float)(ppos.z-uz-vz);
	vtx[1].x = (float)(ppos.x-ux+vx);
	vtx[1].y = (float)(ppos.y-uy+vy);
	vtx[1].z = (float)(ppos.z-uz+vz);
	vtx[2].x = (float)(ppos.x+ux+vx);
	vtx[2].y = (float)(ppos.y+uy+vy);
	vtx[2].z = (float)(ppos.z+uz+vz);
	vtx[3].x = (float)(ppos.x+ux-vx);
	vtx[3].y = (float)(ppos.y+uy-vy);
	vtx[3].z = (float)(ppos.z+uz-vz);
}

void D3D9ParticleStream::SetEParticleCoords (const VECTOR3 &ppos, double scale, VERTEX_XYZ_TEX *vtx)
{
	VECTOR3 cdir = ppos;
	double ux, uy, uz, vx, vy, vz, len;
	if (cdir.y || cdir.z) {
		ux =  0;
		uy =  cdir.z;
		uz = -cdir.y;
		len = scale / sqrt (uy*uy + uz*uz);
		uy *= len;
		uz *= len;
		vx = cdir.y*cdir.y + cdir.z*cdir.z;
		vy = -cdir.x*cdir.y;
		vz = -cdir.x*cdir.z;
		len = scale / sqrt(vx*vx + vy*vy + vz*vz);
		vx *= len;
		vy *= len;
		vz *= len;
	} else {
		ux = 0;
		uy = scale;
		uz = 0;
		vx = 0;
		vy = 0;
		vz = scale;
	}
	vtx[0].x = (float)(ppos.x-ux-vx);
	vtx[0].y = (float)(ppos.y-uy-vy);
	vtx[0].z = (float)(ppos.z-uz-vz);
	vtx[1].x = (float)(ppos.x-ux+vx);
	vtx[1].y = (float)(ppos.y-uy+vy);
	vtx[1].z = (float)(ppos.z-uz+vz);
	vtx[2].x = (float)(ppos.x+ux+vx);
	vtx[2].y = (float)(ppos.y+uy+vy);
	vtx[2].z = (float)(ppos.z+uz+vz);
	vtx[3].x = (float)(ppos.x+ux-vx);
	vtx[3].y = (float)(ppos.y+uy-vy);
	vtx[3].z = (float)(ppos.z+uz-vz);
}

void D3D9ParticleStream::SetShadowCoords (const VECTOR3 &ppos, const VECTOR3 &cdir, double scale, VERTEX_XYZ_TEX *vtx)
{
	double ux, uy, uz, vx, vy, vz, len;
	if (cdir.y || cdir.z) {
		ux =  0;
		uy =  cdir.z;
		uz = -cdir.y;
		len = scale / sqrt (uy*uy + uz*uz);
		uy *= len;
		uz *= len;
		vx = cdir.y*cdir.y + cdir.z*cdir.z;
		vy = -cdir.x*cdir.y;
		vz = -cdir.x*cdir.z;
		len = scale / sqrt(vx*vx + vy*vy + vz*vz);
		vx *= len;
		vy *= len;
		vz *= len;
	} else {
		ux = 0;
		uy = scale;
		uz = 0;
		vx = 0;
		vy = 0;
		vz = scale;
	}
	vtx[0].x = (float)(ppos.x-ux-vx);
	vtx[0].y = (float)(ppos.y-uy-vy);
	vtx[0].z = (float)(ppos.z-uz-vz);
	vtx[1].x = (float)(ppos.x-ux+vx);
	vtx[1].y = (float)(ppos.y-uy+vy);
	vtx[1].z = (float)(ppos.z-uz+vz);
	vtx[2].x = (float)(ppos.x+ux+vx);
	vtx[2].y = (float)(ppos.y+uy+vy);
	vtx[2].z = (float)(ppos.z+uz+vz);
	vtx[3].x = (float)(ppos.x+ux-vx);
	vtx[3].y = (float)(ppos.y+uy-vy);
	vtx[3].z = (float)(ppos.z+uz-vz);
}

void D3D9ParticleStream::CalcNormals (const VECTOR3 &ppos, NTVERTEX *vtx)
{
	VECTOR3 cdir = unit (ppos);
	double ux, uy, uz, vx, vy, vz, len;
	if (cdir.y || cdir.z) {
		ux =  0;
		uy =  cdir.z;
		uz = -cdir.y;
		len = 3.0 / sqrt (uy*uy + uz*uz);
		uy *= len;
		uz *= len;
		vx = cdir.y*cdir.y + cdir.z*cdir.z;
		vy = -cdir.x*cdir.y;
		vz = -cdir.x*cdir.z;
		len = 3.0 / sqrt(vx*vx + vy*vy + vz*vz);
		vx *= len;
		vy *= len;
		vz *= len;
	} else {
		ux = 0;
		uy = 1.0;
		uz = 0;
		vx = 0;
		vy = 0;
		vz = 1.0;
	}
	static float scale = (float)(1.0/sqrt(19.0));
	vtx[0].nx = scale*(float)(-cdir.x-ux-vx);
	vtx[0].ny = scale*(float)(-cdir.y-uy-vy);
	vtx[0].nz = scale*(float)(-cdir.z-uz-vz);
	vtx[1].nx = scale*(float)(-cdir.x-ux+vx);
	vtx[1].ny = scale*(float)(-cdir.y-uy+vy);
	vtx[1].nz = scale*(float)(-cdir.z-uz+vz);
	vtx[2].nx = scale*(float)(-cdir.x+ux+vx);
	vtx[2].ny = scale*(float)(-cdir.y+uy+vy);
	vtx[2].nz = scale*(float)(-cdir.z+uz+vz);
	vtx[3].nx = scale*(float)(-cdir.x+ux-vx);
	vtx[3].ny = scale*(float)(-cdir.y+uy-vy);
	vtx[3].nz = scale*(float)(-cdir.z+uz-vz);
}

void D3D9ParticleStream::Render (LPDIRECT3DDEVICE9 dev, LPDIRECT3DTEXTURE9 &prevtex)
{
	if (!pfirst) return;
	dev->SetTransform (D3DTS_WORLD, &mWorld);

	if (prevtex != tex) dev->SetTexture (0, prevtex = tex);

	if (diffuse) RenderDiffuse (dev);
	else         RenderEmissive (dev);
}

void D3D9ParticleStream::RenderDiffuse (LPDIRECT3DDEVICE9 dev)
{
	static D3DMATERIAL9 smokemat = { // emissive material for engine exhaust
		{1,1,1,1},
		{0,0,0,1},
		{0,0,0,1},
		{0.2f,0.2f,0.2f,1},
		0.0
	};

	ParticleSpec *p;
	int i0, j, n, stride = np/16+1;
	float *u, *v;
	NTVERTEX *vtx;
	
	dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
	dev->SetTextureStageState (0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
	dev->SetRenderState (D3DRS_ZWRITEENABLE, FALSE);

	CalcNormals (plast->pos - *cam_ref, dvtx);
	for (p = pfirst, vtx = dvtx, n = i0 = 0; p; p = p->next) {
		SetDParticleCoords (p->pos - *cam_ref, p->size, vtx);
		u = tu + p->texidx;
		v = tv + p->texidx;
		for (j = 0; j < 4; j++, vtx++) {
			vtx->nx = dvtx[j].nx;
			vtx->ny = dvtx[j].ny;
			vtx->nz = dvtx[j].nz;
			vtx->tu = u[j]; 
			vtx->tv = v[j];
		}
		if (++n == stride || n+i0 == np) {
			smokemat.Diffuse.a = (float)max (0.1, p->alpha0*(1.0-(oapiGetSimTime()-p->t0)*ipht2));
			dev->SetMaterial (&smokemat);
			dev->SetFVF(FVF_NTVERTEX);
			dev->DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST, 0, n*4, n*2, idx, D3DFMT_INDEX16, dvtx+i0*4, sizeof(NTVERTEX));
			i0 += n;
			n = 0;
		}
	}

	dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
	dev->SetTextureStageState (0, D3DTSS_ALPHAARG2, D3DTA_CURRENT);
	dev->SetRenderState (D3DRS_ZWRITEENABLE, TRUE);
}

void D3D9ParticleStream::RenderEmissive (LPDIRECT3DDEVICE9 dev)
{
	static D3DMATERIAL9 smokemat = { // emissive material for engine exhaust
		{0,0,0,1},
		{0,0,0,1},
		{0,0,0,1},
		{1,1,1,1},
		0.0
	};

	ParticleSpec *p;
	int i0, j, n;
	float *u, *v;
	VERTEX_XYZ_TEX *vtx;

	dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
	dev->SetTextureStageState (0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
	dev->SetRenderState (D3DRS_ZWRITEENABLE, FALSE);

	for (p = pfirst, vtx = evtx, n = i0 = 0; p; p = p->next) {
		SetEParticleCoords (p->pos - *cam_ref, p->size, vtx);
		u = tu + p->texidx;
		v = tv + p->texidx;
		for (j = 0; j < 4; j++, vtx++) {
			vtx->tu = u[j];
			vtx->tv = v[j];
		}
		smokemat.Diffuse.a = (float)max (0.1, p->alpha0*(1.0-(oapiGetSimTime()-p->t0)*ipht2));
		SetMaterial (smokemat.Emissive);
		dev->SetMaterial (&smokemat);
		if (++n == stride || n+i0 == np) {
			dev->SetFVF(FVF_XYZ_TEX);
			dev->DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST, 0, n*4, n*2, idx, D3DFMT_INDEX16, evtx+i0*4, sizeof(VERTEX_XYZ_TEX));
			i0 += n;
			n = 0;
		}
	}
	dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
	dev->SetTextureStageState (0, D3DTSS_ALPHAARG2, D3DTA_CURRENT);
	dev->SetRenderState (D3DRS_ZWRITEENABLE, TRUE);
}

// =======================================================================

ExhaustStream::ExhaustStream (oapi::GraphicsClient *_gc, OBJHANDLE hV,
	const double *srclevel, const VECTOR3 *thref, const VECTOR3 *thdir,
	PARTICLESTREAMSPEC *pss)
: D3D9ParticleStream (_gc, pss)
{
	Attach (hV, thref, thdir, srclevel);
	hPlanet = 0;
}

ExhaustStream::ExhaustStream (oapi::GraphicsClient *_gc, OBJHANDLE hV,
	const double *srclevel, const VECTOR3 &ref, const VECTOR3 &_dir,
	PARTICLESTREAMSPEC *pss)
: D3D9ParticleStream (_gc, pss)
{
	Attach (hV, ref, _dir, srclevel);
	hPlanet = 0;
}

void ExhaustStream::Update ()
{
	D3D9ParticleStream::Update ();

	double simt = oapiGetSimTime();
	double dt = oapiGetSimStep();
	double alpha0;

	VESSEL *vessel = (hRef ? oapiGetVesselInterface (hRef) : 0);

	if (np) {
		ParticleSpec *p;
		double lng, lat, r1, r2;
		int i;
		if (vessel) hPlanet = vessel->GetSurfaceRef();
		if (hPlanet) {
			VECTOR3 pp, pv, pw;
			MATRIX3 pR;
			oapiGetRotationMatrix (hPlanet, &pR);
			oapiGetGlobalPos (hPlanet, &pp);
			oapiGetGlobalVel (hPlanet, &pv);
			VECTOR3 dv = pp-plast->pos; // gravitational dv
			double d = length (dv);
			dv *= GGRAV * oapiGetMass(hPlanet)/(d*d*d) * dt;

			ATMPARAM prm;
			oapiGlobalToEqu (hPlanet, pfirst->pos, &lng, &lat, &r1);
			oapiGetWindVector (hPlanet, lng, lat, r1, &pw);
			VECTOR3 av1 = mul (pR, pw) + pv;
			oapiGlobalToEqu (hPlanet, plast->pos, &lng, &lat, &r2);
			oapiGetWindVector (hPlanet, lng, lat, r2, &pw);
			VECTOR3 av2 = mul (pR, pw) + pv;
			VECTOR3 dav = (av2-av1)/np;
			double r = oapiGetSize (hPlanet);
			oapiGetPlanetAtmParams (hPlanet, d, &prm);
			double pref = sqrt(prm.p)/300.0;
			double slow = exp(-beta*pref*dt);

			for (p = pfirst, i = 0; p; p = p->next, i++) {
				p->vel += dv;
				VECTOR3 av = dav*i + av1; // atmosphere velocity
				VECTOR3 vv = p->vel-av;   // velocity difference
				p->vel = vv*slow + av;
				p->size += alpha * dt;

				VECTOR3 s (p->pos - pp);
				if (length(s) < r) {
					VECTOR3 dp = s * (r/length(s)-1.0);
					p->pos += dp;

					static double dv_scale = length(vv)*0.2;
					VECTOR3 dv = {((double)rand()/(double)RAND_MAX-0.5)*dv_scale,
								  ((double)rand()/(double)RAND_MAX-0.5)*dv_scale,
								  ((double)rand()/(double)RAND_MAX-0.5)*dv_scale};
					dv += vv;

					normalise(s);
					VECTOR3 vv2 = dv - s*dotp(s,dv);
					if (length(vv2)) vv2 *= 0.5*length(vv)/length(vv2);
					vv2 += s*(((double)rand()/(double)RAND_MAX)*dv_scale);
					p->vel = vv2*1.0/*2.0*/+av;
					double r = (double)rand()/(double)RAND_MAX;
					p->pos += (vv2-vv) * dt * r;
					//p->size *= (1.0+r);
				}
			}
		}
	}

	if (level && *level > 0 && (alpha0 = Level2Alpha(*level) * Atm2Alpha (vessel->GetAtmDensity())) > 0.01) {
		if (simt > t0+interval) {
			VECTOR3 vp, vv;
			MATRIX3 vR;
			vessel->GetRotationMatrix (vR);
			vessel->GetGlobalPos (vp);
			vessel->GetGlobalVel (vv);
			VECTOR3 vr = mul (vR, *dir) * (-speed);
			while (simt > t0+interval) {
				// create new particle
				double dt = simt-t0-interval;
				double dv_scale = speed*vrand; // exhaust velocity randomisation
				VECTOR3 dv = {((double)rand()/(double)RAND_MAX-0.5)*dv_scale,
						      ((double)rand()/(double)RAND_MAX-0.5)*dv_scale,
							  ((double)rand()/(double)RAND_MAX-0.5)*dv_scale};
				ParticleSpec *p = CreateParticle (mul (vR, *pos) + vp + (vr+dv)*dt,
					vv + vr+dv, size0, alpha0);
				p->size += alpha * dt;

				if (diffuse && hPlanet && bShadows) { // check for shadow render
					double lng, lat, alt;
					static const double eps = 1e-2;
					oapiGlobalToEqu (hPlanet, p->pos, &lng, &lat, &alt);
					//planet->GlobalToEquatorial (MakeVector(p->pos), lng, lat, alt);
					alt -= oapiGetSize(hPlanet);
					if (alt*eps < vessel->GetSize()) p->flag |= 1; // render shadow
				}

				// determine next interval (pretty hacky)
				t0 += interval;
				if (speed > 10) {
					interval = max (0.015, size0 / (pdensity * (0.1*vessel->GetAirspeed() + size0)));
				} else {
					interval = 1.0/pdensity;
				}
				interval *= (double)rand()/(double)RAND_MAX + 0.5;
			}
		}
	} else t0 = simt;

}

void ExhaustStream::RenderGroundShadow (LPDIRECT3DDEVICE9 dev, LPDIRECT3DTEXTURE9 &prevtex)
{
	if (!diffuse || !hPlanet) return;

	bool needsetup = true;
	ParticleSpec *p;
	double R;
	float *u, *v, alpha;
	int n, j, i0; 
	VECTOR3 sd, hn;

	VERTEX_XYZ_TEX *vtx;
	VECTOR3 pp;
	oapiGetGlobalPos (hPlanet, &pp);

	for (p = pfirst, vtx = evtx, n = i0 = 0; p; p = p->next) {
		if (!(p->flag & 1)) continue;

		if (needsetup) {
			R = oapiGetSize(hPlanet);
			sd = unit(p->pos);  // shadow projection direction
			VECTOR3 pv0 = p->pos - pp;   // rel. particle position
			// calculate the intersection of the vessel's shadow with the planet surface
			double fac1 = dotp (sd, pv0);
			if (fac1 > 0.0) return;       // shadow doesn't intersect planet surface
			double arg  = fac1*fac1 - (dotp (pv0, pv0) - R*R);
			if (arg <= 0.0) return;       // shadow doesn't intersect with planet surface
			double a = -fac1 - sqrt(arg);
			VECTOR3 shp = sd*a;           // projection point in global frame
			hn = unit (shp + pv0);        // horizon normal in global frame

			dev->SetTransform (D3DTS_WORLD, &mWorld);
			if (prevtex != tex) dev->SetTexture (0, prevtex = tex);
			dev->SetRenderState (D3DRS_LIGHTING, FALSE);
			dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);
			dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TFACTOR);
			dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
			dev->SetTextureStageState (0, D3DTSS_ALPHAARG2, D3DTA_TFACTOR);
			needsetup = false;
		}

		VECTOR3 pvr = p->pos - pp;   // rel. particle position

		// calculate the intersection of the vessel's shadow with the planet surface
		double fac1 = dotp (sd, pvr);
		if (fac1 > 0.0) break;       // shadow doesn't intersect planet surface
		double arg  = fac1*fac1 - (dotp (pvr, pvr) - R*R);
		if (arg <= 0.0) break;       // shadow doesn't intersect with planet surface
		double a = -fac1 - sqrt(arg);

		SetShadowCoords (p->pos - *cam_ref + sd*a, -hn, p->size, vtx);
		u = tu + p->texidx;
		v = tv + p->texidx;
		for (j = 0; j < 4; j++, vtx++) {
			vtx->tu = u[j];
			vtx->tv = v[j];
		}
		if (++n == stride || n+i0 == np) {
			alpha = (float)max (0.1, 0.60 * p->alpha0*(1.0-(oapiGetSimTime()-p->t0)*ipht2));
			dev->SetRenderState (D3DRS_TEXTUREFACTOR, D3DCOLOR_COLORVALUE(0,0,0,alpha));
			dev->SetFVF(FVF_XYZ_TEX);
			dev->DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST, 0, n*4, n*2, idx, D3DFMT_INDEX16, evtx+i0*4, sizeof(VERTEX_XYZ_TEX));
			i0 += n;
			n = 0;
		}
	}

	if (!needsetup) {
		dev->SetRenderState (D3DRS_LIGHTING, TRUE);
		dev->SetTextureStageState (0, D3DTSS_COLOROP, D3DTOP_MODULATE);
		dev->SetTextureStageState (0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
		dev->SetTextureStageState (0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
		dev->SetTextureStageState (0, D3DTSS_ALPHAARG2, D3DTA_CURRENT);
	}
}

// =======================================================================

ReentryStream::ReentryStream (oapi::GraphicsClient *_gc, OBJHANDLE hV, PARTICLESTREAMSPEC *pss)
: D3D9ParticleStream (_gc, pss)
{
	llevel = 1.0;
	Attach (hV, _V(0,0,0), _V(0,0,0), &llevel);
	hPlanet = 0;
}

void ReentryStream::SetMaterial (D3DCOLORVALUE &col)
{
	// should be heating-dependent
	col.r = 1.0f;
	col.g = 0.7f;
	col.b = 0.5f; 
}

void ReentryStream::Update ()
{
	D3D9ParticleStream::Update ();
	VESSEL *vessel = (hRef ? oapiGetVesselInterface (hRef) : 0);

	double simt = oapiGetSimTime();
	double simdt = oapiGetSimStep();
	double friction = (vessel ? vessel->GetDynPressure() * vessel->GetAirspeed() : 0.0);
	double alpha0;

	if (np) {
		ParticleSpec *p;
		double lng, lat, r1, r2;
		int i;
		if (vessel) hPlanet = vessel->GetSurfaceRef();
		if (hPlanet) {
			VECTOR3 pv, pw;
			MATRIX3 pR;
			oapiGetRotationMatrix (hPlanet, &pR);
			oapiGetGlobalVel (hPlanet, &pv);
			oapiGlobalToEqu (hPlanet, pfirst->pos, &lng, &lat, &r1);
			oapiGetWindVector (hPlanet, lng, lat, r1, &pw);
			VECTOR3 av1 = mul (pR, pw) + pv;
			oapiGlobalToEqu (hPlanet, plast->pos, &lng, &lat, &r2);
			oapiGetWindVector (hPlanet, lng, lat, r2, &pw);
			VECTOR3 av2 = mul (pR, pw) + pv;
			VECTOR3 dav = (av2-av1)/np;
			double r = oapiGetSize (hPlanet);

			for (p = pfirst, i = 0; p; p = p->next, i++) {
				VECTOR3 av = dav*i + av1;
				VECTOR3 vv = p->vel-av;
				double slow = exp(-beta*simdt);
				p->vel = vv*slow + av;
				p->size += alpha * simdt;
			}
		}
	}

	if (friction > 0 && (alpha0 = Atm2Alpha (friction)) > 0.01) {
		if (simt > t0+interval) {
			VECTOR3 vp, vv, av;
			vessel->GetGlobalPos (vp);
			vessel->GetGlobalVel (vv);

			if (hPlanet) {
				VECTOR3 pv, pw;
				MATRIX3 pR;
				oapiGetRotationMatrix (hPlanet, &pR);
				oapiGetGlobalVel (hPlanet, &pv);
				double lng, lat, r;
				oapiGlobalToEqu (hPlanet, vp, &lng, &lat, &r);
				oapiGetWindVector (hPlanet, lng, lat, r, &pw);
				av = mul (pR, pw) + pv;
			} else
				av = vv;

			while (simt > t0+interval) {
				// create new particle
				double dt = simt-t0-interval;
				double ebt = exp(-beta*dt);
				double dv_scale = vessel->GetAirspeed()*vrand; // exhaust velocity randomisation
				VECTOR3 dv = {((double)rand()/(double)RAND_MAX-0.5)*dv_scale,
						      ((double)rand()/(double)RAND_MAX-0.5)*dv_scale,
							  ((double)rand()/(double)RAND_MAX-0.5)*dv_scale};
				VECTOR3 dx = (vv-av) * (1.0-ebt)/beta + av*dt;
				CreateParticle (vp + dx - vv*dt, (vv+dv-av)*ebt + av, size0, alpha0);
				// determine next interval
				t0 += interval;
				interval = max (0.015, size0 / (pdensity * (0.1*vessel->GetAirspeed() + size0)));
				interval *= (double)rand()/(double)RAND_MAX + 0.5;
			}
		}
	} else t0 = simt;
}
