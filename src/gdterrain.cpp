#include "gdterrain.h"

#include <Mesh.hpp>
#include <Math.hpp>
#include <ResourceLoader.hpp>
#include <PhysicsServer.hpp>
#include <World.hpp>

#include "gdcrowdnav.h"

#include <stdlib.h>
#include <string>
#include <time.h>
#include <stdio.h>

using namespace godot;

void GDArcProcHill::_register_methods()
{
    register_method("_process", &GDArcProcHill::_process);
    register_method("_enter_tree", &GDArcProcHill::_enter_tree);
	register_property<GDArcProcHill, float>("amplitude", &GDArcProcHill::amplitude, 10.0f);
    // Not using this functionality for now
    // register_property<GDArcProcHill, int>("arcsPerRing", &GDArcProcHill::arcsPerRing, 12);
    register_property<GDArcProcHill, float>("Hill Radius", &GDArcProcHill::hill_radius, 50.0f);
    register_property<GDArcProcHill, float>("Spawn Distance", &GDArcProcHill::spawnDistance, 200.0f);
    register_property<GDArcProcHill, float>("Despawn Distance", &GDArcProcHill::despawnDistance, 300.0f);
}

void GDArcProcHill::_init()
{
    noiseGen = FastNoiseLite();
    srand(time(NULL));
    noiseGen.SetSeed(rand());
    noiseGen.SetNoiseType(FastNoiseLite::NoiseType::NoiseType_OpenSimplex2);
    noiseGen.SetFrequency(0.005f);
    // You need to initialize properties or the game will crash
    amplitude = 10.0f;
    hill_radius = 50.0f;
}

GDArcProcHill::GDArcProcHill()
{
}

GDArcProcHill::~GDArcProcHill()
{

}

void GDArcProcHill::create_arc(Vector3 pos, float degrees, float radius, float hole)
{
    auto vertices = PoolVector3Array();
    auto arr_mesh = gen_arc_mesh(pos, degrees, radius, hole, (size_t)degrees/6, vertices, (int)radius-hole);
    auto m = MeshInstance::_new();
    m->set_material_override(snowMaterial);
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
    auto arr_mesh = gen_y_arc_mesh(pos, degrees, radius, (size_t)degrees/6, vertices, 16);
    auto m = MeshInstance::_new();
    m->set_material_override(snowMaterial);
    m->set_mesh(arr_mesh);
    m->set_translation(pos);
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
    target = Object::cast_to<Spatial>(get_node("/root/nodes/gameplay/hill/banner"));
    auto res = ResourceLoader::get_singleton();
    snowMaterial = res->load("res://arc_test.tres");
    tree_prefab = res->load("res://tree.tscn");
    coin_prefab = res->load("res://coin.tscn");
    // TODO: just clone an arc prefab and add noise :) 
    create_arc(Vector3(0, 0, 0), 360.0f, hill_radius, 0.0f);
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
    std::vector<float> noises;
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
        float grav = radius/layers * layer;
        float x = x_circle * radius;
        float z = z_circle * radius;
        float y = -grav;
        float noise = noiseGen.GetNoise(pos.x + x, pos.y + y, pos.z + z);
        noises.push_back(noise);
        noise *= amplitude;
        float start = 1.0f - interp;
        Vector3 vert = Vector3(x + noise * x_circle, y, z + noise * z_circle);
        vertices.append(vert);
        // normals.append(Vector3(0, 1, 0));
        if (((int)(noise * 10000)) % 600 == 1)
        {
            Spatial* tree = Object::cast_to<Spatial>(tree_prefab->instance());
            tree->rotate_z(-Math_PI/2.0);
            tree->rotate_y(-radians);
            tree->set_translation(vert);
            float size = 1.0f + (1.0f + noise/amplitude) * 2.0f;
            // Random rotation
            // rotate_y(360.0f * static_cast <float> (rand()) / static_cast <float> (RAND_MAX));
            tree->set_scale(Vector3(size, size, size));
            Object::cast_to<GDBoidAffector>(tree->get_node("boid_repel"))->radius *= size;
            props.push_back(tree);
        }
            if (((int)(noise * 15000)) % 800 == 1)
        {
            Spatial* coin = Object::cast_to<Spatial>(coin_prefab->instance());
            coin->rotate_z(-Math_PI/2.0);
            coin->rotate_y(-radians);
            coin->set_translation(vert);
            props.push_back(coin);
        }
        arc_progress += degrees_per_quad;
        if (arc_progress > degrees) arc_progress = 0.0f;
    }
    for (size_t quad = 0; quad < quads * layers; quad++)
    {
        indices.append(quad + verts_per_layer);
        indices.append(quad + 1);
        indices.append(quad);
        // for (int i = 0; i < 3; i++)
        // {
        //     normals.append((vertices[quad + verts_per_layer] + vertices[quad + 1] + vertices[quad])/3.0f);
        // }

        indices.append(quad + verts_per_layer);
        indices.append(quad + 1 + verts_per_layer);
        indices.append(quad + 1);
        // for (int i = 0; i < 3; i++)
        // {
        //     normals.append((vertices[quad + verts_per_layer] + vertices[quad + 1 + verts_per_layer] + vertices[quad + 1])/3.0f);
        // }
    }
    for (size_t x = 0; x < indices.size(); x++)
    {
        faces.append(vertices[indices[x]]);
        float cell = (1.0f + noises[indices[x]])/2.0f;
        // TODO: Use the v parameter for a winding path free of obstacles!
        uvs.append(Vector2(cell, 0.0f));
    }
    arrays[ArrayMesh::ARRAY_VERTEX] = faces;
    // arrays[ArrayMesh::ARRAY_NORMAL] = normals;
    arrays[ArrayMesh::ARRAY_TEX_UV]= uvs;
    // arrays[ArrayMesh::ARRAY_INDEX] = indices;
    mesh->add_surface_from_arrays(Mesh::PRIMITIVE_TRIANGLES, arrays);
    return mesh;
}