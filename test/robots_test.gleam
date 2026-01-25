import gleam/option
import gleeunit/should
import simplifile
import webls/robots

/// Confirms that the robots.txt correctly stringifies against a snapshot
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

  let assert Ok(expected) = simplifile.read("test/fixtures/robots/robots.txt")

  config
  |> robots.to_string
  |> should.equal(expected)
}

/// Confirms that a robots.txt string can be parsed into a RobotsConfig
pub fn robots_from_string_test() -> Nil {
  let assert Ok(input) = simplifile.read("test/fixtures/robots/robots.txt")

  let assert Ok(config) = robots.from_string(input)

  config.sitemap_url
  |> should.equal(option.Some("https://example.com/sitemap.xml"))

  config.robots
  |> should.equal([
    robots.Robot("googlebot", ["/posts/", "/contact/"], ["/admin/", "/private/"]),
    robots.Robot("bingbot", ["/posts/", "/contact/", "/private/"], ["/"]),
  ])
}

/// Confirms roundtrip: to_string -> from_string produces equivalent config
pub fn robots_roundtrip_test() -> Nil {
  let original =
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

  let serialized = robots.to_string(original)
  let assert Ok(parsed) = robots.from_string(serialized)

  parsed.sitemap_url
  |> should.equal(original.sitemap_url)

  parsed.robots
  |> should.equal(original.robots)
}

/// Confirms that parsing works when Sitemap directive is missing (it's optional)
pub fn robots_from_string_no_sitemap_test() -> Nil {
  let assert Ok(input) =
    simplifile.read("test/fixtures/robots/no_sitemap.txt")

  let assert Ok(config) = robots.from_string(input)

  config.sitemap_url
  |> should.equal(option.None)

  config.robots
  |> should.equal([robots.Robot("googlebot", ["/posts/"], [])])
}

/// Confirms parsing handles extra whitespace and blank lines
pub fn robots_from_string_whitespace_test() -> Nil {
  let assert Ok(input) =
    simplifile.read("test/fixtures/robots/whitespace.txt")

  let assert Ok(config) = robots.from_string(input)

  config.sitemap_url
  |> should.equal(option.Some("https://example.com/sitemap.xml"))

  config.robots
  |> should.equal([robots.Robot("*", ["/"], [])])
}

/// Confirms parsing is case-insensitive for directives
pub fn robots_from_string_case_insensitive_test() -> Nil {
  let assert Ok(input) =
    simplifile.read("test/fixtures/robots/case_insensitive.txt")

  let assert Ok(config) = robots.from_string(input)

  config.sitemap_url
  |> should.equal(option.Some("https://example.com/sitemap.xml"))

  config.robots
  |> should.equal([robots.Robot("googlebot", ["/posts/"], ["/admin/"])])
}

/// Confirms parsing handles comments (full-line and inline)
pub fn robots_from_string_comments_test() -> Nil {
  let assert Ok(input) =
    simplifile.read("test/fixtures/robots/with_comments.txt")

  let assert Ok(config) = robots.from_string(input)

  config.sitemap_url
  |> should.equal(option.Some("https://example.com/sitemap.xml"))

  config.robots
  |> should.equal([robots.Robot("googlebot", ["/posts/"], ["/admin/"])])
}

/// Confirms parsing works with Disallow before Allow
pub fn robots_from_string_flipped_order_test() -> Nil {
  let assert Ok(input) =
    simplifile.read("test/fixtures/robots/flipped_order.txt")

  let assert Ok(config) = robots.from_string(input)

  config.robots
  |> should.equal([robots.Robot("googlebot", ["/posts/"], ["/admin/"])])
}

/// Confirms parsing fails on malformed lines (missing colon)
pub fn robots_from_string_invalid_test() -> Nil {
  let input = "User-agent: googlebot\nthis is not a valid directive\nAllow: /"

  robots.from_string(input)
  |> should.equal(Error(robots.InvalidDirective("this is not a valid directive")))
}

/// Confirms empty input returns empty config (not an error)
pub fn robots_from_string_empty_test() -> Nil {
  let assert Ok(config) = robots.from_string("")

  config.sitemap_url
  |> should.equal(option.None)

  config.robots
  |> should.equal([])
}

/// Confirms config_without_sitemap builder works
pub fn robots_config_without_sitemap_test() -> Nil {
  let config =
    robots.config_without_sitemap()
    |> robots.with_config_robot(
      robots.robot("*")
      |> robots.with_robot_disallowed_route("/admin/"),
    )

  config.sitemap_url
  |> should.equal(option.None)

  config
  |> robots.to_string
  |> should.equal("User-agent: *\n\nDisallow: /admin/")
}
