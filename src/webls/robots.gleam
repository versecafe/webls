import gleam/list
import gleam/result

// Stringify ------------------------------------------------------------------
//
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

// Builder Patern -------------------------------------------------------------

/// Creates a robots config with a sitemap url
pub fn config(sitemap_url: String) -> RobotsConfig {
  RobotsConfig(sitemap_url: sitemap_url, robots: [])
}

/// Adds a list of robots to the robots config
pub fn with_config_robots(
  config: RobotsConfig,
  robots: List(Robot),
) -> RobotsConfig {
  RobotsConfig(..config, robots: list.flatten([config.robots, robots]))
}

/// Adds a robot to the robots config
pub fn with_config_robot(config: RobotsConfig, robot: Robot) -> RobotsConfig {
  RobotsConfig(..config, robots: [robot, ..config.robots])
}

/// Creates a robot policy
pub fn robot(user_agent: String) -> Robot {
  Robot(user_agent, [], [])
}

/// Adds a list of allowed routes to the robot policy
pub fn with_robot_allowed_routes(robot: Robot, routes: List(String)) -> Robot {
  Robot(..robot, allowed_routes: list.flatten([robot.allowed_routes, routes]))
}

/// Adds a allowed route to the robot policy
pub fn with_robot_allowed_route(robot: Robot, route: String) -> Robot {
  Robot(..robot, allowed_routes: [route, ..robot.allowed_routes])
}

/// Adds a list of disallowed routes to the robot policy
pub fn with_robot_disallowed_routes(robot: Robot, routes: List(String)) -> Robot {
  Robot(
    ..robot,
    disallowed_routes: list.flatten([robot.disallowed_routes, routes]),
  )
}

/// Adds a disallowed route to the robot policy
pub fn with_robot_disallowed_route(robot: Robot, route: String) -> Robot {
  Robot(..robot, disallowed_routes: [route, ..robot.disallowed_routes])
}

// Types ----------------------------------------------------------------------

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
