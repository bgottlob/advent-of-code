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
    pairs = pairs(template)
    freq_map = pairs_to_freqs(pairs, %{})

    Enum.reduce(
      1..times,
      {freq_map, List.first(pairs), List.last(pairs)},
      fn _, acc -> polymerize(acc, rules) end
    )
  end

  defp pairs_to_freqs([], freq_map), do: freq_map
  defp pairs_to_freqs([pair | rest], freq_map) do
    new_freq_map = Map.update(freq_map, pair, 1, fn freq -> freq + 1 end)
    pairs_to_freqs(rest, new_freq_map)
  end

  defp polymerize({freq_map, first_pair, last_pair}, rules) do
    <<left::size(8), _right::size(8)>> = first_pair
    <<middle::size(8)>> = Map.fetch!(rules, first_pair)
    new_first_pair = List.to_string([left, middle])

    <<_left::size(8), right::size(8)>> = last_pair
    <<middle::size(8)>> = Map.fetch!(rules, last_pair)
    new_last_pair = List.to_string([middle, right])

    new_freq_map = 
      Enum.reduce(freq_map, freq_map, fn {pair, freq}, acc ->
        <<left::size(8), right::size(8)>> = pair
        <<middle::size(8)>> = Map.fetch!(rules, pair)

        pair_1 = List.to_string([left, middle])
        pair_2 = List.to_string([middle, right])

        acc
        |> Map.update!(pair, fn x -> x - freq end)
        |> Map.update(pair_1, freq, fn x -> x + freq end)
        |> Map.update(pair_2, freq, fn x -> x + freq end)
      end)

    {new_freq_map, new_first_pair, new_last_pair}
  end

  def polymer_to_char_freqs({
    freq_map,
    <<left::size(8), _right::size(8)>>,
    <<_left::size(8), right::size(8)>>
  }) do
    Enum.reduce(
      freq_map,
      %{},
      fn {<<left::size(8), right::size(8)>>, freq}, acc ->
        acc
        |> Map.update(left, freq, fn x -> x + freq end)
        |> Map.update(right, freq, fn x -> x + freq end)
      end
    )
    |> Enum.map(fn {char, freq} -> {char, div(freq,2)} end) # Elements in the middle are double-counted
    |> Enum.into(%{})
    |> Map.update!(left, fn freq -> freq + 1 end)
    |> Map.update!(right, fn freq -> freq + 1 end)
  end

  def final_score(poly_params) do
    {min, max} = 
      poly_params
      |> polymer_to_char_freqs()
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
{template, rules} = ExtendedPolymerization.read_input("test_input")
template
|> ExtendedPolymerization.polymerize(rules, 40)
|> ExtendedPolymerization.final_score()
|> IO.inspect

{template, rules} = ExtendedPolymerization.read_input("input")
template
|> ExtendedPolymerization.polymerize(rules, 40)
|> ExtendedPolymerization.final_score()
|> IO.inspect
