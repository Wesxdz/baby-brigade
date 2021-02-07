#include "gdcrowdnav.h"

#include <PhysicsServer.hpp>
#include <World.hpp>
#include <PhysicsDirectSpaceState.hpp>

#include <algorithm>

using namespace godot;

void GDCrowdNav::_register_methods() 
{
    register_property<GDCrowdNav, float>("height", &GDCrowdNav::set_height, &GDCrowdNav::get_height, 20.0);
    register_property<GDCrowdNav, float>("fall_velocity", &GDCrowdNav::set_fall_velocity, &GDCrowdNav::get_fall_velocity, 0.0);
    register_property<GDCrowdNav, float>("fall_acceleration", &GDCrowdNav::fall_acceleration, -5.0f);
    register_property<GDCrowdNav, uint32_t>("layer", &GDCrowdNav::layer, 0, GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_FLAGS, "Baby, Obstacle, Item, Banner, Enemy");
    register_property<GDCrowdNav, int>("subgroup", &GDCrowdNav::subgroup, 0);

	register_method("_physics_process", &GDCrowdNav::_physics_process);
    register_method("_integrate_forces", &GDCrowdNav::_integrate_forces);
    register_method("_enter_tree", &GDCrowdNav::_enter_tree);
    register_method("_exit_tree", &GDCrowdNav::_enter_tree);

    register_signal<GDCrowdNav>((char *)"landed");
}

GDCrowdNav::GDCrowdNav() {}

GDCrowdNav::~GDCrowdNav() {}

void GDCrowdNav::set_fall_velocity(float v)
{
    fall_velocity = v;
}

float GDCrowdNav::get_fall_velocity()
{
    return fall_velocity;
}

void GDCrowdNav::set_height(float h)
{
    height = h;
}

float GDCrowdNav::get_height()
{
    return height;
}

void GDCrowdNav::_init() 
{
    height = 20.0f;
    fall_velocity = 0.0f;
    fall_acceleration = -5.0f;
    on_ground = height == 0;
    subgroup = 0;
}

void GDCrowdNav::_enter_tree()
{
    field = Object::cast_to<GDBoidField>(get_node("/root/nodes/gameplay/boid_field"));
    field->affected[get_rid()] = layer;
    field->subgroups[get_rid()] = subgroup;
    field->crowdAgents.push_back(get_rid());
}

void GDCrowdNav::_exit_tree()
{
    field = Object::cast_to<GDBoidField>(get_node("/root/nodes/gameplay/boid_field"));
    field->crowdAgents.erase(std::remove(field->crowdAgents.begin(), field->crowdAgents.end(), get_rid()), field->crowdAgents.end());
    field->affected.erase(get_rid());
    field->subgroups.erase(get_rid());
}

void GDCrowdNav::_physics_process(float delta)
{
    if (height > 0)
    {
        if (on_ground)
        {
            // leave ground
        }
        on_ground = false;
        fall_velocity += fall_acceleration * delta;
    } else
    {
        if (!on_ground)
        {
            emit_signal("landed");
        }
        on_ground = true;
        fall_velocity = 0.0f;
    }
    height = std::max(height + fall_velocity, 0.0f);
    
    if (field->accumulatedForces.count(get_rid()))
    {
        add_central_force(field->accumulatedForces[get_rid()] * delta);
    }
}

void GDCrowdNav::_integrate_forces(PhysicsDirectBodyState* state)
{
    // Spatial* banner = Object::cast_to<Spatial>(get_node("/root/nodes/gameplay/hill/banner"));
    Vector3 pos = state->get_transform().origin;
    Vector2 orbit = Vector2(pos.x, pos.z) + (Vector2(pos.x, pos.z).normalized() * 70.0f);
    Vector3 rotation(orbit.x, pos.y, orbit.y);
    look_at(Vector3(0.0f, 1.0f, 1.0f), rotation);
    int64_t terrainOnly = 0b00000001;
    // TODO: Physics Process ray intersections on hundreds of nodes is not scalable
    Dictionary ground = get_world()->get_direct_space_state()->intersect_ray(rotation, Vector3(0.0f, pos.y, 0.0f), Array(), terrainOnly);
    if (ground.size() > 0)
    {
        Vector3 groundPos = ground["position"];
        set_translation(Vector3(groundPos.x, pos.y, groundPos.z) + Vector3(orbit.normalized().x, 0.0f, orbit.normalized().y) * height);
        // Godot::print(std::to_string(yPos).c_str());
    }
    // set_rotation(banner->get_rotation());
}

