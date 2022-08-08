//import required libraries
import java.util.HexFormat;
import java.util.Scanner;
/**
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
 
 */

class main {
    public static void main(String[] args) {
       //Open the file and read the contents
        Scanner input = new Scanner(System.in);
        System.out.println("Enter the file name: ");
        String fileName = input.nextLine();
        Scanner file = new Scanner(System.in);
        file.useDelimiter("\\Z");
        String fileContents = file.next();
        //Split the file contents into lines
        String[] lines = fileContents.split("\n");
        //Create a new compiler object
        compiler compiler = new compiler();
        //Compile the file
        compiler.compile(lines);
        //Print the compiled code
        System.out.println(compiler.getCompiledCode());

    }
}
//create a class called compiler
class compiler {
    //create a string to store the compiled code
    String compiledCode = "";
    //create a method to compile the file
    public void compile(String[] lines) {
        
        //define keywords using the opcodes
        String[] Token = {"SET","ADD", "SUB", "MUL", "DIV", "CMP", "JMP", "JEQ", "JFZ", "JFL", "JFG", "ADS","NOP","ADF","SBF",};
        Integer[] TokenValue = {0x81,0x02,0x03,0x04,0x05,0x06,0x47,0x48,0x49,0x4A,0x4B,0x07};
        //loop through the lines
        for (int i = 0; i < lines.length; i++) {
            //split the line into tokens
            String[] tokens = lines[i].split(" ");
            //check if the first token is a keyword

            
}