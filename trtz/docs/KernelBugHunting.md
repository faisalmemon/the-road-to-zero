# Kernel Bug Hunting

It is generally the case that the barriers to finding and exploiting are getting higher.  But there is good news also.
In this chapter we describe how to use an automated approach to finding vulnerabilities in the XNU kernel.

## Basic Concepts

The GitHub site provides a service which statically analyses code for known coding errors and bad practices, security being
a subset of such analysis rules.  The underlying tool chain, called CodeQL, provides the mechanism where a structured rule
can be used to parse the syntax tree of a compiled program.

In this chapter we show how the XNU kernel and be compiled, and from this a database can be constructed.  Then CodeQL queries
can be run against it to automatically find bad practices and security sensitive issues.

## Sample Visualization

Before we get into the details of what we are setting up, let's jump into what we can expect to end up with.
We will go into the details of setup and configuration in a later section, but it makes more sense to first understand
the approach and benefits we shall gain from using CodeQL.

We can either run a specific rule, to find code references that match the rule, or we can run a batch of queries
given a set of rules.

### Specific rule approach

We start with checking for code which has an if-clause but then has an empty block of C++ code that is invoked when
the condition matches.  For example:
```c
if (ret == ERROR_NOT_ALLOWED)
{
// No code in here.  e.g. missing error handling code?
}
```

When looking for such data, our overall Visual Studio Code setup will look like:

![OverallExample](overallExample.png)

The workflow is to select a snippet to query for.  Here we picked one that looks for empty blocks:

![PickASnippet](pickingASnippet.png)

Then we right-click to get the context menu and select the "Run Query" option:

![RightClickRunQuery](rightClickRunQuery.png)

Lastly, we inspect the matched source code files:

![InspectSourceFile](matchInSourceCode.png)

### Batch Queries

If we update the workspace file `vscode-codeql-starter.code-workspace` to first have increased querying capability:
```
 "settings": {
    "omnisharp.autoStart": false,
    "codeQL.runningQueries.maxQueries": 128
  }
```

then we can Right Click on a directory level to run all the `.ql` files underneath.  We can for example select the
`vscode-codeql-starter/ql/cpp/ql/src/Security/CWE` directory and then run all the Security-related queries.  This takes
a few minutes on a powerful Mac.  But it is still quicker than a manual inspection! 

Unfortunately, as of `xnu-8792.61.2` there are no matches for any of the 64 rules underneath `Security/CWE`.

This is probably because Apple, or perhaps a third-party collaborator, has been running CodeQL as part
of a Continuous Integration pipeline.

Nevertheless, as we have shown, an empty block in the code might allude to a missing error handling case.  So the
less interesting rules might turn up security vulnerabilities or give us ideas for how to write a new rule.  These
private rules would not be part of the CI test set that Apple run.  So there is a real opportunity to find new
weaknesses or helpful bugs.

## Outline of Approach

We need a number of things setup before we can proceed.  Here we've made some assumptions and choices on configuration and setup which we hope can be adapted for your requirements and preferences.

We assume our bug hunting is done with:

- Apple Silicon ARM architecture
- Visual Studio is our editor for querying for, and viewing results
- XNU Kernel `xnu-8792.61.2` is being studied

The top level steps are:

1. Setup for Xcode on Mac on Apple Silicon.
1. Install the Kernel Development Kit.
1. Download and compile the XNU kernel source.
1. Setup and install Visual Studio Code, and the QL plug-in.
1. Install CodeQL helper snippets.
1. Generate XNU CodeQL database.
1. Import snippets into Visual Studio
1. Import XNU CodeQL database.
1. Run CodeQL queries to find weaknesses and vulnerabilities. 

## Software Requirements

We need the following software:

| Name | Purpose | Location |
| -- | -- | -- |
| Xcode | Compiler | Mac App Store |
| Kernel Development Kit (13.1 22C65) | XNU Dependency for compilation | [Apple Download Site](https://developer.apple.com/download/all/) |
| `xnu-build` | Build Scripts for XNU | [pwn0rz/xnu-build](https://github.com/pwn0rz/xnu-build) |
| Visual Studio Code | Editor/Viewer | [Microsoft VS Code](https://code.visualstudio.com) |
| CodeQL plug-in | Integration for CodeQL into VS Code | From `Extensions` in VS Code; search for `CodeQL` |
| CodeQL snippets | Pre-made queries to run | [Starter Workspace](https://github.com/github/vscode-codeql-starter/) |


