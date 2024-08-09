# WebLS

A Gleam library for generating sitemaps and RSS feeds and more. to meet all
your common web listing needs.

[![Package Version](https://img.shields.io/hexpm/v/webls)](https://hex.pm/packages/webls)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/webls/)

```sh
gleam add webls@1
```

```gleam
import webls/rss{RssChannel, RssItem}

pub fn generate_rss_feed() -> String {
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
}
```

Further documentation can be found at <https://hexdocs.pm/webls>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

> Yes the name is a reference to the `ls` command in unix to list files
