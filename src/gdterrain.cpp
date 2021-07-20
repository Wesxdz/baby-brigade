#include "gdterrain.h"

#include <Mesh.hpp>
#include <Math.hpp>
#include <ResourceLoader.hpp>
#include <PhysicsServer.hpp>
#include <World.hpp>
#include <MultiMesh.hpp>
#include <MultiMeshInstance.hpp>

#include "gdcrowdnav.h"
#include "gdbanner.h"

#include <stdlib.h>
#include <string>
#include <time.h>
#include <stdio.h>
#include <algorithm>
#include <random>

using namespace godot;

void GDArcProcHill::_register_methods()
{
    register_method("_process", &GDArcProcHill::_process);
    register_method("_enter_tree", &GDArcProcHill::_enter_tree);
	register_property<GDArcProcHill, float>("amplitude", &GDArcProcHill::amplitude, 10.0f);
    register_property<GDArcProcHill, int>("Chunk Sections", &GDArcProcHill::chunk_sections, 4);
    // Not using this functionality for now
    // register_property<GDArcProcHill, int>("arcsPerRing", &GDArcProcHill::arcsPerRing, 12);
    register_property<GDArcProcHill, float>("Hill Radius", &GDArcProcHill::hill_radius, 50.0f);
    register_property<GDArcProcHill, float>("Spawn Distance", &GDArcProcHill::spawnDistance, 200.0f);
    register_property<GDArcProcHill, float>("Despawn Distance", &GDArcProcHill::despawnDistance, 300.0f);
}

void GDArcProcHill::_init()
{
    // You need to initialize properties or the game will crash
    amplitude = 10.0f;
    hill_radius = 50.0f;
}

GDArcProcHill::GDArcProcHill()
{
    auto res = ResourceLoader::get_singleton();
    biomeLine.spawner[GRASSLANDS] = {200.0f, 500.0f, 700.0f, 
    Color(0.3, 1.0, 0.96, 1), res->load("res://grasslands_palette.png")};
    biomeLine.spawner[TUNDRA] = {300.0f, 400.0f, 600.0f, 
    Color(0.3, 1.0, 0.96, 1), res->load("res://tundra_palette.png"), {{res->load("res://tree.tscn"), 0.1f}}};
    biomeLine.spawner[DESERT] = {400.0f, 600.0f, 800.0f, 
    Color(0.3, 1.0, 0.96, 1), res->load("res://desert_palette.png"), {{res->load("res://cactus.tscn"), 0.02f}}};
    biomeLine.transitionPaths[GRASSLANDS] = {TUNDRA, DESERT};
    biomeLine.transitionPaths[TUNDRA] = {GRASSLANDS};
    biomeLine.transitionPaths[DESERT] = {GRASSLANDS};
    biomeLine.biomes.push_back({GRASSLANDS, 500});
    biomeLine.startY.push_back(0.0f);
    biomeLine.startY.push_back(-500.0f - biomeLine.biomeTransition);

    tree_prefab = res->load("res://tree.tscn");

    srand(time(NULL));
    noiseGen.SetSeed(rand());
    noiseGen.SetNoiseType(FastNoiseLite::NoiseType::NoiseType_OpenSimplex2);
    noiseGen.SetFrequency(0.005f);

    for (size_t i = 0; i < 8; i++)
    {
        foilageGen[i].SetSeed(rand());
        noiseGen.SetNoiseType(FastNoiseLite::NoiseType::NoiseType_OpenSimplex2);
        noiseGen.SetFrequency(0.005f);
    }
    
    foilageEdgeGen.SetSeed(rand());
    foilageEdgeGen.SetNoiseType(FastNoiseLite::NoiseType::NoiseType_Value);
    foilageEdgeGen.SetFrequency(0.01f);
}

