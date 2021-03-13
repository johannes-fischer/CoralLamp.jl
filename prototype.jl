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

# ╔═╡ 2537384c-8386-11eb-283c-b98a0971c685
@draw begin
	d = Drawing(800,800, "coral_test.svg")
	origin()
	side = bottom = 100
	tip = 2*side
	width = 30
	offset = width / 2
	angle = 50 / 180 * pi
	
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
	
	#newpath()
	#line(O,O, :path)
	move(offset, -tip)
	rline(0, tip - offset)
	rline(side - offset, 0)
	arc(side, 0, offset, -pi/2, pi/2)
	
	
	# compute intersection point between side and angle boundaries
	side_outer = currentpoint()
	side_inner = side_outer + Point(-side, 0)
	right_bottom_center = polar(bottom, angle)
	bottom_outer = perpendicular(right_bottom_center, O, offset)
	bottom_inner = bottom_outer - right_bottom_center
	flag, side_ip =  intersectionlines(side_outer, side_inner, bottom_inner, bottom_outer, crossingonly=true)
	@assert flag
	
	line(side_ip)
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
end

# ╔═╡ aecd6644-8393-11eb-2ceb-d56caa349628


# ╔═╡ e7483c8e-838a-11eb-367a-fdaa9c61cde5
mirror_x(p::Point)::Point = Point(p.x, -p.y)

# ╔═╡ e7e63e3e-838a-11eb-1a0c-39d2b41bef41


# ╔═╡ Cell order:
# ╠═24775210-7a09-11eb-34b3-9175ee4fd488
# ╠═33aa9544-7a09-11eb-05ef-9da3db67eb36
# ╠═49d7de80-7a09-11eb-139c-6b17efed44a4
# ╠═e750072c-7a0c-11eb-2b90-f5c10b7d1de2
# ╠═2537384c-8386-11eb-283c-b98a0971c685
# ╠═e3e05400-838a-11eb-0df6-e5b3dcba879a
# ╠═aecd6644-8393-11eb-2ceb-d56caa349628
# ╠═e7483c8e-838a-11eb-367a-fdaa9c61cde5
# ╠═e7e63e3e-838a-11eb-1a0c-39d2b41bef41
