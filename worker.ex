defmodule Worker do

  def init(mapf, reducef, hash, master) do
    state = %{
      mapf: mapf,
      reducef: reducef,
      hash: hash,
      master: master
    }

    send(master, {:idle, self()})
    run(state)
  end

  def run(state) do
    state =
      receive do
        # Map task from the master
        {:map, n, file, nR} ->
          IO.puts("Got map task from master")
          # TODO: add your code here
          # Don't forget to return state at the end


        # Reduce task from the master
        {:reduce, n, files} ->
          IO.puts("Got reduce task from master")
          # TODO: add your code here
          # Don't forget to return state at the end

      end

    run(state)
  end
end
