from collections.set import Set
from builtin.sort import sort
from emberjson import JSON

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
            root.remove(self.path)
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

    fn json(self: Self) -> JSON:
        value = self.value.value().json() if self.value is not None else Null()
        return JSON.object(
            "action": self.action,
            "path": self.path,
            "value": value,
        )

struct ListPatch(Copyable, Movable, EqualityComparable, Stringable, Representable):
    var patches: List[Patch]

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

    fn json(self) -> JSON:
        return JSON.array(self.patches.map(lambda p: p.json()))

    fn __repr__(self) -> String:
        return "ListPatch(" + self.patches.__str__() + ")"

    fn __str__(self) -> String:
        return self.patches.__str__()

fn diff(src: Optional[Element], dst: Optional[Element], path: List[Int] = []) -> ListPatch:
    patches = ListPatch([])

    if src is None and dst is not None:
        _ = patches.append(Patch(action="insert", path=path, value=dst))
        return patches

    if dst is None and src is not None:
        _ = patches.append(Patch(action="remove", path=path, value=None))
        return patches

    if src is not None and dst is not None:
        src_ = src.value()
        dst_ = dst.value()
        print(src_.tag, dst_.tag)
        print(src_.key.or_else(""), dst_.key.or_else(""))
        if src_.tag != dst_.tag or src_.key != dst_.key:
            patches.append(Patch(action="replace", path=path, value=dst))
            return patches

        if not dict_equal(src_.attributes, dst_.attributes) or src_.text != dst_.text:
            if dst_.text is not None:
                el = Element(dst_.tag, dst_.attributes, dst_.text.value(), key=dst_.key)
            else:
                el = Element(dst_.tag, dst_.attributes, [], key=dst_.key)
            patches.append(Patch(action="update", path=path, value=el))

        # Recursively diff children
        has_keys = True if len(dst_.children) > 0 else False
        for child in dst_.children:
            if child.key is None:
                has_keys = False
                break

        if has_keys:
            patches += _diff_children_key(src_.children, dst_.children, path)
        else:
            patches += _diff_children_index(src_.children, dst_.children, path)


    return patches

fn _diff_children_index(src: List[Element], dst: List[Element], path: List[Int] = []) -> ListPatch:
    """Index based node diffing"""
    src_len = len(src)
    dst_len = len(dst)
    max_len = max(src_len, dst_len)

    patches = ListPatch([])
    for i in range(max_len):
        src_child: Optional[Element] = Optional(src[i]) if i < src_len else Optional[Element](None)
        dst_child: Optional[Element] = Optional(dst[i]) if i < dst_len else Optional[Element](None)
        child_path = path + [i]
        patches += diff(src_child, dst_child, child_path)

    return patches

fn _get_key_map(nodes: List[Element]) -> Dict[String, (Int, Element)]:
    return {child.key.value(): (i, child) for (i, child) in enumerate(nodes) if child.key is not None}

fn _diff_children_key2(src: List[Element], dst: List[Element], path: List[Int] = []) -> ListPatch:
    src_key_map = _get_key_map(src)
    # dst_key_map = _get_key_map(dst)
    used_keys = Set[String]()

    patches = ListPatch([])
    for new_index, dst_child in enumerate(dst):
        key = dst_child.key.value()
        used_keys.add(key)

        if key in src_key_map:
            try:
                old_index, src_child = src_key_map[key]
                # Recursively diff matched node
                child_path = path + [new_index]
                patches += diff(src_child, dst_child, child_path)

                if old_index != new_index:
                    # Move required (represented as remove+insert)
                    patches.append(Patch(action="remove", path=path + [old_index], value=None))
                    patches.append(Patch(action="insert", path=path + [new_index], value=dst_child))
            except KeyError:
                pass

        else:
            # New key: insert
            patches.append(Patch(action="insert", path=path + [new_index], value=dst_child))

    # Keys in src not in dst → remove
    for key in src_key_map.keys():
        if key not in used_keys:
            try:
                old_index, _ = src_key_map[key]
                patches.append(Patch(action="remove", path=path + [old_index], value=None))
            except KeyError:
                pass


    return patches


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
