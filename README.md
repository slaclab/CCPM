# Coherent Combination Propagation Method
Full scalar wave propagation (spectral) using the Angular Spectrum Method. Further details can be found in: Lemons, Randy, and Sergio Carbajo. "Reconstruction and Optimization of Coherent Synthesis by Fourier Optics Based Genetic Algorithm." arXiv preprint arXiv:2005.13671 (2020).

# Introduction
This is intended to be the repo for the beam combination project as part of the L4A group in the LCLS division of SLAC National Accelerator Laboratory. The benefit of this code over existing ones is programmatic support for non-traditional beam definitions including common schemes of free space coherent beam combination. Additionally it contains a Genetic Algorithm that can be used to find combination parameters based on real world data collected on cameras.

All files in this repo should be solely code. This is not the place to store results, simulation parameters, images, etc. This restriction is to maintain the cleanliness of the repo and to keep it from growing to an unmanageable size due to large files. This is also going to be the matlab implementation of the code.

# Style Guide
1) Every variable and function generally abides by camelCase. 
2) Occasionally words are broken up with an underscore if it is delimiting a variable or function that is used interchangeably with different parameters ie. hex_NBeams and rect_NBeams.
3) If something is repeated multiple times in the code or may be applicable elsewhere it is often it’s own function with different calling styles.
4) The code should be commented judiciously. In general functions have a comment describing its purpose and use. Lines of code that are doing some tricky indexing or clever manipulation of the data generally have a description of their purpose.

# Coding Choices
The code has been built so that it is without regard to any particular units (ie. mm or s); however, it is still fully consistent to whatever units you want to choose. This means that any particular unit can be used as long as all variables have the proper magnitude. Additionally, the numerical grid is built from the size in real space and the number of points in each direction to use. This is because humans think better in seeing a 4 cm by 4 cm square that runs at a certain speed than seeing 2^12 by 2^12 points that are spaced 0.001 mm apart. Setting mm = 1 seems to be the best of balancing the scales of numbers (and the GA pretty much assumes that).

The code is built from an object-oriented (classes) approach as this is an easy way to hold all information about the simulation in a single 'variable'. This also allows new properties to be added on the fly to the class definition without affecting other parts of the code. The last coding choice to mention is that the class was built with the idea of being able to input and output any given properties. In particular, the field definition functions can be fed properties to use for building the initial field without any GUI interaction.

MATLAB is used as the code language of choice for the quick proto-typing, extensive documentation, and out-of-the box optimization.

# Installation and Use

### Install
This class is easily installed to any MATLAB distribution with only the base tools from 2018b forward. Simply clone or download the repo folder and add it to your MATLAB path.

### Use
##### Beam Propagation
Once you have the `@beamPropagation2D` class on your path then all use starts at the creation of a object with a call like `obj = beamPropagation2D(varargin);`

All calls are defined by one of the following syntaxes:

- `obj = beamPropagation2D()`
- `obj = beamPropagation2D(obj)` or `obj = beamPropagation2D(struct)`
- `obj = beamPropagation2D(lambda,xLen,yLen,npts)`
- `obj = beamPropagation2D(lambda,xLen,yLen,npts,shapeString)`
- `obj = beamPropagation2D(lambda,xLen,yLen,npts,shapeString,inputParams)`

`obj = beamPropagation2D()` returns a beamProp object that has all of the properties empty. The main use of this is to return a placeholder object that can be defined later or if you just want to see what all properties exist.

`obj = beamPropagation2D(obj)` or `obj = beamPropagation2D(struct)` is used to copy the properties of one beamProp object or of a struct with the same properties to a new object. If you were to use the syntax `beamProp2 = beamProp1` instead, both handles would point to the same places in memory and modifying one would change the other.

`obj = beamPropagation2D(lambda,xLen,yLen,npts)` creates a beamProp object, sets up the gridding, and creates a blank field. This can be used to reserve essentially all of the memory that the object will take up. Other properties can/will be defined later but the memory sink is the field matrix.

