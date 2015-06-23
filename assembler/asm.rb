PREFIX = "x\"";
SUFFIX = "\"";
SEPERATOR = ", ";



class OpcodeByte1
  attr_accessor :op, :register, :cond;
  def to_hex
    s = (op << 4 | register.number << 1 | cond).to_s(16);
    if s.length == 1
      "0"+s;
    elsif s.length == 0
      "00";
    else
      s
    end
  end
end

class OpcodeByte2
  attr_accessor :cond, :reg2, :useextra, :reg3;
  def to_hex
    s=(cond << 7 | reg2.number << 4 | useextra << 3 | reg3.number).to_s(16);
    if s.length == 1
      "0"+s;
    elsif s.length==0
      "00";
    else
      s;
    end
  end
end
  

class Register8
  attr_accessor :number
  def initialize(num)
	@number=num
  end
end
class OpcodeOption
  attr_accessor :number
  def initialize(num)
    @number=num;
  end
end

$iftr = 0; #0 for no condition, 1 for if TR, 2 for if not TR
$useextra = 0;
$position = 0;

def set_cond(o1, o2)
  if $iftr==0 then
    o1.cond=0;
    o2.cond=0;
  elsif $iftr==1 then
    o1.cond=1;
    o2.cond=0;
  else
    o1.cond=0;
    o2.cond=1;
  end
end
def output_op(value)
  printf PREFIX + value + SUFFIX;
  printf SEPERATOR;
  $position+=2;
end


def mov_r8_imm8(reg,imm)
  o = OpcodeByte1.new();
  o.op = 0;
  o.register=reg;
  if $iftr<2 then
    o.cond=$iftr;
  else
    raise "if_tr_notset is not allowed with this opcode";
  end
  output_op(o.to_hex.rjust(2,"0") + imm.to_s(16).rjust(2,"0"))
end
def mov_rm8_imm8(reg,imm)
  o=OpcodeByte1.new();
  o.op=1;
  o.register=reg;
  if $iftr<2 then
    o.cond=$iftr;
  else
    raise "if_tr_notset is not allowed with this opcode";
  end
  output_op(o.to_hex.rjust(2,"0") + imm.to_s(16).rjust(2,"0"));
end

def do_group_reg_reg(opcode,group,reg1,reg2)
  o1 = OpcodeByte1.new()
  o1.op=opcode;
  o1.register=reg1;
  o2 = OpcodeByte2.new()
  o2.useextra=$useextra;
  o2.reg2=reg2;
  o2.reg3=OpcodeOption.new(group); #opcode group
  set_cond(o1,o2)
  output_op(o1.to_hex.rjust(2,"0") + o2.to_hex.rjust(2,"0"))
end
def do_subgroup_reg(opcode,group,subgroup,reg1)
  o1 = OpcodeByte1.new()
  o1.op=opcode;
  o1.register=reg1;
  o2 = OpcodeByte2.new()
  o2.useextra=$useextra;
  o2.reg2=OpcodeOption.new(subgroup);
  o2.reg3=OpcodeOption.new(group); #opcode group
  set_cond(o1,o2)
  output_op(o1.to_hex.rjust(2,"0") + o2.to_hex.rjust(2,"0"))
end

def and_reg_reg(reg1, reg2)
  do_group_reg_reg(4,0,reg1,reg2)
end;
def or_reg_reg(reg1, reg2)
  do_group_reg_reg(4,1,reg1,reg2)
end;
def xor_reg_reg(reg1, reg2)
  do_group_reg_reg(4,2,reg1,reg2)
end;
def not_reg_reg(reg1, reg2)
  do_group_reg_reg(4,3,reg1,reg2)
end;
def lsh_reg_reg(reg1, reg2)
  do_group_reg_reg(4,4,reg1,reg2)
end;
def rsh_reg_reg(reg1, reg2)
  do_group_reg_reg(4,5,reg1,reg2)
end;
def lro_reg_reg(reg1, reg2)
  do_group_reg_reg(4,6,reg1,reg2)
end;
def rro_reg_reg(reg1, reg2)
  do_group_reg_reg(4,7,reg1,reg2)
end;
#comparisons
def cmpgt_reg_reg(reg1, reg2)
  do_group_reg_reg(3,0,reg1,reg2)
end;
def cmpgte_reg_reg(reg1, reg2)
  do_group_reg_reg(3,1,reg1,reg2)
end;
def cmplt_reg_reg(reg1, reg2)
  do_group_reg_reg(3,2,reg1,reg2)
end;
def cmplte_reg_reg(reg1, reg2)
  do_group_reg_reg(3,3,reg1,reg2)
end;
def cmpeq_reg_reg(reg1, reg2)
  do_group_reg_reg(3,4,reg1,reg2)
end;
def cmpneq_reg_reg(reg1, reg2)
  do_group_reg_reg(3,5,reg1,reg2)
end;
def cmpeq_reg_0(reg1)
  do_group_reg_reg(3,6,reg1,Register8.new(0)) #last arg isn't used
