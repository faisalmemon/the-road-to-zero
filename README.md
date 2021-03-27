# The Road to Zero

This book explains how to develop your own zero day vulnerabilities for iOS.

The content is in the early planning stage.  I welcome criticism and feedback with that in mind.

Language | Link
-- | --
English | https://faisalmemon.github.io/the-road-to-zero/en
Chinese | https://faisalmemon.github.io/the-road-to-zero/zh

The purpose of this repository is to provide the source code, and other resources, supporting the "The Road to Zero" book.

## Why write this book?

When I look at learning paths in other disciplines, there is a low friction path to develop skills, and practice one's learning.  For example, there is a clear path to learn iOS programming.  Learning Android has even less friction.  I remember this clearly when I was part of a huge team facing redundancy with a seemingly obselete knowledge base (SymbianOS).  The friction on the iOS side was getting a Mac and an iDevice.  It turned out that the SymbianOS experience was valuable because I wrote a book to help engineers understand and resolve crash dumps seen on iOS using OS level insights and skills I already had.

I am now in a situation where I am studying an adjacent skill but there are significant knowledge and cost barriers.  That is, exploring zero day vulnerabilities in iOS. It seems that there is a gap between simple reverse engineering tutorials and crack-me challenges, and those challenges faced on a secure operating system such as iOS.  

Given that iOS security research is valuable, the assumption is that you are using the IDA Pro decompiler, or you are using the Correllium system to develop your security research.  These companies are entitled to price their services accordingly.  The gap is that there are researchers looking to break into this world, and make a meaningful contribution with a modest outlay.  It's not just the price, but the price together with the risk that is the barrier.  When I purchased a Mac and an iPhone, I was already happy with what I had and wasn't sure if the market would take me on as a hobbyist to undertake commericial work in iOS.

## It's already documented right?

Many things are documented, but the valuable piece is not documented.

I have sincere appreciation for those who have written up the basic ideas behind vulnerabilities, and have provided crack-me challenges.  At the opposite end of things, there are some excellent write ups of past vulnerabilities;  Google project Zero is leading the way here.  There insights amount to digital magic!

There is scarce little in the middle.  The OS internals book series by J. Levin are a huge milestone in explaining the Darwin based Operating Systems underpinning our iDevices.

To draw an analogy, Google have shown what fish are out there to be catched, Levin has shown where the fish are, but how do you actually catch a fish?  This book explains that piece.

# Project Details

## Current Status

As of 27th March 2021, the project status is:
- just started,
- building the book outline and scripting.

## Directory Structure

Directory | Purpose
----------| -------
external | Downloaded resources
topics | Topic specific writing
source | Parent directory of compilable source code
markdown | Markdown files for the body text of the book
examples | Examples
screenshots | Screenshots

## Branch Policy

The software configuration management plan (SCM plan) is very simple.
- All development is done on the master branch.
- Feature work is done on a branch.
- Notable versions of the software are tracked by [Release History](./release/releaseHistory.md)

## Authoring Methodology

See https://github.com/faisalmemon/ios-crash-dump-analysis-book#authoring-methodology

## Supporting software

### Essential Software

You need:
- Brew Package manager
- Various Brew packages
- Latex packages
- Class dump

#### Brew Software

I used the Brew package manager on MacOS and used the Brew packages:

Brew Package | Purpose
--|--
`pandoc` | Document translator to get from .markdown format to other formats
`pandoc-citeproc` | Biliography Citation Helper for pandoc

#### Latex Support

Latex support appears not to be available directly in brew so I used the recommended [MacTex](https://www.tug.org/mactex/) and this was installed via a brew cask install
`brew cask install mactex`

#### Class Dump

For analysing binaries I used `class-dump`.  Whilst previously this was available from Brew, it seems now you have to directly download it.

[Download class-dump](http://stevenygard.com/projects/class-dump/)


### Recommended Software

Package | Purpose
--|--
Atom|Edits and understands markdown and can preview render it
BibDesk | Eases the definition of Citations for the Biliography

## Essential Mac Configuration

#### Screenshots

I have discovered the standard screenshot on Mac only does low resolution (screen resolution) images.  Print books need to have higher resolution.

I saw an answer at: https://apple.stackexchange.com/a/110206

I need to experiment in this area.  Maybe putting my screen in large scale mode will give me screenshots with effectively a higher ppi when shrunk down for print.

## Build System

The book is built for English using `buildBook.sh`.  Use `buildBook.sh -l zh` to build the Chinese edition.

The build outputs are:

File | Purpose
--|--
`foo.html` | Intermediate used for GitHub Pages documentation
`boo.pdf` | For the Hard Copy Paper Edition
`foo.docx` | For further conversion into EPUB, and internally for spelling and grammar checking
`foo.epub` | For E-book readers (Apple and Amazon) directly from pandoc
`docs/*` | Final destination for GitHub Pages documentation

The output are `foo.*` and `boo.*` files locally for ease of inspection.  They are ignored by version control.

For github pages, the GitHub documentation facility, the HTML documentation and supporting resources is copied into the `docs/<language-id>` directory and then they are checked in (the branch is required to be master).

The build system also checks for uses of "you" - they should be "we" in all cases apart from the Introduction.

The build system only picks up new trademarks on a second run of the book building script due to it relying on a built index from the prior run.

The build system has one hardcode; the page number that the Disclaimer chapter starts on is hardcoded because it is based upon the number of pages used up by the automatically generated table of contents.
