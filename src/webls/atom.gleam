import birl.{type Time}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

// Stringify ------------------------------------------------------------------

/// Converts an Atom feed to a string of a valid Atom 1.0 feed
pub fn to_string(feed: AtomFeed) -> String {
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">"
  <> atom_feed_to_string(feed)
  <> "</feed>"
}

fn atom_feed_to_string(feed: AtomFeed) -> String {
  "\n<id>"
  <> feed.id
  <> "</id>\n"
  <> "<title>"
  <> text_to_string(feed.title)
  <> "</title>\n"
  <> "<updated>"
  <> birl.to_iso8601(feed.updated)
  <> "</updated>\n"
  <> list.map(feed.authors, person_to_string)
  |> list.reduce(fn(acc, author) { acc <> author })
  |> result.unwrap("")
  <> case feed.link {
    Some(link) -> link_to_string(link)
    None -> ""
  }
  <> list.map(feed.categories, category_to_string)
  |> list.reduce(fn(acc, category) { acc <> category })
  |> result.unwrap("")
  <> list.map(feed.contributors, person_to_string)
  |> list.reduce(fn(acc, contributor) { acc <> contributor })
  |> result.unwrap("")
  <> case feed.generator {
    Some(generator) -> generator_to_string(generator)
    None -> ""
  }
  <> case feed.icon {
    Some(icon) -> "<icon>" <> icon <> "</icon>\n"
    None -> ""
  }
  <> case feed.logo {
    Some(logo) -> "<logo>" <> logo <> "</logo>\n"
    None -> ""
  }
  <> case feed.rights {
    Some(rights) -> "<rights>" <> text_to_string(rights) <> "</rights>\n"
    None -> ""
  }
  <> case feed.subtitle {
    Some(subtitle) -> "<subtitle>" <> subtitle <> "</subtitle>\n"
    None -> ""
  }
  <> list.map(feed.entries, atom_entry_to_string)
  |> list.reduce(fn(acc, entry) { acc <> entry })
  |> result.unwrap("")
}

fn atom_entry_to_string(entry: AtomEntry) -> String {
  "<entry>\n"
  <> "<id>"
  <> entry.id
  <> "</id>\n"
  <> "<title>"
  <> text_to_string(entry.title)
  <> "</title>\n"
  <> "<updated>"
  <> birl.to_iso8601(entry.updated)
  <> "</updated>\n"
  <> list.map(entry.authors, person_to_string)
  |> list.reduce(fn(acc, author) { acc <> author })
  |> result.unwrap("")
  <> case entry.content {
    Some(content) -> "<content>" <> text_to_string(content) <> "</content>\n"
    None -> ""
  }
  <> case entry.link {
    Some(link) -> link_to_string(link)
    None -> ""
  }
  <> case entry.summary {
    Some(summary) -> "<summary>" <> text_to_string(summary) <> "</summary>\n"
    None -> ""
  }
  <> list.map(entry.categories, category_to_string)
  |> list.reduce(fn(acc, category) { acc <> category })
  |> result.unwrap("")
  <> list.map(entry.contributors, person_to_string)
  |> list.reduce(fn(acc, contributor) { acc <> contributor })
  |> result.unwrap("")
  <> case entry.published {
    Some(published) ->
      "<published>" <> birl.to_iso8601(published) <> "</published>\n"
    None -> ""
  }
  <> case entry.rights {
    Some(rights) -> "<rights>" <> text_to_string(rights) <> "</rights>\n"
    None -> ""
  }
  <> case entry.source {
    Some(source) -> source_to_string(source)
    None -> ""
  }
  <> "</entry>\n"
}

fn person_to_string(person: Person) -> String {
  "<author>\n"
  <> "<name>"
  <> person.name
  <> "</name>\n"
  <> case person.email {
    Some(email) -> "<email>" <> email <> "</email>\n"
    None -> ""
  }
  <> case person.uri {
    Some(uri) -> "<uri>" <> uri <> "</uri>\n"
    None -> ""
  }
  <> "</author>\n"
}

