import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/time/calendar
import gleam/time/timestamp.{type Timestamp}
import parsed_it/xml

// Stringify ------------------------------------------------------------------

/// Generates a sitemap.xml string from a sitemap
pub fn to_string(sitemap: Sitemap) -> String {
  let channel_content =
    sitemap.items
    |> list.map(fn(item) { item |> sitemap_item_to_string })
    |> list.reduce(fn(acc, item_string) { acc <> "\n" <> item_string })
    |> result.unwrap("")

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
  <> channel_content
  <> "\n</urlset>"
}

/// Generates a sitemap index XML string from a sitemap index
pub fn index_to_string(index: SitemapIndex) -> String {
  let sitemap_content =
    index.sitemaps
    |> list.map(fn(ref) { ref |> sitemap_reference_to_string })
    |> list.reduce(fn(acc, ref_string) { acc <> "\n" <> ref_string })
    |> result.unwrap("")

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
  <> sitemap_content
  <> "\n</sitemapindex>"
}

fn sitemap_reference_to_string(ref: SitemapReference) -> String {
  "<sitemap>\n"
  <> "<loc>"
  <> ref.loc
  <> "</loc>\n"
  <> case ref.last_modified {
    Some(date) ->
      "<lastmod>"
      <> date |> timestamp.to_rfc3339(calendar.utc_offset)
      <> "</lastmod>\n"
    _ -> ""
  }
  <> "</sitemap>"
}

fn sitemap_item_to_string(item: SitemapItem) -> String {
  "<url>\n"
  <> "<loc>"
  <> item.loc
  <> "</loc>\n"
  <> case item.last_modified {
    Some(date) ->
      "<lastmod>"
      <> date |> timestamp.to_rfc3339(calendar.utc_offset)
      <> "</lastmod>\n"
    _ -> ""
  }
  <> case item.change_frequency {
    Some(freq) ->
      "<changefreq>"
      <> case freq {
        Always -> "always"
        Hourly -> "hourly"
        Daily -> "daily"
        Weekly -> "weekly"
        Monthly -> "monthly"
        Yearly -> "yearly"
        Never -> "never"
      }
      <> "</changefreq>\n"
    _ -> ""
  }
  <> case item.priority {
    Some(priority) ->
      "<priority>"
      <> priority |> float.clamp(0.0, 1.0) |> float.to_string()
      <> "</priority>\n"
    _ -> ""
  }
  <> "</url>"
}

// Builder Patern -------------------------------------------------------------

/// Create a sitemap with a url
pub fn sitemap(url: String) -> Sitemap {
  Sitemap(url: url, last_modified: None, items: [])
}

/// Adds a list of sitemap items to the sitemap
pub fn with_sitemap_items(sitemap: Sitemap, items: List(SitemapItem)) -> Sitemap {
  Sitemap(..sitemap, items: list.flatten([sitemap.items, items]))
}

/// Adds a sitemap item to the sitemap
pub fn with_sitemap_item(sitemap: Sitemap, item: SitemapItem) -> Sitemap {
  Sitemap(..sitemap, items: [item, ..sitemap.items])
}

/// Add a last modified time to the sitemap
pub fn with_sitemap_last_modified(
  sitemap: Sitemap,
  last_modified: Timestamp,
) -> Sitemap {
  Sitemap(..sitemap, last_modified: Some(last_modified))
}

/// Create a base sitemap item with just the URL location
pub fn item(loc: String) -> SitemapItem {
  SitemapItem(
    loc: loc,
    last_modified: None,
    change_frequency: None,
    priority: None,
  )
}

/// Add a change frequency to the sitemap item
pub fn with_item_frequency(
  item: SitemapItem,
  frequency: ChangeFrequency,
) -> SitemapItem {
  SitemapItem(..item, change_frequency: Some(frequency))
}

/// Add a priority to the sitemap item
pub fn with_item_priority(item: SitemapItem, priority: Float) -> SitemapItem {
  SitemapItem(..item, priority: Some(priority))
}

/// Add a last modified time to the sitemap item
pub fn with_item_last_modified(
  item: SitemapItem,
  modified: Timestamp,
) -> SitemapItem {
  SitemapItem(..item, last_modified: Some(modified))
}

/// Create an empty sitemap index
pub fn sitemap_index() -> SitemapIndex {
  SitemapIndex(sitemaps: [])
}

/// Adds a sitemap reference to the sitemap index
pub fn with_index_sitemap(
  index: SitemapIndex,
  ref: SitemapReference,
) -> SitemapIndex {
  SitemapIndex(sitemaps: [ref, ..index.sitemaps])
}

/// Adds a list of sitemap references to the sitemap index
pub fn with_index_sitemaps(
  index: SitemapIndex,
  refs: List(SitemapReference),
) -> SitemapIndex {
  SitemapIndex(sitemaps: list.flatten([index.sitemaps, refs]))
}

/// Create a sitemap reference with a URL location
pub fn reference(loc: String) -> SitemapReference {
  SitemapReference(loc: loc, last_modified: None)
}

/// Add a last modified time to a sitemap reference
pub fn with_reference_last_modified(
  ref: SitemapReference,
  last_modified: Timestamp,
) -> SitemapReference {
  SitemapReference(..ref, last_modified: Some(last_modified))
}

// Types ----------------------------------------------------------------------

/// A complete sitemap
pub type Sitemap {
  Sitemap(
    /// The url location of the sitemap
    url: String,
    /// The time of last modification of the sitemap
    last_modified: Option(Timestamp),
    /// The list of items contained within the sitemap
    items: List(SitemapItem),
  )
}

