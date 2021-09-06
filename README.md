# Bluetooth_Car_IOS_App
A BLE JoyStick Car Controller


![Alt text](/ImagesofApp/AppIcon.jpg?raw=true "JoyRide App")


## Description
The Bluetooth Car IOS App is an app that allows users with 
IOS 12.4 and higher to connect through Bluetooth Low Energy 
(BLE)to an ESP32 in order to send commands to prompt movement 
of a ESP32 car with a custom JoyStick controller button, to 
make a honk sound with the honk button, and to turn on and 
off car lights with light button or turn on automated lights 
with the toggle. The automated lights requires the ESP32 be 
connected with ambient light sensor. The car also will track 
speed in mm/ms for every 10 seconds if encoders are included in 
the build of the car. 

UI Pan Gestures were used for the joystick button to allow for 
more variability in speeds, so that the user had more options 
for how they wanted the car to drive. BLE was used because it 
allowed for the car to use less energy and conserve power.

Some challenges faced included figuring out a good range of 
positions to record for the joystick button that allowed the 
user more variability of the car directions while trying to 
make sure the controller was not too sensitive that the car
would spin out of control at the slightest movement of the 
joystick. 
There was also a challenge in the range of connectivity being 
short as a result of using BLE. 
There was no joystick button built into an app, so we had to 
build one with UI Pan Gestures and Constraints. We then had to
map every cartesian point of the joystick to a PWM value for each 
wheel. We were sending too many values through BLE so that controlling 
the car was delayed. We had to sample fewer points. The light was 
flickering at the cutoff point, so we implemented a bang-bang type 
light controller. We had originally mapped all points in our 84 radius 
circle for the joystick to the 255 PWM values. However, we noticed that 
our car wheel would not start moving until we reached a PWM of 190. We 
had to map our values instead from 190 to 255.

Future improvements would be to lower the sensitivity of the joystick button 
and to implement a backup lights feature. 

## How to Install
Open the .xcodeproj file in Xcode. Connect the Iphone so that you can build 
and run the app on it.

## How to Use 

<img src="/ImagesofApp/MainViewController.PNG"  height="500"> <img src="/ImagesofApp/ScanViewCotroller.PNG" height="500">

Make sure the ESP32 is on to be able to locate it. Then on the app, select scan 
and look for the device. Select the device to connect to it. You can select the
autolight toggle to  activate the light button to allow for manual control of the
light. The Honk horn button is below the light button and allows the car to make a
honk noise when connected to a speaker. Below that is the speed, which reads the encoders
on the car. The bottom button is the joystick which is able to move in the circle to drive
the car in the direction that the button is dragged to.


## Credits



<a href="https://github.com/jessicamalow">
  <img src="https://github.com/jessicamalow.png" height="50">
</a>

<a href="https://github.com/nicolemal">
  <img src="https://github.com/nicolemal.png" height="50">
</a>

<a href="https://github.com/jessicamalow"> Jessica Malow</a>  and <a href="https://github.com/nicolemal"> Nicole Malow 	



## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)

## License
[MIT](https://choosealicense.com/licenses/mit/)

Copyright (c) 2021 JoyRide

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

