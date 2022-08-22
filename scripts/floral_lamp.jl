using Luxor
using CoralLamp


t = get_tile()

diameter = 60cm
radius = diameter / 2

floral = Floral2d(Floral3d(t, radius))
width = diameter / 30 # 2.0cm for 60cm diameter
hole_diameter = 5.5mm
head_hole_diameter = 9.6mm
head_diameter = head_hole_diameter + 1.2width

print(floral)

# format = "svg"
format = "pdf"
draw(floral, width, bridge=0mm, hole_diameter=hole_diameter, filename="floral.$format")
draw(floral, width, bridge=0mm, hole_diameter=hole_diameter, head_diameter=head_diameter, head_hole_diameter=head_hole_diameter, filename="floral_head.$format")
