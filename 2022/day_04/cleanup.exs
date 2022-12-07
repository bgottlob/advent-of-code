defmodule Cleanup do
  def read_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(fn pair ->
        [start, finish] = pair
                          |> String.split("-")
                          |> Enum.map(&String.to_integer/1)
        start..finish
      end)
    end)
  end

  defp fully_contains([x, y]) do
    x = MapSet.new(x)
    y = MapSet.new(y)

    un = MapSet.union(x, y)
    MapSet.equal?(un, x) || MapSet.equal?(un, y)
  end

  defp overlap([x, y]) do
    x = MapSet.new(x)
    y = MapSet.new(y)

    !MapSet.disjoint?(x,y)
  end

  def fully_contain_pairs(pair_sets) do
    Enum.count(pair_sets, &fully_contains/1)
  end

  def overlap_pairs(pair_sets) do
    Enum.count(pair_sets, &overlap/1)
  end
end

IO.puts("Part 1")

Cleanup.read_input("test_input")
|> Cleanup.fully_contain_pairs()
|> IO.inspect

Cleanup.read_input("input")
|> Cleanup.fully_contain_pairs()
|> IO.inspect

IO.puts("Part 2")

Cleanup.read_input("test_input")
|> Cleanup.overlap_pairs()
|> IO.inspect

Cleanup.read_input("input")
|> Cleanup.overlap_pairs()
|> IO.inspect
