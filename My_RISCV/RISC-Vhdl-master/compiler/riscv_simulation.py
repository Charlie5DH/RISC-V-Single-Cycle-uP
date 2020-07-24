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


import riscv_parser
import sys, getopt, ntpath, os
import json
import math
import time
from threading import Timer

timer_expired = False


regs = [0] * 32
pc = 0
branch = False


bram = [0] * 2048
cram = [0] * 2048
ddr2ram = [0] * 0x10000
ioram = [0]*4
pram = [0] * 2048

ram = {0:bram, 1:cram, 2:ddr2ram, 3:ioram, 4:pram}

reg_last_set = []
ram_last_set = []

breakpoints = set([0x40000000])

symbols = {}

def val_to_int(val):
    if val & 0x80000000:
        val -= 1
        val = ~val
        val &= 0xFFFFFFFF
        return 0-val
    return val

def ipow(base, exp):
    return int(math.pow(base, exp))

def reg_set(reg, val):
    val = val & 0xFFFFFFFF
    if reg == "pc":
        global pc
        reg_last_set.append(("pc", reg_get("pc")))
        pc = val
        return
    if reg: 
        reg_last_set.append((reg, regs[reg]))
        regs[reg] = val

def reg_get(reg):
    if reg == "pc": return pc
    return regs[reg]

def ram_get(addr):
    try:
        prefix = int(addr / 0x10000000)
        block = ram[prefix]
        offset = addr % len(block)
        return block[offset]
    except Exception as e:
        print("%d is not a valid prefix."% prefix)
        raise e

def ram_set(addr, val):
    val = val & 0xFF
    try:
        prefix = int(addr / 0x10000000)
        block = ram[prefix]
        offset = addr % len(block)
        ram_last_set.append((prefix, offset, block[offset]))
        block[offset] = val
    except Exception as e:
        print("%d is not a valid prefix."% prefix)
        raise e

def bitfield_at(value, bfrom, bto):
    mask = int(math.pow(2, bto-bfrom)) - 1
    value = int(value / math.pow(2, bfrom)) & mask
    return value

def process(cmd, show):
    reg_last_set = []
    ram_last_set = []
    opcode = bitfield_at(cmd, 0, 7)
    try: p = inst_dict[opcode]
    except Exception as e:
        print("%s is not a valid opcode."% opcode)
        raise e
    p(cmd, show)


def sign_extend(value, msb):
    if value & int(math.pow(2, msb)):
        mask = (int(math.pow(2, 31-msb))-1) << (msb+1)
        return value | mask

    return value

def process_lui(cmd, show):
    rd = bitfield_at(cmd, 7, 12)
    imm = bitfield_at(cmd, 12, 32)
    if show: 
        print("lui %s, %s"%( reg_to_str(rd), off_to_str(imm)))
        return
    reg_set(rd, imm * 0x1000)

def process_auipc(cmd, show):
    rd = bitfield_at(cmd, 7, 12)
    imm = bitfield_at(cmd, 12, 32) * 0x1000
    imm += reg_get("pc")
    if show: 
        print("auipc %s, %s", reg_to_str(rd), off_to_str(imm))
        return
    reg_set(rd, imm)

def process_jal(cmd, show):
    global branch
    rd = bitfield_at(cmd, 7, 12)
    imm_enc = bitfield_at(cmd, 12, 32)
    imm = bitfield_at(imm_enc, 9, 19) * 2
    imm += int(math.pow(2, 11)) * bitfield_at(imm_enc, 8, 9)
    imm += int(math.pow(2, 12)) * bitfield_at(imm_enc, 0, 8)
    imm += int(math.pow(2, 20)) * bitfield_at(imm_enc, 19, 20)
    imm = int(sign_extend(imm, 20))
    if show: 
        print("jal "+reg_to_str(rd)+", "+off_to_str(reg_get("pc")+imm))
        return
    reg_set(rd, reg_get("pc")+4)
    reg_set("pc", reg_get("pc")+imm)
    branch = True


def print_regs():
     s = "Register state, pc = "+off_to_str(reg_get("pc"))+"\n\t"
     for i in range (0, 32):
         s += "x"+(str(i)).zfill(2)+": "+"{0:#0{1}x}".format(reg_get(i),10)+"   "
         if i % 4 == 3: s += "\n\t"
     print(s[:-1]+"Executing next:")


def load_binary(binary):
    try:
        for i in range(0, len(binary)):
            #bram[i] = binary[i]
            pram[i] = binary[i]
    except Exception as e:
        print("Bram does not provide enough space to store %d bytes", len(binary))
        raise e
    
