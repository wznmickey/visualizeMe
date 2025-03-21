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
  - Team Members & responsibilities
    - Zining Wang: Full software development

  - Used Language: elm-lang

  - Source Code: https://github.com/wznmickey/visualizeMe

  - Online Demo: https://wznmickey.github.io/visualizeMe/

  - Data Source (Current): https://www.kaggle.com/datasets/michaelbryantds/cpu-and-gpu-product-data
][#grid(columns: 1, align: center)[#image("tempResult.png") ][
    Current Appearance]]

== Motivation

Nowadays, technology is developing rapidly and the price is higher and higher if you want to get the best performance. While there are many tools showing the performance of the hardware like CPUs, the top performance is not always the best choice for everyone due to the price. Buying a suitable hardware is not focusing on one aspect but the overall balance between performance, power, price and so on. Different people may have different performance requirements preference on maybe single-core performance or multi-core performance. For GPU, one may want high encoding ability while another may want high bandwidth.
Besides, in some other areas like LLM, when we want to choose a model, we would need to balance the speed, size, and accuracy of the model. And as the LLM is under the development, it is unfair to compare todays LLM with the model developed one year ago. So I want to develop a tool that could let people choose the measurement dimensions they care about and compare them in a 2D and 3D plot.

= Develop Process

== Developed Part
#grid(columns: 2)[
  To make the tool acessible to more people, I want to develop a web-based tool and I use elm-lang which is a functional programming language that could be compiled into a static HTML file with JavaScript containing SVG images which could be easily hosted on GitHub Pages service. Now I have developed the basic structure of the tool. In the right image, the x axis is the process Size in Nanomeeters, the y axis is the TDP power and the area of each point is the die size. The user could also zoom in and zoom out to see the details of the data.
][#grid(columns: 1, align: center)[#image("tempResult.png") ][
    Current Appearance]]

== Developing Plan
I plan to do the following things later:

1. Support the feature that the user could choose how x-axis, y-axis, area are bind to the data and the user could filter some data out.
2. Support the feature that the user could upload any data and visualize it.
3. Support the feature that the user could choose the 3D mode and the user could choose one more axis and rotate the 3D plot. (If time allows)

#focus-slide[
  Thanks for listening

  https://wznmickey.github.io/visualizeMe/
]

= Appendix

== project Source Code
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


== slides Source Code
The typst code generating the slides.
`main.typ`
#{
  set text(size: 8pt)
  let x = read("./main.typ")
  raw(x, block: true, lang: "typ")
}
