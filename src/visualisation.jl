@recipe(GraphPlot, graph) do scene
    Attributes(
        vertex_size = 20,
        vertex_color = :black,
        edge_color = :gray,
        with_intensity = true
    )
end

function plot!(plot::GraphPlot)
    graph = plot.graph[]
    N = order(graph)
    vertex_positions = [Point2f(cos(2π*i/N), sin(2π*i/N)) for i in 1:N]
    edge_lines = flatmap(edge -> (vertex_positions[edge[1]], vertex_positions[edge[2]]), edges(graph)) |> collect
    intensities = map(edge -> (plot.edge_color[], matrix(graph)[edge]), edges(graph))
    edge_color = plot.with_intensity[] ? intensities : plot.edge_color

    linesegments!(plot, edge_lines, color=edge_color)
    scatter!(plot, vertex_positions, markersize=plot.vertex_size, color=plot.vertex_color)

    plot
end
export plot!
