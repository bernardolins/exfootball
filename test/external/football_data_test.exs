defmodule Exfootball.External.FootballDataTest do
  use ExUnit.Case
  import FakeServer

  alias Exfootball.External.FootballData
  alias FakeServer.HTTP.Response

  describe "#list_competitions" do
    test_with_server "raises if football-data api returns 4XX" do
      Application.put_env(:exfootball, :football_data_api_url, "http://#{FakeServer.address}")

      response_list = [
        Response.bad_request,
        Response.unauthorized,
        Response.forbidden,
        Response.not_found,
        Response.method_not_allowed,
        Response.not_acceptable
      ]

      route "/competitions", response_list

      Enum.each(1..length(response_list), fn(_) ->
        assert_raise RuntimeError, fn ->
          FootballData.list_competitions
        end
      end)
    end

    test_with_server "raises if football-data api returns 5XX" do
      Application.put_env(:exfootball, :football_data_api_url, "http://#{FakeServer.address}")

      response_list = [
        Response.internal_server_error,
        Response.not_implemented,
        Response.bad_gateway,
        Response.service_unavailable,
        Response.gateway_timeout,
        Response.http_version_not_supported
      ]

      route "/competitions", response_list

      Enum.each(1..length(response_list), fn(_) ->
        assert_raise RuntimeError, fn ->
          FootballData.list_competitions
        end
      end)
    end

    test_with_server "raises Tesla.Error when request timeout" do
      Application.put_env(:exfootball, :football_data_api_url, "http://#{FakeServer.address}")

      route "/competitions", fn(_) -> :timer.sleep(350) end

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
