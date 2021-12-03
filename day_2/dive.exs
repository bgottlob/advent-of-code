defmodule Dive do
  def read_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
  end

  # Part 1
  defp split_command(command) do
    [position, magnitude] = String.split(command)
    [position, String.to_integer(magnitude)]
  end

  def track_positions(commands) do
    track_positions(commands, 0, 0)
  end

  defp track_positions([], horizontal, depth) do
    %{horizontal: horizontal, depth: depth}
  end

  defp track_positions([command | rest], horizontal, depth) do
    case split_command(command) do
      ["forward", mag] ->
        track_positions(rest, horizontal + mag, depth)
      ["down", mag] ->
        track_positions(rest, horizontal, depth + mag)
      ["up", mag] ->
        track_positions(rest, horizontal, depth - mag)
    end
  end

  def multiply_positions(%{horizontal: h, depth: d}), do: h * d

  # Part 2
  def track_positions_aim(commands) do
    track_positions_aim(commands, 0, 0, 0)
  end

  defp track_positions_aim([], horizontal, depth, aim) do
    %{horizontal: horizontal, depth: depth, aim: aim}
  end

  defp track_positions_aim([command | rest], horizontal, depth, aim) do
    case split_command(command) do
      ["forward", mag] ->
        track_positions_aim(rest, horizontal + mag, depth + (aim * mag), aim)
      ["down", mag] ->
        track_positions_aim(rest, horizontal, depth, aim + mag)
      ["up", mag] ->
        track_positions_aim(rest, horizontal, depth, aim - mag)
    end
  end
end

# Part 1
test_instructions = [
  "forward 5",
  "down 5",
  "forward 8",
  "up 3",
  "down 8",
  "forward 2"
]

test_instructions
  |> Dive.track_positions()
  |> IO.inspect
  |> Dive.multiply_positions()
  |> IO.puts

Dive.read_input("input")
|> Dive.track_positions()
|> IO.inspect
|> Dive.multiply_positions()
|> IO.puts

# Part 2
["forward 5",
  "down 5",
  "forward 8",
  "up 3",
  "down 8",
  "forward 2"]
  |> Dive.track_positions_aim()
  |> IO.inspect
  |> Dive.multiply_positions()
  |> IO.puts

Dive.read_input("input")
|> Dive.track_positions_aim()
|> IO.inspect
|> Dive.multiply_positions()
|> IO.puts
