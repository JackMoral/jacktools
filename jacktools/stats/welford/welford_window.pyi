from typing import Iterable


class WelfordWindow:
    """
    Высокопроизводительная реализация скользящего окна статистик Welford на Cython.
    
    Вычисляет основные статистические показатели в реальном времени для скользящего окна:
    - Среднее значение
    - Дисперсию (выборочную)
    - Асимметрию (skewness)
    - Эксцесс (kurtosis)
    - Минимум и максимум
    
    Алгоритм оптимизирован для максимальной производительности с использованием Cython.
    
    Args:
        window_size (int): Размер скользящего окна
        values (Iterable[float | int]): Значения для начального рассчёта
    """
    
    def __init__(self, window_size: int, values: Iterable[float | int] = None) -> None:
        """
        Инициализирует объект Welford с заданным размером окна.
        
        Args:
            window_size: Максимальное количество значений в скользящем окне
            values: Значения для предварительного рассчёта
        """
    
    def update(self, value: float) -> tuple[int, float, float, float, float, float, float, float]:
        """
        Добавляет новое значение в окно и возвращает актуальные статистики.
        
        При добавлении нового значения, если окно заполнено, самое старое значение
        удаляется. Все статистики пересчитываются с учетом нового значения.
        
        Args:
            value: Новое числовое значение для добавления в окно
            
        Returns:
        Кортеж из 8 элементов:
            - quantity (int): Текущее количество значений в окне
            - summary (float): Сумма всех значений в окне
            - maximum (float): Максимальное значение в окне
            - minimum (float): Минимальное значение в окне  
            - mean (float): Среднее арифметическое значений в окне
            - variance (float): Выборочная дисперсия значений в окне
            - skewness (float): Коэффициент асимметрии (skewness)
            - kurtosis (float): Коэффициент эксцесса (kurtosis)
        """
        ...
    
    def get_stats(self) -> tuple[int, float, float, float, float, float, float, float]:
        """
        Возвращает текущие статистики без обновления окна.
        
        Returns:
            Кортеж из 8 элементов (см. документацию метода update)
        """
        ...
    
    @property
    def window_size(self) -> int:
        """Максимальный размер скользящего окна (только чтение)"""
        ...
    
    @property
    def quantity(self) -> int:
        """Текущее количество значений в окне (только чтение)"""
        ...
    
    @property
    def mean(self) -> float:
        """Текущее среднее значение (только чтение)"""
        ...
    
    @property
    def variance(self) -> float:
        """Текущая выборочная дисперсия (только чтение)"""
        ...
    
    @property
    def skewness(self) -> float:
        """Текущий коэффициент асимметрии (только чтение)"""
        ...
    
    @property
    def kurtosis(self) -> float:
        """Текущий коэффициент эксцесса (только чтение)"""
        ...
    
    @property
    def maximal(self) -> float:
        """Текущее максимальное значение в окне (только чтение)"""
        ...
    
    @property
    def minimal(self) -> float:
        """Текущее минимальное значение в окне (только чтение)"""
        ...
    
    @property
    def summary(self) -> float:
        """Сумма всех значений в окне (только чтение)"""
        ...