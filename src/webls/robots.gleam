//// Functions for building and parsing robots.txt files.
////
//// ## Building a robots.txt
////
//// ```gleam
//// import webls/robots
////
//// robots.config("https://example.com/sitemap.xml")
//// |> robots.with_config_robot(
////   robots.robot("*")
////   |> robots.with_robot_disallowed_route("/admin/")
//// )
//// |> robots.to_string
//// ```
////
//// ## Parsing a robots.txt
////
//// ```gleam
//// import webls/robots
////
//// let assert Ok(config) = robots.from_string(robots_txt_content)
//// // Access config.sitemap_url and config.robots
//// ```
////
//// The parser handles comments, extra whitespace, and case-insensitive
//// directives. Unknown directives are ignored. Malformed lines (missing `:`)
//// return an error.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

// Stringify ------------------------------------------------------------------

/// Converts a RobotsConfig to a robots.txt formatted string.
///
/// The output format follows the standard robots.txt specification:
/// - Sitemap directive at the top (if present)
/// - User-agent blocks separated by blank lines
/// - Allow directives followed by Disallow directives for each agent
pub fn to_string(config: RobotsConfig) -> String {
  let sitemap_section = case config.sitemap_url {
    Some(url) -> "Sitemap: " <> url <> "\n\n"
    None -> ""
  }

  let robots_section =
    config.robots
    |> list.map(fn(robot) { robot |> robot_to_string })
    |> list.reduce(fn(acc, line) { acc <> "\n\n" <> line })
    |> result.unwrap("")

  sitemap_section <> robots_section
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

// Builder Pattern ------------------------------------------------------------

/// Creates a robots config with a sitemap url
pub fn config(sitemap_url: String) -> RobotsConfig {
  RobotsConfig(sitemap_url: Some(sitemap_url), robots: [])
}

/// Creates a robots config without a sitemap url
pub fn config_without_sitemap() -> RobotsConfig {
  RobotsConfig(sitemap_url: None, robots: [])
}

/// Sets the sitemap url on a robots config
pub fn with_config_sitemap(config: RobotsConfig, sitemap_url: String) -> RobotsConfig {
  RobotsConfig(..config, sitemap_url: Some(sitemap_url))
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

/// Adds an allowed route to the robot policy
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
    /// The optional url of the sitemap for crawlers to use
    sitemap_url: Option(String),
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

/// Error returned when parsing a malformed robots.txt line
pub type RobotsParseError {
  /// A line could not be parsed as a valid directive (missing `:`)
  InvalidDirective(line: String)
}

// Parse ----------------------------------------------------------------------

/// Parses a robots.txt string into a RobotsConfig.
///
/// The parser handles:
/// - Case-insensitive directives (e.g., `USER-AGENT`, `user-agent`)
/// - Comments (lines starting with `#` or inline `# comment`)
/// - Extra whitespace around directives and values
/// - Unknown directives (silently ignored)
///
/// Returns an error if a non-empty, non-comment line is malformed (missing `:`).
/// An empty config (no sitemap, no robots) is valid.
/// Directives appearing before any `User-agent:` line are ignored.
pub fn from_string(input: String) -> Result(RobotsConfig, RobotsParseError) {
  let lines =
    input
    |> string.split("\n")
    |> list.map(strip_comment)
    |> list.map(string.trim)
    |> list.filter(fn(line) { line != "" })

  case validate_lines(lines) {
    Error(e) -> Error(e)
    Ok(_) -> {
      let sitemap_url = find_sitemap(lines)
      let robot_lines = list.filter(lines, fn(line) { !is_sitemap_line(line) })
      let robots = parse_robots(robot_lines, [], None)
      Ok(RobotsConfig(sitemap_url: sitemap_url, robots: robots))
    }
  }
}

/// Validates that all lines are valid directives (contain `:`)
fn validate_lines(
  lines: List(String),
) -> Result(Nil, RobotsParseError) {
  case lines {
    [] -> Ok(Nil)
    [line, ..rest] ->
      case string.contains(line, ":") {
        True -> validate_lines(rest)
        False -> Error(InvalidDirective(line))
      }
  }
}

/// Strips inline comments from a line (everything after `#`)
fn strip_comment(line: String) -> String {
  case string.split_once(line, "#") {
    Ok(#(before, _)) -> before
    Error(_) -> line
  }
}

/// Splits a directive line into key and value on the first `:`
fn split_directive(line: String) -> Result(#(String, String), Nil) {
  case string.split_once(line, ":") {
    Ok(#(key, value)) -> Ok(#(string.trim(key), string.trim(value)))
    Error(_) -> Error(Nil)
  }
}

fn is_sitemap_line(line: String) -> Bool {
  case split_directive(line) {
    Ok(#(key, _)) -> string.lowercase(key) == "sitemap"
    Error(_) -> False
  }
}

fn find_sitemap(lines: List(String)) -> Option(String) {
  lines
  |> list.find(is_sitemap_line)
  |> result.map(fn(line) {
    case split_directive(line) {
      Ok(#(_, value)) -> value
      Error(_) -> ""
    }
  })
  |> option.from_result
}

fn parse_robots(
  lines: List(String),
  acc: List(Robot),
  current: Option(Robot),
) -> List(Robot) {
  case lines {
    [] ->
      case current {
        Some(r) -> list.reverse([r, ..acc])
        None -> list.reverse(acc)
      }
    [line, ..rest] -> {
      case split_directive(line) {
        Ok(#(key, value)) -> {
          let lower_key = string.lowercase(key)
          case lower_key {
            "user-agent" -> {
              let new_robot = Robot(value, [], [])
              case current {
                Some(r) -> parse_robots(rest, [r, ..acc], Some(new_robot))
                None -> parse_robots(rest, acc, Some(new_robot))
              }
            }
            _ ->
              case current {
                Some(r) -> {
                  let updated = parse_directive(lower_key, value, r)
                  parse_robots(rest, acc, Some(updated))
                }
                None -> parse_robots(rest, acc, None)
              }
          }
        }
        Error(_) -> parse_robots(rest, acc, current)
      }
    }
  }
}

fn parse_directive(key: String, value: String, robot: Robot) -> Robot {
  case key {
    "allow" ->
      Robot(..robot, allowed_routes: list.append(robot.allowed_routes, [value]))
    "disallow" ->
      Robot(
        ..robot,
        disallowed_routes: list.append(robot.disallowed_routes, [value]),
      )
    _ -> robot
  }
}
