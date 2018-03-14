defmodule Exfootball.External.FootballDataTest do
  use ExUnit.Case
  import FakeServer

  alias Exfootball.External.FootballData
  alias FakeServer.HTTP.Response

  @error_base_string "A request to football-data api returned an invalid status:"
  @cache_key :exfootball_cache
  @competition_id 444

  setup do
    Cachex.clear(@cache_key)
    :ok
  end

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

    test_with_server "makes the request once and then caches the competitions list" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions", Exfootball.Support.FootballDataResponses.build(:competitions)

      assert FakeServer.hits == 0
      competitions = FootballData.list_competitions
      assert FakeServer.hits == 1

      cached_competitions = FootballData.list_competitions
      assert cached_competitions == competitions
      assert FakeServer.hits == 1
    end
  end

  describe "#list_teams" do
    test_with_server "raises if football-data api returns 4XX" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions/#{@competition_id}/teams", Response.all_4xx

      Enum.each(Response.all_4xx, fn(%{code: status_code}) ->
        assert_raise RuntimeError, "#{@error_base_string} #{status_code}", fn ->
          FootballData.list_teams(@competition_id)
        end
      end)
    end

    test_with_server "raises if football-data api returns 5XX" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions/#{@competition_id}/teams", Response.all_5xx

      Enum.each(Response.all_5xx, fn(%{code: status_code}) ->
        assert_raise RuntimeError, "#{@error_base_string} #{status_code}", fn ->
          FootballData.list_teams(@competition_id)
        end
      end)
    end

    test_with_server "raises Tesla.Error when request timeout" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions/#{@competition_id}/teams", fn(_) ->
        timeout = Application.get_env(:exfootball, :football_data_api_timeout) + 20
        :timer.sleep(timeout)
      end

      assert_raise Tesla.Error, fn -> FootballData.list_teams(@competition_id) end
    end

    test_with_server "returns an empty list if competition has no teams" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions/#{@competition_id}/teams", Exfootball.Support.FootballDataResponses.build(:competition_teams, teams: [])

      assert FootballData.list_teams(@competition_id) == []
    end

    test_with_server "returns an empty list if football-data-api returns without 'teams' key" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      route "/competitions/#{@competition_id}/teams", Exfootball.Support.FootballDataResponses.build(:competition_teams, teams: nil)

      assert FootballData.list_teams(@competition_id) == []
    end

    test_with_server "returns a list containing all teams of a given competition" do
      Application.put_env(:exfootball, :football_data_api_url, "#{FakeServer.http_address}")

      %{body: %{teams: team_list}} = football_data_teams = Exfootball.Support.FootballDataResponses.build(:competition_teams)

      route "/competitions/#{@competition_id}/teams", football_data_teams

      teams = FootballData.list_teams(@competition_id)

      Enum.each(team_list, fn(team) ->
        assert Enum.member?(teams, team.name)
      end)
    end
  end
end
