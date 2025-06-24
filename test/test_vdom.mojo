from reactpy_vdom import Element, Patch, diff
from testing import assert_equal, assert_not_equal, assert_true, assert_raises

def test_equality():
    a = Element("div", {"a": "b"}, [Element("li", {}, "foo")])
    b = Element("div", {"a": "b"}, [Element("li", {}, "foo")])
    c = Element("div", {"a": "c"}, [Element("li", {}, "foo")])
    d = Element("div", {"a": "c"}, [Element("li", {}, "bar")])
    assert_equal(a, b)
    assert_not_equal(a, c)
    assert_not_equal(a, d)

def test_get():
    root = Element("ul", {}, [
        Element("li", {}, "foo"),
        Element("li", {}, "bar"),
    ])

    # check root
    ref root2 = root.get([])
    assert_equal(root2, root)

    # check nested
    ref foo = root.get([0])
    foo.text = Optional(String("FOO"))
    assert_equal(root.children[0].text.value(), String("FOO"))

    # check invalid path
    with assert_raises():
        _ = root.get([3])

    with assert_raises():
        _ = root.get([-3])

def test_set():
    root = Element("ul", {}, [
        Element("li", {}, "foo"),
        Element("li", {}, "bar"),
    ])

    # check nested
    root.set([1], Element("li", {}, "baz"))
    assert_equal(root.children, [
        Element("li", {}, "foo"),
        Element("li", {}, "baz"),
    ])

    # check root
    root.set([], Element("div", {}, []))
    assert_equal(root, Element("div", {}, []))


def test_insert():
    root = Element("ul", {}, [
        Element("li", {}, "foo"),
        Element("li", {}, "bar"),
    ])

    # check root (can't insert at root)
    root.insert([], Element("div", {}, []))
    assert_equal(root, Element("ul", {}, [
        Element("li", {}, "foo"),
        Element("li", {}, "bar"),
    ]))

    # check nested
    root.insert([1], Element("li", {}, "baz"))
    assert_equal(root.children, [
        Element("li", {}, "foo"),
        Element("li", {}, "baz"),
        Element("li", {}, "bar"),
    ])


def test_remove():
    root = Element("ul", {}, [
        Element("li", {}, "foo"),
        Element("li", {}, "bar"),
    ])

    # check root (can't remove at root)
    _ = root.remove([])
    assert_equal(root, Element("ul", {}, [
        Element("li", {}, "foo"),
        Element("li", {}, "bar"),
    ]))

    # check nested
    _ = root.remove([1])
    assert_equal(root.children, [
        Element("li", {}, "foo")
    ])

# fn test_json():
#     var node: Element
#     # check attributes
#     node = Element("div", {"id": "main"}, [])
#     assert_equal(node.json().to_string(), '{"tag": "div", "attributes": {"id": "main"}}')

#     # check key
#     node = Element("div", {}, [], key=Optional(String("key")))
#     assert_equal(node.json().to_string(), '{"tag": "div", "key": "key"}')

#     # check text
#     node = Element("div", {}, "text")
#     assert_equal(node.json().to_string(), '{"tag": "div", "text": "text"}')

#     # check children
#     node = Element("div", {}, [Element("span", {}, "foo")])
#     assert_equal(node.json().to_string(), '{"tag": "div", "children": [{"tag": "span", "text": "foo"}]}')

#     # check all
#     node = Element("div", {"id": "main"}, [Element("span", {}, "foo", key=Optional(String("a")))])
#     assert_equal(node.json().to_string(), '{"tag": "div", "attributes": {"id": "main"}, "children": [{"tag": "span", "key": "a", "text": "foo"}]}')
