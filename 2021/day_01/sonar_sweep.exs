defmodule SonarSweep do
  # Reads the input file and returns a list of integers
  def read_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end

  # Part 1
  # Returns the number of depth increases in the list
  def depth_increases(depths) do
    depth_increases(depths, 0)
  end

  defp depth_increases([], acc), do: acc

  defp depth_increases([prev, curr | rest], acc) when prev < curr do
    depth_increases([curr | rest], acc + 1)
  end

  defp depth_increases([_ | rest], acc) do
    depth_increases(rest, acc)
  end

  # Part 2
  # Count depth increases for a sum of a three-measurement window
  def windowed_depth_increases(depths) do
    windowed_depth_increases(depths, 0)
  end

  defp windowed_depth_increases([], acc), do: acc

  defp windowed_depth_increases([w, x, y, z | rest], acc)
  when w + x + y < x + y + z do
    windowed_depth_increases([x, y, z | rest], acc + 1)
  end

  defp windowed_depth_increases([_ | rest], acc) do
    windowed_depth_increases(rest, acc)
  end
end

# Part 1
[199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
|> SonarSweep.depth_increases()
|> IO.puts()

SonarSweep.read_input("input")
|> SonarSweep.depth_increases()
|> IO.puts()

# Part 2
[607, 618, 618, 617, 647, 716, 769, 792]
|> SonarSweep.windowed_depth_increases()
|> IO.puts

SonarSweep.read_input("input")
|> SonarSweep.windowed_depth_increases()
|> IO.puts
