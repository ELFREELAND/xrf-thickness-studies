Program xy_mapping;

//--------------------------------------------------------------
// Program to demonstrate XY spx collection + camera image 10x & 100x at start & end points
// based off Bruker Caldera test script.  edited by dw 20190625
//
// Notes: 2 commented END points used in this program
// 1) at line 85, is used to estimate the time required for your scan
// 2) at line 141, is used to manually grab camera frames of the 10x and 100x zoom
//    Set the i,j step for your camera images using lines 94 & 95
//--------------------------------------------------------------



var   X,Y,Z,xyAcc,xySpeed,zSpeed,zAcc,
      MeasureState,PulseRate,Value,
      XEnd,YEnd,XOut,YOut,ZOut         : Double;
      List                             : TStringList;
      RealTime,LifeTime,MoPoState,
      CameraIndex,BufSize,TotalPoints,
      TotalTime,Test,Timer, TimeLeft   : LongInt;
      ActiveDetector,i,j               : LongInt;
      xSteps,ySteps                    : LongInt;
      XSpacing,YSpacing,Variable       : Double;
      Running,Canceled,Moving,
      HighQuality,DoShow,AutomaticOnly : BOOLEAN;
      MeasurementLifeTimePerPoint      : Cardinal;
      MeasurementRealTimePerPoint      : Cardinal;
      AFileName,Command                : String;
      aBmp : TBitmap;
      ImgWidth : word;
      aWidth,aHeight,APixelFormat : integer;



