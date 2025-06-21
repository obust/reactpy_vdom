# <img src="https://raw.githubusercontent.com/reactive-python/reactpy/main/branding/svg/reactpy-logo-square.svg" align="left" height="45"/> ReactPy VDOM



[ReactPy](https://reactpy.dev/) is a library for building user interfaces in Python without Javascript. ReactPy interfaces are made from components that look and behave similar to those found in [ReactJS](https://reactjs.org/). Designed with simplicity in mind, ReactPy can be used by those without web development experience while also being powerful enough to grow with your ambitions.

`reactpy_vdom` is a VDOM library written in Mojo for ReactPy.


# Usage

To get a rough idea of how to write apps in ReactPy, take a look at this tiny _Hello World_ application.

```python
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
