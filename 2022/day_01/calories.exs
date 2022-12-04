defmodule Calories do
  def read_input(filename) do
    File.read!(filename)
    |> String.split("\n\n")
    |> Enum.map(
      fn str ->
        Enum.map(String.split(str), fn cal -> String.to_integer(cal) end)
      end
    )
  end

  defp calories_sums(calories_lists) do
    Enum.map(calories_lists, &(Enum.sum(&1)))
  end

  def most(calories_lists) do
    calories_lists
    |> calories_sums
    |> Enum.max()
  end

  def top3(calories_lists) do
    calories_lists
    |> calories_sums
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end

IO.puts("Part 1")
Calories.read_input("test_input")
|> Calories.most()
|> IO.inspect

Calories.read_input("input")
|> Calories.most()
|> IO.inspect

IO.puts("Part 2")
Calories.read_input("test_input")
|> Calories.top3()
|> IO.inspect

Calories.read_input("input")
|> Calories.top3()
|> IO.inspect
