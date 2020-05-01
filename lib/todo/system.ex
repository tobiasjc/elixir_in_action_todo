defmodule Todo.System do
  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link do
    Supervisor.start_link(
      [
        Todo.Database,
        Todo.Cache,
        Todo.Web
      ],
      strategy: :one_for_one
    )
  end
end
