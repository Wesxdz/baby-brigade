#pragma once

#include <Godot.hpp>
#include <Spatial.hpp>
#include <GDNative.hpp>
#include <ArrayMesh.hpp>
#include <Material.hpp>
#include <MeshInstance.hpp>
#include <PackedScene.hpp>
#include <Texture.hpp>
#include <ShaderMaterial.hpp>

#include <unordered_map>

#include "FastNoiseLite.h"
#include <list>
#include <vector>

#include "gdcrowdnav.h"

namespace godot {

enum BiomeType
{
	GRASSLANDS,
	TUNDRA,
	DESERT,
};

struct SpawnPrefabData
{
	Ref<PackedScene> prefab;
	float freq;
	// TODO: More sophisticated procedural generation ruleset
};

struct BiomeSpawnData
{
	float minSize;
	float averageSize;
	float maxSize;
	Color sky;
	Ref<Texture> palette;
	std::vector<SpawnPrefabData> prefabs;
	// TODO: Enemy types that can spawn in this biome
};

struct BiomeInstance
{
	BiomeType type;
	float size;
};

struct BiomeInterpolation
{
	BiomeType a;
	BiomeType b;
	float startTransitionY;
};

struct BiomeLine
{
	std::vector<int> startY;
	std::vector<BiomeInstance> biomes;
	std::unordered_map<BiomeType, std::vector<BiomeType>> transitionPaths;
	const float biomeTransition = 0.0f;
	std::unordered_map<BiomeType, BiomeSpawnData> spawner;
	BiomeInterpolation GetInterpolation(float y);
};

struct FoilageSpawner
{
	Ref<PackedScene> prefab;
	// terrain height range
	// frequency
	// grouping rules
	// biome mapping
};

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
	BiomeLine biomeLine;
	float cone_height;
	float hill_radius;
	// Multiplier of noise points in world space
	float density;
	float amplitude;
	int arcsPerRing;
	FastNoiseLite noiseGen;
	Ref<ShaderMaterial> terrain_material;
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
	int foilage_spawn_count = 0;
	std::vector<FoilageSpring> foilage_data;

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
	// float get_ground_pos(Vector3 pos);

	void set_seed(float p_seed);
};

}
