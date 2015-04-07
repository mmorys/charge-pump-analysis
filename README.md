charge-pump-analysis
====================

**Author:**  
Marcin M. Morys  
The Propagation Group, Georgia Institute of Technology  
http://www.propagation.gatech.edu/  
marcin.m.morys@gmail.com  

**Description:**  
MATLAB code for analyzing Dickson charge pump performance utilizing LTSpice transient simulation.  

**Requirements:**  
{  
MATLAB base program (http://www.mathworks.com/products/matlab/ - Paid software)  
OR  
Octave (https://www.gnu.org/software/octave/ - Free software)  
}  
AND  
LTSpice IV (http://www.linear.com/designtools/software/ - Free software)  

**Running the code:**  
1. Add LTspice executable to the system path (first time only)
  1. Find LTspice executable (scad3.exe) in Windows Explorer
    1. By default this is C:\Program Files (x86)\LTC\LTspiceIV\scad3.exe
  2. Add the path of scad3.exe to the system path
    1. Click Start -> Control Panel -> System -> Advanced system settings -> Environment Variables...
    2. Under System variables, find Path in the list box
    3. Click on Path, then click “Edit...”
    4. Append the path of scad3.exe to the Environment value string  (For example, by default append “;C:\ProgramFiles (x86)\LTC\LTspiceIV” to the end of the Variable value string. Do not delete any of the current values.)

2. Adjust the simulation settings in the user_inputs.m file and save. Under normal operation, there should be no need to make changes to any other files

3. Run the charge_pump_analysis.m script

**Note:**  
This software was developed under a Windows operating system. While it may work under OS X or other LTspice supported operating systems, this may require some changes to the code.  
