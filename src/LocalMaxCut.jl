module LocalMaxCut

using Makie: @recipe, Attributes, Point2f, linesegments!, scatter!
using Combinatorics: combinations
using Distributions
using .Iterators: flatmap

import Base: size
import Makie: plot!

include("abstracttypes.jl")

# Graphs
include("graph.jl")
include("generator.jl")


# Local Max Cut
include("cut.jl")
include("partition.jl")
include("pivot.jl")
include("flip.jl")
include("localsearch.jl")

# Introspection of Local Max Cut
include("introspect.jl")

# Visualization
include("visualisation.jl")

end
