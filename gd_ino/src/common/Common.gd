extends Node

## コリジョンレイヤー.
enum eCollisionLayer {
	PLAYER = 1,
	WALL = 2,
	ONEWAY = 3,
}

func get_collision_bit(bit:eCollisionLayer) -> int:
	return int(pow(2, bit-1))
