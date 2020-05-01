defmodule Todo.Server do
  use GenServer, restart: :temporary
  @expiry_idle_timeout :timer.seconds(10)

  # Client

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(name) do
    IO.puts("Starting to-do server for name #{name}")
    GenServer.start_link(Todo.Server, name, name: global_name(name))
  end

  @spec put(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def put(server, entry) do
    GenServer.cast(server, {:put, entry})
  end

  @spec get(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def get(server, date) do
    GenServer.call(server, {:get, date})
  end

  @spec update(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def update(server, entry) do
    GenServer.cast(server, {:update, entry})
  end

  @spec update(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def update(server, id, fun) do
    GenServer.cast(server, {:update, id, fun})
  end

  @spec all(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def all(server) do
    GenServer.call(server, {:all})
  end

  # Callbacks

  @impl GenServer
  @spec init(any) :: {:ok, {any, any}, 10000}
  def init(name) do
    {
      :ok,
      {name, Todo.Database.get(name) || Todo.List.new()},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_call({:get, date}, _from, {name, state}) do
    response = Todo.List.entries(state, date)

    {
      :reply,
      response,
      {name, state},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_call({:all}, _from, {name, state}) do
    {
      :reply,
      state.entries,
      {name, state},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_cast({:put, entry}, {name, state}) do
    new_list = Todo.List.add_entry(state, entry)
    Todo.Database.store(name, new_list)

    {
      :noreply,
      {name, new_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_cast({:update, entry}, {name, state}) do
    new_list = Todo.List.update_entry(state, entry)
    Todo.Database.store(name, new_list)

    {
      :noreply,
      {name, new_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_cast({:update, id, fun}, {name, state}) do
    new_list = Todo.List.update_entry(state, id, fun)
    Todo.Database.store(name, new_list)

    {
      :noreply,
      {name, new_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  @spec handle_info(:timeout, {any, any}) :: {:stop, :normal, {any, any}}
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")

    {
      :stop,
      :normal,
      {name, todo_list}
    }
  end

  # Helpers

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end

  @spec whereis(any) :: nil | pid
  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end
end
