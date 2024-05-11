abstract type AbstractIntrospection end
export AbstractIntrospection

function initialise end
function step! end
export initialise, step!

macro initialise!(ex, introspect_sym)
    introspect_ref = GlobalRef(__module__, introspect_sym)
    symbols = ex.args[1].args
    @assert length(symbols) == 3 "step! macro must be called with 3 arguments"
    function_definition = quote
        function initialise($(symbols[1])::Type{$introspect_ref}, $(symbols[2])::Graph, $(symbols[3])::BitVector)
            $(ex.args[2].args[2])
        end
    end
    eval(function_definition)
end
export @initialise


macro step!(ex, introspect_sym)
    introspect_ref = GlobalRef(__module__, introspect_sym)
    symbols = ex.args[1].args
    @assert length(symbols) == 4 "step! macro must be called with 4 arguments"
    function_definition = quote
        function step!($(symbols[1])::$introspect_ref, $(symbols[2])::Graph{T, N}, $(symbols[3])::Int, $(symbols[4])::T) where {T <: Real, N}
            $(ex.args[2].args[2])
        end
    end
    eval(function_definition)
end
export @step!, step!

function localsearch(introspector::Type{<:A}, graph::Graph{T, N}; pivot_rule::P=PIVOT_FIRST, partition_rule::S=PART_ZERO) where {A <: AbstractIntrospection, T <: Real, N, P <: AbstractPivot, S <: AbstractPartition}
    graph_partition = partition(partition_rule, graph)
    introspection = initialise(introspector, graph, graph_partition)

    while true
        flip_index, flip_improvement = flip(pivot_rule, graph, graph_partition)
        iszero(flip_index) && break
        graph_partition[flip_index] = ~graph_partition[flip_index]
        step!(introspection, graph, flip_index, flip_improvement)
    end

    introspection
end
export localsearch

macro introspect(introspect_sym, ex)
    fnsym = popfirst!(ex.args)
    @assert fnsym == :localsearch "Introspection macro must be used with localsearch"
    pushfirst!(ex.args, :($(esc(introspect_sym))))
    pushfirst!(ex.args, fnsym)
    ex
end
export @introspect
