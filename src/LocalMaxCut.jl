module LocalMaxCut

using Combinatorics: combinations
using Distributions

import Base: size

include("abstracttypes.jl")
include("graph.jl")
include("generator.jl")
include("pivot.jl")
include("partition.jl")
include("cut.jl")
include("flip.jl")
include("localsearch.jl")

end
