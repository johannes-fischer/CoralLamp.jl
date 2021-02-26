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
# angle_side_tip = acos(dot(v[2], v[1]))
# l_side_tip = R * angle_side_tip
# p,q = l_side_tip, sqrt(l_side^2 + l_tip^2)
# @show p,q
# # Flat lines
# p,q = norm(v[1]-v[2]), sqrt(norm(v[1]-v[6])^2 + norm(v[6]-v[2])^2)
# @show p,q
# p,q = norm(unnormalized[1]-unnormalized[2]), sqrt(norm(unnormalized[1]-unnormalized[6])^2 + norm(unnormalized[6]-unnormalized[2])^2)
# @show p,q
# ###

@show sphere_angle(v[1],coral.center,v[2]) * 180 / pi
@show sphere_angle(v[5],coral.center,v[2]) * 180 / pi
@show sphere_angle(v[5],coral.center,v[1]) * 180 / pi
@show sphere_angle(v[2],coral.center,v[3]) * 180 / pi
@show sphere_angle(v[3],coral.center,v[4]) * 180 / pi
@show sphere_angle(v[4],coral.center,v[5]) * 180 / pi

sphere_surface_area = 4 * pi * radius^2
