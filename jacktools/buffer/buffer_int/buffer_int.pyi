from typing import Sequence


class UpdaterInt:
    buffer: 'BufferInt'
    def __update(self, new: int, old: int, is_fool: bool) -> None: pass


class BufferInt:
    max_size: int
    count: int
    is_fool: bool
    def __init__(self, max_size: int, updaters: tuple[UpdaterInt, ...], values: list[int] = None): pass
    def add(self, value: int): pass


class UpdaterInt2d:
    buffer: 'BufferInt2d'
    def __update(self, new: Sequence[int], old: Sequence[int], is_fool: bool) -> None:
        '''Только для cdef методов так как передаются указатели'''


class BufferInt2d:
    max_size: int
    count: int
    is_fool: bool
    def __init__(self, max_size: int, updaters: tuple[UpdaterInt2d, ...], values: list[int] = None, row_length=1): pass
    def add(self, value: Sequence[int]): pass