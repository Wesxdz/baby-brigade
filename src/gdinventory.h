#pragma once

#include <Godot.hpp>
#include <Sprite.hpp>
#include <vector>
#include <unordered_map>
#include <initializer_list>

namespace godot {

enum Item
{
	BABY_BOX,
	ASMR_COIN,
	PINEWOOD,
	MOONSTONE,
	WOOD_AXE,
	WOOD_PICK,
	WOOD_SWORD,
	STONE_AXE,
	STONE_PICK,
	STONE_SWORD,
};

struct Ingredient
{
	Item item;
	size_t count;
};

struct Recipe
{
	Recipe() {}
	Recipe(std::initializer_list<Ingredient> i)
	{
		input = i;
	}
	std::vector<Ingredient> input;
};

class GDInventory : public Node {
	GODOT_CLASS(GDInventory, Node)

private:
	std::unordered_map<Item, Recipe> recipes;
	std::unordered_map<Item, size_t> resources;

public:
	Array items;
	static void _register_methods();

	GDInventory();
	~GDInventory();

	void _init(); // our initializer called by Godot

	// This is a hack because GDScript sucks
	int num_ingredients(int item);
	PoolIntArray get_ingredient_items(int item);
	PoolIntArray get_ingredient_counts(int item);

	bool can_craft(int item);
	void craft(int item);
	void change_resource(int item, int amount);
	bool is_resource(int item);
	int get_stock(int item);
	
};

}