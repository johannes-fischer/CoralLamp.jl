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
	Pkg.activate(Base.current_project())
	cd(joinpath(splitpath(Base.current_project())[1:end-1]))
	using CoralLamp, Luxor, PlutoUI, Revise
end

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
	w = 600
	h = 450
	@draw begin
		origin(w/2, h)
		draw(coral, width, 
			bridge=bridge, 
			hole_diameter=hole_diameter, 
			head_diameter=head_diameter, 
			head_hole_diameter=head_hole_diameter, 
			α_head=α_head,
			l_head=l_head,
			test_holes=draw_test_holes
		) 
	end w h
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

# ╔═╡ Cell order:
# ╠═82be8732-6349-11ed-0ff2-074be5a7d82d
# ╟─2f608630-b542-44d8-b913-3ca808b2a5a2
# ╟─0dbb197a-f93e-4290-b1e7-b7980d404679
# ╠═668278d7-b495-4aaf-8329-bbbde2367ac3
# ╟─77a8b185-5161-45bf-aa2e-4b6824da1e79
# ╠═16cb56b7-db7f-45c6-bc94-7e04534b05ff
# ╠═58579588-1b0c-43db-b786-fdb677c14f6c
# ╠═af6107a2-066e-4754-aff0-e31fed9a691d
# ╠═d276775c-abc7-4517-aeeb-ffa2641bd567
