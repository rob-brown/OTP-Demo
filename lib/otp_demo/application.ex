defmodule OtpDemo.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # A stack process with default args.
      OtpDemo.Stack,

      # A stack process with a name.
      {OtpDemo.Stack, [name: :stack]},

      # A stack process that won't restart if stopped normally.
      Supervisor.child_spec({OtpDemo.Stack, [name: :another]}, restart: :transient),

      # A stack process using a custom GenServer.
      {OtpDemo.GenStack, [name: :gen]},

      # A custom Supervisor with one stack process.
      {OtpDemo.Super, [[{OtpDemo.Stack, [name: :last]}]]}
    ]

    opts = [strategy: :one_for_one, name: OtpDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
