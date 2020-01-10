defmodule OtpDemo.GenStack do
  @moduledoc """
  A stack process that uses a home-grown GenServer.
  """

  def child_spec(args) do
    OtpDemo.Gen.child_spec(__MODULE__, args)
  end

  def init() do
    []
  end

  def push(stack, item) do
    OtpDemo.Gen.cast(stack, {:push, item})
  end

  def pop(stack) do
    OtpDemo.Gen.call(stack, :pop)
  end

  def peek(stack) do
    OtpDemo.Gen.call(stack, :peek)
  end

  def count(stack) do
    OtpDemo.Gen.call(stack, :count)
  end

  def handle_cast({:push, item}, state) do
    [item | state]
  end

  def handle_call(:peek, state) do
    {:reply, Enum.at(state, 0, :empty), state}
  end

  def handle_call(:pop, state) do
    {:reply, Enum.at(state, 0, :empty), Enum.drop(state, 1)}
  end

  def handle_call(:count, state) do
    {:reply, Enum.count(state), state}
  end
end
