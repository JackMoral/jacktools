from libc.math cimport sqrt
from libc.stdlib cimport malloc, free
from jacktools.buffer cimport BufferInt, UpdaterInt, BufferDouble, UpdaterDouble

cdef class WelfordInt(UpdaterInt):
    cdef:
        int summary, sum_of_squares, sum_of_cubes, sum_of_4th_powers
        double mean, variance, skewness, kurtosis

    def __cinit__(self):
        self.summary = 0
        self.mean = 0.0
        self.variance = 0.0
        self.skewness = 0.0
        self.kurtosis = 0.0
        self.sum_of_squares = 0
        self.sum_of_cubes = 0
        self.sum_of_4th_powers = 0
              
    cdef void update(self, int new, int old, bint is_full):
        cdef:
            int new_sq, new_cube, new_4th
            int old_sq, old_cube, old_4th

            double inv_q, m2, m3, m4, sqrt_m2
            double sum_of_squares_norm, sum_of_cubes_norm, sum_of_4th_powers_norm, mean_sq
            double temp1, temp2, temp3
        
        new_sq = new * new
        new_cube = new_sq * new
        new_4th = new_cube * new
        
        if is_full:
            old_sq = old * old
            old_cube = old_sq * old
            old_4th = old_cube * old
            
            self.summary -= old
            self.sum_of_squares -= old_sq
            self.sum_of_cubes -= old_cube
            self.sum_of_4th_powers -= old_4th
                
        self.summary += new
        self.sum_of_squares += new_sq
        self.sum_of_cubes += new_cube
        self.sum_of_4th_powers += new_4th
                
        if is_full:
            inv_q = 1.0 / self.buffer.count
            self.mean = self.summary * inv_q
            
            mean_sq = self.mean * self.mean
            sum_of_squares_norm = self.sum_of_squares * inv_q
            sum_of_cubes_norm = self.sum_of_cubes * inv_q  
            sum_of_4th_powers_norm = self.sum_of_4th_powers * inv_q
            
            m2 = sum_of_squares_norm - mean_sq
            temp1 = 3.0 * self.mean * sum_of_squares_norm
            temp2 = 2.0 * mean_sq * self.mean
            m3 = sum_of_cubes_norm - temp1 + temp2
            temp1 = 4.0 * self.mean * sum_of_cubes_norm
            temp2 = 6.0 * mean_sq * sum_of_squares_norm  
            temp3 = 3.0 * mean_sq * mean_sq
            m4 = sum_of_4th_powers_norm - temp1 + temp2 - temp3
            self.variance = m2 * self.buffer.count / (self.buffer.count - 1.0)
            
            if m2 > 1e-12:
                sqrt_m2 = sqrt(m2)
                self.skewness = m3 / (m2 * sqrt_m2) * sqrt(self.buffer.count * (self.buffer.count - 1.0)) / (self.buffer.count - 2.0)
                self.kurtosis = ((self.buffer.count - 1.0) * ((self.buffer.count + 1.0) * (m4 / (m2 * m2) - 3.0) + 6.0)) / ((self.buffer.count - 2.0) * (self.buffer.count - 3.0))
            else:
                self.skewness = 0.0
                self.kurtosis = 0.0

        elif self.buffer.count > 0:
            inv_q = 1.0 / self.buffer.count
            self.mean = self.summary * inv_q
            
            mean_sq = self.mean * self.mean
            sum_of_squares_norm = self.sum_of_squares * inv_q
            sum_of_cubes_norm = self.sum_of_cubes * inv_q  
            sum_of_4th_powers_norm = self.sum_of_4th_powers * inv_q
            
            m2 = sum_of_squares_norm - mean_sq
            temp1 = 3.0 * self.mean * sum_of_squares_norm
            temp2 = 2.0 * mean_sq * self.mean
            m3 = sum_of_cubes_norm - temp1 + temp2
            temp1 = 4.0 * self.mean * sum_of_cubes_norm
            temp2 = 6.0 * mean_sq * sum_of_squares_norm  
            temp3 = 3.0 * mean_sq * mean_sq
            m4 = sum_of_4th_powers_norm - temp1 + temp2 - temp3

            if self.buffer.count > 1:
                self.variance = m2 * self.buffer.count / (self.buffer.count - 1.0)
                if self.buffer.count > 2 and m2 > 1e-12:
                    sqrt_m2 = sqrt(m2)
                    self.skewness = m3 / (m2 * sqrt_m2) * sqrt(self.buffer.count * (self.buffer.count - 1.0)) / (self.buffer.count - 2.0)
                    if self.buffer.count > 3:
                        self.kurtosis = ((self.buffer.count - 1.0) * ((self.buffer.count + 1.0) * (m4 / (m2 * m2) - 3.0) + 6.0)) / ((self.buffer.count - 2.0) * (self.buffer.count - 3.0))
                    else:
                        self.kurtosis = 0.0
                else:
                    self.skewness = 0.0
                    self.kurtosis = 0.0
            else:
                self.variance = 0.0
                self.skewness = 0.0
                self.kurtosis = 0.0
        else:
            self.mean = 0.0
            self.variance = 0.0
            self.skewness = 0.0
            self.kurtosis = 0.0
    
    cpdef list get(self):
        return [self.summary, self.mean, self.variance, self.skewness, self.kurtosis]


