from libc.stdlib cimport malloc, free
from jacktools.buffer cimport UpdaterInt, BufferInt, UpdaterDouble


cdef class ExtremumsInt(UpdaterInt):

    cdef:
        int maximal, minimal
        bint is_init

    def __cinit__(self):
        self.is_init = False
                
    cdef void update(self, int new, int old, bint is_full):

        if self.is_init:
            if new > self.maximal:
                self.maximal = new
                if is_full and old == self.minimal:
                    self._upmin(new)
            elif new < self.minimal:
                self.minimal = new
                if is_full and old == self.maximal:
                    self._upmax(new)
            elif is_full and old != new:
                if old == self.maximal:
                    self._upmax(new)
                elif old == self.minimal:
                    self._upmin(new)
        else:
            self.maximal = new
            self.minimal = new
            self.is_init = True
    
    cdef inline void _upmax(self, int new):
        cdef int i, val, extremum = self.maximal
        self.maximal = new
        for i from 0 <= i < self.buffer.max_size:
            if i == self.buffer.curr_idx:
                continue
            val = self.buffer.buffer[i]
            if val == extremum:
                self.maximal = extremum
                break
            elif val > self.maximal:
                self.maximal = val

    cdef inline void _upmin(self, int new):
        cdef: 
            int i, val 
            int extremum = self.minimal
        self.minimal = new
        for i from 0 <= i < self.buffer.max_size:
            if i == self.buffer.curr_idx:
                continue
            val = self.buffer.buffer[i]
            if val == extremum:
                self.minimal == extremum
                break
            elif val < self.minimal:
                self.minimal = val

    cpdef list[int] get(self):
        if self.is_init:
            return [self.maximal, self.minimal]
        raise NotImplementedError('Объект небыл заполнен данными')


cdef class ExtremumsDouble(UpdaterDouble):

    cdef: 
        double maximal, minimal
        bint is_init

    def __cinit__(self):
        self.is_init = False
                
    cdef void update(self, double new, double old, bint is_full):
        cdef:
            double val, extremum
            int i

        if self.is_init:
            if new > self.maximal:
                self.maximal = new
            elif new < self.minimal:
                self.minimal = new
            elif is_full and old != new:
                if old == self.maximal:
                    extremum = self.maximal
                    self.maximal = new
                    for i from 0 <= i < self.buffer.max_size:
                        if i == self.buffer.curr_idx:
                            continue
                        val = self.buffer.buffer[i]
                        if val == extremum:
                            self.maximal = extremum
                            break
                        elif val > self.maximal:
                            self.maximal = val
                elif old == self.minimal:
                    extremum = self.minimal
                    self.minimal = new
                    for i from 0 <= i < self.buffer.max_size:
                        if i == self.buffer.curr_idx:
                            continue
                        val = self.buffer.buffer[i]
                        if val == extremum:
                            self.minimal == extremum
                            break
                        elif val < self.minimal:
                            self.minimal = val
        else:
            self.maximal = new
            self.minimal = new
            self.is_init = True
    
    cpdef list[double] get(self):
        if self.is_init:
            return [self.maximal, self.minimal]
        raise NotImplementedError('Объект небыл заполнен данными')