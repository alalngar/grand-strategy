extends Node

func province_pop(prov):
	_sync_province_pop.rpc(prov.color, prov.population)

@rpc(any_peer) func _sync_province_pop(color, pop):
	Data.provinces[color].population = pop

func country_treasury(country):
	_sync_country_treasury.rpc(country.tag, country.treasury)

@rpc(any_peer) func _sync_country_treasury(tag, treasury):
	Data.countries[tag].treasury = treasury

func province_buildings(prov):
	_sync_province_buildings.rpc(prov.color, prov.buildings)

@rpc(any_peer) func _sync_province_buildings(color, buildings):
	Data.provinces[color].buildings = buildings

func province_modifiers(prov):
	_sync_province_modifiers.rpc(prov.color, prov.modifiers)

@rpc(any_peer) func _sync_province_modifiers(color, modifiers):
	Data.provinces[color].modifiers = modifiers
