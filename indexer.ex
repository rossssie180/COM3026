defmodule Indexer do

  # exercise: convert to downcase, should be here
  def map(file, content) do
    content
      |> String.split(~r{\W+}, trim: true)
      |> (fn x -> (for y <- x, into: %MapSet{} do y end) end).()
      |> MapSet.to_list()
      |> Enum.map(fn w -> {String.downcase(w), file} end)
  end

  # vals is a list of intermediate values
  # for a single intermediate key
  def reduce(_key, vals) do
    "#{inspect(length(vals))} " <> Enum.join(Enum.sort(vals), ",")

    # (fn vs ->
    #   Enum.join(
    #   (Enum.slice(vs, 0, length(vs)-1) |>
    #   Enum.map(fn x -> x <> ", " end))
    #   )<> Enum.at(vs, length(vs)-1)
    # end).(Enum.sort(vals))
  end

end
