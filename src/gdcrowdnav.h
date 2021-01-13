#pragma once

#include <Godot.hpp>
#include <RigidBody.hpp>

namespace godot {

class GDCrowdNav : public RigidBody {
	GODOT_CLASS(GDCrowdNav, RigidBody)

private:

public:
	static void _register_methods();

	void _init();
	
	GDCrowdNav();
	~GDCrowdNav();
};

}