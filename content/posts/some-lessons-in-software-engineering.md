---
title: "Some lessons in software engineering"
date: 2024-02-03
tags: ["software engineering", "lessons"]
draft: false
---

There are a few lessons that have stood out to me, over the past few years of working as a software engineer.

## Learn about the problem
Learn *everything* about the problem you're trying to solve, or the existing solution, before you start building the new solution. 

Learning everything about the existing system in detail would often have saved me a lot of time when working on the implementation of the new system. 

## Deploy early
Deploy early when working on a new project. 

Early deployment often helps to uncover misunderstood requirements or implicit knowledge/requirements for the project. 
If you deploy late, these things may require major architectural changes because they weren't discovered earlier.

## Document the existing solution
Document the existing solution and why things worked the way they did. 

This is a great way to uncover hidden domain knowledge that may be obvious to users but not to you, or to discover new opportunities for improvement ("why was this done again? - it's always been done that way.").

## Choose boring technology (usually)
Don't use new technology in combination with a new problem to solve. 

Either choose a new problem you haven't solved before *or* choose a new technology to solve a problem you know well. Never in combination.