clear all
clear
clc
sim=remApi('remoteApi');
sim.simxFinish(-1);

clientID=sim.simxStart('127.0.0.1',19999,true,true,5000,5);
c=0;
Vrob=0.6; 
if (clientID>-1)
    disp('connected')
    %Handle
    [returnCode,left_Motor]=sim.simxGetObjectHandle(clientID,'Pioneer_p3dx_leftMotor',sim.simx_opmode_blocking);
    [returnCode,right_Motor]=sim.simxGetObjectHandle(clientID,'Pioneer_p3dx_rightMotor',sim.simx_opmode_blocking); 
    [returnCode,front_Sensor]=sim.simxGetObjectHandle(clientID,'Pioneer_p3dx_ultrasonicSensor5',sim.simx_opmode_blocking);
    [returnCode,left_Sensor]=sim.simxGetObjectHandle(clientID,'Pioneer_p3dx_ultrasonicSensor4',sim.simx_opmode_blocking);
    %[returnCode,left2_Sensor]=sim.simxGetObjectHandle(clientID,'Pioneer_p3dx_ultrasonicSensor16',sim.simx_opmode_blocking);
    [returnCode,right2_Sensor]=sim.simxGetObjectHandle(clientID,'Pioneer_p3dx_ultrasonicSensor7',sim.simx_opmode_blocking);  
    [returnCode,camera]=sim.simxGetObjectHandle(clientID,'Vision_sensor',sim.simx_opmode_blocking);

    
    %[returnCode]=sim.simxSetJointTargetVelocity(clientID,left_Motor,0.1,sim.simx_opmode_blocking);
    [returnCode,detectionState,detectedPoint,~,~]=sim.simxReadProximitySensor(clientID,front_Sensor,sim.simx_opmode_streaming);
    [returnCode,detectionState,detectedPoint,~,~]=sim.simxReadProximitySensor(clientID,left_Sensor,sim.simx_opmode_streaming);
    %[returnCode,detectionState,detectedPoint,~,~]=sim.simxReadProximitySensor(clientID,left2_Sensor,sim.simx_opmode_streaming);
    [returnCode,detectionState,detectedPoint,~,~]=sim.simxReadProximitySensor(clientID,right2_Sensor,sim.simx_opmode_streaming); 
    [returnCode,resolution,image]=sim.simxGetVisionSensorImage2(clientID,camera,1,sim.simx_opmode_streaming);
    
    
    
    
    for i=1:200
        [returnCode,detectionState,detectedPoint,~,~]=sim.simxReadProximitySensor(clientID,front_Sensor,sim.simx_opmode_buffer);
        [returnCode,detectionState,detectedPoint,~,~]=sim.simxReadProximitySensor(clientID,left_Sensor,sim.simx_opmode_buffer);
        %[returnCode,detectionState,detectedPoint,~,~]=sim.simxReadProximitySensor(clientID,left2_Sensor,sim.simx_opmode_buffer);
        [returnCode,detectionState,detectedPoint,~,~]=sim.simxReadProximitySensor(clientID,right2_Sensor,sim.simx_opmode_buffer); 
        [returnCode,resolution,image]=sim.simxGetVisionSensorImage2(clientID,camera,1,sim.simx_opmode_buffer);
        a=norm(detectedPoint);
            if a>0.01 
            disp('Forward')
            [returnCode]=sim.simxSetJointTargetVelocity(clientID,right_Motor,Vrob,sim.simx_opmode_blocking);
            [returnCode]=sim.simxSetJointTargetVelocity(clientID,left_Motor,Vrob,sim.simx_opmode_blocking);
            
            end
            if  (0.3<a) && (a<0.75)   
            disp('Turn')
            for j=1:10
                    [returnCode]=sim.simxSetJointTargetVelocity(clientID,right_Motor,-Vrob,sim.simx_opmode_blocking);
                    [returnCode]=sim.simxSetJointTargetVelocity(clientID,left_Motor,Vrob,sim.simx_opmode_blocking);  
                    
            end
            else 
                 [returnCode]=sim.simxSetJointTargetVelocity(clientID,right_Motor,Vrob,sim.simx_opmode_blocking);
                 [returnCode]=sim.simxSetJointTargetVelocity(clientID,left_Motor,Vrob,sim.simx_opmode_blocking);   %move forward
            end
          imshow(image);
        disp(norm(detectedPoint))   
        pause(0.1)
    end
    
    
    sim.simxFinish(-1);
end

sim.delete();