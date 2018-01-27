defmodule Exfootball.Support.FootballDataResponses do
  use FakeServer.ResponseFactory

  def competitions_response do
    list_size = :random.uniform(10)
    competition_list = Enum.map(1..list_size, fn(_) ->
      %{id: :random.uniform(1000), caption: "#{Faker.Address.country} Championship"}
    end)

    ok(competition_list, %{"content-type" => "application/json"})
  end
end