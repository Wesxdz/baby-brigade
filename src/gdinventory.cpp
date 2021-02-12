#include "gdinventory.h"

using namespace godot;

void GDInventory::_register_methods() 
{
	register_property<GDInventory, Array>("items", &GDInventory::items, Array());
	register_method("craft", &GDInventory::craft);
	register_method("can_craft", &GDInventory::can_craft);
	register_method("is_resource", &GDInventory::is_resource);
	register_method("get_stock", &GDInventory::get_stock);
	register_method("change_resource", &GDInventory::change_resource);
	register_method("num_ingredients", &GDInventory::num_ingredients);
	register_method("get_ingredient_items", &GDInventory::get_ingredient_items);
	register_method("get_ingredient_counts", &GDInventory::get_ingredient_counts);
	register_signal<GDInventory>("item_amount_changed", "item", GODOT_VARIANT_TYPE_INT, "amount", GODOT_VARIANT_TYPE_INT);
}

GDInventory::GDInventory() 
{
}

GDInventory::~GDInventory() 
{
}

void GDInventory::_init() 
{
	resources[Item::ASMR_COIN] = 20;
	resources[Item::PINEWOOD] = 0;
	resources[Item::MOONSTONE] = 0;

	recipes[Item::BABY_BOX] = {{Item::ASMR_COIN, 15}};
	recipes[Item::WOOD_AXE] = {{Item::ASMR_COIN, 5}};
	recipes[Item::WOOD_PICK] = {{Item::PINEWOOD, 5}};
	recipes[Item::WOOD_SWORD] = {{Item::PINEWOOD, 5}};
	recipes[Item::STONE_AXE] = {{Item::PINEWOOD, 2}, {Item::MOONSTONE, 5}};
	recipes[Item::STONE_PICK] = {{Item::PINEWOOD, 2}, {Item::MOONSTONE, 5}};
	recipes[Item::STONE_SWORD] = {{Item::PINEWOOD, 2}, {Item::MOONSTONE, 5}, {Item::ASMR_COIN, 15}};
}

int GDInventory::num_ingredients(int item)
{
	return recipes[(Item)item].input.size();
}

PoolIntArray GDInventory::get_ingredient_items(int item)
{
	PoolIntArray ingredient_items;
	for (Ingredient& ing : recipes[(Item)item].input)
	{
		ingredient_items.append(ing.item);
	}
	return ingredient_items;
}

PoolIntArray GDInventory::get_ingredient_counts(int item)
{
	PoolIntArray ingredient_counts;
	for (Ingredient& ing : recipes[(Item)item].input)
	{
		ingredient_counts.append(ing.count);
	}
	return ingredient_counts;
}

bool GDInventory::can_craft(int item)
{
	for (Ingredient& ing : recipes[(Item)item].input)
	{
		if (resources[ing.item] < ing.count) return false;
	}
	return true;
}

void GDInventory::craft(int item)
{
	for (Ingredient& ing : recipes[(Item)item].input)
	{
		resources[ing.item] -= ing.count;
	}
}

bool GDInventory::is_resource(int item)
{
	return resources.count((Item)item);
}

void GDInventory::change_resource(int item, int amount)
{
	resources[(Item)item] += amount;
	emit_signal("item_amount_changed", item, amount);
}

int GDInventory::get_stock(int item)
{
	return resources[(Item)item];
}