import gleam/option.{None, Some}
import gleam/time/calendar
import gleam/time/timestamp
import gleeunit/should
import simplifile
import webls/rss

/// Confirms that the RSS feed correctly stringifies against a snapshot
pub fn rss_to_string_test() -> Nil {
  let channels = [
    rss.channel("Gleam RSS", "A test RSS feed", "https://gleam.run")
    |> rss.with_channel_category("Releases")
    |> rss.with_channel_language("en")
    |> rss.with_channel_items([
      rss.item("Gleam 1.0", "Gleam 1.0 is here!")
        |> rss.with_item_link("https://gleam.run/blog/gleam-1.0")
        |> rss.with_item_pub_date(timestamp.from_calendar(
          calendar.Date(2024, calendar.August, 11),
          calendar.TimeOfDay(20, 22, 50, 481_000_000),
          calendar.utc_offset,
        ))
        |> rss.with_item_guid(#("gleam 1.0", Some(False))),
      rss.item("Gleam 0.10", "Gleam 0.10 is here!")
        |> rss.with_item_link("https://gleam.run/blog/gleam-0.10")
        |> rss.with_item_author("user@example.com")
        |> rss.with_item_guid(#("gleam 0.10", Some(True))),
    ]),
  ]

  let assert Ok(expected) = simplifile.read("test/fixtures/rss/rss.xml")

  channels
  |> rss.to_string()
  |> should.equal(expected)
}

/// Confirms that from_string parses the RSS fixture correctly
pub fn rss_from_string_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/rss.xml")
  let assert Ok(channels) = rss.from_string(xml)

  // Should have one channel
  let assert [channel] = channels

  // Verify channel metadata
  channel.title |> should.equal("Gleam RSS")
  channel.link |> should.equal("https://gleam.run")
  channel.description |> should.equal("A test RSS feed")
  channel.language |> should.equal(Some("en"))
  channel.categories |> should.equal(["Releases"])

  // Verify items were parsed correctly
  let assert [item1, item2] = channel.items

  // First item
  item1.title |> should.equal("Gleam 1.0")
  item1.description |> should.equal("Gleam 1.0 is here!")
  item1.link |> should.equal(Some("https://gleam.run/blog/gleam-1.0"))
  item1.author |> should.equal(None)
  item1.guid |> should.equal(Some(#("gleam 1.0", Some(False))))

  // Second item
  item2.title |> should.equal("Gleam 0.10")
  item2.description |> should.equal("Gleam 0.10 is here!")
  item2.link |> should.equal(Some("https://gleam.run/blog/gleam-0.10"))
  item2.author |> should.equal(Some("user@example.com"))
  item2.guid |> should.equal(Some(#("gleam 0.10", Some(True))))
}

/// Confirms roundtrip: to_string -> from_string produces equivalent channel
pub fn rss_roundtrip_test() -> Nil {
  let original = [
    rss.channel("Test Feed", "A test feed", "https://example.com")
    |> rss.with_channel_language("en-us")
    |> rss.with_channel_items([
      rss.item("Article 1", "First article content")
        |> rss.with_item_link("https://example.com/article-1"),
    ]),
  ]

  let serialized = rss.to_string(original)
  let assert Ok(parsed) = rss.from_string(serialized)

  let assert [orig_channel] = original
  let assert [parsed_channel] = parsed

  parsed_channel.title |> should.equal(orig_channel.title)
  parsed_channel.link |> should.equal(orig_channel.link)
  parsed_channel.description |> should.equal(orig_channel.description)
  parsed_channel.language |> should.equal(orig_channel.language)
}

/// Confirms parsing of minimal RSS feed (just required fields)
pub fn rss_from_string_minimal_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/minimal.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels

  channel.title |> should.equal("Minimal Feed")
  channel.link |> should.equal("https://example.com")
  channel.description |> should.equal("A minimal RSS feed")
  channel.language |> should.equal(None)
  channel.copyright |> should.equal(None)
  channel.items |> should.equal([])
}

/// Confirms parsing of RSS feed with image
pub fn rss_from_string_with_image_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/with_image.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels
  let assert Some(image) = channel.image

  image.url |> should.equal("https://example.com/logo.png")
  image.title |> should.equal("Example Logo")
  image.link |> should.equal("https://example.com")
  image.description |> should.equal(Some("The logo for Example"))
  image.width |> should.equal(Some(144))
  image.height |> should.equal(Some(88))
}

/// Confirms parsing of RSS feed with enclosures (podcast style)
pub fn rss_from_string_with_enclosure_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/with_enclosure.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels
  let assert [item1, item2] = channel.items

  let assert Some(enc1) = item1.enclosure
  enc1.url |> should.equal("https://example.com/ep1.mp3")
  enc1.length |> should.equal(12_345_678)
  enc1.enclosure_type |> should.equal("audio/mpeg")

  let assert Some(enc2) = item2.enclosure
  enc2.url |> should.equal("https://example.com/ep2.mp3")
  enc2.length |> should.equal(9_876_543)
}

/// Confirms parsing of RSS feed with cloud configuration
pub fn rss_from_string_with_cloud_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/with_cloud.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels
  let assert Some(cloud) = channel.cloud

  cloud.domain |> should.equal("rpc.example.com")
  cloud.port |> should.equal(80)
  cloud.path |> should.equal("/RPC2")
  cloud.register_procedure |> should.equal("pingMe")
  cloud.protocol |> should.equal("soap")

  channel.ttl |> should.equal(Some(60))
}

/// Confirms parsing of RSS feed with text input
pub fn rss_from_string_with_text_input_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/with_text_input.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels
  let assert Some(text_input) = channel.text_input

  text_input.title |> should.equal("Search")
  text_input.description |> should.equal("Search this feed")
  text_input.name |> should.equal("q")
  text_input.link |> should.equal("https://example.com/search")
}

