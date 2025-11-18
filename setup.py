from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize
import sys

if sys.platform == 'win32':
    extra_compile_args = ['/O2', '/fp:fast', '/arch:AVX2', '/openmp']
    extra_link_args = []
else:
    extra_compile_args = ['-O3', '-ffast-math', '-march=native', '-fopenmp']
    extra_link_args = ['-fopenmp']

extensions = [
    Extension(
        "jacktools.stats.welford.welford_window",  # Полный путь к модулю
        ["jacktools/stats/welford/welford_window.pyx"],
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_link_args,
        define_macros=[('NPY_NO_DEPRECATED_API', 'NPY_1_7_API_VERSION')],
        language="c"
    )
]

setup(
    ext_modules=cythonize(
        extensions,
        annotate=False,
        compiler_directives={
            'language_level': 3,
            'boundscheck': False,
            'wraparound': False,
            'initializedcheck': False,
            'nonecheck': False,
            'cdivision': True,
            'optimize.use_switch': True,
            'optimize.unpack_method_calls': True,
        }
    ),
    zip_safe=False,
)