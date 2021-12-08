defmodule Lanternfish do
  def read_input(filename) do
    File.read!(filename)
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  # Memo format
  # %{
  #   {current_timer, days_remaining} => total_fish_count
  # }
  # Returns {fish_count, memo}
  defp fish_count(timer, days, memo) do
    case Map.fetch(memo, {timer, days}) do
      {:ok, count} ->
        {count, memo}
      :error ->
        case days - (timer + 1) do
          remaining when remaining >= 0 ->
            {count_curr, memo} = fish_count(6, remaining, memo)
            {count_reset, memo} = fish_count(8, remaining, memo)
            total = count_curr + count_reset
            memo = Map.put_new(memo, {timer, days}, total)
            {total, memo}
          _ ->
            {1, Map.put_new(memo, {timer, days}, 1)}
        end
    end
  end

  def all_fish_count(timers, days) do
    Enum.reduce(timers, {0, %{}}, fn timer, {acc, memo} ->
      {count, new_memo} = fish_count(timer, days, memo)
      {count + acc, new_memo}
    end)
    |> elem(0)
  end
end

Lanternfish.read_input("input")
|> Lanternfish.all_fish_count(256)
|> IO.inspect()
