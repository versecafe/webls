import gleam/list
import gleam/result

pub fn to_string(config: RobotsConfig) -> String {
  "Sitemap: "
  <> config.sitemap_url
  <> "\n\n"
  <> config.robots
  |> list.map(fn(robot) { robot |> robot_to_string })
  |> list.reduce(fn(acc, line) { acc <> "\n\n" <> line })
  |> result.unwrap("")
}

fn robot_to_string(robot: Robot) -> String {
  "User-agent: "
  <> robot.user_agent
  <> "\n"
  <> robot.allowed_routes
  |> list.map(fn(route) { "Allow: " <> route })
  |> list.reduce(fn(acc, line) { acc <> "\n" <> line })
  |> result.unwrap("")
  <> "\n"
  <> robot.disallowed_routes
  |> list.map(fn(route) { "Disallow: " <> route })
  |> list.reduce(fn(acc, line) { acc <> "\n" <> line })
  |> result.unwrap("")
}

/// The configuration for a robots.txt file
pub type RobotsConfig {
  RobotsConfig(
    /// The url of the sitemap for crawlers to use
    sitemap_url: String,
    /// A list of robot policies
    robots: List(Robot),
  )
}

/// The policy for a specific robot
pub type Robot {
  Robot(
    /// The user agent such as "googlebot" or "*" for catch all
    user_agent: String,
    /// The allowed routes such as "/posts/" and "/contact/"
    allowed_routes: List(String),
    /// The disallowed routes such as "/admin/" and "/private/"
    disallowed_routes: List(String),
  )
}
