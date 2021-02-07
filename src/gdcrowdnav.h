#pragma once

#include <Godot.hpp>
#include <RigidBody.hpp>
#include <PhysicsDirectBodyState.hpp>
#include <vector>
#include <map>
#include <Curve.hpp>
#include <Texture.hpp>

namespace godot {

// struct HeightCell
// {
// 	Texture shadow;
// 	float max_height;
// };

class GDCrowdNav : public RigidBody {
	GODOT_CLASS(GDCrowdNav, RigidBody)

private:
	float height;
	float fall_velocity;
	float fall_acceleration;
	bool on_ground;
	Vector3 target;

public:
	// TODO: Need up update boid field affected if this is changed at runtime
	uint32_t layer;
	int subgroup;
	class GDBoidField* field;
	static void _register_methods();

	void _init();
	
	void _enter_tree();
	void _exit_tree();
	void _physics_process(float delta);
	void _integrate_forces(PhysicsDirectBodyState* state);
	
	void set_height(float h);
	float get_height();

	void set_fall_velocity(float v);
	float get_fall_velocity();

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
		Repel,
		Converge,
		Diverge
	} behavior;
	void set_behavior(int b);
	int get_behavior();
	class GDBoidField* field;
	NodePath bodyNode;
	RID body;
	uint32_t affect_layers;
	int subgroup;

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
	std::vector<RID> crowdAgents;
	std::map<RID, Vector3> accumulatedForces;
	std::map<RID, uint32_t> affected;
	std::map<RID, int> subgroups;

	void Step();

public:
	static void _register_methods();
	void _init();

	void _physics_process(float delta);
};

}
