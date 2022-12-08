defmodule NoSpace do

  def parse_input(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.chunk_while( # group command with its output
      nil,
      fn line, acc ->
        if String.starts_with?(line, "$") do # start a new chunk for this cmd
          cmd = parse_cmd(line)
          if acc == nil do
            # Don't emit nothing before the first command
            {:cont, %{cmd: cmd}}
          else
            acc = Map.update(acc, :output, [], &Enum.reverse/1)
            {:cont, acc, %{cmd: cmd}}
          end
        else
          output = [line | Map.get(acc, :output, [])]
          {:cont, Map.put(acc, :output, output)}
        end
      end,
      fn acc -> {:cont, acc, nil} end
    )
  end

  defp parse_cmd(cmd) do
    cmd
    |> String.trim_leading("$ ")
    |> String.split()
    |> List.to_tuple()
  end

  def run(cmds) do
    run(cmds, "/", %{})
  end

  defp run([], _curr, acc), do: acc
  defp run([%{cmd: {"ls"}, output: output} | rest], curr, acc) do
    contents = Enum.map(output, &process_output_line/1)
    run(rest, curr, Map.put(acc, curr, %{contents: contents}))
  end

  defp run([%{cmd: {"cd", dir}} | rest], curr, acc) do
    curr =
      if String.starts_with?(dir, "/") do
        dir
      else
        # Path.expand/1 will process .. as the parent directory
        Path.join(curr, dir) |> Path.expand()
      end

    run(rest, curr, acc)
  end

  defp process_output_line(line) do
    case String.split(line) do
      ["dir", dir] -> {:dir, dir}
      [size, filename] -> {:file, filename, String.to_integer(size)}
    end
  end

  def calculate_sizes(directories) do
    # Sort by the number of / characters in the path, meaning the deepest
    # directories will have their sizes calculated first
    sorted = 
      directories
      |> Map.delete("/")
      |> Map.keys()
      |> Enum.sort_by(fn dir ->
        dir
        |> String.to_charlist()
        |> Enum.count(fn
          ?/ -> true
          _  -> false
        end)
      end, :desc)
    sorted = List.flatten([sorted, "/"])

    Enum.reduce(sorted, directories, fn dir, acc ->
      size = calculate_size(acc[dir][:contents], dir, acc, 0)
      Map.update!(acc, dir, fn record ->
        Map.put(record, :size, size)
      end)
    end)
  end

  defp calculate_size([], _curr_dir, _directories, total), do: total
  defp calculate_size([{:dir, dir} | rest], curr_dir, directories, total) do
    size = directories[Path.join(curr_dir, dir)][:size]
    calculate_size(rest, curr_dir, directories, total + size)
  end

  defp calculate_size([{:file, _, size} | rest], curr_dir, directories, total) do
    calculate_size(rest, curr_dir, directories, total + size)
  end

  # Calculates the sum of the directory sizes under (or equal to) some threshold
  def size_sum_threshold(directories, threshold) do
    Enum.reduce(directories, 0, fn {_dir, %{size: size}}, acc ->
      if size <= threshold do
        size + acc
      else
        acc
      end
    end)
  end

  def size_to_free(directories, total_disk_space, update_size) do
    unused_space = total_disk_space - directories["/"][:size]
    needed_space = update_size - unused_space

    directories
    |> Stream.map(fn {_dir, %{size: size}} -> size end)
    |> Enum.sort(:asc)
    |> Enum.find(&(&1 >= needed_space))
  end
end

IO.puts "Part 1"

NoSpace.parse_input("test_input")
|> NoSpace.run()
|> NoSpace.calculate_sizes()
|> NoSpace.size_sum_threshold(100_000)
|> IO.inspect

NoSpace.parse_input("input")
|> NoSpace.run()
|> NoSpace.calculate_sizes()
|> NoSpace.size_sum_threshold(100_000)
|> IO.inspect

IO.puts "Part 2"

NoSpace.parse_input("test_input")
|> NoSpace.run()
|> NoSpace.calculate_sizes()
|> NoSpace.size_to_free(70_000_000, 30_000_000)
|> IO.inspect

NoSpace.parse_input("input")
|> NoSpace.run()
|> NoSpace.calculate_sizes()
|> NoSpace.size_to_free(70_000_000, 30_000_000)
|> IO.inspect
