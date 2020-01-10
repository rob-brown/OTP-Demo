defmodule OtpDemo.Stack do
  @moduledoc """
  A stack process with its own run loop.
  See OtpDemo.GenStack to see the GenServer logic extracted.
  """

  def start_link(options) do
    name = Keyword.get(options, :name, __MODULE__)
    pid = spawn_link(__MODULE__, :loop, [[]])
    Process.register(pid, name)
    {:ok, pid}
  end

  def child_spec(args) do
    %{
      id: Keyword.get(args, :name, __MODULE__),
      start: {__MODULE__, :start_link, [args]},
      restart: :permanent
    }
  end

  def loop(stack) do
    receive do
      {:push, item} ->
        loop([item | stack])

      {from, :pop} ->
        respond(from, Enum.at(stack, 0, :empty))
        loop(Enum.drop(stack, 1))

      {from, :peek} ->
        respond(from, Enum.at(stack, 0, :empty))
        loop(stack)

      {from, :count} ->
        respond(from, Enum.count(stack))
        loop(stack)

      :stop ->
        IO.puts("Stopping")
        :ok
    end
  end

  def push(stack, item) do
    cast(stack, {:push, item})
  end

  def pop(stack) do
    call(stack, :pop)
  end

  def peek(stack) do
    call(stack, :peek)
  end

  def count(stack) do
    call(stack, :count)
  end

  def stop(stack) do
    cast(stack, :stop)
  end

  ## Helpers

  defp cast(stack, msg) do
    send(stack, msg)
    :ok
  end

  defp call(stack, msg) do
    ref = make_ref()
    send(stack, {{self(), ref}, msg})

    receive do
      {^ref, response} ->
        response
    after
      5000 ->
        :timeout
    end
  end

  defp respond({sender, ref}, response) do
    send(sender, {ref, response})
  end
end
