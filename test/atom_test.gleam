import gleam/time/calendar
import gleam/time/timestamp
import gleeunit/should
import simplifile
import webls/atom

/// Confirms that the Atom feed correctly stringifies against a snapshot
pub fn atom_to_string_test() -> Nil {
  let test_timestamp =
    timestamp.from_calendar(
      calendar.Date(2024, calendar.January, 15),
      calendar.TimeOfDay(12, 0, 0, 0),
      calendar.utc_offset,
    )

  let feed =
    atom.feed(
      "urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6",
      atom.plain_text("Example Feed"),
      test_timestamp,
    )
    |> atom.with_feed_author(
      atom.person("John Doe")
      |> atom.with_person_email("john@example.com")
      |> atom.with_person_uri("https://example.com/john"),
    )
    |> atom.with_feed_link(
      atom.link("https://example.com/")
      |> atom.with_link_rel("alternate")
      |> atom.with_link_content_type("text/html"),
    )
    |> atom.with_feed_category(
      atom.category("technology")
      |> atom.with_category_scheme("https://example.com/categories")
      |> atom.with_category_label("Technology"),
    )
    |> atom.with_feed_subtitle("A subtitle for the feed")
    |> atom.with_feed_icon("https://example.com/icon.png")
    |> atom.with_feed_logo("https://example.com/logo.png")
    |> atom.with_feed_rights(atom.plain_text("Copyright 2024"))
    |> atom.with_feed_entries([
      atom.entry(
        "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a",
        atom.plain_text("Atom-Powered Robots Run Amok"),
        test_timestamp,
      )
        |> atom.with_entry_authors([atom.person("Jane Doe")])
        |> atom.with_entry_content(atom.html("<p>Some interesting content.</p>"))
        |> atom.with_entry_link(
          atom.link("https://example.com/entry/1")
          |> atom.with_link_rel("alternate"),
        )
        |> atom.with_entry_summary(atom.plain_text("A summary of the entry"))
        |> atom.with_entry_categories([atom.category("robots")])
        |> atom.with_entry_published(test_timestamp)
        |> atom.with_entry_rights(atom.plain_text("CC BY 4.0")),
      atom.entry(
        "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6b",
        atom.xhtml("<div>Second Entry</div>"),
        test_timestamp,
      )
        |> atom.with_entry_summary(atom.plain_text("Another summary")),
    ])

  let assert Ok(expected) = simplifile.read("test/fixtures/atom.xml")

  feed
  |> atom.to_string()
  |> should.equal(expected)
}
