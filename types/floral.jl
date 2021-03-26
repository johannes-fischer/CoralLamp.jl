using AngleBetweenVectors
using Luxor
using Rotations
# using Luxor: offsetlinesegment
# using IntegralArrays

struct Floral3d
    tip
    side_a
    side_b
    bottom_a
    bottom_b
    center
    radius
end

function Floral3d(data::PolyhedraTile, radius::Float64, stem_factor::Float64=1.0)
    stem = stem_factor * radius / 15  # length 2cm looked good for 60cm diameter -> divide radius by 15
    stem_angle = stem / radius
    axis = cross(data.tip, data.bottom_a + data.bottom_b)  # rotation axis as cross product of tip and center between two bottom (will be normalized)
    rot = AngleAxis(stem_angle, axis...)
    center = rot * data.tip
    points = [data.tip, data.side_a, data.side_b, data.bottom_a, data.bottom_b]
    push!(points, center)
    Floral3d(normalize.(points)..., radius)
end


    # For corner circles in floral
    # https://juliagraphics.github.io/Luxor.jl/stable/simplegraphics/#Circles-and-tangents
    # line intersections https://juliagraphics.github.io/Luxor.jl/stable/geometrytools/#Intersections
    