#!/usr/bin/env python3

from distutils.core import setup

setup(name='Snappy',
      version='0.1',
      description='SNAP GUI in python',
      author='Heiko Klein',
      author_email='Heiko.Klein@met.no',
#      url='https://www.python.org/sigs/distutils-sig/',
      packages=['Snappy'],
      package_dir={'Snappy': 'Snappy'},
      package_data={'Snappy': ['resources/*']},
      scripts=['snappy']
)
