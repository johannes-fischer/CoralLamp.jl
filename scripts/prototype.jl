### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 24775210-7a09-11eb-34b3-9175ee4fd488
using Luxor, PlutoUI, Colors

# ╔═╡ 0dc0cffa-85d1-11eb-108e-995b8b449c62
function cornersmooth(pt1, pt2, pt3, corner_radius)
	_, center, _ = Luxor.offsetlinesegment(pt1, pt2, pt3, corner_radius, corner_radius)
	p1 = getnearestpointonline(pt1, pt2, center)
	p2 = getnearestpointonline(pt2, pt3, center)
	return center, p1, p2
end

# ╔═╡ 2537384c-8386-11eb-283c-b98a0971c685
@draw begin
	d = Drawing(800,800, "coral_test.svg")
	origin()
	side = bottom = 100
	tip = 1.5*side
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
		Point(0, -tip),
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

# ╔═╡ 3832a56e-85d7-11eb-0e36-5d035ae3e079
import Luxor.offsetlinesegment

# ╔═╡ 405f061a-85d7-11eb-1249-e55633407b36
@draw begin
	c1 = (O, 150)
	c2 = (O + (100, 0), 150)

	circle(c1... , :stroke)
	circle(c2... , :stroke)

	sethue("purple")
	circle(c1... , :clip)
	circle(c2... , :fill)
	clipreset()

	sethue("black")

	text(string(150^2 * π |> round), c1[1] - (125, 0))
	text(string(150^2 * π |> round), c2[1] + (100, 0))
	sethue("white")
	text(string(intersection2circles(c1..., c2...) |> round),
		 midpoint(c1[1], c2[1]), halign=:center)

	sethue("red")
	flag, C, D = intersectioncirclecircle(c1..., c2...)
	if flag
		circle.([C, D], 5, :fill)
	end
end

# ╔═╡ bac005ea-8ce0-11eb-002b-0f61fcba8355
@draw begin
	Drawing(2000,1000, "floral_test.svg")
	origin()
	translate(0, -200)
	stem = 2cm
	arc_r = [276., 1036, -1036, -276]
	arc_a = [1.4, 0.48, 0.48, 1.4]
	
	# draw skeleton
	@layer begin
		sethue("red")
		line(O, Point(0, -stem), :stroke)
		for (radius, α) in zip(arc_r, arc_a)
			if sign(radius) < 0
				arc(radius, 0., abs(radius), 0, α, :stroke)
			else
				carc(radius, 0., abs(radius), pi, pi - α, :stroke)
			end
		end
	end
end

# ╔═╡ Cell order:
# ╠═24775210-7a09-11eb-34b3-9175ee4fd488
# ╠═2537384c-8386-11eb-283c-b98a0971c685
# ╠═0dc0cffa-85d1-11eb-108e-995b8b449c62
# ╠═3832a56e-85d7-11eb-0e36-5d035ae3e079
# ╠═405f061a-85d7-11eb-1249-e55633407b36
# ╠═bac005ea-8ce0-11eb-002b-0f61fcba8355
