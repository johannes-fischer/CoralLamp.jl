struct Floral3d
    tip::SVector{3}
    side_a::SVector{3}
    side_b::SVector{3}
    bottom_a::SVector{3}
    bottom_b::SVector{3}
    center::SVector{3}
    radius::Float64
end

function Floral3d(data::PolyhedraTile, radius::Float64, stem_factor::Float64=1.0)
    stem = stem_factor * radius / 15  # length 2cm looked good for 60cm diameter -> divide radius by 15
    stem_angle = stem / radius
    axis = cross(data.tip, data.bottom_a + data.bottom_b)  # rotation axis as cross product of tip and center between two bottom (will be normalized)
    rot = AngleAxis(stem_angle, axis...)
    center = rot * data.tip
    points = [data.tip, data.side_a, data.side_b, data.bottom_a, data.bottom_b]
    push!(points, center)
    Floral3d(radius * normalize.(points)..., radius)
end

struct Floral2d
    stem::Float64
    outer_r::Float64
    outer_rad::Float64
    inner_r::Float64
    inner_rad::Float64
end
function Floral2d(f::Floral3d)
    stem = f.radius * angle(f.tip, f.center)

    # tangent in center through tip is tangent to all circular arcs
    # Circular arcs can be determined by intersecting the sphere with a plane
    # The tangent has to be in this plane ue to symmetry of small circles on a sphere
    sphere = Sphere(f.radius)
    tangent_line = tangent(sphere, f.center, f.tip)
    tangent_plane = tangentplane(sphere, f.center)

    # Compute the projected radius of the circle on the sphere
    # All circles meet in the floral center, at which the tangent plane is located
    # The floral center forms a co-vertex of the projected ellipse
    arcs = []
    for pt in [f.side_a, f.side_b, f.bottom_a, f.bottom_b]
        circle_plane = Plane(f.center, f.center + tangent_line.dir, pt)
        circle = intersection(sphere, circle_plane)
        println(circle)
        e = project(circle, tangent_plane)
        # The radius of curvature at the co-vertices of an ellipse is given by a^2/b
        # https://en.wikipedia.org/wiki/Ellipse#Curvature
        # This should give the correct unrolled radius, since locally the sphere circle
        # looks like an ellipse projection (?)
        r = e.a^2 / e.b

        L = circle.r * angle(f.center - circle.center, pt - circle.center) # length of circular arc
        α = L / r # arc length of unrolled circular arc

        # compute tangent plane spanning vector orthogonal to tangent vector
        # determine sign of projection of pt onto this vector
        # (should be positive on side a and negative on side b or vice versa)
        # NOW UNUSED
        # sgn = sign(dot(pt, cross(tangent_line.dir, tangent_plane.normal)))
        push!(arcs, [r, α])
    end
    outer = mean(arcs[1:2])
    inner = mean(arcs[3:4])
    Floral2d(stem, outer..., inner...)
end



# For corner circles in floral
# https://juliagraphics.github.io/Luxor.jl/stable/simplegraphics/#Circles-and-tangents
# line intersections https://juliagraphics.github.io/Luxor.jl/stable/geometrytools/#Intersections

# strokepath()


