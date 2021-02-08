#pragma once

#include <Godot.hpp>
#include <RigidBody.hpp>
#include <PhysicsDirectBodyState.hpp>
#include <vector>
#include <map>
#include <Curve.hpp>
#include <Texture.hpp>

#include "nanoflann.hpp"
using namespace nanoflann;

template <typename T>
struct PointCloud
{

	std::vector<godot::Vector3> pts;

	// Must return the number of data points
	inline size_t kdtree_get_point_count() const { return pts.size(); }

	// Returns the dim'th component of the idx'th point in the class:
	// Since this is inlined and the "dim" argument is typically an immediate value, the
	//  "if/else's" are actually solved at compile time.
	inline T kdtree_get_pt(const size_t idx, const size_t dim) const
	{
		if (dim == 0) return pts[idx].x;
		else if (dim == 1) return pts[idx].y;
		else return pts[idx].z;
	}

	// Optional bounding-box computation: return false to default to a standard bbox computation loop.
	//   Return true if the BBOX was already computed by the class and returned in "bb" so it can be avoided to redo it again.
	//   Look at bb.size() to find out the expected dimensionality (e.g. 2 or 3 for point clouds)
	template <class BBOX>
	bool kdtree_get_bbox(BBOX& /* bb */) const { return false; }

};

typedef KDTreeSingleIndexAdaptor<
	L2_Simple_Adaptor<float, PointCloud<real_t>>,
	PointCloud<real_t>,
	3
	> agent_kd_tree_t;

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
	int behavior;
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
	void StepOptimized();

public:
	static void _register_methods();
	void _init();

	void _physics_process(float delta);
};

}
