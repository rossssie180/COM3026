defmodule MRSeq do

  def map_phase(files, mapf) do
    Enum.flat_map(files, fn file ->
      content = File.read!(file)
      mapf.(file, content)
    end)
  end

  def reduce_phase(intermediate, reducef) do
    intermediate
      |> Enum.group_by(fn {k, _v} -> k end, fn {_k, v} -> v end)
      |> Enum.map(fn {k, vals} -> {k, reducef.(k, vals)} end)
      |> Enum.sort_by(fn {k, _v} -> k end)
  end

  def run_mr_job(prog, input_dir) do
    [mapf, reducef] = load_mr(prog)
    if mapf != nil && reducef != nil do
      {_, files} = File.ls(input_dir)   # can assume files are there
      files = files |> Enum.map(fn s -> input_dir <> "/" <> s end)
      intermediate = map_phase(files, mapf)
      output = reduce_phase(intermediate, reducef)
      output = Enum.map(output, fn {k, v} -> "#{inspect({k, v})}\n" end)
      File.write("mr-out-0", output)
    else
      {:error, "Map or Reduce function is missing"}
    end
  end

  def load_mr(mr) do
    mr
    |> Code.compile_file()
    |> (fn [{mod, _} | _] -> mod end).()
    |> (fn mod -> if function_exported?(mod, :reduce, 2), do: {mod, [Function.capture(mod, :reduce, 2)]},
            else: {mod, [nil]} end).()
    |> (fn {mod, lst} -> if function_exported?(mod, :map, 2), do: [Function.capture(mod, :map, 2) | lst],
            else: [nil | lst] end).()
  end
end
