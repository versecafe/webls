import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/time/calendar
import gleam/time/timestamp.{type Timestamp}

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
  <> timestamp.to_rfc3339(feed.updated, calendar.utc_offset)
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
  <> timestamp.to_rfc3339(entry.updated, calendar.utc_offset)
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
      "<published>"
      <> timestamp.to_rfc3339(published, calendar.utc_offset)
      <> "</published>\n"
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
  <> timestamp.to_rfc3339(source.updated, calendar.utc_offset)
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

/// Creates plain text content
pub fn plain_text(input: String) -> Text {
  PlainText(input)
}

/// Creates HTML text content
pub fn html(input: String) -> Text {
  Html(input)
}

/// Creates XHTML text content
pub fn xhtml(input: String) -> Text {
  XHtml(input)
}

/// Creates a base link with just the href
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

/// Sets the relationship type of the link
pub fn with_link_rel(link: Link, rel: String) -> Link {
  Link(..link, rel: Some(rel))
}

/// Sets the content type of the link
pub fn with_link_content_type(link: Link, content_type: String) -> Link {
  Link(..link, content_type: Some(content_type))
}

/// Sets the language of the linked resource
pub fn with_link_hreflang(link: Link, hreflang: String) -> Link {
  Link(..link, hreflang: Some(hreflang))
}

/// Sets the title of the link
pub fn with_link_title(link: Link, title: String) -> Link {
  Link(..link, title: Some(title))
}

/// Sets the length in bytes of the linked resource
pub fn with_link_length(link: Link, length: Int) -> Link {
  Link(..link, length: Some(length))
}

/// Creates a base category with just the term
pub fn category(term: String) -> Category {
  Category(term: term, scheme: None, label: None)
}

/// Sets the categorization scheme URI for the category
pub fn with_category_scheme(category: Category, scheme: String) -> Category {
  Category(..category, scheme: Some(scheme))
}

/// Sets the human-readable label for the category
pub fn with_category_label(category: Category, label: String) -> Category {
  Category(..category, label: Some(label))
}

/// Creates a base person with just the name
pub fn person(name: String) -> Person {
  Person(name: name, email: None, uri: None)
}

/// Sets the email address of the person
pub fn with_person_email(person: Person, email: String) -> Person {
  Person(..person, email: Some(email))
}

/// Sets the URI associated with the person
pub fn with_person_uri(person: Person, uri: String) -> Person {
  Person(..person, uri: Some(uri))
}