BiomeInterpolation BiomeLine::GetInterpolation(float y)
{
    while (y < startY[startY.size() - 1])
    {
        Godot::print("Create new biome!");
        BiomeInstance currentBiome = biomes[biomes.size() - 1];
        BiomeInstance nextBiome;
        nextBiome.type = transitionPaths[currentBiome.type][rand()%transitionPaths[currentBiome.type].size()];
        BiomeSpawnData data = spawner[nextBiome.type];
        std::default_random_engine gen;
        std::normal_distribution<float> dist(data.averageSize);
        nextBiome.size = std::min(std::max(data.minSize, dist(gen)), data.maxSize);
        biomes.push_back(nextBiome);
        startY.push_back(startY[startY.size() - 1] - nextBiome.size - biomeTransition);
    }
    BiomeInterpolation bi;
    bi.startTransitionY = 0.0f;
    bi.b = biomes[biomes.size() - 1].type;
    if (biomes.size() == 1)
    {
        bi.a = biomes[biomes.size() - 1].type;
    } 
    else
    {
        size_t closestTransitionIndex = 0;
        for (size_t i = startY.size() - 1; i >= 0; i--)
        {
            if (y < startY[i])
            {
                closestTransitionIndex = i;
                break;
            }
        }
        bool isInTransitionZone = closestTransitionIndex > 0 && std::abs(y - startY[closestTransitionIndex]) > biomes[closestTransitionIndex].size;
        if (isInTransitionZone)
        {
            bi.startTransitionY = startY[closestTransitionIndex] + biomeTransition;
            // bi.interp = (std::abs(y - startY[closestTransitionIndex]) - biomes[closestTransitionIndex].size)/biomeTransition;
            // Godot::print(std::to_string(bi.startTransitionY).c_str());
        }
        bi.a = biomes[biomes.size() - 2].type;
    }
    return bi;
}

GDArcProcHill::~GDArcProcHill()
{

}

void GDArcProcHill::create_arc(Vector3 pos, float degrees, float radius, float hole)
{
    auto vertices = PoolVector3Array();
    auto arr_mesh = gen_arc_mesh(pos, degrees, radius, hole, (size_t)degrees/6, vertices, (int)radius-hole);
    auto m = MeshInstance::_new();
    // TODO: Refactor redundant code with create_y_arc to procedures
    BiomeInterpolation bi = biomeLine.GetInterpolation(pos.y);
    terrain_material->set_shader_param("ramp_start", biomeLine.spawner[bi.a].palette);
    terrain_material->set_shader_param("ramp_end", biomeLine.spawner[bi.b].palette);
    // terrain_material->set_shader_param("startTransitionY", bi.startTransitionY);
    m->set_material_override(terrain_material->duplicate());
    m->set_cast_shadows_setting(0);
    m->set_mesh(arr_mesh);
    auto physics = PhysicsServer::get_singleton();
    RID body = physics->body_create(PhysicsServer::BODY_MODE_STATIC);
    physics->body_set_space(body, get_world()->get_space());
    physics->body_set_collision_layer(body, 1);
    RID poly = physics->shape_create(PhysicsServer::SHAPE_CONCAVE_POLYGON);
    physics->shape_set_data(poly, vertices);
    physics->body_add_shape(body, poly);
    add_child(m);
    arcs.push_back({m, body, pos});
}

void GDArcProcHill::create_y_arc(Vector3 pos, float degrees, float radius)
{
    auto vertices = PoolVector3Array();
    size_t quads = (size_t)degrees/6;
    if (arc_section % chunk_sections == 0)
    {
        // active_rotation = std::round(rand() * quads) * (360.0f/quads);
        // active_rotation = (M_PI * 2)/quads * (arc_section/chunk_sections);
    }
    auto arr_mesh = gen_y_arc_mesh(pos, degrees, radius, quads, vertices, 1);
    auto m = MeshInstance::_new();
    // BiomeInterpolation bi = biomeLine.GetInterpolation(pos.y);
    // terrain_material->set_shader_param("ramp_start", biomeLine.spawner[bi.a].palette);
    // terrain_material->set_shader_param("ramp_end", biomeLine.spawner[bi.b].palette);
    // terrain_material->set_shader_param("startTransitionY", bi.startTransitionY);
    m->set_material_override(terrain_material->duplicate());
    m->set_mesh(arr_mesh);
    m->set_translation(pos);
    m->rotate_y(active_rotation);
    auto physics = PhysicsServer::get_singleton();
    RID body = physics->body_create(PhysicsServer::BODY_MODE_STATIC);
    physics->body_set_space(body, get_world()->get_space());
    physics->body_set_collision_layer(body, 1);
    RID poly = physics->shape_create(PhysicsServer::SHAPE_CONCAVE_POLYGON);
    physics->shape_set_data(poly, vertices);
    physics->body_add_shape(body, poly);
    physics->body_set_shape_transform(body, 0, Transform(Basis(), pos));
    add_child(m);
    for (Spatial* prop : props)
    {
        m->add_child(prop);
    }
    props.clear();
    arcs.push_back({m, body, pos});
}

