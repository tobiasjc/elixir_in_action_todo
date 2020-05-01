defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  @spec new(any) :: any
  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, &add_entry(&2, &1))
  end

  @spec add_entry(%Todo.List{}, map) :: %Todo.List{}
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)
    %Todo.List{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  @spec update_entry(atom | %{entries: map}, %{id: any}) :: atom | %{entries: map}
  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  @spec remove_entry(atom | %{entries: map}, any) :: atom | %{entries: map}
  def remove_entry(todo_list, entry_id) do
    case Map.pop(todo_list.entries, entry_id) do
      {nil, _} ->
        todo_list

      {_, new_entries} ->
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  @spec update_entry(atom | %{entries: map}, any, any) :: atom | %{entries: map}
  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  @spec entries(atom | %{entries: any}, any) :: [any]
  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end
end
