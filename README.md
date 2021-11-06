# The Road to Zero

This book explains how to develop your own zero day vulnerabilities for iOS.

The content is in the early planning stage.  I welcome criticism and feedback with that in mind.

Language | Link
-- | --
English | https://faisalmemon.github.io/the-road-to-zero/

The purpose of this repository is to provide the source code, and other resources, supporting the "The Road to Zero" book.

## Why write this book?

When I look at learning paths in other disciplines, there is a low friction path to develop skills, and practice one's learning.  For example, there is a clear path to learn iOS programming.  Learning Android has even less friction.  I remember this clearly when I was part of a huge team facing redundancy with a seemingly obselete knowledge base (SymbianOS).  The friction on the iOS side was getting a Mac and an iDevice.  It turned out that the SymbianOS experience was valuable because I wrote a book to help engineers understand and resolve crash dumps seen on iOS using OS level insights and skills I already had.

I am now in a situation where I am studying an adjacent skill but there are significant knowledge and cost barriers.  That is, exploring zero day vulnerabilities in iOS. It seems that there is a gap between simple reverse engineering tutorials and crack-me challenges, and those challenges faced on a secure operating system such as iOS.  

Given that iOS security research is valuable, the assumption is that you are using the IDA Pro decompiler, or you are using the Correllium system to develop your security research.  These companies are entitled to price their services accordingly.  The gap is that there are researchers looking to break into this world, and make a meaningful contribution with a modest outlay.  It's not just the price, but the price together with the risk that is the barrier.  When I purchased a Mac and an iPhone, I was already happy with what I had and wasn't sure if the market would take me on as a hobbyist to undertake commercial work in iOS.

## It's already documented right?

Many things are documented, but the valuable piece is not documented.

I have sincere appreciation for those who have written up the basic ideas behind vulnerabilities, and have provided crack-me challenges.  At the opposite end of things, there are some excellent write ups of past vulnerabilities;  Google project Zero is leading the way here.  Their insights amount to digital magic!

There is scarce little in the middle.  The OS internals book series by J. Levin are a huge milestone in explaining the Darwin based Operating Systems underpinning our iDevices.

To draw an analogy, Google have shown what fish are out there to be catched, Levin has shown where the fish are, but how do you actually catch a fish?  This book explains that piece.

# Project Details

## Current Status

As of 31st Oct 2021, the project status is:
- I am converting the book from being pandoc/markdown based to being MkDocs based.

So no new book content for a while until build processing is resolved.

## Timeline

I can't guarantee time, I can't guarantee speed, but this is what I know.  I think I can do 0.1 % of the book each day, with a few stretches of full focus, I think my target is to complete the book is March 2023.

## Directory Structure

Directory | Purpose
----------| -------
external | Downloaded resources
topics | Topic specific writing
examples | Examples
screenshots | Screenshots
trtz | Source code of book

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
- Brew Package Manager
- [MkDocs Software Package](https://www.mkdocs.org/getting-started/)
- [Material Design MkDocs plug-in](https://squidfunk.github.io/mkdocs-material/getting-started/)
- Class dump
- Draw.io.app for diagrams

#### Class Dump

For analysing binaries I used `class-dump`.  Whilst previously this was available from Brew, it seems now you have to directly download it.

[Download class-dump](http://stevenygard.com/projects/class-dump/)

#### Draw.io.app

The diagram drawing app is installable from 
https://github.com/jgraph/drawio-desktop

### Recommended Software

Package | Purpose | Installation
--|--|--
Atom|Edits and understands markdown and can preview render it | `brew install --cask atom`
BibDesk | Eases the definition of Citations for the Biliography | `brew install --cask bibdesk`

## Essential Mac Configuration

#### Screenshots

I have discovered the standard screenshot on Mac only does low resolution (screen resolution) images.  Print books need to have higher resolution.

I saw an answer at: https://apple.stackexchange.com/a/110206

I need to experiment in this area.  Maybe putting my screen in large scale mode will give me screenshots with effectively a higher ppi when shrunk down for print.

## Build System

The book is built using the MkDocs workflow.  It is published via the GitHub pages workflow in MkDocs.