/// Confirms parsing of RSS feed with skip hours and days
pub fn rss_from_string_with_skip_hours_days_test() -> Nil {
  let assert Ok(xml) =
    simplifile.read("test/fixtures/rss/with_skip_hours_days.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels

  channel.skip_hours |> should.equal([0, 1, 2])
  channel.skip_days |> should.equal([rss.Saturday, rss.Sunday])
}

/// Confirms parsing of RSS feed with categories
pub fn rss_from_string_with_categories_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/with_categories.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels

  channel.categories |> should.equal(["Technology", "Programming"])

  let assert [item] = channel.items
  item.categories |> should.equal(["Gleam", "Functional Programming"])
}

/// Confirms parsing of full-featured RSS channel
pub fn rss_from_string_full_channel_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/full_channel.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels

  channel.title |> should.equal("Full Featured Feed")
  channel.language |> should.equal(Some("en-us"))
  channel.copyright |> should.equal(Some("Copyright 2024 Example Inc."))
  channel.managing_editor |> should.equal(Some("editor@example.com"))
  channel.web_master |> should.equal(Some("webmaster@example.com"))
  channel.pub_date |> should.be_some
  channel.last_build_date |> should.be_some
  channel.generator |> should.equal(Some("webls"))
  channel.docs |> should.equal(Some("https://www.rssboard.org/rss-2-0-1"))
  channel.ttl |> should.equal(Some(30))

  let assert [item] = channel.items
  item.title |> should.equal("Full Item")
  item.link |> should.equal(Some("https://example.com/full-item"))
  item.author |> should.equal(Some("author@example.com"))
  item.comments |> should.equal(Some("https://example.com/full-item/comments"))
  item.source |> should.equal(Some("Original Source"))
  item.guid |> should.equal(Some(#("https://example.com/full-item", Some(True))))
}

/// Confirms parsing handles single item (not wrapped in list)
pub fn rss_from_string_single_item_test() -> Nil {
  let assert Ok(xml) = simplifile.read("test/fixtures/rss/single_item.xml")
  let assert Ok(channels) = rss.from_string(xml)

  let assert [channel] = channels
  let assert [item] = channel.items

  item.title |> should.equal("Only Item")
  item.description |> should.equal("The only item in this feed")
}

/// Confirms channel builder with_channel_copyright works
pub fn rss_with_channel_copyright_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_copyright("Copyright 2024")

  channel.copyright |> should.equal(Some("Copyright 2024"))
}

/// Confirms channel builder with_channel_managing_editor works
pub fn rss_with_channel_managing_editor_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_managing_editor("editor@example.com")

  channel.managing_editor |> should.equal(Some("editor@example.com"))
}

/// Confirms channel builder with_channel_web_master works
pub fn rss_with_channel_web_master_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_web_master("webmaster@example.com")

  channel.web_master |> should.equal(Some("webmaster@example.com"))
}

/// Confirms channel builder with_channel_pub_date works
pub fn rss_with_channel_pub_date_test() -> Nil {
  let ts =
    timestamp.from_calendar(
      calendar.Date(2024, calendar.June, 15),
      calendar.TimeOfDay(10, 30, 0, 0),
      calendar.utc_offset,
    )

  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_pub_date(ts)

  channel.pub_date |> should.equal(Some(ts))
}

/// Confirms channel builder with_channel_last_build_date works
pub fn rss_with_channel_last_build_date_test() -> Nil {
  let ts =
    timestamp.from_calendar(
      calendar.Date(2024, calendar.June, 15),
      calendar.TimeOfDay(10, 30, 0, 0),
      calendar.utc_offset,
    )

  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_last_build_date(ts)

  channel.last_build_date |> should.equal(Some(ts))
}

