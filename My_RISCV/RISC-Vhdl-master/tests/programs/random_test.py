# VHDL implementation of RISC-V-ISA
# Copyright (C) 2016 Chair of Computer Architecture
# at Technical University of Munich
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


import random
import math

def double_dif (a, b):
    return (a/b) << 16


def double_pow(a, b):
    n = 1
    for i in range(0, b):
        n = double_mul(n, a)
    return n

def double_mul(a, b):
    a = a >> 8
    b = b >> 8
    return a*b

def sin(x):
    s = 0x28BE93CB #magic number (0x100000000 / 2 pi as 16-bit double)
    i = int(x / s)
    value = i
    value -= int(double_pow(i, 3) / 6)
    value += int(double_pow(i, 5) / 120)
    value -= int(double_pow(i, 7) / 5040)
    return value


for i in range(0, 0x10000, 0x100):
    print(sin(i * 0x10000))
    



