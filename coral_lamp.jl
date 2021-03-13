using LinearAlgebra
using Plots
using Distances
using Luxor

include("data.jl")
include("util/spherical_geometry.jl")
include("types/coral.jl")
include("types/floral.jl")

v = get_vertices()

diameter = 60cm
radius = diameter / 2

coral = Coral3d(v, radius)
width = diameter / 30

# ### TEST - compare pythagoras error on ball surface, i.e. these values should not be equal
# # Curved lines
# angle_side_tip = acos(dot(coral.side_a, coral.tip))
# l_side_tip = R * angle_side_tip
# p,q = l_side_tip, sqrt(l_side^2 + l_tip^2)
# @show p,q
# # Flat lines
# p,q = norm(coral.tip-coral.side_a), sqrt(norm(coral.tip-coral.center)^2 + norm(coral.center-coral.side_a)^2)
# @show p,q
# p,q = norm(unnormalized[1]-unnormalized[2]), sqrt(norm(unnormalized[1]-unnormalized[6])^2 + norm(unnormalized[6]-unnormalized[2])^2)
# @show p,q
# ###

@show angles(coral)

