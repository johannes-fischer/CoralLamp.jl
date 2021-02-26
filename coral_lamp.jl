using LinearAlgebra
using Plots
using Distances

include("data.jl")
include("util/spherical_geometry.jl")
include("types/coral.jl")
include("types/floral.jl")

v = get_vertices()

diameter = 0.6
radius = diameter / 2

coral = Coral(v, radius)

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

@show sphere_angle(coral.tip,coral.center,coral.side_a) * 180 / pi
@show sphere_angle(coral.side_b,coral.center,coral.side_a) * 180 / pi
@show sphere_angle(coral.side_b,coral.center,coral.tip) * 180 / pi
@show sphere_angle(coral.side_a,coral.center,coral.bottom_a) * 180 / pi
@show sphere_angle(coral.bottom_a,coral.center,coral.bottom_b) * 180 / pi
@show sphere_angle(coral.bottom_b,coral.center,coral.side_b) * 180 / pi

sphere_surface_area = 4 * pi * radius^2
