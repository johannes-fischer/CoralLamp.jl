using Luxor
using CoralLamp

t = get_tile()
diameter = 60cm

coral = Coral2d(t, diameter / 2)
print(coral)

width = diameter / 30

bridge = 0mm
hole_diameter = 5.5mm
head_hole_diameter = 9.6mm
head_diameter = head_hole_diameter + width
α_head = 0.25
l_head = 0.5

draw_test_holes = true

format = "svg"
# format = "pdf"

draw_a4(coral, width,
    bridge=bridge,
    hole_diameter=hole_diameter,
    test_holes=draw_test_holes,
    filename="coral.$format")

draw_a4(coral, width,
    bridge=bridge,
    hole_diameter=hole_diameter,
    head_diameter=head_diameter,
    head_hole_diameter=head_hole_diameter,
    α_head=α_head,
    l_head=l_head,
    test_holes=draw_test_holes,
    filename="coral_head.$format")