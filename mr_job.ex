defmodule MRJob do

  def load_mr(mr) do
    mr
    |> Code.compile_file()
    |> (fn [{mod, _} | _] -> mod end).()
    |> (fn mod ->
          if function_exported?(mod, :reduce, 2),
            do: {mod, [Function.capture(mod, :reduce, 2)]},
            else: {mod, [nil]}
        end).()
    |> (fn {mod, lst} ->
          if function_exported?(mod, :map, 2),
            do: [Function.capture(mod, :map, 2) | lst],
            else: [nil | lst]
        end).()
  end

  def run(prog, files, nR, nW, hash) do
    mpid = Master.start(files, nR)
    [mapf, reducef] = load_mr(prog)
    wpids = Enum.map(1..nW, fn _ -> spawn(Worker, :init, [mapf, reducef, hash, mpid]) end)
    ret = {status, _} = Master.wait_until_done()
    # IO.puts(inspect(ret))
    Enum.each(wpids, fn p -> Process.exit(p, :kill) end)
    if status == :done do
      out_files = ret |> elem(1)

      kv_strings =
        Enum.concat(
          Enum.map(
            out_files,
            fn f -> File.read!(f) |> String.split("\n", trim: true) end
          )
        )

      kvs = Enum.map(kv_strings, fn kv -> Code.eval_string(kv) |> elem(0) end)
      lst = Enum.sort(kvs, &(elem(&1, 0) <= elem(&2, 0)))
      output = Enum.map(lst, fn {k, v} -> "#{inspect({k, v}, limit: :infinity, printable_limit: :infinity)}\n" end)
      File.write("mr_out_all", output)

      # Uncomment the following line if you want to remove the original output files
      # Enum.each(out_files, fn f -> File.rm(f) end)

      # IO.puts("Job done!")
      ret
    else
      # IO.puts("Error: #{reason}")
      ret
    end
  end
end
