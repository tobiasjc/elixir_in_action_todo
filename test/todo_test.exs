defmodule TodoTest do
  use ExUnit.Case

  doctest Todo.Cache

  test "to-do operations" do
    # {:ok, cache} = Todo.Cache.start()
    alice_pid = Todo.Cache.server_process("alice")
    Todo.Server.put(alice_pid, %{date: ~D[2020-10-10], title: "Dentist"})
    entries = Todo.Server.get(alice_pid, ~D[2020-10-10])
    head = Enum.find(entries, fn entry -> entry.id == 3 end)

    assert %{date: ~D[2020-10-10], id: 3, title: "Dentist"} == head
  end

  test "server process" do
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end
end
