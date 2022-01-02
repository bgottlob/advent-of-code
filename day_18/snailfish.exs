#defmodule Snailfish do
#  def read_snail_number(str) when is_binary(str) do
#    Code.eval_string(str) |> elem(0)
#  end
#
#  def find_explode(pair) do
#    find_explode(pair, [])
#  end
#
#  # Find a pair that should be exploded
#  def find_explode(pair, path) when length(path) == 4 do
#    explode(pair, path)
#  end
#
#  def find_explode(curr = [left, _right], path) when is_list(left) do
#    find_explode(left, [{:left, curr} | path])
#  end
#
#  def find_explode(curr = [_left, right], path) when is_list(right) do
#    find_explode(right, [{:right, curr} | path])
#  end
#
#  def find_explode(pair = [_,_], _), do: pair
#
#  defp explode([left, right], path) do
#    {left_neighbor, [{dir, left_neighbor_pair} | new_path]} = left_neighbor(path)
#  end
#
#  # Left neighbor operation:
#  # 1. Traverse up the path until you come from the right
#  # 2. Traverse one step down to the left
#  # 3. Traverse as far to the right as possible
#  defp left_neighbor(path) do
#    traverse_up_left_neighbor(path)
#  end
#
#  # There is no left neighbor
#  defp traverse_up_left_neighbor([]), do: nil
#
#  defp traverse_up_left_neighbor([{:left, _} | path]) do
#    traverse_up_left_neighbor(path)
#  end
#
#  defp traverse_up_left_neighbor([{:right, [left, _right]} | path]) do
#    case left do
#      neighbor when is_integer(neighbor) ->
#        {neighbor, [{:left, neighbor} | path]}
#      [neighbor,_] when is_integer(neighbor) ->
#        {neighbor, path}
#      [pair = [_,_], _] ->
#        traverse_down_left_neighbor(pair, path)
#    end
#  end
#
#  defp traverse_down_left_neighbor([_, right], path) when is_integer(right) do
#    {right, path}
#  end
#
#  defp traverse_down_left_neighbor([_, right = [_,_]], path) do
#    traverse_down_left_neighbor(right, [{:right, right} | path])
#  end
#end

defmodule Snailfish do
  def read_snail_number(str) do
    Code.eval_string(str)
    |> elem(0)
    |> to_tree_map()
  end

  def to_tree_map(deep_list) do
    to_tree_map(deep_list, 0, %{})
  end

  def to_tree_map([left, right], curr, acc) do
    acc = Map.put(acc, curr, :pair)
    acc = to_tree_map(left, (2 * curr) + 1, acc)
    to_tree_map(right, (2 * curr) + 2, acc)
  end

  def to_tree_map(int, curr, acc) when is_integer(int) do
    Map.put(acc, curr, int)
  end

  defp left_child(id),  do: (2 * id) + 1
  defp right_child(id), do: (2 * id) + 2

  def is_left_child?(id),  do: rem(id, 2) != 0
  def is_right_child?(id), do: rem(id, 2) == 0

  def parent(0), do: nil
  def parent(id) do
    sub = case rem(id, 2) do
      1 -> 1
      0 -> 2
    end
    div(id - sub, 2)
  end

  def explode(tree) do
    to_explode = to_explode(tree, 0, 0) |> IO.inspect
    left_neighbor = left_neighbor(tree, to_explode) |> IO.inspect
    right_neighbor = right_neighbor(tree, to_explode) |> IO.inspect

    tree = update_neighbor(tree, left_child(to_explode), left_neighbor)
    tree = update_neighbor(tree, right_child(to_explode), right_neighbor)

    tree
    |> Map.delete(left_child(to_explode))
    |> Map.delete(right_child(to_explode))
    |> Map.put(to_explode, 0)
  end

  defp update_neighbor(tree, _to_add_id, nil), do: tree
  defp update_neighbor(tree, to_add_id, neighbor_id) do
    Map.update!(
      tree,
      neighbor_id,
      fn val -> val + Map.fetch!(tree, to_add_id) end
    )
  end

  # Returns the id of the :pair node to be exploded
  defp to_explode(_tree, curr, 4), do: curr
  defp to_explode(tree, curr, levels) do
    case {has_left_pair?(tree, curr), has_right_pair?(tree, curr)} do
      {true, _} ->
        to_explode(tree, left_child(curr), levels + 1)
      {false, true} ->
        to_explode(tree, right_child(curr), levels + 1)
      {false, false} ->
        nil
    end
  end

  defp has_left_pair?(tree, curr) do
    Map.get(tree, left_child(curr), nil) == :pair
  end

  defp has_right_pair?(tree, curr) do
    Map.get(tree, right_child(curr), nil) == :pair
  end

  # Left neighbor operation:
  # 1. Traverse up the path until you come from the right
  # 2. Traverse one step down to the left
  # 3. Traverse as far to the right as possible
  def left_neighbor(tree, id) do
    case traverse_up_left_neighbor(id) do
      nil ->
        nil
      curr ->
        case has_left_pair?(tree, curr) do
          true ->
            traverse_rightmost(tree, left_child(curr))
          false ->
            left_child(curr)
        end
    end
  end

  defp traverse_up_left_neighbor(id) do
    par = parent(id)
    case is_right_child?(id) do
      true ->
        par
      false ->
        traverse_up_left_neighbor(par)
    end
  end

  defp traverse_rightmost(tree, curr) do
    case has_right_pair?(tree, curr) do
      true ->
        traverse_rightmost(tree, right_child(curr))
      false ->
        right_child(curr)
    end
  end

  # Left neighbor operation:
  # 1. Traverse up the path until you come from the left
  # 2. Traverse one step down to the right
  # 3. Traverse as far to the left as possible
  def right_neighbor(tree, id) do
    curr = traverse_up_right_neighbor(id)

    case has_right_pair?(tree, curr) do
      true ->
        traverse_leftmost(tree, right_child(curr))
      false ->
        right_child(curr)
    end
  end

  defp traverse_up_right_neighbor(id) do
    par = parent(id)
    case is_left_child?(id) do
      true ->
        par
      false ->
        traverse_up_right_neighbor(par)
    end
  end

  defp traverse_leftmost(tree, curr) do
    case has_left_pair?(tree, curr) do
      true ->
        traverse_leftmost(tree, left_child(curr))
      false ->
        left_child(curr)
    end
  end
end

#Snailfish.read_snail_number("[[6,[5,[4,[3,2]]]],1]")
#|> IO.inspect
#|> Snailfish.explode()
#|> IO.inspect

Snailfish.read_snail_number("[[[[[9,8],1],2],3],4]")
|> IO.inspect
|> Snailfish.explode()
|> IO.inspect
