from emberjson import JSON, Null
from collections import Set

from .utils import dict_equal, dict_keys, enumerate

struct Element(Copyable, Movable, EqualityComparable, Stringable, Representable):
    var tag: String
    var attributes: Dict[String, String]
    var children: List[Element]
    var text: Optional[String]
    var key: Optional[String]

    fn __init__(out self, tag: String, attributes: Dict[String, String], children: List[Element], key: Optional[String] = None):
        self.tag = tag
        self.attributes = attributes
        self.children = children
        self.text = Optional[String](None)
        self.key = key
        # self.key = Optional[String](None)

    fn __init__(out self, tag: String, attributes: Dict[String, String], text: String, key: Optional[String] = None):
        self.tag = tag
        self.attributes = attributes
        self.children = []
        self.text = Optional(text)
        self.key = key
        # self.key = Optional[String](None)

    fn __eq__(self, other: Self) -> Bool:
        return self.tag == other.tag and dict_equal(self.attributes, other.attributes) and self.children == other.children and self.text == other.text and self.key == other.key

    fn __ne__(self, other: Self) -> Bool:
        return not self == other

    fn __repr__(self) -> String:
        return "Element(tag=" + self.tag + ", attributes=" + self.attributes.__str__() + ", children=" + self.children.__repr__() + ", text=" + self.text.__repr__() + ", key=" + self.key.__repr__() + ")"

    fn __str__(self) -> String:
        s = "<" + self.tag
        if self.key is not None:
            s += " key=" + self.key.value()

        for item in self.attributes.items():
            s += " " + item.key + "=" + item.value
        s += ">"

        if self.text is not None:
            s += self.text.value()
        if len(self.children) > 0:

            for child in self.children:
                s += String(child)


        s += "</" + self.tag + ">"

        return s

    # fn get(ref self, path: List[Int]) raises -> ref [self] Self:
    #     """Get node at path."""
    #     var current = Pointer(to=self)
    #     for index in path:
    #         debug_assert(-len(current[].children) <= index < len(current[].children), "index: ",
    #             index,
    #             " is out of bounds for `children` of length: ",
    #             len(current[].children))
    #         if index < 0 or index >= len(current[].children):
    #             current_ = Pointer(to=current[].children[index])
    #             current = rebind[Pointer[Element, __origin_of(self)]](current_)
    #         else:
    #             raise Error("index: ", index, " is out of bounds for `children` of length: ", len(current[].children))
    #     return current[]

    fn get(ref self, path: List[Int]) raises -> ref [self] Self:
        """Get node at path."""
        var current = Pointer(to=self)
        for index in path:
            # debug_assert(-len(current[].children) <= index < len(current[].children), "index: ",
            #     index,
            #     " is out of bounds for `children` of length: ",
            #     len(current[].children))
            if index < 0 or index >= len(current[].children):
                raise Error("index: ", index, " is out of bounds for `children` of length: ", len(current[].children))
            current_ = Pointer(to=current[].children[index])
            current = rebind[Pointer[Element, __origin_of(self)]](current_)
        return current[]

    fn set(mut self, path: List[Int], node: Self):
        """Set node at path."""
        if len(path) == 0:
            self.tag = node.tag
            self.attributes = node.attributes
            self.children = node.children
            self.text = node.text
            self.key = node.key
            return

        try:
            ref parent = self.get(path[:-1])
            index = path[-1]
            parent.children[index] = node
        except Error:
            pass

    fn update(mut self, path: List[Int], node: Self):
        """Update node attributes and text at path."""
        try:
            ref target = self.get(path)
            target.attributes = node.attributes
            target.text = node.text
        except Error:
            pass

    fn insert(mut self, path: List[Int], node: Self):
        """Insert node at path."""
        if len(path) == 0:
            return

        try:
            ref parent = self.get(path[:-1])

            index = path[-1]
            if index >= len(parent.children):
                    parent.children.append(node)
            else:
                parent.children.insert(index, node)
        except Error:
            pass

    fn remove(mut self, path: List[Int]):
        """Remove node at path."""
        if len(path) == 0:
            return

        try:
            ref parent = self.get(path[:-1])

            index = path[-1]
            _ = parent.children.pop(index)
        except Error:
            pass

    fn json(self) -> JSON:
        var obj = JSON.object()
        obj["tag"] = self.tag
        if len(self.attributes) > 0:
            var attributes = JSON.object()
            for key in self.attributes.keys():
                attributes[key] = self.attributes[key]
            obj["attributes"] = attributes
        if len(self.children) > 0:
            var children: List[JSON] = []
            for child in self.children:
                children.append(child.json())
            obj["children"] = children
        if self.text is not None:
            obj["text"] = self.text.value()
        if self.key is not None:
            obj["key"] = self.key.value()
        return obj

    fn clone(self) -> Self:
        attributes = Dict[String, String]()
        for key in self.attributes.keys():
            try:
                attributes[key] = self.attributes[key]
            except KeyError:
                pass
        if self.text is not None:
            return Element(self.tag, attributes, self.text.value(), key=self.key)
        else:
            children: List[Element] = []
            for child in self.children:
                children.append(child.clone())
            return Element(self.tag, attributes, children, key=self.key)


fn get_node(owned root: Element, path: List[Int]) -> Optional[Element]:
    # current = root^
    for index in path:
        if index < 0 or index >= len(root.children):
            return None
        ref root = root.children[index]
    return root

fn set_node(root: Element, path: List[Int], node: Element) -> Element:
    if len(path) == 0:
        return node  # replace root

    parent_path = path[:-1]
    index = path[-1]
    parent = get_node(root, parent_path)
    if parent is None:
        return root  # invalid path

    parent_ = parent.value()
    if index >= len(parent_.children):
        parent_.children.append(node)
    else:
        parent_.children[index] = node

    return root

fn get_node2(root: Element) -> ref [root] Element:
    return root

fn insert_node(mut root: Element, path: List[Int], node: Element) -> Element:
    print("inserting node at index : " + String(",").join(path) + " " + String(node))
    if len(path) == 0:
        return node  # replace root

    # parent_path = path[:-1]
    # parent = get_node(root, parent_path)
    # if parent is None:
    #     return root  # invalid path

    # parent_ = parent.value()

    parent_ = get_node2(root)
    print("parent : " + String(parent_))  # parent : <div></div>

    index = path[-1]
    if index >= len(parent_.children):
        parent_.children.append(node)
    else:
        parent_.children.insert(index, node)


    # if index >= len(root.children):
    #     root.children.append(node)
    # else:
    #     root.children.insert(index, node)

    print("parent : " + String(parent_))  # parent : <div><p>Hello world</p></div>

    print("root : " + String(root))  # root : <div></div>

    return root
