# WebLS

A Gleam library for generating sitemaps and RSS feeds and more. to meet all
your common web listing needs.

[![Package Version](https://img.shields.io/hexpm/v/webls)](https://hex.pm/packages/webls)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/webls/)

```sh
gleam add webls
```

```gleam
import gleam/option.{None}
import webls/sitemap.{Sitemap}

pub fn sitemap() -> String {
  let sitemap =
    Sitemap(url: "https://gleam.run/sitemap.xml", last_modified: None, items: [
      sitemap.item("https://gleam.run")
        |> sitemap.with_frequency(sitemap.Monthly)
        |> sitemap.with_priority(1.0),
      sitemap.item("https://gleam.run/blog")
        |> sitemap.with_frequency(sitemap.Weekly),
      sitemap.item("https://gleam.run/blog/gleam-1.0"),
      sitemap.item("https://gleam.run/blog/gleam-1.1"),
    ])

  sitemap |> sitemap.to_string()
}
```

Further documentation can be found at <https://hexdocs.pm/webls>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

> Yes the name is a reference to the `ls` command in unix to list files
