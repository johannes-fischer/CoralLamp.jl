using AngleBetweenVectors

function sphere_angle(a,b,c,center=[0.0,0.0,0.0])
    # Compute spherical angle at b between arc AB and BC, relative to center
    n1 = cross(b - center, a - center)
    n2 = cross(b - center, c - center)
    angle(n1, n2)
end
