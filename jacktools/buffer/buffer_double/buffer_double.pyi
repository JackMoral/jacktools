from typing import Sequence, Iterable

class UpdaterDouble:
    buffer: 'BufferDouble'
    def __update(self, new: float, old: float, is_full: bool) -> None: pass

class BufferDouble:
    max_size: int
    count: int
    is_fool: bool
    def __init__(self, max_size: int, updaters: tuple[UpdaterDouble, ...], values: Iterable[float] = None): pass
    def add(self, value: float) -> None: pass


class UpdaterDouble2d:
    buffer: 'BufferDouble2d'
    def __update(self, new: Sequence[float], old: Sequence[float], is_full: bool) -> None:
        '''Только для cdef функций, в new и old передаются указатели!'''


class BufferDouble2d:
    max_size: int
    count: int
    is_fool: bool
    def __init__(self, max_size: int, updaters: tuple[UpdaterDouble2d, ...], values: Iterable[Sequence[float]] = None, row_length=1): pass
    def add(self, value: Sequence[float]) -> None: pass