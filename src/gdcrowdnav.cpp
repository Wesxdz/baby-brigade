#include "gdcrowdnav.h"

#include <PhysicsServer.hpp>
#include <World.hpp>
#include <PhysicsDirectSpaceState.hpp>

using namespace godot;

void GDCrowdNav::_register_methods() 
{
	register_method("_physics_process", &GDCrowdNav::_physics_process);
    register_method("_integrate_forces", &GDCrowdNav::_integrate_forces);
    register_method("_enter_tree", &GDCrowdNav::_enter_tree);
}

GDCrowdNav::GDCrowdNav() {}

GDCrowdNav::~GDCrowdNav() {}

void GDCrowdNav::_init() 
{
}

void GDCrowdNav::_enter_tree()
{
    field = Object::cast_to<GDBoidField>(get_node("/root/nodes/gameplay/boid_field"));
}

void GDCrowdNav::_physics_process(float delta)
{
    Spatial* banner = Object::cast_to<Spatial>(get_node("/root/nodes/gameplay/hill/banner"));
    target = banner->get_global_transform().origin;
    Vector3 toTarget = target - get_global_transform().origin;
    // add_central_force(toTarget.normalized() * delta * 5000.0f);
    if (field->accumulatedForces.count(get_rid()))
    {
        add_central_force(field->accumulatedForces[get_rid()] * delta);
    }
    // set_rotation(banner->get_rotation());
    // Godot::print(std::to_string(toTarget.y).c_str());
}

void GDCrowdNav::_integrate_forces(PhysicsDirectBodyState* state)
{
    Spatial* banner = Object::cast_to<Spatial>(get_node("/root/nodes/gameplay/hill/banner"));
    Vector3 pos = state->get_transform().origin;
    Vector2 orbit = Vector2(pos.x, pos.z).normalized() * 70.0f;
    Vector3 rotation(orbit.x, pos.y, orbit.y);
    int64_t terrainOnly = 0b00000001;
    Dictionary ground = get_world()->get_direct_space_state()->intersect_ray(rotation, Vector3(0.0f, pos.y, 0.0f), Array(), terrainOnly);
    if (ground.size() > 0)
    {
        Vector3 groundPos = ground["position"];
        set_translation(Vector3(groundPos.x, pos.y, groundPos.z));
        // Godot::print(std::to_string(yPos).c_str());
    }
    set_rotation(banner->get_rotation());
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

    register_method("_enter_tree", &GDBoidAffector::_enter_tree);
    register_method("_exit_tree", &GDBoidAffector::_exit_tree);
}

void GDBoidAffector::_init()
{
    radius = 20.0f;
    strength = 1.0f;
}

GDBoidAffector::GDBoidAffector()
{
}

void GDBoidAffector::_enter_tree()
{
    field = Object::cast_to<GDBoidField>(get_node("/root/nodes/gameplay/boid_field"));
    field->boids.push_back(this);
    if (!bodyNode.is_empty())
    {
        body = Object::cast_to<RigidBody>(get_node(bodyNode))->get_rid();
    }
}

#include <algorithm>

void GDBoidAffector::_exit_tree()
{
    field->boids.erase(std::find(field->boids.begin(), field->boids.end(), this));
}

void GDBoidField::Step()
{
    accumulatedForces.clear();
    for (GDBoidAffector* boid : boids)
    {
        auto physics = PhysicsServer::get_singleton();
        if (boid->bodyNode.is_empty() || physics->body_get_mode(boid->body) != PhysicsServer::BodyMode::BODY_MODE_RIGID) return;
        Vector3 pos = boid->get_global_transform().origin;
        for (GDBoidAffector* other : boids) // TODO: Spatial partitioning
        {
            if (boid == other) continue;
            Vector3 otherPos = other->get_global_transform().origin;
            Vector3 toOther = otherPos - pos;
            float t = toOther.length()/other->radius;
            if (t <= 1.0f)
            {
                accumulatedForces[boid->body] += toOther * other->curve.ptr()->interpolate(1.0f - t) * other->strength * (other->behavior == GDBoidAffector::Behavior::Attract ? 1.0f : -1.0f);
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