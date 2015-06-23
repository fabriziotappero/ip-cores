#!/usr/bin/env python

from distutils.core import setup

setup(name="Chips",
      version="0.1.2",
      description="Design hardware with Python",
      long_description="""\

Chips
-----

The Chips library allows hardware devices to be designed in python and C

Features

- Design components in C

- Connect components together using a python API to generate a chip

- Automatic generation of synthesisable Verilog.

""",

      author="Jon Dawson",
      author_email="chips@jondawson.org.uk",
      url="http://github.com/dawsonjon/Chips-2.0",
      keywords=["Verilog", "FPGA", "C", "HDL", "Synthesis"],
      classifiers = [
          "Programming Language :: Python",
          "License :: OSI Approved :: MIT License",
          "Operating System :: OS Independent",
          "Intended Audience :: Science/Research",
          "Intended Audience :: Developers",
          "Development Status :: 3 - Alpha",
          "Topic :: Scientific/Engineering :: Electronic Design Automation (EDA)",
          "Topic :: Software Development :: Embedded Systems",
          "Topic :: Software Development :: Code Generators",
      ],
      packages=[
          "chips",
          "chips.compiler",
          "chips.api"
      ],
      scripts=[
          "c2verilog"
      ]
)
