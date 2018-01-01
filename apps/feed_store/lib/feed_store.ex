defmodule FeedStore do
  @moduledoc """
  Documentation for FeedStore.

  ## Examples

      iex> FeedStore.get("url")
      nil

  """
  @time_to_live 3_600_000

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(url) do
    case Agent.get(__MODULE__, fn map -> map[url] end) do
      f = %{feed: _feed, cached_at: cached_at, time_to_live: ttl} ->
        case cache_fresh?(cached_at, ttl) do
          true -> f
          false -> refresh_cache(url)
        end

      nil ->
        refresh_cache(url)
    end

    Agent.get(__MODULE__, fn map -> map[url] end)
  end

  def get_feed(url) do
    %{feed: feed, cached_at: _ca, time_to_live: _ttl} = get(url)
    feed
  end

  def store(url, content) do
    save(url, content)
  end

  def status(url, clock) do
    %{feed: _f, cached_at: ca, time_to_live: ttl} =
      Agent.get(__MODULE__, fn map -> map[url] end)

    case cache_fresh?(ca, ttl, clock) do
      true -> :fresh
      false -> :stale
    end
  end

  defp save(url, %{feed: content, cached_at: ca, time_to_live: ttl}) do
    Agent.update(__MODULE__, fn map ->
      Map.put(map, url, %{feed: content, cached_at: ca, time_to_live: ttl})
    end)
  end

  defp save(url, content) when is_binary(content) do
    save(url, %{
      feed: content,
      time_to_live: @time_to_live,
      cached_at: sys_time()
    })
  end

  defp sys_time() do
    System.system_time(:milli_seconds)
  end

  # time_to_live is in milliseconds
  defp cache_fresh?(cached_at, time_to_live, time \\ sys_time()) do
    time - cached_at < time_to_live
  end

  defp refresh_cache(url) do
    IO.puts("External call to #{url}")

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        save(url, body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason, label: :refresh_error)
    end
  end
end
