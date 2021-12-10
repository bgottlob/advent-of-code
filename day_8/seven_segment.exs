defmodule SevenSegment do
  def read_input(filename) do
    Enum.map(File.stream!(filename), &read_line/1)
  end

  defp read_line(line) do
    line
    |> String.trim()
    |> String.split("|")
    |> Enum.map(&String.split/1)
    |> List.to_tuple
  end

  def count_digits(lines) do
    lines
    |> Stream.map(&output_digit_count/1)
    |> Enum.sum()
  end

  # Counts the number of 1s, 4s, 7s, and 8s in the output signal
  defp output_digit_count({_input, output}) do
    output
    |> Enum.filter(&unique_segment_signal?/1)
    |> Enum.count()
  end

  defp unique_segment_signal?(signal) do
    case String.length(signal) do
      2 -> true # digit == 1
      4 -> true # digit == 4
      3 -> true # digit == 7
      7 -> true # digit == 8
      _ -> false
    end
  end

  #  0000
  # 1    2
  # 1    2
  #  3333
  # 4    5
  # 4    5
  #  6666
  # The segments that make up the given number on the display
  defp segments_for(0), do: [0,1,2,4,5,6] |> MapSet.new()
  defp segments_for(1), do: [2,5] |> MapSet.new()
  defp segments_for(2), do: [0,2,3,4,6] |> MapSet.new()
  defp segments_for(3), do: [0,2,3,5,6] |> MapSet.new()
  defp segments_for(4), do: [1,2,3,5] |> MapSet.new()
  defp segments_for(5), do: [0,1,3,5,6] |> MapSet.new()
  defp segments_for(6), do: [0,1,3,4,5,6] |> MapSet.new()
  defp segments_for(7), do: [0,2,5] |> MapSet.new()
  defp segments_for(8), do: [0,1,2,3,4,5,6] |> MapSet.new()
  defp segments_for(9), do: [0,1,2,3,5,6] |> MapSet.new()

  # Returns the digits that could possibly displayed given the number of
  # overlaps with a specific digit
  defp possible_with_overlaps(overlaps, digit) do
    Enum.filter(0..9, fn x ->
      overlaps == MapSet.size(
        MapSet.intersection(segments_for(x), segments_for(digit))
      )
    end)
    |> MapSet.new()
  end

  # Returns the digits that could possibly be displayed given the size of the
  # signal
  defp possible_with_signal_size(2), do: [1]
  defp possible_with_signal_size(3), do: [7]
  defp possible_with_signal_size(4), do: [4]
  defp possible_with_signal_size(5), do: [2,3,5]
  defp possible_with_signal_size(6), do: [0,6,9]
  defp possible_with_signal_size(7), do: [8]

  def output_value({input, output}) do
    signal_map =
      [input, output]
      |> List.flatten()
      |> Enum.sort_by(&signal_size_sorter/1)
      |> map_signals(%{})

    output
    |> Stream.map(fn signal -> Map.fetch!(signal_map, signal) end)
    |> digits_to_decimal()
  end

  defp digits_to_decimal(digits) do
    digits
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {digit, index}, acc ->
      acc + Integer.pow(10, index) * digit
    end)
  end

  defp signal_size_sorter(signal) do
    # Precedence - [2 or 3 or 4 or 8] < 5 < 6
    case String.length(signal) do
      size when size == 2 or size == 3 or size == 4 or size == 7 -> 0
      5 -> 1
      6 -> 2
    end
  end

  def map_signals([], signal_map), do: signal_map
  def map_signals([signal | rest], signal_map) do
    case possible_with_signal_size(String.length(signal)) do
      [only] ->
        map_signals(rest, Map.put(signal_map, signal, only))
      multiple ->
        possible =
          Enum.reduce(signal_map, MapSet.new(multiple), fn
            _, [only_possible] ->
              [only_possible]
            {mapped_signal, signal_value}, possible_values ->
              MapSet.intersection(
                possible_values,
                possible_with_overlaps(
                  overlaps(signal, mapped_signal),
                  signal_value
                )
              )
          end)
          |> MapSet.to_list()
        case possible do
          #[] ->
          #  map_signals(rest ++ possible, signal_map)
          [definite] ->
            map_signals(rest, Map.put(signal_map, signal, definite))
        end
    end
  end

  def overlaps(signal_x, signal_y) do
    [set_x, set_y] = for signal <- [signal_x, signal_y] do
      signal
      |> String.to_charlist()
      |> MapSet.new()
    end

    MapSet.intersection(set_x, set_y) |> MapSet.size()
  end
end

SevenSegment.read_input("input")
|> SevenSegment.count_digits()
|> IO.inspect()

SevenSegment.read_input("small_test_input")
|> Enum.map(&SevenSegment.output_value/1)
|> Enum.sum()
|> IO.inspect()

SevenSegment.read_input("test_input")
|> Enum.map(&SevenSegment.output_value/1)
|> Enum.sum()
|> IO.inspect()

SevenSegment.read_input("input")
|> Enum.map(&SevenSegment.output_value/1)
|> Enum.sum()
|> IO.inspect()
