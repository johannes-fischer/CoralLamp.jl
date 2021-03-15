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

# ╔═╡ e3e05400-838a-11eb-0df6-e5b3dcba879a

mirror_y(p::Point)::Point = Point(-p.x, p.y)

# ╔═╡ e7483c8e-838a-11eb-367a-fdaa9c61cde5
mirror_x(p::Point)::Point = Point(p.x, -p.y)

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
	
	r1 = 10
	r2 = 5
	corner_radius = [r1, r2, r2, r2, r1]
	
	sethue("black")
	
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
		circle(p, 5,  :stroke)
	end
	
	for (i, s1) in enumerate(skeleton)
		@layer begin
			rotate(slope(O, s1))
			#circle(bottom, 0, 5)
			arc(distance(O, s1), 0, offset, -pi/2, pi/2)
		end
		
		s2 = skeleton[i % length(skeleton) + 1]
		p1, corner, p2 = Luxor.offsetlinesegment(s1, O, s2, offset, offset)
		carc2r(cornersmooth(p1, corner, p2, corner_radius[i])...)
	end
	
	closepath()
	strokepath()
	finish()
end

# ╔═╡ 3832a56e-85d7-11eb-0e36-5d035ae3e079
import Luxor.offsetlinesegment

# ╔═╡ 405f061a-85d7-11eb-1249-e55633407b36
#=@draw begin
	d = Drawing(800,800, "coral_test.svg")
	origin()
	side = bottom = 100
	tip = 2*side
	width = 30
	offset = width / 2
	angle = 45 / 180 * pi
	
	corner_radius1 = 15
	corner_radius2 = 5
	
	sethue("black")
	
	# draw skeletton
	@layer begin
		sethue("red")
		line(O, Point(0, -tip), :stroke)
		line(Point(side, 0), Point(-side, 0), :stroke)
		move(O)
		bottom_a = polar(bottom, angle)
		line(O, bottom_a, :stroke)
		bottom_b = polar(bottom, pi - angle)
		line(O, bottom_b, :stroke)
	end
	
	
	
	# Start new path
	#newpath()
	#line(O,O, :path)
	p1 = Point(offset, -tip)
	move(p1)
	
	c = p1 + Point(0, tip - offset)
	#line(c)
	
	p2 = c + Point(side - offset, 0)
	#line(p2)
		
	carc2r(cornersmooth(p1, c, p2, corner_radius1)...)
	 
	right_side = Point(side, 0)
	arc(right_side, offset, -pi/2, pi/2)
	
	# compute intersection point between side and angle boundaries
	side_outer = currentpoint()
	side_inner = side_outer + Point(-side, 0)
	right_bottom_center = polar(bottom, angle)
	bottom_outer = perpendicular(right_bottom_center, O, offset)
	bottom_inner = bottom_outer - right_bottom_center
	flag, side_ip =  intersectionlines(side_outer, side_inner, bottom_inner, bottom_outer, crossingonly=true)
	@assert flag
	
	_, center, _ = Luxor.offsetlinesegment(right_side, O, right_bottom_center, offset, offset)
	
	line(center)
	line(bottom_outer)
	
	@layer begin
		rotate(angle)
		#circle(bottom, 0, 5)
		arc(bottom, 0, offset, -pi/2, pi/2)
	end
	
	right_outer = currentpoint()
	right_inner = right_outer - right_bottom_center
	flag, bottom_ip =  intersectionlines(right_outer, right_inner, O, Point(0, bottom), crossingonly=true)
	@assert flag
	
	line(bottom_ip)
	line(mirror_y(right_outer))
	@layer begin
		rotate(pi - angle)
		arc(bottom, 0, offset, -pi/2, pi/2)
	end
	
	line(mirror_y(side_ip))
	line(mirror_y(side_outer))
	arc(-side, 0, offset, pi/2, 3pi/2)
	rline(side - offset, 0)
	rline(0, -(tip-offset))
	arc(0, -tip, offset, pi, 2pi)
	
	closepath()
	
	
	#line(side_inner)
	#line(bottom_inner, bottom_outer)
	
	strokepath()
	
	#circle(ip, 5)
	
		
	strokepath()
	#do_action(:stroke)
	finish()
	d
end=#

# ╔═╡ Cell order:
# ╠═24775210-7a09-11eb-34b3-9175ee4fd488
# ╠═33aa9544-7a09-11eb-05ef-9da3db67eb36
# ╠═49d7de80-7a09-11eb-139c-6b17efed44a4
# ╠═e750072c-7a0c-11eb-2b90-f5c10b7d1de2
# ╠═2537384c-8386-11eb-283c-b98a0971c685
# ╠═e3e05400-838a-11eb-0df6-e5b3dcba879a
# ╠═e7483c8e-838a-11eb-367a-fdaa9c61cde5
# ╠═e7e63e3e-838a-11eb-1a0c-39d2b41bef41
# ╠═6a92c0ba-85ce-11eb-0733-efc5f7ac0721
# ╠═0dc0cffa-85d1-11eb-108e-995b8b449c62
# ╠═3832a56e-85d7-11eb-0e36-5d035ae3e079
# ╠═405f061a-85d7-11eb-1249-e55633407b36
