# Kernel Bug Hunting

It is generally the case that the barriers to finding and exploiting are getting higher.  But there is good news also.
In this chapter we describe how to use an automated approach to finding vulnerabilities in the XNU kernel.

## Outline of Approach

We need a number of things setup before we can proceed.  Here we've made some assumptions and choices on configuration and setup which we hope can be adapted for your requirements and preferences.

We assume our bug hunting is done with:
- Apple Silicon ARM architecture
- Visual Studio is our editor for querying for, and viewing results
- XNU Kernel `xnu-8792.61.2` is being studied

1. Setup for Xcode on Mac on Apple Silicon.
1. Install the Kernel Development Kit.
1. Download and compile the XNU kernel source.
1. Setup and install Visual Studio Code, and the QL plug-in.
1. Install CodeQL helper snippets.
1. Generate XNU CodeQL database.
1. Import snippets into Visual Studio
1. Import XNU CodeQL database.
1. Run CodeQL queries to find weaknesses and vulnerabilities. 

## Sample Visualization

Before we get into the details of what we are setting up, let's jump into what we can expect to end up with.

![OverallExample](./overallExample.png)

The workflow is to select a snippet to query for.  Here we picked one that looks for empty blocks:

![PickASnippet](./pickingASnippet.png)

Then we right-click to get the context menu and select the "Run Query" option.

![RightClickRunQuery](./rightClickRunQuery.png)

Lastly, we inspect the matched source code files.

![InspectSourceFile](./matchInSourceCode.png)

## Collect needed software

We need the following software:

| Name | Purpose | Location |
| -- | -- | -- |
| Xcode | Compiler | Mac App Store |
| Kernel Development Kit (13.1 22C65) | XNU Dependency for compilation | [Apple Download Site](https://developer.apple.com/download/all/) |
| `xnu-build` | Build Scripts for XNU | [pwn0rz/xnu-build](https://github.com/pwn0rz/xnu-build) |
| Visual Studio Code | Editor/Viewer | [Microsoft VS Code](https://code.visualstudio.com) |
| CodeQL plug-in | Integration for CodeQL into VS Code | `Extensions` in VS Code; `CodeQL` |
| CodeQL snippets | Pre-made queries to run | [Starter Workspace](https://github.com/github/vscode-codeql-starter/) |