void GDBoidAffector::set_behavior(int b)
{
    behavior = (Behavior)b;
}

int GDBoidAffector::get_behavior()
{
    return (int)behavior;
}

void GDBoidAffector::_register_methods()
{
    register_property<GDBoidAffector, float>("radius", &GDBoidAffector::radius, 10.0f);
    register_property<GDBoidAffector, float>("strength", &GDBoidAffector::strength, 1.0f);
    register_property<GDBoidAffector, Ref<Curve>>("curve", &GDBoidAffector::curve, Ref<Curve>());
    register_property<GDBoidAffector, NodePath>("body", &GDBoidAffector::bodyNode, NodePath());
    register_property<GDBoidAffector, int>("behavior", &GDBoidAffector::set_behavior, &GDBoidAffector::get_behavior, (int)GDBoidAffector::Behavior::Repel, GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_ENUM, "Attract, Repel");
    register_property<GDBoidAffector, uint32_t>("affect_layers", &GDBoidAffector::affect_layers, 0, GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_FLAGS, "Baby, Obstacle, Item, Banner, Enemy");
    register_property<GDBoidAffector, int>("subgroup", &GDBoidAffector::subgroup, 0);

    register_method("_enter_tree", &GDBoidAffector::_enter_tree);
    register_method("_exit_tree", &GDBoidAffector::_exit_tree);
}

void GDBoidAffector::_init()
{
    radius = 20.0f;
    strength = 1.0f;
    subgroup = 0;
}

GDBoidAffector::GDBoidAffector()
{
}

void GDBoidAffector::_enter_tree()
{
    field = Object::cast_to<GDBoidField>(get_node("/root/nodes/gameplay/boid_field"));
    field->boids.push_back(this);
    // if (!bodyNode.is_empty())
    // {
    //     body = Object::cast_to<RigidBody>(get_node(bodyNode))->get_rid();
    //     GDCrowdNav* crowdNav = Object::cast_to<GDCrowdNav>(get_node(bodyNode));
    //     if (crowdNav)
    //     {
    //         field->affected[body] = crowdNav->affected_by_layers;
    //     }
    //     // Godot::print(std::to_string(body.get_id()).c_str());
    // }
}

#include <algorithm>

void GDBoidAffector::_exit_tree()
{
    field->boids.erase(std::find(field->boids.begin(), field->boids.end(), this));
}

void GDBoidField::Step()
{
    accumulatedForces.clear();
    auto physics = PhysicsServer::get_singleton();
    for (size_t a = 0; a < crowdAgents.size(); a++)
    {
        RID agent = crowdAgents[a];
        PhysicsDirectBodyState* agentState = physics->body_get_direct_state(agent);
        for (size_t b = 0; b < boids.size(); b++) // TODO: Spatial partitioning
        {
            GDBoidAffector* boid = boids[b];
            Vector3 pos = boid->get_global_transform().origin;
            if (boid->body == agent) continue;
            if ((!(boid->affect_layers & affected[agent])) || (boid->subgroup != 0 && boid->subgroup != subgroups[agent])) continue;

            if (agentState)
            {
                Vector3 otherPos = agentState->get_transform().origin;
                Vector3 toAgent = otherPos - pos;
                float t = toAgent.length()/boid->radius;
                if (t <= 1.0f)
                {
                    accumulatedForces[agent] += toAgent * boid->curve.ptr()->interpolate(1.0f - t) * boid->strength * (boid->behavior == GDBoidAffector::Behavior::Attract ? -1.0f : 1.0f);
                }
            }
        }
    }
}

void GDBoidField::_register_methods()
{
    register_method("_physics_process", &GDBoidField::_physics_process);
}

void GDBoidField::_init()
{

}

void GDBoidField::_physics_process(float delta)
{
    Step();
}