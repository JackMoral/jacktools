cdef class UpdaterInt:
    cdef BufferInt buffer
    cdef void update(self, int new, int old, bint is_full)

cdef class UpdaterInt2d:
    cdef BufferInt2d buffer
    cdef void update(self, int *new, int *old, bint is_full)

cdef class BufferInt:
    cdef readonly:
        int max_size
        int count
        bint is_full
    cdef:
        int curr_idx
        int max_idx
        int *buffer
        tuple[UpdaterInt, ...] updaters
    cpdef void add(self, int value)

cdef class BufferInt2d:
    cdef readonly:
        int max_size
        int count
        bint is_full
    cdef:
        int curr_idx
        int max_idx
        int **buffer
        int row_length
        size_t row_size
        tuple[UpdaterInt2d, ...] updaters
    cpdef void add(self, object value)