defmodule Master do

  def start(files, nR) do
    spawn(Master, :init, [files, nR, self()])
  end

  def wait_until_done() do
    receive do
      m -> m
    end
  end

  def init(files, nR, parent) do

    state = %{
      parent: parent
    }

    run(state)
  end


  def run(state) do
    state =
      receive do
        # idle worker handshake
        {:idle, pid} ->
          IO.puts("Got idle from worker #{inspect(pid)}: handshake")
          Process.monitor(pid)
          # TODO: add your code here
          # Don't forget to return state at the end

        # map worker completes
        {:map, pid, n, files} ->
          IO.puts("Got map task complete from worker #{inspect(pid)}")
          # TODO: add your code here
          # Don't forget to return state at the end

        # reduce worker completes
        {:reduce, pid, n, file} ->
          IO.puts("Got reduce task complete from worker #{inspect(pid)}")
          # TODO: add your code here
          # Don't forget to return state at the end

        # failed worker
        {:DOWN, _, :process, pid, reason} ->
          IO.puts("worker #{inspect(pid)} is down")
          # TODO: add your code here
          # Don't forget to return state at the end

        end # receive

    run(state)
  end # run
end
# module