`obj = beamPropagation2D(lambda,xLen,yLen,npts,shapeString)` does everything the previous call does but also calls GUI help for defining the field based on shapeString. The currently defined methods for field creation are: `’gauss’`, `’laguerre’`, `’hermite’`, `’input’`, `’hex’`, `’rect’`, and `’man’`. `’gauss’` creates a standard Gaussian field whereas `’laguerre’` and `’hermite’` can be used to create the expected higher order modes. `’input’` allows field definition from either a three column csv (x,y,z) or from a png or jpg image. There is currently no phase definition with `’input’`. `’hex’` creates a hexagonal close pack of gaussian beams where the amplitude, phase offset (think time displacement), and phase curvature can be set for each beam. `’rect’` allows the same beam definition but with the beams arranged rectangularly rather than hexagonally. `’man’` allows you to place as many beams on the field as you want in whatever configuration you can think of with any different properties. This is the most open and provides no sanity checking.

`obj = beamPropagation2D(lambda,xLen,yLen,npts,shapeString,inputParams)` is the same as before but removes the GUI aspect and instead defines the field based on the properties in inputParams. This allows programmatic definition of new fields. `inputParams` should be a struct with the same field names as those that are set by `shapeString`. To get a list of the fields you can use the function `struct = obj.outputProperties2D(shapeString)`.

Once an initial field is defined then calls to `obj.forwardProp_FreeSpace2D(z)` and `obj.backwardProp_FreeSpace2D(z)` propagate a beam. Both of these methods return the propagated field but don't change the currently defined one in the object. To redefine the field as the propagated one directs the output to `obj.field_fList`. If you will be doing a bunch of propagations over a constant z, then `obj.field_phasevec = obj.genPropPhase(z)` can be used to save the matrix defining propagation phase. This saves computation time but requires more memory per object. 

Lastly there are two ways to plot the field. The first is simply `obj.plotField2D(plotType)` where `plotType` is either `’abs’` or `’angle’`. This plots either the intensity or the phase of the field currently defined in `obj.field_fList`. The next is `obj.makeMovie2D(plotType)` or `obj.makeMovie2D(plotType,d0,dF,nSteps,fileName)` which will save a gif of the propagation from initial point, `d0`, to final point, `dF`, in `nSteps` and in the current folder as `fileName`.

##### Genetic Algorithm
Explaining what a GA is or what it accomplishes is out of scope here. In the current day and age there is an uncountable amount of info out there that you should peruse first. Additionally it is a good idea to get a handle on the `beamPropagation2D` class before tackling this.

Like `beamPropagation2D` this is a class, `genAlgBeamProp` and it can be created with similar syntax:
- `obj = genAlgBeamProp()`
- `obj = genAlgBeamProp(obj)` or `obj = genAlgBeamProp(struct)`
- `obj = genAlgBeamProp(‘GUI’)`

`obj = genAlgBeamProp()` creates a blank object like `beamPropagation2D`

`obj = genAlgBeamProp(obj)` and `obj = genAlgBeamProp(struct)` act similarly to `beamPropagation2D`. Both calls will import the fields from one to the new one; however, `obj` will always return right after import and `struct` will return if `struct.final_props` is not empty. If that property is empty then it will attempt to set up the GA based on the properties in `struct`. This is intentional because there are a number of properties that are needed and a struct really is the best way to hold them. A struct with the necessary properties to initialize can be returned by the function call `genAlgBeamProp.initStruct()`. This function also accepts `’img’` and `’gif’` (or both) as inputs. `’img’` returns properties that need to be set to act on real data collected from a camera. `’gif’` returns properties that need to be set to create and save a gif of the GA working.

`obj = genAlgBeamProp(‘GUI’)` starts a GUI to help you set all of the needed properties based on whatever run you want to do. This is the best place to start before trying to do it programatically.

To best get an idea of how to initialize, run, and interpret data from a `genAlgBeamProp` object it is best to look at `GenAlgInit.m`
