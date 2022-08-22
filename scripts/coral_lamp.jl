using Luxor
using CoralLamp


t = get_tile()

diameter = 60cm
radius = diameter / 2

coral = Coral2d(Coral3d(t, radius))
width = diameter / 30
hole_diameter = 5.5mm
head_hole_diameter = 9.6mm
head_diameter = head_hole_diameter + 1.2width

print(coral)

format = "svg"
# format = "pdf"
draw(coral, width, bridge=0mm, hole_diameter=hole_diameter, test_holes=true, filename="coral.$format")
draw(coral, width, bridge=0mm, hole_diameter=hole_diameter, head_diameter=head_diameter, head_hole_diameter=head_hole_diameter, test_holes=true, filename="coral_head.$format")
