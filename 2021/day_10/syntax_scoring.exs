defmodule SyntaxScoring do

  def read_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.map(&String.to_charlist/1)
  end

  def error_score(lines) do
    lines
    |> Enum.map(&parse/1)
    |> Enum.filter(fn
      {:incomplete, _open_stack} -> false
      :valid -> false
      {:corrupted, _char} -> true
    end)
    |> Enum.map(fn {:corrupted, char} -> char_error_score(char) end)
    |> Enum.sum()
  end

  def total_incomplete_score(lines) do
    scores =
      lines
      |> Enum.map(&parse/1)
      |> Enum.filter(fn
        {:incomplete, _open_stack} -> true
        :valid -> false
        {:corrupted, _char} -> false
      end)
      |> Enum.map(fn {:incomplete, stack} -> incomplete_score(stack) end)
      |> Enum.sort()
    Enum.at(scores, div(Enum.count(scores), 2), :wont_happen)
  end

  def incomplete_score(open_stack) do
    incomplete_score(open_stack, 0)
  end

  defp incomplete_score([], score), do: score
  defp incomplete_score([char | rest], score) do
    incomplete_score(rest, score * 5 + char_incomplete_score(char))
  end

  defp char_incomplete_score(?(), do: 1
  defp char_incomplete_score(?[), do: 2
  defp char_incomplete_score(?{), do: 3
  defp char_incomplete_score(?<), do: 4

  defp char_error_score(?)), do: 3
  defp char_error_score(?]), do: 57
  defp char_error_score(?}), do: 1197
  defp char_error_score(?>), do: 25137

  defp parse(chars) do
    parse(chars, [])
  end

  @open_chars  '[({<'
  @close_chars '])}>'

  defp parse([], []), do: :valid
  defp parse([], open_stack), do: {:incomplete, open_stack}

  # Open character detected, add to stack and continue
  defp parse([open | rest], open_stack) when open in @open_chars do
    parse(rest, [open | open_stack])
  end

  # Is it possible for a closing char to appear when there are no open chars
  # left?
  #defp parse([close | rest], []) when close in @close_chars do
  defp parse([?] | rest], [?[ | open_stack]), do: parse(rest, open_stack)
  defp parse([?) | rest], [?( | open_stack]), do: parse(rest, open_stack)
  defp parse([?} | rest], [?{ | open_stack]), do: parse(rest, open_stack)
  defp parse([?> | rest], [?< | open_stack]), do: parse(rest, open_stack)
  defp parse([close | _rest], [open | _open_stack]) # mismatch!
  when close in @close_chars and open in @open_chars do
    {:corrupted, close}
  end
end

SyntaxScoring.read_input("test_input")
|> SyntaxScoring.error_score()
|> IO.inspect()

SyntaxScoring.read_input("input")
|> SyntaxScoring.error_score()
|> IO.inspect()

SyntaxScoring.read_input("test_input")
|> SyntaxScoring.total_incomplete_score()
|> IO.inspect()

SyntaxScoring.read_input("input")
|> SyntaxScoring.total_incomplete_score()
|> IO.inspect()
