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

"""
    Circle with radius r on a sphere with radius R. Sphere center is the origin, circle center is given by center
    (Note that the center vector is normal to the circle (plane in which it lies))
"""
struct SphereCircle
    R  # sphere radius
    # sphere center at origin
    r  # circle radius
    center  # 3d coordinates of circle center = normal of plane that intersects with sphere to produce circle
end

function sphereplaneintersection(R::Float64, plane::Plane)::SphereCircle
    @assert abs(plane.distance) <= R
    r = sqrt(R^2 - plane.distance^2)
    center = plane.distance * plane.normal
    SphereCircle(R, r, center)
end

# get tangent -> tangent is in plane -> intersection