struct ZeroPartition <: AbstractPartition end
struct RandomPartition <: AbstractPartition end

const PART_ZERO = ZeroPartition()
const PART_RANDOM = RandomPartition()

partition(::ZeroPartition, graph::Graph) = falses(order(graph))
partition(::RandomPartition, graph::Graph) = bitrand(order(graph))
