defmodule AliyunOpenApiSdk do
  @moduledoc """
  Documentation for `AliyunOpenApiSdk`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AliyunOpenApiSdk.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Convert map atom keys to strings
  """
  def stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {stringify_key(k), v} end)
    |> Enum.into(%{})
  end

  defp stringify_key(key) when is_atom(key), do: Atom.to_string(key)
  defp stringify_key(key), do: key

  def check_changeset(enemy, params \\ %{}, api_action, init_data, method) do
    case enemy.valid? do
      true ->
        {:ok,
         %{
           method: method,
           body: bingo_changeset(params, api_action, init_data)
         }}

      false ->
        {:error, %{:error => enemy.errors}}
    end
  end

  def bingo_changeset(params, api_action, init_data) do
    params
    |> Map.put(:Action, api_action)
    |> Map.merge(init_data)
    |> stringify_keys
  end
end
