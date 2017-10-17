# Love2D-Shadowcasting
Implementation of shadowcasting in Love2D.

## How to run:
Install [love](https://github.com/love2d/love).
Run love with the folder as the argument.

Left click to insert boxes, right click to insert lights. Press space to toggle gravity.

## How it works:

For each light source :
* Record the angle from light to each vertex of every box.
* Sort the above array.
* Iterate through the array, raycasting from the light source towards each angle, recording the hit positions.
* Draw triangles using above information.

## Screenshots
![](https://i.imgur.com/pQm8rcG.png);
![](https://i.imgur.com/u9jkN1q.png);