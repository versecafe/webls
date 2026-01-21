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

  let assert Ok(expected) = simplifile.read("test/fixtures/sitemap.xml")

  sitemap
  |> sitemap.to_string()
  |> should.equal(expected)
}
