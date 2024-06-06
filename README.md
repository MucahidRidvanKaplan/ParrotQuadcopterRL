# ParrotQuadcopterRL
Reinforcement Learning for Parrot Mambo Minidrone Attitude Control

## [Quadcopter Modeling and Simulation based on Parrot Minidrone](https://www.mathworks.com/help/aeroblks/quadcopter-modeling-based-on-parrot-minidrone.html)

### This project uses:
* Matlab
* Simulink
* Aerospace Toolbox
* Aerospace Blockset
* Control System Toolbox
* Image Processing Toolbox
* Deep Learning Toolbox
* Reinforcement Learning Toolbox
* Optimization Toolbox
* Simulink Control Design
* Signal Processing Toolbox
* Computer Vision Toolbox
* Simulink 3D Animation

This project shows how to use Simulink® to model, simulate, and visualize a quadcopter, based on the Parrot® series of mini-drones.

For more details on the quadcopter implementation, see [Model a Quadcopter Based on Parrot Minidrones](https://www.mathworks.com/help/aeroblks/quadcopter-project.html).

**Note:** Hardware integration with the example would require installation of the [Simulink Support Package for Parrot Minidrones](https://www.mathworks.com/hardware-support/parrot-minidrones.html) and a C/C++ compiler.

## Open the Quadcopter Project
Run the following command to create and open a working copy of the project files for this project:
```
openProject('Quadcopter');
```

## Design
The high-level design is as shown below, with each component designed as separate subsystems, and each subsystem supports multiple approaches, in the form of variants.
![image](https://github.com/MucahidRidvanKaplan/ParrotQuadcopterRL/assets/32431520/0b430561-9ae9-475c-b2d9-fa89d2e4b1e5)

### Command

Provides input command signals to all six degrees of freedom (x, y, z, roll, pitch, yaw). The VSS_COMMAND variable can be used to selectively provide the input command signal using:
* Signal Editor Block
* Joystick
* Pre-saved Data
* Spreadsheet

### Environment

Sets the environmental parameters, gravity, temperature, speed of sound, pressure, density, and magnetic field to appropriate values. The VSS_ENVIRONMENT variable can be used to selectively set the environment parameter values to be:
* Constant
* Variable

### Sensors

Measures the position, orientation, velocity, and acceleration of the vehicle and also captures the visual data. The VSS_SENSORS variable can be used to selectively set the sensors to be:

* Dynamic
* Feedthrough

### Airframe

Select the vehicle model, as either, nonlinear, or linear using the VSS_AIRFRAME variable. The linear state-space model is obtained by linearizing the non-linear model about a trim solution using the Simulink Control Design toolbox.

### FCS (Flight Control System)

The FCS consists of:

* __Estimators:__ implemented using a complementary filter and Kalman filter to estimate the position and orientation of the vehicle. The estimator parameters are based on [1].
* __Flight Controller:__ implemented using PID controllers to control the position and orientation of the vehicle.
* __Landing Logic:__ implements the algorithm to override the reference commands and land the vehicle in specific scenarios.

![image](https://github.com/MucahidRidvanKaplan/ParrotQuadcopterRL/assets/32431520/ce88f8c4-a503-4e8a-9e8a-4b4a2a3808e2)


### Visualization

The actuator input values, the vehicle states, and the environment parameter values are logged and can be visualized using the Simulation Data Inspector. The vehicle orientation and actuator input values are displayed using Flight Instruments.

In addition, the VSS_VISUALIZATION variable can be used to visualize the vehicle orientation using:

* Scopes
* In Workspace
* FlightGear
* Airport scene
* AppleHill scene: requires Unreal from Epic Games® and the Aerospace Blockset Interface for Unreal Engine® support package installed.

## Implementation

* The AC cmd bus signal from the Command subsystem forms the reference signal to the FCS subsystem.
* The Environment bus signal from the Environment subsystem has the environment data and is passed on to the Sensors subsystem (acceleration due to gravity input for the Inertial Measurement Unit), and the Airframe subsystem (used in computation of forces and moments).
* The Sensors bus signal and the Image Data from Sensors subsystem form the measured signal, providing information on the current state of vehicle, to the FCS subsystem.
* The FCS subsystem consisting of estimators and controllers computes the command signal to the quadcopter motors, Actuators, based on the reference and measured signals. The additional output from FCS, Flag will stop the simulation if the vehicle state values (position and velocity) cross certain safe limits.
* The Airframe subsystem acting as the plant model, takes the Actuator commands as inputs to the motors corresponding to the four rotors of the quadcopter. The Multirotor block, the implementation of which is based on [2], and [3], is used in the computation of forces and moments. The output from the Airframe subsystem is the States bus signal, which is fed back to the Sensors subsystem.
* The Visualization subsystem uses the AC cmd bus signal(reference command signal), the Actuators input generated by FCS, and the States bus signal from Aiframe subsystem to aid in the visualization.

## References
[1] https://github.com/Parrot-Developers/RollingSpiderEdu/tree/master/MIT_MatlabToolbox/trunk/matlab/libs/RoboticsToolbox.

[2] Prouty, R. Helicopter Performance, Stability, and Control. PWS Publishers, 2005.

[3] Pounds, P., Mahony, R., Corke, P. Modelling and control of a large quadrotor robot. Control Engineering Practice. 2010.
