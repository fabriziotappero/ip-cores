# Work_dirin maaritys kayttaa nykyista hakemistoa (pwd) 

echo " "
echo "This environment.cshrc script must be from the same directory where this is located!"
echo " "

# Newest modelsim on Lion is 5.5d
# Panther has all of thse, but 5.6b crashed
# with tb_two_wrappers, so 5.7a is used instead
# 17.09.03 es

# HP-machines use one of these
# source /opt/modeltech-5.5d/modeltech.cshrc
# source /opt/modeltech-5.6b/modeltech.cshrc
# source /opt/modeltech-5.7a/modeltech.cshrc

#tulitikli uses one of these
#source /opt/mentor/modeltech-5.7g/modeltech.cshrc
#source /opt/mentor/modeltech-5.8/modeltech.cshrc
source /opt/mentor/modeltech-6.0a/modeltech.csh


# Synopsys-hommat pitaa sourcettaa vastaa Mentorin
# juttujen jalkeen, koska paskat Mentorin softat ei muuten
# toimi. Tulee maailman informatiivisin
# virheilmoitus "printenv: Undefined variable."
# hp:
#source /opt/synopsys/syn-2000.11/synopsys.cshrc

# tulitikli:
#source /opt/synopsys/syn-2002.05-SP2/synopsys.cshrc





setenv USER_HOME $HOME


setenv MEM_DATA_DIR /tmp/${USER}/Mem
setenv MEM_WORK_DIR ${PWD}

echo "###########"
echo Directory settings for mem
echo   Mem_data_dir = $MEM_DATA_DIR
echo   Mem_work_dir = $MEM_WORK_DIR
echo "###########"





echo; echo " Environment is set"