void GDArcProcHill::_enter_tree()
{
    MultiMeshInstance* foilage = Object::cast_to<MultiMeshInstance>(get_node("/root/nodes/gameplay/hill/terrain/foilage"));
    Ref<MultiMesh> mm = foilage->get_multimesh();
    foilage_data.resize(mm->get_instance_count());

    target = Object::cast_to<Spatial>(get_node("/root/nodes/gameplay/hill/banner"));
    auto res = ResourceLoader::get_singleton();
    terrain_material = res->load("res://arc_terrain.tres");
    // terrain_material->set_shader_param("ramp_start", biomes[GRASSLANDS].palette);
    // terrain_material->set_shader_param("ramp_end", biomes[GRASSLANDS].palette);
    demon_prefab = res->load("res://demon.tscn");
    enemy_banner_prefab = res->load("res://enemy_banner.tscn");
    // TODO: just clone an arc prefab and add noise :) 
    create_arc(Vector3(0.0f, 0.0f, 0.0f), 360.0f, hill_radius, 0.0f);
}

void GDArcProcHill::_process(float delta)
{
    Node* node = get_node_or_null("/root/nodes/gameplay/hill/banner");
    if (node)
    {
        if (arcs.front().pos.distance_to(target->get_translation()) > despawnDistance)
        {
            remove_child(arcs.front().mesh);
            PhysicsServer::get_singleton()->free_rid(arcs.front().body);
            arcs.pop_front();
        }
        if (abs(abs(target->get_translation().y) - abs(nextArcY)) < spawnDistance)
        {
            
            create_y_arc(Vector3(0.0, nextArcY, 0.0), 360.0f, hill_radius);
            nextArcY -= 16.0f;
            arc_section++;
        }

    }
}


void GDArcProcHill::set_seed(float p_seed)
{
    noiseGen.SetSeed(p_seed);
}

ArrayMesh* GDArcProcHill::gen_arc_mesh(Vector3 pos, float degrees, float radius, float hole, size_t quads, PoolVector3Array& faces, int layers)
{
    ArrayMesh* mesh = ArrayMesh::_new();
    Array arrays = Array();
    arrays.resize(ArrayMesh::ARRAY_MAX);
    size_t verts_per_layer = (quads+1);
    size_t vertex_count = verts_per_layer * (layers+1);
    auto vertices = PoolVector3Array();
    auto normals = PoolVector3Array();
    auto indices = PoolIntArray();
    float outline = radius - hole;
    float degrees_per_quad = degrees/quads;
    float arc_progress = 0.0f;
    for (size_t v = 0; v < vertex_count; v++)
    {
        float radians = Math::deg2rad(arc_progress);
        float x_circle = cos(radians);
        float z_circle = sin(radians);
        int layer = v/verts_per_layer;
        float interp = 1.0f - (layer/layers);
        float grav = outline/layers * layer;
        float x = x_circle * (radius - grav);
        float z = z_circle * (radius - grav);
        float y = -sqrt(pow(abs(x), 2) + pow(abs(z), 2));
        float noise = noiseGen.GetNoise(pos.x + x, pos.y + y, pos.z + z);
        noise *= amplitude;
        float start = 1.0f - interp;
        vertices.append(pos + Vector3(x + (x_circle * noise * interp), y, z + (z_circle * noise * interp)));
        normals.append(Vector3(0, 1, 0));
        arc_progress += degrees_per_quad;
        if (arc_progress > degrees) arc_progress = 0.0f;
    }
    for (size_t quad = 0; quad < quads * layers; quad++)
    {
        indices.append(quad);
        indices.append(quad + 1);
        indices.append(quad + verts_per_layer);

        indices.append(quad + 1);
        indices.append(quad + 1 + verts_per_layer);
        indices.append(quad + verts_per_layer);
    }
    for (size_t x = 0; x < indices.size(); x++)
    {
        faces.append(vertices[indices[x]]);
    }
    arrays[ArrayMesh::ARRAY_VERTEX] = vertices;
    arrays[ArrayMesh::ARRAY_NORMAL] = normals;
    arrays[ArrayMesh::ARRAY_INDEX] = indices;
    mesh->add_surface_from_arrays(Mesh::PRIMITIVE_TRIANGLES, arrays);
    return mesh;
}

