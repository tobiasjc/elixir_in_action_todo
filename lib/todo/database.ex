defmodule Todo.Database do
  @db_folder "./persist/#{node()}"

  @pool_size 3

  # Client

  @spec store(any, any) :: :ok
  def store(key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :store_local,
        [key, data],
        :timer.seconds(5)
      )

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
  end

  @spec store_local(any, any) :: any
  def store_local(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.store(worker_pid, key, data)
      end
    )
  end

  @spec get(any) :: any
  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> Todo.DatabaseWorker.get(worker_pid, key) end
    )
  end

  # Implementation

  @spec child_spec(any) :: no_return()
  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @pool_size
      ],
      [@db_folder]
    )
  end

  # Helpers
end
