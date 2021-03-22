### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 24775210-7a09-11eb-34b3-9175ee4fd488
using Luxor, PlutoUI, Colors

# ╔═╡ 33aa9544-7a09-11eb-05ef-9da3db67eb36
@draw begin
    x = ngon(O, 100, 4, 0, vertices=true)
	line(O, x[1], :path)
	line(O)
	for i in 2:3
		line(x[i])
		line(O)
	end
	line(x[4])
	closepath()
	do_action(:stroke)
end

# ╔═╡ 49d7de80-7a09-11eb-139c-6b17efed44a4
begin
	de = Drawing(800,800, "test.svg")
	origin()
	#circle(O,100,:stroke)
	newpath()
	line(100,100)
	line(-100,100)
	rline(00,-100)
	closepath()
	line(Point(-100,0),Point(-200,-200), :path)
	rline(200,0)
	#closepath()
	do_action(:stroke)
	finish()
	de
end

# ╔═╡ e750072c-7a0c-11eb-2b90-f5c10b7d1de2
@draw begin
	#x = ngon(O, 100, 4, 0, vertices=true)
	points = Array{Point,1}()
	for i in 1:4
		append!(points, [O,x[i]])
	end
	poly(points, :stroke, close=true)
	poly(offsetpoly(points, 30), :stroke, close=true)
	p = ngon(O, 100, 3, 0)
	#poly(p, :stroke, close=true)
	sethue("red")
	#poly(offsetpoly(p, 30), :stroke, close=true)
end

# ╔═╡ 6a92c0ba-85ce-11eb-0733-efc5f7ac0721
function parallel_line(pt1, pt2, offset=0)
	normal = perpendicular(pt2-pt1)
	normal = normal / distance(normal, O) * offset
	return [pt1 + normal, pt2 + normal]
end

# ╔═╡ e7e63e3e-838a-11eb-1a0c-39d2b41bef41
@draw begin
	pt = ngon(Point(0, 0), 80, 3, vertices=true)
	#pt = [O,Point(100,0)]
	poly(pt, :stroke)
	#translate(200, 0)
	#polysmooth(pt, 10, :stroke, debug=true)
	sethue("red")
	poly([p for p in Luxor.offsetlinesegment(pt..., 40, -40)], :stroke)
	#poly(offsetpoly(pt), :stroke)
	sethue("blue")
	poly(parallel_line(pt[1:2]..., 20), :stroke)
end

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

# ╔═╡ Cell order:
# ╠═24775210-7a09-11eb-34b3-9175ee4fd488
# ╠═33aa9544-7a09-11eb-05ef-9da3db67eb36
# ╠═49d7de80-7a09-11eb-139c-6b17efed44a4
# ╠═e750072c-7a0c-11eb-2b90-f5c10b7d1de2
# ╠═2537384c-8386-11eb-283c-b98a0971c685
# ╠═e7e63e3e-838a-11eb-1a0c-39d2b41bef41
# ╠═6a92c0ba-85ce-11eb-0733-efc5f7ac0721
# ╠═0dc0cffa-85d1-11eb-108e-995b8b449c62
# ╠═3832a56e-85d7-11eb-0e36-5d035ae3e079
# ╠═405f061a-85d7-11eb-1249-e55633407b36
