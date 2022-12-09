defmodule TreeHouse do
  def read_input(filename) do
    File.stream!(filename)
    |> Enum.map(&String.trim_trailing/1)
    |> read_lines()
  end

  defp read_lines(lines) do
    read_lines(lines, 0, %{})
  end

  defp read_lines([], _row, acc), do: acc
  defp read_lines([line | rest], row, acc) do
    acc = 
      line
      |> String.to_charlist
      |> Enum.with_index()
      |> IO.inspect
      |> Enum.reduce(acc, fn {char, col}, inner_acc ->
        Map.put(inner_acc, {row, col}, char - ?0)
      end)

    read_lines(rest, row + 1, acc)
  end

  def visible_trees(grid) do
    {{max_x, _}, _} =
      Enum.max_by(grid, fn {{x, _y}, _} -> x end)
    {{_, max_y}, _} =
      Enum.max_by(grid, fn {{_x, y}, _} -> y end)

    {max_x, max_y}

    top_row = for x <- 0..max_x, do: {x,0}
    bottom_row = for x <- 0..max_x, do: {x,max_y}

    left_col = for y <- 0..max_y, do: {0,y}
    right_col = for y <- 0..max_y, do: {max_x,y}

    [
      visible_trees(grid, top_row, :down, -1, MapSet.new()),
      visible_trees(grid, bottom_row, :up, -1, MapSet.new()),
      visible_trees(grid, left_col, :right, -1, MapSet.new()),
      visible_trees(grid, right_col, :left, -1, MapSet.new())
    ]
  end

  defp visible_trees(grid, [start | rest], direction, max_before, acc) do

  end
end

TreeHouse.read_input("test_input")
|> TreeHouse.visible_trees()
|> IO.inspect