end;
def cmpneq_reg_0(reg1)
  do_group_reg_reg(3,7,reg1,Register8.new(0))
end;

def mov_reg_mreg(reg1, reg2)
  do_group_reg_reg(5,2,reg1,reg2)
end
def mov_mreg_reg(reg1, reg2)
  do_group_reg_reg(5,3,reg1,reg2)
end
def mov_reg_reg(reg1, reg2)
  do_group_reg_reg(5,1,reg1,reg2)
end

  

def mov(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Integer and arg2<0x100 then
    mov_r8_imm8 arg1,arg2 
  elsif arg1.kind_of? Array and arg2.kind_of? Integer and arg2<0x100 then
    if arg1.length>1 or arg1.length<1 or not arg1[0].kind_of? Register8 then
      raise "memory reference is not correct. Only a register is allowed";
    end
    reg=arg1[0];
    mov_rm8_imm8 reg, arg2
  elsif arg1.kind_of? Array and arg2.kind_of? Register8 then
    if arg1.length>1 or arg1.length<1 or not arg1[0].kind_of? Register8 then
      raise "memory reference is not correct. Only a register is allowed";
    end
    mov_mreg_reg arg1[0], arg2
  elsif arg1.kind_of? Register8 and arg2.kind_of? Array then
    if arg2.length>1 or arg2.length<1 or not arg2[0].kind_of? Register8 then
      raise "memory reference is not correct. Only a register is allowed";
    end
    mov_reg_mreg arg1,arg2[0]
  elsif arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    mov_reg_reg arg1, arg2
  else
    raise "No suitable mov opcode found";
  end
end
def and_(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    and_reg_reg arg1,arg2
  else
    raise "No suitable and opcode found";
  end
end
def or_(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    or_reg_reg arg1,arg2
  else
    raise "No suitable or opcode found";
  end
end
def xor_(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    xor_reg_reg arg1,arg2
  else
    raise "No suitable xor opcode found";
  end
end
def not_(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    not_reg_reg arg1,arg2
  else
    raise "No suitable not opcode found";
  end
end
def rsh(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    rsh_reg_reg arg1,arg2
  else
    raise "No suitable rsh opcode found";
  end
end
def lsh(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    lsh_reg_reg arg1,arg2
  else
    raise "No suitable lsh opcode found";
  end
end
def rro(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    rro_reg_reg arg1,arg2
  else
    raise "No suitable rro opcode found";
  end
end
def lro(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    lro_reg_reg arg1,arg2
  else
    raise "No suitable lro opcode found";
  end
end

def cmpgt(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    cmpgt_reg_reg arg1,arg2
  else
    raise "No suitable cmpgt opcode found";
  end
end
def cmpgte(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    cmpgte_reg_reg arg1,arg2
  else
    raise "No suitable cmpgte opcode found";
  end
end
def cmplt(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    cmplt_reg_reg arg1,arg2
  else
    raise "No suitable cmplt opcode found";
  end
end
def cmplte(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    cmplte_reg_reg arg1,arg2
  else
    raise "No suitable cmplte opcode found";
  end
end
def cmpeq(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    cmpeq_reg_reg arg1,arg2
  elsif arg1.kind_of? Register8 and arg2.kind_of? Integer and arg2==0 then
    cmpeq_reg_0 arg1
  else
    raise "No suitable cmpeq opcode found";
  end
end
def cmpneq(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Register8 then
    cmpneq_reg_reg arg1,arg2
  elsif arg1.kind_of? Register8 and arg2.kind_of? Integer and arg2==0 then
    cmpneq_reg_0 arg1
  else
    raise "No suitable cmpneq opcode found";
  end
end

def Label
  attr_accessor :name, :pos
  def initialize(name, pos)
    @name=name;
    @pos=pos;
  end
end
$labellist={}
def new_label(name)
  $labellist[name.to_s]=$position;
end
def lbl(name)
  $labellist[name.to_s];
end
  
  
def if_tr_set
  $iftr = 1
  yield
  $iftr = 0
end


r0=Register8.new(0)
r1=Register8.new(1)
r2=Register8.new(2)
r3=Register8.new(3)
r4=Register8.new(4)
r5=Register8.new(5)
sp=Register8.new(6)
ip=Register8.new(7)


#test code follows. Only do it here for convenience.. real usage should prefix assembly files with `require "asm.rb"` 


#port0(0) is LED port0(1) is a button

mov r4, 1
mov r5, 0xFD
#mov r5, 0x01 #the port bitmask
mov [r4],r5
mov r3, 0
mov [r3], 0
mov r2, 0x02
#poll for button
new_label :loop
mov r0, [r3]
and_ r0, r2 #isolate just the button at pin 2
cmpneq r0, 0
if_tr_set{
  mov [r3], 0x01
}
cmpeq r0,0
if_tr_set{
  mov [r3], 0x00
}
mov ip, lbl(:loop)

printf("\n");
while $position<64
  printf("x\"0000\", ")
  $position+=2;
end
puts "\nsize:" + $position.to_s
