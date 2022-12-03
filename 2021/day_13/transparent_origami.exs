defmodule TransparentOrigami do
  def read_input(filename) do
    File.stream!(filename)
    |> Enum.map(&String.trim_trailing/1)
    |> read_lines()
  end

  defp read_lines(lines) do
    read_lines(lines, MapSet.new(), [])
  end

  defp read_lines([], dots, folds) do
    {dots, Enum.reverse(folds)}
  end

  # Throw away the empty line
  defp read_lines(["" | rest], dots, folds), do: read_lines(rest, dots, folds)
  defp read_lines([line | rest], dots, folds) do
    {new_dots, new_folds} = case {
      Regex.run(~r/^(\d+),(\d+)$/, line, capture: :all_but_first),
      Regex.run(~r/^fold along ([xy])=(\d+)$/, line, capture: :all_but_first)
    } do
      {[x,y], nil} ->
        {MapSet.put(dots, {String.to_integer(x), String.to_integer(y)}), folds}
      {nil, [xy, num]} ->
        {dots, [{String.to_atom(xy), String.to_integer(num)} | folds]}
    end

    read_lines(rest, new_dots, new_folds)
  end

  def fold(dots, fold_params) do
    {to_fold, stay_same} = split_to_fold(dots, fold_params)

    [perform_fold(to_fold, fold_params), stay_same]
    |> List.flatten()
    |> MapSet.new()
  end

  defp split_to_fold(dots, {x_or_y, fold_line}) do
    splitter = case x_or_y do
      :x -> fn {x, _y} -> x > fold_line end
      :y -> fn {_x, y} -> y > fold_line end
    end
    Enum.split_with(dots, splitter)
  end

  defp move_by(curr, fold_line) do
    (curr - fold_line) * 2
  end

  defp perform_fold(to_fold, {x_or_y, fold_line}) do
    mapper = case x_or_y do
      :x -> fn {x,y} -> {x - move_by(x, fold_line), y} end
      :y -> fn {x,y} -> {x, y - move_by(y, fold_line)} end
    end
    Enum.map(to_fold, mapper)
  end

  def folds({dots, []}), do: dots
  def folds({dots, [fold | rest]}) do
    folds({fold(dots, fold), rest})
  end

  def to_string(dots) do
    {max_x, _y} = Enum.max_by(dots, fn {x, _y} -> x end)
    {_x, max_y} = Enum.max_by(dots, fn {_x, y} -> y end)

    for y <- 0..max_y do
      Enum.reduce(0..max_x, "", fn x, acc ->
        case MapSet.member?(dots, {x,y}) do
          true -> acc <> "#"
          false -> acc <> "."
        end
      end)
    end
    |> Enum.join("\n")
  end
end

{dots, folds} = TransparentOrigami.read_input("test_input")
TransparentOrigami.fold(dots, List.first(folds))
|> Enum.count()
|> IO.inspect

{dots, folds} = TransparentOrigami.read_input("input")
TransparentOrigami.fold(dots, List.first(folds))
|> Enum.count()
|> IO.inspect

TransparentOrigami.read_input("input")
|> TransparentOrigami.folds()
|> TransparentOrigami.to_string()
|> IO.puts()
