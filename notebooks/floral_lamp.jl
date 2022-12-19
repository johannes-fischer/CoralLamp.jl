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
	using CoralLamp, Luxor, PlutoUI, Revise
end

# ╔═╡ 4853143c-35af-4d07-81e1-ca870e7c163a
md"# Floral"

# ╔═╡ 2f608630-b542-44d8-b913-3ca808b2a5a2
md"Diameter: $(@bind diameter_cm Slider(1:1:100, default=60))


Width: $(@bind width_factor Slider(0.5:0.01:1.0, default=1.0))
"

# ╔═╡ 0dbb197a-f93e-4290-b1e7-b7980d404679
begin
	diameter=diameter_cm*cm
	width_cm = width_factor * diameter_cm / 30
	
	md"""Diameter: $diameter_cm cm
	
	Width: $width_cm cm"""
end

# ╔═╡ 668278d7-b495-4aaf-8329-bbbde2367ac3
begin
	t = get_tile()
	
	floral = Floral2d(t, diameter / 2)
	width = width_factor * diameter / 30
	
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
md"""Head parameters 

diameter: $(@bind head_diameter Slider(width:0.01:2*width, default=default_head_diameter))

α: $(@bind α_head Slider(0:0.01:1, default=0.4))

l: $(@bind l_head Slider(0:0.01:1, default=1.0))

h2: $(@bind h2_factor Slider(0:0.01:1, default=0.25))
"""


# ╔═╡ 16cb56b7-db7f-45c6-bc94-7e04534b05ff
head_diameter, α_head, l_head, h2_factor

# ╔═╡ 58579588-1b0c-43db-b786-fdb677c14f6c
let
	@draw begin
		origin()
		translate(0, 150)
		draw(floral, width, 
			bridge=bridge, 
			hole_diameter=hole_diameter, 
			head_diameter=head_diameter, 
			head_hole_diameter=head_hole_diameter, 
			α_head=α_head,
			l_head=l_head,
			h2_factor=h2_factor,
		) 
	end 600 450
end

# ╔═╡ af6107a2-066e-4754-aff0-e31fed9a691d
begin
	draw_a4(floral, width, 
		bridge=bridge, 
		hole_diameter=hole_diameter, 
		filename="floral.$format")
	nothing
end

# ╔═╡ d276775c-abc7-4517-aeeb-ffa2641bd567
begin
	draw_a4(floral, width, 
		bridge=bridge, 
		hole_diameter=hole_diameter, 
		head_diameter=head_diameter, 
		head_hole_diameter=head_hole_diameter, 
		α_head=α_head,
		l_head=l_head,
		h2_factor=h2_factor,
		filename="floral_head.$format")
	nothing
end

# ╔═╡ 242f268d-6c05-4c6b-bc45-ee50a7911750
md"## Tiling"

# ╔═╡ 523f7e5c-6375-42eb-9aeb-f3f88ea6cb8d
#canvas_width, canvas_height = 1220mm, 2440mm
canvas_width, canvas_height = 610mm, 610mm
#canvas_width, canvas_height = 640mm, 610mm
#canvas_width, canvas_height = 970mm, 610mm

# ╔═╡ f5a5cd97-2b3f-4229-bc5a-8bc335e6ae6f
begin
	d = 0.1 * width
	length = floral.stem + floral.inner_r * sin(floral.inner_rad)
	side = floral.outer_r * (1-cos(floral.outer_rad))
	width, d, length, side
end

# ╔═╡ cffded6d-c8dc-43ae-8a2b-e52b525e906f
mirror_y(p) = Point(p.x, -p.y)

# ╔═╡ 4f34b349-5de3-48f8-846f-dbfae2197152
function Luxor.isinside(shape_center::Point, shape_bb::BoundingBox, drawing_bb::BoundingBox)
	shifted_bb = shape_center .+ shape_bb
	all(isinside.(shifted_bb, (drawing_bb,)))
end

# ╔═╡ be11b677-cbc6-4654-949b-285987f78621
begin
	floral_path = construct_path(floral, width, 
		bridge=bridge, hole_diameter=hole_diameter)
	bb = BoundingBox(floral_path)
	newpath()
	rotated_bb = BoundingBox(mirror_y.(bb))
	bb, rotated_bb
