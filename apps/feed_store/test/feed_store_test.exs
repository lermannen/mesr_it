defmodule FeedStoreTest do
  use ExUnit.Case
  doctest FeedStore

  setup do
    FeedStore.start_link()
    :ok
  end

  test "Starts the agent" do
    assert FeedStore.get("url") == nil
  end

  test "Stores the value in the agent" do
    FeedStore.store("uri", %{
      feed: "feed",
      cached_at: System.system_time(),
      time_to_live: 5000
    })

    assert FeedStore.get_feed("uri") == "feed"
  end

  test "Can store several feeds in the agent" do
    time = System.system_time()

    FeedStore.store("url1", %{feed: "feed1", cached_at: time, time_to_live: 500})

    FeedStore.store("url2", %{feed: "feed2", cached_at: time, time_to_live: 500})

    FeedStore.store("url3", %{feed: "feed3", cached_at: time, time_to_live: 500})

    assert FeedStore.get_feed("url1") == "feed1"
    assert FeedStore.get_feed("url2") == "feed2"
    assert FeedStore.get_feed("url3") == "feed3"
  end

  test "fetches the content from the url" do
    url = "http://feed.mesr.it/mo"

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.get(url)

    assert FeedStore.get_feed(url) == body
  end

  test "it returns the cached data while it's fresh" do
    url = "http://feed.mesr.it/mo"

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.get(url)

    %{feed: ^body, cached_at: cached_at} = FeedStore.get(url)

    assert FeedStore.get(url) == %{
             feed: body,
             cached_at: cached_at,
             time_to_live: 3_600_000
           }
  end

  test "it fetches new data when the cache is stale" do
    url = "http://feed.mesr.it/mo"
    FeedStore.store(url, %{feed: "", cached_at: 0, time_to_live: 600})
    %{feed: body, cached_at: cached_at} = FeedStore.get(url)
    assert body != ""
    assert cached_at > 0
  end

  test "feeds can have individual TTL" do
    time = System.system_time()

    FeedStore.store("feed1", %{feed: "feed1", cached_at: time, time_to_live: 20})

    FeedStore.store("feed2", %{
      feed: "feed2",
      cached_at: time,
      time_to_live: 800
    })

    assert FeedStore.status("feed1", time + 700) == :stale
    assert FeedStore.status("feed2", time + 700) == :fresh
  end
end