/// A sitemap index that references multiple sitemaps
pub type SitemapIndex {
  SitemapIndex(
    /// The list of sitemap references
    sitemaps: List(SitemapReference),
  )
}

/// A reference to a sitemap within a sitemap index
pub type SitemapReference {
  SitemapReference(
    /// The location URL of the sitemap
    loc: String,
    /// The time of last modification of the referenced sitemap
    last_modified: Option(Timestamp),
  )
}

/// A item within a sitemap
pub type SitemapItem {
  SitemapItem(
    /// The location/url of the page
    loc: String,
    /// The time of last modification of the page
    last_modified: Option(Timestamp),
    /// How frequently the page is likely to continue to change
    change_frequency: Option(ChangeFrequency),
    /// The priority of the page compared to others within the sitemap
    /// Must be between 0.0 and 1.0
    priority: Option(Float),
  )
}

/// The fequency at which a page tends to change
pub type ChangeFrequency {
  Always
  Hourly
  Daily
  Weekly
  Monthly
  Yearly
  Never
}

// Decoders -------------------------------------------------------------------

/// Result of parsing a sitemap XML - either a regular sitemap or an index
pub type SitemapParseResult {
  ParsedSitemap(Sitemap)
  ParsedSitemapIndex(SitemapIndex)
}

/// Parses a sitemap XML string into a Sitemap
pub fn from_string(sitemap_xml: String) -> Result(Sitemap, xml.XmlDecodeError) {
  xml.parse(from: sitemap_xml, using: sitemap_decoder())
}

/// Parses a sitemap index XML string into a SitemapIndex
pub fn index_from_string(
  sitemap_xml: String,
) -> Result(SitemapIndex, xml.XmlDecodeError) {
  xml.parse(from: sitemap_xml, using: sitemap_index_decoder())
}

/// Parses a sitemap XML string, detecting whether it's a regular sitemap or index
/// Returns a SitemapParseResult indicating which type was parsed
pub fn parse(
  sitemap_xml: String,
) -> Result(SitemapParseResult, xml.XmlDecodeError) {
  // Try parsing as regular sitemap first
  case from_string(sitemap_xml) {
    Ok(sitemap) -> Ok(ParsedSitemap(sitemap))
    Error(_) ->
      // Try parsing as sitemap index
      case index_from_string(sitemap_xml) {
        Ok(index) -> Ok(ParsedSitemapIndex(index))
        Error(e) -> Error(e)
      }
  }
}

fn sitemap_decoder() -> decode.Decoder(Sitemap) {
  // urlset is the root element, url children contain the items
  // When there are multiple <url> elements, they become a list
  // When there's a single <url> element, it's a single object
  use items <- decode.field(
    "url",
    decode.one_of(decode.list(sitemap_item_decoder()), [
      sitemap_item_decoder() |> decode.map(fn(item) { [item] }),
    ]),
  )
  decode.success(Sitemap(url: "", last_modified: None, items:))
}

fn change_frequency_decoder() -> decode.Decoder(ChangeFrequency) {
  use variant <- decode.then(decode.at(["$text"], decode.string))
  case variant {
    "always" -> decode.success(Always)
    "hourly" -> decode.success(Hourly)
    "daily" -> decode.success(Daily)
    "weekly" -> decode.success(Weekly)
    "monthly" -> decode.success(Monthly)
    "yearly" -> decode.success(Yearly)
    "never" -> decode.success(Never)
    _ -> decode.failure(Never, "ChangeFrequency")
  }
}

fn sitemap_item_decoder() -> decode.Decoder(SitemapItem) {
  use loc <- decode.field("loc", decode.at(["$text"], decode.string))
  use last_modified <- decode.optional_field(
    "lastmod",
    None,
    decode.optional(timestamp_decoder()),
  )
  use change_frequency <- decode.optional_field(
    "changefreq",
    None,
    decode.optional(change_frequency_decoder()),
  )
  use priority <- decode.optional_field(
    "priority",
    None,
    decode.optional(decode.at(["$text"], string_float_decoder())),
  )
  decode.success(SitemapItem(loc:, last_modified:, change_frequency:, priority:))
}

fn string_float_decoder() -> decode.Decoder(Float) {
  use str <- decode.then(decode.string)
  case float.parse(str) {
    Ok(f) -> decode.success(f)
    Error(_) ->
      // Try parsing as int and convert to float
      case int.parse(str) {
        Ok(i) -> decode.success(int.to_float(i))
        Error(_) -> decode.failure(0.0, "Float")
      }
  }
}

fn timestamp_decoder() -> decode.Decoder(Timestamp) {
  use date_str <- decode.then(decode.at(["$text"], decode.string))
  case timestamp.parse_rfc3339(date_str) {
    Ok(ts) -> decode.success(ts)
    Error(_) -> decode.failure(timestamp.from_unix_seconds(0), "Timestamp")
  }
}

fn sitemap_index_decoder() -> decode.Decoder(SitemapIndex) {
  // sitemapindex is the root element, sitemap children contain the references
  use sitemaps <- decode.field(
    "sitemap",
    decode.one_of(decode.list(sitemap_reference_decoder()), [
      sitemap_reference_decoder() |> decode.map(fn(ref) { [ref] }),
    ]),
  )
  decode.success(SitemapIndex(sitemaps:))
}

fn sitemap_reference_decoder() -> decode.Decoder(SitemapReference) {
  use loc <- decode.field("loc", decode.at(["$text"], decode.string))
  use last_modified <- decode.optional_field(
    "lastmod",
    None,
    decode.optional(timestamp_decoder()),
  )
  decode.success(SitemapReference(loc:, last_modified:))
}
