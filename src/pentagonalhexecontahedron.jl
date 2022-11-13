
struct PolyhedraTile
    tip
    side_a
    side_b
    bottom_a
    bottom_b
end

function read_vertices()
    # Pentagonal hexecontahedron
    # vertices do not lie on a sphere! Long tips have slightly larger radius
    filename = "data/pentagonalhexecontahedron.csv"
    df = CSV.read(filename, DataFrame, header=false)
    vertices = [Vector(row) for row in eachrow(df)]
end

function get_tile()
    vertices = read_vertices()
    tip = find_tips(vertices)[1]
    get_tip_tiles(vertices, tip)[1]
end

function get_tiles()
    vertices = read_vertices()
    tips = find_tips(vertices)
    vcat(map(j_tip->get_tip_tiles(vertices, j_tip), tips)...)
end

function find_tips(vertices)
    norms = norm.(vertices)
    tips_mask = norms .> 3.7
    findall(tips_mask)
end

function get_tip_tiles(vertices, j_tip)
    # get the five tiles corresponding to tip with index j_tip
    tiles = []
    pentagon = get_pentagon(vertices, j_tip)
    ordered = [first(pentagon)]
    deleteat!(pentagon, 1)
    while length(pentagon) > 0
        last = ordered[end]
        next = first(sort(pentagon, by=i->euclidean(vertices[i], vertices[last])))
        push!(ordered, next)
        setdiff!(pentagon, [next])
    end
    for (i_side1, i_side2) in zip(ordered, drop(ncycle(ordered, 2), 1))
        i_bottom1, i_bottom2 = sort(1:length(vertices), by=i->euclidean(vertices[i], vertices[i_side1]) + euclidean(vertices[i],vertices[i_side2]))[3:4]
        if euclidean(vertices[i_side1],vertices[i_bottom1]) > euclidean(vertices[i_side1],vertices[i_bottom2])
            i_bottom1, i_bottom2 = i_bottom2, i_bottom1
        end
        push!(tiles, PolyhedraTile(vertices[[j_tip, i_side1, i_side2, i_bottom1, i_bottom2]]...))
    end
    tiles
end

function get_pentagon(vertices, j_tip)
    sorted = sort(1:length(vertices), by=i->euclidean(vertices[i], vertices[j_tip]))
    # First entry is the tip j itself
    sorted[2:6]
end

# ### TEST if all tiles are equal or not
# tiles = get_tiles()
# corals = [Coral2d(Coral3d(t, 30.)) for t in tiles]
# r = hcat(map(c->[getfield(c,i) for i in 1:6], corals)...)
# using Statistics
# @show mean(r, dims=2)
# @show std(r, dims=2)
