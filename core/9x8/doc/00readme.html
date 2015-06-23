<!-- Copyright 2012, Sinclair R.F., Inc. -->
<html>
<title>
9-bit opcode, 8-bit data stack-based micro controller
</title>
<body>
<b>9-bit Opcode, 8-bit Data, Stack-Based Micro Controller</b><br/>
Copyright 2012, Sinclair R.F., Inc.<br/><br/>
This document describes the 9-bit opcode, 8-bit data, stack-based
  microcontroller.
<h1>Contents</h1>
  <b><a href="opcodes.html">Opcodes</a></b><br/>
  <b><a href="macros.html">Macros</a></b><br/>
<h1>Directory Contents</h1>
  This directory contains the assembler and the Verilog and VHDL templates for
    the processor.  While the assember can be run by itself, it is more
    typically run within the "<tt>../../ssbcc</tt>" script as part of making a
    compute computer core.<br/><br/>
  The "<tt>core.v</tt>" and "<tt>core.vhd</tt>" files in this directory are not
    complete modules.  They cannot be compiled.<br/><br/>
<h1>Introduction</h1>
  This processor is a minimalist FPGA-based microcontroller.  It&nbsp;provides
    8-bit data manipulation operations and function calls.  There are no
    condition registers as the results of tests are on the data stack.  The
    instruction space, data stack size, return stack size, and existence and
    sizes of RAMs and ROMs are controlled by a configuration file so that the
    processor can be sized for the problem at hand.  The configuration file also
    describes the input and output ports and include 0&nbsp; to&nbsp;8 bit port
    widths and strobes.  A&nbsp;complete processor can be implemented using just
    the configuration file and the assembly file.<br/><br/>
  A&nbsp;9-bit opcode was chosen because (1)&nbsp;it works well with Altera,
    Lattice, and Xilinx SRAM widths and (2)&nbsp;it allows pushing 8-bit data
    onto the stack with a single instruction.<br/><br/>
  An&nbsp;8-bit data width was chosen because that's a practical minimal
    size.  It&nbsp;is also common to many hardware interfaces such as I2C
    devices.<br/><br/>
  The machine has single-cycle instruction execution for all
    instructions.  However, some operations, such as a jump, require pushing the
    8 lsb of the target address onto the stack in one instruction, executing the
    jump with the remaining 5 msb of the target address, and then a <tt>nop</tt>
    during the following instruction.<br/><br/>
  Only one data stack shift can be achieved per instruction cycle.  This means
    that all operations that consume the top two elements of the stack, such as
    a store instruction, can only remove one element from the stack and must be
    immediately followed by a "<tt>drop</tt>" instruction to remove what had
    been the second element on the data stack.<br/><br/>
  This architecture accommodates up to a 13-bit instruction address space by
    first pushing the 8 least significant bits of the destination address onto
    the stack and then encoding the 5&nbsp;most significant bits in the jump
    instruction.  This is the largest practicable instruction address width
    because (1)&nbsp;one bit of the opcode is required to indicate pushing an
    8-bit value onto the stack, (2)&nbsp;one bit of the remaining 8 bits is
    required to indicate a jump instructions, (3)&nbsp;one bit is required to
    indicate whether the jump is always performed or is conditionally performed,
    and (4)&nbsp;one more bit is required to indicate whether the jump is a jump
    or a call.  This consumes 4&nbsp;bits and leaves 5&nbsp;bits of additional
    address space for the jump instruction.<br/><br/>
  This architecture also supports 0&nbsp;to 4&nbsp;pages of RAM and ROM with a
    combined limit of 4&nbsp;pages.  Each page of RAM or ROM can hold up to
    256&nbsp;bytes of data.  This architecture provides up to 1&nbsp;kB of
    RAM and ROM for the micro controller.<br/><br/>
