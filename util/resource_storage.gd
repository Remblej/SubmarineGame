class_name ResourceStorage extends Node

var resources: Array[int] # array of resource_id

func add(resource_id: int, amount: int = 1):
	for i in range(amount):
		resources.push_back(resource_id)

func remove(resource_id: int, amount: int = 1):
	for i in range(amount):
		resources.erase(resource_id)

func contains(resource_id: int, amount: int = 1) -> bool:
	return amount(resource_id) >= amount

func amount(resource_id: int) -> int:
	var count = 0
	for r_id in resources:
		if r_id == resource_id:
			count += 1
	return count
