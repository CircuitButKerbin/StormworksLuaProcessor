--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
--require the io lib
--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    function onLBSimulatorTick(simulator, ticks)
       print(output._bools)
       address = b2h(output._bools)
       if address == nil then address = 0x00000030 end
       --setup virtual memory
       --0x30 to 0x12f will read from the interrupt vector table
       --0x130 to 0xffff will be ROM
       --0xffff to 0xffffffff will be RAM
        if withinrange(address, 0x00000030, 0x0000012f) then 
            file = io.open("./memory/IVT.bin", "r")
        elseif address > 0x0000ffff then
            file = io.open("./memory/ROM.bin", "r")
        elseif address > 0xffffffff then
            file = io.open("./memory/RAM.bin", "rw")
        else error(HardwareException.ACCESS_VIOLATION[2] .. ": " .. address)
            goto End
        end
        --seek to the address, then read the 8 bytes following it
        file:seek("set", address)
        local data = file:read(8)
        --close the file
        file:close()
        --convert the bytes to an array
        local data_array = {}
        for i=1,8 do
            data_array[i] = string.byte(data, i)
        end
        --split the array into groups of 4
        local data_array_split = {}
        for i=1,#data_array,4 do
            data_array_split[#data_array_split+1] = data_array:sub(i,i+3)
        end
        for i=1, 32 do
            simulator:setInputBool(i, data_array_split[1][i])
        end
        --split the latter 3 groups into groups of 2, then convert them to decimal and send them over setInputNumber() indexes 1-6
        for i=1,#data_array_split[2],2 do
            simulator:setInputNumber(i, string.byte(data_array_split[2], i, i+1))
        end
        ::End::
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
line = 0
ticks = 0
text = ''
beginexceution = true
initialized = false
flags = {}


function floatingpointtobinary(float)
--convert a 32-bit floating point into it's bits
    
    
end



touchX,touchY=-1,-1--DO NOT DELETE!

    --Word size is 32 bits
    --DWord size is 64 bits
    --QWord size is 128 bits





    --define our instrucion set. the 2 most significat bits determine the size of the op-code. the rest of the 2 bytes are opcodes, and the rest is operands
    --the opcodes are:
    --0x00: NOP                                                       -- No operation
    --0x81: SET <register> (0xYY) <value> (0xZZZZZZZZ)                -- Set register to a 32 bit value
    --0x02: ADD <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Add 2 unsigned ints together and store in register X
    --0x03: SUB <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Subtract 2 unsigned ints and store in register X
    --0x04: MUL <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Multiply 2 unsigned ints and store in register X
    --0x05: DIV <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Divide 2 unsigned ints and store in register X
    --0x06: CMP <register> (0xYY) <register> (0xZZ)                   -- Compare 2 signed ints and set flags
    --0x47: JMP <address>  (0xZZZZZZZZ)                               -- Jump to address
    --0x48: JEQ <address>  (0xZZZZZZZZ)                               -- Jump to address if equal
    --0x49: JFZ <address>  (0xZZZZZZZZ)                               -- Jump to address if zero
    --0x4A: JFL <address>  (0xZZZZZZZZ)                               -- Jump to address if less than
    --0x4B: JFG <address>  (0xZZZZZZZZ)                               -- Jump to address if greater than
    --0x07: ADS <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Add 2 signed ints together and store in register X
    --0x08: NOP                                                       -- No operation
    --0x09: MGS <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Multiply 2 signed ints and store in register X
    --0x0A: NOP                                                       -- No operation
    --0x0B: ADF <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Add 2 floats together and store in register X
    --0x0C: SBF <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Subtract 2 floats together and store in register X
    --0x0D: MGF <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Multiply 2 floats together and store in register X
    --0x0E: DVF <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Divide 2 floats together and store in register X
    --0x0F: CMF <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Compare 2 floats and set flags
    --0x10: PUSH <register>(0xXX)                                     -- Push register to stack
    --0x11: POP <register> (0xXX)                                     -- Pop register from stack
    --0x12: ASC <register> (0xYY) <register> (0xZZ)                   -- Add 2 signed ints together with carry and store in register X
    --0x13: SBC <register> (0xYY) <register> (0xZZ)                   -- Subtract 2 signed ints with borrow and store in register X
    --0x11: AUC <register> (0xYY) <register> (0xZZ)                   -- Add 2 unsigned ints together with carry and store in register X
    --0x12: NOP                                                       -- No operation
    --0x13: MOV <register> (0xYY) <register> (0xZZ)                   -- Move register Z to register Y
    --0x91: MMR <register> (0xXX) <address> (0xYYYYYYYY)              -- Move word from memory Y to register X
    --0x92: MRM <register> (0xXX) <address> (0xZZZZZZZZ)              -- Move word from register Z to memory X
    --0x93: LDF <register> (0xXX) <address> (0xYYYYYYYY)              -- Load float from IO Y to register X
    --0x94: STF <register> (0xXX) <address> (0xZZZZZZZZ)              -- Store float from register X to IO Z
    --0x14: AND <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Bitwise AND 2 unsigned ints and store in register X
    --0x15: OR <register> (0xXX) <register> (0xYY) <register> (0xZZ)  -- Bitwise OR 2 unsigned ints and store in register X
    --0x16: XOR <register> (0xXX) <register> (0xYY) <register> (0xZZ) -- Bitwise XOR 2 unsigned ints and store in register X
    --0x17: INT <register> (0xXX)                                     -- Call interrupt X
    --0x18: RET                                                       -- Return from interrupt
    --0x19: BIO <register> (0xXX)                                     -- Set IOB to register X
    --0x1A: BIN <register> (0xXX)                                     -- Set register X to INB
    --0x1B: INC <register> (0xXX)                                     -- Increment register X
    --0x1C: DEC <register> (0xXX)                                     -- Decrement register X
    --0x1D: MER <register> <register>                                 -- Move word from effective memory Y to register Z
    --0x1E: EMR <register> <register>                                 -- 


    --define our registers addresses
    --0x00 --REG_ADR                --address register
    --0x01 --REG_EAX                --general purpose register
    --0x02 --REG_EBX                --general purpose register
    --0x03 --REG_ECX                --general purpose register
    --0x04 --REG_EDX                --general purpose register
    --0x05 --REG_ESP                --stack pointer
    --0x06 --REG_EBP                --base pointer
    --0x07 --REG_ESI                --source pointer
    --0x08 --REG_EDI                --destination pointer
    --0x09 --REG_EIP                --instruction pointer
    --0x0A --REG_FLAGS              --flags
    --0x0B --REG_STACK              --stack
    --0x0C --REG_XMM1               --floating point register 
    --0x0D --REG_XMM2               --floating point register
    --0x0E --REG_XMM3               --floating point register
    --0x0F --REG_XMM4               --floating point register
    --0x10 --REG_XMM5               --floating point register
    --0x11 --REG_XMM6               --floating point register

    --define our flags
    --0x12 --FLAG_RES               --reserved LSB
    --0x13 --FLAG_ZERO              --zero flag
    --0x14 --FLAG_SIGN              --sign flag
    --0x15 --FLAG_OVERFLOW          --overflow flag
    --0x16 --FLAG_CARRY             --carry flag
    --0x17 --FLAG_PARITY            --parity flag
    --0x18 --FLAG_TRAP              --trap flag
    --0x19 --FLAG_INTERRUPT         --interrupt flag
    --0x1A --FLAG_DIRECTION         --direction flag
    --0x1B --FLAG_GREATER           --greater flag
    --0x1C --FLAG_LESS              --less flag
    --0x1D --FLAG_EQUAL             --equal flag
    --0x1E --FLAG_BUSY              --busy flag MSB

    --special registers
    --0x2E --REG_INT                --interrupt register (m32)
    --0x2F --REG_ENC                --increment register (m32)
    --define our instructions
    --define interrupt table
    --table is 256 bytes long, starting at 0x30, and ending at 0x12F, each pointer is 4 bytes long, the latter 3 bytes are reserved for the interrupt handler address
    --the table can hold 64 pointers, each pointing to a function
    --0x00 --INT_RES                --reserved
    --0x05 --INT_KEYBOARD           --keyboard interrupt handler
    --0x0A --INT_DIVIDE_ERROR       --divide error interrupt handler
    --0x0F --INT_IO_CHANNEL         --I/O channel interrupt handler
    --0x14 --INT_TIMER              --timer interrupt handler
    --0x19 --INT_PROGRAM_EXCEPTION --program exception interrupt handler
    --0x1E --INT_ILLEGAL_INSTRUCTION--illegal instruction interrupt handler
    --0x23 --INT_MATH_EXCEPTION    --math exception interrupt handler
    --0x28 --INT_BREAKPOINT        --breakpoint interrupt handler
    --0x2D --INT_OVERFLOW          --overflow interrupt handler
    --0x32 --INT_BOUND_EXCEPTION   --bound exception interrupt handler
    --0x37 to 0xDB are reserved for future use
    --0x3C to 0xFF are editable by the user
    

--define hardware exceptions 
--{code, description, isrecoverable}
HardwareException = {}
HardwareException.__index = HardwareException
HardwareException.ILLEGAL_INSTRUCTION=      {0x01,"ILLEGAL INSTRUCTION EXCEPTION",true}
HardwareException.DIVIDE_BY_ZERO =          {0x02,"DIVIDE BY ZERO EXCEPTION",true}
HardwareException.ACCESS_VIOLATION =        {0x03, "ACCESS_VIOLATION",true}
HardwareException.RETURNTABLE_LOOKUP_FAIL = {0x04, "RETURNTABLE_LOOKUP_FAIL",false}
HardwareException.STACK_OVERFLOW =          {0x05, "STACK_OVERFLOW",true}

HardwareIO = {}
--define registers
Registers = {}
Registers.__index = Registers
Registers.ADR = 0x00000000
--general purpose register
Registers.EAX = 0x00000000
--general purpose register
Registers.EBX = 0x00000000
--general purpose register
Registers.ECX = 0x00000000
--general purpose register
Registers.EDX = 0x00000000
--stack pointer
Registers.ESP = 0x00000000
--base pointer
Registers.EBP = 0x00000000
--source pointer
Registers.ESI = 0x00000000
--destination pointer
Registers.EDI = 0x00000000
--instruction pointer
Registers.EIP = 0x00000000
--increment register
Registers.ENC = 0x00000000
--flags
Registers.FLAGS =  0x00000



function throw(exception)
    if exception == HardwareException.ILLEGAL_INSTRUCTION then
        print(HardwareException.ILLEGAL_INSTRUCTION[2])
    elseif exception == HardwareException.DIVIDE_BY_ZERO then
        print(HardwareException.DIVIDE_BY_ZERO[2])
    elseif exception == HardwareException.ACCESS_VIOLATION then
        print(HardwareException.ACCESS_VIOLATION[2])
        print(Registers.EIP)
    elseif exception == HardwareException.RETURNTABLE_LOOKUP_FAIL then
        print(HardwareException.RETURNTABLE_LOOKUP_FAIL[2])
        error(HardwareException.RETURNTABLE_LOOKUP_FAIL[2])
    elseif exception == HardwareException.STACK_OVERFLOW then
        print(HardwareException.STACK_OVERFLOW[2])
    end
end

function btn(value)
 return value == true and 1 or value == false and 0
end

--binary to decimal
function b2d(b)
    print(b)
    --convert the binary array of boolean values to decimal integer
    local d = 0
    for i = 1, #b do
        d = d + btn(b[i]) * 2^(#b-i)
    end
    return d
end
--decimal to binary
function d2b(d)
    local b = {}
    while d > 0 do
        b[#b+1] = d % 2
        d = math.floor(d / 2)
    end
    return b
end

function onTick()
    --set I/O arrays
    offset = 0
    for i=7, 32 do
        HardwareIO.iofloat[i] = input.getNumber(i)
    end
    for i=1, 32 do
        --next 128 bits from memory
        HardwareIO.iobool[i] = input.getBool(i)
    end
    for n=1, 6 do
        local input = input.getNumber(n)
        bin = d2b(input)
        for i in bin do
            HardwareIO.iobool[i+32+offset] = bin[i]
        end
        offset = offset + bin.length
    end



    main()
end
function setflag(flag, value)
    local flags = d2b(Registers.FLAGS)
    if flag == 0x12 then
        flags[1] = value
    elseif flag == 0x13 then
        flags[2] = value
    elseif flag == 0x14 then
        flags[3] = value
    elseif flag == 0x15 then
        flags[4] = value
    elseif flag == 0x16 then
        flags[5] = value
    elseif flag == 0x17 then
        flags[6] = value
    elseif flag == 0x18 then
        flags[7] = value
    elseif flag == 0x19 then
        flags[8] = value
    elseif flag == 0x1A then
        flags[9] = value
    elseif flag == 0x1B then
        flags[10] = value
    elseif flag == 0x1C then
        flags[11] = value
    elseif flag == 0x1D then
        flags[12] = value
    elseif flag == 0x1E then
        flags[13] = value
    end
    Registers.FLAGS = b2d(flags)
end
InternalFlags = {}
InternalFlags.AWAITIO = false
InternalFlags.AWAITIOTIMER = 0
InternalFlags.AWAITIOCOMPLETE = false
InternalFlags.AWAITIOCOMPLETECALLER = 0x00
function getflag(flag)
    local flags = d2b(Registers.FLAGS)
    if flag == 0x12 then
        return flags[1]
    elseif flag == 0x13 then
        return flags[2]
    elseif flag == 0x14 then
        return flags[3]
    elseif flag == 0x15 then
        return flags[4]
    elseif flag == 0x16 then
        return flags[5]
    elseif flag == 0x17 then
        return flags[6]
    elseif flag == 0x18 then
        return flags[7]
    elseif flag == 0x19 then
        return flags[8]
    elseif flag == 0x1A then
        return flags[9]
    elseif flag == 0x1B then
        return flags[10]
    elseif flag == 0x1C then
        return flags[11]
    elseif flag == 0x1D then
        return flags[12]
    elseif flag == 0x1E then
        return flags[13]
    end
end
--function classes end
function main()
print("main")
if InternalFlags.AWAITIO == true then
    if InternalFlags.AWAITIOTIMER > 0 then
        InternalFlags.AWAITIOTIMER = InternalFlags.AWAITIOTIMER - 1
        goto Break
    else
        InternalFlags.AWAITIO = false
        InternalFlags.AWAITIOTIMER = 0
        InternalFlags.AWAITIOCOMPLETE = true
    end
end

if beginexceution then 
    print("Starting")
    beginexceution = false
    Registers.EIP = 0x00000130
    goto fetchmemory
end
    if InternalFlags.AWAITIOCOMPLETE == true and InternalFlags.AWAITIOCOMPLETECALLER == 0x01 then 
        goto fetchmemorycontinue
    else 
        goto skipfetch end

    ::fetchmemory::
    bin = d2b(Registers.EIP)
    if Registers.EIP > 0xffffffff or Registers.EIP < 0x00000030 then
        throw(HardwareException.ACCESS_VIOLATION)
        goto Break
    end
    for i in bin do
        output.setBool(i, bin[i])
    end
    bin = nil
    --await for the memory to be fetched
    InternalFlags.AWAITIO = true
    InternalFlags.AWAITIOTIMER = 3
    goto Break
    ::fetchmemorycontinue::
    InternalFlags.AWAITIO = false
    InternalFlags.AWAITIOTIMER = 0
    InternalFlags.AWAITIOCOMPLETE = false
    InternalFlags.AWAITIOCOMPLETECALLER = 0x00
    --decode the instruction
    hex = b2h(HardwareIO.iobool)
    print(hex)
    ::skipfetch::
    

    ::Break::
end



--binary to string, then to hexadicmal
function b2h(b)
    --convert the binary to decimal
    local d = b2d(b)
    --convert the decimal to hex without using a function
    local h = ""
    while d > 0 do
        h = string.char(d % 16 + 48) .. h
        d = math.floor(d / 16)
    end
end

--hexadecimal to binary
function h2b(h)
    local b = ""
    for i = 1, #h, 2 do
        b = b .. string.char(tonumber(h:sub(i, i + 1), 16))
    end
    return b
end
--calculate fibonacci without recursion
function fibonacci(n)
    local a = 0
    local b = 1
    for i = 1, n do
        local c = a + b
        a = b
        b = c
    end
    return a
end


function withinrange(value, min, max)
    if value >= min and value <= max then
        return true
    else
        return false
    end
end

