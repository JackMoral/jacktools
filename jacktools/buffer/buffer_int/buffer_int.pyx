from libc.stdlib cimport malloc, free
from libc.string cimport memcpy


cdef class UpdaterInt:
    cdef void update(self, int new, int old, bint is_full): pass

cdef class UpdaterInt2d:
    cdef void update(self, int *new, int *old, bint is_full): pass


cdef class BufferInt:

    def __cinit__(self, int max_size, tuple[UpdaterInt, ...] updaters, object values = None):
        cdef int i
        cdef UpdaterInt updater

        self.max_size = max_size
        self.max_idx = max_size - 1
        self.curr_idx = 0
        self.count = 0
        self.is_full = False
        self.updaters = updaters
        self.buffer = <int*> malloc(max_size * sizeof(int))
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
    
    cpdef void add(self, int value):
        cdef int old_value
        cdef UpdaterInt updater

        if self.is_full:
            old_value = self.buffer[self.curr_idx]
            self.buffer[self.curr_idx] = value
            for updater in self.updaters:
                updater.update(value, old_value, self.is_full)
        else:
            self.count += 1
            self.buffer[self.curr_idx] = value
            for updater in self.updaters:
                updater.update(value, old_value, self.is_full)
        
            if self.count == self.max_size:
                self.is_full = True 

        if self.curr_idx == self.max_idx:
            self.curr_idx = 0
        else:
            self.curr_idx += 1
    

cdef class BufferInt2d:

    def __cinit__(self, int max_size, tuple[UpdaterInt2d, ...] updaters, object values = None, int row_length = 1):
        cdef int i, j
        cdef UpdaterInt2d updater

        self.max_size = max_size
        self.max_idx = max_size - 1
        self.curr_idx = 0
        self.count = 0
        self.is_full = False
        self.row_length = row_length
        self.row_size = row_length * sizeof(int*)
        self.updaters = updaters
        self.buffer = <int**> malloc(max_size * sizeof(int*))
        if self.buffer == NULL:
            raise MemoryError("Недостаточно памяти!")
        
        for i from 0 <= i < max_size:
            self.buffer[i] = <int *> malloc(self.row_size)
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
        cdef int *old_vals
        cdef int *new_vals = self.buffer[self.curr_idx]
        cdef UpdaterInt2d updater
        try:
            if self.is_full:
                old_vals = <int*> malloc(self.row_size)
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