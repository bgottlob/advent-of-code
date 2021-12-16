defmodule ExtendedPolymerization do
  def read_input(filename) do
    [template, _blank | rules] = File.stream!(filename)
                                 |> Enum.map(&String.trim_trailing/1)
    {template, read_rules(rules)}
  end

  defp read_rules(lines) do
    for line <- lines, into: %{} do
      Regex.run(~r/^([A-Z]+) -> ([A-Z]+)/, line, capture: :all_but_first)
      |> List.to_tuple()
    end
  end

  def pairs(str) do
    charlist = String.to_charlist(str)
    [_ | charlist_to_zip] = charlist
    Enum.zip_with(charlist, charlist_to_zip, fn x,y -> List.to_string([x,y]) end)
  end

  def polymerize(template, rules, times) do
    Enum.reduce(1..times, template, fn _, acc ->
      polymerize(acc, rules)
    end)
  end

  defp polymerize(template, rules) do
    polymerize_pairs(pairs(template), rules, "")
  end

  defp polymerize_pairs([], _rules, acc), do: acc
  defp polymerize_pairs([pair | rest], rules, acc) do
    insert = Map.fetch!(rules, pair) |> String.to_charlist()
    [left, right] = String.to_charlist(pair)
    append = case rest do
      [] -> List.flatten([left, insert, right])
      _ -> List.flatten([left, insert])
    end
    polymerize_pairs(rest, rules,"#{acc}#{append}")
  end

  def final_score(template) do
    {min, max} =
      template
      |> String.to_charlist()
      |> Enum.frequencies()
      |> Enum.map(fn {_, freq} -> freq end)
      |> Enum.min_max()

    max - min
  end
end

# Part 1
{template, rules} = ExtendedPolymerization.read_input("test_input")
template
|> ExtendedPolymerization.polymerize(rules, 10)
|> ExtendedPolymerization.final_score()
|> IO.inspect

{template, rules} = ExtendedPolymerization.read_input("input")
template
|> ExtendedPolymerization.polymerize(rules, 10)
|> ExtendedPolymerization.final_score()
|> IO.inspect

# Part 2
#{template, rules} = ExtendedPolymerization.read_input("test_input")
#template
#|> ExtendedPolymerization.polymerize(rules, 40)
#|> ExtendedPolymerization.final_score()
#|> IO.inspect

{template, rules} = ExtendedPolymerization.read_input("test_input")
IO.inspect rules
template |> IO.inspect
|> ExtendedPolymerization.polymerize(rules, 1)
|> IO.inspect
|> ExtendedPolymerization.polymerize(rules, 1)
|> IO.inspect
|> ExtendedPolymerization.polymerize(rules, 1)
|> IO.inspect
|> ExtendedPolymerization.polymerize(rules, 1)
|> IO.inspect
|> ExtendedPolymerization.polymerize(rules, 1)
|> IO.inspect
|> ExtendedPolymerization.polymerize(rules, 1)
|> IO.inspect
|> ExtendedPolymerization.final_score()
|> IO.inspect
