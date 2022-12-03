defmodule HydrothermalVenture do
  def read_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.map(&read_segment/1)
  end

  # Each line
  defp read_segment(line) do
      line
      |> String.split(" -> ")
      |> Enum.map(fn point_str ->
        point_str
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
  end

  # Ignore diagonals
  defp segment_points(segment = [{x_1, y_1}, {x_2, y_2}])
  when x_1 != x_2 and y_1 != y_2 do
    # Comment out the line below and return [] here for Part 1
    diagonal_segment_points(segment, [{x_1, y_1}])
  end

  defp segment_points([{x_1, y_1}, {x_2, y_2}]) do
    {start_x, end_x} = start_end([x_1, x_2])
    {start_y, end_y} = start_end([y_1, y_2])
    for x <- start_x..end_x, y <- start_y..end_y, do: {x,y}
  end

  defp diagonal_segment_points([end_point, end_point], points), do: points

  defp diagonal_segment_points([{x_1, y_1}, end_point = {x_2, y_2}], points) do
    point = case {x_1 < x_2, y_1 < y_2} do
      {false, false} -> {x_1 - 1, y_1 - 1}
      {false, true}  -> {x_1 - 1, y_1 + 1}
      {true, false}  -> {x_1 + 1, y_1 - 1}
      {true, true}   -> {x_1 + 1, y_1 + 1}
    end

    diagonal_segment_points([point, end_point], [point | points])
  end

  defp start_end(nums) do
    {Enum.min(nums), Enum.max(nums)}
  end

  def point_frequencies(segments) do
    segments
    |> Enum.map(&segment_points/1)
    |> List.flatten()
    |> Enum.reduce(%{}, fn point, acc ->
      Map.update(acc, point, 1, fn freq -> freq + 1 end)
    end)
  end

  def overlapping_count(freqs) do
    Enum.count(freqs, fn {_point, freq} -> freq >= 2 end)
  end
end

HydrothermalVenture.read_input("test_input")
|> HydrothermalVenture.point_frequencies()
|> HydrothermalVenture.overlapping_count()
|> IO.inspect

HydrothermalVenture.read_input("input")
|> HydrothermalVenture.point_frequencies()
|> HydrothermalVenture.overlapping_count()
|> IO.inspect
