using AngleBetweenVectors
using Luxor

struct Coral3d
    tip
    side_a
    side_b
    bottom_a
    bottom_b
    center
    radius
end

function Coral3d(data::NamedTuple, radius::Float64)
    center = normalize((data.side_a + data.side_b) / 2)
    Coral3d(data.tip, data.side_a, data.side_b, data.bottom_a, data.bottom_b, center, radius)
end

# angle at ball center between alle the tips of the shape and the star center
function angle_distances(c::Coral3d)
    angle_tip_center = angle(c.tip, c.center)
    angle_side_center = (angle(c.side_a, c.center) + angle(c.side_b, c.center)) / 2
    angle_bottom_center = (angle(c.bottom_a, c.center) + angle(c.bottom_b, c.center)) / 2
    return [angle_tip_center, angle_side_center, angle_bottom_center]
end

# great circle distances between tips and star center = length of the arms in the 2D projection
arm_lengths(c::Coral3d) = c.radius * angle_distances(c)

function angles(c::Coral3d)
    angle_tip_side = (sphere_angle(c.tip, c.center, c.side_a) + sphere_angle(c.tip, c.center, c.side_b)) / 2
    angle_bottom_side = (sphere_angle(c.bottom_a, c.center, c.side_a) + sphere_angle(c.bottom_b, c.center, c.side_b)) / 2
    angle_bottom = sphere_angle(c.bottom_a, c.center, c.bottom_b)
    return rad2deg.([angle_tip_side, angle_bottom_side, angle_bottom])
end

struct Coral2d
    length_tip
    length_side
    length_bottom
    angle_tip_side
    angle_bottom_side
    angle_bottom
end

unroll(c::Coral3d)::Coral2d = Coral2d(arm_lengths(c)..., angles(c)...)

function generate_svg(c::Coral2d, width, hole_diameter, corner_radius)
    # start at tip
    offset = width / 2

    d = Drawing(800, 800, "coral.svg")

    finish()

    # TEST how output SVG looks!!! is it one closed path??
    # still to read:
    # polygons and Paths
    # transofrms and matrices

    # https://juliagraphics.github.io/Luxor.jl/stable/simplegraphics/#Paths-and-positions
    # https://juliagraphics.github.io/Luxor.jl/stable/simplegraphics/#Arcs-and-curves
    # polysmooth for corner circles in coral
    # For corner circles in floral
    # https://juliagraphics.github.io/Luxor.jl/stable/simplegraphics/#Circles-and-tangents
    # line intersections https://juliagraphics.github.io/Luxor.jl/stable/geometrytools/#Intersections
    
end
