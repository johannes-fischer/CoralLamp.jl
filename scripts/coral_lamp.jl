using Luxor
using CoralLamp


t = get_tile()

diameter = 60cm
radius = diameter / 2

coral = Coral2d(Coral3d(t, radius))
width = diameter / 30
hole_diameter = 5mm

print(coral)

svg(coral, width, hole_diameter)
