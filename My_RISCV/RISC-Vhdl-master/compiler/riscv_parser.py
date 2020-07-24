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


import riscv_linker as linker

def parse_string(string):
	"""parses a linebreak seperated instruciton string"""
	lines = string.split("\n")
	symbols = {}
	object = []
	line_nr = 0
	for line in lines:
		parse_line(line, symbols, object, line_nr)
		line_nr += 1
	linked = linker.linker(symbols, object)
	return (linked[0], linked[1], symbols)

	
def parse_line(line, symbols, object, line_nr):
	"""parse a single line"""
	line = line.strip("\t")
	line = line.strip(" ")
	if len(line):
		if(line[0] == '.'):
			#add a symbol
			symbols[line[1:]] = len(object)*4
		else:
			object.append((line_nr, line, len(object)*4))
