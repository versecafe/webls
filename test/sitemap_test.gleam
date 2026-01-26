import gleam/option.{None, Some}
import gleam/time/calendar
import gleam/time/timestamp
import gleeunit/should
import simplifile
import webls/sitemap

/// Confirms that the sitemap correctly stringifies against a snapshot
pub fn sitemap_to_string_test() -> Nil {
  let sitemap =
    sitemap.sitemap("https://gleam.run/sitemap.xml")
    |> sitemap.with_sitemap_items([
      sitemap.item("https://gleam.run")
        |> sitemap.with_item_frequency(sitemap.Monthly)
        |> sitemap.with_item_priority(1.0),
      sitemap.item("https://gleam.run/blog")
        |> sitemap.with_item_frequency(sitemap.Weekly),
      sitemap.item("https://gleam.run/blog/gleam-1.0"),
      sitemap.item("https://gleam.run/blog/gleam-1.1"),
    ])

  let assert Ok(expected) = simplifile.read("test/fixtures/sitemap/sitemap.xml")

  sitemap
  |> sitemap.to_string()
  |> should.equal(expected)
}

/// Confirms that from_string parses the sitemap fixture correctly
pub fn sitemap_from_string_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/sitemap/sitemap.xml")
  let assert Ok(parsed) = sitemap.from_string(xml)

  // Verify the items were parsed correctly
  parsed.items
  |> should.equal([
    sitemap.SitemapItem(
      loc: "https://gleam.run",
      last_modified: None,
      change_frequency: Some(sitemap.Monthly),
      priority: Some(1.0),
    ),
    sitemap.SitemapItem(
      loc: "https://gleam.run/blog",
      last_modified: None,
      change_frequency: Some(sitemap.Weekly),
      priority: None,
    ),
    sitemap.SitemapItem(
      loc: "https://gleam.run/blog/gleam-1.0",
      last_modified: None,
      change_frequency: None,
      priority: None,
    ),
    sitemap.SitemapItem(
      loc: "https://gleam.run/blog/gleam-1.1",
      last_modified: None,
      change_frequency: None,
      priority: None,
    ),
  ])
}

/// Confirms roundtrip: to_string -> from_string produces equivalent config
pub fn sitemap_roundtrip_test() -> Nil {
  let original =
    sitemap.sitemap("https://example.com/sitemap.xml")
    |> sitemap.with_sitemap_items([
      sitemap.item("https://example.com")
        |> sitemap.with_item_frequency(sitemap.Daily)
        |> sitemap.with_item_priority(1.0),
      sitemap.item("https://example.com/about")
        |> sitemap.with_item_frequency(sitemap.Monthly)
        |> sitemap.with_item_priority(0.5),
    ])

  let serialized = sitemap.to_string(original)
  let assert Ok(parsed) = sitemap.from_string(serialized)

  parsed.items
  |> should.equal(original.items)
}

/// Confirms parsing of sitemap with lastmod dates
pub fn sitemap_from_string_with_lastmod_test() -> Nil {
  let assert Ok(xml) =
    simplifile.read("test/fixtures/sitemap/with_lastmod.xml")
  let assert Ok(parsed) = sitemap.from_string(xml)

  let assert [item1, item2] = parsed.items

  item1.loc |> should.equal("https://example.com")
  item1.change_frequency |> should.equal(Some(sitemap.Daily))
  item1.priority |> should.equal(Some(1.0))
  item1.last_modified |> should.be_some

  item2.loc |> should.equal("https://example.com/about")
  item2.last_modified |> should.be_some
  item2.change_frequency |> should.equal(None)
  item2.priority |> should.equal(None)
}

/// Confirms parsing of minimal sitemap with just loc
pub fn sitemap_from_string_minimal_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/sitemap/minimal.xml")
  let assert Ok(parsed) = sitemap.from_string(xml)

  let assert [item] = parsed.items

  item.loc |> should.equal("https://example.com")
  item.last_modified |> should.equal(None)
  item.change_frequency |> should.equal(None)
  item.priority |> should.equal(None)
}

/// Confirms parsing handles all change frequency values
pub fn sitemap_from_string_all_frequencies_test() -> Nil {
  let assert Ok(xml) =
    simplifile.read("test/fixtures/sitemap/all_frequencies.xml")
  let assert Ok(parsed) = sitemap.from_string(xml)

  let assert [always, hourly, daily, weekly, monthly, yearly, never] =
    parsed.items

  always.change_frequency |> should.equal(Some(sitemap.Always))
  hourly.change_frequency |> should.equal(Some(sitemap.Hourly))
  daily.change_frequency |> should.equal(Some(sitemap.Daily))
  weekly.change_frequency |> should.equal(Some(sitemap.Weekly))
  monthly.change_frequency |> should.equal(Some(sitemap.Monthly))
  yearly.change_frequency |> should.equal(Some(sitemap.Yearly))
  never.change_frequency |> should.equal(Some(sitemap.Never))
}

