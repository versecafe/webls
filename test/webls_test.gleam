import birl
import gleam/option.{None, Some}
import gleam/string
import gleeunit
import gleeunit/should
import webls/rss.{RssChannel, RssItem}
import webls/sitemap.{Sitemap, SitemapItem}

pub fn main() -> Nil {
  gleeunit.main()
}

/// Confirms that the RSS feed correctly stringifies using known length
pub fn rss_to_string_test() -> Nil {
  let channels = [
    RssChannel(
      title: "Gleam RSS",
      description: "A test RSS feed",
      link: "https://gleam.run",
      items: [
        RssItem(
          title: "Gleam 1.0",
          link: "https://gleam.run/blog/gleam-1.0",
          description: "Gleam 1.0 is here!",
          pub_date: birl.now(),
          author: None,
          guid: #("gleam.run", Some(True)),
        ),
        RssItem(
          title: "Gleam 0.10",
          link: "https://gleam.run/blog/gleam-0.10",
          description: "Gleam 0.10 is here!",
          pub_date: birl.now(),
          author: Some("ve.re.ca@protonmail.com"),
          guid: #("gleam.run", Some(True)),
        ),
      ],
    ),
  ]

  channels
  |> rss.to_string()
  |> string.length()
  |> should.equal(674)
}

/// Confirms that the sitemap correctly stringifies using known length
pub fn sitemap_to_string_test() -> Nil {
  let sitemap =
    Sitemap(
      url: "https://gleam.run/sitemap-0.xml",
      last_modified: Some(birl.now()),
      items: [
        SitemapItem(
          loc: "https://gleam.run",
          last_modified: None,
          change_frequency: Some(sitemap.Monthly),
          priority: Some(1.0),
        ),
        SitemapItem(
          loc: "https://gleam.run/blog",
          last_modified: None,
          change_frequency: Some(sitemap.Weekly),
          priority: None,
        ),
        SitemapItem(
          loc: "https://gleam.run/blog/gleam-1.0",
          last_modified: None,
          change_frequency: None,
          priority: Some(0.5),
        ),
        SitemapItem(
          loc: "https://gleam.run/blog/gleam-1.1",
          last_modified: None,
          change_frequency: None,
          priority: None,
        ),
      ],
    )

  sitemap
  |> sitemap.to_string()
  |> string.length()
  |> should.equal(427)
}
