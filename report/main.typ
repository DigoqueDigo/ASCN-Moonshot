#import "template.typ": *
#show link: underline
#set text(lang:"pt")

#show: project.with(
  title: "Moonshot - Provisioning e Deployment \nGrupo 18",
  authors: (
    "Diogo Marques (pg55931)",
    "Guilherme Rio (pg57875)",
    "Ivan Ribeiro (pg55950)",
    "Luís Ribeiro (pg55976)",
    "Rui Cerqueira (pg57902)",
  ),
  date: "Janeiro 5, 2025",
)

#set heading(numbering: "1.1)")

#include ("chapters/intro.typ")
#include ("chapters/moonshot.typ")
#include ("chapters/auto_deploy.typ")
#include ("chapters/question.typ")
#include ("chapters/monitoring.typ")
#include ("chapters/tests.typ")
#include ("chapters/conclusion.typ")