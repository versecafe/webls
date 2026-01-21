import gleam/option.{Some}
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

  let assert Ok(expected) = simplifile.read("test/fixtures/rss.xml")

  channels
  |> rss.to_string()
  |> should.equal(expected)
}