fn link_to_string(link: Link) -> String {
  "<link href=\""
  <> link.href
  <> "\""
  <> case link.rel {
    Some(rel) -> " rel=\"" <> rel <> "\""
    None -> ""
  }
  <> case link.content_type {
    Some(content_type) -> " type=\"" <> content_type <> "\""
    None -> ""
  }
  <> case link.hreflang {
    Some(hreflang) -> " hreflang=\"" <> hreflang <> "\""
    None -> ""
  }
  <> case link.title {
    Some(title) -> " title=\"" <> title <> "\""
    None -> ""
  }
  <> case link.length {
    Some(length) -> " length=\"" <> int.to_string(length) <> "\""
    None -> ""
  }
  <> "/>\n"
}

fn category_to_string(category: Category) -> String {
  "<category term=\""
  <> category.term
  <> "\""
  <> case category.scheme {
    Some(scheme) -> " scheme=\"" <> scheme <> "\""
    None -> ""
  }
  <> case category.label {
    Some(label) -> " label=\"" <> label <> "\""
    None -> ""
  }
  <> "/>\n"
}

fn generator_to_string(generator: Generator) -> String {
  "<generator"
  <> case generator.uri {
    Some(uri) -> " uri=\"" <> uri <> "\""
    None -> ""
  }
  <> case generator.version {
    Some(version) -> " version=\"" <> version <> "\""
    None -> ""
  }
  <> ">webls</generator>\n"
}

fn source_to_string(source: Source) -> String {
  "<source>\n"
  <> "<id>"
  <> source.id
  <> "</id>\n"
  <> "<title>"
  <> source.title
  <> "</title>\n"
  <> "<updated>"
  <> birl.to_iso8601(source.updated)
  <> "</updated>\n"
  <> "</source>\n"
}

fn text_to_string(text: Text) -> String {
  case text {
    PlainText(value) -> value
    Html(value) -> "<type=\"html\">" <> value <> "</type>"
    XHtml(value) -> "<type=\"xhtml\">" <> value <> "</type>"
  }
}

// Builder Patern -------------------------------------------------------------

pub fn plain_text(input: String) -> Text {
  PlainText(input)
}

pub fn html(input: String) -> Text {
  Html(input)
}

pub fn xhtml(input: String) -> Text {
  XHtml(input)
}

pub fn link(href: String) -> Link {
  Link(
    href: href,
    rel: None,
    content_type: None,
    hreflang: None,
    title: None,
    length: None,
  )
}

pub fn with_link_rel(link: Link, rel: String) -> Link {
  Link(..link, rel: Some(rel))
}

pub fn with_link_content_type(link: Link, content_type: String) -> Link {
  Link(..link, content_type: Some(content_type))
}

pub fn with_link_hreflang(link: Link, hreflang: String) -> Link {
  Link(..link, hreflang: Some(hreflang))
}

pub fn with_link_title(link: Link, title: String) -> Link {
  Link(..link, title: Some(title))
}

pub fn with_link_length(link: Link, length: Int) -> Link {
  Link(..link, length: Some(length))
}

pub fn category(term: String) -> Category {
  Category(term: term, scheme: None, label: None)
}

pub fn with_category_scheme(category: Category, scheme: String) -> Category {
  Category(..category, scheme: Some(scheme))
}

pub fn with_category_label(category: Category, label: String) -> Category {
  Category(..category, label: Some(label))
}

pub fn person(name: String) -> Person {
  Person(name: name, email: None, uri: None)
}

pub fn with_person_email(person: Person, email: String) -> Person {
  Person(..person, email: Some(email))
}

pub fn with_person_uri(person: Person, uri: String) -> Person {
  Person(..person, uri: Some(uri))
}

pub fn feed(id: String, title: Text, updated: Time) -> AtomFeed {
  AtomFeed(
    id: id,
    title: title,
    updated: updated,
    authors: [],
    link: None,
    categories: [],
    contributors: [],
    generator: None,
    icon: None,
    logo: None,
    rights: None,
    subtitle: None,
    entries: [],
  )
}

pub fn entry(id: String, title: Text, updated: Time) -> AtomEntry {
  AtomEntry(
    id: id,
    title: title,
    updated: updated,
    authors: [],
    content: None,
    link: None,
    summary: None,
    categories: [],
    contributors: [],
    published: None,
    rights: None,
    source: None,
  )
}

pub fn with_entry_id(entry: AtomEntry, id: String) -> AtomEntry {
  AtomEntry(..entry, id: id)
}

pub fn with_entry_title(entry: AtomEntry, title: Text) -> AtomEntry {
  AtomEntry(..entry, title: title)
}

