struct FlipIntrospector <: AbstractIntrospector
    initial_cut::BitVector
    flipped_indices::Vector{Int}
end
export FlipIntrospector

@initialise(FlipIntrospector) do introspector, graph, graph_partition
   introspector(deepcopy(graph_partition), Int[])
end

@step!(FlipIntrospector) do introspector, graph, flip_index, flip_improvement
    push!(introspector.flipped_indices, flip_index)
end

struct FlipImprovementIntrospector{T} <: AbstractIntrospector
    improvements::Vector{T}
end
export FlipImprovementIntrospector

@initialise(FlipImprovementIntrospector) do introspector, graph, _
   introspector(eltype(graph)[])
end

@step!(FlipImprovementIntrospector) do introspector, _, _, flip_improvement
    push!(introspector.improvements, flip_improvement)
end
