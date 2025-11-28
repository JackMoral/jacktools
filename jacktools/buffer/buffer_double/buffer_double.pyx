from libc.stdlib cimport malloc, free
from libc.string cimport memcpy

cdef class UpdaterDouble:
    cdef void update(self, double new, double old, bint is_full): pass

cdef class UpdaterDouble2d:
    cdef void update(self, double *new, double *old, bint is_full): pass

cdef class BufferDouble:

    def __cinit__(self, int max_size, tuple[UpdaterDouble, ...] updaters, object values = None):
        cdef UpdaterDouble updater

        self.max_size = max_size
        self.max_idx = max_size - 1
        self.curr_idx = 0
        self.count = 0
        self.is_full = False
        self.updaters = updaters
        self.buffer = <double*> malloc(max_size * sizeof(double))
        if self.buffer == NULL:
            raise MemoryError('Недостаточно памяти')

        for updater in updaters:
            updater.buffer = self

        if values:
            for value in values:
                self.add(value)

    def __dealloc__(self):
        if self.buffer != NULL:
            free(self.buffer)
            self.buffer = NULL
    
    cpdef void add(self, double value):
        cdef double old_value
        cdef UpdaterDouble updater

        if self.is_full:
            old_value = self.buffer[self.curr_idx]
        else:
            self.count += 1
            if self.count >= self.max_size:
                self.is_full = True 
        
        self.buffer[self.curr_idx] = value
        for updater in self.updaters:
            updater.update(value, old_value, self.is_full)

        if self.curr_idx != self.max_idx:
            self.curr_idx += 1
        else:
            self.curr_idx = 0


cdef class BufferDouble2d:

    def __cinit__(self, int max_size, tuple[UpdaterDouble2d, ...] updaters, object values = None, int row_length = 1):
        cdef int i, j
        cdef UpdaterDouble2d updater

        self.max_size = max_size
        self.max_idx = max_size - 1
        self.curr_idx = 0
        self.count = 0
        self.is_full = False
        self.row_length = row_length
        self.row_size = row_length * sizeof(double)
        self.updaters = updaters
        self.buffer = <double**> malloc(max_size * sizeof(double*))
        if self.buffer == NULL:
            raise MemoryError("Недостаточно памяти!")
        
        for i from 0 <= i < max_size:
            self.buffer[i] = <double *> malloc(self.row_size)
            if self.buffer[i] == NULL:
                for j from 0 <= j < i:
                    if self.buffer[j] != NULL:
                        free(self.buffer[j])
                free(self.buffer)
                self.buffer = NULL
                raise MemoryError("Недостаточно памяти!")

        for updater in updaters:
            updater.buffer = self

        if values:
            for value in values:
                self.add(value)

    def __dealloc__(self):
        cdef int i
        if self.buffer != NULL:
            for i from 0 <= i < self.max_size:
                if self.buffer[i] != NULL:
                    free(self.buffer[i])
            free(self.buffer)
    
    cpdef void add(self, object value):
        cdef int i
        cdef double *old_vals
        cdef double *new_vals = self.buffer[self.curr_idx]
        cdef UpdaterDouble2d updater

        try:
            if self.is_full:
                old_vals = <double*> malloc(self.row_size)
                memcpy(old_vals, new_vals, self.row_size)
                if old_vals == NULL:
                    raise MemoryError('Недостаточно памяти!')
                for i from 0 <= i < self.row_length:
                    new_vals[i] = value[i]
                
                for updater in self.updaters:
                    updater.update(new_vals, old_vals, self.is_full)
            else:
                self.count += 1
                for i from 0 <= i < self.row_length:
                    new_vals[i] = value[i]
                
                for updater in self.updaters:
                    updater.update(new_vals, old_vals, self.is_full)
                
                if self.count >= self.max_size:
                    self.is_full = True
            
        finally:
            if old_vals != NULL:
                free(old_vals)

        if self.curr_idx != self.max_idx:
            self.curr_idx += 1
        else:
            self.curr_idx = 0