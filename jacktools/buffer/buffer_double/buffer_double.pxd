
cdef class UpdaterDouble:
    cdef BufferDouble buffer
    cdef void update(self, double new, double old, bint is_full)

cdef class UpdaterDouble2d:
    cdef BufferDouble2d buffer
    cdef void update(self, double *new, double *old, bint is_full)

cdef class BufferDouble:
    cdef readonly:
        int max_size
        int count
        bint is_full
    cdef:
        int curr_idx
        int max_idx
        double *buffer
        tuple[UpdaterDouble, ...] updaters
    cpdef void add(self, double value)

cdef class BufferDouble2d:
    cdef readonly:
        int max_size
        int count
        bint is_full
    cdef:
        int curr_idx
        int max_idx
        double **buffer
        int row_length
        size_t row_size
        tuple[UpdaterDouble2d, ...] updaters
    cpdef void add(self, object value)
