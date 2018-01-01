defmodule MesrItWeb.FeedController do
  use MesrItWeb, :controller

  def show(conn, params) do
    IO.inspect params
    uri = "http://csicon.fm/#{params["id"]}/feed?noRedirect=1"
    FeedStore.start_link
    feed = FeedStore.get(uri)
    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, feed.feed)
  end
end
