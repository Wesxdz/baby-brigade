#pragma once

#include <Godot.hpp>
#include <Spatial.hpp>
#include <RichTextLabel.hpp>

namespace godot {

/*
 * Formation behavior for crowd management
 */
class GDBanner : public Spatial {
	GODOT_CLASS(GDBanner, Spatial)

private:
    float radius;
    float angle;
    float dragXToAngle;
    float turnRate;
    float yPos;
    float meterConversion;
    bool spinEnabled;
    
    RichTextLabel* distanceLabel;
    float ySpeed;

    // Formation (starting with just a circle)
    float formationRadius;

public:
	static void _register_methods();

	GDBanner();
	~GDBanner();

	void _init();
    void _enter_tree();
    void _input(InputEvent* event);
	void _process(float delta);
    void _physics_process(float delta);
    float get_y_pos();
    float get_radius();
    float get_angle();
    void set_spin_enabled(bool enabled);
};

}