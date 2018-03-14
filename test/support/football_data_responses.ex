defmodule Exfootball.Support.FootballDataResponses do
  use FakeServer.ResponseFactory

  def competitions_response do
    list_size = :rand.uniform(10)
    competition_list = Enum.map(1..list_size, fn(_) ->
      %{id: :rand.uniform(1000), caption: "#{Faker.Address.country} Championship"}
    end)

    ok(competition_list, %{"content-type" => "application/json"})
  end

  def competition_teams_response do
    table_size = :rand.uniform(20)
    teams = Enum.map(1..table_size, fn(position) ->
      %{name: "#{Faker.Address.city} FC"}
    end)

    ok(%{teams: teams}, %{"content-type" => "application/json"})
  end
end
