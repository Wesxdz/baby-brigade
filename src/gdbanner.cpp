#include "gdbanner.h"

#include <Input.hpp>
#include <InputEvent.hpp>
#include <InputEventScreenTouch.hpp>
#include <InputEventScreenDrag.hpp>
#include <PhysicsServer.hpp>
#include <World.hpp>
#include <PhysicsDirectSpaceState.hpp>
#include <Dictionary.hpp>
#include <ResourceLoader.hpp>
#include <PackedScene.hpp>

using namespace godot;

void GDBanner::_register_methods() 
{
    register_method("_input", &GDBanner::_input);
    register_method("_enter_tree", &GDBanner::_enter_tree);
    register_method("_process", &GDBanner::_process);
    register_method("_physics_process", &GDBanner::_physics_process);

    register_property<GDBanner, float>("Angle", &GDBanner::angle, 0.0f);
    register_property<GDBanner, float>("Drag X To Angle", &GDBanner::dragXToAngle, 0.1f);
    register_property<GDBanner, float>("Turn Rate", &GDBanner::turnRate, 1.0f);
    register_property<GDBanner, float>("Y Speed", &GDBanner::ySpeed, -1.0f);
    register_property<GDBanner, float>("Meter Conversion", &GDBanner::meterConversion, 0.1f);
}

GDBanner::GDBanner()
{
}

GDBanner::~GDBanner() 
{
}

void GDBanner::_init() 
{
    yPos = get_translation().y;
    radius = 70.0f;

    meterConversion = 0.05f;

    Ref<PackedScene> puppet = ResourceLoader::get_singleton()->load("res://player_banner.tscn");
    add_child(puppet->instance());

    // properties
    // angle = 0.0f;
    // dragXToAngle = 0.0f;
    // ySpeed = 0.0f;
}

void GDBanner::_enter_tree()
{
    distanceLabel = Object::cast_to<RichTextLabel>(get_node("/root/nodes/box/ui/hud/distance"));
}

void GDBanner::_process(float delta) 
{
    Input* input = Input::get_singleton();
    angle += delta * turnRate * (input->get_action_strength("turn_right") - input->get_action_strength("turn_left"));
    distanceLabel->set_text(godot::String::num_int64((int64_t)(std::abs(get_translation().y) * meterConversion)));
    // distanceLabel->set_text(std::to_string(floor(std::abs(get_translation().y) * meterConversion)).c_str());
}

void GDBanner::_physics_process(float delta)
{
    yPos += ySpeed * delta;
    Vector3 rotation = Vector3(radius * cos(angle), yPos, radius * sin(angle));
    look_at(Vector3(0.0f, 1.0f, 1.0f), rotation);
    int64_t terrainOnly = 0b00000001;
    Dictionary ground = get_world()->get_direct_space_state()->intersect_ray(rotation, Vector3(0.0f, yPos, 0.0f), Array(), terrainOnly);
    if (ground.size() > 0)
    {
        set_translation(ground["position"]);
        // Godot::print(std::to_string(yPos).c_str());
    }
}

void GDBanner::_input(InputEvent* event)
{
    auto dragTouch = Object::cast_to<InputEventScreenDrag>(event);
    if (dragTouch)
    {
        angle += dragTouch->get_relative().x * dragXToAngle;
    }
}