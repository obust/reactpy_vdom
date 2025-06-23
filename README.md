# <img src="https://raw.githubusercontent.com/reactive-python/reactpy/main/branding/svg/reactpy-logo-square.svg" align="left" height="45"/> ReactPy VDOM



[ReactPy](https://reactpy.dev/) is a library for building user interfaces in Python without Javascript. ReactPy interfaces are made from components that look and behave similar to those found in [ReactJS](https://reactjs.org/). Designed with simplicity in mind, ReactPy can be used by those without web development experience while also being powerful enough to grow with your ambitions.

`reactpy_vdom` is a VDOM library written in Mojo for ReactPy.

# Build

Build the `reactpy_vdom/_vdom.so` python extension

`pixi run build`

# Usage

To get a rough idea of how to write apps in ReactPy, take a look at this tiny _Hello World_ application.


## Mojo

```mojo
from reactpy_vdom import Element, diff

src = Element("ul", {"class": "foo"}, [
    Element("li", {}, "dog"),
    Element("li", {}, "cat"),
])
print(String(src))
# <ul class=foo><li>dog</li><li>cat</li></ul>

dst = Element("ul", {"class": "bar"}, [
    Element("li", {}, "dog"),
    Element("li", {}, "mouse"),
])
print(String(dst))
# <ul class=bar><li>dog</li><li>mouse</li></ul>

patches = diff(src, dst)
print(String(patches))
# [
#   Patch(action=update, path=[], value=<ul class=bar></ul>),
#   Patch(action=update, path=[1], value=<li>mouse</li>)
# ]

patched = patches(src)
print(String(patched))
# <ul class=bar><li>dog</li><li>mouse</li></ul>
```

## Python

```python
from reactpy_vdom import el, diff, apply

src = element("ul", {"class": "foo"}, [
    element("li", {}, "dog"),
    element("li", {}, "cat"),
])
print(src)
# Element(tag=ul, attributes={'class': 'foo'}, children=[
#   Element(tag=li, attributes={}, children=[], text=Optional('dog'), key=Optional(None)),
#   Element(tag=li, attributes={}, children=[], text=Optional('cat'), key=Optional(None))
# ], text=Optional(None), key=Optional(None))

dst = element("ul", {"class": "bar"}, [
    element("li", {}, "dog"),
    element("li", {}, "mouse"),
])
print(dst)
# Element(tag=ul, attributes={'class': 'bar'}, children=[
#   Element(tag=li, attributes={}, children=[], text=Optional('dog'), key=Optional(None)),
#   Element(tag=li, attributes={}, children=[], text=Optional('mouse'), key=Optional(None))
# ], text=Optional(None), key=Optional(None))

patches = diff(src, dst)
print(patches)
# ListPatch([
#   Patch(action=update, path=[], value=<ul class=bar></ul>),
#   Patch(action=update, path=[1], value=<li>mouse</li>)
# ])

patched = apply(src, patches, True)
print(patched)
# Element(tag=ul, attributes={'class': 'bar'}, children=[
#   Element(tag=li, attributes={}, children=[], text=Optional('dog'), key=Optional(None)),
#   Element(tag=li, attributes={}, children=[], text=Optional('mouse'), key=Optional(None))
# ], text=Optional(None), key=Optional(None))
```
