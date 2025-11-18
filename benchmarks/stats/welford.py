from collections import deque
from math import sqrt
from time import time
from jacktools.stats import WelfordWindow
from random import randint


def _welford_window(
    window_size: int,
    quantity: int = 0,
    summary: int | float = 0,
    maximum: int | float = 0,
    minimum: int | float = 0,
    mean: float = 0.0,
    variance: float = 0.0,
    skewness: float = 0.0,
    kurtosis: float = 0.0,
    sum_of_squares: int | float = 0,
    sum_of_cubes: int | float = 0,
    sum_of_4th_powers: float = 0
):
    '''Класический генератор реализующий окно через деку'''
    window = deque()
    s1 = summary
    s2 = sum_of_squares
    s3 = sum_of_cubes
    s4 = sum_of_4th_powers

    max_val = maximum
    min_val = minimum

    while True:
        value = yield (
            quantity, s1, max_val, min_val, mean,
            variance, skewness, kurtosis,
            s2, s3, s4
        )

        window.append(value)

        if quantity < window_size:
            quantity += 1
        else:
            old_value = window.popleft()
            s1 -= old_value
            s2 -= old_value ** 2
            s3 -= old_value ** 3
            s4 -= old_value ** 4

            if old_value == max_val:
                max_val = max(window) if window else value
            if old_value == min_val:
                min_val = min(window) if window else value

        s1 += value
        s2 += value ** 2
        s3 += value ** 3
        s4 += value ** 4

        if quantity == 1:
            max_val = min_val = value
        else:
            if value > max_val:
                max_val = value
            if value < min_val:
                min_val = value

        if quantity > 0:
            mean = s1 / quantity
            m2 = s2 / quantity - mean * mean
            m3 = s3 / quantity - 3 * mean * (s2 / quantity) + 2 * (mean ** 3)
            m4 = s4 / quantity - 4 * mean * (s3 / quantity) + 6 * (mean ** 2) * (s2 / quantity) - 3 * (mean ** 4)

            if quantity > 1:
                variance = (quantity / (quantity - 1)) * m2
            else:
                variance = 0.0

            if quantity > 2 and m2 > 0:
                g1 = m3 / (m2 ** 1.5)
                skewness = (sqrt(quantity * (quantity - 1)) / (quantity - 2)) * g1
            else:
                skewness = 0.0

            if quantity > 3 and m2 > 0:
                g2 = m4 / (m2 ** 2) - 3
                kurtosis = ((quantity - 1) / ((quantity - 2) * (quantity - 3))) * (((quantity + 1) * g2) + 6)
            else:
                kurtosis = 0.0
        else:
            mean = 0.0
            variance = 0.0
            skewness = 0.0
            kurtosis = 0.0

        summary = s1
        sum_of_squares = s2
        sum_of_cubes = s3
        sum_of_4th_powers = s4


def bench_welford_window():
    """Сравнение с чистой Python реализацией"""
    print("=== bench_welford_window ===\n")
    
    test_size = 100000
    window_size = 10
    data = [randint(0,100) for _ in range(test_size)]

    start_time = time()
    welford_cy = WelfordWindow(window_size)
    for value in data:
        stats_cy = welford_cy.update(value)
    cython_time = time() - start_time
    
    print(f"Cython: {cython_time:.4f} сек, {test_size/cython_time:.0f} оп/сек")
    
    start_time = time()
    welford_py = _welford_window(window_size)
    next(welford_py)  
    for value in data:
        stats_py = welford_py.send(value)
    python_time = time() - start_time
    
    print(f"Python: {python_time:.4f} сек, {test_size/python_time:.0f} оп/сек")
    print(f"Ускорение: {python_time/cython_time:.2f}x")