cdef class WelfordDouble(UpdaterDouble):
    cdef:
        double summary, sum_of_squares, sum_of_cubes, sum_of_4th_powers, mean, variance, skewness, kurtosis

    def __cinit__(self):
        self.summary = 0.0
        self.mean = 0.0
        self.variance = 0.0
        self.skewness = 0.0
        self.kurtosis = 0.0
        self.sum_of_squares = 0.0
        self.sum_of_cubes = 0.0
        self.sum_of_4th_powers = 0.0
              
    cdef void update(self, double new, double old, bint is_full):
        cdef:
            double new_sq, new_cube, new_4th, old_sq, old_cube, old_4th
            double inv_q, m2, m3, m4, sqrt_m2
            double sum_of_squares_norm, sum_of_cubes_norm, sum_of_4th_powers_norm, mean_sq
            double temp1, temp2, temp3
        
        new_sq = new * new
        new_cube = new_sq * new
        new_4th = new_cube * new
        
        if is_full:
            old_sq = old * old
            old_cube = old_sq * old
            old_4th = old_cube * old
            
            self.summary -= old
            self.sum_of_squares -= old_sq
            self.sum_of_cubes -= old_cube
            self.sum_of_4th_powers -= old_4th
                
        self.summary += new
        self.sum_of_squares += new_sq
        self.sum_of_cubes += new_cube
        self.sum_of_4th_powers += new_4th
                
        if is_full:
            inv_q = 1.0 / self.buffer.count
            self.mean = self.summary * inv_q
            
            mean_sq = self.mean * self.mean
            sum_of_squares_norm = self.sum_of_squares * inv_q
            sum_of_cubes_norm = self.sum_of_cubes * inv_q  
            sum_of_4th_powers_norm = self.sum_of_4th_powers * inv_q
            
            m2 = sum_of_squares_norm - mean_sq
            temp1 = 3.0 * self.mean * sum_of_squares_norm
            temp2 = 2.0 * mean_sq * self.mean
            m3 = sum_of_cubes_norm - temp1 + temp2
            temp1 = 4.0 * self.mean * sum_of_cubes_norm
            temp2 = 6.0 * mean_sq * sum_of_squares_norm  
            temp3 = 3.0 * mean_sq * mean_sq
            m4 = sum_of_4th_powers_norm - temp1 + temp2 - temp3
            self.variance = m2 * self.buffer.count / (self.buffer.count - 1.0)
            
            if m2 > 1e-12:
                sqrt_m2 = sqrt(m2)
                self.skewness = m3 / (m2 * sqrt_m2) * sqrt(self.buffer.count * (self.buffer.count - 1.0)) / (self.buffer.count - 2.0)
                self.kurtosis = ((self.buffer.count - 1.0) * ((self.buffer.count + 1.0) * (m4 / (m2 * m2) - 3.0) + 6.0)) / ((self.buffer.count - 2.0) * (self.buffer.count - 3.0))
            else:
                self.skewness = 0.0
                self.kurtosis = 0.0

        elif self.buffer.count > 0:
            inv_q = 1.0 / self.buffer.count
            self.mean = self.summary * inv_q
            
            mean_sq = self.mean * self.mean
            sum_of_squares_norm = self.sum_of_squares * inv_q
            sum_of_cubes_norm = self.sum_of_cubes * inv_q  
            sum_of_4th_powers_norm = self.sum_of_4th_powers * inv_q
            
            m2 = sum_of_squares_norm - mean_sq
            temp1 = 3.0 * self.mean * sum_of_squares_norm
            temp2 = 2.0 * mean_sq * self.mean
            m3 = sum_of_cubes_norm - temp1 + temp2
            temp1 = 4.0 * self.mean * sum_of_cubes_norm
            temp2 = 6.0 * mean_sq * sum_of_squares_norm  
            temp3 = 3.0 * mean_sq * mean_sq
            m4 = sum_of_4th_powers_norm - temp1 + temp2 - temp3

            if self.buffer.count > 1:
                self.variance = m2 * self.buffer.count / (self.buffer.count - 1.0)
                if self.buffer.count > 2 and m2 > 1e-12:
                    sqrt_m2 = sqrt(m2)
                    self.skewness = m3 / (m2 * sqrt_m2) * sqrt(self.buffer.count * (self.buffer.count - 1.0)) / (self.buffer.count - 2.0)
                    if self.buffer.count > 3:
                        self.kurtosis = ((self.buffer.count - 1.0) * ((self.buffer.count + 1.0) * (m4 / (m2 * m2) - 3.0) + 6.0)) / ((self.buffer.count - 2.0) * (self.buffer.count - 3.0))
                    else:
                        self.kurtosis = 0.0
                else:
                    self.skewness = 0.0
                    self.kurtosis = 0.0
            else:
                self.variance = 0.0
                self.skewness = 0.0
                self.kurtosis = 0.0
        else:
            self.mean = 0.0
            self.variance = 0.0
            self.skewness = 0.0
            self.kurtosis = 0.0
    
    cpdef list[double] get(self):
        return [self.summary, self.mean, self.variance, self.skewness, self.kurtosis]