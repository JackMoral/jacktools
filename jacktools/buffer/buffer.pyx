from .buffer_int import BufferInt, BufferInt2d
from .buffer_double import BufferDouble, BufferDouble2d


cpdef object Buffer(
    int max_size,
    object value_type,
    tuple[object, ...] updaters,
    bint twodimensional = False,
    int row_length = 1,
    object values = None
):
    if value_type.__name__ == 'int':
        if not twodimensional:
            return BufferInt(max_size, updaters, values)
        else:
            return BufferInt2d(max_size, updaters, values, row_length)
    elif value_type.__name__ == 'float':
        if not twodimensional:
            return BufferDouble(max_size, updaters, values)
        else:
            return BufferDouble2d(max_size, updaters, values, row_length)

    raise TypeError('Поддерживаются только int или float') 