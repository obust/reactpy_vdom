from typing import overload


from ._vdom import Element, ListPatch, create_element, diff, apply as _apply


@overload
def element(tag: str, attributes: dict, children: list[Element], key: str | None = None) -> Element:
    ...

@overload
def element(tag: str, attributes: dict, text: str, key: str | None = None) -> Element:
    ...

def element(tag: str, attributes: dict, x: list[Element] | str, key: str | None = None) -> Element:
    if isinstance(x, str):
        return create_element(tag, attributes, {"children": [], "text": x, "key": key})
    else:
        return create_element(tag, attributes, {"children": x, "text": None, "key": key})


def apply(element: Element, patches: ListPatch, inplace: bool = True) -> Element:
    return _apply(element, patches, inplace)


__all__ = ["element", "diff", "apply"]
