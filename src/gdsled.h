#pragma once

#include <Godot.hpp>
#include <Spatial.hpp>
#include <RichTextLabel.hpp>

namespace godot {

class GDSled : public Spatial {
	GODOT_CLASS(GDSled, Spatial)

private:
    float radius;
    float angle;
    float dragXToAngle;
    float turnRate;
    float yPos;
    float meterConversion;
    
    RichTextLabel* distanceLabel;
    float ySpeed;
    // TODO: Custom physics design for jumping

public:
	static void _register_methods();

	GDSled();
	~GDSled();

	void _init();
    void _enter_tree();
    void _input(InputEvent* event);
	void _process(float delta);
    void _physics_process(float delta);
};

}