function svg(f::Floral2d, width; hole_diameter, r1=nothing, r2=nothing, bridge=1mm,
    head_diameter=nothing, head_hole_diameter=hole_diameter,
    draw_skeleton=false, filename="floral.svg")
    Drawing("A4", filename)
    origin()
    (; stem, outer_r, inner_r, outer_rad, inner_rad) = f
    translate(0, -3stem)

    halfwidth = width / 2

    tip_pt = Point(0, -stem)

    bridge_a(r) = 0.5bridge / r
    r_hole = hole_diameter / 2

    if isnothing(r1)
        r1 = halfwidth / 2.5
    end
    if isnothing(r2)
        r2 = r1
    end

    ##### start

    segments_ = [
        (Point(outer_r, 0), polar(outer_r, pi - outer_rad)),
        (Point(inner_r, 0), polar(inner_r, pi - inner_rad)),
        (Point(-inner_r, 0), polar(inner_r, inner_rad)),
        (Point(-outer_r, 0), polar(outer_r, outer_rad)),
    ]
    segments = [FloralLeaf(c, c + p) for (c, p) in segments_]

    if draw_skeleton
        # draw skeleton
        @layer begin
            sethue("red")
            line(O, tip_pt, :stroke)
            for f in segments
                c = f.center
                p = f.leaf
                args = (c, O, p)
                isarcclockwise(O, -c, p - c) ? arc2r(args..., :stroke) : carc2r(args..., :stroke)
            end
        end
    end

    holes = [f.leaf for f in segments]
    pushfirst!(holes, tip_pt)

    for (i, p) in enumerate(holes)
        d_hole = i == 1 ? head_hole_diameter : hole_diameter
        r_hole = d_hole / 2
        if bridge > 0
            arc(p, r_hole, bridge_a(r_hole), 2pi - bridge_a(r_hole))
            newsubpath()
        else
            circle(p, r_hole, :stroke)
        end
    end

    f1, f2, f3, f4 = segments
    if isnothing(head_diameter)
        head_radius = halfwidth
        head_angle = 0
    else
        # Parameters for head piece
        α_head = 0.4
        l_head = stem
        right_pts, left_pts = head_piece_smoothing_points(tip_pt, α_head, l_head, halfwidth, head_diameter / 2)

        head_radius = head_diameter / 2
        head_angle = α_head
    end

    # RIGHT HALF OF STEM
    arc(tip_pt, head_radius, -pi / 2 + bridge_a(head_radius), head_angle)

    if !isnothing(head_diameter)
        curve(right_pts[2:4]...)
    end

    start = halfwidth / distance(f1) * f1.center
    carc2r(f1.center, start, f1.leaf)

    # OUTER RIGHT TIP
    drawsegmentcap(f1, halfwidth, bridge_a(halfwidth))
    cornersmooth(f1, f2, halfwidth + r1)
    # INNER RIGHT TIP
    drawsegmentcap(f2, halfwidth, bridge_a(halfwidth))
    cornersmooth(f2, f3, halfwidth + r2)
    # INNER LEFT TIP
    drawsegmentcap(f3, halfwidth, bridge_a(halfwidth))
    cornersmooth(f3, f4, halfwidth + r1)
    # OUTER LEFT TIP
    drawsegmentcap(f4, halfwidth, bridge_a(halfwidth))

    carc2r(f4.center, currentpoint(), O)

    if !isnothing(head_diameter)
        p1, p2, p3, p4 = left_pts
        line(p4)
        curve(p3, p2, p1)
    end

    # LEFT HALF OF STEM
    arc(tip_pt, head_radius, -pi - head_angle, -pi / 2 - bridge_a(head_radius))

    if bridge == 0
        closepath()
    end
    strokepath()

    finish()
end

struct FloralLeaf
    center::Point
    leaf::Point
end

Luxor.slope(f::FloralLeaf) = slope(f.center, f.leaf)
Luxor.distance(f::FloralLeaf) = distance(f.center, f.leaf)

function drawsegmentcap(f::FloralLeaf, offset, bridge)
    @layer begin
        translate(f.leaf)
        α = slope(f)
        (f.center.x > 0) && (α += pi)
        rotate(α)
        arc(O, offset, 0, pi / 2 - bridge)
        (bridge > 0) && newsubpath()
        arc(O, offset, pi / 2 + bridge, pi)
    end
end

function cornersmooth(f1::FloralLeaf, f2::FloralLeaf, offset)
    if distance(f1) ≈ distance(f2)
        sgn = 1, 1
    elseif distance(f1) < distance(f2)
        sgn = 1, -1
    else
        sgn = -1, 1
    end
    cornersmooth(f1, f2, offset, sgn...)
end

function cornersmooth(f1::FloralLeaf, f2::FloralLeaf, offset, sgn1, sgn2)
    flag, p, q = intersectioncirclecircle(f1.center, distance(f1) + sgn1 * offset, f2.center, distance(f2) + sgn2 * offset)
    @assert flag
    if p.y < 0
        p, q = q, p
    end
    sgnarc2r(sgn1)(f1.center, currentpoint(), p)

    c2, p2 = f2.center, f2.leaf
    carc2r(p, currentpoint(), circlecentertangent(c2, distance(f2), p))
    sgnarc2r(sgn2)(c2, currentpoint(), p2)

end

function circlecentertangent(c::Point, r::Float64, p::Point)
    α = r / distance(c, p)
    α * p + (1 - α) * c
end

sgnarc2r(sgn) = sgn > 0 ? arc2r : carc2r