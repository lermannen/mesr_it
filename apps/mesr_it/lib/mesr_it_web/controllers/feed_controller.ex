defmodule MesrItWeb.FeedController do
  use MesrItWeb, :controller

  @feeds ~w(cwj tkl csicon gp wntt thf wian bah mo mmo hw g ggc ww niht tf mnh r
            htc wntttv)

  def show(conn, %{"id" => id} = params) when id in @feeds do
    uri = "http://csicon.fm/#{params["id"]}/feed?noRedirect=1"
    feed = FeedStore.get(uri)

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, feed.feed)
  end

  def show(conn, _params) do
    conn
    |> put_status(:not_found)
    |> put_view(MesrItWeb.ErrorView)
    |> render("404.html")
  end
end
