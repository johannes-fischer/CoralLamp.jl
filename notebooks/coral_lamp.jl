### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 82be8732-6349-11ed-0ff2-074be5a7d82d
let
	using Pkg
	using Revise
	Pkg.activate(Base.current_project())
	cd(joinpath(splitpath(Base.current_project())[1:end-1]))
	using CoralLamp, Luxor, PlutoUI
end

# ╔═╡ 9eabb799-6156-4004-9a86-dcdc8b12b47d
md"# Coral"

# ╔═╡ 2f608630-b542-44d8-b913-3ca808b2a5a2
md"Diameter: $(@bind diameter_cm Slider(1:1:100, default=60))"

# ╔═╡ 0dbb197a-f93e-4290-b1e7-b7980d404679
begin
	diameter=diameter_cm*cm
	md" $diameter_cm cm"
end

# ╔═╡ 668278d7-b495-4aaf-8329-bbbde2367ac3
begin
	t = get_tile()
	
	coral = Coral2d(t, diameter / 2)
	width = diameter / 30
	
	bridge = 0mm
	hole_diameter = 5.5mm
	head_hole_diameter = 9.6mm
	default_head_diameter = head_hole_diameter + width

	draw_test_holes = true
	
	format = "svg"
	#format = "pdf"

	nothing
end

# ╔═╡ 77a8b185-5161-45bf-aa2e-4b6824da1e79
begin
	md"""Head parameters 
	
	diameter: $(@bind head_diameter Slider(width:0.01:2*width, default=default_head_diameter))
	
	α: $(@bind α_head Slider(0:0.01:1, default=0.25))
	
	l: $(@bind l_head Slider(0:0.01:1, default=0.5))
	"""
end

# ╔═╡ 16cb56b7-db7f-45c6-bc94-7e04534b05ff
head_diameter, α_head, l_head

# ╔═╡ 58579588-1b0c-43db-b786-fdb677c14f6c
let
	@draw begin
		origin()
		translate(0, 200)
		draw(coral, width, 
			bridge=bridge, 
			hole_diameter=hole_diameter, 
			head_diameter=head_diameter, 
			head_hole_diameter=head_hole_diameter, 
			α_head=α_head,
			l_head=l_head,
			test_holes=draw_test_holes
		) 
	end 600 600
end

# ╔═╡ af6107a2-066e-4754-aff0-e31fed9a691d
begin
	draw_a4(coral, width, 
		bridge=bridge, 
		hole_diameter=hole_diameter, 
		test_holes=draw_test_holes,
		filename="coral.$format")
	nothing
end

# ╔═╡ d276775c-abc7-4517-aeeb-ffa2641bd567
begin
	draw_a4(coral, width, 
		bridge=bridge, 
		hole_diameter=hole_diameter, 
		head_diameter=head_diameter, 
		head_hole_diameter=head_hole_diameter, 
		α_head=α_head,
		l_head=l_head,
		test_holes=draw_test_holes,
		filename="coral_head.$format")
	nothing
end

# ╔═╡ 276b5f43-b9c7-467f-8303-0c394a967492
md"## Tiling"

# ╔═╡ b9efa391-4c96-46e5-8e16-14f77c4312a5
canvas_width, canvas_height = 1220mm, 2440mm
#canvas_width, canvas_height = 610mm, 610mm
#canvas_width, canvas_height = 640mm, 610mm
#canvas_width, canvas_height = 970mm, 610mm

# ╔═╡ 406e6898-42b5-4bdf-8f90-c1c95d98e3ac
begin
	d = 0.1 * width
	tip = coral.length_tip
	side = coral.length_side
	width, d, tip, side
end

# ╔═╡ ffd596aa-70ae-4883-89a7-e6e2e53bca85
mirror_y(p) = Point(p.x, -p.y)

# ╔═╡ 87e8f4b3-7c39-430f-a028-f0a5af417650
function Luxor.isinside(shape_center::Point, shape_bb::BoundingBox, drawing_bb::BoundingBox)
	shifted_bb = shape_center .+ shape_bb
	all(isinside.(shifted_bb, (drawing_bb,)))
end

