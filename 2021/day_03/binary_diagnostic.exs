defmodule BinaryDiagnostic do
  def read_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
  end

  # Part 1

  # Create data structure grouping the bits of bitstrings by position
  # Example:
  # Maps these strings:
  # 01
  # 10
  # 11
  # 01
  # to:
  #
  # %{ 0 => [1, 0, 1, 1]
  #    1 => [0, 1, 1, 0] }
  #
  # Key is position in the bitstring, in descending order from left to right
  # Position in the list is the order from the input list, with the first
  # position being the first bitstring in the input list
  def bits_by_position(bitstrings) do
    bitstrings
    |> Enum.map(fn bitstring ->
      length = String.length(bitstring)

      bitstring
      |> String.to_charlist()
      |> Enum.with_index(fn element, index -> {element, length - 1 - index} end)
    end)
    |> List.flatten()
    |> Enum.group_by(
      fn {_bit_char, pos} -> pos end,
      fn
        {48, _} -> 0
        {49, _} -> 1
      end
    )
  end

  # Transform values from map created by bits_by_position into a map containing
  # the bits (unchanged) and the mode (most common) bit at the key position
  #
  # Input:
  # %{ 0 => [1, 0, 1, 1]
  #    1 => [0, 1, 1, 0] }
  # Output:
  # %{ 0 => %{bits: [1, 0, 1, 1], mode: 1}
  #    1 => %{bits: [0, 1, 1, 0], mode: :equal}
  def add_mode(position_map) do
    position_map
    |> Stream.map(fn {pos, bits} -> {pos, %{bits: bits, mode: mode(bits)}} end)
    |> Enum.into(%{})
  end

  def mode(bits) do
    mode(bits, %{})
  end

  def mode([], %{0 => zero, 1 => one}) when zero > one, do: 0
  def mode([], %{0 => zero, 1 => one}) when zero < one, do: 1
  def mode([], _freqs), do: :equal # Added for part 2
  def mode([curr | rest], acc) do
    mode(
      rest,
      Map.update(acc, curr, 0, fn freq -> freq + 1 end)
    )
  end

  # Reduces a mode map to a bitstring converted to a decimal integer where each
  # mode bit is in the position in the bitstring given by its corresponding key,
  # with an optional map function to the mode bit
  defp mode_map_to_decimal(mode_map, bit_mapper \\ fn bit -> bit end) do
    Enum.reduce(mode_map, 0, fn {pos, %{mode: bit}}, acc ->
      acc + Integer.pow(2, pos) * bit_mapper.(bit)
    end)
  end

  def gamma(mode_map) do
    mode_map_to_decimal(mode_map)
  end

  def epsilon(mode_map) do
    mode_map_to_decimal(mode_map, &flip/1)
  end

  defp flip(0), do: 1
  defp flip(1), do: 0

  # Part 2
  def generator_rating_bitstring(
    mode_map,
    mode_mapper \\ fn
      :equal -> 1
      mode   -> mode
    end
  ) do
    num_bitstrings =
      mode_map
      |> Map.fetch!(0)
      |> Map.fetch!(:bits)
      |> length()

    generator_rating_bitstring(
      mode_map,
      Enum.sort(Map.keys(mode_map), :desc),
      MapSet.new(for i <- 0..(num_bitstrings - 1), do: i),
      mode_mapper
    ) |> MapSet.to_list() |> List.first()
  end


  defp generator_rating_bitstring(_, [], acc_set, _), do: acc_set
  defp generator_rating_bitstring(mode_map, [pos | rest], acc_set, mode_mapper) do
    case MapSet.size(acc_set) do
      size when size == 1 -> acc_set # Stop!
      size when size > 1 -> # Recursive case
        %{bits: bits} = Map.fetch!(mode_map, pos)

        mode =
          bits
          |> Enum.with_index()
          |> Enum.filter(fn {_bit, index} ->  # Remove the eliminated bitstrings
            MapSet.member?(acc_set, index)
          end) 
          |> Enum.map(fn {bit, _index} -> bit end)
          |> mode()
          |> mode_mapper.()

        remaining =
          bits
          |> Enum.with_index()
          |> Enum.filter(fn
            {^mode, _index} -> true
            _               -> false
          end)
          |> Enum.reduce(MapSet.new(), fn {_bit, index}, set ->
            MapSet.put(set, index)
          end)
          |> MapSet.intersection(acc_set)

        generator_rating_bitstring(mode_map, rest, remaining, mode_mapper)
    end
  end

  def bitstring_from_input(bitstrings, index) do
    bitstrings
    |> List.to_tuple()
    |> elem(index)
  end

  def bitstring_to_decimal(bitstring) do
    length = String.length(bitstring)
    bitstring
    |> String.to_charlist()
    |> Enum.with_index(fn element, index -> {element, length - 1 - index} end)
    |> Enum.map(fn
      {48, i} -> {0, i}
      {49, i} -> {1, i}
    end)
    |> Enum.reduce(0, fn {bit, pos}, acc ->
      acc + Integer.pow(2, pos) * bit
    end)
  end

  def oxygen_generator(bitstrings, mode_map) do
    bitstring_from_input(bitstrings, generator_rating_bitstring(mode_map))
    |> bitstring_to_decimal()
  end

  def co2_scrubber_generator(bitstrings, mode_map) do
    bitstring_from_input(
      bitstrings,
      generator_rating_bitstring(mode_map, fn
        :equal -> 0
        mode   -> flip(mode)
      end)
    )
    |> bitstring_to_decimal()
  end
end

test_input = [
  "00100",
  "11110",
  "10110",
  "10111",
  "10101",
  "01111",
  "00111",
  "11100",
  "10000",
  "11001",
  "00010",
  "01010"
]

# Part 1
test_mode_map = 
  test_input
  |> BinaryDiagnostic.bits_by_position()
  |> BinaryDiagnostic.add_mode()

IO.inspect(
  BinaryDiagnostic.gamma(test_mode_map) * BinaryDiagnostic.epsilon(test_mode_map)
)

input = BinaryDiagnostic.read_input("input")
mode_map = 
  input
  |> BinaryDiagnostic.bits_by_position()
  |> BinaryDiagnostic.add_mode()

IO.inspect(
  BinaryDiagnostic.gamma(mode_map) * BinaryDiagnostic.epsilon(mode_map)
)

# Part 2
IO.inspect(
  BinaryDiagnostic.oxygen_generator(test_input, test_mode_map) *
    BinaryDiagnostic.co2_scrubber_generator(test_input, test_mode_map)
)

IO.inspect(
  BinaryDiagnostic.oxygen_generator(input, mode_map) *
    BinaryDiagnostic.co2_scrubber_generator(input, mode_map)
)
