defmodule Todo.DatabaseWorker do
  use GenServer

  # Client

  @spec start_link({any, any}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(db_folder) do
    # IO.puts("Starting database worker #{self()}")

    GenServer.start_link(
      __MODULE__,
      db_folder
    )
  end

  @spec store(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def store(pid, key, data) do
    GenServer.call(pid, {:store, key, data})
  end

  @spec get(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # Callbacks

  @impl GenServer
  @spec init(any) :: {:ok, any} | {:stop, map}
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    data =
      case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  @impl GenServer
  def handle_call({:store, key, data}, _from, db_folder) do
    db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, :ok, db_folder}
  end

  # Helpers

  # defp via_tuple(worker_id) do
  #   Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  # end

  defp file_name(folder, key) do
    Path.join(folder, to_string(key))
  end
end