# ╔═╡ 88342e3d-9570-4543-9db5-0d8d1eaa5046
begin
	coral_path = construct_path(coral, width, 
		bridge=bridge, hole_diameter=hole_diameter)
	bb = BoundingBox(coral_path)
	newpath()
	rotated_bb = BoundingBox(mirror_y.(bb))
	bb, rotated_bb
end

# ╔═╡ fda16479-193a-4679-83b9-f150bb4d8534
# only draw shapes that are fully contained in drawing
draw_only_complete = true

# ╔═╡ 8cbf6e97-1f43-49e3-8303-9edbc386cf6e
begin
	layout = 1
	name = "coral_tiling_v$layout.svg"
	n_tiles = 0
	@svg begin
		nrows = 17
		ncols = 13
		
		# In large drawings, additional rows/cols can be added to also reach the top right and bottom left corners, since the area filled with shapes is a parallelogram
		offset_rows = 1
		offset_cols = 1
	
		if layout == 1
			initial_offset = Point(side*1.15, side*1.05)
			horizontal_offset = Point(2*(side+width+d), 0)
			vertical_offset = Point(0, 1.38 * tip)
			pair_offset = Point((side+width+d), 0.4*(tip+width+d))
		elseif layout == 2
			initial_offset = Point(side*1.15, side*1.05)
			horizontal_offset = Point(side+2width+2d, (width+d))
			vertical_offset = Point(-3width-d, 2tip+2d)
			pair_offset = Point((width+d), tip+width+d)
		elseif layout == 3
			initial_offset = Point(width+d+side*1.15, side*1.05)
			horizontal_offset = Point(side+2width+d, (width+d))
			vertical_offset = Point(width, 2tip+width+2d)
			pair_offset = Point(-(width+d), tip+width+d)
		end
		
		origin(O)
		drawing_bb = BoundingBox(centered=false)
		translate(initial_offset)
	
		for _ in 1:offset_rows
			translate(-vertical_offset)
		end
		for _ in 1:offset_cols
			translate(-horizontal_offset)
		end
		
		for _ in 1:nrows
			@layer for _ in 1:ncols
				@layer begin
					rotate(π)
					if !draw_only_complete || isinside(getworldposition(centered=false), rotated_bb, drawing_bb)
						drawpath(coral_path, action=:stroke)
						n_tiles += 1
					end
				end
				@layer begin
					translate(pair_offset)
					if !draw_only_complete || isinside(getworldposition(centered=false), bb, drawing_bb)
						drawpath(coral_path, action=:stroke)
						n_tiles += 1
					end
				end
				translate(horizontal_offset)
			end
			translate(vertical_offset)
		end
	end canvas_width canvas_height name
end

# ╔═╡ 0320fdfc-90ae-40d3-b65f-f5d595646cd0
n_tiles

# ╔═╡ Cell order:
# ╟─9eabb799-6156-4004-9a86-dcdc8b12b47d
# ╠═82be8732-6349-11ed-0ff2-074be5a7d82d
# ╟─2f608630-b542-44d8-b913-3ca808b2a5a2
# ╟─0dbb197a-f93e-4290-b1e7-b7980d404679
# ╠═668278d7-b495-4aaf-8329-bbbde2367ac3
# ╟─77a8b185-5161-45bf-aa2e-4b6824da1e79
# ╠═16cb56b7-db7f-45c6-bc94-7e04534b05ff
# ╠═58579588-1b0c-43db-b786-fdb677c14f6c
# ╠═af6107a2-066e-4754-aff0-e31fed9a691d
# ╠═d276775c-abc7-4517-aeeb-ffa2641bd567
# ╟─276b5f43-b9c7-467f-8303-0c394a967492
# ╠═b9efa391-4c96-46e5-8e16-14f77c4312a5
# ╠═0320fdfc-90ae-40d3-b65f-f5d595646cd0
# ╠═406e6898-42b5-4bdf-8f90-c1c95d98e3ac
# ╠═ffd596aa-70ae-4883-89a7-e6e2e53bca85
# ╠═87e8f4b3-7c39-430f-a028-f0a5af417650
# ╠═88342e3d-9570-4543-9db5-0d8d1eaa5046
# ╠═fda16479-193a-4679-83b9-f150bb4d8534
# ╠═8cbf6e97-1f43-49e3-8303-9edbc386cf6e
