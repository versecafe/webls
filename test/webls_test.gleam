import birl
import gleam/option.{Some}
import gleam/string
import gleeunit
import gleeunit/should
import webls/robots
import webls/rss
import webls/sitemap

pub fn main() -> Nil {
  gleeunit.main()
}

/// Confirms that the RSS feed correctly stringifies using known length
pub fn rss_to_string_test() -> Nil {
  let channels = [
    rss.channel("Gleam RSS", "A test RSS feed", "https://gleam.run")
    |> rss.with_channel_category("Releases")
    |> rss.with_channel_language("en")
    |> rss.with_channel_items([
      rss.item("Gleam 1.0", "Gleam 1.0 is here!")
        |> rss.with_item_link("https://gleam.run/blog/gleam-1.0")
        |> rss.with_item_pub_date(birl.now())
        |> rss.with_item_guid(#("gleam 1.0", Some(False))),
      rss.item("Gleam 0.10", "Gleam 0.10 is here!")
        |> rss.with_item_link("https://gleam.run/blog/gleam-0.10")
        |> rss.with_item_author("user@example.com")
        |> rss.with_item_guid(#("gleam 0.10", Some(True))),
    ]),
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
    sitemap.sitemap("https://gleam.run/sitemap.xml")
    |> sitemap.with_sitemap_last_modified(birl.now())
    |> sitemap.with_sitemap_items([
      sitemap.item("https://gleam.run")
        |> sitemap.with_item_frequency(sitemap.Monthly)
        |> sitemap.with_item_priority(1.0),
      sitemap.item("https://gleam.run/blog")
        |> sitemap.with_item_frequency(sitemap.Weekly),
      sitemap.item("https://gleam.run/blog/gleam-1.0"),
      sitemap.item("https://gleam.run/blog/gleam-1.1"),
    ])

  let length: Int =
    sitemap
    |> sitemap.to_string()
    |> string.length()

  { length > 400 }
  |> should.be_true
}

/// Confirms that the robots.txt correctly stringifies using known length
pub fn robots_to_string_test() -> Nil {
  let config =
    robots.config("https://example.com/sitemap.xml")
    |> robots.with_config_robots([
      robots.robot("googlebot")
        |> robots.with_robot_allowed_routes(["/posts/", "/contact/"])
        |> robots.with_robot_disallowed_routes(["/admin/", "/private/"]),
      robots.robot("bingbot")
        |> robots.with_robot_allowed_routes([
          "/posts/", "/contact/", "/private/",
        ])
        |> robots.with_robot_disallowed_routes(["/"]),
    ])

  let length: Int =
    config
    |> robots.to_string
    |> string.length()

  { length > 200 }
  |> should.be_true
}
