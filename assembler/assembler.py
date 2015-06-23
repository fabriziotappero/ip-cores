#!/usr/bin/python

import sys
import re

tipo1=['ldi','ldm','stm', 'adi']
tipo2=['cmp','add','sub','and','oor','xor']
tipo3=['jmp','jpz','jnz','jpc','jnc','csr', 'csz', 'cnz', 'csc', 'cnc']
tipo4=['sl0','sl1','sr0','sr1','rrl','rrr', 'not']
tipo5=['ret', 'nop']
#instruccion   opcode
opcodes={}
opcodes['ldi']=2;
opcodes['ldm']=3;
opcodes['stm']=4;
opcodes['cmp']=5;
opcodes['add']=6;
opcodes['sub']=7;
opcodes['and']=8;
opcodes['oor']=9;
opcodes['xor']=10;
opcodes['jmp']=11;
opcodes['jpz']=12;
opcodes['jnz']=13;
opcodes['jpc']=14;
opcodes['jnc']=15;
opcodes['csr']=16;
opcodes['ret']=17;
opcodes['adi']=18;
opcodes['csz']=19;
opcodes['cnz']=20;
opcodes['csc']=21;
opcodes['cnc']=22;
opcodes['sl0']=23;
opcodes['sl1']=24;
opcodes['sr0']=25;
opcodes['sr1']=26;
opcodes['rrl']=27;
opcodes['rrr']=28;
opcodes['not']=29;
opcodes['nop']=30;



def verify_args(line):
    if len(line)>1:
        line_split=line.split()
        opcode=line_split[0]
        if opcode in tipo1+tipo2+tipo4:
            args=re.findall(r'r(\d+)',line)
    else:
        return 'invalid command'
    
    if not opcode in tipo1+tipo2+tipo3+tipo4+tipo5:
        return 'invalid command'
    else:
        if opcode in tipo1:
            arg2=line.split(',')
            direccion=arg2[1]
            
            if len(args)!=1 :
                return 'incorrect number of arguments'
            else:
                if int(args[0])<0 or int(args[0])>7:
                    return 'arg1 out of range (0-7)'
                else:    
                    if int(direccion)<0 or int(direccion)>255:
                        return 'addr out of range (0-255)'
                    else:
                        return 'ok'
                    
        if opcode in tipo2:
            if len(args)!=2:
                return 'incorrect number of arguments'
            else:
                if int(args[0])<0 or int(args[0])>7:
                    return 'arg1 out of range (0-7)'
                else:    
                    if int(args[1])<0 or int(args[1])>7:
                        return 'arg2 out of range (0-7)'
                    else:
                        return 'ok'
        if opcode in tipo3:
            addr=line_split[1]
            if len(line_split)!=2:
                return 'incorrect argument'
            else:
                if int(addr)<0 or int(addr)>2048:
                    return 'addr out of range (0-2048)'
                else: 
                    return 'ok'
                
        if opcode in tipo4:
            if len(args)!=2 :
                return 'incorrect number of arguments'
            else:
                if int(args[1])<0 or int(args[1])>7:
                    return 'arg1 out of range (0-7)'
                else:    
                    return 'ok'
                
        if opcode in tipo5:
            return 'ok'
                

def extract_info(file,flag):
    tags={}
    f=open(file,'rU')
    text=f.read()
    f.close()    
    text=text.lower()
    
    
    #para quitar los saltos de linea '\n' '\t' al final del archivo
    while text[-1]=='\n' or text[-1]=='\t' or text[-1]=='\s' or text[-1]=='\r':
        text=text[:-1]
    
    lines=text.split('\n')
    line_number=0
    lines2=[]
    
    for line in lines:
        if len(line)!=0:
            line_split=line.split()
            opcode=line_split[0]
            if not opcode in tipo1+tipo2+tipo3+tipo4+tipo5:
                if not opcode in tags:
                    tags[opcode]=line_number
                    line=' '.join(line_split[1:])
                    line='\t'+line
                    
                else:
                    print 'label used more than once'
        
            lines2.append(line)
            line_number+=1
        
    text2='\n'.join(lines2)
    ##parte que se encarga de reemplazar los tags en las direcciones
    for tags_elements in tags.keys():
        line2=text2.split(tags_elements)
        text2=str(tags[tags_elements]).join(line2)
    
    
    lines=text2.split('\n')
    error_line=0
    text_asm=''
    for line in lines:
        erro=verify_args(line)
        if erro!='ok':
            print 'error in line:',error_line 
            print line, '->', erro,'\n'
        else: 
            line_split=line.split()
            opcode=line_split[0]
            if opcode in tipo1+tipo2+tipo4:
                args=re.findall(r'r(\d+)',line)
            if opcode in tipo1:
                arg2=line.split(',')
                direccion=arg2[1]
                dato=(opcodes[opcode]<<11) | (int(args[0])<<8) | int(direccion)
                text_asm+= '%X' % dato + '\n'
            if opcode in tipo2:
                dato=(opcodes[opcode]<<11) | (int(args[0])<<8) | (int(args[1])<<5)
                text_asm+= '%X' % dato + '\n'
            if opcode in tipo3:
                addr=line_split[1]
                dato=(opcodes[opcode]<<11) | int(addr) 
                text_asm+= '%X' % dato + '\n'
            if opcode in tipo4:
                dato=(opcodes[opcode]<<11) | (int(args[1])<<8) 
                text_asm+= '%X' % dato + '\n'
            if opcode in tipo5:
                dato=(opcodes[opcode]<<11) 
                text_asm+= '%X' % dato + '\n'
        error_line+=1
        
    line_show=text2.split('\n')
    line_text=text_asm.split('\n')
    
    if flag:
        print 'addr inst\t\t\t\tasm\n'
        for i in range(len(line_show)):
            esp=4-len(line_text[i])
            val=''
            while esp:
                esp-=1
                val+=' '
            
            ntabs=5-len(str(i))
            tab=' '
            etab=''
            ctabs=0
            while ctabs<ntabs:
                ctabs+=1
                etab+=tab
            
            print str(i)+etab+line_text[i]+val+'\t'+line_show[i]
            
    line_zero=''

    for i in range(2048-len(line_show)):
        line_zero=line_zero+'0000\n'
    text_asm+=line_zero
    
    return text_asm

def main():
    
    args = sys.argv[1:]
    
    if not args:
        print 'uso: ./assembler.py [-s] archivo.asm'
        sys.exit(1)
        
    show = False
    if args[0] == '-s':
        show = True
        del args[0]
    
    text=extract_info(args[0],show)
    outf = open('instructions.mem', 'w')
    outf.write(text)
    outf.close()
  


if __name__ == '__main__':
  main()