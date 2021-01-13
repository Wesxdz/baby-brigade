#pragma once

#include <Godot.hpp>
#include <RigidBody.hpp>

namespace godot {

/*

*/
class GDCrowdNav : public RigidBody {
	GODOT_CLASS(GDCrowdNav, RigidBody)

private:
	Vector3 target;

public:
	static void _register_methods();

	void _init();
	
	GDCrowdNav();
	~GDCrowdNav();
};

}