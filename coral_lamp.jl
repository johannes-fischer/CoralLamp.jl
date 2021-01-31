using LinearAlgebra

include("data.jl")

vertices = hcat(dual_vertices...)

# @show "Pentagonal Hexecontahedron"
# for i = 1:size(vertices)[2]
#     @show i, norm(vertices[:,i])
# end

i2x(polyhedra,i) = polyhedra[:,i]
dist(polyhedra,i,j) = norm(polyhedra[:,i] - polyhedra[:,j])

i1 = 5
n_vertices = size(vertices)[2]

pentagon = sort(1:n_vertices, by=i->dist(vertices,i,i1))[2:6]
i2 = first(pentagon)
i5 = sort(pentagon, by=i->dist(vertices,i,i2))[2]
i3,i4 = sort(1:n_vertices, by=i->dist(vertices,i,i2) + dist(vertices,i,i5))[3:4]
if dist(vertices,i2,i3) > dist(vertices,i2,i4)
    i3,i4 = i4,i3
end
# Vertices coordinates
v = [i2x(vertices, i) for i in [i1,i2,i3,i4,i5]]
center = (v[2] + v[5])/2

# using Plots
# data = v[[1,2,5,2,3,4,5,1]]
# data = hcat(data..., center)
# p1=plot(data[1,:],data[2,:],data[3,:])
# display(p1)

### TEST before normalizing all vectors to sphere
for i in 1:length(v)
    ip1 = (i) % length(v) + 1
    ip2 = (i+1) % length(v) + 1
    angle = acos(dot(v[ip2]-v[ip1],v[i]-v[ip1]) / norm(v[ip2]-v[ip1])/norm(v[i]-v[ip1])) * 180 / pi
    @show i, ip1, ip2, angle
end
###

push!(v, center)
unnormalized = deepcopy(v)
normalize!.(v)

### TEST
@show norm.(diff(v))[2:4]
###

angle_tip_center = acos(dot(v[1], v[6]))
angle_side_center = acos(dot(v[2], v[6]))
angle_side_center2 = acos(dot(v[5], v[6]))
angle_bottom_center = acos(dot(v[3], v[6]))
angle_bottom_center2 = acos(dot(v[4], v[6]))

R = 0.3

l_tip = R * angle_tip_center #Distance from center to tip
l_side = R * angle_side_center #Distance from center to the side vertices, perpendicular to the center-tip line
l_bottom = R * angle_bottom_center #Distance from center to bottom vertices

### TEST
# Curved lines
angle_side_tip = acos(dot(v[2], v[1]))
l_side_tip = R * angle_side_tip
p,q = l_side_tip, sqrt(l_side^2 + l_tip^2)
@show p,q
# Flat lines
p,q = norm(v[1]-v[2]), sqrt(norm(v[1]-v[6])^2 + norm(v[6]-v[2])^2)
@show p,q
p,q = norm(unnormalized[1]-unnormalized[2]), sqrt(norm(unnormalized[1]-unnormalized[6])^2 + norm(unnormalized[6]-unnormalized[2])^2)
@show p,q
###

function sphere_angle(a,b,c,center=[0.0,0.0,0.0])
    n1 = cross(b - center, a - center)
    n2 = cross(b - center, c - center)
    normalize!(n1)
    normalize!(n2)
    acos(dot(n1,n2))
end

sphere_angle(v[1],center,v[2]) * 180 / pi
sphere_angle(v[5],center,v[2]) * 180 / pi
sphere_angle(v[5],center,v[1]) * 180 / pi
sphere_angle(v[2],center,v[3]) * 180 / pi
sphere_angle(v[3],center,v[4]) * 180 / pi
sphere_angle(v[4],center,v[5]) * 180 / pi

sphere_surface_area = 4 * pi * R^2
