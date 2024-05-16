classdef Camera < handle
    %CAMERA Class for the realsense camera used for tracking CF
    %

    properties(Access = private)
        pipe % controls camera
        pointcloud % allows the ability to create pointcloud
        depthRange % how far in the y direction cf will search
        widthRange % range of x directionality camera will search ( 0 +/- x )
        heigthRange % range of z directionality camera will search ( 0 +/- z )
        numCF % number of cfs to track
        cameraLocArr % location of camera in global reference frame

    end

    properties(Access = public)
    
    end

    methods(Access = public)

        function cam = Camera()
            %CAMERA Construct an instance of this class
            %   assign values for pipeline, pointcloud, and # of cf to
            %   track

            % initiates how many cfs will be tracked
            cam.numCF = 0;

            % initiates realsense properties
            cam.pipe = realsense.pipeline;
            cam.pointcloud = realsense.pointcloud;

            % initiates ranges for search
            cam.depthRange = 2;
            cam.widthRange = 1;
            cam.heigthRange = 1;
            
            % assigns camera location
            cam.cameraLocArr = [2.3 2.173 0.396];

        end

        function startCamera(cam)
            %STARTCAMERA starts camera tracking of enviroment
            cam.pipe.start();
        end

        function stopCamera(cam)
            %STOPCAMERA ends camera tracking of enviroment
            cam.pipe.stop();
        end

        function cam = addCF(cam)
            %ADDCF increases the number of cf that are being tracked
           
            cam.numCF = cam.numCF + 1;
       
        end

        function cam = removeCF(cam)
            %REMOVECF decreases the number of cf that are being tracked
           
            cam.numCF = cam.numCF - 1;
       
        end

        function numCF = currNumCF(cam)
            %CURRNUMCF gives the current number of cfs currently being
            %tracked

            numCF = cam.numCF;

        end
            


    end

    methods(Access = private)

        function currFrame = getRGBFrame(cam)
            %GETRGBFRAME retrieves the current RGB frame of the enviroment
            
            % perpares camera for capture frame
            frameSet = cam.pipe.wait_for_frames();
            % retrieves current RGB frame
            cf = frameSet.get_color_frame();
            % manipulates frame into usable RBG image
            dd = cf.get_data();
            currFrame = permute(reshape(dd' , [3 , cf.get_width(),cf.get_height()]) , [3,2,1]);

        end
      
        function verts = getDepthCloud(cam)
            %GETDEPTHCLOUD retrieves the current depth cloud frame of the
            %enviroment

            % perpares camera for capture frame
            frameSet = cam.pipe.wait_for_frames();
            % retrieves current depth frame
            df = frameSet.get_depth_frame();
            % manipulates frame into usable depth image
            pts = cam.pointcloud.calculate(df);
            verts = pts.get_vertices();

        end

        function globalPtArr = translatePts(cam , ptArr)
            %TRANSLATEPTS takes array of pts wrt to camera and translates 
            % them into array of pts wrt to global reference frame
            % Pts must be in [x , y , z] structure
            
            % creates array to store global points
            globalPtArr = zeros(height(ptArr) , 3);

            % updates the local camera pts to global pts
            globalPtArr(: , 1) = ptArr(: , 1) - cam.cameraLocArr(1);
            globalPtArr(: , 2) = ptArr(: , 2) - cam.cameraLocArr(2);
            globalPtArr(: , 3) = ptArr(: , 3) - cam.cameraLocArr(3);

        end
    end
end

