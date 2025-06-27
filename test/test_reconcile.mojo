from testing import assert_equal, assert_not_equal

from reactpy_vdom import Element, Patch, diff, ListPatch
# def test_patch_insert():
#     root = Element("div", {}, [])
#     p = Element("p", {}, "Hello world")
#     patch = Patch(action="insert", path=[0], value=p)
#     patched = patch(root)
#     assert_equal(len(patched.children), 1)
#     assert_equal(patched.children[0], p)

def test_patch_insert():
    var src = Element("div", {}, [])
    var dst = Element("div", {}, [
        Element("p", {}, "Hello world")
    ])
    var patches = diff(src, dst)
    var expected = ListPatch([
        Patch(action="insert", path=[0], value=Element("p", {}, "Hello world"))
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)


def test_patch_remove():
    src = Element("div", {}, [
        Element("p", {}, "Hello world")
    ])
    dst = Element("div", {}, [])
    var patches = diff(src, dst)
    var expected = ListPatch([
        Patch(action="remove", path=[0])
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)

def test_patch_replace():
    var src = Element("p", {}, "foo")
    var dst = Element("span", {}, "bar")
    var patches = diff(src, dst)
    var expected = ListPatch([
        Patch(action="replace", path=[], value=Element("span", {}, "bar"))
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)

    src = Element("div", {}, [Element("p", {}, "foo")])
    dst = Element("div", {}, [Element("span", {}, "bar")])
    patches = diff(src, dst)
    expected = ListPatch([
        Patch(action="replace", path=[0], value=Element("span", {}, "bar"))
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)

def test_patch_update_attributes():
    src = Element("div", {"class": "foo"}, [
        Element("li", {}, "dog"),
        Element("li", {}, "cat"),
    ])
    dst = Element("div", {"class": "bar"}, [
        Element("li", {}, "dog"),
        Element("li", {}, "cat"),
    ])
    patches = diff(src, dst)
    expected = ListPatch([
        Patch(action="update", path=[], value=Element("div", {"class": "bar"}, []))
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)

def test_patch_update_text():
    src = Element("ul", {"class": "foo"}, [
        Element("li", {}, "dog"),
        Element("li", {}, "cat"),
    ])
    dst = Element("ul", {"class": "foo"}, [
        Element("li", {}, "dog"),
        Element("li", {}, "mouse"),
    ])
    patches = diff(src, dst)
    expected = ListPatch([
        Patch(action="update", path=[1], value=Element("li", {}, "mouse"))
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)

def test_patch_keyed_children():
    # case: without keys
    src = Element("ul", {}, [
        Element("li", {}, "a"),
        Element("li", {}, "b"),
    ])
    dst = Element("ul", {}, [
        Element("li", {}, "foo"),
        Element("li", {}, "a"),
        Element("li", {}, "b"),
    ])
    patches = diff(src, dst)
    expected = ListPatch([
        Patch(action="update", path=[0], value=Element("li", {}, "foo")),
        Patch(action="update", path=[1], value=Element("li", {}, "a")),
        Patch(action="insert", path=[2], value=Element("li", {}, "b")),
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)


    # case: with keys
    src = Element("ul", {}, [
        Element("li", {}, "a", key=Optional(String("a"))),
        Element("li", {}, "b", key=Optional(String("b"))),
    ])
    dst = Element("ul", {}, [
        Element("li", {}, "foo", key=Optional(String("foo"))),
        Element("li", {}, "a", key=Optional(String("a"))),
        Element("li", {}, "b", key=Optional(String("b"))),
    ])
    patches = diff(src, dst)
    expected = ListPatch([
        Patch(action="remove", path=[1]),
        Patch(action="remove", path=[0]),
        Patch(action="insert", path=[0], value=Element("li", {}, "foo", key=Optional(String("foo")))),
        Patch(action="insert", path=[1], value=Element("li", {}, "a", key=Optional(String("a")))),
        Patch(action="insert", path=[2], value=Element("li", {}, "b", key=Optional(String("b")))),
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)

def test_patch_update_nested():
    src = Element("div", {}, [
        Element("section", {}, [
            Element("ul", {}, [
                Element("li", {}, "foo"),
                Element("li", {}, "bar")
            ])
        ])
    ])

    dst = Element("div", {}, [
        Element("section", {}, [
            Element("ul", {}, [
                Element("li", {}, "foo"),
                Element("li", {}, "qux")
            ])
        ])
    ])

    patches = diff(src, dst)
    expected = ListPatch([
        Patch(action="update", path=[0, 0, 1], value=Element("li", {}, "qux"))
    ])
    assert_equal(patches, expected)
    assert_equal(patches(src), dst)

# def test_patch_inplace():
#     src = Element("ul", {}, [])
#     dst = Element("ul", {}, [
#         Element("li", {}, "foo")
#     ])

#     patches = diff(src, dst)
#     expected = ListPatch([
#         Patch(action="insert", path=[0], value=Element("li", {}, "foo"))
#     ])
#     assert_equal(patches, expected)
#     assert_equal(patches(src), dst)

#     # check inplace patch
#     patched1 = patches(src, inplace=False)
#     assert_not_equal(src, dst)
#     assert_equal(patched1, dst)

#     # check non-inplace patch
#     patched2 = patches(src, inplace=True)
#     assert_equal(src, dst)
#     assert_equal(patched2, dst)

# def test_patch_json_serialization():
#     patch = Patch("insert", [0], Element("p", {}, "foo"))
#     assert_equal(patch.json().to_string(), '{"action": "insert", "path": [0], "value": {"tag": "p", "text": "foo"}}')

#     patch = Patch("remove", [0], None)
#     assert_equal(patch.json().to_string(), '{"action": "remove", "path": [0], "value": null}')

#     patch = Patch("replace", [0], Element("p", {}, "bar"))
#     assert_equal(patch.json().to_string(), '{"action": "replace", "path": [0], "value": {"tag": "p", "text": "bar"}}')

#     patch = Patch("update", [0], Element("p", {"class": "bar"}, "cat"))
#     assert_equal(patch.json().to_string(), '{"action": "update", "path": [0], "value": {"tag": "p", "attributes": {"class": "bar"}, "text": "cat"}}')
