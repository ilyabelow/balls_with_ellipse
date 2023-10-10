extends Node2D

const gravity := Vector2.DOWN * 1000.0

@export var ball_to_ball_elasticity := .9
@export var ball_to_wall_elasticity := .9

@export var ball_rad := 10.

var ellipse_pos := Vector2(250, 300)
var balls: Array[Ball]
var ellipse: Ellipse

@export var grid_resolution := 20.
var grid = []


func _ready() -> void:
	var screen_size := get_viewport_rect().size
	for i in range(ceil(screen_size.x / grid_resolution)):
		var y_array = []
		for j in range(ceil(screen_size.y / grid_resolution)):
			y_array.push_back([])
		grid.append(y_array)

	ellipse = Ellipse.new()
	ellipse.a = 200.
	ellipse.b = 100.
	add_child(ellipse)
	
	for i in range(20):
		var ball := Ball.new()
		balls.append(ball)
		ball.position = Vector2(100,0)*randf() + Vector2(0,100)*randf() + ellipse_pos
		ball.radius = ball_rad
		add_child(ball)

func check_collision(r1, r2) -> bool:
	var rad_sum = (r1.radius + r2.radius)
	return (r1.position - r2.position).length_squared() < rad_sum*rad_sum


func collide_balls(b1: Ball, b2: Ball) -> void:
	var diff := b1.position - b2.position
	var dist := diff.length()
	var normal := diff / dist
	var tangent := normal.orthogonal()

	var tangent_vel1 := b1.velocity.project(tangent)
	var tangent_vel2 := b2.velocity.project(tangent)
	var normal_vel1 := b1.velocity.project(normal)
	var normal_vel2 := b2.velocity.project(normal)

	b1.velocity = tangent_vel1 + normal_vel2 * ball_to_ball_elasticity;
	b2.velocity = tangent_vel2 + normal_vel1 * ball_to_ball_elasticity;
	
	var intersection_length = b1.radius + b2.radius - dist
	b1.position += intersection_length * 0.5 * normal
	b2.position -= intersection_length * 0.5 * normal


func check_collision_with_ellipse(b: Ball, e: Ellipse) -> bool:
	var p := e.get_nearest_point_approx(b.position)
	var dist := (p - b.position).length()
	return dist*dist < b.radius*b.radius


func collide_ball_and_ellipse(b: Ball, e: Ellipse) -> void:
	var point := e.get_nearest_point_approx(b.position)
	var diff := b.position - point
	if (b.position - e.position).dot(diff) > 0:
		diff *= -1
	var dist := diff.length()
	var normal := diff / dist
	var tangent := normal.orthogonal()

	var tangent_vel := b.velocity.project(tangent)
	var normal_vel := b.velocity.project(normal)

	b.velocity = tangent_vel - normal_vel * ball_to_wall_elasticity;
	b.position = point + normal * b.radius



func clear_grid() -> void:
	for i in range(len(grid)):
		for j in range(len(grid[i])):
			grid[i][j].clear()


func get_grid_coord(ball: Ball) -> Vector2i:
	var i: int = clampi(ball.position.x / grid_resolution, 0, len(grid)-1)
	var j: int = clampi(ball.position.y / grid_resolution, 0, len(grid[i])-1)
	return Vector2i(i, j)


func add_to_grid(ball: Ball):
	var coord := get_grid_coord(ball)
	grid[coord.x][coord.y].append(ball)


func collide_two_cells(cell1, cell2):
	for ball1 in cell1:
		for ball2 in cell2:
			if ball1 == ball2:
				continue
			if check_collision(ball1, ball2):
				collide_balls(ball1, ball2)


func _physics_process(delta: float) -> void:
	var time = Time.get_ticks_msec()/1000.
	var tm: Transform2D
	tm = tm.rotated(time)
	tm.origin = -Vector2(0, abs(sin(time)**15))*200. + ellipse_pos
	ellipse.upd_tm(tm)


	for k in range(3):
		clear_grid()

		for ball in balls:
			add_to_grid(ball)
		for i in range(len(grid)):
			for j in range(len(grid[i])):
				for other_i in range(max(i-1, 0), min(i+2, len(grid))):
					for other_j in range(max(j-1, 0), min(j+2, len(grid[i]))):
						collide_two_cells(grid[other_i][other_j], grid[i][j])
		for ball in balls:
			if check_collision_with_ellipse(ball, ellipse):
				collide_ball_and_ellipse(ball, ellipse)

	for ball in balls:
		ball.apply_gravity(delta, gravity)
		ball.move(delta)
		
	
