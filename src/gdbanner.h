#pragma once

#include <Godot.hpp>
#include <Spatial.hpp>
#include <RichTextLabel.hpp>

namespace godot {

/*
 * Player interface for crowd position manipulation
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
};

}