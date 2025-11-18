# cython: language_level=3
from libc.math cimport sqrt
from libc.stdlib cimport malloc, free
import cython

@cython.final
cdef class WelfordWindow:
    cdef readonly:
        int window_size
        int quantity
        int current_index
        double summary, maximal, minimal, mean, variance, skewness, kurtosis
    cdef:
        double *window
        double sum_of_squares, sum_of_cubes, sum_of_4th_powers
    
    def __cinit__(self, int window_size, object values = None):
        self.window_size = window_size
        self.quantity = 0
        self.summary = 0.0
        self.maximal = 0.0
        self.minimal = 0.0
        self.mean = 0.0
        self.variance = 0.0
        self.skewness = 0.0
        self.kurtosis = 0.0
        self.sum_of_squares = 0.0
        self.sum_of_cubes = 0.0
        self.sum_of_4th_powers = 0.0
        self.current_index = 0
        
        self.window = <double*> malloc(window_size * sizeof(double))
        
        if values:
            for val in values:
                self.update(val)
    
    def __dealloc__(self):
        if self.window != NULL:
            free(self.window)
    
    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    def update(self, double value):
        cdef:
            double old_value
            double value_sq, value_cube, value_4th
            double old_sq, old_cube, old_4th

            double inv_q, m2, m3, m4, sqrt_m2
            double sum_of_squares_norm, sum_of_cubes_norm, sum_of_4th_powers_norm
            double mean_sq, mean_cube, mean_4th
            double temp1, temp2, temp3

            double current_extremal = self.window[0]
            double val
            int i
        
        value_sq = value * value
        value_cube = value_sq * value
        value_4th = value_cube * value
        
        if self.quantity >= self.window_size:
            old_value = self.window[self.current_index]
            
            old_sq = old_value * old_value
            old_cube = old_sq * old_value
            old_4th = old_cube * old_value
            
            self.summary -= old_value
            self.sum_of_squares -= old_sq
            self.sum_of_cubes -= old_cube
            self.sum_of_4th_powers -= old_4th
        else:
            self.quantity += 1
        
        self.window[self.current_index] = value
        self.current_index = (self.current_index + 1) % self.window_size
        
        self.summary += value
        self.sum_of_squares += value_sq
        self.sum_of_cubes += value_cube
        self.sum_of_4th_powers += value_4th
        
        if self.quantity == 1:
            self.maximal = value
            self.minimal = value
        else:
            if value > self.maximal:
                self.maximal = value
            elif value < self.minimal:
                self.minimal = value
            
            if old_value == self.maximal:                
                for i from 1 <= i < self.quantity:
                    val = self.window[i]
                    if val > current_extremal:
                        current_extremal = val
                        if current_extremal == self.maximal:
                            break
                self.maximal = current_extremal
            elif old_value == self.minimal:
                for i from 1 <= i < self.quantity:
                    val = self.window[i]
                    if val < current_extremal:
                        current_extremal = val
                        if current_extremal == self.minimal:
                            break
                self.minimal = current_extremal
        
        if self.quantity > 0:
            inv_q = 1.0 / self.quantity
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

            if self.quantity > 1:
                self.variance = m2 * self.quantity / (self.quantity - 1.0)
                if self.quantity > 2 and m2 > 1e-12:
                    sqrt_m2 = sqrt(m2)
                    self.skewness = m3 / (m2 * sqrt_m2) * sqrt(self.quantity * (self.quantity - 1.0)) / (self.quantity - 2.0)
                    if self.quantity > 3 and m2 > 1e-12:
                        self.kurtosis = ((self.quantity - 1.0) * ((self.quantity + 1.0) * (m4 / (m2 * m2) - 3.0) + 6.0)) / ((self.quantity - 2.0) * (self.quantity - 3.0))
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
        
        return (
            self.quantity, self.summary, self.maximal, self.minimal, 
            self.mean, self.variance, self.skewness, self.kurtosis
        )
    
    def get_stats(self):
        return (
            self.quantity, self.summary, self.maximal, self.minimal, 
            self.mean, self.variance, self.skewness, self.kurtosis
        )
