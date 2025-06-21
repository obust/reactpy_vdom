

fn dict_equal[
    K: KeyElement, V: EqualityComparable & Copyable & Movable
](a: Dict[K, V], b: Dict[K, V]) -> Bool:
    if len(a) != len(b):
        return False
    for k in a.keys():
        try:
            if a[k] != b[k]:
                return False
        except KeyError:
            return False
    return True

fn dict_keys[K: KeyElement, V: Copyable & Movable](d: Dict[K, V]) -> Set[K]:
    keys = Set[K]()
    for key in d.keys():
        keys.add(key)
    return keys


fn enumerate[T: Copyable & Movable](l: List[T]) -> List[(Int, T)]:
    return [(i, l[i]) for i in range(len(l))]
