defmodule SmokeBasin do
  alias SmokeBasin.HeightMap
  def read_input(filename) do
    File.read!(filename)
    |> String.split("")
    |> HeightMap.from_chars()
  end

  def total_risk_level(heightmap) do
    HeightMap.low_points(heightmap)
    |> Stream.map(&(elem(&1, 0)))
    |> Stream.map(&(&1 + 1))
    |> Enum.sum()
  end

  def largest_basins_score(heightmap) do
    HeightMap.basins(heightmap)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.slice(0,3)
    |> Enum.product()
  end
end

defmodule SmokeBasin.HeightMap do
  defstruct [:max_x, :max_y, :map]

  # ["3", "2", "4", "\n"], ["1", "5", "6"]
  # %HeightMap{
  #  max_x: 2,
  #  max_y: 1,
  #  map: %{
  #   {0,0} => 3
  #   {1,0} => 2
  #   {2,0} => 4
  #   {0,1} => 1
  #   {1,1} => 5
  #   {2,1} => 6
  #  }
  # }
  def from_chars(chars) do
    from_chars(chars, 0, %__MODULE__{max_x: 0, max_y: 0, map: %{}})
  end

  defp from_chars([], _x_counter, heightmap) do
    Map.update!(heightmap, :max_y, &(&1 - 1))
  end

  defp from_chars(["" | rest], x_counter, heightmap) do
    from_chars(rest, x_counter, heightmap)
  end

  defp from_chars(["\n" | rest], x_counter, heightmap) do
    new_heightmap =
      heightmap
      |> Map.put(:max_x, x_counter - 1)
      |> Map.update!(:max_y, &(&1 + 1))

    from_chars(rest, 0, new_heightmap)
  end

  defp from_chars([height | rest], x_counter, heightmap) do
    coord = {x_counter, heightmap.max_y}
    height = String.to_integer(height)
    new_heightmap = put_height(heightmap, coord, height)

    from_chars(rest, x_counter + 1, new_heightmap)
  end

  defp put_height(heightmap, coord, height) do
    Map.update!(heightmap, :map, &(Map.put(&1, coord, height)))
  end

  defp possible_neighbor_coords({x,y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  defp neighbor_coords(%__MODULE__{max_x: max_x, max_y: max_y}, coord) do
    possible_neighbor_coords(coord)
    |> Enum.filter(fn {x,y} ->
      x >= 0 && y >= 0 && x <= max_x && y <= max_y
    end)
  end

  defp neighbor_values(heightmap, coord) do
    neighbor_coords(heightmap, coord)
    |> Enum.map(&(Map.fetch!(heightmap.map, &1)))
  end

  defp all_coords(heightmap) do
    for x <- 0..heightmap.max_x, y <- 0..heightmap.max_y, do: {x,y}
  end

  def low_points(heightmap) do
    all_coords(heightmap)
    |> Stream.map(&(low_point(heightmap, &1)))
    |> Enum.filter(fn x -> x != nil end)
  end

  defp low_point(heightmap, coord) do
    height = Map.fetch!(heightmap.map, coord)
    case Enum.all?(neighbor_values(heightmap, coord), &(height < &1)) do
      true  -> {height, coord}
      false -> nil
    end
  end

  def basins(heightmap) do
    Enum.map(
      low_points(heightmap),
      fn {_height, coord} ->
        basin_from(heightmap, coord)
      end
    )
  end

  def basin_from(heightmap, coord) do
    basin_from(heightmap, coord, MapSet.new())
  end

  defp basin_from(heightmap, coord, basin_coords) do
    basin_coords = MapSet.put(basin_coords, coord)
    height = Map.fetch!(heightmap.map, coord)

    case neighbor_coords(heightmap, coord) do
      [] -> basin_coords
      neighbor_coords ->
        neighbor_coords
        |> Stream.filter(fn neighbor_coord ->
          neighbor_height = Map.fetch!(heightmap.map, neighbor_coord)
          height < neighbor_height && neighbor_height < 9
        end)
        |> Enum.reduce(basin_coords, fn neighbor_coord, acc ->
          MapSet.union(acc, basin_from(heightmap, neighbor_coord))
        end)
    end
  end
end

SmokeBasin.read_input("test_input")
|> SmokeBasin.total_risk_level()
|> IO.inspect

SmokeBasin.read_input("input")
|> SmokeBasin.total_risk_level()
|> IO.inspect

SmokeBasin.read_input("test_input")
|> SmokeBasin.largest_basins_score()
|> IO.inspect

SmokeBasin.read_input("input")
|> SmokeBasin.largest_basins_score()
|> IO.inspect