def load_symbols(symtable):
    for key in symtable:
        symbols[symtable[key]] = key

def off_to_str(offset, sym_resolve=True):
    offset = offset & 0xFFFFFFFF
    if sym_resolve: 
        if offset in symbols:
            return "."+symbols[offset]+" (="+"{0:#0{1}x}".format(offset, 10)+")"
    return "="+"{0:#0{1}x}".format(offset, 10)

def reg_to_str(reg):
    return "x"+str(reg).zfill(2)


def printchars(binary=False):
    screen = ""
    for i in range(0, 32):
        for j in range(0, 64):
            v = ram_get(0x20000000 + i * 64 + j)
            if binary: screen += '{:02X}'.format(v) + " "
            else: screen += str(chr(v))
        screen += "\n"
    print(screen)


def main(argv):
    try:
        opts, args = getopt.getopt(argv, "b:s:h:")
    except getopt.GetoptError:
        sys.exit(2)

    symfile = None
    binfile = None
    
    #Parse the options
    for opt, arg in opts:
        if opt == "-s":
            symfile = arg
        if opt == "-b":
            binfile = arg
        if opt == "-h":
            print("Usage: python riscv_simulation.py -s {symboltable} -b {binary}")
    
    if not symfile:
        print("Missing symbol file.")
        raise
    if not binfile:
        print("Missing binary file.")
        raise

    symfile = open(symfile, "r+")
    load_symbols(json.loads(symfile.read()))
    symfile.close()

    binfile = open(binfile, "rb")
    load_binary(binfile.read())
    binfile.close()

    debug()


def process_jalr(cmd, show):
    global branch
    rd = bitfield_at(cmd, 7, 12)
    rs = bitfield_at(cmd, 15, 20)
    imm = sign_extend(bitfield_at(cmd, 20, 32), 11)
    if show: 
        print("jalr %s, %s, %s" % ( reg_to_str(rd), reg_to_str(rs), off_to_str(reg_get(rs)+imm)))
        return
    reg_set(rd, reg_get("pc")+4)
    reg_set("pc", reg_get(rs)+imm)
    branch = True


def process_cbranch(cmd, show):
    global branch
    imm = bitfield_at(cmd, 8, 12) * 2
    imm |= bitfield_at(cmd, 7, 8) * ipow(2, 11)
    imm |= bitfield_at(cmd, 25, 31) * ipow(2, 5)
    imm |= bitfield_at(cmd, 31, 32) * ipow(2, 12)
    imm = sign_extend(imm, 12)
    pc_new = reg_get("pc") + imm
    funct3 = bitfield_at(cmd, 12, 15)
    rs1 = bitfield_at(cmd, 15, 20)
    rs2 = bitfield_at(cmd, 20, 25)
    if funct3 == 0:
        mnem = "beq"
        branch = reg_get(rs1) == reg_get(rs2)
    elif funct3 == 1:
        mnem = "bne"
        branch = reg_get(rs1) != reg_get(rs2)
    elif funct3 == 4:
        mnem = "blt"
        branch = val_to_int(reg_get(rs1)) < val_to_int(reg_get(rs2))
    elif funct3 == 5:
        mnem = "bge"
        branch = val_to_int(reg_get(rs1)) >= val_to_int(reg_get(rs2))
    elif funct == 6:
        mnem = "bltu"
        branch = reg_get(rs1) < reg_get(rs2)
    elif funct == 7:
        mnem = "bgeu"
        branch = reg_get(rs1) >= reg_get(rs2)
    else:
        print("Funct3 %s is not a valid funct3-branch enconding." % funct3)
        raise
    if show: 
        print("%s %s, %s, %s $%s" % (mnem,  reg_to_str(rs1), reg_to_str(rs2),
        off_to_str(pc_new), branch))
        return
    if branch:
        reg_set("pc", pc_new)

