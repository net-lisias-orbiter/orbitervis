// ==============================================================
// Light.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

// ==============================================================
// class D3D7Light (implementation)
//
// This class represents a light source in terms of DX7 interface
// (D3DLIGHT7)
// ==============================================================

#include "Light.h"
#include "Scene.h"
#include "Camera.h"
#include "D3D9Util.h"

D3D7Light::D3D7Light (OBJHANDLE _hObj, LTYPE _ltype, const Scene *scene, DWORD _idx)
{
	hObj = _hObj;
	rpos = _V(0,0,0);
	ltype = _ltype;
	scn = scene;
	idx = _idx;

	memset (&light, 0, sizeof(D3DLIGHT9));

	switch (ltype) {
	case Point:       light.Type = D3DLIGHT_POINT;       break;
	case Spot:        light.Type = D3DLIGHT_SPOT;        break;
	case Directional: light.Type = D3DLIGHT_DIRECTIONAL; break;
	}
	light.Diffuse.r = light.Specular.r = 1.0f; // generalise (from light source specs)
	light.Diffuse.g = light.Specular.g = 1.0f;
	light.Diffuse.b = light.Specular.b = 1.0f;

	light.Attenuation0 = 1.0f; 
    light.Range = 10000000; //FLT_MAX;

	scn->GetClient()->GetDevice()->LightEnable (idx, TRUE);
}

void D3D7Light::Update ()
{
	switch (ltype) {
	case Point:
		// to be done
		break;
	case Spot:
		// to be done
		break;
	case Directional:
		UpdateDirectional();
		break;
	};
}

void D3D7Light::UpdateDirectional ()
{
	VECTOR3 rpos;
	oapiGetGlobalPos (hObj, &rpos);
	rpos -= *scn->GetCamera()->GetGPos(); // object position rel. to camera
	rpos /= -length(rpos); // normalise
	D3DVEC(rpos, light.Direction);
}

void D3D7Light::SetLight (LPDIRECT3DDEVICE9 dev)
{
	dev->SetLight (idx, &light);
}