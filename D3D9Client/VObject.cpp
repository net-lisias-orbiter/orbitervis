// ==============================================================
// VObject.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

// ==============================================================
// class vObject (implementation)
//
// A "vObject" is the visual representation of an Orbiter object
// (vessel, planet/moon/sun, surface base). vObjects usually have
// one or more meshes associated with it that define their visual
// appearance, but they can be arbitrarily complex (e.g. planets
// with clould layers, atmospheric haze, etc.)
// Visual objects don't persist as their "logical" counterparts,
// but are created and deleted as they pass in and out of the
// visual range of a camera. vObjects are therefore associated
// with a particular scene. In multi-scene environments, a single
// logical object may have multiple vObjects associated with it.
// ==============================================================

#include "VObject.h"
#include "VVessel.h"
#include "VPlanet.h"
#include "VBase.h"
#include "Camera.h"
#include "D3D9Util.h"

using namespace oapi;

const D3D9Client *vObject::gc = NULL;

vObject::vObject (OBJHANDLE _hObj, const Scene *scene)
{
	active = true;
	hObj = _hObj;
	scn  = scene;
	D3DMAT_Identity (&mWorld);
	cdist = 0.0;
}

vObject *vObject::Create (OBJHANDLE _hObj, const Scene *scene)
{
	switch (oapiGetObjectType (_hObj)) {
	case OBJTP_VESSEL:
		return new vVessel (_hObj, scene);
	case OBJTP_PLANET:
		return new vPlanet (_hObj, scene);
	case OBJTP_SURFBASE:
		return new vBase (_hObj, scene);
	default:
		return new vObject (_hObj, scene);
	}
}

void vObject::GlobalInit (const D3D9Client *gclient)
{
	gc = gclient;
}


void vObject::Activate (bool isactive)
{
	active = isactive;
}

bool vObject::Update ()
{
	if (!active) return false;

	MATRIX3 grot;
	oapiGetRotationMatrix (hObj, &grot);
	oapiGetGlobalPos (hObj, &cpos);
	cpos -= *scn->GetCamera()->GetGPos();
	// object positions are relative to camera

	cdist = length (cpos);
	// camera distance

	D3DMAT_SetInvRotation (&mWorld, &grot);
	D3DMAT_SetTranslation (&mWorld, &cpos);
	// update the object's world matrix

	CheckResolution();
	return true;
}