def process_xi(cmd, show):
    rd = bitfield_at(cmd, 7, 12)
    funct3 = bitfield_at(cmd, 12, 15)
    rs1 = bitfield_at(cmd, 15, 20)
    shamt = bitfield_at(cmd, 20, 25)
    funct7 = bitfield_at(cmd, 25, 32)
    imm = sign_extend(bitfield_at(cmd, 20, 32), 11)
    rs1_val = reg_get(rs1)
    int_imm = val_to_int(imm)
    int_rs1 = val_to_int(rs1_val)
    if funct3 == 0:
        mnem = "addi"
        r = rs1_val + imm
    elif funct3 == 2:
        mnem = "slti"
        r = 1 if int_rs1 < int_imm else 0
    elif funct3 == 3:
        mnem = "stliu"
        r = 1 if rs1_val < imm else 0
    elif funct3 == 4:
        mnem = "xori"
        r = rs1_val ^ imm
    elif funct3 == 6:
        mnem = "ori"
        r = rs1_val | imm
    elif funct3 == 7:
        mnem = "andi"
        r = rs1_val & imm
    elif funct3 == 1:
        mnem = "slli"
        r = rs1_val << shamt
        imm = shamt
    elif funct3 == 5:
        r = rs1_val >> shamt
        imm = shamt
        if shamt == 0x40:
            mnem = "srai"
            fill = ipow(2, shamt)-1
            fill *= ipow(2, 32-shamt)
            r |= fill
        else:
            mnem = "srli"
    if show: 
        print("%s %s, %s, %s"%( mnem, reg_to_str(rd), reg_to_str(rs1), off_to_str(imm)))
        return
    reg_set(rd, r)


def process_lx(cmd, show):
    rd = bitfield_at(cmd, 7, 12)
    funct3 = bitfield_at(cmd, 12, 15)
    rs1 = bitfield_at(cmd, 15, 20)
    src = reg_get(rs1)
    imm = sign_extend(bitfield_at(cmd, 20, 32), 11)
    src += imm   
    signed = True
    if funct3 == 0:
        mnem = "lb"
        size = 1
    elif funct3 == 1:
        mnem = "lh"
        size = 2
    elif funct3 == 2:
        mnem = "lw"
        size = 4
    elif funct3 == 4:
        mnem = "lbu"
        size = 1
        signed = False
    elif funct3 == 5:
        mnem = "lhu"
        size = 2
        signed = False
    if show:
        print("%s %s, %s, %s"%(mnem, reg_to_str(rd), reg_to_str(rs1), off_to_str(imm)))
        return
    read = 0
    for i in range(0, size):
        read |= ram_get(src+i) * ipow(2, i*8)
    if signed: read = sign_extend(read, (size*8)-1)
    reg_set(rd, read)
    
def process_sx(cmd, show):
    imm = bitfield_at(cmd, 7, 12)
    imm |= bitfield_at(cmd, 25, 32) * ipow(2, 5)
    funct3 = bitfield_at(cmd, 12, 15)
    rs1 = bitfield_at(cmd, 15, 20)
    rs2 = bitfield_at(cmd, 20, 25) 
    dst = reg_get(rs1) + imm
    val = reg_get(rs2)

    if funct3 == 0:
        mnem = "sb"
        size = 1
    elif funct3 == 1:
        mnem = "sh"
        size = 2
    elif funct3 == 2:
        mnem = "sw"
        size = 4
    else:
        print("%s is not a valid width for store."%funct3)
    if show: 
        print("%s %s, %s, %s"%(mnem, reg_to_str(rs1), reg_to_str(rs2), off_to_str(imm)))
        return

    for i in range(0, size):
        ram_set(dst+i, val&0xFF)
        val = val >> 8
    
