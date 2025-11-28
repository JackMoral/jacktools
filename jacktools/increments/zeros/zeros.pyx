from libc.stdlib cimport malloc, free
from jacktools.buffer cimport UpdaterInt2d


cdef class ZeroInt2d(UpdaterInt2d):

    cdef: 
        int *dry
        int *both

    def __cinit__(self):
        self.dry = <int*> malloc(3 * sizeof(int))
        if self.dry == NULL:
            raise MemoryError('Недостаточно памяти')
        self.dry[0] = 0
        self.dry[1] = 0
        self.dry[2] = 0
        
        self.both = <int*> malloc(2 * sizeof(int))
        if self.both == NULL:
            free(self.dry)
            self.dry = NULL
            raise MemoryError('Недостаточно памяти')
        self.both[0] = 0
        self.both[1] = 0
                
    def __dealloc__(self):
        if self.dry != NULL:
            free(self.dry)
            self.dry = NULL
        if self.both != NULL:
            free(self.both)
            self.both = NULL

    cdef void update(self, int *new, int *old, bint is_full):
        cdef: 
            int a = new[0] 
            int b = new[1]
            int a2, b2, summary
        
        if is_full:
            a2 = old[0]
            b2 = old[1]
            summary = a2 + b2
            if summary == 0:
                self.dry[1] -= 1
                self.both[1] -= 1
            elif a2 == 0:
                self.dry[2] -= 1
                self.both[1] -= 1
            elif b2 == 0:
                self.dry[0] -= 1
                self.both[1] -= 1
            else:
                self.both[0] -= 1

        summary = a + b
        if summary == 0:
            self.dry[1] += 1
            self.both[1] += 1
        elif a == 0:
            self.dry[2] += 1
            self.both[1] += 1
        elif b == 0:
            self.dry[0] += 1
            self.both[1] += 1
        else:
            self.both[0] += 1
        
    cpdef tuple[list[int], list[int]] get(self):
        return (
            [self.dry[0], self.dry[1], self.dry[2]], 
            [self.both[0], self.both[1]]
        )