ArrayMesh* GDArcProcHill::gen_y_arc_mesh(Vector3 pos, float degrees, float radius, size_t quads, PoolVector3Array& faces, int layers)
{
    ArrayMesh* mesh = ArrayMesh::_new();
    Array arrays = Array();
    arrays.resize(ArrayMesh::ARRAY_MAX);
    size_t verts_per_layer = (quads+1);
    size_t vertex_count = verts_per_layer * (layers+1);
    auto vertices = PoolVector3Array();
    auto normals = PoolVector3Array();
    auto uvs = PoolVector2Array();
    auto uv2 = PoolVector2Array();
    std::vector<float> noises;
    std::vector<float> noises_above;
    std::vector<float> noises_below;
    auto indices = PoolIntArray();
    float degrees_per_quad = degrees/quads;
    float arc_progress = 0.0f;
    for (size_t v = 0; v < vertex_count; v++)
    {
        float radians = Math::deg2rad(arc_progress);
        float x_circle = cos(radians);
        float z_circle = sin(radians);
        int layer = v/verts_per_layer;
        float interp = 1.0f - (layer/layers);
        float x = x_circle * radius;
        float z = z_circle * radius;
        float y = -16.0f * layer;
        Vector3 noisePos = Vector3(pos.x + x, pos.y + y, pos.z + z);
        float noise = noiseGen.GetNoise(noisePos.x, noisePos.y, noisePos.z);
        noises.push_back(noise);
        noises_above.push_back(noiseGen.GetNoise(noisePos.x, noisePos.y + 16, noisePos.z)); // TODO: Optimize by quad and precalc?
        noises_below.push_back(noiseGen.GetNoise(noisePos.x, noisePos.y - 16, noisePos.z));
        noise *= amplitude;
        float start = 1.0f - interp;
        Vector3 vert = Vector3(x + noise * x_circle, y, z + noise * z_circle);
        vertices.append(vert);
        // normals.append(Vector3(0, 1, 0));
        // if (((int)(noise * 10000)) % 600 == 1)
        // {
        //     Spatial* tree = Object::cast_to<Spatial>(tree_prefab->instance());
        //     tree->rotate_z(-Math_PI/2.0);
        //     tree->rotate_y(-radians);
        //     tree->set_translation(vert);
        //     float size = 1.0f + (1.0f + noise/amplitude) * 2.0f;
        //     // Random rotation
        //     // tree->rotate_y(360.0f * static_cast <float> (rand()) / static_cast <float> (RAND_MAX));
        //     tree->set_scale(Vector3(size, size, size));
        //     Object::cast_to<GDBoidAffector>(tree->get_node("boid_repel"))->radius *= size;
        //     props.push_back(tree);
        // }
        //     if (((int)(noise * 15000)) % 800 == 1)
        // {
        //     Spatial* coin = Object::cast_to<Spatial>(coin_prefab->instance());
        //     coin->rotate_z(-Math_PI/2.0);
        //     coin->rotate_y(-radians);
        //     coin->set_translation(vert);
        //     props.push_back(coin);
        // }
        if (v > verts_per_layer && noise > 0.5) // ((int)(noise * 1.0)) % 100 == 0
        {
            int flower = -1;
            for (size_t i = 0; i < 8; i++)
            {
                if (foilageGen[i].GetNoise(noisePos.x, noisePos.y, noisePos.z) + foilageEdgeGen.GetNoise(noisePos.x, noisePos.y, noisePos.z) > 0.8f)
                {
                    flower = i;
                    break;
                }
            }
            if (flower >= 0)
            {
                auto spawn = Transform(Basis(), Vector3());
                spawn.rotate(Vector3(1.0, 0, 0), Math_PI/2.0 + .3 - (rand() % 100 * 0.006)); //
                spawn.rotate(Vector3(0.0, 1.0, 0.0), active_rotation + -radians + Math_PI/2.0 + .3 - (rand() % 100 * 0.006)); //
                
                spawn.origin = pos + vert; // 16.0 * Vector3(vert.x, 0.0, vert.z).normalized()
                // TODO: Offset randomly from vert
                MultiMeshInstance* foilage = Object::cast_to<MultiMeshInstance>(get_node("/root/nodes/gameplay/hill/terrain/foilage"));
                Ref<MultiMesh> mm = foilage->get_multimesh();
                mm->set_visible_instance_count(foilage_spawn_count);
                int index = foilage_spawn_count % mm->get_instance_count();
                mm->set_instance_transform(index, spawn);
                // TODO: Only simulate foilage data for quads that are visible and affected by forces
                foilage_data[index] = {spawn.origin, Vector3(spawn.origin.x, 0.0, spawn.origin.z).normalized(), Quat(), Math_PI/2.0, 1.0, 0.0f};
                mm->set_instance_custom_data(index, Color((flower/8.0f), (float)rand()/RAND_MAX, 0));
                foilage_spawn_count++;
            }
            // TODO: Despawn!
            
            if (noise > 0.9 && foilageGen[0].GetNoise(noisePos.x, noisePos.y, noisePos.z) > 0.8f && ((int)(noise * 10))%4 == 0)
            {
                Spatial* tree = Object::cast_to<Spatial>(tree_prefab->instance());
                auto spawn = Transform(Basis(), Vector3());
                spawn.rotate(Vector3(1.0, 0, 0), Math_PI/2.0); //  + .3 - (rand() % 100 * 0.006)
                spawn.rotate(Vector3(0.0, 1.0, 0.0), -radians + Math_PI/2.0); // + .3 - (rand() % 100 * 0.006)) 
                spawn.origin = vert;
                tree->set_transform(spawn);
                // tree->translate(vert);
                // tree->look_at(tree->get_global_transform().origin + Vector3(0.0, -1.0, 0.0), Vector3(vert.x, 0.0, vert.z));
                // tree->get_transform().set_look_at(Vector3(0, 0, 0), Vector3(0, -100.0, 0), Vector3(vert.x, 0.0, vert.z));
                props.push_back(tree);
            }
        }
        // if (((int)(noise * 15000)) % 800 == 1)
        // {
        //     Spatial* coin = Object::cast_to<Spatial>(coin_prefab->instance());
        //     coin->rotate_z(-Math_PI/2.0);
        //     coin->rotate_y(-radians);
        //     coin->set_translation(vert);
        //     props.push_back(coin);
        // }
        // Temp disable enemy spawning for testing terrain
        // if (((int)(noise * 15000)) % 2400 == 1)
        // {
        //     Vector3 spawnPoint = pos + vert;
        //     GDBanner* banner = Object::cast_to<GDBanner>(enemy_banner_prefab->instance());
        //     banner->yPos = spawnPoint.y;
        //     banner->angle = radians;
        //     banner->set_translation(spawnPoint);
        //     banner->set_rotate_speed((rand())/((float)(RAND_MAX/2.0f)) - 1.0f);
        //     banner->set_y_speed((rand())/((float)(RAND_MAX/10.0f)) + 5.0f);
        //     GDBoidAffector* affector = Object::cast_to<GDBoidAffector>(banner->get_child(0));
        //     affector->subgroup = enemySpawnGroup;
        //     get_node("/root/nodes/gameplay/hill")->add_child(banner);
        //     for (int n = 0; n < std::max(1, (int)(-spawnPoint.y/1000 + (rand()/((float)(RAND_MAX/3.0f)) - 2.0))); n++)
        //     {
        //         GDCrowdNav* demon = Object::cast_to<GDCrowdNav>(demon_prefab->instance());
        //         // demon->rotate_z(-Math_PI/2.0);
        //         // demon->rotate_y(-radians);
        //         demon->set_translation(spawnPoint + Vector3(0, n, 0));
        //         demon->subgroup = enemySpawnGroup;
        //         get_node("/root/nodes/gameplay/hill")->add_child(demon);
        //         banner->connect("despawn_banner", demon->get_node("resolver"), "despawn");
        //         banner->followers++;
        //         demon->get_node("resolver")->connect("despawn", banner, "lose_follower");
        //     }
        //     enemySpawnGroup++;
        // }
        arc_progress += degrees_per_quad;
        if (arc_progress > degrees) arc_progress = 0.0f;
    }
    std::vector<float> cells;
    std::vector<float> cells_above;
    std::vector<float> cells_below;
    for (size_t quad = 0; quad < quads * layers; quad++)
    {
        // int layer = quad/quads;
        // float progress = (float)layer/layers;
        // float inc = 1.0f/layers;
        float progress = 0.0f;
        float inc = 1.0;
        int tiles = 1;
        float tile_uv = 1.0/tiles;
        // float tile = (rand() % tiles)/((float)tiles);
        float tile = 0.0f;
        indices.append(quad + verts_per_layer);
        uv2.append({progress, tile + tile_uv});
        indices.append(quad + 1);
        uv2.append({progress + inc, tile});
        indices.append(quad);
        uv2.append({progress, tile});
        indices.append(quad + verts_per_layer);
        uv2.append({progress, tile + tile_uv});
        indices.append(quad + 1 + verts_per_layer);
        uv2.append({progress + inc, tile + tile_uv});
        indices.append(quad + 1);
        uv2.append({progress + inc, tile});
        float avgAboveCell = 0.0f;
        float avgCell = 0.0f;
        float avgBelowCell = 0.0f;
        for (size_t x = 0; x < 6; x++)
        {
            avgAboveCell += (1.0f + noises_above[indices[indices.size() - 1 - x]])/2.0f;
            avgBelowCell += (1.0f + noises_below[indices[indices.size() - 1 - x]])/2.0f;
            avgCell += (1.0f + noises[indices[indices.size() - 1 - x]])/2.0f;
        }
        avgCell /= 6;
        avgAboveCell /= 6;
        avgBelowCell /= 6;
        cells.push_back(avgCell);
        cells_above.push_back(avgAboveCell);
        cells_below.push_back(avgBelowCell);
    }
    for (size_t x = 0; x < indices.size(); x++)
    {
        faces.append(vertices[indices[x]]);
        // float cell = (1.0f + noises[indices[x]])/2.0f;
        float cell = cells[x/6];
        auto IsDirt = [](float cell)
        {
            return cell < 0.5f;
        };
        float adjacent = 0;
        if (IsDirt(cell))
        {
            adjacent = 16.0f;
        }
        else
        {
            // dirt above +1 dirt right +2 dirt below +4 dirt left +8
            adjacent += IsDirt(cells_above[x/6]) * 1.0f;
            int right = (x + 6)/6;
            if (right >= cells.size()) right = 0;
            adjacent += IsDirt(cells[right]) * 2.0f;
            adjacent += IsDirt(cells_below[x/6]) * 4.0f;
            int left = (x - 6)/6;
            if (left < 0) left = cells.size() - 1;
            adjacent += IsDirt(cells[left]) * 8.0f;
            // Render as full or partial grass depending on adjacent tiles
        }
        adjacent/=16.0f;
        // TODO: Use the v parameter for a winding path free of obstacles!
        uvs.append(Vector2(adjacent, 0.0f));
    }
    arrays[ArrayMesh::ARRAY_VERTEX] = faces;
    // arrays[ArrayMesh::ARRAY_NORMAL] = normals;
    arrays[ArrayMesh::ARRAY_TEX_UV]= uvs;
    arrays[ArrayMesh::ARRAY_TEX_UV2] = uv2;
    // arrays[ArrayMesh::ARRAY_INDEX] = indices;
    mesh->add_surface_from_arrays(Mesh::PRIMITIVE_TRIANGLES, arrays);
    return mesh;
}

Vector3 GDArcProcHill::get_ground_pos(Vector3 pos)
{
    float radians = atan2(-pos.z, pos.x);
    float x_circle = cos(radians);
    float z_circle = sin(radians);
    float noise = noiseGen.GetNoise(x_circle * hill_radius, pos.y, z_circle * hill_radius);
    return Vector3(x_circle * hill_radius + noise * amplitude, pos.y, z_circle * hill_radius + noise * amplitude);
}