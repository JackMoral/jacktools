from libc.stdlib cimport malloc, free
from jacktools.buffer cimport UpdaterInt


cdef class OverUnderInt(UpdaterInt):

    cdef: 
        int over
        int under
        int value

    def __cinit__(self, int value):
        self.over = 0
        self.under = 0
        self.value = value
                
    cdef void update(self, int new, int old, bint is_full):
        if is_full:
            if old != new:
                if old > self.value:
                    self.over -= 1
                else:
                    self.under -= 1
                
                if new > self.value:
                    self.over += 1
                else:
                    self.under += 1
        else:
            if new > self.value:
                self.over += 1
            else:
                self.under += 1
    
    cpdef list[int] get(self):
        return [self.over, self.under]
        