def process_ax(cmd, show):
    err = None
    rd = bitfield_at(cmd, 7, 12)
    funct3 = bitfield_at(cmd, 12, 15)
    rs1 = bitfield_at(cmd, 15, 20)
    rs2 = bitfield_at(cmd, 20, 25)
    funct7 = bitfield_at(cmd, 25, 32)
    rs1_val = reg_get(rs1)
    rs2_val = reg_get(rs2)
    int_rs2 = val_to_int(rs2_val)
    int_rs1 = val_to_int(rs1_val)
    if funct7 == 1:
        #M-Extension
        if funct3 == 0:
            mnem = "mul"
            r = rs1_val * rs2_val
        elif funct3 == 1:
            mnem = "mulh"
            r = int_rs1 * int_rs2
            r = r >> 32
        elif funct3 == 2:
            mnem = "mulhsu"
            r = int_rs1 * rs2_val
            r = r >> 32
        elif funct3 == 3:
            mnem = "mulhu"
            r = rs1_val * rs2_val
            r = r >> 32
        elif funct3 == 4:
            mnem = "div"
            if int_rs2:
                r = int(int_rs1 / int_rs2)
            else: err = "Division by zero."
        elif funct3 == 5:
            mnem = "divu"
            if rs2_val:
                r = int(rs1_val / rs2_val)
            else: err = "Division by zero."
        elif funct3 == 6:
            mnem = "rem"
            if int_rs2:
                div = int(int_rs1 / int_rs2)
                r = int_rs1 - (div * int_rs2)
            else: err = "Division by zero."
        elif funct3 == 7:
            mnem = "remu"
            if rs2_val:
                div = int(rs1_val / rs2_val)
                r = rs2_val - (div * rs2_val)
            else: err = "Division by zero."



    else:   
        if funct3 == 0:
            if funct7 == 0x0:
                mnem = "add"
                r = rs1_val + rs2_val
            else:
                mnem = "sub"
                r = rs1_val - rs2_val
        elif funct3 == 2:
            mnem = "slt"
            r = 1 if int_rs1 < int_rs2 else 0
        elif funct3 == 3:
            mnem = "stli"
            r = 1 if rs1_val < rs2_val else 0
        elif funct3 == 4:
            mnem = "xor"
            r = rs1_val ^ rs2_val
        elif funct3 == 6:
            mnem = "or"
            r = rs1_val | rs2_val
        elif funct3 == 7:
            mnem = "and"
            r = rs1_val & rs2_val
        elif funct3 == 1:
            if rs2_val > 32:
                err = "Shift amount too high "+str(rs2_val)+"."
            mnem = "sll"
            r = rs1_val << rs2_val
        elif funct3 == 5:
            if rs2_val > 32:
                err = "Shift amount too high "+str(rs2_val)+"."
            r = rs1_val >> rs2_val
            if shamt == 0x40:
                mnem = "sra"
                fill = ipow(2, rs2_val)-1
                fill *= ipow(2, 32-rs2_val)
                r |= fill
            else:
                mnem = "srl"
    if show:
        try: print("%s %s, %s, %s"%( mnem, reg_to_str(rd), reg_to_str(rs1), off_to_str(imm)))
        except: print("%s %s, %s, %s"%( mnem, reg_to_str(rd), reg_to_str(rs1), reg_to_str(rs2)))
        return
    if err:
        print(err)
        raise
    reg_set(rd, r)

def pins_show():
    # |    0x0    |    0x1    |    0x2    |    0x3     |
    # | p_in(7-0) | p_in(15-8)| p_out(7-0)| p_out(15-8)|
    # p_in: 15-12: Switches
    # p_in: 11-7: Buttons
    # p_in: 6-0: None
    # p_out: 0-0: LED
    p_in = ram_get(0x30000000) | ((ram_get(0x30000001)) * 256)
    p_out = ram_get(0x30000002) | ((ram_get(0x30000003)) * 256)
    s = "Pin State:\n\tSwitches:\n"
    for i in range (0, 4):
        s += "\t\tSWITCH_"+str(i)+": "+str(1 if p_in & (0x1000 << i) else 0) + "\n"
    s += "\tButtons:\n"
    for i in range(0, 5):
        s += "\t\tBUTTON_"+str(i)+": "+str(1 if p_in & (0x80 << i) else 0) + "\n"
    s += "\tLeds:\n"
    s += "\t\tLED_0: "+str(p_out & 1)+"\n"
    print(s)

def pin_set(pin, val):
    pins = 0
    for i in range (0, 4):
        pins |= ram_get(0x30000000+i) * ipow(2, 8*i)

    tokens = pin.split("_")
    pin_class = tokens[0].lower()
    pin_id = int(tokens[1])
    if pin_class == "switch":
        if pin_id > 3:
            print("Invalid pin_id for pin_class SWITCH")
            return
        mask = 0x1000 << pin_id
    elif pin_class == "button":
        if pin_id > 4:
            print("Invalid pin_id for pin_class BUTTON")
            return
        mask = 0x80 << pin_id
    elif pin_class == "led":
        if pin_id > 0:
            print("Invalid pin_id for pin_class LED")
            return
        mask = 0x10000 << pin_id
    
    if val:
        pins |= mask
    else:
        pins &= (~mask)
    
    #Write back
    for i in range(0, 4):
        ram_set(0x30000000+i, pins&0xFF)
        pins = pins >> 8


def memdump(offset, size, chunksize):
    s = "Memdump of offset "+off_to_str(offset)+":\n"
    for i in range(0, size):
        if i % chunksize == 0: s += off_to_str(offset+i, sym_resolve=False)+": "
        s += '{:02X}'.format(ram_get(offset+i)) + " "
        if i % chunksize == chunksize-1: s += "\n"
    print(s)
        




