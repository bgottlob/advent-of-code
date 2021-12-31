defmodule TrickShot do
  def read_input(filename) do
    str = File.read!(filename) |> String.trim_trailing()
    [min_x, max_x, min_y, max_y] = Regex.run(
      ~r/^target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)$/,
      str,
      capture: :all_but_first
    )
    |> Enum.map(fn num_str -> String.to_integer(num_str) end)

    {min_x..max_x, min_y..max_y}
  end

  def highest_y(min_y.._) do
    # The desired vertical velocity when the probe reaches y=0 on its way down
    # hits the bottom edge of the range
    vy_0 = min_y + 1

    # The position of the top of the arc the probe fell from to reach this speed
    # Counting down from up, essentially -9 + -8 + -7 + ... + -1
    Enum.sum(1..(-vy_0))
  end

  defp possible_x_velocities(min_x..max_x) do
    min_possible_x_velocity(min_x)..max_x
  end

  # Find the starting x velocity what will stop at the given vertical edge
  defp min_possible_x_velocity(target_x) do
    min_possible_x_velocity(target_x, 0)
  end

  defp min_possible_x_velocity(target_x, curr) do
    if Enum.sum(0..curr) >= target_x do
      curr
    else
      min_possible_x_velocity(target_x, curr + 1)
    end
  end

  defp possible_y_velocities(min_y.._) do
    min_y..(-(min_y + 1))
  end

  def all_velocities({target_x, target_y}) do
    xs = possible_x_velocities(target_x)
    ys = possible_y_velocities(target_y)
    (for x <- xs, y <- ys, do: {x, y})
    |> Enum.filter(fn vel -> reaches_target?(target_x, target_y, vel) end)
  end

  def reaches_target?(target_x, target_y, vel) do
    reaches_target?(target_x, target_y, vel, {0,0})
  end

  defp reaches_target?(
    min_x..max_x = target_x,
    min_y..max_y = target_y,
    {x_vel, y_vel},
    {x,y}
  ) do
    cond do
      x in target_x && y in target_y ->
        true
      x > max_x || y < min_y ->
        false
      x < min_x || y > max_y ->
        new_x_vel =
          case x_vel - 1 do
            new_x_vel when new_x_vel <= 0 -> 0
            new_x_vel -> new_x_vel
          end

        reaches_target?(
          target_x,
          target_y,
          {new_x_vel, y_vel - 1},
          {x + x_vel, y + y_vel}
        )
    end
  end
end

# Part 1
TrickShot.highest_y(-10..-5)
|> IO.inspect

{_, y_range} = TrickShot.read_input("input")
TrickShot.highest_y(y_range)
|> IO.inspect

# Part 2
actual =
  TrickShot.all_velocities({20..30, -10..-5})
  |> MapSet.new()

_expected =
  Regex.scan(~r/(-?\d+),(-?\d+)/, File.read!("test_velocities"), capture: :all_but_first)
  |> Enum.map(fn [x,y] -> {String.to_integer(x), String.to_integer(y)} end)
  |> MapSet.new()

MapSet.size(actual) |> IO.inspect

TrickShot.read_input("input")
|> TrickShot.all_velocities()
|> Enum.count()
|> IO.inspect
