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
#include <OS.hpp>

#include "gdterrain.h"

using namespace godot;

float GDBanner::get_y_pos()
{
    return yPos;
}

float GDBanner::get_radius()
{
    return radius;
}

float GDBanner::get_angle()
{
    return angle;
}

void GDBanner::_register_methods() 
{
    register_method("_enter_tree", &GDBanner::_enter_tree);
    register_method("_exit_tree", &GDBanner::_exit_tree);
    register_method("_physics_process", &GDBanner::_physics_process);
    
    register_method("get_y_pos", &GDBanner::get_y_pos);
    register_method("get_angle", &GDBanner::get_angle);
    register_method("get_radius", &GDBanner::get_radius);
    register_method("lose_follower", &GDBanner::lose_follower);

    register_property<GDBanner, float>("Y Speed", &GDBanner::set_y_speed, &GDBanner::get_y_speed, 0.0f);
    register_property<GDBanner, float>("Rotate Speed", &GDBanner::set_rotate_speed, &GDBanner::get_rotate_speed, 0.0f);

    register_property<GDBanner, float>("Meter Conversion", &GDBanner::meterConversion, 0.1f);
    register_signal<GDBanner>("despawn_banner");
}

void GDBanner::set_y_speed(float s)
{
    ySpeed = s;
}

float GDBanner::get_y_speed()
{
    return ySpeed;
}

void GDBanner::set_rotate_speed(float s)
{
    rotateSpeed = s;
}

float GDBanner::get_rotate_speed()
{
    return rotateSpeed;
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
    radius = 200.0f;

    formationRadius = 10.0f;

    meterConversion = 0.05f;

    // properties
    angle = 0.0f;
    ySpeed = 0.0f;
    rotateSpeed = 0.0f;
}

void GDBanner::_enter_tree()
{
    // distanceLabel = Object::cast_to<RichTextLabel>(get_node("/root/nodes/hud/distance"));
}

void GDBanner::despawn()
{
    emit_signal("despawn_banner");
}

void GDBanner::lose_follower()
{
    followers--;
    if (followers == 0)
    {
        Godot::print("Spawn loot!");
    }
}

void GDBanner::_exit_tree()
{
    despawn();
}

void GDBanner::_physics_process(float delta)
{
    // Godot::print(std::string("Banner!").c_str());
    yPos += ySpeed * delta;
    angle += rotateSpeed * delta;
    Vector3 rotation = Vector3(radius * cos(angle), yPos, radius * sin(angle));
    look_at(Vector3(0.0f, 1.0f, 1.0f), rotation);

    auto terrain = Object::cast_to<GDArcProcHill>(get_node("/root/nodes/gameplay/hill/terrain"));
    Vector3 origin = get_global_transform().origin;
    // set_translation(terrain->get_ground_pos(rotation);

    int64_t terrainOnly = 0b00000001;
    Dictionary ground = get_world()->get_direct_space_state()->intersect_ray(rotation, Vector3(0.0f, yPos, 0.0f), Array(), terrainOnly);
    if (ground.size() > 0)
    {
        set_translation(ground["position"]);
        // Godot::print(std::to_string(yPos).c_str());
    }
}

void GDTwistController::_register_methods()
{
    register_property<GDTwistController, NodePath>("Banner Path", &GDTwistController::bannerPath, NodePath());
    register_method("set_spin_enabled", &GDTwistController::set_spin_enabled);
    register_property<GDTwistController, float>("Drag X To Angle", &GDTwistController::dragXToAngle, 0.1f);
    register_property<GDTwistController, float>("Turn Rate", &GDTwistController::turnRate, 1.0f);

    register_method("_input", &GDTwistController::_input);
    register_method("_process", &GDTwistController::_process);
    register_method("_enter_tree", &GDTwistController::_enter_tree);
}

void GDTwistController::_init()
{
    spinEnabled = true;
    dragXToAngle = 0.0f;
}

void GDTwistController::set_spin_enabled(bool enabled)
{
    spinEnabled = enabled;
}

void GDTwistController::_enter_tree()
{
    Rect2 safe = OS::get_singleton()->get_window_safe_area();
    dragXToAngle = (Math_PI * 1.5)/safe.size.width;
    banner = Object::cast_to<GDBanner>(get_node(bannerPath));
}

void GDTwistController::_process(float delta) 
{
    Input* input = Input::get_singleton();
    if (spinEnabled)
    {
        banner->angle += delta * turnRate * (input->get_action_strength("turn_right") - input->get_action_strength("turn_left"));
    }
    // distanceLabel->set_text(godot::String::num_int64((int64_t)(std::abs(get_translation().y) * meterConversion)));
}

void GDTwistController::_input(InputEvent* event)
{
    if (spinEnabled)
    {
        auto dragTouch = Object::cast_to<InputEventScreenDrag>(event);
        if (dragTouch)
        {
            banner->angle += dragTouch->get_relative().x * dragXToAngle;
        }
    }
}