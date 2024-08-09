import birl.{type Time}
import gleam/list
import gleam/option.{type Option, Some}
import gleam/result

/// Generates an RSS feed as a string from a list of channels
pub fn to_string(channels: List(RssChannel)) -> String {
  let channel_content =
    channels
    |> list.map(fn(channel) { channel |> channel_to_string })
    |> list.reduce(fn(acc, channel_string) { acc <> "\n" <> channel_string })
    |> result.unwrap("")

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0\">"
  <> channel_content
  <> "\n</rss>"
}

fn channel_to_string(channel: RssChannel) -> String {
  let channel_items: String =
    channel.items
    |> list.map(fn(rss_item) { rss_item |> rss_item_to_string })
    |> list.reduce(fn(acc, rss_item_string) { acc <> "\n" <> rss_item_string })
    |> result.unwrap("")

  "\n<channel>\n"
  <> "<title>"
  <> channel.title
  <> "</title>\n"
  <> "<description>"
  <> channel.description
  <> "</description>\n"
  <> "<link>"
  <> channel.link
  <> "</link>\n"
  <> channel_items
  <> "</channel>"
}

fn rss_item_to_string(item: RssItem) -> String {
  "<item>\n"
  <> "<title>"
  <> item.title
  <> "</title>\n"
  <> "<link>"
  <> item.link
  <> "</link>\n"
  <> "<description>"
  <> item.description
  <> "</description>\n"
  <> "<pubDate>"
  <> item.pub_date |> birl.to_iso8601
  <> "</pubDate>\n"
  <> case item.author {
    Some(author) -> "<author>" <> author <> "</author>\n"
    _ -> ""
  }
  <> case item.guid {
    #(guid, Some(is_permalink)) ->
      "<guid isPermaLink=\""
      <> case is_permalink {
        True -> "true"
        False -> "false"
      }
      <> "\">"
      <> guid
      <> "</guid>\n"

    _ -> ""
  }
  <> "</item>"
}

/// A simple RSS channel
pub type RssChannel {
  RssChannel(
    /// The title of the RSS channel
    title: String,
    /// The description of the RSS channel
    description: String,
    /// The link to the top page of the RSS channel
    link: String,
    /// The list of items in the RSS channel
    items: List(RssItem),
  )
}

/// A simple RSS item with optional author
pub type RssItem {
  RssItem(
    /// The title of the RSS item
    title: String,
    /// The link to the page the RSS item is on
    link: String,
    /// The description of the RSS item
    description: String,
    /// The publication date of the RSS item
    pub_date: Time,
    /// An optional author field, note RSS author must be email addresses
    author: Option(String),
    /// A guid and an optional boolean for whether it is a permalink
    guid: #(String, Option(Bool)),
  )
}
