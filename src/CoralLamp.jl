module CoralLamp

using Luxor
using Luxor: offsetlinesegment
using LinearAlgebra
using Distances
using Rotations
using AngleBetweenVectors
using StaticArrays
using IntegralArrays

using IterTools
using Base.Iterators

using CSV
using DataFrames
using Statistics

export 
    svg,
    Coral2d,
    Coral3d,
    Floral2d,
    Floral3d,
    get_tile,
    angle

include("pentagonalhexecontahedron.jl")
include("util_geometry.jl")
include("util_luxor.jl")
include("coral.jl")
include("floral.jl")

end # module