pub fn with_entry_updated(entry: AtomEntry, updated: Time) -> AtomEntry {
  AtomEntry(..entry, updated: updated)
}

pub fn with_entry_authors(entry: AtomEntry, authors: List(Person)) -> AtomEntry {
  AtomEntry(..entry, authors: list.flatten([entry.authors, authors]))
}

pub fn with_entry_content(entry: AtomEntry, content: Text) -> AtomEntry {
  AtomEntry(..entry, content: Some(content))
}

pub fn with_entry_link(entry: AtomEntry, link: Link) -> AtomEntry {
  AtomEntry(..entry, link: Some(link))
}

pub fn with_entry_summary(entry: AtomEntry, summary: Text) -> AtomEntry {
  AtomEntry(..entry, summary: Some(summary))
}

pub fn with_entry_categories(
  entry: AtomEntry,
  categories: List(Category),
) -> AtomEntry {
  AtomEntry(..entry, categories: list.flatten([entry.categories, categories]))
}

pub fn with_entry_contributors(
  entry: AtomEntry,
  contributors: List(Person),
) -> AtomEntry {
  AtomEntry(
    ..entry,
    contributors: list.flatten([entry.contributors, contributors]),
  )
}

pub fn with_entry_published(entry: AtomEntry, published: Time) -> AtomEntry {
  AtomEntry(..entry, published: Some(published))
}

pub fn with_entry_rights(entry: AtomEntry, rights: Text) -> AtomEntry {
  AtomEntry(..entry, rights: Some(rights))
}

pub fn with_entry_source(entry: AtomEntry, source: Source) -> AtomEntry {
  AtomEntry(..entry, source: Some(source))
}

pub fn with_feed_author(feed: AtomFeed, author: Person) -> AtomFeed {
  AtomFeed(..feed, authors: [author, ..feed.authors])
}

pub fn with_feed_authors(feed: AtomFeed, authors: List(Person)) -> AtomFeed {
  AtomFeed(..feed, authors: list.flatten([feed.authors, authors]))
}

pub fn with_feed_link(feed: AtomFeed, link: Link) -> AtomFeed {
  AtomFeed(..feed, link: Some(link))
}

pub fn with_feed_category(feed: AtomFeed, category: Category) -> AtomFeed {
  AtomFeed(..feed, categories: [category, ..feed.categories])
}

pub fn with_feed_categories(
  feed: AtomFeed,
  categories: List(Category),
) -> AtomFeed {
  AtomFeed(..feed, categories: list.flatten([feed.categories, categories]))
}

pub fn with_feed_contributor(feed: AtomFeed, contributor: Person) -> AtomFeed {
  AtomFeed(..feed, contributors: [contributor, ..feed.contributors])
}

pub fn with_feed_contributors(
  feed: AtomFeed,
  contributors: List(Person),
) -> AtomFeed {
  AtomFeed(
    ..feed,
    contributors: list.flatten([feed.contributors, contributors]),
  )
}

pub fn with_feed_generator(feed: AtomFeed, generator: Generator) -> AtomFeed {
  AtomFeed(..feed, generator: Some(generator))
}

pub fn with_feed_icon(feed: AtomFeed, icon: String) -> AtomFeed {
  AtomFeed(..feed, icon: Some(icon))
}

pub fn with_feed_logo(feed: AtomFeed, logo: String) -> AtomFeed {
  AtomFeed(..feed, logo: Some(logo))
}

pub fn with_feed_rights(feed: AtomFeed, rights: Text) -> AtomFeed {
  AtomFeed(..feed, rights: Some(rights))
}

pub fn with_feed_subtitle(feed: AtomFeed, subtitle: String) -> AtomFeed {
  AtomFeed(..feed, subtitle: Some(subtitle))
}

pub fn with_feed_entry(feed: AtomFeed, entry: AtomEntry) -> AtomFeed {
  AtomFeed(..feed, entries: [entry, ..feed.entries])
}

pub fn with_feed_entries(feed: AtomFeed, entries: List(AtomEntry)) -> AtomFeed {
  AtomFeed(..feed, entries: list.flatten([feed.entries, entries]))
}

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
  PlainText(value: String)
  Html(value: String)
  XHtml(value: String)
}

pub type Source {
  Source(id: String, title: String, updated: Time)
}
