from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize
import sys
from glob import glob
from os import cpu_count

if sys.platform == 'win32':
    extra_compile_args = ['/O2', '/fp:fast', '/arch:AVX2', '/openmp']
    extra_link_args = []
else:
    extra_compile_args = ['-O3', '-ffast-math', '-march=native', '-fopenmp']
    extra_link_args = ['-fopenmp']

setup(
    ext_modules=cythonize(
        [
            Extension(
                i.split('.', 1)[0].replace('/', '.'), [i],
                extra_compile_args=extra_compile_args,
                extra_link_args=extra_link_args
            )
            for i in glob('**/*.pyx', recursive=True)
        ],
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
        },
        nthreads=cpu_count()
    ),
    zip_safe=False
)