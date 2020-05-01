defmodule Todo.Cache do
  # Interface

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    IO.puts("Starting to-do cacche")

    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  @spec server_process(any) :: any
  def server_process(todo_list_name) do
    existing_process(todo_list_name) || new_process(todo_list_name)
  end

  # Implementations

  @spec child_spec(any) :: %{
          id: Todo.Cache,
          start: {Todo.Cache, :start_link, []},
          type: :supervisor
        }
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  # Helpers

  defp existing_process(todo_list_name) do
    Todo.Server.whereis(todo_list_name)
  end

  defp new_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    )
  end
end
