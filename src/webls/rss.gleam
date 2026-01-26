import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp.{type Timestamp}
import parsed_it/xml

// Stringify ------------------------------------------------------------------

/// Converts a list of RSS channels to a string of a valid RSS 2.0.1 feed
pub fn to_string(channels: List(RssChannel)) -> String {
  let channel_content =
    channels
    |> list.map(fn(channel) { channel |> rss_channel_to_string })
    |> list.reduce(fn(acc, channel_string) { acc <> "\n" <> channel_string })
    |> result.unwrap("")

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0.1\">"
  <> channel_content
  <> "\n</rss>"
}

fn rss_channel_to_string(channel: RssChannel) -> String {
  let channel_items: String =
    channel.items
    |> list.map(fn(rss_item) { rss_item |> rss_item_to_string })
    |> list.reduce(fn(acc, rss_item_string) { acc <> "\n" <> rss_item_string })
    |> result.unwrap("")

  "\n<channel>\n"
  <> "<title>"
  <> channel.title
  <> "</title>\n"
  <> "<link>"
  <> channel.link
  <> "</link>\n"
  <> "<description>"
  <> channel.description
  <> "</description>\n"
  <> case channel.language {
    Some(language) -> "<language>" <> language <> "</language>\n"
    _ -> ""
  }
  <> case channel.copyright {
    Some(copyright) -> "<copyright>" <> copyright <> "</copyright>\n"
    _ -> ""
  }
  <> case channel.managing_editor {
    Some(managing_editor) ->
      "<managingEditor>" <> managing_editor <> "</managingEditor>\n"
    _ -> ""
  }
  <> case channel.web_master {
    Some(web_master) -> "<webMaster>" <> web_master <> "</webMaster>\n"
    _ -> ""
  }
  <> case channel.pub_date {
    Some(pub_date) ->
      "<pubDate>"
      <> pub_date |> timestamp.to_rfc3339(calendar.utc_offset)
      <> "</pubDate>\n"
    _ -> ""
  }
  <> case channel.last_build_date {
    Some(last_build_date) ->
      "<lastBuildDate>"
      <> last_build_date |> timestamp.to_rfc3339(calendar.utc_offset)
      <> "</lastBuildDate>\n"
    _ -> ""
  }
  <> channel.categories
  |> list.map(fn(category) { "<category>" <> category <> "</category>\n" })
  |> list.reduce(fn(acc, category) { acc <> category })
  |> result.unwrap("")
  <> case channel.generator {
    Some(generator) -> "<generator>" <> generator <> "</generator>\n"
    _ -> ""
  }
  <> case channel.docs {
    Some(docs) -> "<docs>" <> docs <> "</docs>\n"
    _ -> ""
  }
  <> case channel.cloud {
    Some(cloud) ->
      "<cloud domain=\""
      <> cloud.domain
      <> "\" port=\""
      <> int.to_string(cloud.port)
      <> "\" path=\""
      <> cloud.path
      <> "\" registerProcedure=\""
      <> cloud.register_procedure
      <> "\" protocol=\""
      <> cloud.protocol
      <> "\"/>\n"
    _ -> ""
  }
  <> case channel.ttl {
    Some(ttl) -> "<ttl>" <> int.to_string(ttl) <> "</ttl>\n"
    _ -> ""
  }
  <> case channel.image {
    Some(image) ->
      "<image>"
      <> "<url>"
      <> image.url
      <> "</url>\n"
      <> "<title>"
      <> image.title
      <> "</title>\n"
      <> "<link>"
      <> image.link
      <> "</link>\n"
      <> case image.description {
        Some(description) ->
          "<description>" <> description <> "</description>\n"
        _ -> ""
      }
      <> case image.width {
        Some(width) -> "<width>" <> int.to_string(width) <> "</width>\n"
        _ -> ""
      }
      <> case image.height {
        Some(height) -> "<height>" <> int.to_string(height) <> "</height>\n"
        _ -> ""
      }
      <> "</image>\n"
    _ -> ""
  }
  <> case channel.text_input {
    Some(text_input) ->
      "<textInput>"
      <> "<title>"
      <> text_input.title
      <> "</title>\n"
      <> "<description>"
      <> text_input.description
      <> "</description>\n"
      <> "<name>"
      <> text_input.name
      <> "</name>\n"
      <> "<link>"
      <> text_input.link
      <> "</link>\n"
      <> "</textInput>\n"
    _ -> ""
  }
  <> case channel.skip_hours |> list.length > 0 {
    True -> {
      "<skipHours>"
      <> list.map(channel.skip_hours, fn(hour) {
        "<hour>" <> int.to_string(hour) <> "</hour>"
      })
      |> list.reduce(fn(acc, hour) { acc <> "\n" <> hour })
      |> result.unwrap("")
      <> "</skipHours>\n"
    }
    _ -> ""
  }
  <> case channel.skip_days |> list.length > 0 {
    True -> {
      "<skipDays>"
      <> list.map(channel.skip_days, fn(day) {
        "<day>" <> day |> weekday_to_string <> "</day>"
      })
      |> list.reduce(fn(acc, day) { acc <> "\n" <> day })
      |> result.unwrap("")
      <> "</skipDays>\n"
    }
    _ -> ""
  }
  <> channel_items
  <> "</channel>"
}

