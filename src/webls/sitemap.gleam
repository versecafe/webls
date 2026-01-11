import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/time/calendar
import gleam/time/timestamp.{type Timestamp}

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
