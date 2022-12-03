defmodule GiantSquid do
  def read_input(filename) do
    lines = File.stream!(filename) |> Enum.map(&String.trim_trailing/1)
    [move_line, _blank | lines] = lines
    moves =
      move_line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    {moves, read_boards(lines)}
  end

  defp read_boards(lines) do
    # 6 is the step to skip empty lines between boards
    Enum.chunk_every(lines, 5, 6)
    |> Enum.map(&read_board/1)
  end

  # Given a list of   
  defp read_board(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, row}, acc ->
      new_row =
        String.split(line)
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {number, column}, acc ->
          # A number cannot be be repeated within the same board
          Map.put(acc, String.to_integer(number), {{column, row}, false})
        end)

      Map.merge(acc, new_row)
    end)
  end

  def mark(board, number) do
    if Map.has_key?(board, number) do
      Map.update!(board, number, fn {coord, _marked} -> {coord, true} end)
    else
      board
    end
  end

  defp marked_coordinates(board) do
    board
    |> Enum.map(fn
      {_number, {coord, true}}  -> coord
      {_number, {_coord, false}} -> nil
    end)
    |> Enum.filter(fn
      nil   -> false
      {_,_} -> true
    end)
  end

  def unmarked_numbers(board) do
    board
    |> Enum.map(fn
      {_number, {_coord, true}} -> nil
      {number, {_coord, false}} -> number
    end)
    |> Enum.filter(fn
      nil -> false
      _   -> true
    end)
  end

  def winner?(board) do
    marked = MapSet.new(marked_coordinates(board))
    paths()
    |> Enum.any?(fn path ->
      MapSet.subset?(MapSet.new(path), MapSet.new(marked))
    end)
  end

  def find_first_winner({moves, boards}) do
    find_winner(moves, boards, :first, nil, nil)
  end

  defp find_winner([], _boards, :last, winner, last_called) do
    {winner, last_called}
  end

  defp find_winner(_moves, _boards, :first, winner, last_called)
  when winner != nil do
    {winner, last_called}
  end

  defp find_winner([move | rest], boards, first_last,  winner, last_called) do
    boards = Enum.map(boards, fn board -> mark(board, move) end)
    {new_winner, new_boards} = pop_winners(boards)

    {new_winner, new_last_called} =
      case new_winner do
        nil -> {winner, last_called}
        _   -> {new_winner, move}
      end

    find_winner(rest, new_boards, first_last, new_winner, new_last_called)
  end

  defp pop_winners(boards) do
    pop_winners(boards, nil)
  end

  defp pop_winners(boards, winner) do
    winner_index = Enum.find_index(boards, fn board -> winner?(board) end)
    case winner_index do
      nil -> 
        {winner, boards} # No more winners, end recursion
      winner_index -> 
        {new_winner, new_boards} = List.pop_at(boards, winner_index)
        pop_winners(new_boards, new_winner)
    end
  end

  def final_score({board, last_called}) do
    unmarked_sum =
      board
      |> unmarked_numbers()
      |> Enum.sum()
    unmarked_sum * last_called
  end

  defp paths() do
    vertical = for row <- 0..4, do: (for col <- 0..4, do: {row, col})
    horizontal = for col <- 0..4, do: (for row <- 0..4, do: {row, col})
    vertical ++ horizontal
  end

  def find_last_winner({moves, boards}) do
    find_winner(moves, boards, :last, nil, nil)
  end
end

# Part 1

GiantSquid.read_input("test_input")
|> GiantSquid.find_first_winner()
|> GiantSquid.final_score()
|> IO.inspect

GiantSquid.read_input("input")
|> GiantSquid.find_first_winner()
|> GiantSquid.final_score()
|> IO.inspect

# Part 2

GiantSquid.read_input("test_input")
|> GiantSquid.find_last_winner()
|> GiantSquid.final_score()
|> IO.inspect

GiantSquid.read_input("input")
|> GiantSquid.find_last_winner()
|> IO.inspect
|> GiantSquid.final_score()
|> IO.inspect
