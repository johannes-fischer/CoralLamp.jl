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

# ╔═╡ 41aa7243-778d-48b4-918c-56f2075bd620
function draw_floral()
	# outer_r, inner_r, outer_rad, inner_rad
	stem = 2cm
	
	width = 1.5cm
	offset = width / 2
	
	tip = Point(0, -stem)
	
	outer_r = 276.
	inner_r = 1036.
	outer_rad = 1.4
	inner_rad = 0.48
	
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
	segments = [(c, c+p) for (c, p) in segments]
	
	
	# draw skeleton
	@layer begin
		sethue("red")
		line(O, tip, :stroke)
		for (c, p) in segments
			args = (c, O, p)
			isarcclockwise(O, -c, p-c) ? arc2r(args..., :stroke) : carc2r(args..., :stroke)
		end
	end
	
	s1, s2, s3, s4 = segments
	
	# STEM
	arc(tip, offset, -pi/2, 0)
	
	# OUTER RIGHT
	c1, p1 = s1
	p1_m = polar(distance(s1...) - offset, slope(s1...))
	start = c1 + polar(distance(c1, O) - offset, slope(c1, O))
	carc2r(c1, start, p1)
	
	@layer begin
		translate(p1)
		rotate(slope(c1, p1) + pi)
		arc(O, offset, 0, pi)
	end
	
	c2, p2 = s2
	flag, m1, m2 = intersectioncirclecircle(c1, distance(c1, p1) + offset + r1, c2, distance(c2, p2) - offset - r1)
	@assert flag
	if m1.y < 0
		m1, m2 = m2, m1
	end
	arc2r(c1, currentpoint(), m1)
	
	# INNER RIGHT
	carc2r(m1, currentpoint(), c2 + polar(distance(c2, p2) - offset, slope(c2, m1)))
	carc2r(c2, currentpoint(), p2)
	
	@layer begin
		translate(p2)
		rotate(slope(c2, p2) + pi)
		arc(O, offset, 0, pi)
	end
	
	c3, p3 = s3
	flag, m1, m2 = intersectioncirclecircle(c2, distance(c2, p2) + offset + r2, c3, distance(c3, p3) + offset + r2)
	@assert flag
	if m1.y < 0
		m1, m2 = m2, m1
	end
	arc2r(c2, currentpoint(), m1)
	
	# INNER LEFT
	carc2r(m1, currentpoint(), c3 + polar(distance(c3, p3) + offset, slope(c3, m1)))
	arc2r(c3, currentpoint(), p3)
	
	@layer begin
		translate(p3)
		rotate(slope(c3, p3) + 0pi)
		arc(O, offset, 0, pi)
	end
	
	c4, p4 = s4
	flag, m1, m2 = intersectioncirclecircle(c3, distance(c3, p3) - offset - r1, c4, distance(c4, p4) + offset + r1)
	@assert flag
	if m1.y < 0
		m1, m2 = m2, m1
	end
	carc2r(c3, currentpoint(), m1)
	
	# OUTER LEFT
	carc2r(m1, currentpoint(), c4 + polar(distance(c4, p4) + offset, slope(c4, m1)))
	arc2r(c4, currentpoint(), p4)
	
	@layer begin
		translate(p4)
		rotate(slope(c4, p4) + 0pi)
		arc(O, offset, 0, pi)
	end
	
	carc2r(c4, currentpoint(), O)
	
	
	#=
	draw_segment(segments[1], -offset, reverse=true)
	# half circle cap
	circlecap(segments[1], offset)
	draw_segment(segments[1], offset, reverse=false)
	
	# circle intersection s1 s2
	
	
	draw_segment(segments[2], -offset, reverse=true)
	circlecap(segments[2], offset)
	draw_segment(segments[2], offset, reverse=false)
	
	draw_segment(segments[3], offset, reverse=true)
	circlecap(segments[3], offset)
	draw_segment(segments[3], -offset, reverse=false)
	draw_segment(segments[4], offset, reverse=true)
	circlecap(segments[4], offset)
	draw_segment(segments[4], -offset, reverse=false)
	
	#for (s1, s2) in zip(segments, segments[2:end-1])
	#	draw_segment(s1, offset, reverse=false)
	#	draw_segment(s2, -offset, reverse=true)
	#end
	=#
	
	arc(tip, offset, -pi, -pi/2)
	
	closepath()
	strokepath()
end

# ╔═╡ bac005ea-8ce0-11eb-002b-0f61fcba8355
@draw begin
	Drawing(2000,1000, "floral_test.svg")
	origin()
	translate(0, -200)
	draw_floral()
end

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
radius(f::FloralLeaf) = distance(f.center, f.leaf)

# ╔═╡ c8a82268-94be-11eb-2400-e56f8d76ec23
function draw_segment(segment, offset; reverse=false)
	c, r, start, finish = segment
	left = c.x < 0
	if xor(reverse, left)
		carc(c, r + offset, finish, start)
	else
		arc(c, r + offset, start, finish)
	end
	# todo: use arc2r(p1, p2, p3)
end

# ╔═╡ 797d0a46-edb8-43b0-a42d-c5662266b0af
function cornersmooth(segment1, segment2, offset1, offset2)

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
# ╠═c8a82268-94be-11eb-2400-e56f8d76ec23
# ╠═797d0a46-edb8-43b0-a42d-c5662266b0af
