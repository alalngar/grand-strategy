extends Node

func province_dev(prov):
	_sync_province_dev.rpc(prov.color, prov.development)

@rpc(any_peer) func _sync_province_dev(color, dev):
	Data.provinces[color].development = dev

func country_treasury(country):
	_sync_country_treasury.rpc(country.tag, country.treasury)

@rpc(any_peer) func _sync_country_treasury(tag, treasury):
	Data.countries[tag].treasury = treasury

func province_buildings(prov):
	_sync_province_buildings.rpc(prov.color, prov.buildings)

@rpc(any_peer) func _sync_province_buildings(color, buildings):
	Data.provinces[color].buildings = buildings
