function localsearch(graph::Graph; pivot_rule::P=PIVOT_FIRST, partition_rule::S=PART_ZERO) where {P <: AbstractPivot,  S <: AbstractPartition}
    graph_partition = partition(partition_rule, graph)
    steps = 0

    pivot_rule = initialise(pivot_rule, graph)

    while true
        flip_index, _ = flip(pivot_rule, graph, graph_partition)
        iszero(flip_index) && break
        graph_partition[flip_index] = ~graph_partition[flip_index]
        steps += 1
    end

    steps
end
export localsearch
