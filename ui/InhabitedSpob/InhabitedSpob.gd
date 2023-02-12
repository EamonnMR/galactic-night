extends NinePatchRect

func for_each_tab(each: Callable):
	for tab in %TabContainer.get_children():
		each.call(tab)

func rebuild():
	for_each_tab(
		func rebuild_inner(tab):
			tab.rebuild()
	)
	
func assign(spob):
	for_each_tab(
		func assign_inner(tab):
			tab.assign(spob)
	)
