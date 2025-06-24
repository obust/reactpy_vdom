from collections.set import Set
from builtin.sort import sort
from emberjson import JSON
from python import PythonObject, Python

from .vdom import Element, get_node, insert_node, set_node
from .utils import dict_equal, enumerate

@fieldwise_init
struct Patch(Copyable, Movable, EqualityComparable, Representable, Stringable):
    var action: String  # "insert", "remove", "replace", "update"
    var path: List[Int]
    var value: Optional[Element]

    fn __call__(self: Self, root_: Element, inplace: Bool = True) -> Element:
        var root = root_
        if not inplace:
            root = root.clone()

        if self.action == "insert":
            root.insert(self.path, self.value.value())
        elif self.action == "remove":
            _ = root.remove(self.path)
        elif self.action == "replace":
            root.set(self.path, self.value.value())
        elif self.action == "update":
            root.update(self.path, self.value.value())

        return root

    fn __eq__(self: Self, other: Self) -> Bool:
        return self.action == other.action and self.path == other.path and self.value == other.value

    fn __ne__(self: Self, other: Self) -> Bool:
        return not self == other

    fn __repr__(self) -> String:
        value = self.value.value().__str__() if self.value is not None else "None"
        return "Patch(action=" + self.action + ", path=" + self.path.__str__() + ", value=" + value + ")"

    fn __str__(self) -> String:
        return self.__repr__()

    fn python(self: Self) raises -> PythonObject:
        action = Python.str(self.action)
        path = Python.list([Python.int(i) for i in self.path])
        value = self.value.value().python() if self.value is not None else PythonObject(None)
        return Python.dict(action=action, path=path, value=value)

    fn json(self: Self) -> JSON:
        value = self.value.value().json() if self.value is not None else Null()
        return JSON.object({
            "action": JSON.string(self.action),
            "path": JSON.array(self.path),
            "value": value,
        })

struct ListPatch(Copyable, Movable, Defaultable, EqualityComparable, Stringable, Representable):
    var patches: List[Patch]

    fn __init__(out self):
        self.patches = List[Patch]()

    fn __init__(out self, patches: List[Patch]):
        self.patches = patches

    fn __call__(self, root_: Element, inplace: Bool = True) -> Element:
        var root = root_
        if not inplace:
            root = root.clone()

        for patch in self.patches:
            root = patch(root, inplace=True)

        return root

    fn __eq__(self, other: Self) -> Bool:
        return self.patches == other.patches

    fn __ne__(self, other: Self) -> Bool:
        return self.patches != other.patches

    fn append(mut self, patch: Patch):
        self.patches.append(patch)

    fn __add__(self, other: ListPatch) -> Self:
        return ListPatch(self.patches + other.patches)

    fn __iadd__(mut self, other: ListPatch):
        self.patches += other.patches

    fn python(self) raises -> PythonObject:
        return Python.list([patch.python() for patch in self.patches])

    fn json(self) -> JSON:
        return JSON.array([patch.json() for patch in self.patches])

    fn __repr__(self) -> String:
        return "ListPatch(" + self.patches.__str__() + ")"

    fn __str__(self) -> String:
        return self.patches.__str__()


fn diff(ref src: Element, ref dst: Element, path: List[Int] = []) -> ListPatch:
    patches = ListPatch([])

    # case replace
    if src.tag != dst.tag or src.key != dst.key:
        patches.append(Patch(action="replace", path=path, value=dst))
        return patches

    # case update
    if not dict_equal(src.attributes, dst.attributes) or src.text != dst.text:
        if dst.text is not None:
            el = Element(dst.tag, dst.attributes, dst.text.value(), key=dst.key)
        else:
            el = Element(dst.tag, dst.attributes, [], key=dst.key)
        patches.append(Patch(action="update", path=path, value=el))

    # Recursively diff children
    has_keys = True if len(dst.children) > 0 else False
    for child in dst.children:
        if child.key is None:
            has_keys = False
            break

    if has_keys:
        patches += _diff_children_key(src.children, dst.children, path)
    else:
        patches += _diff_children_index(src.children, dst.children, path)


    return patches

fn _diff_children_index(src: List[Element], dst: List[Element], path: List[Int] = []) -> ListPatch:
    """Index based node diffing"""
    src_len = len(src)
    dst_len = len(dst)
    max_len = max(src_len, dst_len)

    patches = ListPatch([])
    for i in range(max_len):
        if i >= src_len:
            patches.append(Patch(action="insert", path=path + [i], value=dst[i]))
            continue
        elif i >= dst_len:
            patches.append(Patch(action="remove", path=path + [i], value=None))
            continue

        ref src_child = src[i]
        ref dst_child = dst[i]
        child_path = path + [i]
        patches += diff(src_child, dst_child, child_path)

    return patches

fn _get_key_map(nodes: List[Element]) -> Dict[String, (Int, Element)]:
    return {child.key.value(): (i, child) for (i, child) in enumerate(nodes) if child.key is not None}


fn _diff_children_key(src: List[Element], dst: List[Element], path: List[Int] = []) -> ListPatch:
    src_key_map = _get_key_map(src)
    used_keys = Set[String]()

    remove_ops: List[Patch] = []
    insert_ops: List[Patch] = []

    patches = ListPatch([])

    for new_index, dst_child in enumerate(dst):
        key = dst_child.key.value()
        used_keys.add(key)

        if key in src_key_map:
            try:
                old_index, src_child = src_key_map[key]

                child_path = path + [new_index]
                patches += diff(src_child, dst_child, child_path)

                if old_index != new_index:
                    # Defer reordering to avoid index shifts
                    remove_ops.append(Patch(action="remove", path=path + [old_index], value=None))
                    insert_ops.append(Patch(action="insert", path=path + [new_index], value=dst_child))
            except KeyError:
                pass
        else:
            insert_ops.append(Patch(action="insert", path=path + [new_index], value=dst_child))

    for key in src_key_map.keys():
        if key not in used_keys:
            try:
                old_index, _ = src_key_map[key]
                remove_ops.append(Patch(action="remove", path=path + [old_index], value=None))
            except KeyError:
                pass

    # Apply removes in reverse order to avoid shifting issues
    @parameter
    fn compare_fn(a: Patch, b: Patch) -> Bool:
        return a.path[-1] > b.path[-1]
    sort[compare_fn](remove_ops)

    for patch in remove_ops:
        patches.append(patch)

    # Then apply inserts
    for patch in insert_ops:
        patches.append(patch)

    return patches


##################
# PYTHON EXPORTS #
##################

fn py_diff(src: PythonObject, dst: PythonObject) raises -> PythonObject:
    src_ptr = src.downcast_value_ptr[Element]()
    dst_ptr = dst.downcast_value_ptr[Element]()
    patches = diff(src_ptr[], dst_ptr[])
    return PythonObject(alloc=patches^)

fn py_apply(element: PythonObject, patches: PythonObject, inplace: PythonObject) raises -> PythonObject:
    element_ptr = element.downcast_value_ptr[Element]()
    patches_ptr = patches.downcast_value_ptr[ListPatch]()
    inplace_ = Bool(inplace)
    patched = patches_ptr[](element_ptr[], inplace=inplace_)
    return PythonObject(alloc=patched^)


fn ListPatch_python(self: PythonObject) raises -> PythonObject:
    self_ptr = self.downcast_value_ptr[ListPatch]()
    return self_ptr[].python()

# fn ListPatch_json(self: PythonObject) raises -> PythonObject:
#     self_ptr = self.downcast_value_ptr[ListPatch]()
#     json_str = self_ptr[].json().to_string()
#     return PythonObject(json_str)


