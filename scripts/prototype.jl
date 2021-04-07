### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 24775210-7a09-11eb-34b3-9175ee4fd488
using Luxor, PlutoUI, Colors

# ╔═╡ 0dc0cffa-85d1-11eb-108e-995b8b449c62
function cornersmooth(pt1::Point, pt2::Point, pt3::Point, corner_radius)
	_, center, _ = Luxor.offsetlinesegment(pt1, pt2, pt3, corner_radius, corner_radius)
	p1 = getnearestpointonline(pt1, pt2, center)
	p2 = getnearestpointonline(pt2, pt3, center)
	return center, p1, p2
end

# ╔═╡ 3832a56e-85d7-11eb-0e36-5d035ae3e079
import Luxor.offsetlinesegment

# ╔═╡ c8e66ff0-94be-11eb-19d1-c3e0fd1ad8fe
struct ArcSegment
	center::Point
	r::Real
	start::Real
	finish::Real
end

# ╔═╡ ecb10dc6-1312-4d1a-afb3-55aad56aba67
struct FloralLeaf
	center::Point
	leaf::Point
end

# ╔═╡ ee2e3d4a-44c4-4d5e-a2cc-099ca1de4b48
Luxor.slope(f::FloralLeaf) = slope(f.center, f.leaf)

# ╔═╡ 8818c1c7-0a14-4542-b620-187737e9cd74
Luxor.distance(f::FloralLeaf) = distance(f.center, f.leaf)

# ╔═╡ 90981576-c4bb-49db-9ca2-885b2be3f8e8
function cornersmooth(f1, f2, offset)
	if distance(f1) ≈ distance(f2)
		sgn = 1, 1
	elseif distance(f1) < distance(f2)
		sgn = 1, -1
	else
		sgn = -1, 1
	end
	cornersmooth(f1, f2, offset, sgn...)
end

# ╔═╡ 719e97fc-76cf-47a4-b450-7185569badfd
function drawsegmentcap(f::FloralLeaf, offset, bridge)
	@layer begin
		translate(f.leaf)
		α = slope(f)
		(f.center.x > 0) && (α += pi)
		rotate(α)
		arc(O, offset, 0, pi/2 - bridge)
		(bridge > 0) && newsubpath()
		arc(O, offset, pi/2 + bridge, pi)
	end
end

# ╔═╡ 857f21fb-6bce-4e1c-be29-068ca5a753c2
function circlecentertangent(c::Point, r::Float64, p::Point)
	α = r / distance(c, p)
	α*p + (1-α)*c
end

# ╔═╡ 220b7b8d-eb32-44c7-944e-2ba08e19b3f1
sgnarc2r(sgn) = sgn > 0 ? arc2r : carc2r

# ╔═╡ 797d0a46-edb8-43b0-a42d-c5662266b0af
function cornersmooth(f1, f2, offset, sgn1, sgn2)
	flag, p, q = intersectioncirclecircle(f1.center, distance(f1) + sgn1*offset, f2.center, distance(f2) + sgn2*offset)
	@assert flag
	if p.y < 0
		p, q = q, p
	end
	sgnarc2r(sgn1)(f1.center, currentpoint(), p)
	
	c2, p2 = f2.center, f2.leaf
	# INNER RIGHT
	carc2r(p, currentpoint(), circlecentertangent(c2, distance(f2), p))
	sgnarc2r(sgn2)(c2, currentpoint(), p2)
	
end

# ╔═╡ a9d5b5b2-7375-4a5e-a55d-e42a13d6a6cf
function draw_coral()
	side = bottom = 100
	tipp = 1.5*side
	width = 30
	offset = width / 2
	side_angle = deg2rad(60)
	
	bridge = 0.4mm * 1
	bridge_a(r) = bridge / r
	
	r1 = 10
	r2 = 5
	r_corner = [r1, r2, r2, r2, r1]
	r_hole = 5
	
	sethue("black")
	setline(2)
	
	skeleton = [
		Point(0, -tipp),
		Point(side, 0),
		polar(bottom, side_angle),
		polar(bottom, pi - side_angle),
		Point(-side, 0)
	]
	
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

