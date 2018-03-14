defmodule Exfootball.External.FootballDataTest do
  use ExUnit.Case
  import FakeServer

  alias Exfootball.External.FootballData
  alias FakeServer.HTTP.Response

  @error_base_string "A request to football-data api returned an invalid status:"

  describe "#list_competitions" do
    test_with_server "raises if football-data api returns 4XX" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions", Response.all_4xx

      Enum.each(Response.all_4xx, fn(%{code: status_code}) ->
        assert_raise RuntimeError, "#{@error_base_string} #{status_code}", fn ->
          FootballData.list_competitions
        end
      end)
    end

    test_with_server "raises if football-data api returns 5XX" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions", Response.all_5xx

      Enum.each(Response.all_5xx, fn(%{code: status_code}) ->
        assert_raise RuntimeError, "#{@error_base_string} #{status_code}", fn ->
          FootballData.list_competitions
        end
      end)
    end

    test_with_server "raises Tesla.Error when request timeout" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions", fn(_) ->
        timeout = Application.get_env(:exfootball, :football_data_api_timeout) + 20
        :timer.sleep(timeout)
      end

      assert_raise Tesla.Error, fn -> FootballData.list_competitions end
    end

    test_with_server "returns an empty list if there are no competitions available" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions", Response.ok([], %{"content-type" => "application/json"})

      assert FootballData.list_competitions == %{}
    end

    test_with_server "returns a list of tuples with the same size of the list of competitions replied by football-data api" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      competition_list = [%{id: 444, caption: "Campeonato Brasileiro da Série A"}, %{id: 445, caption: "Premier League 2017/18"}, %{id: 446, caption: "Championship 2017/18"}]

      route "/competitions", Response.ok(competition_list, %{"content-type" => "application/json"})

      competition_response = Enum.to_list(FootballData.list_competitions)

      assert length(competition_response) == 3
    end

    test_with_server "returns a list with the names and ids of all competitions replied by football-data api" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      football_data_response = Exfootball.Support.FootballDataResponses.build(:competitions)

      route "/competitions", football_data_response

      competitions = FootballData.list_competitions

      Enum.each(football_data_response.body, fn(c) ->
        refute is_nil(Map.get(competitions, c[:id]))
        assert c[:caption] == Map.get(competitions, c[:id])
      end)
    end
  end
end
