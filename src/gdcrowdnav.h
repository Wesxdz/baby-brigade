#pragma once

#include <Godot.hpp>
#include <RigidBody.hpp>
#include <PhysicsDirectBodyState.hpp>
#include <vector>
#include <map>
#include <Curve.hpp>

namespace godot {

class GDCrowdNav : public RigidBody {
	GODOT_CLASS(GDCrowdNav, RigidBody)

private:
	Vector3 target;

public:
	class GDBoidField* field;
	static void _register_methods();

	void _init();
	
	void _enter_tree();
	void _physics_process(float delta);
	void _integrate_forces(PhysicsDirectBodyState* state);

	GDCrowdNav();
	~GDCrowdNav();
};

class GDBoidAffector : public Spatial {
	GODOT_CLASS(GDBoidAffector, Spatial)

public:
	float radius;
	float strength;
	Ref<Curve> curve;
	enum Behavior
	{
		Attract,
		Repel
	} behavior;
	void set_behavior(int b);
	int get_behavior();
	class GDBoidField* field;
	NodePath bodyNode;
	RID body;

public:
	static void _register_methods();

	void _init();
	void _enter_tree();
	void _exit_tree();
	GDBoidAffector();
};


class GDBoidField : public Node
{
	GODOT_CLASS(GDBoidField, Node)
public:
	std::vector<GDBoidAffector*> boids;
	std::map<RID,Vector3> accumulatedForces;
	void Step();

public:
	static void _register_methods();
	void _init();

	void _physics_process(float delta);
};

}