/// Creates a base Atom feed with required fields
pub fn feed(id: String, title: Text, updated: Timestamp) -> AtomFeed {
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

/// Creates a base Atom entry with required fields
pub fn entry(id: String, title: Text, updated: Timestamp) -> AtomEntry {
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

/// Sets the unique identifier of the entry
pub fn with_entry_id(entry: AtomEntry, id: String) -> AtomEntry {
  AtomEntry(..entry, id: id)
}

/// Sets the title of the entry
pub fn with_entry_title(entry: AtomEntry, title: Text) -> AtomEntry {
  AtomEntry(..entry, title: title)
}

/// Sets the last updated timestamp of the entry
pub fn with_entry_updated(entry: AtomEntry, updated: Timestamp) -> AtomEntry {
  AtomEntry(..entry, updated: updated)
}

/// Adds a list of authors to the entry
pub fn with_entry_authors(entry: AtomEntry, authors: List(Person)) -> AtomEntry {
  AtomEntry(..entry, authors: list.flatten([entry.authors, authors]))
}

/// Sets the content of the entry
pub fn with_entry_content(entry: AtomEntry, content: Text) -> AtomEntry {
  AtomEntry(..entry, content: Some(content))
}

/// Sets the link of the entry
pub fn with_entry_link(entry: AtomEntry, link: Link) -> AtomEntry {
  AtomEntry(..entry, link: Some(link))
}

/// Sets the summary of the entry
pub fn with_entry_summary(entry: AtomEntry, summary: Text) -> AtomEntry {
  AtomEntry(..entry, summary: Some(summary))
}

/// Adds a list of categories to the entry
pub fn with_entry_categories(
  entry: AtomEntry,
  categories: List(Category),
) -> AtomEntry {
  AtomEntry(..entry, categories: list.flatten([entry.categories, categories]))
}

/// Adds a list of contributors to the entry
pub fn with_entry_contributors(
  entry: AtomEntry,
  contributors: List(Person),
) -> AtomEntry {
  AtomEntry(
    ..entry,
    contributors: list.flatten([entry.contributors, contributors]),
  )
}

/// Sets the publication date of the entry
pub fn with_entry_published(entry: AtomEntry, published: Timestamp) -> AtomEntry {
  AtomEntry(..entry, published: Some(published))
}

/// Sets the rights information of the entry
pub fn with_entry_rights(entry: AtomEntry, rights: Text) -> AtomEntry {
  AtomEntry(..entry, rights: Some(rights))
}

/// Sets the source feed of the entry
pub fn with_entry_source(entry: AtomEntry, source: Source) -> AtomEntry {
  AtomEntry(..entry, source: Some(source))
}

/// Adds an author to the feed
pub fn with_feed_author(feed: AtomFeed, author: Person) -> AtomFeed {
  AtomFeed(..feed, authors: [author, ..feed.authors])
}

/// Adds a list of authors to the feed
pub fn with_feed_authors(feed: AtomFeed, authors: List(Person)) -> AtomFeed {
  AtomFeed(..feed, authors: list.flatten([feed.authors, authors]))
}

/// Sets the link of the feed
pub fn with_feed_link(feed: AtomFeed, link: Link) -> AtomFeed {
  AtomFeed(..feed, link: Some(link))
}

/// Adds a category to the feed
pub fn with_feed_category(feed: AtomFeed, category: Category) -> AtomFeed {
  AtomFeed(..feed, categories: [category, ..feed.categories])
}

/// Adds a list of categories to the feed
pub fn with_feed_categories(
  feed: AtomFeed,
  categories: List(Category),
) -> AtomFeed {
  AtomFeed(..feed, categories: list.flatten([feed.categories, categories]))
}

/// Adds a contributor to the feed
pub fn with_feed_contributor(feed: AtomFeed, contributor: Person) -> AtomFeed {
  AtomFeed(..feed, contributors: [contributor, ..feed.contributors])
}

/// Adds a list of contributors to the feed
pub fn with_feed_contributors(
  feed: AtomFeed,
  contributors: List(Person),
) -> AtomFeed {
  AtomFeed(
    ..feed,
    contributors: list.flatten([feed.contributors, contributors]),
  )
}

/// Sets the generator of the feed
pub fn with_feed_generator(feed: AtomFeed, generator: Generator) -> AtomFeed {
  AtomFeed(..feed, generator: Some(generator))
}

/// Sets the icon URL of the feed
pub fn with_feed_icon(feed: AtomFeed, icon: String) -> AtomFeed {
  AtomFeed(..feed, icon: Some(icon))
}

/// Sets the logo URL of the feed
pub fn with_feed_logo(feed: AtomFeed, logo: String) -> AtomFeed {
  AtomFeed(..feed, logo: Some(logo))
}

/// Sets the rights information of the feed
pub fn with_feed_rights(feed: AtomFeed, rights: Text) -> AtomFeed {
  AtomFeed(..feed, rights: Some(rights))
}

/// Sets the subtitle of the feed
pub fn with_feed_subtitle(feed: AtomFeed, subtitle: String) -> AtomFeed {
  AtomFeed(..feed, subtitle: Some(subtitle))
}

/// Adds an entry to the feed
pub fn with_feed_entry(feed: AtomFeed, entry: AtomEntry) -> AtomFeed {
  AtomFeed(..feed, entries: [entry, ..feed.entries])
}

/// Adds a list of entries to the feed
pub fn with_feed_entries(feed: AtomFeed, entries: List(AtomEntry)) -> AtomFeed {
  AtomFeed(..feed, entries: list.flatten([feed.entries, entries]))
}

// Types ----------------------------------------------------------------------

/// An Atom 1.0 spec compliant feed
pub type AtomFeed {
  AtomFeed(
    /// The unique identifier of the feed
    id: String,
    /// The title of the feed
    title: Text,
    /// The last time the feed was updated
    updated: Timestamp,
    /// A list of authors of the feed
    authors: List(Person),
    /// An optional link associated with the feed
    link: Option(Link),
    /// A list of categories for the feed
    categories: List(Category),
    /// A list of contributors to the feed
    contributors: List(Person),
    /// The generator program of the feed
    generator: Option(Generator),
    /// A small icon URL representing the feed
    icon: Option(String),
    /// A larger logo URL representing the feed
    logo: Option(String),
    /// Rights information for the feed
    rights: Option(Text),
    /// A subtitle or tagline for the feed
    subtitle: Option(String),
    /// A list of entries in the feed
    entries: List(AtomEntry),
  )
}

/// A person associated with a feed or entry (author or contributor)
pub type Person {
  Person(
    /// The name of the person
    name: String,
    /// An optional email address of the person
    email: Option(String),
    /// An optional URI associated with the person
    uri: Option(String),
  )
}

/// Generator information for the feed
pub type Generator {
  Generator(
    /// An optional URI for the generator
    uri: Option(String),
    /// An optional version of the generator
    version: Option(String),
  )
}

/// A link element in the feed or entry
pub type Link {
  Link(
    /// The URI of the link
    href: String,
    /// The relationship type (e.g., "alternate", "self", "enclosure")
    rel: Option(String),
    /// The MIME type of the linked resource
    content_type: Option(String),
    /// The language of the linked resource
    hreflang: Option(String),
    /// A human-readable title for the link
    title: Option(String),
    /// The length in bytes of the linked resource
    length: Option(Int),
  )
}

/// A category for classifying feeds or entries
pub type Category {
  Category(
    /// The category identifier
    term: String,
    /// An optional URI for the categorization scheme
    scheme: Option(String),
    /// An optional human-readable label for the category
    label: Option(String),
  )
}

/// An Atom 1.0 spec compliant entry
pub type AtomEntry {
  AtomEntry(
    /// The unique identifier of the entry
    id: String,
    /// The title of the entry
    title: Text,
    /// The last time the entry was updated
    updated: Timestamp,
    /// A list of authors of the entry
    authors: List(Person),
    /// The content of the entry
    content: Option(Text),
    /// An optional link associated with the entry
    link: Option(Link),
    /// A summary of the entry
    summary: Option(Text),
    /// A list of categories for the entry
    categories: List(Category),
    /// A list of contributors to the entry
    contributors: List(Person),
    /// The original publication date of the entry
    published: Option(Timestamp),
    /// Rights information for the entry
    rights: Option(Text),
    /// The source feed if the entry was copied from another feed
    source: Option(Source),
  )
}

/// Text content that can be plain text, HTML, or XHTML
pub type Text {
  /// Plain text content
  PlainText(value: String)
  /// HTML content
  Html(value: String)
  /// XHTML content
  XHtml(value: String)
}

/// Source information for an entry copied from another feed
pub type Source {
  Source(
    /// The unique identifier of the source feed
    id: String,
    /// The title of the source feed
    title: String,
    /// The last time the source feed was updated
    updated: Timestamp,
  )
}