<h1>Design</h1>
  The processor is a mix of instructions that operate on the top element of the
    data stack (such as left or right shifts); operations that combine the top
    two elements of the data stack such as addition and subtraction and bit wise
    logical operations; operations that manipulate the data stack such as
    <tt>drop</tt>, <tt>nip</tt>, and 8-bit pushes; operations that move data
    between the data stack and the return stack; jumps and calls and their
    conditional variants; memory operations; and I/O operations.<br/><br/>
  This section describes these.  The next section defines these instructions in
    detail.<br/><br/>
  <ul>
    <li>Data Stack Operations:<br/><br/>
      The data stack is an 8&nbsp;bit wide stack.  The top two elements of this
        data stack, called <tt>T</tt> for the top of the data stack and
        <tt>N</tt> for the next-to-top of the data stack, are stored in
        registers so that they are immediately available to the processor core.
        The remaining values are stored in the 8-bit wide RAM
        comprising the stack.  This will usually be some form of distributed RAM
        on an FPGA.  The index to the top of the stack is retained in a
        register.<br/><br/>
      A&nbsp;couple of examples illustrate how the data stack is
        manipulated:<br/><br/>
        <ul>
        <li>A&nbsp;push instruction moves <tt>N</tt> onto the data stack RAM and
          increments the pointer into the data stack, moves <tt>T</tt> into
          <tt>N</tt>, and replaces <tt>T</tt> with the value being pushed onto
          the data stack.<br/><br/>
        <li>The <tt>&lt;&lt;0</tt> instruction rotates the value in <tt>T</tt>
          left one bit and brings a zero in as the new lsb.  The data stack is
          otherwise left unchanged.<br/><br/>
        <li>The <tt>swap</tt> instruction swaps the values in <tt>T</tt> and
          <tt>N</tt> and leaves the rest of the data stack unchanged.<br/><br/>
        <li>The <tt>drop</tt> instruction moves <tt>N</tt> into <tt>T</tt>, the
          top of the data stack RAM into <tt>N</tt>, and decrements the pointer
          into the data stack.<br/><br/>
        <li>The <tt>store</tt> instruction requires the value to be stored and
          the address to which it is to be stored.  Since the address cannot be
          encoded as part of the <tt>store</tt> instruction and since multi-byte
          <tt>store+</tt> and <tt>store-</tt> instructions require the address
          to remain on the stack as the rest of the stack is consumed, the
          address for the <tt>store</tt> instruction is in <tt>T</tt> while the
          data to be stored is in <tt>N</tt>.  I.e., if the value to be stored
          is in <tt>T</tt>, then the address where it is to be stored is then
          pushed onto the data stack and the <tt>store</tt> instruction is
          issued.  The <tt>store</tt> instruction drops the top of the data
          stack, leaving the value that was stored on the top of the data stack.
          The <tt>store+</tt> and <tt>store-</tt> instruction differ from this
          in that the value in <tt>N</tt> is dropped from the data stack and the
          altered address is retained in <tt>T</tt>.<br/><br/>
        <li>The <tt>outport</tt> instruction is similar to the <tt>store</tt>
          instruction in that the port number is pushed onto the data stack
          prior to the <tt>outport</tt> instruction which then drops the port
          number from the data stack.<br/><br/>
        </ul>
      The return stack is similar except that only the top-most value,
        <tt>R</tt>, is retained in a dedicated register.<br/><br/>
      Separate registers are used for <tt>N</tt> and the top of the return stack
        are implmented in registers rather than the output of the RAM because
        there there are multipler sources for their values when they are added
        to their stack.  Instead, the value registered in <tt>N</tt> or
        <tt>R</tt> is pushed onto the body of the stack.<br/><br/>
      Faster stack implementations won't improve the processor speed because the
        3&nbsp;levels of logic required to implement the core are slower than
        the storing <tt>N</tt> or <tt>R</tt> into their stack bodies.<br/><br/>
      </li>
    <li>Jump and Call Instructions:<br/><br/>
      The large SRAM on the FPGAs can have registers for their input addresses
        and registers for their output data.  These registers are used to extract
        the fastest speed possible from the memory.  While it is possible to
        design the processor ROM to avoid these registers, that isn't always
        what's desired.  This however impacts how jump instructions are
        performed.<br/><br/>
      Specifically, if a jump instruction changes the program counter during
        cycle <em>n</em>, then the new input address is registered at the end of that
        clock cycle and the corresponding data is registered at the end of the
        next clock cycle, i.e., the new opcode is available at the end of cycle
        <em>n</em>+1.  That is, the new opcode can't performed by the core until
        cycle&nbsp;<em>n</em>+2.<br/><br/>
      This means that the instruction immediately following a jump or call
        instruction will be performed before the first instruction at the target
        of the jump or call.  For an unconditional jump or call, i.e.,
        <tt>jump</tt> or <tt>call</tt>, this subsequent instruction will
        normally be a <tt>nop</tt>.  However, for a conditional jump or call,
        i.e., a <tt>jumpc</tt> or <tt>callc</tt> instruction, this will normally
        be a <tt>drop</tt> that eliminates the conditional used to determine
        whether or not the branch was taken.<br/><br/>
      Some examples are:<br/><br/>
        <ul>
        <li>The following block shows a conditional jump and an unconditional
          jump being used for an
          "<tt>if&nbsp;...&nbsp;else&nbsp;..&nbsp;endif</tt>"  block.
          The&nbsp;<tt>.jump</tt> and <tt>.jumpc</tt> macros are used to encode
          pushing the 8&nbsp;lsb of the target address onto the stack and to
          encode the 5&nbsp;msb into the <tt>jump</tt> or <tt>jumpc</tt>
          instruction.  The macros also add the subsequent <tt>nop</tt> and
          <tt>drop</tt> respectively.<br/><br/>
          <tt>
            ;&nbsp;determine&nbsp;which&nbsp;value&nbsp;to&nbsp;put&nbsp;on&nbsp;the&nbsp;stack&nbsp;based&nbsp;on&nbsp;the&nbsp;value&nbsp;in&nbsp;T<br/>
            ;&nbsp;(&nbsp;f&nbsp;-&nbsp;u&nbsp;)<br/>
            .jumpc(true_case)<br/>
            &nbsp;&nbsp;0x80&nbsp;.jump(end_case)<br/>
            :true_case<br/>
            &nbsp;&nbsp;0x37<br/>
            :end_case
            </tt><br/><br/>
          The condition on the top of the data stack is consumed by the initial
          <tt>jumpc</tt>.  If&nbsp;<tt>T</tt> is true then <tt>0x37</tt> will be
          pushed onto the data stack.  Otherwise <tt>0x80</tt> will be pushed
          onto the data stack.  This can be written slightly more efficienty by
          replacing the <tt>nop</tt> in the <tt>.jump</tt> macro as
          follows:<br/><br/>
          <tt>&nbsp;&nbsp;.jumpc(true_case)&nbsp;.jump(end_case,0x37)&nbsp;:true_case&nbsp;0x37&nbsp;:end_case</tt><br/><br/>
          This reduces the total number of instructions from 8
          to&nbsp;7.<br/><br/>
          </li>
        <li>The following statement shows how a function can return a flag used
          by a second conditional call:<br/><br/>
          <tt>&nbsp;&nbsp;.call(data_pending)&nbsp;.callc(process_data)</tt><br/><br/>
          Here, the <tt>data_pending</tt> function returns a true or false
          flag on the top of the data stack.  The subsequent <tt>callc</tt> then
          processes the data only if there was data to process.<br/><br/>
        </ul>
      </li>
    <li><a name="memory">Memory Operations</a>:<br/><br/>
      The fetch and store memory access instructions are designed such that four
        banks of memory can be accessed, each of which can hold up to
        256&nbsp;bytes.  This allows up to a total of 1&nbsp;kB of
        memory to be accessed by the processor.<br/><br/>
      There are three variants of the fetch instruction and three variants of
        the store instruction.<br/><br/>
      The simplest fetch instruction exchanges the top of the data stack with
        the value it had indexed from the memory bank encoded in the store
        instruction.  For example, the two instruction sequence<br/><br/>
        <tt>&nbsp;&nbsp;0x10 .fetch(0)</tt><br/><br/>
        has the effect of pushing the value from <tt>00_0001_0000</tt> onto the
        data stack where the leading two zeros are the bank number.<br/><br/>
      The simplest store instruction similarly uses the top of the data stack as
        the address within the memory bank and stores the value in the
        next-to-top of the data stack at that location.  For example, the four
        instruction sequence<br/><br/>
        <tt>&nbsp;&nbsp;0x5A 0x10 .store(0) drop</tt><br/><br/>
        has the effect of storing the value <tt>0x5A</tt> in the memory address
        <tt>00_0001_0000</tt>.<br/><br/>
      The remaining two fetch and two store instructions are designed to
        facilitate storing and fetching multi-byte values.  These vectorized
        fetch and store instructions increment or decrement the top of the stack
        while reading from or storing to memory.  For example, the instruction
        sequence<br/><br/>
        <tt>&nbsp;&nbsp;0x13&nbsp;.fetch-(0)&nbsp;.fetch-(0)&nbsp;.fetch-(0)&nbsp;.fetch(0)</tt><br/><br/>
        will push the memory values from <tt>00_0001_0011</tt>,
        <tt>00_0001_0010</tt>, <tt>00_0001_0001</tt>, and <tt>00_0001_0000</tt>
        onto the data stack with the value from <tt>00_0001_0000</tt> on the
        top of the stack.  The instruction sequence<br/><br/>
        <tt>&nbsp;&nbsp;0x10&nbsp;.store+(0)&nbsp;.store+(0)&nbsp;.store+(0)&nbsp;.store(0)&nbsp;drop</tt><br/><br/>
        has the reverse effect in that it stores the top four values on the
        stack in memory with the value that had been at the top of the stack
        being stored at address <tt>00_0001_000</tt>.  That is, it has the
        effect of storing the values from the four-fetch instruction sequence
        into memory and preserving their order.<br/><br/>
      If the values were in the reverse order on the stack the instruction
        sequence would have been<br/><br/>
        <tt>&nbsp;&nbsp;0x13&nbsp;.store-(0)&nbsp;.store-(0)&nbsp;.store-(0)&nbsp;.store-(0)&nbsp;drop</tt><br/><br/>
      In practice, the <tt>.fetch</tt> and <tt>.store</tt> macros do not use a
        hard-wired number for the bank address.  Instead the memory bank is
        specified by a symbolic name.  For example, a memory is defined in the
        micro controller architecture file using a statement such as:<br/><br/>
        <tt>&nbsp;&nbsp;MEMORY RAM ram 32</tt><br/><br/>
        which defines a RAM named "<tt>ram</tt>" and allocates 32&nbsp;bytes of
        storage.  The corresponding RAM in the assembler code is then selected by
        the directive:<br/><br/>
        <tt>&nbsp;&nbsp;.memory&nbsp;RAM&nbsp;ram</tt><br/><br/>
        and variables within this bank of memory are defined using the
        "<tt>.variable</tt>" directive as follows:<br/><br/>
        <tt>&nbsp;&nbsp;.variable&nbsp;single_value&nbsp;0<br/>
        &nbsp;&nbsp;.variable&nbsp;multi_count&nbsp&nbsp;2*0</tt><br/><br/>
        The first of these defines "<tt>single_value</tt>" to be a single-byte
        value initialized to zero and the second defines "<tt>multi_count</tt>"
        to be a two&nbsp;byte value initialized to&nbsp;0.  Variable order is
        preserved by the assembler.<br/><br/>
      As an example, the following assembly code will initialize this block of
        memory to zero:<br/><br/>
        <tt>&nbsp;&nbsp;$(size['ram'])&nbsp;:loop&nbsp;0&nbsp;swap&nbsp;.store-(ram)&nbsp;.jumpc(loop,nop)&nbsp;drop</tt><br/><br/>
        Note that the memory size is not hard-wired into  the
        assembly code but is accessed through the calculation
        "<tt>$(size['ram'])</tt>".  Also, since the <tt>.store-</tt> macro
        decrements the top of the stack before the conditional jump, the last
        value stored in memory before the loop exits will have been stored at
        address&nbsp;<tt>0x01</tt>.  However, since the size must be a power of
        two, the first value stored will be at the effective
        address&nbsp;<tt>0x00</tt>.  The loop itself is 6&nbsp;instructions.
        This can be reduced to 5&nbsp;instructions at the cost of an additional
        drop instruction as follows:<br/><br/>
        <tt>&nbsp;&nbsp;$(size['ram'])&nbsp;0&nbsp;:loop&nbsp;swap&nbsp;.store-(ram)&nbsp;.jumpc(loop,0)&nbsp;drop&nbsp;drop</tt><br/><br/>
        The optional argument to the <tt>.jumpc</tt> macro is required so that
        the memory address is not dropped from the data stack after the
        conditional is tested.  The equivalent operation without replacing the
        <tt>drop</tt> instruction with a <tt>nop</tt> instruction would be:<br/><br/>
        <tt>&nbsp;&nbsp;$(size['ram'])&nbsp;:loop&nbsp;0&nbsp;swap&nbsp;.store-(ram)&nbsp;dup&nbsp;.jumpc(loop,drop)&nbsp;drop</tt><br/><br/>
        where the <tt>drop</tt> has been explicitely included.<br/><br/>
      Memories can be either "<tt>RAM</tt>" or "<tt>ROM</tt>" and must be
        declared as the same type in the architecture file and in the assembler
        files.  Within the assembler source the "<tt>.memory</tt>" directive can
        be repeated so that variables in one memory bank can be defined in
        multiple assembler files.  The "<tt>.memory</tt>" directive must be
        repeated if the source file changes and after function
        definitions.<br/><br/>
      The Forth language requires that the MSB of multi-word values be stored on
        the top of the data stack.  Using the <tt>.store+</tt> and
        <tt>.fetch-</tt> instructions to write to and read from memory will
        keep the corresponding MSB at the top of the stack and as the first byte
        in memory.  If&nbsp;the LSB is at the top of the data stack then the
        <tt>.store-</tt> instruction can be used to store it in the desired
        order.<br/><br/>
      The following macros are provided to facilitate memory
        operations:<br/><br/>
        <ul>
        <li><tt>.fetch(name)</tt> where <tt>name</tt> is the name of a
            RAM<br/><br/>
          This generates the single-instruction <tt>fetch</tt> opcode with the
            memory bank number encoded in the instruction.<br/><br/>
        <li><tt>.fetch+(name)</tt> where <tt>name</tt> is the name of a
            RAM<br/><br/>
          This generates the single-instruction <tt>fetch+</tt> opcode with the
            memory bank number encoded in the instruction.<br/><br/>
        <li><tt>.fetch-(name)</tt> where <tt>name</tt> is the name of a
            RAM<br/><br/>
          This generates the single-instruction <tt>fetch-</tt> opcode with the
            memory bank number encoded in the instruction.<br/><br/>
        <li><tt>.fetchindexed(name)</tt> where <tt>name</tt> is a variable
            name<br/><br/>
          If <tt>variable</tt> is in memory <tt>ram</tt> then
            <tt>.fetchindexed(variable)</tt> becomes the 3&nbsp;instruction
            sequence
            "<tt>variable&nbsp;+&nbsp;.fetch(ram)</tt>"<br/><br/>
        <li><tt>.fetchvalue(name)</tt> where <tt>name</tt> is a variable
            name.<br/><br/>
          If <tt>variable</tt> is in memory <tt>ram</tt> then
            <tt>.fetchvalue(variable)</tt> becomes the 2&nbsp;instruction
            sequence "<tt>variable&nbsp;.fetch(ram)</tt>"<br/><br/>
        <li><tt>.fetchvector(name,length)</tt><br/><br/>
          <tt>name</tt> is a variable name<br/>
          <tt>length</tt> is the length of the vector to transfer from the data
            stack to the RAM.<br/><br/>
          If <tt>variable</tt> is in memory <tt>ram</tt> then
            <tt>.fetchvector(variable,4)</tt> becomes the 5&nbsp;instruction
            sequence
          "<tt>$(variable+3)&nbsp;.fetch-(ram)&nbsp;.fetch-(ram)&nbsp;.fetch-(ram)&nbsp;.fetch(ram)</tt>"<br/><br/>
        <li><tt>.store(name)</tt> where <tt>name</tt> is the name of a
            RAM<br/><br/>
          This generates the single-instruction <tt>store</tt> opcode with the
            memory bank number encoded in the instruction.<br/><br/>
        <li><tt>.store+(name)</tt> where <tt>name</tt> is the name of a
            RAM<br/><br/>
          This generates the single-instruction <tt>store+</tt> opcode with the
            memory bank number encoded in the instruction.<br/><br/>
        <li><tt>.store-(name)</tt> where <tt>name</tt> is the name of a
            RAM<br/><br/>
          This generates the single-instruction <tt>store-</tt> opcode with the
            memory bank number encoded in the instruction.<br/><br/>
        <li><tt>.storeindexed(name)</tt><br/><br/>
          <tt>name</tt> is a variable name<br/>
          An optional second argument can replace the <tt>drop</tt> that normally
            ends this sequence.<br/><br/>
          If <tt>variable</tt> is in memory <tt>ram</tt> then
            <tt>.storeindexed(variable)</tt> becomes the 4&nbsp;instruction
            sequence
            "<tt>variable&nbsp;+&nbsp;.store(ram)&nbsp;drop</tt>"<br/><br/>
        <li><tt>.storevalue(name)</tt> where <tt>name</tt> is a variable
            name.<br/><br/>
          An optional second argument can replace the <tt>drop</tt> that normally
            ends this sequence.<br/><br/>
          If <tt>variable</tt> is in memory <tt>ram</tt> then
            <tt>.storevalue(variable)</tt> becomes the 3&nbsp;instruction
            sequence "<tt>variable&nbsp;.store(ram)&nbsp;drop</tt>"<br/><br/>
        <li><tt>.storevector(name,length)</tt><br/><br/>
          <tt>name</tt> is a variable name<br/>
          <tt>length</tt> is the length of the vector to transfer from the data
            stack to the RAM.<br/><br/>
          If <tt>variable</tt> is in memory <tt>ram</tt> then
            <tt>.storevector(variable,4)</tt> becomes the 6&nbsp;instruction
            sequence
            "<tt>variable&nbsp;.store+(ram)&nbsp;.store+(ram)&nbsp;.store+(ram)&nbsp;.store(ram)&nbsp;drop</tt>"<br/><br/>
        </ul>
    </ul>
