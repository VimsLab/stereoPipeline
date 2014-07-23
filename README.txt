These files represent the stereo pipeline developed in the VIMS lab. The system is built for calibrated non-canonical stereo setups such as those commonly used in the lab. These functions and scripts will likely need to be modified to suit your needs. 

It is recommended that you run through the 'runStereoPipeline' script when you begin as this will run through setting up your parameters.


Step 1: calibrate the setup. Traditionally this has been done using DLR Calde and Callab

Step 2: Compute rectification. Use the 'calculateRectParams' function.

Step 3: reconstruct using 'computeStereo3D'. This function takes in the two images, and  a struct which encapsulates the rect_params struct and calib_params structs containing rectification and calibration parameters. the structure is detailed below.


Good rectification and calibration parameters are needed to ensure a good reconstruction as well as a few other parameters related to the disparity. 

Calibration parameters are determined through the calibration process using DLR calde and callab. A low rmse is critical. More info and a free download of these programs is available here: http://www.dlr.de/rmc/rm/desktopdefault.aspx/tabid-3925/6084_read-9197/ 

Good rectification sometimes requires repeated attempts. There is randomness in the process, so sometimes you will get errors such as 'For the rectification to succeed, the images must have 
enough corresponding points and the epipoles must be outside the images.' Repeat the attempts until rectification looks good. This function will display an anaglyph. A good rectification
will yield a convincing anaglyph with minimal distortion of the images

Disparity related parameters are adjusted within the code in the function 'computeStereo3D' the best choice of these parameters will depend on your data, and require some fine tuning. 
There is a commented point in the code which should be used to test the disparity before attempting to triangulate. uncomment that line and run the function and look at the disparity.



params struct breakdown:

Params	(the overall encapsulating struct)
	params.rect_params (parameters related to image rectification)
		params.rect_params.tform1 (the image transformation for the first image)
		params.rect_params.tform1 (the image transformation for the second image)
		params.rect_params.outputView (reference object for the outputview)
		params.rect_params.tref1 (reference object for the first image)
		params.rect_params.tref2 (reference object for the second image)
	params.calib_params (parameters related to calibration
		params.calib_params.T (transformation from first camera to the second)
		params.calib_params.R (rotation from first camera to the second)
		params.calib_params.left (parameters related to the left camera)
			params.calib_params.left.A (intrinsic parameters of left camera)
			params.calib_params.left.K1 (first order radial distortion estimate)
			params.calib_params.left.K2 (second order radial distortion estimate)
		params.calib_params.left (parameters related to the right camera)
			params.calib_params.right.A (intrinsic parameters of right camera)
			params.calib_params.right.K1 (first order radial distortion estimate)
			params.calib_params.right.K2 (second order radial distortion estimate)
				