defmodule Tuning do
  def first_marker(signal, num_distinct) do
    first_marker(String.to_charlist(signal), num_distinct, 0)
  end

  defp first_marker([], _num_distinct, _ct), do: false
  defp first_marker(signal, num_distinct, ct) do
    first = Enum.take(signal, num_distinct)
    case Enum.uniq(first) |> length() do
      ^num_distinct -> ct + num_distinct
      _ -> first_marker(tl(signal), num_distinct, ct + 1)
    end
  end
end

IO.puts("Part 1")

num_distinct = 4
Tuning.first_marker("mjqjpqmgbljsphdztnvjfqwrcgsmlb", num_distinct) |> IO.inspect
Tuning.first_marker("bvwbjplbgvbhsrlpgdmjqwftvncz", num_distinct) |> IO.inspect
Tuning.first_marker("nppdvjthqldpwncqszvftbrmjlhg", num_distinct) |> IO.inspect
Tuning.first_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", num_distinct) |> IO.inspect
Tuning.first_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", num_distinct) |> IO.inspect

File.read!("input")
|> String.trim_trailing()
|> Tuning.first_marker(num_distinct)
|> IO.inspect

IO.puts("Part 2")

num_distinct = 14
Tuning.first_marker("mjqjpqmgbljsphdztnvjfqwrcgsmlb", num_distinct) |> IO.inspect
Tuning.first_marker("bvwbjplbgvbhsrlpgdmjqwftvncz", num_distinct) |> IO.inspect
Tuning.first_marker("nppdvjthqldpwncqszvftbrmjlhg", num_distinct) |> IO.inspect
Tuning.first_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", num_distinct) |> IO.inspect
Tuning.first_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", num_distinct) |> IO.inspect

File.read!("input")
|> String.trim_trailing()
|> Tuning.first_marker(num_distinct)
|> IO.inspect
