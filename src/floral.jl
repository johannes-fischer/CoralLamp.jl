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
    Floral3d(radius*normalize.(points)..., radius)
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


## Todos: integrate floral drawing from prototype to real script
## make use of new floral2d structure

function svg(f::Floral2d, width, hole_diameter, r1=nothing, r2=nothing, bridge=1mm)
    Drawing("A4", "floral.svg")
    origin()
	# translate(0, -200)
	stem = f.stem
    segments = [f.outerright, f.innerright, f.innerleft, f.outerleft]
	offset = width / 2
	
	# draw skeleton
	@layer begin
		sethue("red")
		line(O, Point(0, -stem), :stroke)
		for segment in segments
            x = -segment.orientation * segment.r
            y = 0
			if segment.orientation > 0
				arc(x, y, segment.r, 0, segment.rad, :stroke)
			else
				carc(x, y, segment.r, pi, pi - segment.rad, :stroke)
			end
		end
	end
    # COMPUTE END POINTS AND USE THEM TO DRAW ARCS!
    # necessary to draw holes

	sethue("black")
	setline(1)


    

    # For corner circles in floral
    # https://juliagraphics.github.io/Luxor.jl/stable/simplegraphics/#Circles-and-tangents
    # line intersections https://juliagraphics.github.io/Luxor.jl/stable/geometrytools/#Intersections
    
	# strokepath()
	
    finish()
end

