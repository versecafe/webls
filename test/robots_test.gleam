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

  let assert Ok(expected) = simplifile.read("test/fixtures/robots.txt")

  config
  |> robots.to_string
  |> should.equal(expected)
}
