from emberjson import JSON, Null
from collections import Set
from python import PythonObject, Python
from os import abort

from .utils import dict_equal, dict_keys, enumerate

struct Element(Copyable, Movable, Defaultable, EqualityComparable, Stringable, Representable):
    var tag: String
    var attributes: Dict[String, String]
    var children: List[Element]
    var text: Optional[String]
    var key: Optional[String]

    fn __init__(out self):
        self.tag = String()
        self.attributes = Dict[String, String]()
        self.children = List[Element]()
        self.text = Optional[String](None)
        self.key = Optional[String](None)

    fn __init__(out self, owned tag: String, owned attributes: Dict[String, String], owned children: List[Element], owned key: Optional[String] = None):
        self.tag = tag
        self.attributes = attributes
        self.children = children
        self.text = Optional[String](None)
        self.key = key

    fn __init__(out self, owned tag: String, owned attributes: Dict[String, String], owned text: String, owned key: Optional[String] = None):
        self.tag = tag
        self.attributes = attributes
        self.children = []
        self.text = Optional(text)
        self.key = key

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

    fn remove(mut self, path: List[Int]) -> Optional[Element]:
        """Remove node at path."""
        if len(path) == 0:
            return

        try:
            ref parent = self.get(path[:-1])

            index = path[-1]
            element = parent.children.pop(index)
            return element
        except Error:
            pass

        return

    fn python(self) raises -> PythonObject:
        tag = Python.str(self.tag)
        attributes = Python.dict()
        for ref key in self.attributes.keys():
            attributes[Python.str(key)] = Python.str(self.attributes[key])
        children = Python.list([child.python() for child in self.children])
        text = Python.str(self.text.value()) if self.text is not None else PythonObject(None)
        key = Python.str(self.key.value()) if self.key is not None else PythonObject(None)
        return Python.dict(tag=tag, attributes=attributes, children=children, text=text, key=key)

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

    fn clone(self, include_children: Bool = True) -> Self:
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
            if include_children:
                for child in self.children:
                    children.append(child.clone())
            return Element(self.tag, attributes, children, key=self.key)



##################
# PYTHON EXPORTS #
##################


fn create_element(tag: PythonObject, attributes: PythonObject, kwargs: PythonObject) raises -> PythonObject:
    tag_ = String(tag)

    attributes_: Dict[String, String] = {}
    for item in attributes.items():
        key, value = item[0], item[1]
        attributes_[String(key)] = String(value)

    py_none = PythonObject(None)
    key = kwargs["key"]
    if key is py_none:
        key_: Optional[String] = None
    else:
        key_: Optional[String] = String(key)

    text = kwargs["text"]
    children = kwargs["children"]

    if text is not py_none:
        text_ = String(text)
        element = Element(tag_, attributes_, text_)
    else:
        children_: List[Element] = []
        for child in children:
            child_ptr = child.downcast_value_ptr[Element]()
            children_.append(child_ptr[])
        element = Element(tag_, attributes_, children_)

    return PythonObject(alloc=element^)
