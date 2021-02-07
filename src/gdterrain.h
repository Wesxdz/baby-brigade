#pragma once

#include <Godot.hpp>
#include <Spatial.hpp>
#include <GDNative.hpp>
#include <ArrayMesh.hpp>
#include <Material.hpp>
#include <MeshInstance.hpp>
#include <PackedScene.hpp>

#include "FastNoiseLite.h"
#include <list>
#include <vector>

namespace godot {

// Arc Procedural Hill (a cone atop a cylinder, with a noise surface)
class GDArcProcHill : public Spatial {
	GODOT_CLASS(GDArcProcHill, Spatial)

private:
	struct Arcsegment
	{
		MeshInstance* mesh;
		RID body;
		Vector3 pos;
	};

	float cone_height;
	float hill_radius;
	// Multiplier of noise points in world space
	float density;
	float amplitude;
	int arcsPerRing;
	FastNoiseLite noiseGen;
	Ref<Material> snowMaterial;
	Ref<PackedScene> tree_prefab;
	Ref<PackedScene> coin_prefab;
	Ref<PackedScene> demon_prefab;
	Ref<PackedScene> enemy_banner_prefab;
	std::list<Arcsegment> arcs;
	float nextArcY = -50.0f;
	Spatial* target;
	float despawnDistance = 300.0f;
	float spawnDistance = 200.0f;
	std::vector<Spatial*> props;
	int enemySpawnGroup = 1;

public:

	static void _register_methods();

	GDArcProcHill();
	~GDArcProcHill();

	void _init();
	void _process(float delta);

	void gen_hill();

	void _enter_tree();

	void create_arc(Vector3 pos, float degrees, float radius, float hole);
	void create_y_arc(Vector3 pos, float degrees, float radius);
	ArrayMesh* gen_arc_mesh(Vector3 pos, float degrees, float radius, float hole, size_t quads, PoolVector3Array& faces, int layers = 1);
	// Arc normal is vector from y origin
	ArrayMesh* gen_y_arc_mesh(Vector3 pos, float degrees, float radius, size_t quads, PoolVector3Array& faces, int layers = 1);

	void set_seed(float p_seed);
};

}
