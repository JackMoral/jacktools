from libc.stdlib cimport malloc, free
from jacktools.buffer cimport UpdaterInt2d


cdef class OutcomeInt2d(UpdaterInt2d):

    cdef: 
        int *outcome
        double *double_chance

    def __cinit__(self):
        self.outcome = <int*> malloc(3 * sizeof(int))
        if self.outcome == NULL:
            raise MemoryError('Недостаточно памяти')
        
        self.double_chance = <double*> malloc(3 * sizeof(double))
        if self.double_chance == NULL:
            free(self.outcome)
            self.outcome = NULL
            raise MemoryError('Недостаточно памяти')
        
        self.outcome[0] = 0
        self.outcome[1] = 0
        self.outcome[2] = 0
        self.double_chance[0] = 0
        self.double_chance[1] = 0
        self.double_chance[2] = 0
                
    def __dealloc__(self):
        if self.outcome != NULL:
            free(self.outcome)
            self.outcome = NULL
        if self.double_chance != NULL:
            free(self.double_chance)
            self.double_chance = NULL

    cdef void update(self, int *new, int *old, bint is_full):
        cdef: 
            int a = new[0] 
            int b = new[1]
            int a2, b2

        if is_full:
            a2 = old[0]
            b2 = old[1]
            if a2 > b2:
                self.outcome[0] -= 1
                self.double_chance[0] -= 0.5
                self.double_chance[1] -= 0.5
            elif a2 < b2:
                self.outcome[2] -= 1
                self.double_chance[2] -= 0.5
                self.double_chance[1] -= 0.5
            else:
                self.outcome[1] += 1
                self.double_chance[0] += 0.5
                self.double_chance[2] += 0.5

        if a > b:
            self.outcome[0] += 1
            self.double_chance[0] += 0.5
            self.double_chance[1] += 0.5
        elif a < b:
            self.outcome[2] += 1
            self.double_chance[2] += 0.5
            self.double_chance[1] += 0.5
        else:
            self.outcome[1] += 1
            self.double_chance[0] += 0.5
            self.double_chance[2] += 0.5
    
    cpdef tuple[list[int], list[float]] get(self):
        return (
            [self.outcome[0], self.outcome[1], self.outcome[2]], 
            [self.double_chance[0], self.double_chance[1], self.double_chance[2]]
        )
