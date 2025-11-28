from jacktools.buffer import Buffer
from jacktools.increments import (
    ExtremumsInt, WelfordInt, OverUnderInt, 
    ExtremumsDouble, WelfordDouble,
    ZeroInt2d, OutcomeInt2d
)

def test_buffer_and_increments():

    def test_int():
        extrem = ExtremumsInt()
        welford = WelfordInt()
        over_under = OverUnderInt(5)
        buffer = Buffer(
            5, int, (extrem,welford,over_under), values=[1,2,3,3,1,5,7,8,9]
        )
        buffer.add(2)
        buffer.add(5)
        assert extrem.get() == [9, 2] , 'ExtremumsInt вернул не верные екстримумы'
        assert over_under.get() == [3, 2] , 'OverUnderInt вернул не верный рассчёт'
        welstats = welford.get()
        assert [float(f'{welstats[3]:.8f}'), float(f'{welstats[4]:.5f}')] == [-0.92667853, 0.12987], 'WelfordInt не верно считает'
    
    def test_double():
        extrem = ExtremumsDouble()
        welford = WelfordDouble()
        buffer = Buffer(
            15, float, (extrem, welford), values=(1.5, 2.3, 4.1, 3.8)
        )
        for i in (2.7, 5.2, 4.9, 3.5, 4.2, 3.1, 2.9, 4.7, 3.3, 4.5, 2.5):
            buffer.add(i)
        
        for i in (5.4, 1.2, 1.1, 5.6):
            buffer.add(i)
        
        assert extrem.get() == [5.6, 1.1] , 'ExtremumsDouble вернул не верные екстримумы'
        welstats = welford.get()
        assert [float(f'{welstats[3]:.7f}'), float(f'{welstats[4]:.5f}')] == [-0.3987238, -0.75196], 'WelfordDouble не верно считает'
    
    def test_int_2d():
        zero = ZeroInt2d()
        outcome = OutcomeInt2d()
        buffer = Buffer(
            5, int, (zero,outcome), True, 2,
            values=[[1,0],[2,3],[0,2],[1,1],[3,0]]
        )
        print(outcome.get())
        buffer.add([3,3])
        buffer.add([0,1])
        buffer.add([0,0])
        assert zero.get() == ([1,1,1],[2,3]) , 'ZeroInt2d сделал не верный подсчёт'
        assert outcome.get() == ([1,3,1],[2.0,1.0,2.0]) , 'OutcomeInt2d сделал не верный подсчёт'

    test_int()
    test_double()
    test_int_2d()

    print(f'OK - test_buffer_and_increments')