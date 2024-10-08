abstract type AbstractIntrospector end
export AbstractIntrospector

function initialise end
function step! end
function deinitialise! end


step!(::A, ::Graph{T,N}, ::Int, ::T) where {N,T<:Real,A<:AbstractIntrospector} = nothing
deinitialise!(::A, ::Graph{T,N}, ::BitVector) where {N,T<:Real,A<:AbstractIntrospector} = nothing

function localsearch(introspector::Type{<:A}, graph::Graph{T,N}; pivot_rule::P=PIVOT_FIRST, partition_rule::S=PART_ZERO) where {A<:AbstractIntrospector,T<:Real,N,P<:AbstractPivot,S<:AbstractPartition}
    graph_partition = partition(partition_rule, graph)
    introspection = initialise(introspector, graph, graph_partition)

    while true
        flip_index, flip_improvement = flip(pivot_rule, graph, graph_partition)
        iszero(flip_index) && break
        graph_partition[flip_index] = ~graph_partition[flip_index]
        step!(introspection, graph, flip_index, flip_improvement)
    end

    deinitialise!(introspection, graph, graph_partition)

    introspection
end
export localsearch

macro initialise(ex, introspect_sym)
    introspect_ref = GlobalRef(__module__, introspect_sym)
    symbols = ex.args[1].args
    @assert length(symbols) == 3 "step! macro must be called with 3 arguments"
    function_definition = quote
        function $(LocalMaxCut).$(:initialise)($(symbols[1])::Type{$introspect_ref}, $(symbols[2])::Graph{T,N}, $(symbols[3])::BitVector) where {N,T<:Real}
            $(ex.args[2].args[2])
        end
    end
    function_definition
end
export @initialise

macro step!(ex, introspect_sym)
    introspect_ref = GlobalRef(__module__, introspect_sym)
    symbols = ex.args[1].args
    @assert length(symbols) == 4 "step! macro must be called with 4 arguments"
    function_definition = quote
        function $(LocalMaxCut).$(:step!)($(symbols[1])::$introspect_ref, $(symbols[2])::Graph{T,N}, $(symbols[3])::Int, $(symbols[4])::T) where {T<:Real,N}
            $(ex.args[2].args[2])
        end
    end
    function_definition
end
export @step!

macro deinitialise!(ex, introspect_sym)
    introspect_ref = GlobalRef(__module__, introspect_sym)
    symbols = ex.args[1].args
    @assert length(symbols) == 4 "step! macro must be called with 4 arguments"
    function_definition = quote
        function $(LocalMaxCut).$(:deinitialise!)($(symbols[1])::$introspect_ref, $(symbols[2])::Graph{T,N}, $(symbols[3])::BitVector) where {T<:Real,N}
            $(ex.args[2].args[2])
        end
    end
    function_definition
end

macro introspect(introspect_sym, ex)
    fnsym = popfirst!(ex.args)
    @assert fnsym == :localsearch "Introspection macro must be used with localsearch"
    pushfirst!(ex.args, introspect_sym)
    pushfirst!(ex.args, fnsym)
    esc(ex)
end
export @introspect
