defmodule DumboOctopus do
  def read_input(filename) do
    File.stream!(filename)
    |> Enum.map(&String.trim_trailing/1)
    |> read_to_octomap()
  end

  defp read_to_octomap(lines) do
    read_to_octomap(lines, 0, %{})
  end

  defp read_to_octomap([], _, octomap), do: octomap
  defp read_to_octomap([line | rest], y, octomap) do
    new_octomap =
      String.to_charlist(line)
      |> Enum.with_index()
      |> Enum.reduce(octomap, fn {char, x}, acc ->
        energy = List.to_integer([char])
        Map.put(acc, {x, y}, %{energy: energy, flashed: false})
      end)

    read_to_octomap(rest, y + 1, new_octomap)
  end

  def steps_until_all_flash(octomap) do
    steps_until_all_flash(octomap, 1)
  end

  defp steps_until_all_flash(octomap, step) do
    case step(octomap) do
      {new_octomap, 100} ->
        {new_octomap, step}
      {new_octomap, _} ->
        steps_until_all_flash(new_octomap, step + 1)
    end
  end

  def steps(octomap, steps) do
    Enum.reduce(1..steps, {octomap, 0}, fn _step, {acc_octomap, acc_flashes} ->
      {new_octomap, step_flashes} = step(acc_octomap)
      {new_octomap, step_flashes + acc_flashes}
    end)
  end

  defp step(octomap) do
    octomap = increase_step(octomap)
    octomap = flash_step(octomap)

    # Count flashes before they are reset
    flashes = Enum.count(octomap, fn
      {_key, %{flashed: true}} -> true
      _ -> false
    end)

    octomap = reset_step(octomap)

    {octomap, flashes}
  end

  defp increase_step(octomap) do
    Enum.map(octomap, fn {coord, %{energy: energy}} -> {coord, %{energy: energy + 1, flashed: false}} end)
    |> Enum.into(%{})
  end

  defp flash_step(octomap) do
    to_flash = Enum.find(octomap, fn
      {_coord, %{energy: energy, flashed: false}} when energy > 9 -> true
      _ -> false
    end)

    case to_flash do
      nil ->
        octomap
      {coord, _entry} ->
        Enum.reduce(adjacent_to(coord), octomap, fn adj_coord, acc_octomap ->
          Map.update!(acc_octomap, adj_coord, fn adj_entry = %{energy: adj_energy} ->
            Map.put(adj_entry, :energy, adj_energy + 1)
          end)
        end)
        |> Map.update!(coord, fn entry ->
          Map.put(entry, :flashed, true)
        end)
        |> flash_step()
    end
  end

  defp reset_step(octomap) do
    Enum.map(octomap, fn
      {coord, %{energy: energy}} when energy > 9 ->
        {coord, %{energy: 0, flashed: false}}
      {coord, %{energy: energy}} ->
        {coord, %{energy: energy, flashed: false}}
    end)
    |> Enum.into(%{})
  end

  defp adjacent_to({x,y}) do
    for ax <- (x - 1)..(x + 1), ay <- (y - 1)..(y + 1),
      {x,y} != {ax, ay} && ax >= 0 && ax <= 9 && ay >= 0 && ay <= 9 do
        {ax, ay}
      end
  end
end

# Part 1
DumboOctopus.read_input("small_test_input")
|> DumboOctopus.steps(2)
|> elem(1)
|> IO.inspect()

DumboOctopus.read_input("test_input")
|> DumboOctopus.steps(100)
|> elem(1)
|> IO.inspect()

# Part 2
DumboOctopus.read_input("test_input")
|> DumboOctopus.steps_until_all_flash()
|> elem(1)
|> IO.inspect()

DumboOctopus.read_input("input")
|> DumboOctopus.steps_until_all_flash()
|> elem(1)
|> IO.inspect()
