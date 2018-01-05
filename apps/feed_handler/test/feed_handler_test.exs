defmodule FeedHandlerTest do
  use ExUnit.Case
  doctest FeedHandler

  test "greets the world" do
    assert FeedHandler.hello() == :world
  end
end
