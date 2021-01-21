extends Panel

export var num = 0

func pickup():
	num += 1
	$count.text = str(num)
	$collect.play()
