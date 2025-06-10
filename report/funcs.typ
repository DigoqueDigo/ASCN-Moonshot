#import "@preview/note-me:0.3.0": admonition

#let code_block(
  code: []
) = block(
    width: 100%,
    fill: luma(230),
    inset: 10pt,
    radius: 8pt,
    stroke: luma(0),
    code,
)

#let code_grid(
  code1: [],
  code2: []
) = grid(
    columns: 2,
    gutter: 5mm,
    code1,
    code2,
)

#let question(
  title: [],
  question: []
) = admonition(
  icon-path: "icons/report.svg",
  title: title,
  color: color.maroon,
  foreground-color: color.black,
  background-color: color.luma(230),
  emph(question)
)

#let answer(
  answer: []
) = admonition(
  icon-path: "icons/light-bulb.svg",
  title: "Resposta",
  color: color.olive,
  foreground-color: color.black,
  background-color: color.luma(230),
  emph(answer)
)

#let image_block(
  imagem: image,
  caption: []
) = figure(
    block(
      stroke: luma(0),
      inset: 1pt,
      radius: 2pt,
      imagem
    ),
    caption: caption,
)
