defmodule OtpDemo.Super do
  @moduledoc """
  A reimplementation of Supervisor.
  Only for educational insight.
  """

  defmodule Child do
    @enforce_keys [:pid, :ref, :spec]
    defstruct [:pid, :ref, :spec]
  end

  alias __MODULE__.Child

  def start_link(children) do
    IO.puts("Starting custom supervisor")
    pid = spawn_link(__MODULE__, :init, [children])
    {:ok, pid}
  end

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args}
    }
  end

  def init(children) do
    Process.flag(:trap_exit, true)

    children
    |> Enum.map(&get_spec/1)
    |> Enum.map(&start_child/1)
    |> Map.new(&{&1.pid, &1})
    |> loop()
  end

  def loop(state) do
    receive do
      {:DOWN, _ref, _type, pid, _info} ->
        IO.puts("Supervisor got down")

        state
        |> maybe_restart(pid)
        |> loop()

      {:EXIT, _from, _reason} ->
        IO.puts("Supervisor got exit")
        loop(state)
    end
  end

  ## Helpers

  defp get_spec({module, args}) do
    module.child_spec(args)
  end

  defp get_spec(module) do
    get_spec({module, []})
  end

  defp start_child(spec) do
    {m, f, a} = spec.start
    {:ok, pid} = :erlang.apply(m, f, a)
    ref = Process.monitor(pid)
    %Child{pid: pid, ref: ref, spec: spec}
  end

  defp maybe_restart(state, pid) do
    with c = %Child{} <- state[pid],
         x when x in [:permanent, :transient] <-
           Map.get(c.spec, :restart, :permanent),
         new_child = start_child(c.spec) do
      state
      |> Map.delete(pid)
      |> Map.put(pid, new_child)
    else
      _ ->
        state
    end
  end
end
