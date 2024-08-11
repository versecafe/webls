import birl
import gleam/option.{None, Some}
import gleam/string
import gleeunit
import gleeunit/should
import webls/robots.{Robot, RobotsConfig}
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
          author: Some("user@example.com"),
          guid: #("gleam.run", Some(True)),
        ),
      ],
    ),
  ]

  let length: Int =
    channels
    |> rss.to_string()
    |> string.length()

  { length > 600 }
  |> should.be_true
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

  let length: Int =
    sitemap
    |> sitemap.to_string()
    |> string.length()

  { length > 400 }
  |> should.be_true
}

pub fn sitemap_builder_test() -> Nil {
  let built =
    Sitemap(url: "https://gleam.run/sitemap.xml", last_modified: None, items: [
      sitemap.item("https://gleam.run")
        |> sitemap.with_frequency(sitemap.Monthly)
        |> sitemap.with_priority(1.0),
      sitemap.item("https://gleam.run/blog")
        |> sitemap.with_frequency(sitemap.Weekly),
      sitemap.item("https://gleam.run/blog/gleam-1.0"),
      sitemap.item("https://gleam.run/blog/gleam-1.1"),
    ])

  let manual =
    Sitemap(url: "https://gleam.run/sitemap.xml", last_modified: None, items: [
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
        priority: None,
      ),
      SitemapItem(
        loc: "https://gleam.run/blog/gleam-1.1",
        last_modified: None,
        change_frequency: None,
        priority: None,
      ),
    ])

  built |> should.equal(manual)
}

/// Confirms that the robots.txt correctly stringifies using known length
pub fn robots_to_string_test() -> Nil {
  let config =
    RobotsConfig(sitemap_url: "https://gleam.run/sitemap.xml", robots: [
      Robot(
        user_agent: "googlebot",
        allowed_routes: ["/posts/", "/contact/"],
        disallowed_routes: ["/admin/", "/private/"],
      ),
      Robot(
        user_agent: "bingbot",
        allowed_routes: ["/posts/", "/contact/"],
        disallowed_routes: ["/admin/", "/private/"],
      ),
    ])

  let length: Int =
    config
    |> robots.to_string
    |> string.length()

  { length > 200 }
  |> should.be_true
}
