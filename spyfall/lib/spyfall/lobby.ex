defmodule Spyfall.Lobby do
  def handle_call(:start, _from, state) do
    {players, min} = state

    if Set.size(players) < min do
      {:reply, {:error, "At least #{min} players are needed to start"}, state}
    else
      {:reply, Spyfall.Game.start_link(Set.to_list(players)), state}
    end
  end

  def start_link do
    Agent.start_link(fn -> HashSet.new end)
  end

  def join(lobby, player) do
    Agent.get_and_update(lobby, fn players ->
      if Set.member?(players, player) do
        {{:error, "#{player} is already in the lobby"}, players}
      else
        {:ok, Set.put(players, player)}
      end
    end)
  end

  def leave(lobby, player) do
    Agent.get_and_update(lobby, fn players ->
      if not Set.member?(players, player) do
        {{:error, "#{player} is not in the lobby"}, players}
      else
        {:ok, Set.delete(players, player)}
      end
    end)
  end

  def players(lobby) do
    Agent.get(lobby, &Set.to_list(&1))
  end

  def start_game(lobby) do
    min = Application.get_env(:spyfall, :min_players)

    Agent.get_and_update(lobby, fn players ->
      if Set.size(players) < min do
        {{:error, "At least #{min} players are needed to start"}, players}
      else
        {Spyfall.Game.start_link(Set.to_list(players)), players}
      end
    end)
  end
end
