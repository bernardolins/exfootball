defmodule Exfootball.External.FootballDataTest do
  use ExUnit.Case
  import FakeServer

  alias Exfootball.External.FootballData
  alias FakeServer.HTTP.Response

  @error_base_string "A request to football-data api returned an invalid status:"

  describe "#list_competitions" do
    test_with_server "raises if football-data api returns 4XX" do
      Application.put_env(:exfootball, :football_data_api_url, "http://#{FakeServer.address}")

      route "/competitions", Response.all_4xx

      Enum.each(Response.all_4xx, fn(%{code: status_code}) ->
        assert_raise RuntimeError, "#{@error_base_string} #{status_code}", fn ->
          FootballData.list_competitions
        end
      end)
    end

    test_with_server "raises if football-data api returns 5XX" do
      Application.put_env(:exfootball, :football_data_api_url, "http://#{FakeServer.address}")

      route "/competitions", Response.all_5xx

      Enum.each(Response.all_5xx, fn(%{code: status_code}) ->
        assert_raise RuntimeError, "#{@error_base_string} #{status_code}", fn ->
          FootballData.list_competitions
        end
      end)
    end

    test_with_server "raises Tesla.Error when request timeout" do
      Application.put_env(:exfootball, :football_data_api_url, "http://#{FakeServer.address}")

      route "/competitions", fn(_) -> :timer.sleep(550) end

      assert_raise Tesla.Error, fn -> FootballData.list_competitions end
    end

    test_with_server "returns a list of tuples with the same size of the list of competitions replied by football-data api" do
      Application.put_env(:exfootball, :football_data_api_url, "http://#{FakeServer.address}")

      route "/competitions" do
        Response.ok(
          [%{id: 444, caption: "Campeonato Brasileiro da Série A"},
           %{id: 445, caption: "Premier League 2017/18"},
           %{id: 446, caption: "Championship 2017/18"}],
          %{"content-type" => "application/json"}
        )
      end

      competition_list = Enum.to_list(FootballData.list_competitions)

      assert length(competition_list) == 3
    end

    test_with_server "returns a list with the names and ids of all competitions replied by football-data api" do
      Application.put_env(:exfootball, :football_data_api_url, "http://#{FakeServer.address}")

      competitions_response = Exfootball.Support.FootballDataResponses.build(:competitions)

      route "/competitions", competitions_response

      competitions = FootballData.list_competitions

      Enum.each(competitions_response.body, fn(c) ->
        refute is_nil(Map.get(competitions, c[:id]))
        assert c[:caption] == Map.get(competitions, c[:id])
      end)
    end
  end
end