fn rss_item_to_string(item: RssItem) -> String {
  "<item>\n"
  <> "<title>"
  <> item.title
  <> "</title>\n"
  <> "<description>"
  <> item.description
  <> "</description>\n"
  <> case item.link {
    Some(link) -> "<link>" <> link <> "</link>\n"
    _ -> ""
  }
  <> case item.author {
    Some(author) -> "<author>" <> author <> "</author>\n"
    _ -> ""
  }
  <> case item.comments {
    Some(comments) -> "<comments>" <> comments <> "</comments>\n"
    _ -> ""
  }
  <> case item.source {
    Some(source) -> "<source>" <> source <> "</source>\n"
    _ -> ""
  }
  <> case item.pub_date {
    Some(pub_date) ->
      "<pubDate>"
      <> pub_date |> timestamp.to_rfc3339(calendar.utc_offset)
      <> "</pubDate>\n"
    _ -> ""
  }
  <> item.categories
  |> list.map(fn(category) { "<category>" <> category <> "</category>\n" })
  |> list.reduce(fn(acc, category) { acc <> category })
  |> result.unwrap("")
  <> case item.enclosure {
    Some(enclosure) ->
      "<enclosure url=\""
      <> enclosure.url
      <> "\" length=\""
      <> int.to_string(enclosure.length)
      <> "\" type=\""
      <> enclosure.enclosure_type
      <> "\"/>\n"
    _ -> ""
  }
  <> case item.guid {
    Some(guid) ->
      case guid {
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
    _ -> ""
  }
  <> "</item>"
}

fn weekday_to_string(weekday: Weekday) -> String {
  case weekday {
    Monday -> "Monday"
    Tuesday -> "Tuesday"
    Wednesday -> "Wednesday"
    Thursday -> "Thursday"
    Friday -> "Friday"
    Saturday -> "Saturday"
    Sunday -> "Sunday"
  }
}

// Builder Pattern -------------------------------------------------------------

/// Creates a base RSS channel
pub fn channel(title: String, description: String, link: String) -> RssChannel {
  RssChannel(
    title: title,
    description: description,
    link: link,
    language: None,
    copyright: None,
    managing_editor: None,
    web_master: None,
    pub_date: None,
    last_build_date: None,
    categories: [],
    generator: None,
    docs: None,
    cloud: None,
    ttl: None,
    image: None,
    text_input: None,
    skip_hours: [],
    skip_days: [],
    items: [],
  )
}

/// Sets the language of the RSS channel example: "en-us"
pub fn with_channel_language(
  channel: RssChannel,
  language: String,
) -> RssChannel {
  RssChannel(..channel, language: Some(language))
}

/// Sets the copyright information for the RSS channel
pub fn with_channel_copyright(
  channel: RssChannel,
  copyright: String,
) -> RssChannel {
  RssChannel(..channel, copyright: Some(copyright))
}

/// Sets the managing editor's email address for the RSS channel
pub fn with_channel_managing_editor(
  channel: RssChannel,
  managing_editor: String,
) -> RssChannel {
  RssChannel(..channel, managing_editor: Some(managing_editor))
}

/// Sets the web master's email address for the RSS channel
pub fn with_channel_web_master(
  channel: RssChannel,
  web_master: String,
) -> RssChannel {
  RssChannel(..channel, web_master: Some(web_master))
}

/// Sets the publication date of the RSS channel
pub fn with_channel_pub_date(
  channel: RssChannel,
  pub_date: Timestamp,
) -> RssChannel {
  RssChannel(..channel, pub_date: Some(pub_date))
}

/// Sets the last build date of the RSS channel
pub fn with_channel_last_build_date(
  channel: RssChannel,
  last_build_date: Timestamp,
) -> RssChannel {
  RssChannel(..channel, last_build_date: Some(last_build_date))
}

/// Adds a category to the RSS channel
pub fn with_channel_category(
  channel: RssChannel,
  category: String,
) -> RssChannel {
  RssChannel(..channel, categories: [category, ..channel.categories])
}

/// Adds a list of categories to the RSS channel
pub fn with_channel_categories(
  channel: RssChannel,
  categories: List(String),
) -> RssChannel {
  RssChannel(
    ..channel,
    categories: list.flatten([channel.categories, categories]),
  )
}

/// Sets the generator element for the RSS channel with a custom string
pub fn with_channel_custom_generator(
  channel: RssChannel,
  generator: String,
) -> RssChannel {
  RssChannel(..channel, generator: Some(generator))
}

/// Sets the generator element for the RSS channel to webls
pub fn with_channel_generator(channel: RssChannel) -> RssChannel {
  with_channel_custom_generator(channel, "webls")
}

/// Adds the RSS 2.0.1 spec documentation link to the RSS channel
pub fn with_channel_docs(channel: RssChannel) -> RssChannel {
  RssChannel(..channel, docs: Some("https://www.rssboard.org/rss-2-0-1"))
}

/// Sets the cloud element for the RSS channel with a domain, port, path,
/// register procedure, and protocol
pub fn with_channel_cloud(channel: RssChannel, cloud: Cloud) -> RssChannel {
  RssChannel(..channel, cloud: Some(cloud))
}

/// Sets the time-to-live (TTL) for the RSS channel in minutes
pub fn with_channel_ttl(channel: RssChannel, ttl: Int) -> RssChannel {
  RssChannel(..channel, ttl: Some(ttl))
}

/// Sets an optional image associated with the RSS channel
pub fn with_channel_image(channel: RssChannel, image: Image) -> RssChannel {
  RssChannel(..channel, image: Some(image))
}

/// Sets an optional text input for the RSS channel
pub fn with_channel_text_input(
  channel: RssChannel,
  text_input: TextInput,
) -> RssChannel {
  RssChannel(..channel, text_input: Some(text_input))
}

/// Sets a list of hours in GMT which content aggregation should be skipped
pub fn with_channel_skip_hours(
  channel: RssChannel,
  skip_hours: List(Int),
) -> RssChannel {
  RssChannel(..channel, skip_hours: skip_hours)
}

/// Sets a list of days to skip in the RSS channel
pub fn with_channel_skip_days(
  channel: RssChannel,
  skip_days: List(Weekday),
) -> RssChannel {
  RssChannel(..channel, skip_days: skip_days)
}

/// Adds a list of items in the RSS channel
pub fn with_channel_items(
  channel: RssChannel,
  items: List(RssItem),
) -> RssChannel {
  RssChannel(..channel, items: list.flatten([channel.items, items]))
}

/// Adds a RSS item to the RSS channel
pub fn with_channel_item(channel: RssChannel, item: RssItem) -> RssChannel {
  RssChannel(..channel, items: [item, ..channel.items])
}

/// Creates a base RSS item
pub fn item(title: String, description: String) -> RssItem {
  RssItem(
    title: title,
    description: description,
    link: None,
    author: None,
    categories: [],
    comments: None,
    enclosure: None,
    guid: None,
    pub_date: None,
    source: None,
  )
}

/// Sets the link to the page or source of the RSS item
pub fn with_item_link(item: RssItem, link: String) -> RssItem {
  RssItem(..item, link: Some(link))
}

/// Sets an optional author field, note RSS author must be email addresses
pub fn with_item_author(item: RssItem, author: String) -> RssItem {
  RssItem(..item, author: Some(author))
}

/// Sets a list of categories for the RSS item
pub fn with_item_categories(item: RssItem, categories: List(String)) -> RssItem {
  RssItem(..item, categories: categories)
}

/// Sets a URL to the comments section for the RSS item
pub fn with_item_comments(item: RssItem, comments: String) -> RssItem {
  RssItem(..item, comments: Some(comments))
}

/// Sets an optional enclosure (media resource) for the RSS item
pub fn with_item_enclosure(item: RssItem, enclosure: Enclosure) -> RssItem {
  RssItem(..item, enclosure: Some(enclosure))
}

/// Sets the guid of the RSS item with an optional boolean for whether it is a permalink
pub fn with_item_guid(item: RssItem, guid: #(String, Option(Bool))) -> RssItem {
  RssItem(..item, guid: Some(guid))
}

/// Sets the publication date of the RSS item
pub fn with_item_pub_date(item: RssItem, pub_date: Timestamp) -> RssItem {
  RssItem(..item, pub_date: Some(pub_date))
}

/// Sets the RSS channel the item came from
pub fn with_item_source(item: RssItem, source: String) -> RssItem {
  RssItem(..item, source: Some(source))
}

// Types ----------------------------------------------------------------------

/// RSS 2.0.1 spec compliant channel
pub type RssChannel {
  RssChannel(
    /// The title of the RSS channel
    title: String,
    /// The link to the top page of the RSS channel
    link: String,
    /// The description of the RSS channel
    description: String,
    /// The language of the RSS channel
    language: Option(String),
    /// The copyright information for the RSS channel
    copyright: Option(String),
    /// The managing editor's email address
    managing_editor: Option(String),
    /// The web master’s email address
    web_master: Option(String),
    /// The publication date of the RSS channel
    pub_date: Option(Timestamp),
    /// The last build date of the RSS channel
    last_build_date: Option(Timestamp),
    /// A list of categories for the RSS channel
    categories: List(String),
    /// The generator program of the RSS channel, feel free to shout webls out!
    generator: Option(String),
    /// A link to the documentation for the RSS spec
    docs: Option(String),
    /// Cloud configuration for the RSS channel
    cloud: Option(Cloud),
    /// The time-to-live (TTL) for the RSS channel
    ttl: Option(Int),
    /// An optional image associated with the RSS channel
    image: Option(Image),
    /// An optional text input for the RSS channel
    text_input: Option(TextInput),
    /// A list of hours in GMT which content aggregation should be skipped
    skip_hours: List(Int),
    /// A list of days to skip in the RSS channel
    skip_days: List(Weekday),
    /// A list of items in the RSS channel
    items: List(RssItem),
  )
}

/// An image associated with a RSS channel
pub type Image {
  Image(
    /// The URL of the image
    url: String,
    /// The title of the image
    title: String,
    /// The link associated with the image
    link: String,
    /// An optional description of the image
    description: Option(String),
    /// An optional width of the image in pixels
    width: Option(Int),
    /// An optional height of the image in pixels
    height: Option(Int),
  )
}

/// Cloud configuration for an RSS channel
pub type Cloud {
  Cloud(
    /// The domain of the cloud service
    domain: String,
    /// The port for the cloud service
    port: Int,
    /// The path for the cloud service
    path: String,
    /// The registration procedure for the cloud service (usually "http-post" or "xml-rpc")
    register_procedure: String,
    /// The protocol used for the cloud service
    protocol: String,
  )
}

/// A text input field for an RSS channel
pub type TextInput {
  TextInput(
    /// The title of the text input field
    title: String,
    /// A description of the text input field's purpose
    description: String,
    /// The name attribute for the text input field
    name: String,
    /// The link associated with the text input field
    link: String,
  )
}

/// An enclosure resource for an RSS item
pub type Enclosure {
  Enclosure(
    /// The URL of the enclosure resource
    url: String,
    /// The length of the enclosure in bytes
    length: Int,
    /// The type of the enclosure (e.g., audio/mpeg, video/mp4)
    enclosure_type: String,
  )
}

/// RSS 2.0.1 spec compliant item
pub type RssItem {
  RssItem(
    /// The title of the RSS item
    title: String,
    /// The description of the RSS item
    description: String,
    /// The link to the page or source of the RSS item
    link: Option(String),
    /// An optional author field, note RSS author must be email addresses
    author: Option(String),
    /// A URL to the comments section for the RSS item
    comments: Option(String),
    /// The RSS channel the item came from
    source: Option(String),
    /// The publication date of the RSS item
    pub_date: Option(Timestamp),
    /// A list of categories for the RSS item
    categories: List(String),
    /// An optional enclosure resource for the RSS item
    enclosure: Option(Enclosure),
    /// A guid and an optional boolean for whether it is a permalink
    guid: Option(#(String, Option(Bool))),
  )
}

pub type Weekday {
  Monday
  Tuesday
  Wednesday
  Thursday
  Friday
  Saturday
  Sunday
}

// Decoders -------------------------------------------------------------------

/// Parses an RSS XML string into a list of RssChannels
pub fn from_string(
  rss_xml: String,
) -> Result(List(RssChannel), xml.XmlDecodeError) {
  xml.parse(from: rss_xml, using: rss_decoder())
}

fn rss_decoder() -> decode.Decoder(List(RssChannel)) {
  // rss -> channel (single or list)
  use channels <- decode.field(
    "channel",
    decode.one_of(decode.list(channel_decoder()), [
      channel_decoder() |> decode.map(fn(ch) { [ch] }),
    ]),
  )
  decode.success(channels)
}

fn channel_decoder() -> decode.Decoder(RssChannel) {
  use title <- decode.field("title", text_decoder())
  use link <- decode.field("link", text_decoder())
  use description <- decode.field("description", text_decoder())
  use language <- decode.optional_field(
    "language",
    None,
    decode.optional(text_decoder()),
  )
  use copyright <- decode.optional_field(
    "copyright",
    None,
    decode.optional(text_decoder()),
  )
  use managing_editor <- decode.optional_field(
    "managingEditor",
    None,
    decode.optional(text_decoder()),
  )
  use web_master <- decode.optional_field(
    "webMaster",
    None,
    decode.optional(text_decoder()),
  )
  use pub_date <- decode.optional_field(
    "pubDate",
    None,
    decode.optional(timestamp_decoder()),
  )
  use last_build_date <- decode.optional_field(
    "lastBuildDate",
    None,
    decode.optional(timestamp_decoder()),
  )
  use categories <- decode.optional_field("category", [], categories_decoder())
  use generator <- decode.optional_field(
    "generator",
    None,
    decode.optional(text_decoder()),
  )
  use docs <- decode.optional_field(
    "docs",
    None,
    decode.optional(text_decoder()),
  )
  use cloud <- decode.optional_field(
    "cloud",
    None,
    decode.optional(cloud_decoder()),
  )
  use ttl <- decode.optional_field(
    "ttl",
    None,
    decode.optional(int_text_decoder()),
  )
  use image <- decode.optional_field(
    "image",
    None,
    decode.optional(image_decoder()),
  )
  use text_input <- decode.optional_field(
    "textInput",
    None,
    decode.optional(text_input_decoder()),
  )
  use skip_hours <- decode.optional_field("skipHours", [], skip_hours_decoder())
  use skip_days <- decode.optional_field("skipDays", [], skip_days_decoder())
  use items <- decode.optional_field(
    "item",
    [],
    decode.one_of(decode.list(item_decoder()), [
      item_decoder() |> decode.map(fn(item) { [item] }),
    ]),
  )
  decode.success(RssChannel(
    title:,
    link:,
    description:,
    language:,
    copyright:,
    managing_editor:,
    web_master:,
    pub_date:,
    last_build_date:,
    categories:,
    generator:,
    docs:,
    cloud:,
    ttl:,
    image:,
    text_input:,
    skip_hours:,
    skip_days:,
    items:,
  ))
}

fn item_decoder() -> decode.Decoder(RssItem) {
  use title <- decode.field("title", text_decoder())
  use description <- decode.field("description", text_decoder())
  use link <- decode.optional_field(
    "link",
    None,
    decode.optional(text_decoder()),
  )
  use author <- decode.optional_field(
    "author",
    None,
    decode.optional(text_decoder()),
  )
  use comments <- decode.optional_field(
    "comments",
    None,
    decode.optional(text_decoder()),
  )
  use source <- decode.optional_field(
    "source",
    None,
    decode.optional(text_decoder()),
  )
  use pub_date <- decode.optional_field(
    "pubDate",
    None,
    decode.optional(timestamp_decoder()),
  )
  use categories <- decode.optional_field("category", [], categories_decoder())
  use enclosure <- decode.optional_field(
    "enclosure",
    None,
    decode.optional(enclosure_decoder()),
  )
  use guid <- decode.optional_field(
    "guid",
    None,
    decode.optional(guid_decoder()),
  )
  decode.success(RssItem(
    title:,
    description:,
    link:,
    author:,
    comments:,
    source:,
    pub_date:,
    categories:,
    enclosure:,
    guid:,
  ))
}

fn text_decoder() -> decode.Decoder(String) {
  decode.at(["$text"], decode.string)
}

fn int_text_decoder() -> decode.Decoder(Int) {
  use str <- decode.then(text_decoder())
  case int.parse(str) {
    Ok(i) -> decode.success(i)
    Error(_) -> decode.failure(0, "Int")
  }
}

fn timestamp_decoder() -> decode.Decoder(Timestamp) {
  use date_str <- decode.then(text_decoder())
  case timestamp.parse_rfc3339(date_str) {
    Ok(ts) -> decode.success(ts)
    Error(_) -> decode.failure(timestamp.from_unix_seconds(0), "Timestamp")
  }
}

fn categories_decoder() -> decode.Decoder(List(String)) {
  decode.one_of(decode.list(text_decoder()), [
    text_decoder() |> decode.map(fn(cat) { [cat] }),
  ])
}

fn cloud_decoder() -> decode.Decoder(Cloud) {
  // Cloud element uses attributes: domain, port, path, registerProcedure, protocol
  use domain <- decode.field("$attrs", decode.at(["domain"], decode.string))
  use port <- decode.field("$attrs", decode.at(["port"], string_int_decoder()))
  use path <- decode.field("$attrs", decode.at(["path"], decode.string))
  use register_procedure <- decode.field(
    "$attrs",
    decode.at(["registerProcedure"], decode.string),
  )
  use protocol <- decode.field("$attrs", decode.at(["protocol"], decode.string))
  decode.success(Cloud(domain:, port:, path:, register_procedure:, protocol:))
}

fn string_int_decoder() -> decode.Decoder(Int) {
  use str <- decode.then(decode.string)
  case int.parse(str) {
    Ok(i) -> decode.success(i)
    Error(_) -> decode.failure(0, "Int")
  }
}

fn image_decoder() -> decode.Decoder(Image) {
  use url <- decode.field("url", text_decoder())
  use title <- decode.field("title", text_decoder())
  use link <- decode.field("link", text_decoder())
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(text_decoder()),
  )
  use width <- decode.optional_field(
    "width",
    None,
    decode.optional(int_text_decoder()),
  )
  use height <- decode.optional_field(
    "height",
    None,
    decode.optional(int_text_decoder()),
  )
  decode.success(Image(url:, title:, link:, description:, width:, height:))
}

fn text_input_decoder() -> decode.Decoder(TextInput) {
  use title <- decode.field("title", text_decoder())
  use description <- decode.field("description", text_decoder())
  use name <- decode.field("name", text_decoder())
  use link <- decode.field("link", text_decoder())
  decode.success(TextInput(title:, description:, name:, link:))
}

fn enclosure_decoder() -> decode.Decoder(Enclosure) {
  // Enclosure element uses attributes: url, length, type
  use url <- decode.field("$attrs", decode.at(["url"], decode.string))
  use length <- decode.field(
    "$attrs",
    decode.at(["length"], string_int_decoder()),
  )
  use enclosure_type <- decode.field(
    "$attrs",
    decode.at(["type"], decode.string),
  )
  decode.success(Enclosure(url:, length:, enclosure_type:))
}

fn guid_decoder() -> decode.Decoder(#(String, Option(Bool))) {
  use guid_text <- decode.field("$text", decode.string)
  use is_permalink <- decode.optional_field(
    "$attrs",
    None,
    decode.optional(decode.at(["isPermaLink"], bool_string_decoder())),
  )
  decode.success(#(guid_text, is_permalink))
}

fn bool_string_decoder() -> decode.Decoder(Bool) {
  use s <- decode.then(decode.string)
  case string.lowercase(s) {
    "true" -> decode.success(True)
    "false" -> decode.success(False)
    _ -> decode.failure(False, "Bool")
  }
}

fn skip_hours_decoder() -> decode.Decoder(List(Int)) {
  use hours <- decode.optional_field(
    "hour",
    [],
    decode.one_of(decode.list(int_text_decoder()), [
      int_text_decoder() |> decode.map(fn(h) { [h] }),
    ]),
  )
  decode.success(hours)
}

fn skip_days_decoder() -> decode.Decoder(List(Weekday)) {
  use days <- decode.optional_field(
    "day",
    [],
    decode.one_of(decode.list(weekday_decoder()), [
      weekday_decoder() |> decode.map(fn(d) { [d] }),
    ]),
  )
  decode.success(days)
}

fn weekday_decoder() -> decode.Decoder(Weekday) {
  use day_str <- decode.then(text_decoder())
  case string.lowercase(day_str) {
    "monday" -> decode.success(Monday)
    "tuesday" -> decode.success(Tuesday)
    "wednesday" -> decode.success(Wednesday)
    "thursday" -> decode.success(Thursday)
    "friday" -> decode.success(Friday)
    "saturday" -> decode.success(Saturday)
    "sunday" -> decode.success(Sunday)
    _ -> decode.failure(Monday, "Weekday")
  }
}
