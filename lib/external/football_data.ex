defmodule Exfootball.External.FootballData do
  use Tesla

  plug Tesla.Middleware.BaseUrl, Application.get_env(:exfootball, :football_data_api_url)
  plug Tesla.Middleware.Timeout, timeout: Application.get_env(:exfootball, :football_data_api_timeout)
  plug Tesla.Middleware.JSON

  adapter Tesla.Adapter.Hackney

  @cache_key :exfootball_cache
  @cache_ttl :timer.hours(24)

  def list_competitions do
    cache_bucket = "competitions"
    case Cachex.get(@cache_key, cache_bucket) do
      {:ok, nil} ->
        get("/competitions")
        |> handle_errors
        |> Enum.map(fn(competition) ->
          {competition["id"], competition["caption"]}
        end)
        |> Enum.into(%{})
        |> store_on_cache(cache_bucket)
      {:ok, competition_list} ->
        competition_list
    end
  end

  def list_teams(competition_id) do
    get("/competitions/#{competition_id}/teams")
    |> handle_errors
    |> Map.get("teams")
    |> Enum.map(fn(team) ->
      team["name"]
    end)
  end

  def league_table(competition_id, matchday \\ 1) do
    get("/competitions/#{competition_id}/leagueTable?matchday=#{matchday}")
    |> handle_errors
    |> Map.get("standing")
    |> Enum.map(fn(team) ->
      {team["position"], team["teamName"]}
    end)
    |> Enum.into(%{})
  end

  defp handle_errors(%Tesla.Env{status: 200, body: body}), do: body
  defp handle_errors(%Tesla.Env{status: status}), do: raise "A request to football-data api returned an invalid status: #{status}"

  defp store_on_cache(value, cache_bucket) do
    Cachex.set(@cache_key, cache_bucket, value, [ttl: @cache_ttl])
    value
  end
end
