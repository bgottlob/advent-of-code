defmodule Whales do
  def read_input(filename) do
    File.read!(filename)
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def cheapest_fuel(subs) do
    {min, max} = Enum.min_max(subs)
    
    Enum.to_list(min..max)
    |> Enum.reduce(
      :infinity, # https://elixirforum.com/t/infinity-in-elixir-erlang/7396
      fn position, cheapest ->
        cheapest_fuel(subs, position, 0, cheapest)
      end
    )
  end

  # Calculate the fuel cost to move all submarines to the given position

  # Optimization: bail when the current cost equals or exceeds the cheapest found so far
  defp cheapest_fuel(_subs, _position, cost, cheapest) when cost >= cheapest do
    cheapest
  end
  # This is the new cheapest cost
  defp cheapest_fuel([], _position, total_cost, _cheapest), do: total_cost
  defp cheapest_fuel([sub | rest], position, total_cost, cheapest) do
    cheapest_fuel(rest, position, total_cost + cost2(sub, position), cheapest)
  end

  # The cost for moving a single sub to the given position
  def cost1(sub, position) do
    abs(sub - position)
  end

  def cost2(sub, position) do
    Enum.sum(for x <- 0..abs(sub - position), do: x)
  end
end

Whales.read_input("test_input")
|> Whales.cheapest_fuel()
|> IO.inspect

Whales.read_input("input")
|> Whales.cheapest_fuel()
|> IO.inspect
