mutable struct Introspection{T <: Real}
    steps::Int
    const partition::BitVector
    const flip_counts::Vector{Int}
    const flip_degrees::Vector{Int}
    const flip_improvements::Vector{T}
    const degree_flip_counts::Dict{Int, Dict{Int, Int}}
end

steps(introspection::Introspection) = introspection.steps
partition(introspection::Introspection) = introspection.cut
flip_counts(introspection::Introspection) = introspection.flip_counts
flip_degrees(introspection::Introspection) = introspection.flip_degrees
flip_improvements(introspection::Introspection) = introspection.flip_improvements
degree_flip_counts(introspection::Introspection) = introspection.degree_flip_counts

function step!(introspection::Introspection, flip_index::Int, improvement::Float64, flip_degree::Int)
    introspection.steps += 1
    flip_counts(introspection)[flip_index] += 1
    push!(flip_degrees(introspection), flip_degree)
    push!(flip_improvements(introspection), improvement)
    toggle!(cut(introspection), flip_index)
end

function introspective_localsearch(graph::Graph{N, T}; pivot_rule::P=PIVOT_FIRST, partition_rule::S=PART_ZERO, print::Bool=false) where {N, T <: Real, P <: AbstractPivot,  S <: AbstractPartition}

    introspection = Introspection(
        0, 
        partition(partition_rule, graph), 
        zeros(Int, order(graph)), 
        Vector{Int}(), 
        Vector{T}(),
        Dict((degree, Dict{Int, Int}()) for degree in unique(degrees(graph)))
    )
    flip_instance = (cut_instance::BitVector) -> flip(pivot_rule, graph, cut_instance)

    while true 
        print && printpartition(graph, partition(introspection))
        flip_index, flip_improvement = flip_instance(cut(introspection))
        iszero(flip_index) && break
        step!(introspection, flip_index, flip_improvement, degrees(graph)[flip_index])
    end

    print && printpartition(graph, partition(introspection))

    for (index, flip_count) in enumerate(flip_counts(introspection))
        introspection.degree_flip_counts[graph.degrees[index]][flip_count] = get!(degree_flip_counts(introspection)[degrees(graph)[index]], flip_count, 0) + 1
    end 

    introspection
end
export introspective_localsearch

macro introspect(ex, kws...)
    @assert first(ex.args) == :(localsearch) "Introspection only works on localsearch function"
    #possiblekeys = (:print, :return_data)
    #for kw in kws
    #    kw.args[1] ∉ possiblekeys && throw(ArgumentError("The only keyword arguments allowed are $(possiblekeys)"))
    #end
    #data = kws[findfirst(kw -> kw.args[1] === :return_data, kws)].args[2]
    #kws = filter(kw -> kw.args[1] != :return_data, kws)
    #kwkeys = [kw.args[1] for kw in kws]
    #kwvalues = [kw.args[2] for kw in kws]
    ex.args[1] = :(introspective_localsearch)
    #kwexprs = Vector{Expr}()
    #for (key, value) in zip(kwkeys, kwvalues)
    #    push!(kwexprs, Expr(:kw, key, value))
    #end
    #push!(ex.args, kwexprs...)
    #Expr(:call, data, ex)
    esc(ex)
end
export introspect