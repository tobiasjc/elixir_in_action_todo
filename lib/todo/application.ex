defmodule Todo.Application do
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_, _) do
    Todo.System.start_link()
  end
end
