#  Copyright 2015 Abid Hasan Mujtaba
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#
#  This is the Makefile which provides targets for common actions that one can perform with this project.

# We provide a list of phony targets which specify actions that are not based on changes in the code-base
.PHONY: clean, test, ghci, unit, quick, prof, heap, stats, prof_test, heap-d, heap-r, heap-b, heap-y

# We define a simple variable for specifying which main function in the Test.hs script to use
# The default value is 'main' and is used when the 'make test' is executed
# The 'unit' and 'quick' targets redefine this variable before running 'test'
MAIN = main

# Analogous to MAIN we define PROF and PROF_FLAGS variables which are empty be default but are populated when the 'prof' target is executed. These add flags to the compilation and execution commands that allow profiling to occur.
PROF =
PROF_FLAGS =

clean:				# Clean the compilation by-products (.hi, .o, .prof files and executables)
	rm -f *.hi *.o *.prof *.hp *.aux *.ps Test test


# test: Test
# 	./Test ${PROF}

# Note: An @ symbol placed at the start of a command stops the executed command from being printed. We simply run the 'Test' executable. Profiling flags may be present if the 'prof' target is executed

# The test target has the file Test as its dependency.
# If the file doesn't exist the 'Test' rule is executed.
# If it does exist the rule is still tested for recursive dependencies


# Define targets for running a subset of the tests. This is carried out by redefining the MAIN variable
# Note how 'test' is the only target of both 'unit' and 'quick'. The drawback of this strategy is that the 'Test' target is only activated when one of the .hs scripts change. So running one of the test targets after another one does NOT recompile the module and so the previously specified tests are run. This can be overcome by either running 'make clean' or by "touching" one of the dependencies of the 'Test' target.

# unit: MAIN = main_unit
# unit: test
#
# quick: MAIN = main_quick
# quick: test

# Define a phony target for compiling and executing the tests with profiling activated. This makes use of the PROF and PROF_FLAGS variables which are empty by default.

# Time and Space Profiling. Generates a Test.prof file.
prof_test: PROF_FLAGS = -prof -fprof-auto-calls
prof_test: test

prof: PROF = +RTS -p
prof: prof_test


# Source for heap profile options: https://downloads.haskell.org/~ghc/7.6.3/docs/html/users_guide/prof-heap.html

# Heap Profiling by cost-center. This generates a Test.hp file. One can plot the profile data by running 'hp2ps Test.hp' which generates a Test.ps file with a graph in it.
# The -L20 flag tells the profile to use 20 characters (instead of the default 25) for the methods being profiled.
# Note that the profiled method names are in reverse order with the last method in the call-tree listed first.
heap: PROF = +RTS -hc -L20
heap: prof_test

# Heap profile by "closure description"
# This displays thunks on the heap in particular closures which don't have a well-defined name
heap-d: PROF = +RTS -hd -L20
heap-d: prof_test

# Heap Profiling that focuses on retainers
heap-r: PROF = +RTS -hr -L20
heap-r: prof_test

# Biographical Heap Profiling
heap-b: PROF = +RTS -hc -hbdrag,void
heap-b: prof_test

# Heap Profile broken down by "type"
heap-y: PROF = +RTS -hy
heap-y: prof_test



# Display the graph generated by the heap profile
graph:
	hp2ps Test.hp
	okular Test.ps > /dev/null 2>&1 &


stats: PROF_FLAGS = -rtsopts
stats: PROF = +RTS -sstderr
stats: test


# Test: Test.hs CAS.hs Vars.hs Makefile
# 	ghc --make ${PROF_FLAGS} -main-is Test.$(MAIN) Test.hs

# We declare Test.hs to be a dependency of the executable Test.
# If the timestamp on Test.hs is newer than that of Test Make knows that code changes have been made and so it runs the command (rule) specified.
# Similarly if CAS.hs was changed recently we want the compilation to occur again to incorporate these changes.
# The command simply compiles the Test.hs file and creates the Test executable
# Note the use of -main-is which is used to specify the main function since it is inside the Test module and not a module named Main which is where ghc searches for it by default.
# Note the use of the MAIN variable to define which function to use as the main function while compiling the script. The different targets (test, unit and quick) define this differently to access different main functions to limit the tests being run
# Note the use of the PROF_FLAGS variable which when set for the 'prof' target causes the test module to be compiled with profiling enabled.


# ghci:
# 	make clean
# 	ghci Vars.hs

# Running ghci with a compiled module adds both Prelude and CAS together which causes conflicts in such things as the ^ operator. So in this target we first remove the compiled modules and then run ghci.
# By providing the module name after ghci the module is loaded from the start.
# Since Vars.hs imports CAS before it defines useful symbols and constants you automatically import CAS when you load the Vars module
