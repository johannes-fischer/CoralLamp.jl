struct Coral3d
    tip
    side_a
    side_b
    bottom_a
    bottom_b
    center
    radius
end

function Coral3d(data::PolyhedraTile, radius::Float64)
    points = [data.tip, data.side_a, data.side_b, data.bottom_a, data.bottom_b]
    center = (data.side_a + data.side_b) / 2
    push!(points, center)
    Coral3d(radius * normalize.(points)..., radius)
end

# angle at ball center between alle the tips of the shape and the star center
function angledistances(c::Coral3d)
    angle_tip_center = angle(c.tip, c.center)
    angle_side_center = (angle(c.side_a, c.center) + angle(c.side_b, c.center)) / 2
    angle_bottom_center = (angle(c.bottom_a, c.center) + angle(c.bottom_b, c.center)) / 2
    return [angle_tip_center, angle_side_center, angle_bottom_center]
end

# great circle distances between tips and star center = length of the arms in the 2D projection
armlengths(c::Coral3d) = c.radius * angledistances(c)

function angles(c::Coral3d)
    angle_tip_side = (sphere_angle(c.tip, c.center, c.side_a) + sphere_angle(c.tip, c.center, c.side_b)) / 2
    angle_bottom_side = (sphere_angle(c.bottom_a, c.center, c.side_a) + sphere_angle(c.bottom_b, c.center, c.side_b)) / 2
    angle_bottom = sphere_angle(c.bottom_a, c.center, c.bottom_b)
    return [angle_tip_side, angle_bottom_side, angle_bottom]
end

struct Coral2d
    length_tip
    length_side
    length_bottom
    rad_tip_side
    rad_side_bottom
    rad_bottom
end
Coral2d(c::Coral3d) = Coral2d(armlengths(c)..., angles(c)...)

function Base.show(io::IO, c::Coral2d)
    println(io, "Coral2d:")
    println(io, "tip: ", c.length_tip)
    println(io, "side: ", c.length_side)
    println(io, "bottom: ", c.length_bottom)
    println(io, rad2deg(c.rad_tip_side))
    println(io, rad2deg(c.rad_side_bottom))
    println(io, rad2deg(c.rad_bottom))
end

function svg(c::Coral2d, width; hole_diameter, r1=nothing, r2=nothing, bridge=1mm,
    head_diameter=nothing, head_hole_diameter=hole_diameter, test_holes=false,
    draw_skeleton=false, filename="coral.svg")
    Drawing("A4", filename)
    origin()

    tip = c.length_tip
    side = c.length_side
    bottom = c.length_bottom
    halfwidth = width / 2

    bridge_a(r) = 0.5bridge / r

    if isnothing(r1)
        r1 = side / 10 * 0.95
    end
    if isnothing(r2)
        r2 = r1 / 2 * 0.95
    end
    r_corner = [r1, r2, r2, r2, r1]

    sethue("black")
    setline(1)

    lengths = [tip, side, bottom, bottom, side]
    angles = IntegralArray([-pi / 2, c.rad_tip_side, c.rad_side_bottom, c.rad_bottom, c.rad_side_bottom])

    skeleton = [polar(l, a) for (l, a) in zip(lengths, angles)]

    # draw skeleton
    if draw_skeleton
        @layer begin
            sethue("red")
            for p in skeleton
                line(O, p, :stroke)
            end
        end
    end

    for (i, p) in enumerate(skeleton)
        d_hole = i == 1 ? head_hole_diameter : hole_diameter
        r_hole = d_hole / 2
        if bridge > 0
            arc(p, r_hole, bridge_a(r_hole), 2pi - bridge_a(r_hole))
            newsubpath()
        else
            circle(p, r_hole, :stroke)
        end
    end

    # Points for Bezier curve for smooth head piece

    if !isnothing(head_diameter)
        # Parameters for head piece
        α_head = 0.3
        l_head = 1/2 * tip
        right_pts, left_pts = head_piece_smoothing_points(first(skeleton), α_head, l_head, halfwidth, head_diameter / 2)
    end

    for (i, s1) in enumerate(skeleton)
        if bridge > 0
            newsubpath()
        end
        s2 = skeleton[i%length(skeleton)+1]

        @layer let
            if isnothing(head_diameter) || i != 1
                cap_radius = halfwidth
                cap_angle = pi / 2
            else
                cap_radius = head_diameter / 2
                cap_angle = pi / 2 + α_head
            end
            rotate(slope(O, s1))
            arc(distance(O, s1), 0, cap_radius, bridge_a(cap_radius), cap_angle)
        end
        if !isnothing(head_diameter) && i == 1
            curve(right_pts[2:4]...)
        end

        p1, corner, p2 = Luxor.offsetlinesegment(s1, O, s2, halfwidth, halfwidth)
        carc2r(cornersmooth(p1, corner, p2, r_corner[i])...)

        if !isnothing(head_diameter) && i == length(skeleton)
            p1, p2, p3, p4 = left_pts
            line(p4)
            curve(p3, p2, p1)
        end
        @layer let
            if isnothing(head_diameter) || i != length(skeleton)
                cap_radius = halfwidth
                cap_angle = -pi / 2
            else
                cap_radius = head_diameter / 2
                cap_angle = -(pi / 2 + α_head)
            end
            rotate(slope(O, s2))
            arc(distance(O, s2), 0, cap_radius, cap_angle, -bridge_a(cap_radius))
        end
    end

    if bridge == 0
        closepath()
    end
    strokepath()

    if test_holes
        draw_test_holes(-side, bridge_a)
    end

    finish()
end

function draw_test_holes(offset, bridge_a)
    space = 10mm
    diameter = 4.0mm
    n_rows = 4
    n_cols = 5
    for j in 1:n_rows, i in 1:n_cols
        p = Point(offset + i * space, -(j + 1) * space)
        radius = diameter / 2
        newpath()
        arc(p, radius, i / 2 * bridge_a(radius), 2pi, :stroke)
        diameter += 0.1mm
    end
end
