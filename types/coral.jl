using AngleBetweenVectors
using Luxor
using Luxor: offsetlinesegment
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

function Coral3d(data::PolyhedraTile, radius::Float64)
    points = [data.tip, data.side_a, data.side_b, data.bottom_a, data.bottom_b]
    center = (data.side_a + data.side_b) / 2
    push!(points, center)
    Coral3d(normalize.(points)..., radius)
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
Coral2d(c::Coral3d) = Coral2d(arm_lengths(c)..., angles(c)...)

function Base.show(io::IO, c::Coral2d)
    println("Coral2d:")
    println(io, c.length_tip)
    println(io, c.length_side)
    println(io, c.length_bottom)
    println(io, rad2deg(c.rad_tip_side))
    println(io, rad2deg(c.rad_side_bottom))
    println(io, rad2deg(c.rad_bottom))
end

function generate_svg(c::Coral2d, width, hole_diameter, r1=nothing, r2=nothing, bridge=1mm)
    d = Drawing("A4", "coral.svg")
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
	setline(1)

    lengths = [tip, side, bottom, bottom, side]
    angles = IntegralArray([-pi/2, c.rad_tip_side, c.rad_side_bottom, c.rad_bottom, c.rad_side_bottom])
	
    skeleton = [polar(l, a) for (l, a) in zip(lengths, angles)]
	
	# draw skeleton
	# @layer begin
	# 	sethue("red")
	# 	for p in skeleton
	# 		line(O, p, :stroke)
	# 	end
	# end
	
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

