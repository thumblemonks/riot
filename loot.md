---
title: Riot loot
description: Recipes for common situations encountered when testing with Riot
keywords: ruby, testing, framework, riot, loot, recipes, cookbook
layout: default
---

## Loot or Recipes or Cookbook

I wanted to call this section "Booty".

### Adding context helpers methods

### Lazy-loaded factory-ish helpers

    helper(:foo) { @foo ||= Foo.new }
