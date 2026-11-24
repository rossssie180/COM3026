defmodule WordCount do

  # exercise: convert to downcase, should be here
  def map(_, content) do
    content
      |> String.split(~r{\W+}, trim: true)
      |> Enum.map(fn w -> {String.downcase(w), "1"} end)
  end

  def reduce(_key, vals) do
    length(vals)
  end

end
