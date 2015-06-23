################################################################################
#
# Copyright 2013, Sinclair R.F., Inc.
#
################################################################################

import ssbccUtil

def genVhdlPkg(config):
  """
  Method to generate a VHDL Package file corresponding to the instantiated micro
  controller.
  """
  coreName = config.Get('outCoreName');
  packageName = '%s_pkg' % coreName;
  packageFileName = '%s.vhd' % packageName;
  try:
    fp = open(packageFileName,'wt');
  except:
    raise SSBCCException('Could not open %s' % packageFileName);
  fp.write('library ieee;\n');
  fp.write('use ieee.std_logic_1164.all;\n');
  fp.write('package %s is\n' % packageName);
  fp.write('component %s is\n' % coreName);
  # If any, write the generics.
  if config.parameters:
    fp.write('generic (\n');
    lines = ['  %s : std_logic_vector(31 downto 0) := x"%08X"' % (p[0],ssbccUtil.IntValue(p[1]),) for p in config.parameters];
    for ix in range(len(lines)-1):
      lines[ix] += ';'
    for l in lines:
      fp.write('%s\n' % l);
    fp.write(');\n');
  # Start the port list, initialize each line with two spaces, and make a list of the lines that are signal declarations.
  fp.write('port (\n');
  nIOs = len(config.ios);
  lines = ['  ' for ix in range(nIOs)];
  signals = [i for i in range(nIOs) if config.ios[i][2] != 'comment'];
  # Generate the comment lines.
  for ix in [i for i in range(nIOs) if i not in signals]:
    lines[ix] += '-- %s' % config.ios[ix][0];
  # Add the signal name to each signal declaration and the trailing spaces and ':'.
  for ix in signals:
    lines[ix] += config.ios[ix][0];
  maxLen = max([len(lines[ix]) for ix in signals]);
  # Add the signal direction to each signal declararation.
  for ix in signals:
    lines[ix] += ' '*(maxLen-len(lines[ix])) + ' : ';
  for ix in [i for i in signals if config.ios[i][2] == 'input']:
    lines[ix] += 'in';
  for ix in [i for i in signals if config.ios[i][2] == 'output']:
    lines[ix] += 'out';
  for ix in [i for i in signals if config.ios[i][2] == 'inout']:
    lines[ix] += 'inout';
  maxLen = max([len(lines[ix]) for ix in signals]);
  for ix in signals:
    lines[ix] += ' '*(maxLen-len(lines[ix])+1);
  # Add the signal type to the signal declarations.
  for ix in [i for i in signals if config.ios[i][1] == 1]:
    lines[ix] += 'std_logic';
  for ix in [i for i in signals if config.ios[i][1] != 1]:
    lines[ix] += 'std_logic_vector(%d downto 0)' % (config.ios[ix][1]-1);
  # Add the trailing ';' to all but the last signal declaration.
  for ix in signals[:-1]:
    lines[ix] += ';';
  # Write the signal declarations and the associated comments.
  for l in lines:
    fp.write(l+'\n');
  fp.write(');\n');
  fp.write('end component %s;\n' % coreName);
  fp.write('end package;\n');
  fp.close();
