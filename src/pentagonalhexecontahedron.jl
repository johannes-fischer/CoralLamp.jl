
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
    #vertices = [[0.,0.,-3.6322],[0.,0.,3.6322],[-2.42147,0.,-2.70728],[2.42147,0.,2.70728],[-3.74093,0.,-0.714455],[3.74093,0.,0.714455],[-2.31202,0.,3.02648],[2.31202,0.,-3.02648],[-2.97388,1.2495,-1.66963],[2.97388,1.2495,1.66963],[-3.20333,-1.64692,-0.468228],[3.20333,-1.64692,0.468228],[-2.89122,-0.64303,-2.10244],[2.89122,-0.64303,2.10244],[-3.33708,1.41527,0.232068],[3.33708,1.41527,-0.232068],[-3.47888,-0.374822,0.974575],[3.47888,-0.374822,-0.974575],[-0.175393,3.59762,0.468228],[0.175393,3.59762,-0.468228],[-2.70728,-2.09705,-1.21073],[-2.70728,2.09705,-1.21073],[2.70728,-2.09705,1.21073],[2.70728,2.09705,1.21073],[-2.46401,0.973951,-2.48455],[2.46401,0.973951,2.48455],[-3.24272,0.374822,1.59285],[3.24272,0.374822,-1.59285],[-3.02794,-1.95071,0.468228],[3.02794,-1.95071,-0.468228],[-2.89419,2.18236,-0.232068],[2.89419,2.18236,0.232068],[-3.16974,-1.29605,1.21073],[-3.16974,1.29605,1.21073],[3.16974,-1.29605,-1.21073],[3.16974,1.29605,-1.21073],[-2.54667,-1.58042,-2.05174],[2.54667,-1.58042,2.05174],[-0.753368,0.64303,3.49455],[0.753368,0.64303,-3.49455],[-0.442882,-3.59762,-0.232068],[0.442882,-3.59762,0.232068],[-0.40484,-3.20021,1.66963],[0.40484,-3.20021,-1.66963],[-1.10352,-1.2495,3.22706],[1.10352,-1.2495,-3.22706],[-0.462459,-3.3931,-1.21073],[-0.462459,3.3931,-1.21073],[0.462459,-3.3931,1.21073],[0.462459,3.3931,1.21073],[-0.530344,1.58042,3.22706],[0.530344,1.58042,-3.22706],[-0.388538,-2.62087,2.48455],[0.388538,-2.62087,-2.48455],[-2.64202,-1.41527,2.05174],[2.64202,-1.41527,-2.05174],[-0.0953548,2.99569,-2.05174],[0.0953548,2.99569,2.05174],[-2.06405,-2.82539,-0.974575],[2.06405,-2.82539,0.974575],[-2.07547,1.64692,2.48455],[2.07547,1.64692,-2.48455],[-0.180196,-0.973951,3.49455],[0.180196,-0.973951,-3.49455],[-0.888732,2.82539,2.10244],[0.888732,2.82539,-2.10244],[-2.56904,1.95071,1.66963],[2.56904,1.95071,-1.66963],[-1.21073,-2.09705,2.70728],[-1.21073,2.09705,2.70728],[1.21073,-2.09705,-2.70728],[1.21073,2.09705,-2.70728],[-1.29676,-2.99569,-1.59285],[1.29676,-2.99569,1.59285],[-1.94597,2.62087,-1.59285],[1.94597,2.62087,1.59285],[-1.41484,3.20021,-0.974575],[1.41484,3.20021,0.974575],[-1.63386,-0.330921,-3.22706],[1.63386,-0.330921,3.22706],[-2.00249,-2.18236,2.10244],[2.00249,-2.18236,-2.10244],[-0.933564,0.330921,-3.49455],[0.933564,0.330921,3.49455],[-1.87047,-3.23974,0.714455],[-1.87047,3.23974,0.714455],[1.87047,-3.23974,-0.714455],[1.87047,3.23974,-0.714455],[-1.15601,-2.00227,-3.02648],[-1.15601,2.00227,-3.02648],[1.15601,-2.00227,3.02648],[1.15601,2.00227,3.02648]]
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
    # get the five tiles corresponding to  tip with index j_tip
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
