import birl.{type Time}
import gleam/option.{type Option}

// Stringify ------------------------------------------------------------------

// Builder Patern -------------------------------------------------------------

// Types ----------------------------------------------------------------------

pub type AtomFeed {
  AtomFeed(
    id: String,
    title: Text,
    updated: Time,
    authors: List(Person),
    link: Option(Link),
    categories: List(Category),
    contributors: List(Person),
    generator: Option(Generator),
    icon: Option(String),
    logo: Option(String),
    rights: Option(Text),
    subtitle: Option(String),
    entries: List(AtomEntry),
  )
}

pub type Person {
  Person(name: String, email: Option(String), uri: Option(String))
}

pub type Generator {
  Generator(uri: Option(String), version: Option(String))
}

pub type Link {
  Link(
    href: String,
    rel: Option(String),
    content_type: Option(String),
    hreflang: Option(String),
    title: Option(String),
    length: Option(Int),
  )
}

pub type Category {
  Category(term: String, scheme: Option(String), label: Option(String))
}

pub type AtomEntry {
  AtomEntry(
    id: String,
    title: Text,
    updated: Time,
    authors: List(Person),
    content: Option(Text),
    link: Option(Link),
    summary: Option(Text),
    categories: List(Category),
    contributors: List(Person),
    published: Option(Time),
    rights: Option(Text),
    source: Option(Source),
  )
}

pub type Text {
  Text(content: String, data_type: Option(TextTypes))
}

pub type TextTypes {
  PlainText
  Html
  Xhtml
}

pub type Source {
  Source(id: String, title: String, updated: Time)
}
