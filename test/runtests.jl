using Test
using CoralLamp
using Statistics

@testset "input data" begin
    # test if all tiles are equal
    tiles = CoralLamp.get_tiles("../data/pentagonalhexecontahedron.csv")
    corals = [Coral2d(t, 30.0) for t in tiles]
    r = hcat(map(c -> [getfield(c, i) for i in 1:6], corals)...)
    @test maximum(std(r, dims=2)) <= 1e-3
end