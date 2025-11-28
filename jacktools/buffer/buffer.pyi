from .buffer_int import BufferInt, UpdaterInt, BufferInt2d, UpdaterInt2d
from .buffer_double import BufferDouble, UpdaterDouble2d, UpdaterDouble, BufferDouble2d

def Buffer(
    max_size: int,
    value_type: type[int] | type[float],
    updaters: tuple[UpdaterInt, ...] | tuple[UpdaterInt2d, ...] | tuple[UpdaterDouble, ...] | tuple[UpdaterDouble2d, ...],
    twodimensional = False,
    row_length = 1,
    values: list[int] | list[list[int]] = None
) -> BufferInt | BufferInt2d | BufferDouble | BufferDouble2d: ...