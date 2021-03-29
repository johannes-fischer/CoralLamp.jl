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

struct Floral2d 
    stem::Float64
    outerright::CircleSegment
    innerright::CircleSegment
    innerleft::CircleSegment
    outerleft::CircleSegment
end
function Floral2d(f::Floral3d)
    # tangent in center through tip is tangent to all circular arcs 
    # Circular arcs can be determined by intersecting the sphere with a plane
    # The tangent has to be in this plane ue to symmetry of small circles on a sphere
    sphere = Sphere(f.radius)
    tangent = tangent(sphere, f.center, f.tip)
    tangent_plane = tangentplane(sphere, f.center)

    # Compute the projected radius of the circle on the sphere
    # All circles meet in the floral center, at which the tangent plane is
    # The floral center forms a co-vertex of the projected ellipse

    # for each side, bottom
    circle_plane = Plane(f.center, f.center + tangent.dir, f.side_a)
    circle = intersection(sphere, circle_plane)
    e = project(circle, tangent_plane)
    # The radius of curvature at the co-vertices of an ellipse is given by a^2/b
    # https://en.wikipedia.org/wiki/Ellipse#Curvature
    # This should give the correct unrolled radius, since locally the sphere circle
    # looks like an ellipse projection (?)
    r = e.a^2 / e.b

    # compute arc length of circle as length of small circle segment
    # compute circle centers

    

end


    # For corner circles in floral
    # https://juliagraphics.github.io/Luxor.jl/stable/simplegraphics/#Circles-and-tangents
    # line intersections https://juliagraphics.github.io/Luxor.jl/stable/geometrytools/#Intersections
    