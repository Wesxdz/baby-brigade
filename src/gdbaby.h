#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <Godot.hpp>
#include <Spatial.hpp>
#include <Resource.hpp>
#include <PackedScene.hpp>

namespace godot {

enum Career
{
	UNEMPLOYED,
	LUMBERJACK,
	MINER,
	KNIGHT,
};

struct HealthComponent
{
	int health;
};

class GDCareer : public Resource
{
	GODOT_CLASS(GDCareer, Resource)
private:

public:
	Career type;
	Array actions;

};

class GDAction : public Resource
{
	GODOT_CLASS(GDAction, Resource)
private:

public:
	String name;
	float cooldown;
	float priority;
	// Animation?
	Ref<PackedScene> fx;

};

class GDBaby : public Spatial {
	GODOT_CLASS(GDBaby, Spatial)

private:
	Career career;

public:
	static void _register_methods();

	GDBaby();
	~GDBaby();

	void _init();

};

}

#endif