end

# ╔═╡ 036fccf7-951e-4b1c-bee5-25058e207768
# only draw shapes that are fully contained in drawing
draw_only_complete = false

# ╔═╡ f8fcd667-2231-4090-8b78-de71f8008d48
md"""
pair offset x $(@bind pair_offset_x Slider(1:0.01:2, default=1.36, show_value=true))

pair offset y $(@bind pair_offset_y Slider(0:0.01:2, default=0.65, show_value=true))

vertical offset $(@bind vert_offset Slider(0:0.01:1, default=0.77, show_value=true))
"""

# ╔═╡ adf967ff-7856-4317-a162-168c4e67b84d
begin
	layout1 = 1
	name = "floral_tiling_v$layout1.svg"
	n_tiles = 0
	@svg begin
		nrows = 2
		ncols = 2
		
		# In large drawings, additional rows/cols can be added to also reach the top right and bottom left corners, since the area filled with shapes is a parallelogram
		offset_rows = 0
		offset_cols = 0
	
		if layout1 == 1
			x_offset = 1.36 * side
			initial_offset = Point(d + width/2 + side, 0.92*length + d)
			horizontal_offset = Point(2x_offset+2d, 0)
			vertical_offset = Point(0, 0.77*length+2d)
			pair_offset = Point(x_offset + d, -0.65*length - d)
		elseif layout1 == 2
			x_offset = 1.46 * side
			initial_offset = Point(d + width/2 + side, 0.92*length + d)
			horizontal_offset = Point(2x_offset + 2d, 0)
			vertical_offset = Point(0, 0.77*length+2d)
			pair_offset = Point(x_offset + d, -1.02*length - d)
		elseif layout1 == 3
			#x_offset = 1.36 * side
			#initial_offset = Point(d + width/2 + side, 0.92*length + d)
			#horizontal_offset = Point(2x_offset+2d, 0)
			#vertical_offset = Point(0, 0.77*length+2d)
			#pair_offset = Point(x_offset + d, -0.65*length - d)
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
						drawpath(floral_path, action=:stroke)
						n_tiles += 1
					end
				end
				@layer begin
					translate(pair_offset)
					if !draw_only_complete || isinside(getworldposition(centered=false), bb, drawing_bb)
						drawpath(floral_path, action=:stroke)
						n_tiles += 1
					end
				end
				translate(horizontal_offset)
			end
			translate(vertical_offset)
		end
	end canvas_width canvas_height name
end

# ╔═╡ f2462edc-37b4-4d92-9711-13078239c8db
n_tiles

# ╔═╡ Cell order:
# ╟─4853143c-35af-4d07-81e1-ca870e7c163a
# ╠═82be8732-6349-11ed-0ff2-074be5a7d82d
# ╟─2f608630-b542-44d8-b913-3ca808b2a5a2
# ╟─0dbb197a-f93e-4290-b1e7-b7980d404679
# ╠═668278d7-b495-4aaf-8329-bbbde2367ac3
# ╟─77a8b185-5161-45bf-aa2e-4b6824da1e79
# ╠═16cb56b7-db7f-45c6-bc94-7e04534b05ff
# ╠═58579588-1b0c-43db-b786-fdb677c14f6c
# ╠═af6107a2-066e-4754-aff0-e31fed9a691d
# ╠═d276775c-abc7-4517-aeeb-ffa2641bd567
# ╟─242f268d-6c05-4c6b-bc45-ee50a7911750
# ╠═523f7e5c-6375-42eb-9aeb-f3f88ea6cb8d
# ╠═f2462edc-37b4-4d92-9711-13078239c8db
# ╠═f5a5cd97-2b3f-4229-bc5a-8bc335e6ae6f
# ╠═cffded6d-c8dc-43ae-8a2b-e52b525e906f
# ╠═4f34b349-5de3-48f8-846f-dbfae2197152
# ╠═be11b677-cbc6-4654-949b-285987f78621
# ╠═036fccf7-951e-4b1c-bee5-25058e207768
# ╠═f8fcd667-2231-4090-8b78-de71f8008d48
# ╠═adf967ff-7856-4317-a162-168c4e67b84d
