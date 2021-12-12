defmodule PassagePathing do
  def read_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&(String.split(&1, "-")))
    |> Enum.reduce(%{}, fn [cave_1, cave_2], acc when cave_1 != cave_2 ->
      acc
      |> add_edge(cave_1, cave_2)
      |> add_edge(cave_2, cave_1)
    end)
  end

  defp add_edge(adj_map, cave_1, cave_2) do
    # Create an adjacency list for each cave
    Map.update(adj_map, cave_1, MapSet.new([cave_2]), fn adj_list ->
      MapSet.put(adj_list, cave_2)
    end)
  end

  def traverse(adj_map, part \\ :part_1) do
    traverse(adj_map, part, [{"start", %{}, []}], MapSet.new())
  end

  defp traverse(_adj_map, _part, [], all_paths), do: all_paths
  defp traverse(adj_map, part, [{cave, explored_small, path} | rest], all_paths) do
    # Keep track of the visited node
    new_path = [cave | path]
    new_explored_small =
      if small_cave?(cave) do
        # A cave that was explored a second time can't be explored a third time,
        # so an update will only ever happen when the existing value is 1,
        # this might help catch problems when debugging
        Map.update(explored_small, cave, 1, fn 1 -> 2 end)
      else
        explored_small
      end

    new_all_paths =
      if cave == "end" do
        MapSet.put(all_paths, new_path)
      else
        all_paths
      end

    neighbor_params =
      if cave == "end" do
        []
      else # Keep going down this path and branch out to additional ones
        Map.fetch!(adj_map, cave)
        |> Enum.filter(fn neighbor_cave ->
          can_explore?(neighbor_cave, new_explored_small, part) &&
            neighbor_cave != "start" # Start cannot be explored twice
        end)
        |> Enum.map(fn neighbor_cave ->
          {neighbor_cave, new_explored_small, new_path}
        end)
      end

    traverse(adj_map, part, List.flatten(neighbor_params, rest), new_all_paths)
  end

  defp small_cave?(cave) do
    String.match?(cave, ~r/^[a-z]+$/)
  end

  defp can_explore?(cave, explored_small, :part_1) do
    !small_cave?(cave) || !Map.has_key?(explored_small, cave)
  end

  defp can_explore?(cave, explored_small, :part_2) do
    can_explore?(cave, explored_small, :part_1) || (
      Enum.count(explored_small, fn {_cave, visited} ->
        visited > 1
      end) == 0
    )
  end
end

# Part 1

PassagePathing.read_input("test_input")
|> PassagePathing.traverse()
|> Enum.count()
|> IO.inspect()

PassagePathing.read_input("large_test_input")
|> PassagePathing.traverse()
|> Enum.count()
|> IO.inspect()

PassagePathing.read_input("even_larger_test_input")
|> PassagePathing.traverse()
|> Enum.count()
|> IO.inspect()

PassagePathing.read_input("input")
|> PassagePathing.traverse()
|> Enum.count()
|> IO.inspect()

# Part 2

PassagePathing.read_input("test_input")
|> PassagePathing.traverse(:part_2)
|> Enum.count()
|> IO.inspect()

PassagePathing.read_input("large_test_input")
|> PassagePathing.traverse(:part_2)
|> Enum.count()
|> IO.inspect()

PassagePathing.read_input("even_larger_test_input")
|> PassagePathing.traverse(:part_2)
|> Enum.count()
|> IO.inspect()

PassagePathing.read_input("input")
|> PassagePathing.traverse(:part_2)
|> Enum.count()
|> IO.inspect()
