from jacktools.stats import WelfordWindow
import sys

def test_welford_window():
    test_data = (2.7, 5.2, 4.9, 3.5, 4.2, 3.1, 2.9, 4.7, 3.3, 4.5, 2.5)
    window_size = 15
    welford = WelfordWindow(window_size, (1.5, 2.3, 4.1, 3.8))
    
    for i in test_data:
        welford.update(i)

    for i in (5.4, 1.2, 1.1, 5.6):
        stats = welford.update(i)

    if sys.platform == 'win32':
        assert stats == (
            15, 54.80000000000001, 5.6, 1.1, 3.653333333333334, 2.0498095238095178, 
            -0.3987238009579166, -0.7519627389138926
        ) , 'test_welford_window выдал неверные данные'
    else:
        assert stats == (
            15, 54.80000000000001, 5.6, 1.1, 3.653333333333334, 2.0498095238095178, 
            -0.39872380095791043, -0.7519627389139034
        )
