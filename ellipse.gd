class_name Ellipse
extends Node2D

const dt = 0.1

var a: float = 100
var b: float = 200

var points: PackedVector2Array
var inv_tm: Transform2D

func _ready():
	var t := 0.0
	while t < 2*PI + dt:
		points.append(Vector2(a*cos(t), b*sin(t)))
		t += dt

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw() -> void:
	draw_polyline(points, Color(0,0,0), 1.)

func upd_tm(tm: Transform2D) -> void:
	transform = tm
	inv_tm = tm.inverse()


func get_normal(r: Vector2) -> Vector2:
	r = inv_tm * r
	if abs(r.x) < 0.01:
		return Vector2(1, 0) if r.y > 0 else Vector2(-1, 0)
	return Vector2(a*a*r.y/(b*b*r.x), 1).normalized() * transform


func get_nearest_point_approx(r: Vector2) -> Vector2:
	r = inv_tm * r
	var t := atan2(a*r.y, b*r.x)
	return transform * Vector2(a*cos(t), b*sin(t))
