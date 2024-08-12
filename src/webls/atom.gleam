import birl.{type Time}
import gleam/list
import gleam/option.{type Option, None, Some}

// Stringify ------------------------------------------------------------------

// Builder Patern -------------------------------------------------------------

pub fn text(text: String, text_type: TextTypes) -> Text {
  Text(content: text, data_type: Some(text_type))
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

pub fn feed(id: String, title: String, updated: Time) -> AtomFeed {
  AtomFeed(
    id: id,
    title: text(title, PlainText),
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
  AtomEntry(..entry, authors: list.concat([entry.authors, authors]))
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
  AtomEntry(..entry, categories: list.concat([entry.categories, categories]))
}

pub fn with_entry_contributors(
  entry: AtomEntry,
  contributors: List(Person),
) -> AtomEntry {
  AtomEntry(
    ..entry,
    contributors: list.concat([entry.contributors, contributors]),
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
  AtomFeed(..feed, authors: list.concat([feed.authors, authors]))
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
  AtomFeed(..feed, categories: list.concat([feed.categories, categories]))
}

pub fn with_feed_contributor(feed: AtomFeed, contributor: Person) -> AtomFeed {
  AtomFeed(..feed, contributors: [contributor, ..feed.contributors])
}

pub fn with_feed_contributors(
  feed: AtomFeed,
  contributors: List(Person),
) -> AtomFeed {
  AtomFeed(..feed, contributors: list.concat([feed.contributors, contributors]))
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
  AtomFeed(..feed, entries: list.concat([feed.entries, entries]))
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
