using AngleBetweenVectors
using Luxor
import Luxor.offsetlinesegment
using IntegralArrays

struct Coral3d
    tip
    side_a
    side_b
    bottom_a
    bottom_b
    center
    radius
end

function Coral3d(data::NamedTuple, radius::Float64)
    center = normalize((data.side_a + data.side_b) / 2)
    Coral3d(data.tip, data.side_a, data.side_b, data.bottom_a, data.bottom_b, center, radius)
end

# angle at ball center between alle the tips of the shape and the star center
function angle_distances(c::Coral3d)
    angle_tip_center = angle(c.tip, c.center)
    angle_side_center = (angle(c.side_a, c.center) + angle(c.side_b, c.center)) / 2
    angle_bottom_center = (angle(c.bottom_a, c.center) + angle(c.bottom_b, c.center)) / 2
    return [angle_tip_center, angle_side_center, angle_bottom_center]
end

# great circle distances between tips and star center = length of the arms in the 2D projection
arm_lengths(c::Coral3d) = c.radius * angle_distances(c)

function angles(c::Coral3d)
    angle_tip_side = (sphere_angle(c.tip, c.center, c.side_a) + sphere_angle(c.tip, c.center, c.side_b)) / 2
    angle_bottom_side = (sphere_angle(c.bottom_a, c.center, c.side_a) + sphere_angle(c.bottom_b, c.center, c.side_b)) / 2
    angle_bottom = sphere_angle(c.bottom_a, c.center, c.bottom_b)
    return [angle_tip_side, angle_bottom_side, angle_bottom]
end

struct Coral2d
    length_tip
    length_side
    length_bottom
    rad_tip_side
    rad_side_bottom
    rad_bottom
end

function Base.show(io::IO, c::Coral2d)
    println("Coral2d:")
    println(io, c.length_tip)
    println(io, c.length_side)
    println(io, c.length_bottom)
    println(io, rad2deg(c.rad_tip_side))
    println(io, rad2deg(c.rad_side_bottom))
    println(io, rad2deg(c.rad_bottom))
end

unroll(c::Coral3d)::Coral2d = Coral2d(arm_lengths(c)..., angles(c)...)

function generate_svg(c::Coral2d, width, hole_diameter, r1=nothing, r2=nothing, bridge=1mm)
    d = Drawing(800, 800, "coral.svg")
    origin()

	tip = c.length_tip
	side = c.length_side
    bottom = c.length_bottom
	offset = width / 2

	r_hole = hole_diameter / 2
	bridge_a(r) = 0.5bridge / r
	
    if isnothing(r1)
        r1 = side / 10 * 0.95
    end
    if isnothing(r2)
        r2 = r1 / 2 * 0.95
    end
	r_corner = [r1, r2, r2, r2, r1]
	
	sethue("black")
	setline(2)

    lengths = [tip, side, bottom, bottom, side]
    angles = IntegralArray([-pi/2, c.rad_tip_side, c.rad_side_bottom, c.rad_bottom, c.rad_side_bottom])
	
	# skeleton = [
	# 	Point(0, -tip),
	# 	Point(side, 0),
	# 	polar(bottom, side_angle),
	# 	polar(bottom, pi - side_angle),
	# 	Point(-side, 0)
	# ]
    skeleton = [polar(l, a) for (l, a) in zip(lengths, angles)]
	
	# draw skeleton
	@layer begin
		sethue("red")
		for p in skeleton
			line(O, p, :stroke)
		end
	end
	
	for p in skeleton
		#circle(p, r_hole,  :stroke)
		arc(p, r_hole, bridge_a(r_hole), 2pi - bridge_a(r_hole))
		newsubpath()
	end
	
	for (i, s1) in enumerate(skeleton)
		if bridge > 0
			newsubpath()
		end
		s2 = skeleton[i % length(skeleton) + 1]
		@layer begin
			rotate(slope(O, s1))
			arc(distance(O, s1), 0, offset, bridge_a(offset), pi/2)
		end
		p1, corner, p2 = Luxor.offsetlinesegment(s1, O, s2, offset, offset)
		carc2r(cornersmooth(p1, corner, p2, r_corner[i])...)
		@layer begin
			rotate(slope(O, s2))
			arc(distance(O, s2), 0, offset, -pi/2, -bridge_a(offset))
		end
	end
	if bridge == 0
		closepath()
	end
	strokepath()
	
    finish()

end

# @draw begin
# 	d = Drawing(800,800, "coral_test.svg")
# 	origin()
# 	side = bottom = 100
# 	tip = 2*side
# 	width = 30
# 	offset = width / 2
# 	angle = 45 / 180 * pi
	
# 	corner_radius1 = 15
# 	corner_radius2 = 5
	
# 	sethue("black")
	
# 	# draw skeletton
# 	@layer begin
# 		sethue("red")
# 		line(O, Point(0, -tip), :stroke)
# 		line(Point(side, 0), Point(-side, 0), :stroke)
# 		move(O)
# 		bottom_a = polar(bottom, angle)
# 		line(O, bottom_a, :stroke)
# 		bottom_b = polar(bottom, pi - angle)
# 		line(O, bottom_b, :stroke)
# 	end
	
	
	
# 	# Start new path
# 	#newpath()
# 	#line(O,O, :path)
# 	p1 = Point(offset, -tip)
# 	move(p1)
	
# 	c = p1 + Point(0, tip - offset)
# 	#line(c)
	
# 	p2 = c + Point(side - offset, 0)
# 	#line(p2)
		
# 	carc2r(cornersmooth(p1, c, p2, corner_radius1)...)
	 
# 	right_side = Point(side, 0)
# 	arc(right_side, offset, -pi/2, pi/2)
	
# 	# compute intersection point between side and angle boundaries
# 	side_outer = currentpoint()
# 	side_inner = side_outer + Point(-side, 0)
# 	right_bottom_center = polar(bottom, angle)
# 	bottom_outer = perpendicular(right_bottom_center, O, offset)
# 	bottom_inner = bottom_outer - right_bottom_center
# 	flag, side_ip =  intersectionlines(side_outer, side_inner, bottom_inner, bottom_outer, crossingonly=true)
# 	@assert flag
	
# 	_, center, _ = Luxor.offsetlinesegment(right_side, O, right_bottom_center, offset, offset)
	
# 	line(center)
# 	line(bottom_outer)
	
# 	@layer begin
# 		rotate(angle)
# 		#circle(bottom, 0, 5)
# 		arc(bottom, 0, offset, -pi/2, pi/2)
# 	end
	
# 	right_outer = currentpoint()
# 	right_inner = right_outer - right_bottom_center
# 	flag, bottom_ip =  intersectionlines(right_outer, right_inner, O, Point(0, bottom), crossingonly=true)
# 	@assert flag
	
# 	line(bottom_ip)
# 	line(mirror_y(right_outer))
# 	@layer begin
# 		rotate(pi - angle)
# 		arc(bottom, 0, offset, -pi/2, pi/2)
# 	end
	
# 	line(mirror_y(side_ip))
# 	line(mirror_y(side_outer))
# 	arc(-side, 0, offset, pi/2, 3pi/2)
# 	rline(side - offset, 0)
# 	rline(0, -(tip-offset))
# 	arc(0, -tip, offset, pi, 2pi)
	
# 	closepath()
	
	
# 	#line(side_inner)
# 	#line(bottom_inner, bottom_outer)
	
# 	strokepath()
	
# 	#circle(ip, 5)
	
		
# 	strokepath()
# 	#do_action(:stroke)
# 	finish()
# 	d
# end