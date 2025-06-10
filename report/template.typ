#let project(
  title: "",
  authors: (),
  date: none,
  logo: none,
  body,
) = {
 
  set text(
    font: "Noto Sans Bamum",
    lang: "pt",
    region: "pt"
  )

  set page(
    numbering: "1",
    number-align: center)
  
  show math.equation: set text(
    font: "Fira Math",
    size: 0.9em
  )

  show table: set text(
    font: "Fira Sans",
    size: 0.9em
  )

  // Title page.
  // The page can contain a logo if you pass one with `logo: "logo.png"`.
  v(0.6fr)
  if logo != none {
    align(right, image(logo, width: 26%))
  }
  v(9.6fr)

  text(1.1em, date)
  v(1.2em, weak: true)
  text(2em, weight: 700, title)

  // Author information.
  pad(
    top: 0.7em,
    right: 20%,
    grid(
      // columns: (1fr,) * calc.min(3, authors.len()),
      columns: (1fr),
      rows: (auto, auto),
      gutter: 1em,
      ..authors.map(author => align(start, strong(author))),
    ),
  )

  v(2.4fr)
  pagebreak()

  outline(
    title: "Índice",
    depth: 3,
  )

  pagebreak()

  // Main body.
  set par(justify: true)

  show heading.where(level: 1): it => {
    pagebreak(weak: true);
    it;
    v(0.5em);
  }

  body
}