/// Confirms parsing handles single item (not wrapped in list)
pub fn sitemap_from_string_single_item_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/sitemap/single_item.xml")
  let assert Ok(parsed) = sitemap.from_string(xml)

  let assert [item] = parsed.items

  item.loc |> should.equal("https://example.com/single")
  item.change_frequency |> should.equal(Some(sitemap.Weekly))
  item.priority |> should.equal(Some(0.8))
}

/// Confirms parsing handles various priority values
pub fn sitemap_from_string_with_priorities_test() -> Nil {
  let assert Ok(xml) =
    simplifile.read("test/fixtures/sitemap/with_priorities.xml")
  let assert Ok(parsed) = sitemap.from_string(xml)

  let assert [high, medium, low, zero] = parsed.items

  high.priority |> should.equal(Some(1.0))
  medium.priority |> should.equal(Some(0.5))
  low.priority |> should.equal(Some(0.1))
  zero.priority |> should.equal(Some(0.0))
}

/// Confirms builder with_sitemap_item adds single item
pub fn sitemap_with_single_item_test() -> Nil {
  let sitemap =
    sitemap.sitemap("https://example.com/sitemap.xml")
    |> sitemap.with_sitemap_item(sitemap.item("https://example.com/page1"))
    |> sitemap.with_sitemap_item(sitemap.item("https://example.com/page2"))

  sitemap.items
  |> should.equal([
    sitemap.SitemapItem(
      loc: "https://example.com/page2",
      last_modified: None,
      change_frequency: None,
      priority: None,
    ),
    sitemap.SitemapItem(
      loc: "https://example.com/page1",
      last_modified: None,
      change_frequency: None,
      priority: None,
    ),
  ])
}

/// Confirms with_sitemap_last_modified sets the sitemap's last modified time
pub fn sitemap_with_last_modified_test() -> Nil {
  let ts =
    timestamp.from_calendar(
      calendar.Date(2024, calendar.June, 15),
      calendar.TimeOfDay(10, 30, 0, 0),
      calendar.utc_offset,
    )

  let sitemap =
    sitemap.sitemap("https://example.com/sitemap.xml")
    |> sitemap.with_sitemap_last_modified(ts)

  sitemap.last_modified |> should.equal(Some(ts))
}

/// Confirms item builder with_item_last_modified works
pub fn sitemap_item_with_last_modified_test() -> Nil {
  let ts =
    timestamp.from_calendar(
      calendar.Date(2024, calendar.June, 15),
      calendar.TimeOfDay(10, 30, 0, 0),
      calendar.utc_offset,
    )

  let item =
    sitemap.item("https://example.com")
    |> sitemap.with_item_last_modified(ts)

  item.last_modified |> should.equal(Some(ts))
}

/// Confirms priority clamping in to_string (values > 1.0 clamped to 1.0)
pub fn sitemap_priority_clamp_high_test() -> Nil {
  let sm =
    sitemap.sitemap("https://example.com/sitemap.xml")
    |> sitemap.with_sitemap_items([
      sitemap.item("https://example.com")
        |> sitemap.with_item_priority(2.0),
    ])

  // Should contain priority 1.0, not 2.0
  sm
  |> sitemap.to_string()
  |> should.equal(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">
<url>
<loc>https://example.com</loc>
<priority>1.0</priority>
</url>
</urlset>",
  )
}

/// Confirms priority clamping in to_string (values < 0.0 clamped to 0.0)
pub fn sitemap_priority_clamp_low_test() -> Nil {
  let sm =
    sitemap.sitemap("https://example.com/sitemap.xml")
    |> sitemap.with_sitemap_items([
      sitemap.item("https://example.com")
        |> sitemap.with_item_priority(-0.5),
    ])

  // Should contain priority 0.0, not -0.5
  sm
  |> sitemap.to_string()
  |> should.equal(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">
<url>
<loc>https://example.com</loc>
<priority>0.0</priority>
</url>
</urlset>",
  )
}

/// Confirms empty sitemap produces valid XML
pub fn sitemap_empty_test() -> Nil {
  let sm = sitemap.sitemap("https://example.com/sitemap.xml")

  sm
  |> sitemap.to_string()
  |> should.equal(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">

</urlset>",
  )
}
