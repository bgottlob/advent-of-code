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

  def least_risk_score({cave_map, orig_finish}, map_size \\ :small) do
    # Create a map of least cost path values from {0,0} to each other node
    start = {0,0}
    finish = case map_size do
      :small -> orig_finish
      :large -> transform_coord(orig_finish, 5)
    end

    dijkstra(
      cave_map,
      map_size,
      start,
      orig_finish,
      finish,
      MapSet.new(),
      %{start => 0}
    )
    |> Map.fetch!(finish)
  end

  defp transform_coord({x, y}, mult) do
    {(x + 1) * mult - 1, (y + 1) * mult - 1}
  end

  defp dijkstra(cave_map, map_size, curr, orig_finish, finish, visited, least_costs) do
    neighbors = Enum.filter(
      neighbors(curr, finish),
      fn coord -> !MapSet.member?(visited, coord) end
    )

    new_least_costs =
      Enum.reduce(neighbors, least_costs, fn neighbor, acc_least_costs ->
        tentative_cost =
          Map.fetch!(acc_least_costs, curr) +
            cave_map_cost(cave_map, orig_finish, neighbor)

        if tentative_cost < Map.get(acc_least_costs, neighbor, :infinity) do
          Map.put(acc_least_costs, neighbor, tentative_cost)
        else
          acc_least_costs
        end

      end)

    new_visited = MapSet.put(visited, curr)

    if curr == finish do
      new_least_costs
    else
      # of all coordinates with some tentative cost
      # do not consider visited nodes
      # find the coordinate with the lowest tentative cost
      {next, _} =
        new_least_costs
        |> Enum.filter(fn {coord, _} -> !MapSet.member?(new_visited, coord) end)
        |> Enum.min(fn {_, cost_a}, {_, cost_b} ->
          cost_a <= cost_b
        end)

      dijkstra(cave_map, map_size, next, orig_finish, finish, new_visited, new_least_costs)
    end
  end

  def cave_map_cost(cave_map, {ofx, ofy}, {x,y} = coord) do
    case Map.fetch(cave_map, coord) do
      {:ok, cost} -> cost
      :error ->
        # Boundaries of small map
        width = ofx + 1
        height = ofy + 1

        source = {rem(x, width), rem(y, height)}
        add = div(x, width) + div(y, height)

        source_cost = Map.fetch!(cave_map, source)

        case rem(source_cost + add, 9) do
          0 -> 9
          final -> final
        end
    end
  end

  defp neighbors({x,y}, {fx, fy}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(fn {ax, ay} ->
      ax >= 0 && ay >= 0 && ax <= fx && ay <= fy
    end)
  end
end

Chiton.read_input("test_input")
|> Chiton.least_risk_score()
|> IO.inspect

Chiton.read_input("input")
|> Chiton.least_risk_score()
|> IO.inspect

Chiton.read_input("test_input")
|> Chiton.least_risk_score(:large)
|> IO.inspect

Chiton.read_input("input")
|> Chiton.least_risk_score(:large)
|> IO.inspect
