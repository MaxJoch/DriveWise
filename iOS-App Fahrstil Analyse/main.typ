#import "@preview/clean-dhbw:0.3.1": *
#import "glossary.typ": glossary-entries

#let appendix-content = [
  #include "sections/appendix/Anhang.typ"
]

#show: clean-dhbw.with(
  title: "Entwicklung einer App zur Analyse des Fahrverhaltens von PKW-Fahrern",
  authors: (
    (name: "Joscha Heid", student-id: "7654321", 
     course: "TINF23B6", course-of-studies: "Informatik", 
    ),
    (name: "Max Joch", student-id: "2298512", 
     course: "TINF23B6", course-of-studies: "Informatik", 
    ),
  ),
  city: "Karlsruhe",
  at-university: true, 
  type-of-thesis: "Studienarbeit",
  show-confidentiality-statement: true, // optional, if company desires so
  show-declaration-of-authorship: true,
  bibliography: bibliography("sources.bib"),
  appendix: appendix-content, 
  date: datetime.today(),
  glossary: glossary-entries,          // glossary terms from external file (see below)
  language: "de",                      // en, de
  supervisor: (
    university: "Prof. Dr. Roland Schätzle"
  ),
  university: "Duale Hochschule Baden-Württemberg",
  university-location: "Karlsruhe",
  university-short: "DHBW",
  // for more options check the package documentation (https://typst.app/universe/package/clean-dhbw)

)


// introduction
#include "sections/introduction/Einleitung.typ"

// basics
#include "sections/basics/NamensgebungUndLogoFindung.typ"
#include "sections/basics/FahrverhaltenUndAblenkung.typ"
#include "sections/basics/SmatphoneSensorik.typ"
#include "sections/basics/IOSAPPEntwicklung.typ"
#include "sections/basics/Gamification.typ"
#include "sections/basics/UserExperience.typ"
#include "sections/basics/Projektmanagement.typ"

// implementation
#include "sections/implementation/Umsetzung.typ"
#include "sections/conclusion/Schluss.typ"
