#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.2.0": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/codly:1.0.0": *

#show: codly-init.with()
#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Visualize Me],
    subtitle: [Explore the quickly updated world],
    author: [Zining Wang \@ Northeastern University],
    date: datetime.today(),
    institution: [EECE5642 Project Proposal ],
  ),
)
#set heading(numbering: numbly("{1}.", default: "1.1"))
#title-slide()
= Outline <touying:hidden>

#outline(title: none, indent: 1em, depth: 2)
= Project Information
== Project Information
#grid(columns: 2)[
  - Team Members & contributions:
    - Zining Wang: Idea, Design, Implementation and Presentation

  - Used Language: elm-lang

  - Source Code: https://github.com/wznmickey/visualizeMe

  - Online Demo: https://wznmickey.github.io/visualizeMe/

  - Data Source:
    - https://www.kaggle.com/datasets/michaelbryantds/cpu-and-gpu-product-data
    - https://llm-stats.com/
][#grid(columns: 1, align: center)[#image("tempResult.png") ][
    Current Appearance]]

== Motivation

In today’s fast-paced technological world, advancements in hardware and artificial intelligence (AI) are occurring at breakneck speed. This creates a dilemma for consumers and professionals who seek to stay up-to-date with the best performing systems without breaking the bank. While tools for benchmarking hardware, particularly *CPUs* and *GPUs*, have become increasingly sophisticated, the problem lies in the fact that top-tier performance is not necessarily the most cost-effective solution for everyone.

When selecting hardware, it’s important to recognize that performance should not be the only consideration. Several other factors play a crucial role in choosing the right setup for a given application.
#pagebreak()
- Power Consumption: While higher performance often correlates with higher power requirements, a balance must be struck to avoid excessive *energy* costs or hardware *overheating*.

- Price: The most powerful hardware often comes with a premium *price* tag, but for many users, the best performance is not required for their daily tasks. For example, a developer or gamer may need just enough GPU power to run programs efficiently, but not necessarily the highest-end models available.

#pagebreak()
- Specific Use Case: Different use cases demand different hardware characteristics.
  - Single-core performance might be essential for applications that rely heavily on *sequential* processing (e.g., certain older games or single-threaded applications).

  - Multi-core performance is critical for tasks like *rendering*, *scientific computing*, and modern gaming where *parallel* processing is leveraged.

  - For GPUs, some users prioritize high *encoding* and *decoding* ability for video production, while others might prefer high *memory bandwidth* for tasks such as gaming, machine learning, or 3D rendering.
#pagebreak()
In addition to hardware considerations, there are also other contexts in which performance must be evaluated. For instance, in the realm of Large Language Models (LLMs) and other AI models, the user’s needs must be balanced across several dimensions. As LLMs continue to evolve, *model size*, *performance*, and processing *speed* are important factors to weigh. Some users may prioritize faster inference times, while others may be more concerned with the accuracy of the results. Additionally, some may be restricted by computational resources, thus requiring smaller models that can still offer competitive performance.

== Current Situation
Hard to filter the desired parameters.
#grid(columns: (1fr, 0.3fr, 1fr))[https://socpk.com/allperf/
  #image("socpk.png", height: 80%)][][
  https://llm-stats.com/
  #image("LLM.png")
]



= Develop Process

== Developed Part
#grid(columns: 2)[
  To make the tool acessible to more people, I want to develop a web-based tool and I use elm-lang which is a functional programming language that could be compiled into a static HTML file with JavaScript containing SVG images which could be easily hosted on GitHub Pages service.
][#grid(columns: 1, align: center)[#image("tempResult.png") ][
    Current Appearance]]

== Live Demo

https://wznmickey.github.io/visualizeMe/


1. *Zoom* in and out by pressing the button.
2. *Reset* the zoom by pressing the button.
3. Zoom by the *wheel*. (Thanks to the suggestion that using the wheel to zoom in my proposal)
4. *Move* the plot by clicking the new center.
5. *Drag* the plot to move it. (Thanks to the suggestion that removing the 十 line at the center of the screen in my proposal)
6. *Switch* on the text, size and the pareto line.
7. *Upload* the data and visualize it.
8. Change the x-axis, y-axis *text*.

== Challenge

1. Lack of *documentation* and *packages* for elm-lang. e.g. csv parsing,key binding
2. Lack of *contributor*. I work alone in this project.
3. Lack of *experience* in web frontend development. I am not familiar with tools like CSS in organizing different elements in a page.


== Current bugs & Undeveloped Part

There are some bugs in the current version:
- The text would not disappear when it is out of the diagram.
- The size of each point could not resize according to the relative size of the data.
- Text may of x-axis and y-axis may be overlapped by the data point features.
- The layer of the element to capture wheel is lower than that of the element to show the data which causes the wheel event not captured in the center.

To-do:
- Detect columns' name automatacally.
- Filter different data columns in the csv file.
- When the mouse is moved onto each point, the text of the point should be shown.
- Better design of the layout of the page.
- Use a url to import the latest online data.

#focus-slide[

  *Developed For*

  computer DIY players

  LLM local deployment users & researchers

  Any people who have many options to choose from

  https://wznmickey.github.io/visualizeMe/
]

= Appendix

== Project Source Code
`Main.elm`
#{
  set text(size: 8pt)
  let x = read("../src/Main.elm")
  raw(x, block: true, lang: "elm")
}
`Zoom.elm`
#{
  set text(size: 8pt)
  let x = read("../src/Zoom.elm")
  raw(x, block: true, lang: "elm")
}


== Slides Source Code
The typst code generating the slides.
`main.typ`
#{
  set text(size: 8pt)
  let x = read("./main.typ")
  raw(x, block: true, lang: "typ")
}
