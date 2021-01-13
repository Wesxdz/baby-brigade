extends RichTextLabel

var count = 0

func pickup():
	count += 1
	text = String(count)
