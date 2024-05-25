module LocalMaxCut

using Makie: @recipe, Attributes, Point, linesegments!, scatter!, lift, Slider, Figure, Axis, Label, record, Observable
using Combinatorics: combinations
using Distributions
using Printf: @sprintf
using .Iterators: flatmap
using Random: bitrand

import Base: size, eltype
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
include("basic_introspects.jl")

# Visualization
include("visualisation.jl")

end