/// Confirms channel builder with_channel_categories works
pub fn rss_with_channel_categories_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_categories(["Tech", "Programming"])

  channel.categories |> should.equal(["Tech", "Programming"])
}

/// Confirms channel builder with_channel_generator works
pub fn rss_with_channel_generator_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_generator()

  channel.generator |> should.equal(Some("webls"))
}

/// Confirms channel builder with_channel_custom_generator works
pub fn rss_with_channel_custom_generator_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_custom_generator("MyApp v1.0")

  channel.generator |> should.equal(Some("MyApp v1.0"))
}

/// Confirms channel builder with_channel_docs works
pub fn rss_with_channel_docs_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_docs()

  channel.docs |> should.equal(Some("https://www.rssboard.org/rss-2-0-1"))
}

/// Confirms channel builder with_channel_cloud works
pub fn rss_with_channel_cloud_test() -> Nil {
  let cloud =
    rss.Cloud(
      domain: "rpc.example.com",
      port: 80,
      path: "/RPC2",
      register_procedure: "pingMe",
      protocol: "soap",
    )

  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_cloud(cloud)

  channel.cloud |> should.equal(Some(cloud))
}

/// Confirms channel builder with_channel_ttl works
pub fn rss_with_channel_ttl_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_ttl(60)

  channel.ttl |> should.equal(Some(60))
}

/// Confirms channel builder with_channel_image works
pub fn rss_with_channel_image_test() -> Nil {
  let image =
    rss.Image(
      url: "https://example.com/logo.png",
      title: "Logo",
      link: "https://example.com",
      description: Some("A logo"),
      width: Some(100),
      height: Some(50),
    )

  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_image(image)

  channel.image |> should.equal(Some(image))
}

/// Confirms channel builder with_channel_text_input works
pub fn rss_with_channel_text_input_test() -> Nil {
  let text_input =
    rss.TextInput(
      title: "Search",
      description: "Search the feed",
      name: "q",
      link: "https://example.com/search",
    )

  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_text_input(text_input)

  channel.text_input |> should.equal(Some(text_input))
}

/// Confirms channel builder with_channel_skip_hours works
pub fn rss_with_channel_skip_hours_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_skip_hours([0, 1, 2, 3])

  channel.skip_hours |> should.equal([0, 1, 2, 3])
}

/// Confirms channel builder with_channel_skip_days works
pub fn rss_with_channel_skip_days_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_skip_days([rss.Saturday, rss.Sunday])

  channel.skip_days |> should.equal([rss.Saturday, rss.Sunday])
}

/// Confirms channel builder with_channel_item (singular) works
pub fn rss_with_channel_item_test() -> Nil {
  let channel =
    rss.channel("Test", "Desc", "https://example.com")
    |> rss.with_channel_item(rss.item("Item 1", "Description 1"))
    |> rss.with_channel_item(rss.item("Item 2", "Description 2"))

  let assert [item2, item1] = channel.items
  item1.title |> should.equal("Item 1")
  item2.title |> should.equal("Item 2")
}

/// Confirms item builder with_item_categories works
pub fn rss_with_item_categories_test() -> Nil {
  let item =
    rss.item("Test", "Desc")
    |> rss.with_item_categories(["Tech", "News"])

  item.categories |> should.equal(["Tech", "News"])
}

/// Confirms item builder with_item_comments works
pub fn rss_with_item_comments_test() -> Nil {
  let item =
    rss.item("Test", "Desc")
    |> rss.with_item_comments("https://example.com/comments")

  item.comments |> should.equal(Some("https://example.com/comments"))
}

/// Confirms item builder with_item_enclosure works
pub fn rss_with_item_enclosure_test() -> Nil {
  let enclosure =
    rss.Enclosure(
      url: "https://example.com/audio.mp3",
      length: 12_345_678,
      enclosure_type: "audio/mpeg",
    )

  let item =
    rss.item("Test", "Desc")
    |> rss.with_item_enclosure(enclosure)

  item.enclosure |> should.equal(Some(enclosure))
}

/// Confirms item builder with_item_source works
pub fn rss_with_item_source_test() -> Nil {
  let item =
    rss.item("Test", "Desc")
    |> rss.with_item_source("Original Feed")

  item.source |> should.equal(Some("Original Feed"))
}

/// Confirms empty channel produces valid XML
pub fn rss_empty_channel_test() -> Nil {
  let channels = [rss.channel("Empty", "An empty feed", "https://example.com")]

  let result = rss.to_string(channels)

  result
  |> should.equal(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<rss version=\"2.0.1\">
<channel>
<title>Empty</title>
<link>https://example.com</link>
<description>An empty feed</description>
</channel>
</rss>",
  )
}
