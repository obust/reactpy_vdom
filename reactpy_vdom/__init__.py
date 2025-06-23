from typing import overload


from ._vdom import create_element, Element, diff, apply


@overload
def el(tag: str, attributes: dict, children: list[Element], key: str | None = None) -> Element:
    ...

@overload
def el(tag: str, attributes: dict, text: str, key: str | None = None) -> Element:
    ...

def el(tag: str, attributes: dict, x: list[Element] | str, key: str | None = None) -> Element:
    if isinstance(x, str):
        return create_element(tag, attributes, {"children": [], "text": x, "key": key})
    else:
        return create_element(tag, attributes, {"children": x, "text": None, "key": key})


__all__ = ["el", "diff", "apply"]
