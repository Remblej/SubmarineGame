class_name Pocket extends Resource

enum Size { VERY_SMALL, SMALL, MEDIUM, BIG, VERY_BIG }
enum Hardness { VERY_SOFT, SOFT, MEDIUM, HARD, VERY_HARD }

var size: Size
var hardness: Hardness

func random_width() -> int:
	match size:
		Size.VERY_SMALL:
			return randi_range(26, 32)
		Size.SMALL:
			return randi_range(32, 48)
		Size.MEDIUM:
			return randi_range(48, 64)
		Size.BIG:
			return randi_range(70, 90)
		Size.VERY_BIG:
			return randi_range(100, 156)
		_:
			return -1

func random_height() -> int:
	return random_width()

func random_hardness() -> int:
	match hardness:
		Hardness.VERY_SOFT:
			return 1
		Hardness.SOFT:
			return randi_range(2, 3)
		Hardness.MEDIUM:
			return randi_range(4, 8)
		Hardness.HARD:
			return randi_range(10, 18)
		Hardness.VERY_HARD:
			return randi_range(24, 36)
		_:
			return -1
