defmodule OtpDemo.Gen do
  @moduledoc """
  A reimplementation of GenServer.
  Only for educational insight.
  """

  def start_link(options) do
    mod = Keyword.fetch!(options, :module)
    name = Keyword.get(options, :name, __MODULE__)
    pid = spawn_link(__MODULE__, :init, [mod])
    Process.register(pid, name)
    {:ok, pid}
  end

  def child_spec(mod, args) do
    [module: mod, name: mod]
    |> Keyword.merge(args)
    |> child_spec()
  end

  def child_spec(args) do
    %{
      id: Keyword.get(args, :name, __MODULE__),
      start: {__MODULE__, :start_link, [args]},
      restart: :permanent
    }
  end

  def init(mod) do
    state = mod.init()
    loop(mod, state)
  end

  def loop(mod, state) do
    receive do
      {:call, from, msg} ->
        case mod.handle_call(msg, state) do
          {:reply, msg, new_state} ->
            respond(from, msg)
            loop(mod, new_state)

          {:noreply, new_state} ->
            loop(mod, new_state)
        end

      {:cast, msg} ->
        new_state = mod.handle_cast(msg, state)
        loop(mod, new_state)

      :stop ->
        IO.puts("Stopping")
        :ok
    end
  end

  def cast(gen, msg) do
    send(gen, {:cast, msg})
    :ok
  end

  def call(gen, msg) do
    ref = make_ref()
    send(gen, {:call, {self(), ref}, msg})

    receive do
      {^ref, response} ->
        response
    after
      5000 ->
        :timeout
    end
  end

  ## Helpers

  defp respond({sender, ref}, response) do
    send(sender, {ref, response})
  end
end
