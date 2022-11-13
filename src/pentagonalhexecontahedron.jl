
struct PolyhedraTile
    tip
    side_a
    side_b
    bottom_a
    bottom_b
end

function read_vertices(filename="data/pentagonalhexecontahedron.csv")
    # Pentagonal hexecontahedron
    # vertices do not lie on a sphere! Long tips have slightly larger radius
    df = CSV.read(filename, DataFrame, header=false)
    vertices = [Vector(row) for row in eachrow(df)]
end

function get_tile()
    vertices = read_vertices()
    tip = find_tips(vertices)[1]
    get_tip_tiles(vertices, tip)[1]
end

function get_tiles(filename="data/pentagonalhexecontahedron.csv")
    vertices = read_vertices(filename)
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
    sorted = sort(1:length(vertices), by=i -> euclidean(vertices[i], vertices[j_tip]))
    # First entry is the tip j itself
    sorted[2:6]
end
