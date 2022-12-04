defmodule RPS do
  @score_result %{
    loss: 0,
    draw: 3,
    win: 6
  }

  @score_shape %{
    rock: 1,
    paper: 2,
    scissors: 3
  }

  @decrypt_opponent %{
    ?A => :rock,
    ?B => :paper,
    ?C => :scissors
  }

  @decrypt_player %{
    ?X => :rock,
    ?Y => :paper,
    ?Z => :scissors
  }

  @decrypt_result %{
    ?X => :loss,
    ?Y => :draw,
    ?Z => :win
  }

  def read_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Enum.map(fn line ->
      [left, ?\s, right] = String.to_charlist(line)
      {left, right}
    end)
  end

  defp winning_shape(moves) do
    shapes = Tuple.to_list(moves) |> Enum.sort
    case shapes do
      [:paper, :rock] -> :paper
      [:paper, :scissors] -> :scissors
      [:rock, :scissors] -> :rock
      [same, same] -> :draw
    end
  end

  @desired_shape_map %{
    paper: %{win: :scissors, loss: :rock},
    rock: %{win: :paper, loss: :scissors},
    scissors: %{win: :rock, loss: :paper}
  }

  defp desired_shape(opponent, :draw), do: opponent

  defp desired_shape(opponent, desired_result) do
    @desired_shape_map[opponent][desired_result]
  end

  defp result(moves = {opponent, player}) do
    case winning_shape(moves) do
      :draw -> :draw
      ^opponent -> :loss
      ^player -> :win 
    end
  end

  defp decrypt_moves({opponent, player}) do
    {@decrypt_opponent[opponent], @decrypt_player[player]}
  end

  defp decrypt_moves_and_result({opponent, desired_result}) do
    {@decrypt_opponent[opponent], @decrypt_result[desired_result]}
  end

  defp score(moves) do
    moves = {_opponent, player} = decrypt_moves(moves)
    result = result(moves)
    @score_result[result] + @score_shape[player]
  end

  def total_score(rounds) do
    rounds
    |> Enum.map(&(score(&1)))
    |> Enum.sum()
  end

  def total_score_select_move(rounds) do
    rounds
    |> Enum.map(fn round ->
      {opponent, result} = decrypt_moves_and_result(round)
      player = desired_shape(opponent, result)
      @score_result[result] + @score_shape[player]
    end)
    |> Enum.sum
  end
end

IO.puts("Part 1")
RPS.read_input("test_input")
|> RPS.total_score()
|> IO.inspect

RPS.read_input("input")
|> RPS.total_score()
|> IO.inspect

IO.puts("Part 2")
RPS.read_input("test_input")
|> RPS.total_score_select_move()
|> IO.inspect

RPS.read_input("input")
|> RPS.total_score_select_move()
|> IO.inspect
