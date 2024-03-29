function sphere_angle(a,b,c,center=[0.0,0.0,0.0])
    # Compute spherical angle at b between arc AB and BC, relative to center
    n1 = cross(b - center, a - center)
    n2 = cross(b - center, c - center)
    angle(n1, n2)
end

"""
    3d plane defined by all points x with dot(normal, x) == distance
"""
struct Plane
    normal::SVector{3}
    distance::Real
    Plane(n::SVector{3}, d::Real) = new(normalize(n), d)
end
Plane(normal::SVector{3}, p::SVector{3}) = Plane(normal, dot(normalize(normal), p))
Plane(p1::SVector{3}, p2::SVector{3}, p3::SVector{3}) = Plane(cross(p2-p1, p3-p1), p1)

projectonto(vector::SVector{3}, p::Plane) = vector + (p.distance - dot(vector, p.normal)) * p.normal

"""
    Sphere with origin as center and radius R
"""
struct Sphere
    R::Real
end
tangentplane(s::Sphere, p::SVector{3})::Plane = Plane(p, s.R)

struct Line3d
    p::SVector{3}
    dir::SVector{3}
    Line3d(p, d) = new(p, normalize(d))
end
function tangent(s::Sphere, p::SVector{3}, q::SVector{3})::Line3d
    @assert norm(p) ≈ s.R
    plane = tangentplane(s, p)
    direction = projectonto(q, plane) - p
    Line3d(p, direction)
end
projectonto(vector::SVector{3}, l::Line3d) = l.p + dot(vector - l.p, l.dir) * l.dir

"""
    Circle with radius r on a sphere with radius R. Sphere center is the origin, circle center is given by center
    (Note that the center vector is normal to the circle (plane in which it lies))
"""
struct SphereCircle
    R::Real  # sphere radius
    r::Real  # circle radius
    center::SVector{3}  # 3d coordinates of circle center = normal of plane that intersects with sphere to produce circle
end

function intersection(s::Sphere, plane::Plane)::SphereCircle
    @assert abs(plane.distance) <= s.R
    r = sqrt(s.R^2 - plane.distance^2)
    center = plane.distance * plane.normal
    SphereCircle(s.R, r, center)
end

struct Ellipse
    a::Real
    b::Real
end

function project(c::SphereCircle, tangent::Plane)
    # A sphere circle is projected as an ellipse
    # to the tangent plane in one of the circle's points A
    # The projected ellipse has a co-vertex at the point A
    proj = projectonto(c.center, tangent)
    Ellipse(c.r, norm(proj - tangent.distance * tangent.normal))
end

function head_piece_smoothing_points(tip_pt::Point, α_head, l_head, r, R, h2_factor=1.0)
    # see Pluto notebooks

    # Distances of Bezier handles in curve direction to intersect
    h1 = R / tan(α_head) - r / sin(α_head)
    h2 = l_head - R / sin(α_head) + r / tan(α_head)
    h2 *= h2_factor

    mirror_x(p::Point) = Point(-p.x, p.y)

    q1 = tip_pt + polar(R, α_head)
    q2 = q1 + polar(h1, α_head + pi / 2)
    q4 = tip_pt + Point(r, l_head)
    q3 = q4 + h2 * Point(0, -1)
    right_pts = [q1, q2, q3, q4]
    left_pts = mirror_x.(right_pts)
    right_pts, left_pts
end