# ╔═╡ 2537384c-8386-11eb-283c-b98a0971c685
@draw begin
	d = Drawing(800,800, "coral_test.svg")
	origin()
	draw_coral()
	
end

# ╔═╡ 41aa7243-778d-48b4-918c-56f2075bd620
function draw_floral()
	stem = 2cm
	
	width = 1.5cm
	offset = width / 2
	
	
	tip = Point(0, -stem)
	
	outer_r = 276.
	inner_r = 1036.
	outer_rad = 1.4
	inner_rad = 0.48
	
	bridge = 0.4mm * 1
	bridge_a(r) = bridge / r
	r_hole = 5.5mm / 2
	
	#r1 = offset / 2
	#r1 = offset / 3
	r1 = offset / 2.5
	r2 = r1
	
	##### start
	
	segments = [
		(Point(outer_r, 0), polar(outer_r, pi - outer_rad)),
		(Point(inner_r, 0), polar(inner_r, pi - inner_rad)),
		(Point(-inner_r, 0), polar(inner_r, inner_rad)),
		(Point(-outer_r, 0), polar(outer_r, outer_rad)),
	]
	segments = [FloralLeaf(c, c+p) for (c, p) in segments]
	
	
	# draw skeleton
	@layer begin
		sethue("red")
		line(O, tip, :stroke)
		for f in segments
			c = f.center
			p = f.leaf
			args = (c, O, p)
			isarcclockwise(O, -c, p-c) ? arc2r(args..., :stroke) : carc2r(args..., :stroke)
		end
	end
	
	holes = [f.leaf for f in segments]
	push!(holes, tip)
	for p in holes
		#circle(p, r_hole,  :stroke)
		arc(p, r_hole, bridge_a(r_hole), 2pi - bridge_a(r_hole))
		newsubpath()
	end
	
	f1, f2, f3, f4 = segments
	
	# STEM
	arc(tip, offset, -pi/2 + bridge_a(offset), 0)
	
	# OUTER RIGHT
	start = offset / distance(f1) * f1.center
	carc2r(f1.center, start, f1.leaf)
	
	drawsegmentcap(f1, offset, bridge_a(offset))
	cornersmooth(f1, f2, offset + r1)
	drawsegmentcap(f2, offset, bridge_a(offset))
	cornersmooth(f2, f3, offset + r2)
	drawsegmentcap(f3, offset, bridge_a(offset))
	cornersmooth(f3, f4, offset + r1)
	drawsegmentcap(f4, offset, bridge_a(offset))
	
	carc2r(f4.center, currentpoint(), O)
	
	arc(tip, offset, -pi, -pi/2 - bridge_a(offset))
	
	if bridge == 0
		closepath()
	end
	strokepath()
end

# ╔═╡ bac005ea-8ce0-11eb-002b-0f61fcba8355
@draw begin
	Drawing(2000,1000, "floral_test.svg")
	origin()
	translate(0, -200)
	draw_floral()
end

# ╔═╡ Cell order:
# ╠═24775210-7a09-11eb-34b3-9175ee4fd488
# ╠═2537384c-8386-11eb-283c-b98a0971c685
# ╠═a9d5b5b2-7375-4a5e-a55d-e42a13d6a6cf
# ╠═0dc0cffa-85d1-11eb-108e-995b8b449c62
# ╠═3832a56e-85d7-11eb-0e36-5d035ae3e079
# ╠═bac005ea-8ce0-11eb-002b-0f61fcba8355
# ╠═41aa7243-778d-48b4-918c-56f2075bd620
# ╠═c8e66ff0-94be-11eb-19d1-c3e0fd1ad8fe
# ╠═ecb10dc6-1312-4d1a-afb3-55aad56aba67
# ╠═ee2e3d4a-44c4-4d5e-a2cc-099ca1de4b48
# ╠═8818c1c7-0a14-4542-b620-187737e9cd74
# ╠═797d0a46-edb8-43b0-a42d-c5662266b0af
# ╠═90981576-c4bb-49db-9ca2-885b2be3f8e8
# ╠═719e97fc-76cf-47a4-b450-7185569badfd
# ╠═857f21fb-6bce-4e1c-be29-068ca5a753c2
# ╠═220b7b8d-eb32-44c7-944e-2ba08e19b3f1