<h1>OPCODES</h1>
  This section documents the opcodes.<br/><br/>
  Alphabetic listing:
    <a href="#&">&amp;</a>,
    <a href="#+">+</a>,
    <a href="#-">-</a>,
    <a href="#-1<>">-1&lt;&gt;</a>,
    <a href="#-1=">-1=</a>,
    <a href="#0<>">0&lt;&gt;</a>,
    <a href="#0=">0=</a>,
    <a href="#0>>">0&gt;&gt;</a>,
    <a href="#1+">1+&gt;</a>,
    <a href="#1-">1-&gt;</a>,
    <a href="#1>>">1&gt;&gt;</a>,
    <a href="#<<0">&lt;&lt;0</a>,
    <a href="#<<1">&lt;&lt;1</a>,
    <a href="#<<msb">&lt;&lt;msb</a>,
    <a href="#>r">&gt;r</a>,
    <a href="#FE=">FE=</a>,
    <a href="#FF=">FF=</a>,
    <a href="#^">^</a>,
    <a href="#call">call</a>,
    <a href="#callc">callc</a>,
    <a href="#dis">dis</a>,
    <a href="#drop">drop</a>,
    <a href="#dup">dup</a>,
    <a href="#ena">ena</a>,
    <a href="#fetch">fetch</a>,
    <a href="#fetch+">fetch+</a>,
    <a href="#fetch-">fetch-</a>,
    <a href="#inport">inport</a>,
    <a href="#jump">jump</a>,
    <a href="#jumpc">jumpc</a>,
    <a href="#lsb>>">lsb&gt;&gt;</a>,
    <a href="#msb>>">msb&gt;&gt;</a>,
    <a href="#nip">nip</a>,
    <a href="#nop">nop</a>,
    <a href="#or">or</a>,
    <a href="#outport">outport</a>,
    <a href="#over">over</a>,
    <a href="#push">push</a>,
    <a href="#r>">r&gt;</a>,
    <a href="#r@">r@</a>,
    <a href="#return">return</a>,
    <a href="#store">store</a>,
    <a href="#store+">store+</a>,
    <a href="#store-">store-</a>,
    <a href="#swap">swap</a>
    <br/><br/>
  <h2><a name="opcode_mapping">Opcode Mapping</a></h2>
    <table>
    <tr>
      <th align="left">Opcode&nbsp;&nbsp;&nbsp;</th>
        <th>8</th><th>7</th><th>6</th><th>5</th><th>4</th><th>3&nbsp;&nbsp;&nbsp;</th><th>2</th><th>1</th><th>0&nbsp;&nbsp;&nbsp;</th>
        <th align="left">Description</th>
        </tr>
      <th align="left"><a href="#nop">nop</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td>
        <td align="left">no operation</td>
        </tr>
      <th align="left"><a href="#<<0">&lt;&lt;0</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td>
        <td align="left">left shift 1 bit and bring in a 0</td>
        </tr>
      <th align="left"><a href="#<<1">&lt;&lt;1</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>0</td>
        <td align="left">left shift 1 bit and bring in a 1</td>
        </tr>
      <th align="left"><a href="#<<msb">&lt;&lt;msb</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td>
        <td align="left">left shift 1 bit and rotate the msb into the lsb</td>
        </tr>
      <th align="left"><a href="#0>>">0&gt;&gt;</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td>
        <td align="left">right shift 1 bit and bring in a 0</td>
        </tr>
      <th align="left"><a href="#1>>">1&gt;&gt;</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>1</td>
        <td align="left">right shift 1 bit and bring in a 1</td>
        </tr>
      <th align="left"><a href="#msb>>">msb&gt;&gt;</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>0</td>
        <td align="left">right shift 1 bit and keep the msb the same</td>
        </tr>
      <th align="left"><a href="#lsb>>">lsb&gt;&gt;</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>1</td>
        <td align="left">right shift 1 bit and rotate the lsb into the msb</td>
        </tr>
      <th align="left"><a href="#dup">dup</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td>
        <td align="left">push a duplicate of the top of the data stack onto the data stack</td>
        </tr>
      <th align="left"><a href="#r@">r@</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>1</td>
        <td align="left">push a duplicate of the top of the return stack onto the data stack</td>
        </tr>
      <th align="left"><a href="#over">over</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>0</td>
        <td align="left">push a duplicate of the next-to-top of the data stack onto the data stack</td>
        </tr>
      <th align="left"><a href="#swap">swap</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>1</td><td>0</td>
        <td align="left">swap the top and the next-to-top of the data stack</td>
        </tr>
      <th align="left"><a href="#+">+</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td>
        <td align="left">pop the stack and replace the top with N+T</td>
        </tr>
      <th align="left"><a href="#-">-</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>1</td><td>0</td><td>0</td>
        <td align="left">pop the stack and replace the top with N-T</td>
        </tr>
      <th align="left"><a href="#dis">dis</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td>
        <td align="left">disable interrupts</td>
        </tr>
      <th align="left"><a href="#ena">ena</a></th>
        <td>0</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>0</td><td>0</td><td>1</td>
        <td align="left">enable interrupts</td>
        </tr>
      <th align="left"><a href="#0=">0=</a></th>
        <td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td>
        <td align="left">replace the top of the stack with "<tt>0xFF</tt>" if it is "<tt>0x00</tt>" (i.e., it is zero), otherwise replace it with "<tt>0x00</tt>"<br/>
        </tr>
      <th align="left"><a href="#0<>">0&lt;&gt;</a></th>
        <td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td><td>0</td><td>1</td>
        <td align="left">replace the top of the stack with "<tt>0xFF</tt>" if it is not "<tt>0x00</tt>" (i.e., it is non-zero), otherwise replace it with "<tt>0x00</tt>"<br/>
        </tr>
      <th align="left"><a href="#-1=">-1=</a></th>
        <td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td><td>1</td><td>0</td>
        <td align="left">replace the top of the stack with "<tt>0xFF</tt>" if it is "<tt>0xFF</tt>" (i.e., it is all ones), otherwise replace it with "<tt>0x00</tt>"<br/>
        </tr>
      <th align="left"><a href="#-1<>">-1&lt;&gt;</a></th>
        <td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td><td>1</td><td>1</td>
        <td align="left">replace the top of the stack with "<tt>0xFF</tt>" if it is not "<tt>0xFF</tt>" (i.e., it is not all ones), otherwise replace it with "<tt>0x00</tt>"<br/>
        </tr>
      <th align="left"><a href="#return">return</a></th>
        <td>0</td><td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td>
        <td align="left">return from a function call</td>
        </tr>
      <th align="left"><a href="#inport">inport</a></th>
        <td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td><td>0</td>
        <td align="left">replace the top of the stack with the contents of the specified input port</td>
        </tr>
      <th align="left"><a href="#outport">outport</a></th>
        <td>0</td><td>0</td><td>0</td><td>1</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td>
        <td align="left">write the next-to-top of the data stack to the output port specified by the top of the data stack</td>
        </tr>
      <th align="left"><a href="#>r">&gt;r</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td>
        <td align="left">Pop the top of the data stack and push it onto the return stack</td>
        </tr>
      <th align="left"><a href="#r>">r&gt;</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>1</td><td>0</td><td>0</td><td>1</td>
        <td align="left">Pop the top of the return stack and push it onto the data stack</td>
        </tr>
      <th align="left"><a href="#&">&amp;</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td><td>0</td>
        <td align="left">pop the stack and replace the top with N &amp; T</td>
        </tr>
      <th align="left"><a href="#or">or</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>0</td><td>0</td><td>0</td><td>1</td>
        <td align="left">pop the stack and replace the top with N | T</td>
        </tr>
      <th align="left"><a href="#^">^</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>0</td><td>0</td><td>1</td><td>0</td>
        <td align="left">pop the stack and replace the top with N ^ T</td>
        </tr>
      <th align="left"><a href="#nip">nip</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>0</td><td>0</td><td>1</td><td>1</td>
        <td align="left">pop the next-to-top from the data stack</td>
        </tr>
      <th align="left"><a href="#drop">drop</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>0</td><td>1</td><td>0</td><td>0</td>
        <td align="left">drop the top value from the stack<tt></td>
        </tr>
      <th align="left"><a href="#1+">1+</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td>
        <td align="left">Add 1 to T</td>
        </tr>
      <th align="left"><a href="#1-">1-</a></th>
        <td>0</td><td>0</td><td>1</td><td>0</td><td>1</td><td>1</td><td>1</td><td>0</td><td>0</td>
        <td align="left">Subtract 1 from T</td>
        </tr>
      <th align="left"><a href="#store">store</a></th>
        <td>0</td><td>0</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td><td>b</td><td>b</td>
        <td align="left">Store N in the T'th entry in bank "<tt>bb</tt>", drop the top of the data stack</td>
        </tr>
      <th align="left"><a href="#fetch">fetch</a></th>
        <td>0</td><td>0</td><td>1</td><td>1</td><td>0</td><td>1</td><td>0</td><td>b</td><td>b</td>
        <td align="left">Exchange the top of the stack with the T'th value from bank "<tt>bb</tt>"</td>
        </tr>
      <th align="left"><a href="#store+">store+</a></th>
        <td>0</td><td>0</td><td>1</td><td>1</td><td>1</td><td>0</td><td>0</td><td>b</td><td>b</td>
        <td align="left">Store N in the T'th entry in bank "<tt>bb</tt>", nip the data stack, and increment T</td>
        </tr>
      <th align="left"><a href="#store-">store-</a></th>
        <td>0</td><td>0</td><td>1</td><td>1</td><td>1</td><td>0</td><td>1</td><td>b</td><td>b</td>
        <td align="left">Store N in the T'th entry in bank "<tt>bb</tt>", nip the data stack, and decrement T</td>
        </tr>
      <th align="left"><a href="#fetch+">fetch+</a></th>
        <td>0</td><td>0</td><td>1</td><td>1</td><td>1</td><td>1</td><td>0</td><td>b</td><td>b</td>
        <td align="left">Push the T'th entry from bank "<tt>bb</tt>" into the data stack as N and increment T</td>
        </tr>
      <th align="left"><a href="#fetch-">fetch-</a></th>
        <td>0</td><td>0</td><td>1</td><td>1</td><td>1</td><td>1</td><td>1</td><td>b</td><td>b</td>
        <td align="left">Push the T'th entry from bank "<tt>bb</tt>" into the data stack as N and decrement T</td>
        </tr>
      <th align="left"><a href="#jump">jump</a></th>
        <td>0</td><td>1</td><td>0</td><td>0</td><td>x</td><td>x</td><td>x</td><td>x</td><td>x</td>
        <td align="left">Jump to the address "<tt>x_xxxx_TTTT_TTTT</tt>"</td>
        </tr>
      <th align="left"><a href="#jumpc">jumpc</a></th>
        <td>0</td><td>1</td><td>0</td><td>1</td><td>x</td><td>x</td><td>x</td><td>x</td><td>x</td>
        <td align="left">Conditionally jump to the address "<tt>x_xxxx_TTTT_TTTT</tt>"</td>
        </tr>
      <th align="left"><a href="#call">call</a></th>
        <td>0</td><td>1</td><td>1</td><td>0</td><td>x</td><td>x</td><td>x</td><td>x</td><td>x</td>
        <td align="left">Call the function at address "<tt>x_xxxx_TTTT_TTTT</tt>"</td>
        </tr>
      <th align="left"><a href="#callc">callc</a></th>
        <td>0</td><td>1</td><td>1</td><td>1</td><td>x</td><td>x</td><td>x</td><td>x</td><td>x</td>
        <td align="left">Conditionally call the function at address "<tt>x_xxxx_TTTT_TTTT</tt>"</td>
        </tr>
      <th align="left"><a href="#push">push</a></th>
        <td>1</td><td>x</td><td>x</td><td>x</td><td>x</td><td>x</td><td>x</td><td>x</td><td>x</td>
        <td align="left">Push the 8-bit value "<tt>xxxx_xxxx</tt>" onto the data stack.</td>
        </tr>
    </table>
  <h2><a name="&">Instruction:  &amp;</a></h2>
    <b>Desription:</b>  Pop the data stack and replace the top with the bitwise
      and of the previous top and next-to-top.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T &amp; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
  <h2><a name="+">Instruction:  +</a></h2>
    <b>Desription:</b>  Pop the data stack and replace the top with the
      8&nbsp;sum of the previous top and next-to-top.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N + T<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
  <h2><a name="-">Instruction:  -</a></h2>
    <b>Desription:</b>  Pop the data stack and replace the top with the
      8&nbsp;difference of the previous top and next-to-top.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N - T<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
  <h2><a name="-1<>">Instruction:  -1<></a></h2>
    <b>Desription:</b>  Set the top of the stack to all ones if the previous
      value was not all ones, otherwise set it to all zeros.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; 0xFF if T!=0xFF, 0x00 otherwise<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="-1=">Instruction:  -1=</a></h2>
    <b>Desription:</b>  Set the top of the stack to all ones if the previous
      value was all ones, otherwise set it to all zeros.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; 0xFF if T=0xFF, 0x00 otherwise<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="0<>">Instruction:  0<></a></h2>
    <b>Desription:</b>  Set the top of the stack to all ones if the previous
      value was not all zeros, otherwise set it to all zeros.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; 0xFF if T!=0x00, 0x00 otherwise<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="0=">Instruction:  0=</a></h2>
    <b>Desription:</b>  Set the top of the stack to all ones if the previous
      value was all zeros, otherwise set it to all zeros.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; 0xFF if T=0x00, 0x00 otherwise<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="0>>">Instruction:  0&gt;&gt;</a></h2>
    <b>Desription:</b>  Right shift the top of the stack one bit, replacing the
      left-most bit with a zero.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; { 0, T[7], T[6], ..., T[1] }<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="1+">Instruction:  1+</a></h2>
    <b>Desription:</b>  Add 1 to T.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T+1<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="1-">Instruction:  1-</a></h2>
    <b>Desription:</b>  Subtract 1 from T.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T-1<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="1>>">Instruction:  1&gt;&gt;</a></h2>
    <b>Desription:</b>  Right shift the top of the stack one bit, replacing the
      left-most bit with a zero.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; { 1, T[7], T[6], ..., T[1] }<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="<<0">Instruction:  &lt;&lt;0</a></h2>
    <b>Desription:</b>  Left shift the top of the stack one bit, replacing the
      right-most bit with a zero.
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; { T[6], T[5], ..., T[0], 0 }<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="<<1">Instruction:  &lt;&lt;1</a></h2>
    <b>Desription:</b>  Left shift the top of the stack one bit, replacing the
      right-most bit with a one.<br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; { T[6], T[5], ..., T[0], 1 }<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="<<msb">Instruction:  &lt;&lt;msb</a></h2>
    <b>Desription:</b>  Left shift the top of the stack one bit, leaving the
      right-most bit unchanged.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; { T[6], T[5], ..., T[0], T[7] }<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name=">r">Instruction:  &gt;r</a></h2>
    <b>Desription:</b>  Pop the data stack and push its previous value onto the
      return stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R &leftarrow; T<br/>
      <tt>++return</tt> &leftarrow; R<br/>
      T &leftarrow; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
  <h2><a name="^">Instruction:  ^</a></h2>
    <b>Desription:</b>  Pop the data stack and replace the top with the bitwise
      exclusive or of the previous top and next-to-top.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T ^ N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
  <h2><a name="call">Instruction:  call</a></h2>
    <b>Desription:</b>  Call the function at the address constructed from the
      opcode and <tt>T</tt>.  Discard&nbsp;<tt>T</tt> and push the PC onto the
      return stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; { O[4], ..., O[0], T[7], T[6], ..., T[0] }<br/>
      R &leftarrow; PC+1<br/>
      <tt>++return</tt> &leftarrow; R<br/>
      T &leftarrow; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
    <b>Special:</b><br/><br/>
      Interrupts are disabled during the clock cycle immediately following a
      call instruction.<br/><br/>
      The assembler normally places a "<tt>nop</tt>" instruction immediately
      after the "<tt>call</tt>" instruction.<br/><br/>
  <h2><a name="callc">Instruction:  callc</a></h2>
    <b>Desription:</b>  Conditionally call the function at the address
      constructed from the opcode and <tt>T</tt>.  Discard&nbsp;<tt>T</tt> and
      conditionally push the next PC onto the return stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      if N != 0 then<br/>
      &nbsp;&nbsp;PC &leftarrow; { O[4], ..., O[0], T[7], T[6], ..., T[0] }<br/>
      &nbsp;&nbsp;R &leftarrow; PC<br/>
      &nbsp;&nbsp;<tt>++return</tt> &leftarrow; R<br/>
      else<br/>
      &nbsp;&nbsp;PC &leftarrow; PC+1<br/>
      &nbsp;&nbsp;R and <tt>return</tt> unchanged<br/>
      endif<br/>
      T &leftarrow; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
    <b>Special:</b><br/><br/>
      Interrupts are disabled during the clock cycle immediately following a
      callc instruction.<br/><br/>
      The assembler normally places a "<tt>drop</tt>" instruction immediately
      after the "<tt>callc</tt>" instruction.<br/><br/>
  <h2><a name="dis">Instruction:  dis</a></h2>
    <b>Desription:</b>  Disable interrupts.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R, <tt>return</tt>, T, N, and <tt>stack</tt> unchanged</br>
      <br/>
  <h2><a name="drop">Instruction:  drop</a></h2>
    <b>Desription:</b>  Pop the data stack, discarding the value that had been
      on the top.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
  <h2><a name="dup">Instruction:  dup</a></h2>
    <b>Desription:</b>  Push the top of the data stack onto the data
      stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T<br/>
      N &leftarrow; T<br/>
      <tt>++stack</tt> &leftarrow; N<br/>
      <br/>
  <h2><a name="ena">Instruction:  ena</a></h2>
    <b>Desription:</b>  Enable interrupts.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R, <tt>return</tt>, T, N, and <tt>stack</tt> unchanged</br>
      <br/>
  <h2><a name="fetch">Instruction:  fetch</a></h2>
    <b>Desription:</b>  Replace the top of the data stack with an 8&nbsp;bit
      value from memory.  The memory bank is specified by the two
      least-significant bits of the opcode.  The index within the memory bank is
      specified by the previous value of the top of the stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; bb[T] where "bb" is the bank<br/>
      N and <tt>stack</tt> unchanged<br/>
    <b>Special:</b>
      See <a href="#memory">memory</a> for instructions on using the fetch and
      vectorized fetch macros.<br/>
      <br/>
  <h2><a name="fetch+">Instruction:  fetch+</a></h2>
    <b>Desription:</b>  Push the T'th entry from bank "<tt>bb</tt>" onto the
      data stack as N and increment the top of the data stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T+1<br/>
      N &leftarrow; bb[T] where "bb" is the bank<br/>
      <tt>++stack</tt><br/>
    <b>Special:</b>
      See <a href="#memory">memory</a> for instructions on using the fetch and
      vectorized fetch macros.<br/>
      <br/>
  <h2><a name="fetch-">Instruction:  fetch-</a></h2>
    <b>Desription:</b>  Push the T'th entry from bank "<tt>bb</tt>" onto the
      data stack as N and decrement the top of the data stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T-1<br/>
      N &leftarrow; bb[T] where "bb" is the bank<br/>
      <tt>++stack</tt><br/>
    <b>Special:</b>
      See <a href="#memory">memory</a> for instructions on using the fetch and
      vectorized fetch macros.<br/>
      <br/>
  <h2><a name="inport">Instruction:  inport</a></h2>
    <b>Desription:</b>  Replace the top of the data stack with the 8&nbsp;value
      from the port specified by the previous value of the top of the data
      stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; <tt>input_port</tt>[T]<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
    <b>Special:</b><br/><br/>
      The recommended procedure to read from an inport port is to use the
      "<tt>.inport</tt>" macro.<br/><br/>
  <h2><a name="jump">Instruction:  jump</a></h2>
    <b>Desription:</b>  Jump to the address constructed from the opcode and
      <tt>T</tt>.  Discard&nbsp;<tt>T</tt>.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; { O[4], ..., O[0], T[7], T[6], ..., T[0] }<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
    <b>Special:</b><br/><br/>
      Interrupts are disabled during the clock cycle immediately following a
      jump instruction.<br/><br/>
      The assembler normally places a "<tt>nop</tt>" instruction immediately
      after the "<tt>jump</tt>" instruction.<br/><br/>
  <h2><a name="jumpc">Instruction:  jumpc</a></h2>
    <b>Desription:</b>  Jump to the address constructed from the opcode and
      <tt>T</tt> if <tt>N</tt> is non-zero.  Discard <tt>S</tt>
      and&nbsp;<tt>N</tt>.<br/><br/>
    <b>Operation:</b><br/><br/>
      if N != 0 then<br/>
      &nbsp;&nbsp;PC &leftarrow; { O[4], ..., O[0], T[7], T[6], ..., T[0] }<br/>
      else<br/>
      &nbsp;&nbsp;PC &leftarrow; PC+1<br/>
      end if<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
    <b>Special:</b><br/><br/>
      Interrupts are disabled during the clock cycle immediately following a
      jumpc instruction.<br/><br/>
      The assembler normally places a "<tt>drop</tt>" instruction immediately
      after the "<tt>jump</tt>" instruction so that the conditional is dropped
      from the data stack.<br/><br/>
  <h2><a name="lsb>>">Instruction:  lsb&gt;&gt;</a></h2>
    <b>Desription:</b>  Right shift the top of the stack one bit, replacing the
      left-most bit with the previous value of the right-most bit.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; { T[0], T[7], T[6], ..., T[1] }<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="msb>>">Instruction:  msb&gt;&gt;</a></h2>
    <b>Desription:</b>  Right shift the top of the stack one bit, preserving the
      value of the left-most bit.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; { T[7], T[7], T[6], ..., T[1] }<br/>
      N and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="nip">Instruction:  nip</a></h2>
    <b>Desription:</b>  Discard the next-to-top value on the data
      stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <return</tt> unchanged<br/>
      T &leftarrow; T<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
  <h2><a name="nop">Instruction:  nop</a></h2>
    <b>Desription:</b>  No operation.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow PC + 1<br/>
      R, <tt>return</tt>, T, N, and <tt>stack</tt> unchanged<br/>
      <br/>
  <h2><a name="or">Instruction:  or</a></h2>
    <b>Desription:</b>  Pop the data stack and replace the top with the bitwise
      or of the previous top and next-to-top.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T or N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <br/>
  <h2><a name="outport">Instruction:  outport</a></h2>
    <b>Desription:</b>  Pop the data stack and write the previous next-to-top to
      the port specified by the previous top.<br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      <tt>outport</tt>[T] &leftarrow; N<br/>
      <br/>
    <b>Special:</b><br/><br/>
      This instruction must be following by a "<tt>drop</tt>" in order to
      discard the value from the data stack that had been written to the data
      port.  The recommended procedure to write to an output port is to use the
      "<tt>.outport</tt>" macro.<br/><br/>
  <h2><a name="over">Instruction:  over</a></h2>
    <b>Desription:</b>  Push the next-to-top of the data stack onto the data
      stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N<br/>
      N &leftarrow; T<br/>
      <tt>++stack</tt> &leftarrow; N<br/>
      <br/>
  <h2><a name="push">Instruction:  push</a></h2>
    <b>Description:</b>  Push the specified 8-bit value onto the 8-bit
      stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; <tt>opcode</tt>[7:0]<br/>
      N &leftarrow; T<br/>
      <tt>++stack</tt> &leftarrow; N<br/>
      <br/>
  <h2><a name="r>">Instruction:  r&gt;</a></h2>
    <b>Desription:</b>  Pop the return stack and push its previous value onto
      the data stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R &leftarrow; <tt>return--</tt><br/>
      T &leftarrow; R<br/>
      N &leftarrow; T<br/>
      <tt>++stack</tt> &leftarrow; N<br/>
      <br/>
  <h2><a name="r@">Instruction:  r@</a></h2>
    <b>Desription:</b>  Push the top of the return stack onto the data
      stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; R<br/>
      N &leftarrow; T<br/>
      <tt>++stack</tt> &leftarrow; N<br/>
  <h2><a name="return">Instruction:  return</a></h2>
    <b>Description:</b>  Popd the top of the return stack into the PC.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; R<br/>
      R &leftarrow; <tt>return--</tt><br/>
      T, N, and <tt>stack</tt> unchanged<br/>
      <br/>
    <b>Special:</b>
      This instruction must be followed by a "<tt>nop</tt>"
      instruction.<br/><br/>
  <h2><a name="store">Instruction:  store</a></h2>
    <b>Desription:</b>  Drop the top of the data stack and store the previous
      next-to-top of the data stack at the memory location specified by the top
      of the data stack.  The memory bank is specified by the two least
      significant bits of the opcode.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      bb[T] &leftarrow; N where "<tt>bb</tt>" is the bank<br/>
      <br/>
    <b>Special:</b>
      See <a href="#memory">memory</a> for instructions on using the store and
      vectorized store macros.<br/>
      <br/>
  <h2><a name="store+">Instruction:  store+</a></h2>
    <b>Desription:</b>  Nip the data stack and store the previous next-to-top of
      the data stack at the memory location specified by the top of the data
      stack.  Increment the top of the data stack  The memory bank is specified
      by the two least significant bits of the opcode.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T+1<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      bb[T] &leftarrow; N where "<tt>bb</tt>" is the bank<br/>
      <br/>
    <b>Special:</b>
      See <a href="#memory">memory</a> for instructions on using the store and
      vectorized store macros.<br/>
      <br/>
  <h2><a name="store-">Instruction:  store-</a></h2>
    <b>Desription:</b>  Nip the data stack and store the previous next-to-top of
      the data stack at the memory location specified by the top of the data
      stack.  Decrement the top of the data stack  The memory bank is specified
      by the two least significant bits of the opcode.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; T-1<br/>
      N &leftarrow; <tt>stack--</tt><br/>
      bb[T] &leftarrow; N where "<tt>bb</tt>" is the bank<br/>
      <br/>
    <b>Special:</b>
      See <a href="#memory">memory</a> for instructions on using the store and
      vectorized store macros.<br/>
      <br/>
  <h2><a name="swap">Instruction:  swap</a></h2>
    <b>Desription:</b>  Swap the top two values on the data stack.<br/><br/>
    <b>Operation:</b><br/><br/>
      PC &leftarrow; PC+1<br/>
      R and <tt>return</tt> unchanged<br/>
      T &leftarrow; N<br/>
      N &leftarrow; T<br/>
      <tt>stack</tt> unchanged<br/>
      <br/>