begin
   //
   AFileName:='C:\M4 user\Xrf\Data\ELF\20230613_CVD_2808_map\20230613_CVD_2808_60s_10x10pts';
   MeasurementLifeTimePerPoint:=60000; //in ms
   MeasurementRealTimePerPoint:=60000;  //in ms
   X:=112; //top left point
   Y:=87;  //top left point
   Z:=126.66;
   xySpeed:=10;
   xyAcc:=10;
   zAcc:=10;
   zSpeed:=10;
   Value:= 70;
   MoveStageToXY(X,Y,xySpeed,xyAcc,false);
   //
   //MoveStageToZ(Z,zSpeed,zAcc,true);
   xSteps:=10;    //# of X steps
   ySteps:=10;    //# of Y steps
   //
   XSpacing:=1.5;  //in mm
   YSpacing:=1.5;  //in mm
   //
   XOut := 999;
   YOut := 999;
   ZOut := 999;
   Moving := False;
   MoPoState := 999;
   //
   XEnd := X - (xSteps-1)*XSpacing;
   //writeln('X End: ' + IntToStr(XEnd));
   YEnd := Y - (ySteps-1)*YSpacing;
   //writeln('Y End: ' + IntToStr(YEnd));
   //
   MoveStageToXY(XEnd,YEnd,xySpeed,xyAcc,false);
   sleep(2000);
   TotalPoints :=  ySteps;
   TotalPoints := TotalPoints * xSteps;
   TotalTime := TotalPoints
   TotalTime := TotalTime * 2 * MeasurementLifeTimePerPoint / 1000 / 60;
   //
   writeln('X steps: ' + IntToStr(xSteps))
   writeln('Y steps: ' + IntToStr(ySteps))
   writeln('total points: ' + IntToStr(TotalPoints))
   writeln('total time: ' + IntToStr(TotalTime) + ' (in minutes)')
   //
   //create list for X,Y,Z,file name
   LIST := TStringList.Create;
   //
   ClearSpectrumDisplay;
   //////////////////
   // USE this END to during your time and position estimation
   // Comment it out when you are ready to run!!
   //
   //end.
   //////////////////
   //
   // Actual run code follows....
   //
   //take out initial stage hysteresis
   MoveStageToXY((X+0.1),(Y+0.1),xySpeed,xyAcc,True);
   MoveStageToXY((X),(Y),xySpeed,xyAcc,True);
   //
   //Manual camera grab section (needed if large scans are performed
   i:=0   //x steps
   j:=0   //y steps
   MoveStageToXY(X-XSpacing*i,Y-YSpacing*j,xySpeed,xyAcc,True);
   sleep(200);
   //
   //10x camera image capture at beginning of scan
   // camera 0 == 100x, 1 == 10x, 2 == door cam
   CameraIndex := 0;
   HighQuality := true;
   DoShow := true;
   AutomaticOnly := true;
   //turn on camera acquisition
   EnableImageAcquisition()
   //find camera parameters
   GetCameraProps(CameraIndex,aWidth,aHeight,aPixelFormat);
   ImgWidth := aWidth;
   aBmp := TBitmap.Create;
   aBmp.Width := aWidth;
   aBmp.Height :=aHeight;
   //GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp,BufSize);
   //GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp,BufSize);
   GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp);
   GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp);
   aBmp.savetofile(AFileName+'camera_100x_'+IntToStr(i)+'_'+IntToStr(j)+'.bmp')
   writeln('image saved')
   // camera end
   //
   //10x camera image capture at the end of the scan
   CameraIndex := 1;
   HighQuality := true;
   DoShow := true;
   AutomaticOnly := true;
   //turn on camera acquisition
   EnableImageAcquisition()
   //find camera parameters
   GetCameraProps(CameraIndex,aWidth,aHeight,aPixelFormat);
   ImgWidth := aWidth;
   aBmp := TBitmap.Create;
   aBmp.Width := aWidth;
   aBmp.Height :=aHeight;
   GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp);
   GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp);
   aBmp.savetofile(AFileName+'camera_10x_'+IntToStr(i)+'_'+IntToStr(j)+'.bmp')
   writeln('image saved')
   // camera end
   //
   ////////////////
   // USE this END to run several camera images at arbitrary i,j, but not run the XRF scans!
   // Comment it out when you are ready to run!!
   //
   //end.
   //
   Command := '$XR + 1';
   Test := SendRCLCommand(0,False,Command);
   //
   //
   ///////////////
   Command:='XR+';
   SendRCLCommand(0,true,Command);
   FOR i:=0 TO xSteps-1 DO
   BEGIN
      FOR j:=0 TO ySteps-1 DO
      BEGIN
         //IF j:=0 THEN
         //BEGIN
         //move to target position
         //MoveStageToXY(X-XSpacing*i+.05,Y-YSpacing*j,xySpeed,xyAcc,True);
         //sleep(200);
         //MoveStageToXY(X-XSpacing*i,Y-YSpacing*j,xySpeed,xyAcc,True);
         //sleep(200);
         //END;
         //IF NOT j:0 THEN
         //BEGIN
         //move to target position
         MoveStageToXY(X-XSpacing*i,Y-YSpacing*j,xySpeed,xyAcc,True);
         //END;
         writeln('i: ' + IntToStr(i))
         writeln('j: ' + IntToSTR(j))
         //check target position
         GetStagePositionAndState(XOut,YOut,ZOut,Moving,MoPoState)
         //add target position to a list
         List.Add(FloatToStr(XOut) + ',' +
         FloatToStr(YOut)+ ',' +
         FloatToStr(ZOut) + ',' +
         AFileName + '_' + IntToStr(i) + '_' + IntToStr(j));
         // turn on detector towards computer
         ActiveDetector:=1;
         SPUCombineSpectrometer(ActiveDetector)
         // collect data from detector towards computer
         SPUStartLifeTimeMeasurement(ActiveDetector,MeasurementLifeTimePerPoint);
         Timer :=1;
         sleep(1000);
         REPEAT
            SPUGetMeasureState(ActiveDetector,Running,MeasureState,PulseRate,RealTime,Lifetime);
            sleep(1000);
            Timer := Timer +1;
            //writeln('Measure State: ' + FloatToStr(MeasureState));
            //writeln('RealTime: ' + IntToStr(RealTime));
            //writeln('LifeTime: ' + IntToStr(LifeTime));
            Variable := (RealTime * 1.0) / (LifeTime * 1.0);
            //writeln('Dead Time ratio: ' + FloatToStr(Variable));
         UNTIL (LifeTime > (MeasurementLifeTimePerPoint - 10000)) OR (MeasureState > 80.0);
         writeln('1000ms counter det1: ' + IntToStr(Timer));
         writeln('Measure State: ' + FloatToStr(MeasureState));
         writeln('RealTime: ' + IntToStr(RealTime));
         writeln('LifeTime: ' + IntToStr(LifeTime));
         writeln('Dead Time ratio: ' + FloatToStr(Variable));
         TimeLeft := round((MeasurementLifeTimePerPoint - LifeTime) * Variable);
         writeln('TimeLeft: ' + IntToStr(TimeLeft));
         sleep(TimeLeft);
         sleep(1000);
         SPUReadSpectrum(ActiveDetector);
         SaveSpectrum(ActiveDetector,AFileName+'det_1_'+IntToStr(i)+'_'+IntToStr(j)+'.spx')
         writeln('det 1 scan done')
         //Turn on detector towards back door
         ActiveDetector:=2;
         SPUCombineSpectrometer(ActiveDetector)
         //collect data from detector away from computer
         SPUStartLifeTimeMeasurement(ActiveDetector,MeasurementLifeTimePerPoint);
         Timer :=1;
         sleep(1000);
         REPEAT
            SPUGetMeasureState(ActiveDetector,Running,MeasureState,PulseRate,RealTime,Lifetime);
            sleep(1000);
            Timer := Timer +1;
            //writeln('Measure State: ' + FloatToStr(MeasureState));
            //writeln('RealTime: ' + IntToStr(RealTime));
            //writeln('LifeTime: ' + IntToStr(LifeTime));
            Variable := (RealTime * 1.0) / (LifeTime * 1.0);
            //writeln('Dead Time ratio: ' + FloatToStr(Variable));
         UNTIL (LifeTime > (MeasurementLifeTimePerPoint - 10000)) OR (MeasureState > 80.0);
         writeln('1000ms counter det1: ' + IntToStr(Timer));
         writeln('Measure State: ' + FloatToStr(MeasureState));
         writeln('RealTime: ' + IntToStr(RealTime));
         writeln('LifeTime: ' + IntToStr(LifeTime));
         writeln('Dead Time ratio: ' + FloatToStr(Variable));
         TimeLeft := round((MeasurementLifeTimePerPoint - LifeTime) * Variable);
         writeln('TimeLeft: ' + IntToStr(TimeLeft));
         sleep(TimeLeft);
         sleep(1000);
         SPUReadSpectrum(ActiveDetector)
         SaveSpectrum(ActiveDetector,AFileName+'det_2_'+IntToStr(i)+'_'+IntToStr(j)+'.spx')
         writeln('det 2 scan done')
      END;
   END;
   //
   //position at last step for pictures of sample
   MoveStageToXY((X+0.1),(Y+0.1),xySpeed,xyAcc,True);
   i:=xSteps-1
   j:=ySteps-1
   MoveStageToXY((X-XSpacing*i+0.1),(Y-YSpacing*j+0.1),xySpeed,xyAcc,True);
   MoveStageToXY(X-XSpacing*i,Y-YSpacing*j,xySpeed,xyAcc,True);
   sleep(200);
   //
   //100x camera image capture at the end of the scan
   CameraIndex := 0;
   HighQuality := true;
   DoShow := true;
   AutomaticOnly := true;
   //turn on camera acquisition
   EnableImageAcquisition()
   //find camera parameters
   GetCameraProps(CameraIndex,aWidth,aHeight,aPixelFormat);
   ImgWidth := aWidth;
   aBmp := TBitmap.Create;
   aBmp.Width := aWidth;
   aBmp.Height :=aHeight;
   GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp);
   GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp);
   aBmp.savetofile(AFileName+'camera_100x_'+IntToStr(i)+'_'+IntToStr(j)+'.bmp')
   writeln('image saved')
   // camera end
   //
   //10x camera image capture at the end of the scan
   CameraIndex := 1;
   HighQuality := true;
   DoShow := true;
   AutomaticOnly := true;
   //turn on camera acquisition
   EnableImageAcquisition()
   //find camera parameters
   GetCameraProps(CameraIndex,aWidth,aHeight,aPixelFormat);
   ImgWidth := aWidth;
   aBmp := TBitmap.Create;
   aBmp.Width := aWidth;
   aBmp.Height :=aHeight;
   GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp);
   GetCameraImage(CameraIndex,ImgWidth,HighQuality,aBmp);
   aBmp.savetofile(AFileName+'camera_10x_'+IntToStr(i)+'_'+IntToStr(j)+'.bmp')
   writeln('image saved')
   // camera end
   //
   // save of position list file
   List.SaveToFile(AFileName + 'XYZ.txt');
   List.Free;
   //
   Command:='XR-';
   SendRCLCommand(0,true,Command);
   //
end.