defmodule Stacks do
  defp parse_stacks(lines) do
    lines
    |> Stream.map(fn line ->
      # Each crate takes up three characters like "[X]" with a trailing fourth
      # character if there is a stack next to it
      line
      |> String.to_charlist()
      |> Enum.chunk_every(4)
      |> Enum.map(fn
	[?[, crate, ?] | _tl] -> crate
	[?\s, ?\s, ?\s | _tl] -> nil
      end)
    end)
    |> Enum.zip_reduce([], fn crates, acc ->
      # The top crate is at the head of the list
      # Remove nils
      crates = Enum.filter(crates, fn
	nil -> false
	_   -> true
      end)
      [crates | acc]
    end)
    |> Enum.reverse()
    |> List.to_tuple()
  end

  defp parse_moves(lines) do
    lines
    |> Enum.map(fn line ->
      [crates, src, dest] = Regex.run(
	~r/^move (\d+) from (\d+) to (\d+)$/,
	line,
	capture: :all_but_first
      ) |> Enum.map(&String.to_integer/1)
      %{crates: crates, src: src, dest: dest}
    end)
  end

  def parse_input(filename) do
    [stacks, moves] = File.read!(filename) |> String.split("\n\n")
    stacks = String.split(stacks, "\n") |> Enum.drop(-1) 
    moves = String.split(moves, "\n") |> Enum.drop(-1)
    %{stacks: parse_stacks(stacks), moves: parse_moves(moves)}
  end

  def make_moves(%{stacks: stacks, moves: moves}, part_2 \\ false) do
    Enum.reduce(moves, stacks, fn move, acc_stacks ->
      make_move(move, acc_stacks, part_2)
    end)
  end

  defp make_move(%{crates: crates, dest: dest, src: src}, stacks, part_2) do
    # 0-index stack numbers
    src = src - 1
    dest = dest - 1

    {src_stack, dest_stack} = move_crates(
      crates,
      elem(stacks, src),
      elem(stacks, dest),
      part_2
    )

    stacks
    |> put_elem(src, src_stack)
    |> put_elem(dest, dest_stack)
  end

  defp move_crates(0, src_stack, dest_stack, _part_2), do: {src_stack, dest_stack}
  defp move_crates(num_crates, [crate | src_stack], dest_stack, false) do
    move_crates(num_crates - 1, src_stack, [crate | dest_stack], false)
  end
  defp move_crates(num_crates, src_stack, dest_stack, true) do
    {crates, src_stack} = Enum.split(src_stack, num_crates)
    {src_stack, List.flatten([crates, dest_stack])}
  end

  def top_crates(stacks) do
    stacks
    |> Tuple.to_list()
    |> Enum.map(&hd/1)
  end
end

IO.puts "Part 1"

Stacks.parse_input("test_input")
|> Stacks.make_moves()
|> Stacks.top_crates()
|> IO.inspect

Stacks.parse_input("input")
|> Stacks.make_moves()
|> Stacks.top_crates()
|> IO.inspect

IO.puts "Part 2"

Stacks.parse_input("test_input")
|> Stacks.make_moves(true)
|> Stacks.top_crates()
|> IO.inspect

Stacks.parse_input("input")
|> Stacks.make_moves(true)
|> Stacks.top_crates()
|> IO.inspect
