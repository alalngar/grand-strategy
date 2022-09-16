extends Node

func prov_pop(prov):
	_sync_prov_pop.rpc(prov.color, prov.population)

@rpc func _sync_prov_pop(color, pop):
	Data.provinces[color].population = pop

func country_treasury(country):
	_sync_country_treasury.rpc(country.tag, country.treasury)

@rpc func _sync_country_treasury(tag, treasury):
	Data.countries[tag].treasury = treasury
