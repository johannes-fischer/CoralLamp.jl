using AngleBetweenVectors

struct Coral 
    tip
    side_a
    side_b
    bottom_a
    bottom_b
    center
    radius
end

function Coral(data::NamedTuple, radius::Float64)
    center = normalize((data.side_a + data.side_b) / 2)
    Coral(data.tip, data.side_a, data.side_b, data.bottom_a, data.bottom_b, center, radius)
end

function angles(c::Coral)
    angle_tip_center = angle(c.tip, c.center)
    angle_side_center = (angle(c.side_a, c.center) + angle(c.side_b, c.center)) / 2
    angle_bottom_center = (angle(c.bottom_a, c.center) + angle(c.bottom_b, c.center)) / 2
    return [angle_tip_center, angle_side_center, angle_bottom_center]
end

function arm_lengths(c::Coral)
    return c.radius * angles(c)
end
