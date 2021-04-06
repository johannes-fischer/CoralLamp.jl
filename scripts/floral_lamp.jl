using Luxor
using CoralLamp


t = get_tile()

diameter = 60cm
radius = diameter / 2

floral = Floral2d(Floral3d(t, radius))
width = diameter / 40 # 1.5cm for 60cm diameter
hole_diameter = 5.5mm

print(floral)

svg(floral, width, hole_diameter)
