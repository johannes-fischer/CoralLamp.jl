using LinearAlgebra
#using Plots
using Distances
using Luxor

include("data.jl")
include("util/spherical_geometry.jl")
include("util/luxor_util.jl")
include("types/coral.jl")
include("types/floral.jl")

v = get_vertices()

diameter = 60cm
radius = diameter / 2

coral = unroll(Coral3d(v, radius))
width = diameter / 30
hole_diameter = 5mm

#print(coral)

generate_svg(coral, width, hole_diameter)

