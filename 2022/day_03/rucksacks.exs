defmodule Rucksacks do
  def read_input(filename) do
    File.stream!(filename)
    |> Enum.map(&String.trim/1)
  end

  def read_input_groups(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Enum.chunk_every(3)
  end

  defp priority(item) when item >= ?a and item <= ?z, do: item - ?a + 1
  defp priority(item) when item >= ?A and item <= ?Z, do: item - ?A + 27

  # Split a rucksack string into two charlists, one with the contents of each
  # of the two compartments
  defp compartments(rucksack) do
    compartment_size = div(String.length(rucksack), 2)

    rucksack
    |> String.split_at(compartment_size)
    |> Tuple.to_list()
    |> Enum.map(&String.to_charlist/1)
  end

  defp common_item(rucksack) do
    [left, right] = rucksack
                    |> compartments()
                    |> Enum.map(&MapSet.new/1)

    [item] = MapSet.intersection(left, right) |> MapSet.to_list()
    item
  end

  defp badge(rucksacks) do
    [r1, r2, r3] = Enum.map(rucksacks, fn r ->
      String.to_charlist(r) |> MapSet.new()
    end)

    [item] =
      MapSet.intersection(r1, r2)
      |> MapSet.intersection(r3)
      |> MapSet.to_list

    item
  end

  def common_item_priority_sum(rucksacks) do
    rucksacks
    |> Stream.map(&common_item/1)
    |> Stream.map(&priority/1)
    |> Enum.sum()
  end

  def badge_priority_sum(rucksack_groups) do
    rucksack_groups
    |> Stream.map(&badge/1)
    |> Stream.map(&priority/1)
    |> Enum.sum()
  end
end

IO.puts("Part 1")

Rucksacks.read_input("test_input")
|> Rucksacks.common_item_priority_sum()
|> IO.inspect

Rucksacks.read_input("input")
|> Rucksacks.common_item_priority_sum()
|> IO.inspect

IO.puts("Part 2")

Rucksacks.read_input_groups("test_input")
|> Rucksacks.badge_priority_sum()
|> IO.inspect

Rucksacks.read_input_groups("input")
|> Rucksacks.badge_priority_sum()
|> IO.inspect
