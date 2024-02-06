struct Graph{T, N} <: AbstractGraph{T, N}
    matrix::Matrix{T}
    edges::Vector{CartesianIndex{2}}
    degrees::Vector{Int}

    function Graph(matrix::Matrix{T}, edges::Vector{CartesianIndex{2}}, degrees::Vector{Int}) where {T <: Real}
        @assert size(matrix, 1) == size(matrix, 2) == length(degrees)
        new{T, size(matrix, 1)}(matrix, edges, degrees)
    end
end
export Graph

order(::Graph{T, N}) where {T <: Real, N } = N
size(::Graph{T, N}) where {T <: Real, N } = (N, N)
matrix(::Graph{T, N}) where {T <: Real, N } = graph.matrix
edges(::Graph{T, N}) where {T <: Real, N} = graph.edges
degrees(::Graph{T, N}) where {T <: Real, N} = graph.degrees

function Graph{T, N}() where {T <: Real, N}
    @assert N > 0 "$N is not a valid graph order. It must be a positive integer."
    Graph(zeros(T, N, N), Vector{CartesianIndex{2}}(), zeros(Int, N))
end

Graph{T}(order::Int) where {T <: Real} = Graph{T, order}()

function Graph{T, N}(edges::Vector{CartesianIndex{2}}) where {T <: Real, N}
    @assert N > 0 "$N is not a valid graph order. It must be a positive integer."

    degrees = zeros(Int, N)
    degrees[getindex.(edges, 1)] .+= 1
    degrees[getindex.(edges, 2)] .+= 1

    Graph(zeros(T, N, N), edges, degrees)
end

Graph{T}(order::Int, edges::Vector{CartesianIndex{2}}) where {T} = Graph{T, order}(edges)
Graph(order::Int, edges::Vector{CartesianIndex{2}}) = Graph{Float64, order}(edges)

function Graph(order::Int, edges::Vector{CartesianIndex{2}}, weights::Vector{T}) where {T <: Real}
    @assert order > 0 "$order is not a valid graph order. It must be a positive integer."
    @assert length(weights) == length(edges) "The number of weights must be equal to the number of edges."

    matrix = zeros(T, order, order)

    matrix[edges] .= weights
    matrix[CartesianIndex.(reverse.(Tuple.(edges)))] .= weights
    
    degrees = zeros(Int, order)
    degrees[getindex.(edges, 1)] .+= 1
    degrees[getindex.(edges, 2)] .+= 1
        
    Graph(matrix, edges, degrees)
end