<h1>Assembler</h1>
  This section describes the contents of an assembly language file and the
    instruction format.<br/><br/>
  The following is a simple, 10 instruction sequence, demonstrating a
    loop:<br/><br/>
    <tt>&nbsp;&nbsp;;&nbsp;consume&nbsp;256*6+3&nbsp;clock&nbsp;cycles</tt><br/>
    <tt>&nbsp;&nbsp;0&nbsp;:l00&nbsp;1&nbsp;-&nbsp;dup&nbsp;.jumpc(l00)&nbsp;drop&nbsp;.return</tt><br/><br/>
  This looks a lot like Forth code in that the operations are single words and
    are strung together on a single line.  Unlike traditional assembly
    languages, there are no source and destination registers, so most of the
    operations for this stack-based processor simply manipulate the stack.  This
    can make it easier to see the body of the assembly code since an instruction
    sequence can occupy a single line of the file instead of tens of lines of
    vertical space.  The exceptions to the single-operand format are labels,
    such as the "<tt>:l00</tt>" which are declared with a single "<tt>:</tt>"
    immediately followed by the name of the label with no intervening spaces;
    jump instructions such as the 3&nbsp;instruction,
    "<tt>push&nbsp;jumpc&nbsp;drop</tt>", sequence created by the
    "<tt>.jumpc</tt>" macro; and the 2&nbsp;operand, "<tt>return&nbsp;nop</tt>",
    sequence created by the "<tt>.return</tt>" macro.  The "<tt>.jump</tt>",
    "<tt>.jumpc</tt>", "<tt>.call</tt>", and "<tt>.callc</tt>", macros are
    pre-defined in the assembler and ensure that the correct sequence of
    operands is generated for the jump, conditional jump, function call, and
    conditional function call instructions.  Similarly, the "<tt>.return</tt>"
    macro is pre-defined in the assember and ensures that the correct sequence
    of operations is done for returning from a called function.<br/><br/>
  Memory does not have to be declared for the processor.  For example, the LED
    flashing examples required no variable or constant storage, and therefore do
    not declare or consume resources required for memory.  Variable declarations
    are done within pages declared using the "<tt>.memory</tt>" and
    "<tt>.variable</tt>" macros as follows:<br/><br/>
    <tt>&nbsp;&nbsp;.memory&nbsp;RAM&nbsp;myRAM</tt><br/>
    <tt>&nbsp;&nbsp;.variable&nbsp;save_count</tt><br/>
    <tt>&nbsp;&nbsp;.variable&nbsp;old_count&nbsp;0x0a</tt><br/>
    <tt>&nbsp;&nbsp;.variable&nbsp;out_string&nbsp;.length&nbsp;16</tt><br/><br/>
    Here, the "<tt>.memory&nbsp;RAM</tt>" macro declares the start of a page
    of&nbsp;RAM.  The RAM will be allocated as prescribed in the processor
    description file.  Here, the variable "<tt>save_count</tt>" will be at
    memory address "<tt>0x00</tt>" and will occupy a single, uninitialized slot
    of memory.  The variable "<tt>old_count</tt>" will also occupy a single slot
    of memory at address "<tt>0x01</tt>" and will be initialized to the hex
    value "<tt>0x0a</tt>".  Note that if the processor is reset that this value
    will not be re-initialized.  Finally, the variable "<tt>out_string</tt>"
    will start at address "<tt>0x02</tt>" and will occupy 16 bytes of
    memory.<br/><br/>
  A&nbsp;ROM is declared similarly.  For example,<br/><br/>
    <tt>&nbsp;&nbsp;.memory&nbsp;ROM&nbsp;myROM</tt><br/>
    <tt>&nbsp;&nbsp;.variable&nbsp;hex_to_ascii&nbsp;'0'&nbsp;'1'&nbsp;'2'&nbsp;'3'&nbsp;'4'&nbsp;'5'&nbsp;'6'&nbsp;'7'&nbsp;;&nbsp;first&nbsp;8&nbsp;characters</tt><br/>
    <tt>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'8'&nbsp;'9'&nbsp;'A'&nbsp;'B'&nbsp;'C'&nbsp;'D'&nbsp;'E'&nbsp;'F'&nbsp;;&nbsp;second&nbsp;8&nbsp;characters</tt><br/><br/>
    declares a page of ROM with the 16&nbsp;element array hex_to_ascii
    initialized with the values required to convert a 4-bit value to the
    corresponding hex ascii character.  This also illustrates how the
    initialization sequence (and length determination) can be continued on
    multiple lines.  If&nbsp;"<tt>outbyte</tt>" is a function that outputs a
    single byte to a port, then the hex value of a one-byte value can be output
    using the following sequence:<br/><br/>
    <tt>&nbsp;&nbsp;dup&nbsp;0&gt;&gt;&nbsp;0&gt;&gt;&nbsp;0&gt;&gt;&nbsp;0&gt;&gt;&nbsp;hex_to_ascii&nbsp;+&nbsp;.fetch(myROM)&nbsp;.call(outbyte)</tt><br/>
    <tt>&nbsp;&nbsp;0x0F&nbsp;and&nbsp;hex_to_ascii&nbsp;+&nbsp;.fetch(myROM)&nbsp;.call(outbyte)</tt><br/><br/>
    The first line extracts the most significant nibble of the byte by right
    shifting it 4 times while filling the left with zeros, adding that value to
    the address "<tt>hex_to_ascii</tt>" to get the corresponding ascii
    character, fetching that value from the ROM named "<tt>myROM</tt>", and then
    calling the function that consumes that value on the top of the stack while
    sending it to the output port (this takes 11 instructions).  The second line
    extracts the least significant nibble using an "<tt>and</tt>" instructions
    and then proceeds similarly (this takes 8 instructions).  The
    "<tt>.fetch</tt>" macro generates the "<tt>fetch</tt>" instruction using the
    3&nbsp;bit value of "<tt>myROM</tt>" as part of the memory address
    generation.<br/><br/>
  The "<tt>.store</tt>" macro is similar to the "<tt>.fetch</tt>" macro except
    that the assembler will generate an error message if a "<tt>store</tt>"
    operation is attempted to a ROM page.<br/><br/>
  Two additional variants of the "<tt>.fetch</tt>" and "<tt>.store</tt>" macros
    are provided.  The first, "<tt>.fetch(save_count)</tt>" will generate the
    2&nbsp;instruction sequence consisting of (1)&nbsp;the instruction to push
    the 8&nbsp;bit address of "<tt>save_count</tt>" onto the stack and
    (2)&nbsp;the "<tt>fetch</tt>" instruction with the 3&nbsp;bit page number
    associated with "<tt>save_count</tt>".  This helps ensure the correct page
    is used when accessing "<tt>save_count</tt>".  The instruction
    "<tt>store(save_count)</tt>" is similar.  The second variant of these is for
    indexed fetches and stores.  For example, the preceding example to convert
    the single-byte value to hex could be written as<br/><br/>
    <tt>&nbsp;&nbsp;dup&nbsp;0&gt;&gt;&nbsp;0&gt;&gt;&nbsp;0&gt;&gt;&nbsp;0&gt;&gt;&nbsp;.fetchindexed(hex_to_ascii)&nbsp;.call(outbyte)</tt><br/>
    <tt>&nbsp;&nbsp;0x0F&nbsp;and&nbsp;.fetchindexed(hex_to_ascii)&nbsp;.call(outbyte)</tt><br/><br/>
    Here, the macro "<tt>.fetchindexed</tt>" consumes the top of the data stack
    as an index into the array variable "<tt>hex_to_ascii</tt>" and pushes the
    indexed value onto the top of the data stack.<br/><br/>
  The "<tt>store</tt>" instruction must be followed by a drop instruction since
    it consumes the top two values in the data stack.  The "<tt>.store</tt>" and
    "<tt>.storeindexed</tt>" macros generate this drop function automatically.
    Thus, "<tt>.store(myRAM)</tt>" generates the 2&nbsp;instruction sequence
    "<tt>store&nbsp;drop</tt>", "<tt>.store(save_count)</tt>" generates the
    3&nbsp;instruction sequence "<tt>save_count&nbsp;store&nbsp;drop</tt>", and
    "<tt>.storeindexed(out_string)</tt>" generates the 4&nbsp;instruction
    sequence "<tt>out_string&nbsp;+&nbsp;store&nbsp;drop</tt>", all with the
    proviso that the "<tt>store</tt>" instructions include the 3&nbsp;bit
    address&nbsp;"<tt>myRAM</tt>".<br/><br/>
  <h2>Program Structure</h2>
  <h2>Directives</h2>
    Alphebetic listing:
      <a href="#.abbr">.abbr</a>,
      <a href="#.constant">.constant</a>,
      <a href="#.function">.function</a>,
      <a href="#.include">.include</a>,
      <a href="#.interrupt">.interrupt</a>,
      <a href="#.main">.main</a>,
      <a href="#.memory">.memory</a>,
      and <a href="#.variable">.variable</a>.<br/><br/>
    <h3><a name=".abbr">.abbr</a></h3>
      TODO
    <h3><a name=".constant">.constant</a></h3>
      TODO
    <h3><a name=".function">.function</a></h3>
      TODO
    <h3><a name=".include">.include</a></h3>
      TODO
    <h3><a name=".interrupt">.interrupt</a></h3>
      TODO
    <h3><a name=".main">.main</a></h3>
      TODO
    <h3><a name=".memory">.memory</a></h3>
      TODO
    <h3><a name=".variable">.variable</a></h3>
      TODO
  <h2>Macros</h2>
    Alphebetic listing:
      <a href="#.call">.call</a>,
      <a href="#.callc">.callc</a>,
      <a href="#.fetch">.fetch</a>,
      <a href="#.fetch+">.fetch+</a>,
      <a href="#.fetch-">.fetch-</a>,
      <a href="#.fetchindexed">.fetchindexed</a>,
      <a href="#.fetchvalue">.fetchvalue</a>,
      <a href="#.fetchvector">.fetchvector</a>,
      <a href="#.inport">.inport</a>,
      <a href="#.jump">.jump</a>,
      <a href="#.jumpc">.jumpc</a>,
      <a href="#.outport">.outport</a>,
      <a href="#.return">.return</a>,
      <a href="#.store">.store</a>,
      <a href="#.store+">.store+</a>,
      <a href="#.store-">.store-</a>,
      <a href="#.storeindexed">.storeindexed</a>,
      <a href="#.storevalue">.storevalue</a>,
      and <a href="#.storevector">.storevector</a>.<br/><br/>
    <h3><a name=".call">.call</a></h3>
      TODO
    <h3><a name=".callc">.callc</a></h3>
      TODO
    <h3><a name=".fetch">.fetch</a></h3>
      TODO
    <h3><a name=".fetch-">.fetch-</a></h3>
      TODO
    <h3><a name=".fetch+">.fetch+</a></h3>
      TODO
    <h3><a name=".fetchindexed">.fetchindexed</a></h3>
      TODO
    <h3><a name=".fetchvalue">.fetchvalue</a></h3>
      TODO
    <h3><a name=".fetchvector">.fetchvector</a></h3>
      TODO
    <h3><a name=".inport">.inport</a></h3>
      TODO
    <h3>.jump</h3>
      <b>Description:</b>  Generate the 3 instruction sequence associated with a <tt>jump</tt> instruction.<br/><br/>
      <b>Operation(1):</b>  <tt>.jump(label)</tt> generates the following 3 instructions:<br/>
        &nbsp;&nbsp;1&nbsp;&mdash;&nbsp;push the 8 lsb of the label address onto the data stack<br/>
        &nbsp;&nbsp;2&nbsp;&mdash;&nbsp;jump with the 5 msb of the label address encoded in the jump instruction<br/>
        &nbsp;&nbsp;3&nbsp;&mdash;&nbsp;no operation<br/><br/>
      <b>Operation(2):</b>  <tt>.jump(label,op)</tt> where "op" is an instruction generates the following 3 instructions:<br/>
        &nbsp;&nbsp;1&nbsp;&mdash;&nbsp;push the 8 lsb of the label address onto the data stack<br/>
        &nbsp;&nbsp;2&nbsp;&mdash;&nbsp;jump with the 5 msb of the label address encoded in the jump instruction<br/>
        &nbsp;&nbsp;3&nbsp;&mdash;&nbsp;op<br/><br/>
      Note that Operation(1) is a special case of Operation(2) with "op" being the <tt>nop</tt> instruction.<br/>
    <h3>.jumpc</h3>
      <b>Description:</b>  Generate the 3 instruction sequence associated with a <tt>jumpc</tt> instruction.<br/><br/>
      <b>Operation(1):</b>  <tt>.jumpc(label)</tt> generates the following 3 instructions:<br/>
        &nbsp;&nbsp;1&nbsp;&mdash;&nbsp;push the 8 lsb of the label address onto the data stack<br/>
        &nbsp;&nbsp;2&nbsp;&mdash;&nbsp;jump with the 5 msb of the label address encoded in the jump instruction<br/>
        &nbsp;&nbsp;3&nbsp;&mdash;&nbsp;drop<br/><br/>
      <b>Operation(2):</b>  <tt>.jumpc(label,op)</tt> where "op" is an instruction generates the following 3 instructions:<br/>
        &nbsp;&nbsp;1&nbsp;&mdash;&nbsp;push the 8 lsb of the label address onto the data stack<br/>
        &nbsp;&nbsp;2&nbsp;&mdash;&nbsp;jump with the 5 msb of the label address encoded in the jumpc instruction<br/>
        &nbsp;&nbsp;3&nbsp;&mdash;&nbsp;op<br/><br/>
      Note that Operation(1) is a special case of Operation(2) with "op" being the <tt>drop</tt> instruction.<br/>
    <h3><a name=".outport">.outport</a></h3>
      TODO
    <h3><a name=".return">.return</a></h3>
      TODO
    <h3><a name=".store">.store</a></h3>
      TODO
    <h3><a name=".store-">.store-</a></h3>
      TODO
    <h3><a name=".store+">.store+</a></h3>
      TODO
    <h3><a name=".storeindexed">.storeindexed</a></h3>
      TODO
    <h3><a name=".storevalue">.storevalue</a></h3>
      TODO
    <h3><a name=".storevector">.storevector</a></h3>
      TODO
</body>
</html>
