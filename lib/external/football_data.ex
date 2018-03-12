defmodule Exfootball.External.FootballData do
  use Tesla

  plug Tesla.Middleware.BaseUrl, Application.get_env(:exfootball, :football_data_api_url)
  plug Tesla.Middleware.Timeout, timeout: Application.get_env(:exfootball, :football_data_api_timeout)
  plug Tesla.Middleware.JSON

  adapter Tesla.Adapter.Hackney

  def list_competitions do
    get("/competitions")
    |> handle_errors
    |> Enum.map(fn(competition) ->
      {competition["id"], competition["caption"]}
    end)
    |> Enum.into(%{})
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
end
