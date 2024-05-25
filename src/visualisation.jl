@recipe(GraphPlot, graph) do scene
    Attributes(
        vertex_size = 20,
        vertex_color = :black,
        edge_color = :gray,
        with_intensity = true,
    )
end

function plot!(plot::GraphPlot)
    vertices = lift(plot.graph) do graph
        N = order(graph)
        map(i -> Point{2, Float32}(cos(2π*i/N), sin(2π*i/N)), 1:N)
    end

    edge_lines = lift(plot.graph, vertices) do graph, vertices
        flatmap(edge -> (vertices[edge[1]], vertices[edge[2]]), edges(graph)) |> collect
    end

    edge_colors = lift(plot.graph, plot.with_intensity, plot.edge_color) do graph, with_intensity, edge_color
        with_intensity || return edge_color
        map(edge -> (edge_color, matrix(graph)[edge]), edges(graph))
    end

    linesegments!(plot, edge_lines, color=edge_colors)
    scatter!(plot, vertices, markersize=plot.vertex_size, color=plot.vertex_color)

    plot
end
export plot!

@recipe(CutPlot, graph, cut) do scene
    Attributes(
        vertex_size = 20,
        vertex_color = :black,
        edge_color = :gray,
        with_intensity = true,
        layout = CircularLayout()
    )
end

abstract type CutLayout end
struct Circular <: CutLayout end
struct SideBySide <: CutLayout end


function plot!(plot::CutPlot)
    vertices = lift(plot.graph, plot.cut, cut.layout) do graph, cut, layout
        N = order(graph)

        map(i -> Point{2, Int}(cut[i] ? 1 : -1, i), 1:N)
    end

    edge_lines = lift(plot.graph, plot.cut, vertices) do graph, cut, vertices
        cut_edges = Point{2, Int}[]
        for edge in edges(graph)
            if (cut[edge[1]] != cut[edge[2]])
                push!(cut_edges, vertices[edge[1]], vertices[edge[2]])
            end
        end
        cut_edges
    end

    edge_colors = lift(plot.graph, plot.with_intensity, plot.edge_color, plot.cut) do graph, with_intensity, edge_color, cut
        with_intensity || edge_color
        edge_colors = Tuple{Symbol, Float64}[]
        for edge in edges(graph)
             if (cut[edge[1]] != cut[edge[2]])
                push!(edge_colors, (edge_color, matrix(graph)[edge]))
            end
        end
        edge_colors
    end

    linesegments!(plot, edge_lines, color=edge_colors)
    scatter!(plot, vertices, markersize=plot.vertex_size, color=plot.vertex_color)

    plot
end
export plot!

function localmaxcutplot(graph::Graph; pivot_rule::P=PIVOT_FIRST, partition_rule::S=PART_ZERO) where {P <: AbstractPivot, S <: AbstractPartition}
    introspector = @introspect FlipIntrospector localsearch(graph, pivot_rule=pivot_rule, partition_rule=partition_rule)

    fig = Figure()

    ax = Axis(
        fig[1,1:3],
        limits=((-1.2, 1.2), (0, order(graph) + 1)),
        leftspinevisible=false,
        rightspinevisible=false,
        topspinevisible=false,
        bottomspinevisible=false,
        xgridvisible=false,
        ygridvisible=false,
        xticksvisible=false,
        xticklabelsvisible=false,
        yticksvisible=false,
        yticklabelsvisible=false,
        tellheight=true,
    )

    sl = Slider(fig[2, 1:3], range=0:length(introspector.flipped_indices), startvalue = 0)

    cut = lift(sl.value) do value
        iszero(value) && return introspector.initial_cut
        initial_cut = deepcopy(introspector.initial_cut)
        for i in 1:value
            flip_index = introspector.flipped_indices[i]
            initial_cut[flip_index] = ~initial_cut[flip_index]
        end
        initial_cut
    end

    cut_value = lift(cut) do cut
        @sprintf "Cut value: %.3f" cutvalue(graph, cut)
    end

    Label(fig[0, 2], cut_value, halign=:center)

    cutplot!(ax, graph, cut)

    fig
end
export localmaxcutplot

function localmaxcutanimation(filename::String, graph::Graph; pivot_rule::P=PIVOT_FIRST, partition_rule::S=PART_ZERO, framerate::Int=1) where {P <: AbstractPivot, S <: AbstractPartition}
    introspector = @introspect FlipIntrospector localsearch(graph, pivot_rule=pivot_rule, partition_rule=partition_rule)

    fig = Figure()

    ax = Axis(
        fig[1,1:3],
        limits=((-1.2, 1.2), (0, order(graph) + 1)),
        leftspinevisible=false,
        rightspinevisible=false,
        topspinevisible=false,
        bottomspinevisible=false,
        xgridvisible=false,
        ygridvisible=false,
        xticksvisible=false,
        xticklabelsvisible=false,
        yticksvisible=false,
        yticklabelsvisible=false,
        tellheight=true,
    )

    step = Observable(0)

    cut = lift(step) do value
        iszero(value) && return introspector.initial_cut
        initial_cut = deepcopy(introspector.initial_cut)
        for i in 1:value
            flip_index = introspector.flipped_indices[i]
            initial_cut[flip_index] = ~initial_cut[flip_index]
        end
        initial_cut
    end

    cut_value = lift(cut) do cut
        @sprintf "Cut value: %.3f" cutvalue(graph, cut)
    end

    Label(fig[0, 2], cut_value, halign=:center)
    cutplot!(ax, graph, cut)

    steps = range=0:length(introspector.flipped_indices)

    record(fig, filename, steps; framerate=framerate) do current_step
        step[] = current_step
    end
end
export localmaxcutanimation

macro plot(expr::Expr)
    first(expr.args) == :localsearch || throw(ArgumentError("The plot macro only works on a localsearch function call"))
    fncall = quote
        localmaxcutplot($(expr.args[2:end]...))
    end
    esc(fncall)
end
export @plot

macro animate(str::String, expr::Expr)
    first(expr.args) == :localsearch || throw(ArgumentError("The plot macro only works on a localsearch function call"))
    fncall = quote
        localmaxcutanimation($str, $(expr.args[2:end]...))
    end
    esc(fncall)
end
export @animate