inst_dict = {
    0x37:process_lui,
    0x17:process_auipc,
    0x6F:process_jal,
    0x67:process_jalr,
    0x63:process_cbranch,
    0x13:process_xi,
    0x3:process_lx,
    0x23:process_sx,
    0x33:process_ax,
}
    
def timer_expire():
    global timer_expired
    timer_expired = True


def pin_timer_apply(pin_id, val):
    print("Timer forces pin %s to %s."%(pin_id, val))
    pin_set(pin_id, val)

def debug():
    global pc
    global branch
    global timer_expired
    pc = 0x40000000
    next_breakpoint = 0x40000000
    try:
        while True:
            
            #Fetching the command
            cycle_pc = reg_get("pc")
            #for bp in breakpoints: print({off_to_str(bp), cycle_pc})
            cmd = 0
            for i in range(0, 4):
                cmd += ram_get(cycle_pc+i) * int(math.pow(2, 8*i))
            bp_on_next = False #Dont force breakpoint on next command unless forced
            if cycle_pc in breakpoints or timer_expired:
                timer_expired = False
                if next_breakpoint != -1: 
                    breakpoints.remove(next_breakpoint)
                    next_breakpoint = -1 #We removed a breakpoint of kind "next"
                print_regs()
                process(cmd, True)
                while True:
                    usr_cmd = input(">>>").lower()
                    if usr_cmd in ("n", "next"):
                        bp_on_next = True
                        break
                    elif usr_cmd in ("s", "skip"):
                        next = reg_get("pc") + 4
                        if next not in breakpoints: next_breakpoint = next
                        break
                    elif usr_cmd in ("c", "continue"):
                        break
                    elif usr_cmd in ("printchars"):
                        printchars()
                    else:
                        tokens = usr_cmd.split(" ")
                        if tokens[0] in ("bp", "bpa", "breakpoint"):
                            try: off = int(tokens[1], 0)
                            except:
                                off = -1
                                for sym in symbols:
                                    if symbols[sym] == tokens[1]:
                                        off = sym
                                        break
                            if off == -1: print("Could not set breakpoint to this offset")
                            else: 
                                breakpoints.add(off)
                                print("Added breakpoint on %s."% tokens[1])
                        elif tokens[0] in ("printchars"):
                            flag = tokens[1]
                            if tokens[1] == "-b": printchars(binary=True)
                        elif tokens[0] in ("pin"):
                            try:
                                opt = tokens[1]
                                if tokens[1] == "show":
                                    pins_show()
                                if tokens[1] == "set":
                                    pin_id = tokens[2]
                                    val = int(tokens[3])
                                    pin_set(pin_id, val)
                                    if len(tokens) == 6 and tokens[4].lower() == "-d":
                                        Timer(int(tokens[5]), pin_timer_apply, (pin_id, val^1)).start()
                                        print("Pin %s will switch its value in %s s."%(pin_id, int(tokens[5])))
                                        Timer(int(tokens[5])+1, timer_expire, ()).start()
                                        break

                            except Exception as e:
                                print("Pin request failed.\nUsage: pin show / pin set {PIN_NAME} {PIN_VALUE(0;1)} [-d {DURATION in s}]")
                                raise e

                        elif tokens[0] in ("m, memdump", "mb"):
                            try:
                                try: off = int(tokens[1], 0)
                                except:
                                    off = -1
                                    for sym in symbols:
                                        if symbols[sym] == tokens[1]:
                                            off = sym
                                            break
                                    if off == -1: 
                                        print("Value is neither offset nor a known symbol.")
                                        raise
                                size = int(tokens[2])
                                try: chunksize = int(tokens[3])
                                except: chunksize = 16
                                memdump(off, size, chunksize)

                            except Exception as e:
                                print("Memdump request failed.\nUsage: m {offset} {size} [{chunksize=16}]")
                        
                        elif tokens[0] in ("t", "timer", "sleep"):
                            try:
                                s = int(tokens[1], 0)
                                Timer(s, timer_expire, ()).start()
                                break

                            except Exception as e:
                                print("Debug sleep failed.")
                                raise e

                                

            process(cmd, False) #Execute the command we halted at
            if not branch: reg_set("pc", reg_get("pc")+4) #Update pc
            branch = False

            if bp_on_next:
                next = reg_get("pc")
                #print("next bp is forced to ", next)
                if next not in breakpoints:
                    next_breakpoint = next
            if next_breakpoint: breakpoints.add(next_breakpoint)

    except Exception as e: 
        print("Error at offset := ", off_to_str(pc))
        raise e          


if __name__ == "__main__":
        main(sys.argv[1:])

