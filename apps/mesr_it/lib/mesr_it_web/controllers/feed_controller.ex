defmodule MesrItWeb.FeedController do
  use MesrItWeb, :controller

  @feeds ~w(cwj tkl csicon gp wntt thf wian bah mo mmo hw g ggc ww niht tf mnh r
            htc wntttv)

  def show(conn, %{"id" => id} = params)
      when id in @feeds do
    IO.inspect(params)
    uri = "http://csicon.fm/#{params["id"]}/feed?noRedirect=1"
    FeedStore.start_link()
    feed = FeedStore.get(uri)

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, feed.feed)
  end
end
