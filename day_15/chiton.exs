defmodule Chiton do
  def read_input(filename) do
    File.stream!(filename)
    |> Enum.map(&String.trim_trailing/1)
    |> read_to_cave_map()
  end

  defp read_to_cave_map(lines) do
    read_to_cave_map(lines, 0, 0, %{})
  end

  defp read_to_cave_map([], x, y, cave_map) do
    {cave_map, {x - 1, y - 1}}
  end

  defp read_to_cave_map([line | rest], _x, y, cave_map) do
    new_cave_map =
      String.to_charlist(line)
      |> Enum.with_index()
      |> Enum.reduce(cave_map, fn {char, x}, acc ->
        Map.put(acc, {x,y}, List.to_integer([char]))
      end)
    read_to_cave_map(rest, String.length(line), y + 1, new_cave_map)
  end

  def least_risk_score({cave_map, finish}) do
    # Create a map of least cost path values from {0,0} to each other node
    start = {0,0}
    least_costs =
      (for {coord, _} <- cave_map, into: %{}, do: {coord, :infinity})
      |> Map.put(start, 0)

    dijkstra(
      cave_map,
      start,
      finish,
      MapSet.new(Map.keys(cave_map)),
      least_costs
    )
    |> Map.fetch!(finish)
  end

  defp dijkstra(cave_map, curr, finish, unvisited, least_costs) do
    neighbors = Enum.filter(
      neighbors(curr),
      fn coord -> MapSet.member?(unvisited, coord) end
    )

    new_least_costs =
      Enum.reduce(neighbors, least_costs, fn neighbor, acc_least_costs ->
        tentative_cost =
          Map.fetch!(acc_least_costs, curr) + Map.fetch!(cave_map, neighbor)

        if tentative_cost < Map.fetch!(acc_least_costs, neighbor) do
          Map.put(acc_least_costs, neighbor, tentative_cost)
        else
          acc_least_costs
        end

      end)

    new_unvisited = MapSet.delete(unvisited, curr)

    if curr == finish do
      new_least_costs
    else
      next = Enum.min(
        new_unvisited,
        fn coord_a, coord_b ->
          Map.fetch!(new_least_costs, coord_a) <= Map.fetch!(new_least_costs, coord_b)
        end
      )
      dijkstra(cave_map, next, finish, new_unvisited, new_least_costs)
    end
  end

  defp neighbors({x,y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end
end

Chiton.read_input("test_input")
|> Chiton.least_risk_score()
|> IO.inspect

Chiton.read_input("input")
|> Chiton.least_risk_score()
|> IO.inspect
