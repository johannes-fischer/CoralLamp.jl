using Luxor
using CoralLamp

t = get_tile()
diameter = 60cm

floral = Floral2d(t, diameter / 2)
print(floral)

width = diameter / 30

bridge = 0mm
hole_diameter = 5.5mm
head_hole_diameter = 9.6mm
head_diameter = head_hole_diameter + width
α_head = 0.4
l_head = 1.0
h2_factor = 0.25

format = "svg"
# format = "pdf"

draw_a4(floral, width,
    bridge=bridge,
    hole_diameter=hole_diameter,
    filename="floral.$format")

draw_a4(floral, width,
    bridge=bridge,
    hole_diameter=hole_diameter,
    head_diameter=head_diameter,
    head_hole_diameter=head_hole_diameter,
    α_head=α_head,
    l_head=l_head,
    h2_factor=h2_factor,
    filename="floral_head.$format")