#pragma once

#include <Godot.hpp>
#include <Spatial.hpp>
#include <RichTextLabel.hpp>
#include <Ref.hpp>
#include <core/Array.hpp>

#include "gdcrowdnav.h"


namespace godot {

/*
 * Formation behavior and movement for crowds
 */
class GDBanner : public Spatial {
	GODOT_CLASS(GDBanner, Spatial)

private:
    float radius;
    float meterConversion;
    
    // RichTextLabel* distanceLabel;
    float ySpeed;
    float rotateSpeed;

    // Formation (starting with just a circle)
    float formationRadius;

public:
    std::vector<NodePath> subgroup_nodes;
    float yPos;
    float angle;
	static void _register_methods();

	GDBanner();
	~GDBanner();

	void _init();
    void _enter_tree();
    void _exit_tree();
    void _physics_process(float delta);
    void set_y_pos(float p);
    float get_y_pos();
    float get_radius();
    float get_angle();
    void set_y_speed(float s);
    float get_y_speed();
    void set_rotate_speed(float s);
    float get_rotate_speed();
};

class GDTwistController : public Node
{
    GODOT_CLASS(GDTwistController, Node)
private:
    NodePath bannerPath;
    GDBanner* banner;
    bool spinEnabled;
    float dragXToAngle;
    float turnRate;

public:
	static void _register_methods();
	void _init();
    void _enter_tree();
	void _process(float delta);
    void _input(InputEvent* event);
    void set_spin_enabled(bool enabled);
};

}